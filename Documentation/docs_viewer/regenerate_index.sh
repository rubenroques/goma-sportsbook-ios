#!/bin/bash
# This script regenerates the files.json index for the documentation viewer.

# Get the absolute path of the Documentation directory (one level up from the script)
DOCS_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Navigate to the Documentation directory
cd "$DOCS_ROOT"

# Generate the JSON file index, ignoring the docs_viewer directory itself
tree -J -I 'docs_viewer' . > docs_viewer/files.json

echo "Documentation index has been regenerated."
