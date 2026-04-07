#!/usr/bin/env -S uv run --script
# /// script
# requires-python=">=3.12"
# dependencies = [
#   "requests",
# ]
# ///

import argparse
import datetime as dt
import json
import os
import re
import sys
import tomllib
from copy import deepcopy
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import quote, urlencode

import requests


# ============================================================================
# Confluence API Client
# ============================================================================


@dataclass
class ConfluenceConfig:
    base_url: str
    user: str
    api_key: str


def atlas_doc_format_node_to_string(node: dict) -> str:
    """
    Converts an atlas_doc_format node to a string representation. This is based purely on observing the output as
    opposed to following any spec/documentation.
    """
    match node["type"]:
        case "doc":
            return "\n".join([atlas_doc_format_node_to_string(child) for child in node["content"]]).strip()
        case "paragraph":
            return " ".join([atlas_doc_format_node_to_string(child) for child in node["content"]]).strip()
        case "text":
            return node["text"].strip()
        case "mention":
            return node["attrs"]["text"].strip()
        case "date":
            return dt.datetime.fromtimestamp(int(node["attrs"]["timestamp"]) / 1000).strftime("%Y-%m-%d")
        case unknown_type:
            raise Exception(f"Not sure how to process node type {unknown_type}")


def task_body_to_text(node: dict) -> str:
    return atlas_doc_format_node_to_string(json.loads(node["body"]["atlas_doc_format"]["value"]))


@dataclass
class ConfluenceTask:
    raw: dict

    @property
    def body(self):
        return task_body_to_text(self.raw)

    @property
    def due_date(self) -> dt.datetime | None:
        due_at = self.raw["dueAt"]
        if due_at:
            return dt.datetime.fromisoformat(due_at)
        return None

    @property
    def space_id(self) -> str:
        return self.raw["spaceId"]

    def to_taskpaper(self, tags: list[str] = None):
        tp = f"- [ ] {self.body}"
        if self.due_date:
            tp += f" @due({self.due_date.astimezone().strftime('%Y-%m-%d %H:%M')})"
        if tags:
            tp += f" @tags({','.join(set(tags))})"
        return tp


@dataclass
class ConfluenceSpace:
    raw: dict

    @property
    def id(self):
        return self.raw["id"]

    @property
    def key(self):
        return self.raw["key"]

    @property
    def name(self):
        return self.raw["name"]


class Confluence:
    def __init__(self, base_url: str, email: str, api_token: str) -> None:
        self.base_url = base_url.removesuffix("/wiki")
        self.session = requests.Session()
        self.session.headers = {"Accept": "application/json"}
        self.session.auth = requests.auth.HTTPBasicAuth(email, api_token)

    @classmethod
    def from_config_path(cls, config_path: Path | None = None, section: str = "confluence"):
        if not config_path:
            config_path = Path(os.path.expandvars(os.getenv("XDG_CONFIG_HOME", "$HOME/.config"))) / "confluence.toml"
        config = tomllib.loads(config_path.read_text())
        confluence_config = ConfluenceConfig(**config[section])
        return Confluence(confluence_config.base_url, confluence_config.user, confluence_config.api_key)

    def get_page(self, page_id: str) -> dict | None:
        params = {"expand": "version"}
        response = self.session.get(f"{self.base_url}/wiki/rest/api/content/{page_id}", params=params)
        if response.status_code == 200:
            return response.json()
        else:
            print(f"Error getting the page. Status code: {response.status_code}", file=sys.stderr)
            return None

    def get_me(self):
        response = self.session.get(f"{self.base_url}/wiki/rest/api/user/current")
        response.raise_for_status()
        return response.json()

    def _get_v2_results(self, relative_url, params):
        results = []
        next_link = relative_url
        while next_link:
            response = self.session.get(f"{self.base_url}{next_link}", params=params)
            response.raise_for_status()
            data = response.json()
            results.extend(data["results"])
            next_link = data.get("_links", {}).get("next")
        return results

    def get_spaces(self, *, keys: list[str] = None, ids: list[str] = None):
        results = []
        if keys:
            results.extend(self._get_v2_results("/wiki/api/v2/spaces", params={"keys": keys}))
        if ids:
            results.extend(self._get_v2_results("/wiki/api/v2/spaces", params={"ids": ids}))
        return [ConfluenceSpace(s) for s in results]

    def get_my_tasks(self, space_ids: list[str] | None = None) -> list[ConfluenceTask]:
        me = self.get_me()
        results = self._get_v2_results(
            "/wiki/api/v2/tasks",
            params={
                "limit": 20,
                "assigned-to": me["accountId"],
                "status": "incomplete",
                "body-format": "atlas_doc_format",
                "space-id": space_ids,
            },
        )
        return [ConfluenceTask(r) for r in results]


