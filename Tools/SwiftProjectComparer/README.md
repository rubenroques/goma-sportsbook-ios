# Swift Project Comparer

A tool for comparing Swift types (classes, structs, enums, typealiases, protocols, extensions) between two project folders. It identifies types that exist in a legacy project but are missing in the base project, helping with project merging and code migration.

## Purpose

When two versions of a project diverge and are developed independently by different teams, it's challenging to identify what has been added to one project that needs to be merged into the other. This tool helps by:

1. Scanning both projects for Swift type definitions
2. Identifying which types exist in the legacy project but are missing in the base project
3. Generating a detailed report to guide the merging process

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
   python swift_project_comparer.py path/to/your/config.yaml
   ```

### Configuration File Format

```yaml
# Path to the base project directory (the one you're merging INTO)
base_directory: "/path/to/base/project"

# Path to the legacy project directory (the one you're merging FROM)
legacy_directory: "/path/to/legacy/project"

# Optional: Directories to exclude from analysis (e.g., third-party libraries)
excluded_directories:
  - "Pods"
  - "Carthage"
  - "ThirdParty"
  - ".git"

# Optional: Types to ignore in the comparison
ignored_types:
  # Ignore these type names regardless of their kind
  names:
    - "CodingKeys"
    - "AppDelegate"
  
  # Ignore specific classes
  classes:
    - "BaseViewController"
  
  # Ignore specific structs, enums, etc.
  structs:
    - "JSONResponseData"
  enums:
    - "APIError"
  
  # Ignore types matching regex patterns
  patterns:
    - ".*Tests$"
    - "Mock.*"

# Optional: Path where the report should be saved (if not provided, prints to console)
output_report: "comparison_report.md"
```

## What It Analyzes

The tool searches for and identifies:

- Classes
- Structs
- Enums
- Typealiases
- Protocols
- Extensions

It handles Swift access modifiers (public, internal, private, fileprivate) and additional keywords like `final`.

## Ignoring Types

The `ignored_types` configuration allows you to exclude types from the comparison that don't need to be migrated:

- **names**: Ignores types with these names regardless of their kind (class, struct, etc.)
- **classes/structs/enums/protocols/extensions**: Ignores only specific kinds of types
- **patterns**: Ignores types whose names match the provided regex patterns

This is useful for:
- Common utility types like `CodingKeys` enums used for JSON parsing
- Standard boilerplate classes like `AppDelegate`
- Generated code or test-related classes
- UIKit extensions (like `UIColor+Extensions`) that are often reimplemented

## Output

The tool generates a Markdown report that includes:

1. A summary of missing types
2. Types organized by category (classes, structs, etc.)
3. Types organized by folder structure in a hierarchical tree view
4. For each missing type:
   - The type name and kind
   - File path and line number for easy location

The folder structure view makes it easy to identify which components need to be migrated together.

## Example Report

```markdown
# Swift Project Comparison Report

## Summary

Total missing types: 42

## Missing Types by Type

### classes: 15
- **UserManager** (Line: 12)
- **NetworkMonitor** (Line: 25)
...

## Missing Types by Folder Structure

📂 **Legacy**
__📂 **Managers**
____📄 **UserManager.swift**
______• class **UserManager** (Line: 12)
__📂 **Networking**
____📄 **NetworkMonitor.swift**
______• class **NetworkMonitor** (Line: 25)
__📂 **Models**
____📂 **App**
______📄 **AppModels.swift**
________• struct **LocationSimple** (Line: 48)
________• enum **BannerAction** (Line: 325)
________• struct **RegionCountry** (Line: 477)
...
```

## Integration with CI/CD

The tool returns a non-zero exit code if any types are missing, making it easy to integrate with CI/CD pipelines to verify that all required types have been migrated.

## Limitations

- The tool only identifies type declarations, not their implementations or properties
- Generic types might not be correctly identified in all cases
- Nested types are identified by their inner name only 