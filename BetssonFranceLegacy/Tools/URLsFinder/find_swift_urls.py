#!/usr/bin/env python3

import os
import re
import argparse
import yaml
from pathlib import Path
from typing import List, Set

class SwiftURLFinder:
    def __init__(self, config_path: str = "url_finder_config.yaml"):
        self.config = self._load_config(config_path)
        self.url_pattern = re.compile(
            r'(?:(?:https?|ftp)://|www\.)[\w/\-?=%.]+\.[\w/\-&?=%.]+',
            re.IGNORECASE
        )

    def _load_config(self, config_path: str) -> dict:
        """Load configuration from YAML file."""
        if not os.path.exists(config_path):
            return {
                "ignore_paths": [],
                "ignore_files": [],
                "ignore_urls": []
            }

        with open(config_path, 'r') as f:
            return yaml.safe_load(f)

    def _should_ignore_path(self, path: str) -> bool:
        """Check if path should be ignored based on config."""
        ignore_paths = self.config.get("ignore_paths", [])
        return any(ignored in str(path) for ignored in ignore_paths)

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
        start_path = Path(start_path)

        for path in start_path.rglob("*.swift"):
            if self._should_ignore_path(path) or self._should_ignore_file(path.name):
                continue

            urls = self.find_urls_in_file(path)
            if urls:
                relative_path = path.relative_to(start_path)
                results[str(relative_path)] = sorted(urls, key=lambda x: x[1])

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