#!/usr/bin/env python3
"""
Jira Release Notifier

Parses CHANGELOG.yml for a given version/build, extracts JIRA ticket references,
adds deployment comments to each ticket, and transitions them to "In QA".

Usage:
    python jira_release_notifier.py

Required Environment Variables:
    JIRA_EMAIL        - Jira account email
    JIRA_API_TOKEN    - Jira API token
    JIRA_BASE_URL     - Jira base URL (e.g., https://gomagaming.atlassian.net)
    VERSION           - Release version (e.g., 0.3.8)
    BUILD             - Build number (e.g., 3801)
    CHANGELOG_FILE    - Path to CHANGELOG.yml
    CLIENT_NAME       - Client name for the comment (e.g., BetssonCameroon)
"""

import os
import re
import sys
import yaml
import requests
from requests.auth import HTTPBasicAuth
from typing import Dict, List, Optional, Set


def get_env_or_exit(name: str) -> str:
    """Get environment variable or exit with error."""
    value = os.environ.get(name)
    if not value:
        print(f"Error: {name} environment variable is required")
        sys.exit(1)
    return value


def parse_changelog(changelog_path: str, version: str, build: int) -> List[str]:
    """Parse CHANGELOG.yml and extract notes for the given version/build."""
    try:
        with open(changelog_path, 'r') as f:
            changelog = yaml.safe_load(f)
    except FileNotFoundError:
        print(f"Warning: Changelog file not found: {changelog_path}")
        return []
    except yaml.YAMLError as e:
        print(f"Warning: Failed to parse changelog: {e}")
        return []

    releases = changelog.get('releases', [])
    for release in releases:
        if release.get('version') == version and release.get('build') == build:
            return release.get('notes', [])

    print(f"Warning: No changelog entry found for v{version} ({build})")
    return []


def extract_jira_tickets(notes: List[str]) -> Set[str]:
    """Extract unique JIRA ticket IDs from release notes."""
    pattern = r'SPOR-\d+'
    tickets = set()

    for note in notes:
        matches = re.findall(pattern, note, re.IGNORECASE)
        tickets.update(match.upper() for match in matches)

    return tickets


