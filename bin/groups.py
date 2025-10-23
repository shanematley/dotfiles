#!/usr/bin/env -S uv run --script
# /// script
# requires-python=">=3.12"
# dependencies = [
#   "requests",
#   "questionary",
#   "rich",
# ]
# ///

import argparse
import hashlib
import json
import os
import subprocess
import sys
import time
import tomllib
import urllib.parse
from abc import ABC, abstractmethod
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import questionary
import requests
from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich.table import Table


# ============================================================================
# XDG Base Directory Helpers
# ============================================================================


def get_xdg_config_home() -> Path:
    """Get XDG config directory, following XDG Base Directory spec"""
    return Path(os.path.expandvars(os.getenv("XDG_CONFIG_HOME", "$HOME/.config")))


def get_xdg_cache_home() -> Path:
    """Get XDG cache directory, following XDG Base Directory spec"""
    return Path(os.path.expandvars(os.getenv("XDG_CACHE_HOME", "$HOME/.cache")))


# ============================================================================
# Cache Manager
# ============================================================================


class CacheManager:
    """Filesystem-based cache with TTL support"""

    def __init__(
        self,
        cache_dir: Path | None = None,
        default_ttl: int = 300,
        enabled: bool = True,
    ):
        """
        :param cache_dir: Directory for cache files (default: $XDG_CACHE_HOME/groups/)
        :param default_ttl: Default time-to-live in seconds (default: 5 minutes)
        :param enabled: Whether caching is enabled
        """
        if cache_dir is None:
            cache_dir = get_xdg_cache_home() / "groups"
        self.cache_dir = cache_dir
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.default_ttl = default_ttl
        self.enabled = enabled

    def _cache_key(self, provider: str, operation: str, params: dict) -> str:
        """Generate cache key from provider, operation, and params"""
        key_string = f"{provider}:{operation}:{json.dumps(params, sort_keys=True)}"
        return hashlib.sha256(key_string.encode()).hexdigest()

    def get(self, provider: str, operation: str, params: dict) -> Any | None:
        """Retrieve cached result if valid"""
        if not self.enabled:
            return None

        cache_key = self._cache_key(provider, operation, params)
        cache_file = self.cache_dir / f"{cache_key}.json"

        try:
            with cache_file.open() as f:
                cached = json.load(f)

            # Check if expired
            if time.time() > cached["expires_at"]:
                cache_file.unlink()
                return None

            return cached["data"]
        except FileNotFoundError:
            return None
        except (json.JSONDecodeError, KeyError, OSError):
            # Corrupted cache, delete it
            cache_file.unlink(missing_ok=True)
            return None

    def set(
        self,
        provider: str,
        operation: str,
        params: dict,
        data: Any,
        ttl: int | None = None,
    ):
        """Store result in cache"""
        if not self.enabled:
            return

        if ttl is None:
            ttl = self.default_ttl

        cache_key = self._cache_key(provider, operation, params)
        cache_file = self.cache_dir / f"{cache_key}.json"

        cached = {
            "provider": provider,
            "operation": operation,
            "params": params,
            "data": data,
            "cached_at": time.time(),
            "expires_at": time.time() + ttl,
            "ttl": ttl,
        }

        with cache_file.open("w") as f:
            json.dump(cached, f)

    def clear(self, provider: str | None = None):
        """Clear cache for specific provider or all"""
        if provider is None:
            # Clear all cache
            for cache_file in self.cache_dir.glob("*.json"):
                cache_file.unlink()
        else:
            # Clear cache for specific provider
            for cache_file in self.cache_dir.glob("*.json"):
                try:
                    with cache_file.open() as f:
                        cached = json.load(f)
                    if cached.get("provider") == provider:
                        cache_file.unlink()
                except (json.JSONDecodeError, OSError):
                    pass

    def info(self) -> dict:
        """Get cache statistics"""
        stats = {
            "total_entries": 0,
            "total_size_bytes": 0,
            "by_provider": {},
            "expired": 0,
        }

        for cache_file in self.cache_dir.glob("*.json"):
            try:
                stats["total_size_bytes"] += cache_file.stat().st_size
                stats["total_entries"] += 1

                with cache_file.open() as f:
                    cached = json.load(f)

                provider = cached.get("provider", "unknown")
                if provider not in stats["by_provider"]:
                    stats["by_provider"][provider] = {"count": 0, "size": 0}

                stats["by_provider"][provider]["count"] += 1
                stats["by_provider"][provider]["size"] += cache_file.stat().st_size

                if time.time() > cached["expires_at"]:
                    stats["expired"] += 1
            except (json.JSONDecodeError, OSError, KeyError):
                pass

        return stats


