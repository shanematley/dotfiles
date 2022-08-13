#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Run sudo and keep-alive: update existing `sudo` time stamp until this script has finished
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils

brew install fzf

# Install some other useful utilities like `sponge`.
#brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
#brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
#brew install gnu-sed --with-default-names

# Install `wget`
brew install wget

# Install more recent versions of some macOS tools.
brew install vim --with-override-system-vi

# Install some CTF tools; see https://github.com/ctfs/write-ups.
# WiFi security
#brew install aircrack-ng
# Remove large files or passwords from git history
#brew install bfg
#brew install binutils
# Binwalk is a tool for searching a given binary image for embedded files and executable code
#brew install binwalk
# Classical cipher cracking
#brew install cifer
# TCP-over-DNS tunnel server and client
#brew install dns2tcp
# Zip password cracker
#brew install fcrackzip
# Foremost is a console program to recover files based on their headers, footers, and internal data structures
#brew install foremost
# A tool to exploit the hash length extension attack in various hashing algorithms.
#brew install hashpump
# Network logon cracker which supports many services
#brew install hydra
# Featureful UNIX password cracker
#brew install john
# Image manipulation
#brew install netpbm
# Port scanning utility for large networks
brew install nmap
# Print info and check PNG, JNG, and MNG files
#brew install pngcheck
# SOcket CAT: netcat on steroids
brew install socat
# Penetration testing for SQL injection and database servers
#brew install sqlmap
# TCP/IP packet demultiplexer
#brew install tcpflow
# Replay saved tcpdump files at arbitrary speeds
#brew install tcpreplay
# Analyze tcpdump output
#brew install tcptrace
# tcpserver and tcpclient are easy-to-use command-line tools for building TCP client-server applications.
#brew install ucspi-tcp # `tcpserver` etc.
# PDF viewer
#brew install xpdf
# General-purpose data compression with high compression ratio
#brew install xz

# Install other useful binaries.
brew install fasd
brew install git
brew install git-lfs
brew install gron
#brew install gs
#brew install imagemagick --with-webp
brew install jq
brew install mtr
brew install node
#brew install lua
#brew install lynx
#brew install p7zip
brew install pv
brew install rename
brew install rg
brew install rlwrap
#brew install ssh-copy-id
brew install tree
brew install vbindiff
brew install zopfli
brew install tokei
brew install highlight
brew install --cask pastebot
brew install pbzip2

# Hammerspoon for great keyboard shortcuts as inspired by https://github.com/jasonrudolph/keyboard
brew install hammerspoon

# dive - a tool for exploring a docker image, layer contents etc. https://github.com/wagoodman/dive
brew install dive

# Remove outdated versions from the cellar.
brew cleanup
