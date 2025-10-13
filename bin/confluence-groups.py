#!/usr/bin/env -S uv run --script
# /// script
# requires-python=">=3.12"
# dependencies = [
# "requests",
# "questionary",
# "rich",
# ]
# ///


import argparse
from dataclasses import dataclass
import os
from pathlib import Path
import sys
import tomllib
import urllib.parse

import questionary
import requests
from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn


@dataclass
class ConfluenceConfig:
    base_url: str
    user: str
    api_key: str


class Confluence:
    def __init__(self, base_url: str, email: str, api_token: str) -> None:
        """
        Initialize a Confluence API client instance.

        :param base_url: The base URL of your Confluence instance.
        :param email: The email address associated with your Atlassian account.
        :param api_token: Your Atlassian API token.
        """
        self.base_url = base_url.removesuffix("/wiki")
        self.session = requests.Session()
        self.session.headers = {"Accept": "application/json"}
        self.session.auth = requests.auth.HTTPBasicAuth(email, api_token)

    @classmethod
    def from_config(cls, config: ConfluenceConfig):
        return Confluence(config.base_url, config.user, config.api_key)

    @classmethod
    def from_config_path(
        cls, config_path: Path | None = None, section: str = "confluence"
    ):
        """
        Create Confluence object from a config file at the given path. If no path is provided, default to
        $XDG_CONFIG_HOME/confluence.toml.
        """
        if not config_path:
            config_path = (
                Path(os.path.expandvars(os.getenv("XDG_CONFIG_HOME", "$HOME/.config")))
                / "confluence.toml"
            )
        config = tomllib.loads(config_path.read_text())
        confluence_config = ConfluenceConfig(**config[section])
        return Confluence.from_config(confluence_config)

    def get_paginated(self, relative_v1_url, params={}, progress_callback=None):
        params = params | {"limit": 200, "start": 0}
        results = []
        # Build initial URL with query parameters
        query_string = urllib.parse.urlencode(params)
        next_link = f"{relative_v1_url}?{query_string}"

        while next_link:
            response = self.session.get(f"{self.base_url}/wiki/{next_link}")
            response.raise_for_status()
            data = response.json()
            results.extend(data["results"])
            next_link = data.get("_links", {}).get("next")

            if progress_callback:
                progress_callback(len(results))

        return results

    def get_groups(self) -> list[dict]:
        """
        Fetch all Confluence groups.

        :return: A list of dictionaries containing group details.
        """
        return self.get_paginated("rest/api/group")

    def get_group_by_id(self, group_id: str) -> dict | None:
        """
        Fetch a specific group by its ID.

        :param group_id: The ID of the group to fetch.
        :return: A dictionary containing group details, or None if not found.
        """
        response = self.session.get(
            f"{self.base_url}/wiki/rest/api/group/by-id",
            params={"id": group_id}
        )
        if response.status_code == 200:
            return response.json()
        else:
            return None

    def find_groups(self, query: str) -> list[dict]:
        """
        Find Confluence groups matching a partial query string.

        :param query: The partial string to search for in group names.
        :return: A list of dictionaries containing matching group details.
        """
        return self.get_paginated("rest/api/group/picker", params={"query": query})

    def list_all_users(self, group_id: str) -> list[dict]:
        """
        Fetch all users of a specific group.

        :param group_id: The ID of the group to fetch users from.
        :return: A list of dictionaries containing the user details.
        """
        return self.get_paginated(f"rest/api/group/{group_id}/membersByGroupId")