# ============================================================================
# Group Provider Base Class
# ============================================================================


class GroupProvider(ABC):
    """Abstract base class for group data providers"""

    def __init__(self, name: str, cache: CacheManager):
        self.name = name
        self.cache = cache

    @abstractmethod
    def search_groups(self, query: str, progress_callback=None) -> list[dict]:
        """
        Search for groups matching the query string.

        :param query: Search query string
        :param progress_callback: Optional callback function(count) for progress updates
        :return: List of group dictionaries with at least 'id' and 'name' keys
        """
        pass

    @abstractmethod
    def get_members(self, group_id: str) -> list[dict]:
        """
        Get members of a specific group.

        :param group_id: Group identifier
        :return: List of member dictionaries
        """
        pass

    @abstractmethod
    def validate_config(self) -> bool:
        """
        Validate that the provider configuration is correct.

        :return: True if config is valid, False otherwise
        """
        pass


# ============================================================================
# Confluence Provider
# ============================================================================


@dataclass
class ConfluenceConfig:
    base_url: str
    user: str
    api_key: str


class Confluence:
    """Confluence API client (ported from confluence-groups.py)"""

    def __init__(self, base_url: str, email: str, api_token: str) -> None:
        self.base_url = base_url.removesuffix("/wiki")
        self.session = requests.Session()
        self.session.headers = {"Accept": "application/json"}
        self.session.auth = requests.auth.HTTPBasicAuth(email, api_token)

    @classmethod
    def from_config(cls, config: ConfluenceConfig):
        return Confluence(config.base_url, config.user, config.api_key)

    def get_paginated(self, relative_v1_url, params={}, progress_callback=None):
        params = params | {"limit": 200, "start": 0}
        results = []
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

    def find_groups(self, query: str) -> list[dict]:
        """Find Confluence groups matching a partial query string"""
        return self.get_paginated("rest/api/group/picker", params={"query": query})

    def get_group_by_id(self, group_id: str) -> dict | None:
        """Fetch a specific group by its ID"""
        response = self.session.get(
            f"{self.base_url}/wiki/rest/api/group/by-id", params={"id": group_id}
        )
        if response.status_code == 200:
            return response.json()
        return None

    def list_all_users(self, group_id: str) -> list[dict]:
        """Fetch all users of a specific group"""
        return self.get_paginated(f"rest/api/group/{group_id}/membersByGroupId")


class ConfluenceProvider(GroupProvider):
    """Confluence group provider with caching"""

    def __init__(self, config: ConfluenceConfig, cache: CacheManager):
        super().__init__("confluence", cache)
        self.config = config
        self.confluence = Confluence.from_config(config)

    def search_groups(self, query: str, progress_callback=None) -> list[dict]:
        # Check cache
        cached = self.cache.get("confluence", "search_groups", {"query": query})
        if cached is not None:
            return cached

        # Fetch from API with progress callback
        results = self.confluence.get_paginated(
            "rest/api/group/picker",
            params={"query": query},
            progress_callback=progress_callback,
        )

        # Store in cache (5 minute TTL)
        self.cache.set(
            "confluence", "search_groups", {"query": query}, results, ttl=300
        )

        return results

    def get_members(self, group_id: str) -> list[dict]:
        # Check cache
        cached = self.cache.get("confluence", "get_members", {"group_id": group_id})
        if cached is not None:
            return cached

        # Fetch from API
        results = self.confluence.list_all_users(group_id)

        # Store in cache (15 minute TTL for member lists)
        self.cache.set(
            "confluence", "get_members", {"group_id": group_id}, results, ttl=900
        )

        return results

    def validate_config(self) -> bool:
        try:
            # Try a simple API call to validate credentials
            response = self.confluence.session.get(
                f"{self.confluence.base_url}/wiki/rest/api/group/picker?query=test&limit=1"
            )
            return response.status_code in (200, 404)
        except Exception:
            return False


