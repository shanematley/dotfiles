_btzf_group_tests_into_single_command() {
    # Takes a list of test targets with filters and groups them per
    # test-target. The test target and test filter for each entry is separated
    # by a space.
    #
    # ("//test1 TestSuiteA.*" "//test1 TestSuiteB.First" "//other:tests OtherTests.A" "//test1 TestSuiteB.Second" "//test3 Foo.*:Bar.*" "//core/... A.*:B.*")
    #
    # ...becomes...
    #
    # //test3 //core/... //other:tests //test1
    # Foo.*:Bar.*:A.*:B.*:OtherTests.A:TestSuiteA.*:TestSuiteB.First:TestSuiteB.Second

    local -A targets_to_tests
    local test_components
    local test_suite

    for test in "${@}"; do
        test_components=(${(s: :)test})
        test_suite=${test_components[1]}
        if [[ ${#test_components[@]} != 2 ]]; then
            echo "Invalid test_suite: ${test}" >&2
            return 1
        fi
        targets_to_tests[$test_suite]="${targets_to_tests[$test_suite]} ${test_components[2]}"
        targets_to_tests[$test_suite]="${targets_to_tests[$test_suite]## }"
    done

    echo "${(k)targets_to_tests}"
    echo "${(vj|:|)targets_to_tests// /:}"
}

btzf() {
    # Takes the provided test target, and allows you to select one or more tests to filter on.
    # Usage: btzf <bazel test target>
    # e.g. btzf //mytarget/test:test
    # or   btzf //...
    local -r CACHE_FILE="${XDG_CACHE_DIR:-$HOME/.cache}/btzf.zsh" # TODO

    local targets
    targets=( $(bazel query 'kind("cc_test rule", '"${1}"')') )
    #echo -e "Targets are:\n${(F)targets}"

    local available_tests
    local output
    available_tests=()
    local -A tests_for_target
    local tests_for_this_target

    # Query for the tests in each test target
    for target in ${targets}; do
        output="$(bazel test ${target} --test_arg=--gtest_list_tests --test_output=all 2>/dev/null | sed -n '/===/,/===/{//b;p}' | sed 's/  #.*//')"

        if [[ $? -ne 0 ]]; then
            echo "Failed to discover tests in query $target" 2>&1
            continue
        fi

        if [[ -z "$output" ]]; then
            echo "No test targets found for query $target" 2>&1
            continue
        fi

        tests_for_this_target=()
        available_tests+=( $target )
        while read -r line; do
            if [[ "$line" =~ .*\\. ]]; then
                first="$line"
                available_tests+=( "$target $first*" )
                tests_for_this_target+=("$first*")
                continue
            fi
            available_tests+=( "$target ${first## }$line" )
        done <<< "$output"
        tests_for_target[$target]="${(j|:|)tests_for_this_target}"
    done

    local selected_tests

    selected_tests="$(echo "${(F)available_tests}" | fzf \
        --expect=alt-enter,ctrl-y \
        --preview='rg $(sed "s#.*\.\(.*\)#\1#; s#/.*##; s#\*" <<< {-1}) -A9999 -I -t cpp | bat --color=always --style=numbers --language=cpp' -m)"
    selected_tests=("${(@f)selected_tests}")
    cmd=${selected_tests[1]}
    selected_tests=("${(@)selected_tests:1}")

    if [[ -z $selected_tests ]]; then
        return
    fi

    # When there is no filter and the whole target was selected, add all test suites in the test target
    for i in {1..$#selected_tests}; do
        target="${selected_tests[$i]}"
        if [[ $selected_tests[$i] != *" "* ]]; then
            selected_tests[$i]="${target} ${tests_for_target[$target]}"
        fi
    done

    echo -e "Selected Tests: \n- ${(pj:\n- :)selected_tests}"

    local grouped
    local test_targets
    local filter

    grouped=$(_btzf_group_tests_into_single_command "${(@)selected_tests}")
    grouped=("${(f)grouped}")
    test_targets="${grouped[1]}"
    filter="${grouped[2]}"

    if [[ -z $cmd ]]; then
        # Default: replace the buffer
        print -z -- "bazel test $test_targets --test_filter='$filter' ${@:2}"
    elif [[ $cmd == ctrl-y ]]; then
        # ctrl-y: copy resultant filter
        echo -n "$filter" | yank.sh
    else
        echo "Not sure what command that was: $cmd"
    fi

}

# For testing the above
#btzf_group_tests() {
#    local selected_tests
#    selected_tests=("//test1 TestSuiteA.*" "//test1 TestSuiteB.First" "//other:tests OtherTests.A" "//test1 TestSuiteB.Second" "//test3 Foo.*:Bar.*" "//core/... A.*:B.*")
#
#    local final_test_target_and_filters
#    echo -e "From:\n- ${(pj:\n- :)selected_tests}"
#    final_test_target_and_filters=$(_btzf_group_tests_into_single_command "${(@)selected_tests}")
#    final_test_target_and_filters=("${(f)final_test_target_and_filters}")
#    echo -e "\n\nTo: \n- ${(pj:\n- :)final_test_target_and_filters}"
#}

# Both of the following require build events which can be achieved by passing the following to bazel build or bazel test:
#    --build_event_json_file=build_events.json

function bazel_test_logs_from_build_events {
    jq -r 'if has("testResult") then ( .testResult.testActionOutput | map(.uri) | .[] ) else empty end' "$1" \
        | sed -Ene 's|^file://(.*\.log$)|\1|p'
}

function bazel_outputs_from_build_events {
    jq -r 'if has("namedSetOfFiles") then ( .namedSetOfFiles.files | map(.uri) | .[] ) else empty end' "$1" \
        | sed -Ee 's|^file://||'
}
