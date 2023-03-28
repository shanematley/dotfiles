#!/bin/bash

stream_to_marked2() {
    local script_path=$(cd "$(dirname "$(readlink -f "$0")")" || exit; pwd;)
    "${script_path}/venv/bin/python" "${script_path}/stream_to_marked2.py"
}

stream_to_marked2
