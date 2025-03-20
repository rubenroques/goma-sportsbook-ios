# Swift Code Migration Validator

A tool to verify that all code from a monolithic Swift file has been properly migrated to a set of extension files, ensuring no functionality is lost during refactoring.

## Purpose

When refactoring large Swift files into multiple extension files, it's easy to accidentally miss some code. This tool helps verify that all lines from the original file have been migrated to the new extension files.

## Requirements

- Python 3.6+
- PyYAML library (`pip install pyyaml`)

## Installation

1. Clone this repository or download the files
2. Install required dependencies:
   ```
   pip install pyyaml
   ```

## Usage

1. Create a YAML configuration file (see example in `config_example.yaml`)
2. Run the script:
   ```
   python swift_code_migration_validator.py path/to/your/config.yaml
   ```

### Configuration File Format

```yaml
# Path to the original monolithic Swift file
old_file: "path/to/MatchWidgetCollectionViewCell_old.swift"

# Path to the new extension files, can be a list or a glob pattern
new_files: 
  - "path/to/MatchWidgetCollectionViewCell+Layout.swift"
  - "path/to/MatchWidgetCollectionViewCell+Setup.swift"
  # Add all extension files here
  
# Alternatively, use a glob pattern:
# new_files: "path/to/*/Extensions/MatchWidgetCollectionViewCell+*.swift"

# Optional: List of patterns to ignore when comparing files
# Exact matches will be ignored, or use wildcards for partial matches
ignore_lines:
  - "import UIKit"  # Ignore this exact line
  - "*setNeedsLayout*"  # Ignore any line containing this text
  - "{" # Ignore opening braces
  - "}" # Ignore closing braces
```

## Output

The tool will report:
- Success message if all lines have been migrated successfully
- Line numbers and content of any missing lines
- Non-zero exit code if migration is incomplete (useful for CI integration)

## Example

```
$ python swift_code_migration_validator.py config.yaml
Reading original file: MatchWidgetCollectionViewCell_old.swift
Found 3 new extension files to compare
  - Reading MatchWidgetCollectionViewCell+Layout.swift
  - Reading MatchWidgetCollectionViewCell+Setup.swift
  - Reading MatchWidgetCollectionViewCell+Actions.swift
Using 4 line patterns to ignore

✅ SUCCESS: All lines from the original file have been migrated to the extension files. 