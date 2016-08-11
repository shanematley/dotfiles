#!/usr/bin/env python
"""
Adjust the terminal or Tmux window and pane title. Written primarily with powerline in mind.

To use with powerline:

    1. Add a new segment to the appropriate themes/shell's default.json:

        { "function": "termtitle.getpanetitle", "priority": 40 }

    2. Ensure this file is accessible to powerline. Suggest placing in ~/.config/powerline
       and adding the path to ~/.config/powerline/config.json:

       { "common": { "paths": [ "~/.config/powerline" ] } }

"""

from __future__ import print_function
import os
import subprocess


TMUX_TERM_TITLE="\033Ptmux;\033\033]0;{}\007\033\\"
BASH_TERM_TITLE="\033]0;{}\007"
TMUX_PANE_TITLE="\033k{}\033\\"


class TitleSetter(object):
    def __init__(self):
        self.is_tmux = 'TMUX' in os.environ
        self.window_title = TMUX_TERM_TITLE if self.is_tmux else BASH_TERM_TITLE
        self.pane_title = TMUX_PANE_TITLE if self.is_tmux else BASH_TERM_TITLE

    def window(self, s):
        print(self.window_title.format(s))

    def pane(self, s):
        print(self.pane_title.format(s))


def get_git_repo():
    return subprocess.check_output("basename $(git rev-parse --show-toplevel 2>/dev/null || pwd)", shell=True).strip()


def gitpanetitle(*args, **kwargs):
    ts = TitleSetter()
    ts.pane(get_git_repo())


def gitwindowtitle(*args, **kwargs):
    ts = TitleSetter()
    ts.window(get_git_repo())

