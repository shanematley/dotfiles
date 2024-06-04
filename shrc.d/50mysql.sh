backup_k8s_mysql() {
  local ns
  local selector
  local db_name
  local pod_name
  local backup_location
  local dry_run
  local k8_context
  declare -a k8s_db_params

  while getopts 'c:s:d:o:l:hn' c; do
    case $c in
    n) dry_run=1 ;;
    c) k8_context="$OPTARG" ;;
    s) ns="$OPTARG" ;;
    d) db_name="$OPTARG" ;;
    o) backup_location="$OPTARG" ;;
    l) selector="$OPTARG" ;;
    h)
      echo "Usage: backup_k8s_mysql [-s namespace] -l selector -o dest_file.sql[.gz] -d database_name"
      return 0
      ;;
    *) return 0 ;;
    esac
  done

  : "${db_name:?Missing -d db name}"
  : "${backup_location:?Missing -o backup location}"
  : "${selector:?Missing -l selector}"

  if ! command -v "kubectl" >/dev/null 2>&1; then
      echo "Cannot find kubectl. Ensure kubectl is on the PATH before using backup_k8s_mysql" >&2
      return 1
  fi

  if [[ -n ${ns} ]]; then
    k8s_db_params+=("-n" "${ns}")
  fi
  k8s_db_params+=("-l" "${selector}")

  local args
  args=(kubectl get pod -n "${ns}" -l "${selector}" -o "jsonpath={.items[0].metadata.name}")
  if [[ -n "$k8_context" ]]; then
      args+=(--context "$k8_context")
  fi
  if [[ $dry_run == 1 ]]; then
      echo "Would run:"
      printf '%s\n' "${args[@]}"
      return
  else
    pod_name="$("${args[@]}")"
  fi
  if [[ -z ${pod_name} ]]; then
    echo "Failed to find k8s pod using selector ${selector} (namespace: {$ns})"
    return 1
  fi

  local kubectl_cmd
  # shellcheck disable=SC2016 # MYSQL_ROOT_PASSWORD is expanded on remote end
  kubectl_cmd=(exec -n "${ns}" "${pod_name}")
  if [[ -n "$k8_context" ]]; then
      kubectl_cmd+=(--context "$k8_context")
  fi
  kubectl_cmd+=(-- sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" '"${db_name}")

  #echo "Running: "
  #printf '%s\n' "${kubectl_cmd[@]}"

  if [[ ${backup_location} =~ .*\.gz$ ]]; then
    kubectl "${kubectl_cmd[@]}" | gzip >"${backup_location}" || { 1>&2 echo "Failed to backup up ${db_name} on pod ${pod_name} to ${backup_location}"; return 1; }
  else
    kubectl "${kubectl_cmd[@]}" >"${backup_location}" || { 1>&2 echo "Failed to backup up ${db_name} on pod ${pod_name} to ${backup_location}"; return 1; }
  fi
  echo "Backed up ${db_name} on pod ${pod_name} to ${backup_location}"
}

restore_k8s_mysql() {
  local ns
  local selector
  local db_name
  local pod_name
  local backup_location
  local drop_db
  declare -a k8s_db_params
  drop_db=

  while getopts 'xn:d:i:l:h' c; do
    case $c in
    n) ns="$OPTARG" ;;
    d) db_name="$OPTARG" ;;
    i) backup_location="$OPTARG" ;;
    l) selector="$OPTARG" ;;
    x) drop_db=1;;
    h)
      echo "Usage: restore_k8s_mysql [-n namespace] -s selector -i dest_file.sql[.gz] -d database_name [-x]    (where -x drops/creates db)"
      return 0
      ;;
    *) return 0 ;;
    esac
  done

  : "${db_name:?Missing -d db name}"
  : "${backup_location:?Missing -i backup location}"
  : "${selector:?Missing -l selector}"

  if [[ -n ${ns} ]]; then
    k8s_db_params+=("-n" "${ns}")
  fi
  k8s_db_params+=("-l" "${selector}")

  pod_name="$(kubectl get pod -n "${ns}" -l "${selector}" -o jsonpath='{.items[0].metadata.name}')"
  if [[ -z ${pod_name} ]]; then
    echo "Failed to find k8s pod using selector ${selector} (namespace: {$ns})"
    return 1
  fi

  local -a kubectl_cmd
  local -a kubectl_base
  # shellcheck disable=SC2016 # MYSQL_ROOT_PASSWORD is expanded on remote end
  kubectl_base=(exec -i -n "${ns}" "${pod_name}" -- sh -c 'exec mysql -u root -p"$MYSQL_ROOT_PASSWORD"')
  # shellcheck disable=SC2016 # MYSQL_ROOT_PASSWORD is expanded on remote end
  kubectl_cmd=(exec -i -n "${ns}" "${pod_name}" -- sh -c 'exec mysql -u root -p"$MYSQL_ROOT_PASSWORD" '"$db_name")

  # Destroy and create db
  if [[ -n $drop_db ]]; then
    echo "Recreating DB"
    if ! kubectl "${kubectl_base[@]}" << EOF
DROP DATABASE IF EXISTS $db_name;
CREATE DATABASE $db_name;
EOF
    then
      echo "Failed to delete and recreate the database"
      return 1
    fi
  fi

  local sql_cmd
  sql_cmd=""
  if [[ ${backup_location} =~ .*\.gz$ ]]; then
    while read -r x; do
        sql_cmd="${sql_cmd}"$'\n'"${x}"
    done < <(zcat < "${backup_location}")
  else
    while read -r x; do
        sql_cmd="${sql_cmd}"$'\n'"${x}"
    done < <(cat "${backup_location}")
  fi

  if ! echo "$sql_cmd" | kubectl "${kubectl_cmd[@]}"; then
    1>&2 echo "Failed to restore ${db_name} on pod ${pod_name} from ${backup_location}"
    return 1
  fi
  echo "Restored ${db_name} on pod ${pod_name} from ${backup_location}"
}