# ============================================================================
# LDAP Provider
# ============================================================================


@dataclass
class LDAPConfig:
    host: str
    port: int
    user: str
    password: str
    base_dn: str


class LDAPProvider(GroupProvider):
    """LDAP group provider using ldapsearch"""

    def __init__(self, config: LDAPConfig, cache: CacheManager):
        super().__init__("ldap", cache)
        self.config = config

    def _run_ldapsearch(
        self, ldap_filter: str, attributes: list[str]
    ) -> dict[str, dict]:
        """Run ldapsearch and parse LDIF output"""
        # fmt: off
        cmd = [
            "ldapsearch",
            "-H", f"ldap://{self.config.host}:{self.config.port}",
            "-x",
            "-D", self.config.user,
            "-w", self.config.password,
            "-b", self.config.base_dn,
            "-o", "ldif-wrap=no",
            ldap_filter,
            *attributes,
        ]
        # fmt: on

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            if result.returncode != 0:
                return {}

            return self._parse_ldif(result.stdout)
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return {}

    def _parse_ldif(self, ldif_output: str) -> dict[str, dict]:
        """Parse LDIF output into dictionary of entries"""
        import base64

        entries = {}
        current_dn = None
        current_entry = {}

        for line in ldif_output.split("\n"):
            line = line.rstrip()

            if line.startswith("dn:"):
                # Save previous entry
                if current_dn and current_entry:
                    entries[current_dn] = current_entry

                # Start new entry
                current_dn = line.split(":", 1)[1].strip()
                current_entry = {}

            elif line and not line.startswith("#") and current_dn:
                if ":" in line:
                    key, value = line.split(":", 1)
                    value = value.strip()

                    # Handle base64 encoded values
                    if value.startswith(":"):
                        value = base64.b64decode(value[1:].strip()).decode(
                            "utf-8", errors="ignore"
                        )

                    # Store multiple values as lists
                    if key in current_entry:
                        if isinstance(current_entry[key], list):
                            current_entry[key].append(value)
                        else:
                            current_entry[key] = [current_entry[key], value]
                    else:
                        current_entry[key] = value

        # Save last entry
        if current_dn and current_entry:
            entries[current_dn] = current_entry

        return entries

    def search_groups(self, query: str, progress_callback=None) -> list[dict]:
        # Check cache
        cached = self.cache.get("ldap", "search_groups", {"query": query})
        if cached is not None:
            return cached

        # Escape query for LDAP filter
        query_escaped = (
            query.replace("\\", "\\\\")
            .replace("*", "\\*")
            .replace("(", "\\(")
            .replace(")", "\\)")
        )

        ldap_filter = (
            f"(&(objectClass=group)"
            f"(|(cn=*{query_escaped}*)"
            f"(description=*{query_escaped}*)"
            f"(displayName=*{query_escaped}*)))"
        )

        entries = self._run_ldapsearch(
            ldap_filter,
            [
                "cn",
                "description",
                "displayName",
                "mail",
                "member",
                "memberOf",
                "managedBy",
            ],
        )

        results = []
        for dn, attrs in entries.items():
            results.append(
                {
                    "id": dn,
                    "name": attrs.get("cn", dn.split(",")[0].replace("CN=", "")),
                    "description": attrs.get("description", ""),
                    "mail": attrs.get("mail", ""),
                    "memberOf": attrs.get("memberOf", [])
                    if isinstance(attrs.get("memberOf"), list)
                    else ([attrs.get("memberOf")] if attrs.get("memberOf") else []),
                    "managedBy": attrs.get("managedBy", ""),
                    "member_count": len(attrs.get("member", []))
                    if isinstance(attrs.get("member"), list)
                    else (1 if attrs.get("member") else 0),
                }
            )

        # Store in cache (10 minute TTL)
        self.cache.set("ldap", "search_groups", {"query": query}, results, ttl=600)

        return results

    def get_members(self, group_id: str) -> list[dict]:
        # Check cache
        cached = self.cache.get("ldap", "get_members", {"group_id": group_id})
        if cached is not None:
            return cached

        # Get group to find members
        ldap_filter = f"(&(objectClass=group)(distinguishedName={group_id}))"
        entries = self._run_ldapsearch(ldap_filter, ["member"])

        members = []
        if entries:
            group_entry = list(entries.values())[0]
            member_dns = group_entry.get("member", [])
            if isinstance(member_dns, str):
                member_dns = [member_dns]

            # Fetch details for each member
            for member_dn in member_dns:
                member_filter = (
                    f"(&(objectClass=person)(distinguishedName={member_dn}))"
                )
                member_entries = self._run_ldapsearch(
                    member_filter,
                    [
                        "cn",
                        "sn",
                        "l",
                        "description",
                        "telephoneNumber",
                        "givenName",
                        "whenCreated",
                        "whenChanged",
                        "displayName",
                        "company",
                        "mailNickname",
                        "sAMAccountName",
                        "mail",
                        "ipPhone",
                    ],
                )

                if member_entries:
                    member_attrs = list(member_entries.values())[0]
                    members.append(
                        {
                            "cn": member_attrs.get("cn", ""),
                            "sn": member_attrs.get("sn", ""),
                            "givenName": member_attrs.get("givenName", ""),
                            "displayName": member_attrs.get("displayName", ""),
                            "sAMAccountName": member_attrs.get("sAMAccountName", ""),
                            "accountId": member_attrs.get(
                                "sAMAccountName", ""
                            ),  # Alias for compatibility
                            "mail": member_attrs.get("mail", ""),
                            "mailNickname": member_attrs.get("mailNickname", ""),
                            "telephoneNumber": member_attrs.get("telephoneNumber", ""),
                            "ipPhone": member_attrs.get("ipPhone", ""),
                            "l": member_attrs.get("l", ""),
                            "location": member_attrs.get(
                                "l", ""
                            ),  # Alias for compatibility
                            "co": member_attrs.get("co", ""),
                            "country": member_attrs.get(
                                "co", ""
                            ),  # Alias for compatibility
                            "company": member_attrs.get("company", ""),
                            "description": member_attrs.get("description", ""),
                            "whenCreated": member_attrs.get("whenCreated", ""),
                            "whenChanged": member_attrs.get("whenChanged", ""),
                        }
                    )

        # Store in cache (30 minute TTL)
        self.cache.set("ldap", "get_members", {"group_id": group_id}, members, ttl=1800)

        return members

    def validate_config(self) -> bool:
        try:
            # Try a simple search to validate connection
            result = self._run_ldapsearch("(objectClass=*)", ["dn"])
            return len(result) > 0
        except Exception:
            return False


