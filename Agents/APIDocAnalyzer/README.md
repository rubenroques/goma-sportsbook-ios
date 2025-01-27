# API Documentation Analyzer

A tool for analyzing API documentation and Swift model files to extract structured information about models, their properties, relationships, and endpoints.

## Features

- Parses Swift model files using SwiftSyntax
- Extracts model properties and their types
- Identifies relationships between models
- Catalogs REST and WebSocket endpoints
- Supports both Swift parser and GPT-4 analysis modes
- Generates structured JSON output

## Prerequisites

- Python 3.8+
- Swift 5.9+
- SwiftSyntax package

## Installation

1. Clone the repository
2. Install Python dependencies:
```bash
pip install -r requirements.txt
```
3. Build the Swift parser:
```bash
swift build
```

## Usage

Basic usage:
```bash
python analyzer.py <path_to_documentation> <root_folder>
```

Options:
- `--gpt`: Use GPT-4 for analysis (requires OpenAI API key)
- `--verbose`: Show detailed logging

Example:
```bash
python analyzer.py api_docs.json /path/to/swift/files --verbose
```

## Output Format

The tool generates an `api_inventory.json` file with the following structure:

```json
{
  "models": [
    {
      "name": "ModelName",
      "properties": {
        "propertyName": {
          "type": "PropertyType",
          "description": "Property description"
        }
      },
      "path": "path/to/swift/file"
    }
  ],
  "relationships": [
    {
      "source": "SourceModel",
      "target": "TargetModel",
      "via": "propertyName"
    }
  ],
  "endpoints": {
    "rest": ["endpoint1", "endpoint2"],
    "websocket": ["wsEndpoint1", "wsEndpoint2"]
  }
}
```

## Project Structure

- `analyzer.py`: Main script for orchestrating the analysis
- `finder.py`: Handles finding Swift files and model implementations
- `parser.py`: Python interface to the Swift parser
- `swift_parser.swift`: Swift script for parsing model files using SwiftSyntax
- `requirements.txt`: Python dependencies
- `Package.swift`: Swift package dependencies

## Dependencies

Python:
- openai>=1.12.0
- python-dotenv>=1.0.0
- pathlib>=1.0.1
- typing-extensions>=4.5.0

Swift:
- SwiftSyntax 509.0.0+

## Error Handling

- Logs missing models
- Attempts recovery from manual definitions
- Validates file paths and API keys
- Handles parsing edge cases

## Contributing

1. Fork the repository
2. Create your feature branch
3. Submit a pull request

## License

MIT

## For LLMs

```context
SYSTEM: You are analyzing a Python tool designed for API documentation analysis.

OBJECTIVE: Extract and analyze Swift models from API documentation and codebase.

KEY COMPONENTS:
1. Input:
   - JSON API documentation with endpoints, signatures, and schemas
   - Swift codebase containing model implementations
   - Optional manual_missing_models.swift for fallback definitions

2. Core Functionality:
   - Signature Parser: Extracts model names from function signatures
     - Handles: AnyPublisher<T, Error>, [T], SubscribableContent<T>
   - Swift Parser: Extracts properties and relationships from Swift code
   - Model Analyzer: Maps properties, types, and relationships

3. Data Structures:
   - Models: Array[{name, properties, path}]
   - Properties: {type, description}
   - Relationships: [{source, via, target}]

4. Caching Strategy:
   - model_cache: Analyzed models
   - schema_cache: Schema analysis results
   - swift_models: Raw implementations
   - swift_files: File contents

EXECUTION FLOW:
1. Load Swift files recursively
2. Process API documentation
3. Extract models from signatures
4. Find and parse Swift implementations
5. Generate relationships graph
6. Check manual models for missing ones
7. Output JSON inventory

OUTPUT: api_inventory.json with models, relationships, and endpoints
```
