from typing import Dict, List, Optional, Any, Set, Tuple
import json
import os
import sys
from pathlib import Path
from openai import OpenAI
from dotenv import load_dotenv
from enum import Enum, auto
from finder import SwiftFileFinder
from parser import SwiftParser
from logger_config import setup_logger, get_log_level
import re
import traceback

class AnalysisMode(Enum):
    SWIFT_PARSER = auto()  # Use Python to parse Swift files
    GPT = auto()          # Use OpenAI GPT to analyze models

class APIDocAnalyzer:
    """
    Analyzes API documentation in JSON format to extract models, relationships,
    and endpoint categorization.
    """

    def __init__(self, root_folder: str, mode: AnalysisMode = AnalysisMode.SWIFT_PARSER, verbose: bool = False):
        """
        Initialize the analyzer.

        Args:
            root_folder: Root folder path where to search for Swift files
            mode: Analysis mode (SWIFT_PARSER or GPT)
            verbose: Whether to show detailed logging
        """
        self.logger = setup_logger(level=get_log_level(verbose))
        self.logger.info("Initializing API Documentation Analyzer")
        self.mode = mode
        self.logger.info(f"Using analysis mode: {mode.name}")

        # Statistics tracking
        self.stats = {
            'swift_files_found': 0,
            'models_found': 0,
            'models_parsed': 0,
            'models_in_inventory': 0
        }

        # Track not found models and parsing failures
        self.not_found_models: Set[str] = set()
        self.parsing_failures: Dict[str, Dict] = {}  # Track detailed parsing failures
        self.model_locations: Dict[str, Dict[str, str]] = {}  # Track where each model is defined

        # Initialize components
        self.root_folder = root_folder
        self.swift_finder = SwiftFileFinder(root_folder)
        self.swift_parser = SwiftParser()

        # Load all Swift files at initialization
        self.swift_files = self.swift_finder.load_swift_files()
        self.stats['swift_files_found'] = len(self.swift_files)
        self.logger.info("Initialization complete")

    def _log_parsing_failure(self, model_name: str, file_path: str, error_info: Dict):
        """Log detailed information about a parsing failure"""
        self.parsing_failures[model_name] = {
            'file_path': file_path,
            'error_info': error_info
        }


    def analyze_documentation(self, doc_path: str) -> Dict:
        """
        Analyze the API documentation and generate an inventory of models and endpoints.
        """
        self.logger.info(f"Starting analysis of API documentation: {doc_path}")

        with open(doc_path, 'r') as f:
            self.api_doc = json.load(f)

        # Extract model names and endpoints
        model_names = self._extract_model_names()
        endpoints = self._extract_endpoints()

        self.stats['models_found'] = len(model_names)
        self.logger.info(f"Found {len(model_names)} models to analyze")
        self.logger.info(f"Found {len(endpoints)} endpoints")

        # Analyze each model
        models = []
        model_info = {}
        processed_count = 0
        total_models = len(model_names)

        # Use Swift parser to analyze each model
        for model_name in model_names:
            # Only log every 10th model or if it's the last one
            processed_count += 1
            if processed_count % 10 == 0 or processed_count == total_models:
                self.logger.info(f"Progress: {processed_count}/{total_models} models processed")

            # Moved to debug level since it's in a loop
            self.logger.debug(f"Analyzing model: {model_name}")

            # Get model location from our mapping
            model_data = self.model_locations.get(model_name)
            if model_data:
                file_path = model_data['file_path']
                implementation = model_data['implementation']

                try:
                    # Parse the model using Swift parser
                    properties = self.swift_parser.parse_properties(file_path, model_name)
                    if properties:
                        self.stats['models_parsed'] += 1
                        # Convert properties to dictionary format
                        model_data = self.swift_parser.properties_to_dict(properties)
                        model_data['name'] = model_name
                        model_data['path'] = file_path
                        models.append(model_data)
                        model_info[model_name] = model_data
                    else:
                        # Detailed logging for parsing failures
                        error_info = {
                            'reason': 'No properties returned',
                            'implementation_preview': implementation[:500] if implementation else 'No implementation found',
                            'file_size': os.path.getsize(file_path) if os.path.exists(file_path) else 'File not found',
                            'stack_trace': traceback.format_stack()
                        }
                        self._log_parsing_failure(model_name, file_path, error_info)
                        self.not_found_models.add(model_name)
                except Exception as e:
                    # Detailed logging for parsing exceptions
                    error_info = {
                        'reason': str(e),
                        'error_type': type(e).__name__,
                        'implementation_preview': implementation[:500] if implementation else 'No implementation found',
                        'file_size': os.path.getsize(file_path) if os.path.exists(file_path) else 'File not found',
                        'stack_trace': traceback.format_exc()
                    }
                    self._log_parsing_failure(model_name, file_path, error_info)
                    self.not_found_models.add(model_name)
            else:
                # Keep warnings for missing models
                self.logger.warning(f"Could not find implementation for model: {model_name}")
                self.not_found_models.add(model_name)

        self.stats['models_in_inventory'] = len(models)

        # Log analysis results
        self.logger.info(f"Successfully analyzed {len(models)} models")
        if self.not_found_models:
            self.logger.warning(f"Could not find {len(self.not_found_models)} models: {', '.join(self.not_found_models)}")

        # Generate inventory
        inventory = {
            'models': models,
            'endpoints': endpoints
        }

        # Print final report
        self._print_final_report()

        return inventory

    def _print_final_report(self):
        """Print a summary report of the analysis"""
        report = f"""
📊 Analysis Summary Report
------------------------
Swift Files Found:      {self.stats['swift_files_found']}
Models Found:          {self.stats['models_found']}
Models Successfully Parsed: {self.stats['models_parsed']}
Models in Inventory:   {self.stats['models_in_inventory']}
Failed Models:         {len(self.not_found_models)}
------------------------"""
        print(report)

        # Print detailed parsing failures if any
        if self.parsing_failures:
            print("\n❌ Parsing Failures Details:")
            print("---------------------------")
            for model_name, failure in self.parsing_failures.items():
                print(f"\nModel: {model_name}")
                print(f"File: {failure['file_path']}")
                print("Error Details:")
                print(json.dumps(failure['error_info'], indent=2))
                print("---------------------------")

    def _extract_model_names(self) -> Set[str]:
        """Extract model names from API documentation"""
        model_names = set()

        # add any models found in Swift files
        self.logger.info("Extracting models from Swift files...")
        processed_files = 0
        total_files = len(self.swift_files)

        for file_path in self.swift_files:
            processed_files += 1
            # Log progress every 50 files or at the end
            if processed_files % 50 == 0 or processed_files == total_files:
                self.logger.info(f"Progress: {processed_files}/{total_files} files scanned")

            content = self.swift_files[file_path]
            # Find struct/class/protocol declarations
            matches = re.finditer(r'(?:struct|class|protocol|enum)\s+(\w+)(?:\s*:|\s*\{)', content)
            for match in matches:
                model_name = match.group(1)
                # Skip certain utility types
                if model_name in {'String', 'Int', 'Double', 'Bool', 'Date', 'Data', 'Dictionary', 'Array', 'Any', 'CodingKeys', 'AnyPublisher', 'Error', 'Data', 'Date', 'Void'}:
                    continue

                # Store the model location with its implementation
                start_idx = match.start()
                code = content[start_idx:]
                # Extract implementation by matching braces
                brace_count = 0
                end_idx = 0
                in_implementation = False

                for i, char in enumerate(code):
                    if char == '{':
                        brace_count += 1
                        in_implementation = True
                    elif char == '}':
                        brace_count -= 1
                        if brace_count == 0 and in_implementation:
                            end_idx = i + 1
                            break

                if end_idx > 0:
                    implementation = code[:end_idx]
                    self.model_locations[model_name] = {
                        'file_path': file_path,
                        'implementation': implementation
                    }
                    self.logger.debug(f"Found model in {file_path}: {model_name}")
                    model_names.add(model_name)

        self.logger.info(f"Total models found: {len(model_names)}")
        # Only log model names in debug mode
        self.logger.debug(f"Models found: {', '.join(sorted(model_names))}")
        return model_names

    def _extract_endpoints(self) -> Dict[str, List[str]]:
        """Extract REST and WebSocket endpoints from documentation"""
        rest_endpoints = []
        websocket_endpoints = []

        # Extract REST endpoints
        for category in self.api_doc.get('api_methods', {}).values():
            rest_endpoints.extend(category.keys())

        # Extract WebSocket endpoints
        websocket_endpoints.extend(self.api_doc.get('websocket_methods', {}).keys())

        self.logger.info(f"Found {len(rest_endpoints)} REST endpoints and {len(websocket_endpoints)} WebSocket endpoints")
        return {
            'rest': sorted(rest_endpoints),
            'websocket': sorted(websocket_endpoints)
        }

def main():
    if len(sys.argv) < 3:
        print("Usage: python analyzer.py <path_to_documentation> <root_folder> [--gpt] [--verbose]")
        sys.exit(1)

    doc_path = sys.argv[1]
    root_folder = sys.argv[2]
    use_gpt = '--gpt' in sys.argv
    verbose = '--verbose' in sys.argv

    mode = AnalysisMode.GPT if use_gpt else AnalysisMode.SWIFT_PARSER
    analyzer = APIDocAnalyzer(root_folder, mode=mode, verbose=verbose)

    results = analyzer.analyze_documentation(doc_path)

    # Write results to file
    output_path = 'api_inventory.json'
    with open(output_path, 'w') as f:
        json.dump(results, f, indent=2)

    print(f"Analysis complete. Results written to {output_path}")
    if analyzer.not_found_models:
        print(f"Models not found: {', '.join(analyzer.not_found_models)}")

if __name__ == '__main__':
    main()