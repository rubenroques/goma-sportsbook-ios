# Existing Tools Catalog

This document catalogs the existing development tools that could be integrated into the Developer Dashboard.

## Code Analysis Tools

### Swift Types Analyzer
- **Location**: `Tools/ReportingTools/analyze_swift_types.py`
- **Description**: Analyzes Swift files for classes, structs, and enums
- **Parameters**:
  - `folder`: Folder to scan (default: project root)
  - `--output, -o`: Output file path
  - `--format`: Output format (markdown, html, json)
  - `--top-files`: Number of top largest files to include
- **Output**: Report showing type distribution, files with multiple declarations, and recommendations
- **Dashboard Integration**: Interactive charts, filterable tables, code preview

## Reporting Tools

*Add other reporting tools here*

## Testing Tools

*Add testing tools here*

## Documentation Tools

*Add documentation tools here*

## Integration Template

For each tool, the following information should be collected for dashboard integration:

```
## Tool Name

### Basic Information
- **Location**: Path to the tool
- **Description**: What the tool does
- **Category**: Code Analysis, Testing, Documentation, etc.

### Execution Details
- **Command**: How to run the tool
- **Parameters**: List of parameters and their descriptions
- **Environment**: Any special environment requirements

### Output Processing
- **Format**: Raw output format (text, JSON, HTML, etc.)
- **Parsing Strategy**: How to parse the output for visualization
- **Visualization Ideas**: Suggested visualizations for the dashboard

### Integration Priority
- **Value**: High/Medium/Low
- **Integration Difficulty**: High/Medium/Low
- **Dependencies**: Any dependencies on other tools or systems
``` 