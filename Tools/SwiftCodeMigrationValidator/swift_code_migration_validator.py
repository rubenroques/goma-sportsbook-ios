#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Swift Code Migration Validator
------------------------------
A tool to verify that all code from a monolithic Swift file has been properly migrated
to a set of extension files, ensuring no functionality is lost during refactoring.
"""

import os
import re
import sys
import yaml
import glob
import argparse
from pathlib import Path
from typing import List, Tuple, Dict, Set, Optional

def load_config(config_path: str) -> Dict:
    """Load the YAML configuration file"""
    with open(config_path, 'r') as file:
        return yaml.safe_load(file)

def normalize_code(text: str) -> List[str]:
    """
    Normalize code by removing comments, whitespace, extra empty lines
    to make comparison more accurate
    """
    lines = []
    for line in text.splitlines():
        # Remove single line comments
        line = re.sub(r'//.*$', '', line)
        # Remove multi-line comments
        line = re.sub(r'/\*.*?\*/', '', line, flags=re.DOTALL)
        # Remove doc comments
        line = re.sub(r'/\*\*.*?\*/', '', line, flags=re.DOTALL)
        # Trim whitespace
        line = line.strip()
        # Skip empty lines
        if line:
            lines.append(line)
    return lines

def read_file_content(file_path: str) -> str:
    """Read the content of a file with proper error handling"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        print(f"Error reading file {file_path}: {e}")
        sys.exit(1)

def get_file_list(file_spec) -> List[str]:
    """
    Get list of files from either a direct list or a glob pattern
    """
    if isinstance(file_spec, list):
        return file_spec
    else:
        # Treat as glob pattern
        files = glob.glob(file_spec)
        if not files:
            print(f"Warning: No files found matching pattern '{file_spec}'")
        return files

def should_ignore_line(line: str, ignore_patterns: List[str]) -> bool:
    """
    Check if a line should be ignored based on the ignore patterns
    """
    if not ignore_patterns:
        return False

    for pattern in ignore_patterns:
        if pattern == line or (pattern.startswith("*") and pattern.endswith("*") and pattern[1:-1] in line):
            return True
    return False

def compare_swift_files(config_path: str) -> List[Tuple[int, str]]:
    """
    Main function to compare old monolithic file with new extension files

    Returns a list of line numbers and content that are missing in the new files
    """
    config = load_config(config_path)

    # Read the old monolithic file
    old_file_path = config['old_file']
    print(f"Reading original file: {old_file_path}")
    old_code = read_file_content(old_file_path)
    old_lines = normalize_code(old_code)

    # Read all new extension files
    all_new_lines = []
    new_files = get_file_list(config['new_files'])

    print(f"Found {len(new_files)} new extension files to compare")
    for file_path in new_files:
        print(f"  - Reading {file_path}")
        new_code = read_file_content(file_path)
        all_new_lines.extend(normalize_code(new_code))

    # Get ignore patterns
    ignore_patterns = config.get('ignore_lines', [])
    if ignore_patterns:
        print(f"Using {len(ignore_patterns)} line patterns to ignore")

    # Find missing lines
    missing_lines = []
    for i, line in enumerate(old_lines):
        # Skip lines that match ignore patterns
        if should_ignore_line(line, ignore_patterns):
            continue

        if line not in all_new_lines:
            missing_lines.append((i+1, line))

    return missing_lines

def generate_report(old_file: str, missing_lines: List[Tuple[int, str]]) -> None:
    """Generate a report of the missing lines"""
    if not missing_lines:
        print("\n✅ SUCCESS: All lines from the original file have been migrated to the extension files.")
        return

    print(f"\n⚠️  MIGRATION INCOMPLETE: Found {len(missing_lines)} lines from {old_file} missing in new files")
    print("\nMissing lines:")
    for line_num, content in missing_lines:
        print(f"Line {line_num}: {content}")

    print(f"\nTotal missing lines: {len(missing_lines)}")

def main():
    parser = argparse.ArgumentParser(
        description='Validate Swift code migration from a monolithic file to extension files'
    )
    parser.add_argument(
        'config_path',
        help='Path to the YAML configuration file'
    )
    args = parser.parse_args()

    config = load_config(args.config_path)
    old_file_path = config['old_file']

    missing_lines = compare_swift_files(args.config_path)
    generate_report(old_file_path, missing_lines)

    # Return non-zero exit code if there are missing lines
    if missing_lines:
        sys.exit(1)

if __name__ == "__main__":
    main()