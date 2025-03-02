#!/usr/bin/env python3
# fetch_responses.py
# Helper script to fetch and save API responses for integration tests

import json
import os
import requests
from pathlib import Path
import sys

# Add the current directory to the path so we can import auth_helper
sys.path.append(str(Path(__file__).parent.absolute()))
from auth_helper import get_auth_token

# Constants
API_BASE_URL = "https://api.gomademo.com"
API_KEY = "i4iStOcZWBFbrmWvwaccKpdVhyRpRB6uZGE9akT6IFMpSwIa0Ghl4lqsFSvqPNhi"

# Path to store the mock responses
SCRIPT_DIR = Path(__file__).parent.absolute()
MOCK_RESPONSES_DIR = SCRIPT_DIR.parent / "MockResponses"

# Endpoint definitions
ENDPOINTS = {
    "HomeTemplate": {
        "path": "/api/home/v1/template",
        "method": "GET",
        "params": {"platform": "ios"}
    },
    "AlertBanner": {
        "path": "/api/promotions/v1/alert-banner",
        "method": "GET",
        "params": {}
    },
    "Banners": {
        "path": "/api/promotions/v1/banners",
        "method": "GET",
        "params": {}
    },
    "CarouselEvents": {
        "path": "/api/promotions/v1/sport-banners",
        "method": "GET",
        "params": {}
    },
    "BoostedOddsBanners": {
        "path": "/api/promotions/v1/boosted-odds-banners",
        "method": "GET",
        "params": {}
    },
    "HeroCards": {
        "path": "/api/promotions/v1/hero-cards",
        "method": "GET",
        "params": {}
    },
    "Stories": {
        "path": "/api/promotions/v1/stories",
        "method": "GET",
        "params": {}
    },
    "News": {
        "path": "/api/promotions/v1/news",
        "method": "GET",
        "params": {"pageIndex": 0, "pageSize": 10}
    },
    "ProChoices": {
        "path": "/api/promotions/v1/pro-choices",
        "method": "GET",
        "params": {}
    },
    "InitialDump": {
        "path": "/api/initial-dump/v1",
        "method": "GET",
        "params": {"platform": "ios"}
    }
}

def fetch_and_save_response(endpoint_name, endpoint_config):
    """
    Fetch response from the API and save it to a file

    Args:
        endpoint_name (str): Name of the endpoint
        endpoint_config (dict): Configuration for the endpoint
    """
    # Get authentication token
    token = get_auth_token()

    # Prepare request
    url = f"{API_BASE_URL}{endpoint_config['path']}"
    headers = {
        "Accept": "application/json",
        "Authorization": f"Bearer {token}",
        "x-api-key": API_KEY
    }

    # Make request
    try:
        if endpoint_config['method'] == "GET":
            response = requests.get(url, headers=headers, params=endpoint_config['params'])
        else:
            response = requests.post(url, headers=headers, json=endpoint_config['params'])

        response.raise_for_status()

        # Parse response
        response_data = response.json()

        # Create directory if it doesn't exist
        output_dir = MOCK_RESPONSES_DIR / endpoint_name
        os.makedirs(output_dir, exist_ok=True)

        # Save response to file
        output_file = output_dir / "response.json"
        with open(output_file, 'w') as f:
            json.dump(response_data, f, indent=2)

        print(f"✅ Successfully saved {endpoint_name} response to {output_file}")

    except Exception as e:
        print(f"❌ Error fetching {endpoint_name}: {e}")
        if hasattr(response, 'text'):
            print(f"Response: {response.text}")

def fetch_all_responses():
    """
    Fetch and save responses for all endpoints
    """
    print("Fetching responses for all endpoints...")

    for endpoint_name, endpoint_config in ENDPOINTS.items():
        print(f"\nFetching {endpoint_name}...")
        fetch_and_save_response(endpoint_name, endpoint_config)

    print("\nAll responses fetched and saved.")

if __name__ == "__main__":
    fetch_all_responses()