# ============================================================================
# OmniFocus Integration
# ============================================================================


def encode_omnifocus_task_add_url(task: ConfluenceTask, space: ConfluenceSpace, page_url: str, dry_run: bool = False):
    params = {}
    params["name"] = task.body
    params["autosave"] = True
    hashtags = re.findall(r"#(\w+)", task.body)
    params["tags"] = ",".join(["Source: Confluence"] + hashtags)
    params["note"] = f"Task scraped from Confluence: {page_url}\nConfluence ID: [{task.raw['id']}]"
    if task.due_date:
        params["due"] = task.due_date.astimezone().strftime("%Y-%m-%d %H:%M")

    if dry_run:
        for k, v in params.items():
            print(f'    - {k}: "{v}"')

    return "omnifocus:///add?" + urlencode({k: v for k, v in params.items() if v}, quote_via=quote)


def add_omnifocus_task(task: ConfluenceTask, space: ConfluenceSpace, page_url: str, dry_run: bool = False):
    url = encode_omnifocus_task_add_url(task, space, page_url, dry_run)
    if not dry_run:
        import webbrowser

        webbrowser.open(url, new=0, autoraise=True)
    else:
        print("Add task:", url)


# ============================================================================
# Main
# ============================================================================


def get_space_for_task(confluence: Confluence, spaces: list[ConfluenceSpace], task: ConfluenceTask) -> ConfluenceSpace:
    matching = [s for s in spaces if s.id == task.space_id]
    if not matching:
        spaces.extend(confluence.get_spaces(ids=[task.space_id]))
        matching = [s for s in spaces if s.id == task.space_id]
    return matching[0]


def get_page_url(confluence: Confluence, page_id: str) -> str:
    page = confluence.get_page(page_id)
    return page["_links"]["base"] + page["_links"]["webui"]


def main():
    parser = argparse.ArgumentParser("Get Confluence tasks")
    parser.add_argument("--space", "-s", nargs="+", help="Confluence space key")
    parser.add_argument(
        "--dry-run", "-n", action="store_true",
        help="Show what would be done without taking action",
    )
    parser.add_argument(
        "--format", "-f",
        choices=["text", "json", "omnifocus"],
        default="text",
        help="Output format (default: text)",
    )
    args = parser.parse_args()

    confluence = Confluence.from_config_path()
    spaces = confluence.get_spaces(keys=args.space or [])
    tasks = confluence.get_my_tasks(space_ids=[s.id for s in spaces])

    if args.format == "json":
        print(json.dumps([t.raw for t in tasks], indent=2))
    elif args.format == "omnifocus":
        for task in tasks:
            space = get_space_for_task(confluence, spaces, task)
            page_url = get_page_url(confluence, task.raw["pageId"])
            add_omnifocus_task(task, space, page_url, dry_run=args.dry_run)
    else:
        for task in tasks:
            line = task.body
            if task.due_date:
                line += f" (due {task.due_date.astimezone().strftime('%Y-%m-%d')})"
            hashtags = re.findall(r"#(\w+)", task.body)
            if hashtags:
                line += f" [{', '.join(hashtags)}]"
            print(line)


if __name__ == "__main__":
    main()
