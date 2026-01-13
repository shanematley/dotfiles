dotfiles
========

These are my dotfiles. Currently this includes:

 * Vim Configuration and Vundle bundles
 * Tmux Configuration
 * inputrc

Installation
============

To install:

    ./install.sh [-v] [-p] [-h]

The installation process will create soft-links to the files in this repository,
but will not overwrite files if they already exist. (Soft-links on the other
hand will be replaced.)

Use -v to install VIM vundle and bundles and -p to install powerline

To change shell, run following and log out/in:

    chsh -s /bin/zsh

Vim on Windows
=======================

Vundle files will be installed to %USERPROFILE%\vimfiles\bundle. To accomplish
this add the following to %USERPROFILE%/_vimrc (or appropriate location):

	source %USERPROFILE%\dotfiles\vimrc
	
Then run:

	install_vundle.cmd

Troubleshooting
===============

If for whatever reason git has issues retrieving a remote repository (e.g. Vundle
is failing to install things. Ensure the following is not set in .gitconfig:

    transfer.fsckObjects = true

Troubleshooting Tmux
====================

If tmux is exiting immediately on masOS with "[Exited]", it may be that
reattach-to-user-namespace is not installed. Install this using:

    brew install reattach-to-user-namespace

Profiling ZSH
=============

To time changes to zsh, run the following:

    time zsh -ic exit

To profile, add the following line to the top of `.zshrc` and open a new shell. Then run `zprof|less` to view the profile information.

    zmodload zsh/zprof

Bin Scripts
===========

The `bin/` directory contains various utility scripts:

* **24-bit-color-test.sh** - Display 24-bit color test patterns in terminal
* **bb** - Run a command in the background with stdout/stderr suppressed
* **confluence-group.sh** - Wrapper to run confluence-group Python tool with pyenv
* **confluence-groups.py** - Manage Confluence groups (list groups, find groups, list users)
* **create-coc-clangd-from-vscode.sh** - Convert VSCode clangd settings to coc.nvim configuration
* **dmesg_time.sh** - Convert dmesg timestamps to human-readable dates
* **ds-destroy** - Delete all .DS_Store files in the current directory tree
* **emoji** - Emoji picker/browser tool
* **find-non-standard-file-names.py** - Find files with non-ASCII or forbidden characters
* **flush_dns.sh** - Flush DNS cache on macOS
* **getsong** - Download audio from YouTube or SoundCloud using yt-dlp
* **git-incoming** - Show remote commits that would be pulled
* **git-outgoing** - Show local commits that need to be pushed
* **git-show-fzf** - Browse files changed in a commit with fzf
* **git-showtool** - Run git difftool on a commit
* **git-stats** - Display repository statistics (commits, contributors, size, etc.)
* **git-who** - Show who has been developing a section of code
* **groups.py** - Query groups from multiple sources (Confluence, LDAP) with caching
* **hoy** - Output today's date in YYYY-MM-DD format
* **ip-convert.sh** - Convert IPv4 addresses between dotted and network order
* **ipy** - Start an interactive Python 3 shell
* **isql** - Start an interactive SQLite session with in-memory database
* **jassigned** - Show JIRA tickets assigned to you
* **jira** - Show details for a specific JIRA ticket
* **jq-fzf** - Interactive jq playground with fzf preview
* **jsonformat** - Pretty-print JSON from stdin using Node.js or jq
* **k9s-set-color-theme.sh** - Install or set k9s color theme
* **loc** - Search files with mlocate and browse with fzf
* **mac-convert.sh** - Convert MAC addresses between colon-hex and decimal
* **mac_version.sh** - Display macOS version name (Sierra, Yosemite, etc.)
* **make_iso.sh** - Create an ISO image from a macOS disk device
* **mksh** - Create a new shell script with boilerplate and open in editor
* **murder** - Gracefully kill processes by PID, name, or port
* **nato** - Convert text to NATO phonetic alphabet
* **notify** - Send desktop notifications (cross-platform)
* **ocr** - Extract text from images using macOS Vision framework
* **piper-say.sh** - Text-to-speech using Piper TTS engine
* **pit** - Page text through $PAGER if output is to a terminal
* **pix** - Display images using mpv
* **rfcf** - Fetch RFC documents from IETF
* **rfcr** - Read RFC documents formatted for terminal
* **rfct.awk** - Format RFC text for terminal reading (AWK script)
* **rfv** - Search and open files with ripgrep and fzf in vim
* **rfv2** - Interactive ripgrep search with live reload and fzf
* **resize_retina.sh** - Resize retina images to half DPI and compress with pngquant
* **rn** - Display current date/time and calendar
* **running** - List running processes (like ps aux | grep but cleaner)
* **sanitise-markdown-link.py** - Escape parentheses in markdown link URLs
* **scratch** - Open a temporary file in editor
* **serveit** - Start a static file server on localhost:8000
* **sfx** - Play a sound effect from XDG_CONFIG_HOME/my-sfx
* **shb** - Build a shebang line for a script using PATH lookup
* **stream_to_marked2.py** - Stream text to Marked 2 app preview
* **stream_to_marked2.sh** - Wrapper for stream_to_marked2.py
* **timer** - Sleep for specified time then play sound and notify
* **trash** - Move files to trash (macOS Finder or gio trash)
* **u+** - Look up Unicode character by hex code
* **updot.py** - Update dotfiles repositories on multiple remote hosts
* **update_zgen_now.sh** - Update zgen plugins and save configuration
* **url** - Parse and display components of a URL
* **waitfor** - Wait for a process to exit while preventing system sleep
* **webm-to-mp3** - Convert WebM files to MP3 using ffmpeg
* **yank.sh** - Copy text to clipboard (cross-platform, supports tmux)

Shell Configuration (shrc.d)
=============================

The `shrc.d/` directory contains shell configuration files that are sourced based on file extension:
- `.sh` files are sourced in both Bash and Zsh
- `.bash` files are sourced only in Bash
- `.zsh` files are sourced only in Zsh

Files are loaded in alphanumeric order (10, 20, 30, etc.) to control load sequence.

## Common Shell Files (.sh)

* **10alias.sh** - Common aliases (ls, grep, path, json/xml formatting, kubectl)
* **10disable_flowcontrol.sh** - Disable terminal flow control (Ctrl-S/Ctrl-Q)
* **10disable_special_tty_chars.sh** - Disable obsolete special TTY characters
* **10editor.sh** - Set EDITOR and VISUAL environment variables to vim
* **10git.sh** - Git helper functions (gs status, commit_onto)
* **10less.sh** - Configure less pager options
* **10man.sh** - Man page utilities (manpreview, mancolour)
* **10osis.sh** - OS detection function (osis)
* **10paths.sh** - Add ~/.local/bin to PATH
* **10tmux.sh** - Tmux split window helpers (tmw, tmv)
* **10zfunctions.sh** - Add ~/.zfunctions to ZSH fpath
* **20extract.sh** - Universal archive extraction function
* **20ip.sh** - Network utilities (my_ip, ii system info, my_public_ip)
* **20process.sh** - Process management functions (my_ps, pp, killps)
* **20todos.sh** - Find TODOs in git branch changes (branch_todos)
* **30fzf.sh** - FZF configuration and integration (fif, fzf_diff, fzf_jq, pods)
* **30fzf-git.sh** - FZF+Git integration functions (_gf files, _gb branches, _gt tags, _gh commits, _gr remotes, _gs stashes)
* **50boop.sh** - Audio feedback for command success/failure
* **50finder.sh** - macOS Finder integration (cdf, sel)
* **50mysql.sh** - Kubernetes MySQL backup/restore functions
* **50subtitles.sh** - Extract subtitles from video files with ffmpeg
* **80powerline_helpers.sh** - Test powerline characters function
* **90nooom.sh** - Run command with OOM killer protection
* **99colorscheme.sh** - Unified color scheme management (dark/light mode for alacritty, vim, tmux, k9s, fzf, bat, ls)
* **macos-aliases.sh** - macOS specific aliases (mergepdf)
* **mkcd.sh** - Create directory and cd into it
* **time.sh** - Timezone conversion functions (jpdate, hkdate, krdate, audate, utdate)
* **weather.sh** - Weather alias using wttr.in

## Bash-only Files (.bash)

* **10history.bash** - Bash history configuration with persistent history logging
* **10mac.bash** - macOS specific function (cdr_to_iso)
* **10prompt.bash** - Bash prompt with Git status and job count
* **30fzf-git-bindings.bash** - Bash keybindings for FZF+Git functions (Ctrl-G Ctrl-F/B/T/H/R/S)
* **80powerline.bash** - Powerline prompt integration for Bash

## Zsh-only Files (.zsh)

* **10history.zsh** - ZSH history configuration (size, deduplication, sharing)
* **10prompt.zsh** - Simple fallback ZSH prompt
* **20prompt.zsh** - Pure prompt configuration
* **30bindings.zsh** - ZSH key bindings (Ctrl-X-E edit, word selection, run-help, delete/home/end keys)
* **30fzf-git-bindings.zsh** - ZSH keybindings for FZF+Git functions (Ctrl-G Ctrl-F/B/T/H/R/S)
* **31fzf.zsh** - Enhanced FZF Ctrl-T widget with yank support
* **50bazel.zsh** - Bazel test filtering with FZF (btzf function)
* **50wordstyle.zsh** - Word style selection keybinding (Alt-Z) and transpose-words configuration
* **80powerline.zsh** - Powerline prompt integration for ZSH
* **90zshplugins.zsh** - Load ZSH plugins (zsh-bd, autosuggestions, zaw, syntax-highlighting)
* **cdr.zsh** - Recent directory tracking (chpwd_recent_dirs, cdr)
* **config.zsh** - ZSH options (completion, flow control, word splitting, comments)
* **help.zsh** - ZSH help system configuration (run-help)
* **zsh_completion.zsh** - ZSH completion system configuration (menu, colors, caching, matchers)


