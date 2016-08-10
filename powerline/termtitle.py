#!/usr/bin/env python

import os
import subprocess
import sys

def is_tmux():
    return 'TMUX' in os.environ

def termtitle(s):
    if is_tmux():
        print "\033Ptmux;\033\033]0;{}\007\033\\".format(s)
    else:
        print "\033]0;{}\007".format(s)


def panetitle(s):
    if is_tmux():
        print "\033k{}\033\\".format(s)
    else:
        termtitle(s)


def get_git_repo():
    return subprocess.check_output("basename $(git rev-parse --show-toplevel 2>/dev/null || pwd)", shell=True).strip()


def set_panetitle_to_gitrepo(*args, **kwargs):
    panetitle(get_git_repo())


def set_termtitle_to_gitrepo(*args, **kwargs):
    termtitle(get_git_repo())

