#!/usr/bin/env -S uv run --script
# /// script
# requires-python=">=3.12"
# dependencies = [
#   "requests",
#   "questionary",
#   "rich",
#   "ldap3",
# ]
# ///

import argparse
import csv
import hashlib
import json
import os
import sys
import time
import tomllib
import urllib.parse
from abc import ABC, abstractmethod
from dataclasses import dataclass
from pathlib import Path
from typing import Any, TextIO

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
    """LDAP group provider using ldap3 library"""

    def __init__(self, config: LDAPConfig, cache: CacheManager):
        super().__init__("ldap", cache)
        self.config = config

    def _search_ldap(self, ldap_filter: str, attributes: list[str]) -> dict[str, dict]:
        """Execute LDAP search query using ldap3 library"""
        from ldap3 import Connection, Server
        from ldap3.core.exceptions import LDAPException

        try:
            server = Server(self.config.host, port=self.config.port)
            conn = Connection(
                server,
                user=self.config.user,
                password=self.config.password,
                auto_bind=True,
            )

            conn.search(
                search_base=self.config.base_dn,
                search_filter=ldap_filter,
                attributes=attributes,
            )

            # Convert entries to dict keyed by DN
            entries = {}
            for entry in conn.entries:
                dn = entry.entry_dn
                attrs = {}
                for attr_name in entry.entry_attributes:
                    attr_value = entry[attr_name].value
                    # ldap3 returns lists for multi-valued attributes
                    # Keep single values as strings for compatibility
                    if isinstance(attr_value, list) and len(attr_value) == 1:
                        attrs[attr_name] = attr_value[0]
                    else:
                        attrs[attr_name] = attr_value
                entries[dn] = attrs

            conn.unbind()
            return entries

        except LDAPException as e:
            print(f"LDAP error: {e}", file=sys.stderr)
            return {}
        except Exception as e:
            print(f"Unexpected error during LDAP search: {e}", file=sys.stderr)
            return {}

    def search_groups(self, query: str, progress_callback=None) -> list[dict]:
        # Check cache
        cached = self.cache.get("ldap", "search_groups", {"query": query})
        if cached is not None:
            return cached

        # Escape query for LDAP filter
        from ldap3.utils.conv import escape_filter_chars

        query_escaped = escape_filter_chars(query)

        ldap_filter = (
            f"(&(objectClass=group)"
            f"(|(cn=*{query_escaped}*)"
            f"(description=*{query_escaped}*)"
            f"(displayName=*{query_escaped}*)))"
        )

        entries = self._search_ldap(
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
        entries = self._search_ldap(ldap_filter, ["member"])

        members = []
        if entries:
            group_entry = list(entries.values())[0]
            member_dns = group_entry.get("member", [])
            if isinstance(member_dns, str):
                member_dns = [member_dns]

            if not member_dns:
                return members

            # Fetch all members in a single query using OR filter
            # Build filter: (&(objectClass=person)(|(distinguishedName=dn1)(distinguishedName=dn2)...))
            # Note: ldap3 doesn't have built-in DN escaping, but DNs from LDAP searches are trusted
            # If this becomes a concern, consider querying members individually
            dn_filters = "".join(f"(distinguishedName={dn})" for dn in member_dns)
            member_filter = f"(&(objectClass=person)(|{dn_filters}))"

            member_entries = self._search_ldap(
                member_filter,
                [
                    "distinguishedName",
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

            # Process all member entries
            for _dn, member_attrs in member_entries.items():
                # Convert datetime objects to strings
                when_created = member_attrs.get("whenCreated", "")
                if when_created and hasattr(when_created, "isoformat"):
                    when_created = when_created.isoformat()

                when_changed = member_attrs.get("whenChanged", "")
                if when_changed and hasattr(when_changed, "isoformat"):
                    when_changed = when_changed.isoformat()

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
                        "whenCreated": when_created,
                        "whenChanged": when_changed,
                    }
                )

        # Store in cache (30 minute TTL)
        self.cache.set("ldap", "get_members", {"group_id": group_id}, members, ttl=1800)

        return members

    def validate_config(self) -> bool:
        try:
            # Try a simple search to validate connection
            result = self._search_ldap("(objectClass=*)", ["dn"])
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

    # Common columns shared across all sources
    COMMON_GROUP_COLUMNS = {"id", "name", "description"}
    COMMON_MEMBER_COLUMNS = {"displayName", "accountId", "email"}

    # Column name mappings: source-specific names -> common names
    COLUMN_MAPPINGS = {
        "mail": "email",  # LDAP uses 'mail', normalize to 'email'
    }

    def __init__(
        self,
        format_type: str = "auto",
        is_tty: bool | None = None,
        output_file: str | None = None,
    ):
        if is_tty is None:
            is_tty = sys.stdout.isatty()

        self.is_tty = is_tty
        self.output_file = output_file
        self.file_handle: TextIO | None = None

        if format_type == "auto":
            self.format_type = "table" if is_tty else "plain"
        else:
            self.format_type = format_type

        self.console = Console(force_terminal=is_tty)

        # Track if CSV header has been written (for members command)
        self._csv_header_written = False
        self._all_headers_set: set[str] = set()  # Track unique headers
        self._metadata_cols: list[str] = []  # Columns like source, group_name, group_id
        self._buffered_rows: list[dict] = []  # Buffer rows when writing to file

    def _get_output_handle(self) -> TextIO:
        """Get the file handle to write to"""
        if self.output_file and self.output_file != "-":
            if not self.file_handle:
                try:
                    self.file_handle = open(self.output_file, "w")
                except OSError as e:
                    print(f"Error opening output file '{self.output_file}': {e}", file=sys.stderr)
                    sys.exit(1)
            return self.file_handle
        return sys.stdout

    def flush_csv(self):
        """Flush buffered CSV rows to file with complete headers"""
        if not self._buffered_rows or self.format_type != "csv":
            return

        output = self._get_output_handle()

        # Build final header list
        common_cols_set = (
            self.COMMON_MEMBER_COLUMNS
            if "group_name" in self._metadata_cols
            else self.COMMON_GROUP_COLUMNS
        )
        common_cols = sorted([k for k in self._all_headers_set if k in common_cols_set])
        specific_cols = sorted(
            [
                k
                for k in self._all_headers_set
                if k not in common_cols_set and k not in self._metadata_cols
            ]
        )
        final_headers = self._metadata_cols + common_cols + specific_cols

        # Write all rows with complete headers
        writer = csv.DictWriter(output, fieldnames=final_headers, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(self._buffered_rows)

        # Clear buffer
        self._buffered_rows = []

    def close(self):
        """Close file handle if open"""
        # Flush any buffered CSV data
        try:
            self.flush_csv()
        except Exception as e:
            print(f"Error flushing CSV data: {e}", file=sys.stderr)

        if self.file_handle:
            try:
                self.file_handle.close()
            except Exception as e:
                print(f"Error closing output file: {e}", file=sys.stderr)
            finally:
                self.file_handle = None

    def _prefix_source_specific_columns(
        self, data: dict, source: str, common_columns: set[str]
    ) -> dict:
        """Prefix source-specific columns with source name"""
        result = {}
        for key, value in data.items():
            # Apply column name mapping if exists
            mapped_key = self.COLUMN_MAPPINGS.get(key, key)

            if mapped_key in common_columns:
                result[mapped_key] = value
            else:
                result[f"{source}_{key}"] = value
        return result

    def format_groups(self, groups: list[dict], source: str):
        """Format group search results"""
        output = self._get_output_handle()

        if self.format_type == "json":
            print(json.dumps(groups, indent=2), file=output)
        elif self.format_type == "csv":
            # Transform groups to have prefixed columns
            transformed_groups = []
            for group in groups:
                prefixed = self._prefix_source_specific_columns(
                    group, source, self.COMMON_GROUP_COLUMNS
                )
                transformed_groups.append(prefixed)

            # Collect all unique keys
            all_keys = {"source"}
            for group in transformed_groups:
                all_keys.update(group.keys())

            # Track metadata columns
            if not self._metadata_cols:
                self._metadata_cols = ["source"]

            # Accumulate all headers seen
            self._all_headers_set.update(all_keys)
            self._all_headers_set.add("source")

            # Prepare rows
            rows = []
            for group in transformed_groups:
                row = {"source": source, **group}
                rows.append(row)

            # If writing to file, buffer the rows
            if self.output_file and self.output_file != "-":
                self._buffered_rows.extend(rows)
            else:
                # Writing to stdout - write immediately
                common_cols = sorted(
                    [k for k in self._all_headers_set if k in self.COMMON_GROUP_COLUMNS]
                )
                specific_cols = sorted(
                    [
                        k
                        for k in self._all_headers_set
                        if k not in self.COMMON_GROUP_COLUMNS
                        and k not in self._metadata_cols
                    ]
                )
                final_headers = self._metadata_cols + common_cols + specific_cols

                writer = csv.DictWriter(
                    output, fieldnames=final_headers, extrasaction="ignore"
                )

                if not self._csv_header_written:
                    writer.writeheader()
                    self._csv_header_written = True

                writer.writerows(rows)
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
                print(f"{group.get('name', '')} ({group.get('id', '')})", file=output)

    def format_members(
        self,
        members: list[dict],
        group_name: str,
        source: str | None = None,
        group_id: str | None = None,
    ):
        """Format group member results"""
        output = self._get_output_handle()

        if self.format_type == "json":
            print(json.dumps(members, indent=2), file=output)
        elif self.format_type == "csv":
            # Transform members to have prefixed columns
            transformed_members = []
            for member in members:
                prefixed = self._prefix_source_specific_columns(
                    member, source or "unknown", self.COMMON_MEMBER_COLUMNS
                )
                transformed_members.append(prefixed)

            # Collect all unique keys
            all_keys = {"source", "group_name", "group_id"}
            for member in transformed_members:
                all_keys.update(member.keys())

            # Track metadata columns
            if not self._metadata_cols:
                self._metadata_cols = ["source", "group_name", "group_id"]

            # Accumulate all headers seen
            self._all_headers_set.update(all_keys)

            # Prepare rows
            rows = []
            for member in transformed_members:
                row = {
                    "source": source or "",
                    "group_name": group_name,
                    "group_id": group_id or "",
                    **member,
                }
                rows.append(row)

            # If writing to file, buffer the rows
            if self.output_file and self.output_file != "-":
                self._buffered_rows.extend(rows)
            else:
                # Writing to stdout - write immediately
                common_cols = sorted(
                    [
                        k
                        for k in self._all_headers_set
                        if k in self.COMMON_MEMBER_COLUMNS
                    ]
                )
                specific_cols = sorted(
                    [
                        k
                        for k in self._all_headers_set
                        if k not in self.COMMON_MEMBER_COLUMNS
                        and k not in self._metadata_cols
                    ]
                )
                final_headers = self._metadata_cols + common_cols + specific_cols

                writer = csv.DictWriter(
                    output, fieldnames=final_headers, extrasaction="ignore"
                )

                if not self._csv_header_written:
                    writer.writeheader()
                    self._csv_header_written = True

                writer.writerows(rows)
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
                    f"{member.get('displayName', '')} ({member.get('accountId', '')})",
                    file=output,
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
    search_parser.add_argument(
        "--output", "-o", help="Output file path (use '-' for stdout)"
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
    members_parser.add_argument(
        "--output", "-o", help="Output file path (use '-' for stdout)"
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

    # Detect TTY and get output file
    is_tty = sys.stdout.isatty()
    output_file = getattr(args, "output", None)
    formatter = OutputFormatter(
        format_type=args.format, is_tty=is_tty, output_file=output_file
    )

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
        try:
            for name, provider in selected_providers.items():
                try:
                    # Show progress bar for TTY when querying Confluence (paginated API)
                    if is_tty and name == "confluence" and not output_file:
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
                        if len(selected_providers) > 1 and is_tty and not output_file:
                            formatter.console.print(
                                f"\n[bold]{name.capitalize()}[/bold]"
                            )
                        formatter.format_groups(groups, name)
                except Exception as e:
                    print(f"Error querying {name}: {e}", file=sys.stderr)
        finally:
            formatter.close()

    # Handle members command
    elif args.command == "members":
        try:
            for name, provider in selected_providers.items():
                try:
                    groups = resolve_group(
                        provider, args.group, args.exact_match, allow_interactive=is_tty
                    )

                    for group in groups:
                        if len(selected_providers) > 1 or len(groups) > 1:
                            if is_tty and not output_file:
                                formatter.console.print(
                                    f"\n[bold cyan]{group['name']}[/bold cyan] [dim]({name})[/dim]"
                                )
                            elif not output_file:
                                print(f"\n{group['name']} ({name})")

                        members = provider.get_members(group["id"])
                        if members:
                            formatter.format_members(
                                members,
                                group["name"],
                                source=name,
                                group_id=group["id"],
                            )
                        elif is_tty and not output_file:
                            formatter.console.print("[dim]No members found[/dim]")
                        elif not output_file:
                            print("No members found")
                except Exception as e:
                    print(f"Error querying {name}: {e}", file=sys.stderr)
        finally:
            formatter.close()


if __name__ == "__main__":
    main()