class JiraClient:
    """Simple Jira REST API client."""

    def __init__(self, base_url: str, email: str, api_token: str):
        self.base_url = base_url.rstrip('/')
        self.auth = HTTPBasicAuth(email, api_token)
        self.headers = {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
        }

    def add_comment(self, issue_key: str, comment: str) -> bool:
        """Add a comment to a Jira issue."""
        url = f"{self.base_url}/rest/api/3/issue/{issue_key}/comment"

        # Atlassian Document Format (ADF) for the comment body
        payload = {
            "body": {
                "type": "doc",
                "version": 1,
                "content": [
                    {
                        "type": "paragraph",
                        "content": [
                            {
                                "type": "text",
                                "text": comment
                            }
                        ]
                    }
                ]
            }
        }

        try:
            response = requests.post(url, json=payload, auth=self.auth, headers=self.headers)
            if response.status_code in (200, 201):
                print(f"  Added comment to {issue_key}")
                return True
            else:
                print(f"  Failed to add comment to {issue_key}: {response.status_code} - {response.text}")
                return False
        except requests.RequestException as e:
            print(f"  Error adding comment to {issue_key}: {e}")
            return False

    def get_transitions(self, issue_key: str) -> List[Dict]:
        """Get available transitions for an issue."""
        url = f"{self.base_url}/rest/api/3/issue/{issue_key}/transitions"

        try:
            response = requests.get(url, auth=self.auth, headers=self.headers)
            if response.status_code == 200:
                return response.json().get('transitions', [])
            else:
                print(f"  Failed to get transitions for {issue_key}: {response.status_code}")
                return []
        except requests.RequestException as e:
            print(f"  Error getting transitions for {issue_key}: {e}")
            return []

    def transition_issue(self, issue_key: str, transition_id: str) -> bool:
        """Transition an issue to a new status."""
        url = f"{self.base_url}/rest/api/3/issue/{issue_key}/transitions"

        payload = {
            "transition": {
                "id": transition_id
            }
        }

        try:
            response = requests.post(url, json=payload, auth=self.auth, headers=self.headers)
            if response.status_code == 204:
                return True
            else:
                print(f"  Failed to transition {issue_key}: {response.status_code} - {response.text}")
                return False
        except requests.RequestException as e:
            print(f"  Error transitioning {issue_key}: {e}")
            return False

    def transition_to_in_qa(self, issue_key: str) -> bool:
        """
        Transition an issue to 'In QA' status.
        Handles the workflow path: To Do -> In Progress -> In Review -> In QA
        """
        # Target status names (case-insensitive matching)
        target_statuses = ['in qa', 'quality']

        transitions = self.get_transitions(issue_key)
        if not transitions:
            return False

        # First, try direct transition to "In QA"
        for t in transitions:
            to_status = t.get('to', {}).get('name', '').lower()
            if to_status == 'in qa' or t.get('name', '').lower() == 'quality':
                if self.transition_issue(issue_key, t['id']):
                    print(f"  Transitioned {issue_key} to In QA")
                    return True

        # If no direct path, try intermediate transitions
        # Order of preference: In Review -> In Progress -> then try In QA again
        intermediate_targets = [
            ('review', 'in review'),
            ('start', 'in progress'),
        ]

        for transition_name, status_name in intermediate_targets:
            for t in transitions:
                t_name = t.get('name', '').lower()
                to_status = t.get('to', {}).get('name', '').lower()
                if t_name == transition_name or to_status == status_name:
                    if self.transition_issue(issue_key, t['id']):
                        print(f"  Transitioned {issue_key} to {t.get('to', {}).get('name', 'next status')}")
                        # Recursively try to reach In QA
                        return self.transition_to_in_qa(issue_key)

        print(f"  Could not find path to 'In QA' for {issue_key}")
        return False

    def get_issue_status(self, issue_key: str) -> Optional[str]:
        """Get the current status of an issue."""
        url = f"{self.base_url}/rest/api/3/issue/{issue_key}?fields=status"

        try:
            response = requests.get(url, auth=self.auth, headers=self.headers)
            if response.status_code == 200:
                return response.json().get('fields', {}).get('status', {}).get('name')
            else:
                return None
        except requests.RequestException:
            return None


def main():
    # Get configuration from environment
    jira_email = get_env_or_exit('JIRA_EMAIL')
    jira_token = get_env_or_exit('JIRA_API_TOKEN')
    jira_base_url = get_env_or_exit('JIRA_BASE_URL')
    version = get_env_or_exit('VERSION')
    build = int(get_env_or_exit('BUILD'))
    changelog_file = get_env_or_exit('CHANGELOG_FILE')
    client_name = os.environ.get('CLIENT_NAME', 'App')

    print(f"Jira Release Notifier")
    print(f"=====================")
    print(f"Version: {version} ({build})")
    print(f"Client: {client_name}")
    print(f"Changelog: {changelog_file}")
    print()

    # Parse changelog and extract tickets
    notes = parse_changelog(changelog_file, version, build)
    if not notes:
        print("No release notes found. Exiting.")
        sys.exit(0)

    print(f"Found {len(notes)} release notes")

    tickets = extract_jira_tickets(notes)
    if not tickets:
        print("No JIRA tickets found in release notes. Exiting.")
        sys.exit(0)

    print(f"Found {len(tickets)} JIRA tickets: {', '.join(sorted(tickets))}")
    print()

    # Initialize Jira client
    jira = JiraClient(jira_base_url, jira_email, jira_token)

    # Process each ticket
    comment = f"Deployed to QA in {client_name} v{version} ({build})"

    success_count = 0
    for ticket in sorted(tickets):
        print(f"Processing {ticket}...")

        # Get current status
        current_status = jira.get_issue_status(ticket)
        if current_status:
            print(f"  Current status: {current_status}")

        # Skip if already in QA or Done
        if current_status and current_status.lower() in ['in qa', 'done']:
            print(f"  Skipping transition (already in {current_status})")
            # Still add the comment
            jira.add_comment(ticket, comment)
            success_count += 1
            continue

        # Add comment
        jira.add_comment(ticket, comment)

        # Transition to In QA
        if jira.transition_to_in_qa(ticket):
            success_count += 1

    print()
    print(f"Processed {success_count}/{len(tickets)} tickets successfully")


if __name__ == '__main__':
    main()
