# Swift Dependency Graph Generator

A tool for analyzing Swift projects to identify dependencies between types, detect circular dependencies, and generate an interactive visualization.

## Features

- 📊 **Dependency Analysis**: Maps dependencies between classes, structs, enums, and protocols
- 🔄 **Circular Dependency Detection**: Automatically identifies circular dependencies
- 💡 **Smart Suggestions**: Provides recommendations for breaking circular dependencies
- 🌐 **Interactive Visualization**: Generates an HTML visualization for exploring the dependency graph
- 🔎 **Filtering and Search**: Filter by type, search for specific classes, or focus on circular dependencies

## Requirements

- Python 3.6+
- Required Python packages (install via pip):
  - networkx
  - pyyaml

## Installation

1. Clone this repository or download the files
2. Install required dependencies:
   ```
   pip install networkx pyyaml
   ```

## Usage

1. Create a YAML configuration file (see example in `config_example.yaml`)
2. Run the script:
   ```
   python swift_dependency_grapher.py path/to/your/config.yaml
   ```
3. The tool will generate an HTML file with the interactive visualization and open it in your default browser

### Configuration File Format

```yaml
# Path to your Swift project directory
project_directory: "/path/to/your/swift/project"

# Directories to exclude from analysis
excluded_directories:
  - "Pods"
  - "Carthage"
  - ".git"
  - "Scripts"

# Output HTML file path
output_file: "dependency_graph.html"
```

## Analyzing Circular Dependencies

Circular dependencies can cause several issues in your codebase:
- Tight coupling between components
- Difficult to test components in isolation
- Memory retention cycles
- Compilation issues

This tool helps you identify circular dependencies and provides suggestions on how to break them, such as:
- Using protocols instead of concrete types
- Replacing inheritance with composition
- Separating components into modules

## Interactive Features

The generated HTML visualization includes:
- Interactive dependency graph with zoom/pan
- Filtering options (by type kind, cycles only)
- Search functionality
- Detailed information for each node
- Clickable circular dependency paths
- Customizable view layouts

## Examples

To run the tool on the Sportsbook iOS project:

```bash
cd /Users/rroques/Desktop/GOMA/iOS/sportsbook-ios
python Tools/SwiftDependencyGrapher/swift_dependency_grapher.py Tools/SwiftDependencyGrapher/config_example.yaml
```

## Screenshot

![Swift Dependency Graph Screenshot](https://via.placeholder.com/800x500?text=Swift+Dependency+Graph+Visualization)

## Limitations

- The dependency detection uses regex pattern matching and may miss some complex relationships
- Generic types and associated types may not be fully represented
- Protocol conformance through extensions might not be accurately reflected
- The tool doesn't analyze external dependencies (only types defined in your project) 