# ============================================================================
# Configuration Manager
# ============================================================================


class ConfigManager:
    """Manages configuration from TOML file with env var expansion"""

    def __init__(self, config_path: Path | None = None):
        if config_path is None:
            config_path = get_xdg_config_home() / "groups_tool.toml"

        self.config_path = config_path
        self.config = self._load_config()

    def _expand_env_vars(self, value: str) -> str:
        """Expand environment variables in format ${VAR_NAME}"""
        if isinstance(value, str) and "${" in value:
            return os.path.expandvars(value)
        return value

    def _expand_dict(self, d: dict) -> dict:
        """Recursively expand environment variables in dictionary values"""
        result = {}
        for key, value in d.items():
            if isinstance(value, dict):
                result[key] = self._expand_dict(value)
            elif isinstance(value, str):
                result[key] = self._expand_env_vars(value)
            else:
                result[key] = value
        return result

    def _load_config(self) -> dict:
        """Load and parse TOML configuration file"""
        if not self.config_path.exists():
            return {}

        with self.config_path.open("rb") as f:
            config = tomllib.load(f)

        return self._expand_dict(config)

    def get_confluence_config(self) -> ConfluenceConfig | None:
        """Get Confluence configuration"""
        if "confluence" not in self.config:
            return None

        c = self.config["confluence"]
        return ConfluenceConfig(
            base_url=c.get("base_url", ""),
            user=c.get("user", ""),
            api_key=c.get("api_key", ""),
        )

    def get_ldap_config(self) -> LDAPConfig | None:
        """Get LDAP configuration"""
        if "ldap" not in self.config:
            return None

        c = self.config["ldap"]
        return LDAPConfig(
            host=c.get("host", ""),
            port=c.get("port", 389),
            user=c.get("user", ""),
            password=c.get("password", ""),
            base_dn=c.get("base_dn", ""),
        )

    def get_cache_config(self) -> dict:
        """Get cache configuration"""
        cache_config = self.config.get("cache", {})

        return {
            "enabled": cache_config.get("enabled", True),
            "ttl": cache_config.get("ttl", 300),
            "directory": Path(os.path.expanduser(cache_config["directory"]))
            if "directory" in cache_config
            else None,
        }


