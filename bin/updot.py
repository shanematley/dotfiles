#!/usr/bin/env python
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
    if [[ $(git rev-parse @) != $(git rev-parse @{{u}}) ]]; then
        [[ $(git rev-parse @) == $(git merge-base @ @{{u}}) ]] && {{ echo "Out of date"; git pull --rebase; }}
        [[ $(git rev-parse @) != $(git rev-parse @{{u}}) ]] && echo -e "\\nNOTE: The repository on {host} has unpushed changes!"
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

if __name__ == "__main__":
    remote_locations = load_yaml()
    if not remote_locations:
        print "No hosts to update found in the configuration file", UPDOT_YAML_PATH
    for remote in remote_locations:
        update_repository(**remote)