def resolve_groups(
    confluence: Confluence, group_identifier: str, exact_match: bool = False, allow_interactive: bool = True
) -> list[dict]:
    """
    Resolve a group identifier to one or more group objects.

    :param confluence: Confluence API client instance
    :param group_identifier: Either 'id:<group_id>' or a group name to search for
    :param exact_match: If True, only match exact group names
    :param allow_interactive: If True, allow interactive selection for multiple matches
    :return: List of group objects (may contain multiple if user selects multiple)
    """
    # If it starts with 'id:', fetch the specific group by ID
    if group_identifier.startswith("id:"):
        group_id = group_identifier[3:]
        group = confluence.get_group_by_id(group_id)
        if group is None:
            print(f"Error: No group found with ID '{group_id}'", file=sys.stderr)
            sys.exit(1)
        return [group]

    # Search for group by name
    matching_groups = confluence.find_groups(group_identifier)

    # Filter to exact matches if requested
    if exact_match:
        matching_groups = [g for g in matching_groups if g["name"] == group_identifier]

    if len(matching_groups) == 0:
        print(f"Error: No groups found matching '{group_identifier}'", file=sys.stderr)
        sys.exit(1)
    elif len(matching_groups) == 1:
        return matching_groups
    else:
        # Multiple matches
        if allow_interactive:
            # Let user select one or more
            choices = [f"{g['name']} ({g['id']})" for g in matching_groups]
            selected = questionary.checkbox(
                "Multiple groups found. Select one or more (use Space to select, Enter to confirm):",
                choices=choices,
            ).ask()

            if selected is None or len(selected) == 0:
                # User cancelled or selected nothing
                sys.exit(0)

            # Map selected strings back to group objects
            selected_ids = [s.split("(")[-1].rstrip(")") for s in selected]
            return [g for g in matching_groups if g["id"] in selected_ids]
        else:
            # Non-interactive mode - error with suggestions
            print(f"Error: Multiple groups match '{group_identifier}':", file=sys.stderr)
            for group in matching_groups:
                print(f"  {group['name']} ({group['id']})", file=sys.stderr)
            print("\nPlease use one of:", file=sys.stderr)
            print("  - The --exact-match flag to match exact group names", file=sys.stderr)
            print("  - The 'id:<group_id>' prefix to specify a group by ID", file=sys.stderr)
            sys.exit(1)


def main():
    parser = argparse.ArgumentParser(description="Manage Confluence groups and users")
    subparsers = parser.add_subparsers(
        dest="command", required=True, help="Available commands"
    )

    # listgroups subcommand
    subparsers.add_parser("listgroups", help="List all groups")

    # findgroups subcommand
    findgroups_parser = subparsers.add_parser(
        "findgroups", help="Find groups matching a filter"
    )
    findgroups_parser.add_argument(
        "filter", help="Filter string to search for in group names"
    )

    # listusers subcommand
    listusers_parser = subparsers.add_parser("listusers", help="List users in a group")
    listusers_parser.add_argument(
        "group_id", help="Group ID (prefix with 'id:') or group name"
    )
    listusers_parser.add_argument(
        "--exact-match", action="store_true", help="Only match exact group names"
    )

    args = parser.parse_args()
    confluence = Confluence.from_config_path()

    # Detect if output is to a terminal (TTY) or being redirected
    is_tty = sys.stdout.isatty()
    console = Console(force_terminal=is_tty)

    if args.command == "listgroups":
        # Show progress bar only if outputting to a terminal
        if is_tty:
            with Progress(
                SpinnerColumn(),
                TextColumn("[progress.description]{task.description}"),
                console=console,
            ) as progress:
                task = progress.add_task("Fetching groups...", total=None)

                def update_progress(count):
                    progress.update(task, description=f"Fetched {count} groups...")

                groups = confluence.get_paginated("rest/api/group", progress_callback=update_progress)
        else:
            groups = confluence.get_paginated("rest/api/group")

        for group in groups:
            if is_tty:
                console.print(f"{group['name']} [dim]({group['id']})[/dim]")
            else:
                print(f"{group['name']} ({group['id']})")

    elif args.command == "findgroups":
        groups = confluence.find_groups(args.filter)
        for group in groups:
            if is_tty:
                console.print(f"{group['name']} [dim]({group['id']})[/dim]")
            else:
                print(f"{group['name']} ({group['id']})")

    elif args.command == "listusers":
        groups = resolve_groups(confluence, args.group_id, args.exact_match, allow_interactive=is_tty)

        for group in groups:
            # Print header with group name and ID
            if is_tty:
                console.print(
                    f"\n[bold cyan]{group['name']}[/bold cyan] [dim]({group['id']})[/dim]"
                )
            else:
                print(f"\n{group['name']} ({group['id']})")

            users = confluence.list_all_users(group['id'])
            if users:
                for user in users:
                    print(
                        f"{user.get('displayName', 'N/A')} ({user.get('accountId', 'N/A')})"
                    )
            elif is_tty:
                console.print("[dim]No users found[/dim]")
            else:
                print("No users found")


if __name__ == "__main__":
    main()
