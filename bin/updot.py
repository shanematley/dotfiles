#!/usr/bin/env python
import argparse
import subprocess
import yaml
import os
import sys

UPDOT_YAML_PATH = '~/.updot.yaml'

def load_yaml():
    try:
        with open(os.path.expanduser(UPDOT_YAML_PATH), 'r') as stream:
            remote_locations = yaml.load(stream)
    except IOError:
        print >>sys.stderr, "Unable to read the config file", UPDOT_YAML_PATH
        sys.exit(1)

    if 'remotes' not in remote_locations:
        print >>sys.stderr, "No remotes are specified in", UPDOT_YAML_PATH
        sys.exit(2)
    return remote_locations['remotes'] or {}

def update_repository(folder, host=None):
    UPDATE_SCRIPT="""cd {remote_loc}
    printf "  Repo [$(pwd)]: "
    git fetch -q
    if [[ $(git rev-parse HEAD) != $(git rev-parse HEAD@{{u}}) ]]; then
        [[ $(git rev-parse HEAD) == $(git merge-base HEAD HEAD@{{u}}) ]] && {{ echo "Out of date"; git pull --rebase; }}
        [[ $(git rev-parse HEAD) != $(git rev-parse HEAD@{{u}}) ]] && echo -e "\\nNOTE: The repository on {host} has unpushed changes!"
    else
        echo "Up to date"
    fi
    """
    print "*** Updating", host or "Local Host", "***"
    if host is not None:
        subprocess.call(["ssh", host, UPDATE_SCRIPT.format(**{'host':host, 'remote_loc':folder})])
    else:
        subprocess.call(UPDATE_SCRIPT.format(**{'host':'this host', 'remote_loc':folder}), shell=True)
    print

def create_config_file():
    try:
        fd = os.open(os.path.expanduser(UPDOT_YAML_PATH), os.O_WRONLY | os.O_CREAT | os.O_EXCL)
        with os.fdopen(fd, 'w') as f:
            yaml.dump({'remotes' : []}, f, default_flow_style=False)
    except OSError as e:
        pass

if __name__ == "__main__":
    parser = argparse.ArgumentParser("Update dotfiles")
    parser.add_argument('--create', action='store_true', help='Create a new yaml config file')
    parser.add_argument('--dry-run', '-n', action='store_true', help='Just print which hosts would be accessed.')
    args = parser.parse_args()
    if args.create:
        create_config_file()
        sys.exit(0)


    remote_locations = load_yaml()
    if not remote_locations:
        print "No hosts to update found in the configuration file", UPDOT_YAML_PATH
    for remote in remote_locations:
        if args.dry_run:
            print " *", remote['host'], ':', remote['folder']
        else:
            update_repository(**remote)