# ============================================================================
# Output Formatter
# ============================================================================


class OutputFormatter:
    """Format output in various formats with TTY detection"""

    def __init__(self, format_type: str = "auto", is_tty: bool | None = None):
        if is_tty is None:
            is_tty = sys.stdout.isatty()

        self.is_tty = is_tty

        if format_type == "auto":
            self.format_type = "table" if is_tty else "plain"
        else:
            self.format_type = format_type

        self.console = Console(force_terminal=is_tty)

    def format_groups(self, groups: list[dict], source: str):
        """Format group search results"""
        if self.format_type == "json":
            print(json.dumps(groups, indent=2))
        elif self.format_type == "csv":
            print("source,id,name,description")
            for group in groups:
                print(
                    f"{source},{group.get('id', '')},{group.get('name', '')},{group.get('description', '')}"
                )
        elif self.format_type == "table" and self.is_tty:
            table = Table(title=f"{source.capitalize()} Groups")
            table.add_column("Name", style="cyan")
            table.add_column("ID", style="dim")
            table.add_column("Description", style="")

            for group in groups:
                table.add_row(
                    group.get("name", ""),
                    group.get("id", ""),
                    group.get("description", ""),
                )

            self.console.print(table)
        else:  # plain
            for group in groups:
                print(f"{group.get('name', '')} ({group.get('id', '')})")

    def format_members(self, members: list[dict], group_name: str):
        """Format group member results"""
        if self.format_type == "json":
            print(json.dumps(members, indent=2))
        elif self.format_type == "csv":
            print("displayName,accountId,email")
            for member in members:
                print(
                    f"{member.get('displayName', '')},{member.get('accountId', '')},{member.get('mail', '')}"
                )
        elif self.format_type == "table" and self.is_tty:
            table = Table(title=f"Members of {group_name}")
            table.add_column("Display Name", style="cyan")
            table.add_column("Account ID", style="")
            table.add_column("Email", style="dim")

            for member in members:
                table.add_row(
                    member.get("displayName", ""),
                    member.get("accountId", ""),
                    member.get("mail", ""),
                )

            self.console.print(table)
        else:  # plain
            for member in members:
                print(
                    f"{member.get('displayName', '')} ({member.get('accountId', '')})"
                )

    def format_cache_info(self, stats: dict):
        """Format cache statistics"""
        if self.format_type == "json":
            print(json.dumps(stats, indent=2))
        else:
            print(f"Total entries: {stats['total_entries']}")
            print(f"Total size: {stats['total_size_bytes']} bytes")
            print(f"Expired entries: {stats['expired']}")
            print("\nBy provider:")
            for provider, pstats in stats["by_provider"].items():
                print(
                    f"  {provider}: {pstats['count']} entries ({pstats['size']} bytes)"
                )


