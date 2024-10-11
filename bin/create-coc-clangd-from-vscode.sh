#!/bin/bash

set -euo pipefail

vscode_settings=.vscode/settings.json
coc_settings=.vim/coc-settings.json

if [[ ! -r "$vscode_settings" ]]; then
    echo "Cannot find $vscode_settings. Aborting"
    exit 1
fi

required_clangd_key=$(jq '{
            enabled: true,
            path: .["clangd.path"],
            arguments: .["clangd.arguments"]
    }' "${vscode_settings}")
            # Use this above if we need to replace the workspace_folder variable. Perhaps not though?
            #arguments: .["clangd.arguments"] | map( gsub("\\$\\{workspaceFolder\\}"; "'"$PWD"'"))

echo -e "## Clangd config from $vscode_settings\n"
echo "$required_clangd_key" | jq .

if [[ -r "$coc_settings" ]]; then
    echo -e "\n## Before\n"
    jq . "$coc_settings"
else
    echo -e "\n## No $coc_settings. Creating\n"
    echo "{}" > "${coc_settings}"
fi

jq ".clangd = $required_clangd_key" "${coc_settings}" > "${coc_settings}.tmp" && mv "${coc_settings}.tmp" "${coc_settings}"

echo -e "\n## After\n"
jq . "$coc_settings"
