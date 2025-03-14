# SwiftCellCloner

A Python tool for cloning Swift UICollectionViewCell files with their XIB files. This tool is particularly useful for refactoring large cell classes into multiple specialized cells based on different types.

## Overview

SwiftCellCloner helps you break down monolithic cell classes into smaller, more focused components by:

1. Creating subdirectories for each specialized cell type
2. Cloning the original Swift and XIB files into each directory
3. Renaming the classes to match their type (e.g., `LiveMatchWidgetCollectionViewCell`)
4. Updating class references in XIB files

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
  xib_file: "path/to/your/OriginalCell.xib"
  base_class_name: "OriginalCell"
```

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

- The tool assumes that your Swift classes conform to the `NibIdentifiable` protocol, which automatically provides `identifier` and `nib` properties based on the class name.
- The tool does not add any static identifier or nib properties to the cloned files.
- The tool only replaces the class name in the Swift file and the XIB file. It does not modify any other code.

## License

This tool is provided as-is with no warranty. Use at your own risk.