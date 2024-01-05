# Build 
btzf() {
    # Usage: btzf <bazel test target>
    # e.g. btzf //mytarget/test:test
    local -r CACHE_FILE="${XDG_CACHE_DIR:-$HOME/.cache}/btzf.zsh" # TODO

    local output
    output="$(bazel test "$1" --test_arg=--gtest_list_tests --test_output=all 2>/dev/null | sed -n '/===/,/===/{//b;p}' | sed 's/  #.*//')"

    if [[ $? -ne 0 ]]; then
        echo "Failed to discover tests in target $1" 2>&1
        return
    fi

    if [[ -z "$output" ]]; then
        echo "No filters found for target $1" 2>&1
        return
    fi

    local first
    first=''

    local filter
    filter="$(while read -r line; do
        if [[ "$line" =~ .*\\. ]]; then
            first="$line"
            continue
        fi
        echo "${first## }$line"
    done <<< "$output" \
      | fzf --preview='rg $(sed "s#.*\.\(.*\)#\1#; s#/.*##" <<< {-1}) -A9999 -I -t cpp | bat --color=always --style=numbers --language=cpp' -m)"

    print -z -- "bazel test $1 --test_filter=$filter ${@:2}"
}


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
