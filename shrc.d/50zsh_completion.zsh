#!/bin/zsh

# For details on this, man zshoptions and man zshcompsys

unsetopt menu_complete
unsetopt flowcontrol
# Automatically use menu completion after the second consecutive request for completion.
setopt auto_menu
setopt complete_in_word
setopt always_to_end
setopt auto_name_dirs
setopt globcomplete

# Make cd push the old directory onto the directory stack
setopt auto_pushd
# Don't push multiple copies of the same directory onto the directory stack
setopt pushd_ignore_dups
# Don't print the directory stack after pushd or popd
setopt pushd_silent


autoload -Uz compinit

zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
mkdir -p "${zcompdump:h}"

# First run (or missing dump): build it
# If having troubles with completion, delete the zcompdump file
if [[ ! -f "$zcompdump" ]]; then
  compinit -i -d "$zcompdump"
else
  # Reuse cache (avoids most of the expensive work)
  compinit -C -i -d "$zcompdump"
fi

# The zsh/complist module offers three extensions to completion listings: the
# ability to highlight matches in such a list, the ability to scroll through
# long lists and a different style of menu completion.
zmodload -i zsh/complist

if whence dircolors >/dev/null; then
    eval "$(dircolors -b)"
    zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"
else
    export CLICOLOR=1
    zstyle ':completion:*:default' list-colors ""
fi

# Information on the completion system:
# http://zsh.sourceforge.net/Doc/Release/Completion-System.html
# https://thevaluable.dev/zsh-completion-guide-examples/
#
# List of styles for the completion system:
#   man zshcompsys - Search for "Standard Styles"
# List of tags:
#   man zshcompsys - Search for "Standard Tags"
#
# Fields are:
# :completion:function:completer (with dropped underscore):command:argument:tag

# Menu selection will be started unconditionally
zstyle ':completion:*:*:*:*:*' menu select
# "processes" is standard tag for process identifiers
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u `whoami` -o pid,user,comm -w -w"
# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME-$HOME/.cache}/zsh/.zcompcache"
zstyle ':completion:*' accept-exact '*(N)'
# Use this for full file names
#zstyle ':completion:*' file-list all
zstyle ':completion:*' completer _extensions _complete _approximate
# case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Group different types of matches
zstyle ':completion:*' group-name ''
# Display a short description of the matches in a completion list
zstyle ':completion:*:descriptions' format %d
zstyle ':completion:*:descriptions' format %B%d%b
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
# Set the order of groups of matches for cd and pushd
zstyle ':completion:*:complete:(cd|pushd):*' tag-order 'local-directories named-directories path-directories'

# Don't complete uninteresting users -- Andrey's list
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache avahi beaglidx bin cacti canna clamav daemon \
        dbus distcache dovecot fax ftp games gdm gkrellmd gopher \
        hacluster haldaemon halt hsqldb ident junkbust ldap lp mail \
        mailman mailnull mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
        operator pcap postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs
