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

brew bundle install

# Remove outdated versions from the cellar.
brew cleanup
