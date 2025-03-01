#!/usr/bin/env python3

import os
import re
import argparse
import yaml
from pathlib import Path
from typing import List, Set
import pathspec

class SwiftURLFinder:
    def __init__(self, config_path: str = "url_finder_config.yaml"):
        self.config = self._load_config(config_path)
        self.ignore_spec = pathspec.PathSpec.from_lines('gitwildmatch', self.config.get("ignore_paths", []))
        self.url_pattern = re.compile(
            r'(?:(?:https?|ftp)://|www\.)[\w/\-?=%.]+\.[\w/\-&?=%.]+',
            re.IGNORECASE
        )

    def _load_config(self, config_path: str) -> dict:
        """Load configuration from YAML file."""
        # Load config file relative to the directory of this script
        config_full_path = os.path.join(os.path.dirname(__file__), config_path)
        if not os.path.exists(config_full_path):
            return {
                "ignore_paths": [],
                "ignore_files": [],
                "ignore_urls": []
            }

        with open(config_full_path, 'r') as f:
            return yaml.safe_load(f)

    def _should_ignore_path(self, relative_path: Path) -> bool:
        """Check if the relative path should be ignored using gitignore rules via pathspec."""
        # Check if the file itself is explicitly ignored
        file_path_str = relative_path.as_posix()
        if self.ignore_spec.match_file(file_path_str):
            return True

        # Check each parent directory to see if it is ignored (simulate gitignore's directory matching)
        for parent in relative_path.parents:
            # Append a trailing slash to indicate a directory
            parent_str = parent.as_posix() + "/"
            if self.ignore_spec.match_file(parent_str):
                return True
        return False

    def _should_ignore_file(self, filename: str) -> bool:
        """Check if file should be ignored based on its name."""
        ignore_files = self.config.get("ignore_files", [])
        return filename in ignore_files

    def _should_ignore_url(self, url: str) -> bool:
        """Check if URL should be ignored based on config."""
        ignore_urls = self.config.get("ignore_urls", [])
        return any(ignored in url for ignored in ignore_urls)

    def find_urls_in_file(self, file_path: Path) -> Set[str]:
        """Find all URLs in a single Swift file."""
        urls = set()
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                matches = self.url_pattern.finditer(content)
                for match in matches:
                    url = match.group()
                    if not self._should_ignore_url(url):
                        urls.add((url, match.start()))
        except Exception as e:
            print(f"Error reading file {file_path}: {e}")
        return urls

    def scan_directory(self, start_path: str) -> dict:
        """Scan directory recursively for Swift files and find URLs."""
        results = {}
        base_path = Path(start_path)

        for path in base_path.rglob("*.swift"):
            # Compute the relative path from the base directory
            relative = path.relative_to(base_path)
            if self._should_ignore_path(relative) or self._should_ignore_file(path.name):
                continue

            urls = self.find_urls_in_file(path)
            if urls:
                results[str(relative)] = sorted(urls, key=lambda x: x[1])

        return results

def main():
    parser = argparse.ArgumentParser(description='Find hardcoded URLs in Swift files')
    parser.add_argument('path', help='Path to scan for Swift files')
    parser.add_argument('--config', default='url_finder_config.yaml',
                      help='Path to configuration file (default: url_finder_config.yaml)')
    args = parser.parse_args()

    finder = SwiftURLFinder(args.config)
    results = finder.scan_directory(args.path)

    if not results:
        print("No URLs found in Swift files.")
        return

    print("\nFound URLs in Swift files:")
    print("=" * 80)

    for file_path, urls in results.items():
        print(f"\n{file_path}:")
        for url, position in urls:
            print(f"  Line position {position}: {url}")

if __name__ == "__main__":
    main()