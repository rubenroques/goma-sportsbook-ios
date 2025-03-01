# Swift URL Finder

A Python script to find hardcoded URLs in Swift source files. This tool recursively scans Swift files in a directory and its subdirectories, identifying URLs and their positions within the files.

## Features

- 🔍 Recursively scans Swift files for URLs
- ⚙️ Configurable path and URL exclusions via YAML
- 📝 Reports exact positions of URLs in files
- 🚫 Ignores specified directories, files, and URLs
- 💪 Handles UTF-8 encoding
- ⚡️ Fast and efficient scanning
- 🛠 Customizable regex pattern for URL detection

## Prerequisites

- Python 3.11 or higher
- PyYAML package

## Installation

1. Make sure you have Python installed:
```bash
mise use python@3.11  # or your preferred Python version manager
```

2. Install the required package:
```bash
pip install pyyaml
```

3. Make the script executable:
```bash
chmod +x find_swift_urls.py
```

## Usage

### Basic Usage

```bash
./find_swift_urls.py <directory_to_scan>
```

### With Custom Configuration

```bash
./find_swift_urls.py <directory_to_scan> --config my_config.yaml
```

## Configuration

The tool uses a YAML configuration file (`url_finder_config.yaml`) to specify which paths, files, and URLs to ignore. Here's an example configuration:

```yaml
# Paths to ignore (partial matches)
ignore_paths:
  - ".build/"
  - "Pods/"
  - "fastlane/"
  - "Tests/"

# Files to ignore (exact matches)
ignore_files:
  - "Package.swift"
  - "Package.resolved"

# URLs to ignore (partial matches)
ignore_urls:
  - "example.com"
  - "localhost"
  - "127.0.0.1"
```

### Configuration Options

- `ignore_paths`: List of directory paths to ignore (supports partial matches)
- `ignore_files`: List of specific filenames to ignore (exact matches)
- `ignore_urls`: List of URLs to ignore (supports partial matches)

## Output Format

The tool outputs results in the following format:

```
Found URLs in Swift files:
================================================================================

path/to/file.swift:
  Line position 123: https://example.com
  Line position 456: https://api.example.com
```

Each URL is displayed with:
- The relative path to the file containing the URL
- The character position in the file where the URL starts
- The complete URL found

## Error Handling

- Files that cannot be read (due to permissions or encoding issues) are reported with an error message
- Invalid configuration files will fall back to default settings
- Non-existent directories will result in an appropriate error message

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Created by the GOMA iOS Team

## Acknowledgments

- Uses PyYAML for configuration parsing
- Inspired by the need to track and manage hardcoded URLs in Swift projects