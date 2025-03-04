#!/usr/bin/env python3
# auth_helper.py
# Helper script to obtain and manage authentication tokens for integration tests

import json
import os
import requests
import time
from pathlib import Path

# Constants
API_BASE_URL = "https://api.gomademo.com"
API_KEY = "i4iStOcZWBFbrmWvwaccKpdVhyRpRB6uZGE9akT6IFMpSwIa0Ghl4lqsFSvqPNhi"
DEVICE_UUID = "68de20be-0e53-3cac-a822-ad0414f13502"
DEVICE_TYPE = "ios"

# Path to store the authentication token
SCRIPT_DIR = Path(__file__).parent.absolute()
AUTH_FILE_PATH = SCRIPT_DIR / "auth_token.json"

def get_auth_token(force_refresh=False):
    """
    Get authentication token, either from cached file or by making a new request.
    
    Args:
        force_refresh (bool): If True, always get a new token regardless of expiration
        
    Returns:
        str: The authentication token
    """
    # Check if we have a cached token that's still valid
    if not force_refresh and os.path.exists(AUTH_FILE_PATH):
        try:
            with open(AUTH_FILE_PATH, 'r') as f:
                auth_data = json.load(f)
                
            # Check if token is still valid (with 5 minute buffer)
            if auth_data.get('expires_at', 0) > time.time() + 300:
                print(f"Using cached token (expires at {time.ctime(auth_data['expires_at'])})")
                return auth_data['token']
            else:
                print("Cached token has expired, requesting new token")
        except Exception as e:
            print(f"Error reading cached token: {e}")
    
    # Request a new token
    return request_new_token()

def request_new_token():
    """
    Request a new authentication token from the API
    
    Returns:
        str: The new authentication token
    """
    url = f"{API_BASE_URL}/api/auth/v1"
    headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "x-api-key": API_KEY
    }
    payload = {
        "device_uuid": DEVICE_UUID,
        "device_type": DEVICE_TYPE
    }
    
    try:
        response = requests.post(url, headers=headers, json=payload)
        response.raise_for_status()
        
        auth_data = response.json()
        
        # Save the token to file
        with open(AUTH_FILE_PATH, 'w') as f:
            json.dump(auth_data, f, indent=2)
        
        print(f"New token obtained (expires at {time.ctime(auth_data['expires_at'])})")
        return auth_data['token']
    
    except Exception as e:
        print(f"Error obtaining authentication token: {e}")
        if hasattr(response, 'text'):
            print(f"Response: {response.text}")
        raise

def extract_token_from_response(response_json):
    """
    Extract token from authentication response
    
    Args:
        response_json (dict): The JSON response from the authentication API
        
    Returns:
        str: The authentication token
    """
    return response_json.get('token', '')

if __name__ == "__main__":
    # When run directly, get a new token and print it
    token = get_auth_token(force_refresh=True)
    print(f"Authentication Token: {token}") 