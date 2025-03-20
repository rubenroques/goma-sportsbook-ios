# SwiftCellCloner

A Python tool for cloning Swift UICollectionViewCell files with their extension files. This tool is particularly useful for refactoring large cell classes into multiple specialized cells based on different types.

## Overview

SwiftCellCloner helps you break down monolithic cell classes into smaller, more focused components by:

1. Creating subdirectories for each specialized cell type
2. Cloning the original Swift file into each directory
3. Cloning all extension files in the Extensions subdirectory
4. Renaming the classes to match their type (e.g., `LiveMatchWidgetCollectionViewCell`)

## Requirements

- Python 3.6+
- PyYAML package (`pip install pyyaml`)

## Installation

1. Clone this repository or copy the `SwiftCellCloner` directory to your project
2. Install the required Python packages:

```bash
pip install pyyaml
```

## Usage

1. Create a configuration file (or modify the existing `config.yaml`)
2. Run the script:

```bash
cd /path/to/your/project
python ./Tools/SwiftCellCloner/cell_cloner.py --config ./Tools/SwiftCellCloner/config.yaml
```

Or if you want to use a different configuration file:

```bash
python ./Tools/SwiftCellCloner/cell_cloner.py --config /path/to/your/config.yaml
```

## Configuration

The configuration file is in YAML format and contains the following sections:

### Source

Defines the source files and base class name:

```yaml
source:
  swift_file: "path/to/your/OriginalCell.swift"
  base_class_name: "OriginalCell"
```

The tool will automatically find all extension files in the "Extensions" directory located in the same directory as the main Swift file. Extension files should follow the naming pattern: `OriginalCell+ExtensionType.swift`.

### Output

Defines the base directory where the new files will be created:

```yaml
output:
  base_directory: "path/to/your/output/directory"
```

### Target Cases

Defines the list of cases to clone into:

```yaml
target_cases:
  - Case1
  - Case2
  - Case3
```

For each case, a subdirectory will be created with the case name, and the files will be cloned with the case name prefixed to the base class name. For example, if the base class name is `MatchWidgetCollectionViewCell` and the case is `Live`, the new class will be named `LiveMatchWidgetCollectionViewCell`.

## Example Configuration

See `config.example.yaml` for a complete example configuration.

## Notes

- The tool assumes your Swift files follow the standard naming conventions for iOS development.
- The tool handles extension files in a dedicated "Extensions" subdirectory.
- Files are expected to follow the naming pattern: `BaseClass+ExtensionType.swift`.
- The tool only replaces class and extension names in the files. It does not modify other code logic.

## License

This tool is provided as-is with no warranty. Use at your own risk.