# ============================================================================
# Helper Functions
# ============================================================================


def resolve_group(
    provider: GroupProvider,
    group_identifier: str,
    exact_match: bool = False,
    allow_interactive: bool = True,
) -> list[dict]:
    """
    Resolve a group identifier to one or more group objects.

    :param provider: Provider instance
    :param group_identifier: Group name to search for or 'id:<group_id>'
    :param exact_match: If True, only match exact group names
    :param allow_interactive: If True, allow interactive selection for multiple matches
    :return: List of group objects
    """
    # If it starts with 'id:', use it directly
    if group_identifier.startswith("id:"):
        group_id = group_identifier[3:]
        return [{"id": group_id, "name": group_identifier}]

    # Search for group by name
    matching_groups = provider.search_groups(group_identifier)

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
                sys.exit(0)

            # Map selected strings back to group objects
            selected_ids = [s.split("(")[-1].rstrip(")") for s in selected]
            return [g for g in matching_groups if g["id"] in selected_ids]
        else:
            # Non-interactive mode - error with suggestions
            print(
                f"Error: Multiple groups match '{group_identifier}':", file=sys.stderr
            )
            for group in matching_groups:
                print(f"  {group['name']} ({group['id']})", file=sys.stderr)
            print("\nPlease use one of:", file=sys.stderr)
            print(
                "  - The --exact-match flag to match exact group names", file=sys.stderr
            )
            print(
                "  - The 'id:<group_id>' prefix to specify a group by ID",
                file=sys.stderr,
            )
            sys.exit(1)


# ============================================================================
# Main CLI
# ============================================================================


