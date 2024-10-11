#!/usr/bin/env bash

set -Eeuo pipefail
trap "echo Error in: \${FUNCNAME:-top level}, line \${LINENO}" ERR

section()   { printf "\n## \033[0;35m%s\033[0m\n\n" "$1"; }
info()      { printf "\r  [ \033[00;34m.\033[0m ] %s\n" "$1"; }
user()      { printf "\r  [ \033[0;33m?\033[0m ] %s\n" "$1"; }
success()   { printf "\r\033[2K  [ \033[00;32m✔\033[0m ] %s\n" "$1"; }
fail()      { printf "\r\033[2K  [ \033[0;31m✘\033[0m ] %s\n" "$1"; echo ''; exit; }
softfail () { printf "\r\033[2K  [ \033[0;31m✘\033[0m ] %s\n" "$1"; }


check() {
  local -r message=$1
  shift
  if "$@" >/dev/null 2>&1; then
    success "$message"
  else
    softfail "Failed: $message"
    return 1
  fi
}

export -f section info user success fail softfail check
