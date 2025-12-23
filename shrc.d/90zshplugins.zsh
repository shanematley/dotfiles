
MY_LOCAL_PLUGINS="${0:a:h}/zshplugins"

# TODO: add unixorn/git-extra-commands?
# TODO: add RobSis/zsh-completion-generator

source "${MY_LOCAL_PLUGINS}/zsh-bd/bd.zsh"
source "${MY_LOCAL_PLUGINS}/zsh-autosuggestions/zsh-autosuggestions.zsh"

################################################################################
# ZAW
################################################################################

source "${MY_LOCAL_PLUGINS}/zaw/zaw.zsh"

bindkey '^R' zaw-history
bindkey '^X\t' zaw-cdr
bindkey '^X;' zaw
if zaw-print-src|grep -q searcher; then
    bindkey '^X^a' zaw-searcher
fi
bindkey '\eg' zaw-git-files
bindkey '\ep' zaw-process
bindkey '^X^b' zaw-git-recent-branches
bindkey '^X^l' zaw-git-log

bindkey -M filterselect '\e' send-break
bindkey -M filterselect '^J' down-line-or-history
bindkey -M filterselect '^K' up-line-or-history
zstyle ':filter-select' extended-search yes
zstyle ':filter-select:highlight' matched bg=black,fg=cyan
zstyle ':filter-select:highlight' marked bg=blue,fg=white
zstyle ':filter-select:highlight' title fg=yellow
zstyle ':filter-select:highlight' selected standout
zstyle ':filter-select' max-lines 20
zstyle ':filter-select' rotate-list yes
zstyle ':filter-select' case-insensitive yes
zstyle ':zaw:git-files' default zaw-callback-append-to-buffer
zstyle ':zaw:git-files' alt zaw-callback-edit-file
zstyle ':zaw:git-recent-branches' alt zaw-callback-append-to-buffer

unset "zaw_sources[perldoc]"
unset "zaw_sources[locate]"
unset "zaw_sources[screens]"
unset "zaw_sources[git-files-legacy]"

################################################################################
# zsh-syntax-highlighting
################################################################################

# Required to be the last thing sourced according to https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md
source "${MY_LOCAL_PLUGINS}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