def main():
    parser = argparse.ArgumentParser(description="Query groups from multiple sources")
    parser.add_argument(
        "--no-cache", action="store_true", help="Bypass cache for this request"
    )
    parser.add_argument(
        "--format",
        choices=["auto", "table", "plain", "json", "csv"],
        default="auto",
        help="Output format",
    )

    subparsers = parser.add_subparsers(
        dest="command", required=True, help="Available commands"
    )

    # search subcommand
    search_parser = subparsers.add_parser("search", help="Search for groups")
    search_parser.add_argument("query", help="Search query string")
    search_parser.add_argument(
        "--sources", help="Comma-separated list of sources (e.g., confluence,ldap)"
    )

    # members subcommand
    members_parser = subparsers.add_parser("members", help="List members of a group")
    members_parser.add_argument(
        "group", help="Group ID (prefix with 'id:') or group name"
    )
    members_parser.add_argument("--sources", help="Comma-separated list of sources")
    members_parser.add_argument(
        "--exact-match", action="store_true", help="Only match exact group names"
    )

    # sources subcommand
    sources_parser = subparsers.add_parser("sources", help="List available sources")
    sources_parser.add_argument(
        "--show-config", action="store_true", help="Show configuration details"
    )

    # cache subcommand
    cache_parser = subparsers.add_parser("cache", help="Manage cache")
    cache_subparsers = cache_parser.add_subparsers(dest="cache_command", required=True)

    clear_parser = cache_subparsers.add_parser("clear", help="Clear cache")
    clear_parser.add_argument(
        "--provider", help="Clear cache for specific provider only"
    )

    cache_subparsers.add_parser("info", help="Show cache statistics")

    args = parser.parse_args()

    # Load configuration
    config_manager = ConfigManager()

    # Initialize cache
    cache_config = config_manager.get_cache_config()
    cache = CacheManager(
        cache_dir=cache_config["directory"],
        default_ttl=cache_config["ttl"],
        enabled=cache_config["enabled"] and not args.no_cache,
    )

    # Initialize providers
    providers = {}

    confluence_config = config_manager.get_confluence_config()
    if confluence_config:
        providers["confluence"] = ConfluenceProvider(confluence_config, cache)

    ldap_config = config_manager.get_ldap_config()
    if ldap_config:
        providers["ldap"] = LDAPProvider(ldap_config, cache)

    # Detect TTY
    is_tty = sys.stdout.isatty()
    formatter = OutputFormatter(format_type=args.format, is_tty=is_tty)

    # Handle cache commands
    if args.command == "cache":
        if args.cache_command == "clear":
            cache.clear(provider=args.provider)
            print(f"Cache cleared{' for ' + args.provider if args.provider else ''}")
        elif args.cache_command == "info":
            stats = cache.info()
            formatter.format_cache_info(stats)
        return

    # Handle sources command
    if args.command == "sources":
        if args.show_config:
            print(
                json.dumps(
                    {name: p.config.__dict__ for name, p in providers.items()},
                    indent=2,
                    default=str,
                )
            )
        else:
            print("Available sources:")
            for name in providers.keys():
                print(f"  - {name}")
        return

    # Determine which sources to use
    if hasattr(args, "sources") and args.sources:
        source_names = [s.strip() for s in args.sources.split(",")]
        selected_providers = {
            name: providers[name] for name in source_names if name in providers
        }

        missing = [name for name in source_names if name not in providers]
        if missing:
            print(f"Warning: Unknown sources: {', '.join(missing)}", file=sys.stderr)
    else:
        selected_providers = providers

    if not selected_providers:
        print(
            "Error: No providers available. Check your configuration.", file=sys.stderr
        )
        sys.exit(1)

    # Handle search command
    if args.command == "search":
        for name, provider in selected_providers.items():
            try:
                # Show progress bar for TTY when querying Confluence (paginated API)
                if is_tty and name == "confluence":
                    with Progress(
                        SpinnerColumn(),
                        TextColumn("[progress.description]{task.description}"),
                        console=formatter.console,
                    ) as progress:
                        task = progress.add_task("Fetching groups...", total=None)

                        def update_progress(count):
                            progress.update(
                                task, description=f"Fetched {count} groups..."
                            )

                        groups = provider.search_groups(
                            args.query, progress_callback=update_progress
                        )
                else:
                    groups = provider.search_groups(args.query)

                if groups:
                    if len(selected_providers) > 1 and is_tty:
                        formatter.console.print(f"\n[bold]{name.capitalize()}[/bold]")
                    formatter.format_groups(groups, name)
            except Exception as e:
                print(f"Error querying {name}: {e}", file=sys.stderr)

    # Handle members command
    elif args.command == "members":
        for name, provider in selected_providers.items():
            try:
                groups = resolve_group(
                    provider, args.group, args.exact_match, allow_interactive=is_tty
                )

                for group in groups:
                    if len(selected_providers) > 1 or len(groups) > 1:
                        if is_tty:
                            formatter.console.print(
                                f"\n[bold cyan]{group['name']}[/bold cyan] [dim]({name})[/dim]"
                            )
                        else:
                            print(f"\n{group['name']} ({name})")

                    members = provider.get_members(group["id"])
                    if members:
                        formatter.format_members(members, group["name"])
                    elif is_tty:
                        formatter.console.print("[dim]No members found[/dim]")
                    else:
                        print("No members found")
            except Exception as e:
                print(f"Error querying {name}: {e}", file=sys.stderr)


if __name__ == "__main__":
    main()
