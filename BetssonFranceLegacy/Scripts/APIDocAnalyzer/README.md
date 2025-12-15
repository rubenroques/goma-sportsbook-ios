# API Documentation Analyzer

A tool that analyzes Swift codebase and API documentation to generate comprehensive documentation with model relationships, endpoints, and type information.

## Features

- Parses Swift model files using SwiftSyntax
- Extracts model properties and their types
- Identifies relationships between models
- Catalogs REST and WebSocket endpoints
- Generates Markdown documentation with linked models
- Supports both direct file parsing and GPT-4 analysis modes

## Prerequisites

- macOS 13.0+
- Python 3.8+
- Swift 5.9+
- Xcode Command Line Tools
- SwiftSyntax package

## Installation

1. Clone the repository
2. Install Python dependencies:
```bash
pip install -r requirements.txt
```
3. Build the Swift parser:
```bash
cd APIDocAnalyzer
swift build
```

## Required Dependencies

### Python Packages
```
openai>=1.12.0
python-dotenv>=1.0.0
pathlib>=1.0.1
typing-extensions>=4.5.0
```

### Swift Packages
```swift
.package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0")
```

## Usage

### Basic Analysis
```bash
python analyzer.py <path_to_documentation.json> <root_folder> [--verbose]
```

### With GPT Analysis
```bash
python analyzer.py <path_to_documentation.json> <root_folder> --gpt --verbose
```

### Generate Documentation
```bash
swift run DocGenerator api_inventory.json sportradar_documentation.json
```

## Input Files

1. API Documentation JSON:
```json
{
  "api_methods": {
    "category": {
      "endpoint": {
        "description": "Description",
        "signature": "func name() -> ReturnType",
        "parameters": { ... }
      }
    }
  },
  "websocket_methods": { ... }
}
```

2. Swift Model Files:
- Must be accessible from the root folder
- Should contain model definitions (struct/class/enum)
- Can be in any subfolder structure

## Output Files

1. `api_inventory.json`:
```json
{
  "models": [
    {
      "name": "ModelName",
      "path": "path/to/file.swift",
      "properties": [
        {
          "name": "propertyName",
          "type": "PropertyType"
        }
      ],
      "relationships": [
        {
          "source_property": "propertyName",
          "target_type": "RelatedModel"
        }
      ]
    }
  ],
  "endpoints": {
    "rest": ["endpoint1"],
    "websocket": ["ws1"]
  }
}
```

2. `API.md`:
- Generated Markdown documentation
- Linked model references
- Organized sections for REST/WebSocket endpoints
- Property tables for each model
- Related model links

## Error Handling

The tool handles several edge cases:
- Missing model implementations
- Invalid Swift syntax
- Malformed JSON documentation
- Circular model dependencies
- File access permissions
- Swift build failures

## For LLMs

```context
SYSTEM: You are analyzing a documentation generator for Swift APIs.

OBJECTIVE: Generate comprehensive API documentation by analyzing Swift codebase and API specifications.

KEY COMPONENTS:

1. Data Sources:
   - Swift source files (.swift)
   - API documentation (JSON)
   - Model inventory (JSON)

2. Analysis Pipeline:
   a. Swift Parser (SwiftSyntax)
      - Extracts: structs, classes, enums
      - Handles: properties, types, relationships
      - Supports: optionals, arrays, dictionaries

   b. Documentation Analyzer
      - Maps: endpoints to models
      - Tracks: type relationships
      - Formats: markdown output

   c. Model Resolution
      - Direct: Swift file parsing
      - Indirect: Type inference
      - Fallback: Manual definitions

3. Type System:
   - Base Types: String, Int, Double, Bool, Date
   - Collections: Array<T>, Dictionary<K,V>
   - Custom Types: All user-defined models
   - Special: AnyPublisher<T,E>, Optional<T>

4. Documentation Structure:
   - REST Services
     - Endpoints
     - Arguments
     - Return Types
   - Real-time Services
     - WebSocket endpoints
     - Subscription details
   - Data Models
     - Properties
     - Type relationships
     - Cross-references

EXECUTION CONTEXT:
- Environment: macOS
- Runtime: Python 3.8+, Swift 5.9+
- Dependencies: SwiftSyntax, OpenAI (optional)
- File System: Read access to Swift sources

OUTPUT FORMATS:
1. Inventory (JSON)
   - Model definitions
   - Type relationships
   - Endpoint catalog

2. Documentation (Markdown)
   - Linked references
   - Type tables
   - API endpoints
```

## License

MIT
