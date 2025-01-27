from typing import Dict, List, Optional, Any, Set, Tuple
import json
import os
import sys
from pathlib import Path
from openai import OpenAI
from dotenv import load_dotenv
import logging
import re
from enum import Enum, auto
from finder import SwiftFileFinder
from parser import SwiftParser

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%H:%M:%S'
)
logger = logging.getLogger('APIDocAnalyzer')

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
        Initialize the analyzer with OpenAI API key.

        Args:
            root_folder: Root folder path where to search for Swift files
            mode: Analysis mode (SWIFT_PARSER or GPT)
            verbose: Whether to show detailed logging
        """
        # Set logging level based on verbose flag
        logger.setLevel(logging.DEBUG if verbose else logging.WARNING)

        logger.info("🚀 Initializing API Documentation Analyzer")
        self.mode = mode
        logger.info(f"📋 Using analysis mode: {mode.name}")

        # Track not found models
        self.not_found_models: Set[str] = set()

        # Initialize components
        self.root_folder = root_folder
        self.swift_finder = SwiftFileFinder(root_folder)
        self.swift_parser = SwiftParser()

        # Load all Swift files at initialization
        self.swift_files = self.swift_finder.load_swift_files()
        logger.info("✅ Initialization complete")

    def _find_swift_model(self, model_name: str) -> Tuple[Optional[str], Optional[str]]:
        """Find Swift implementation of a model"""
        return self.swift_finder.find_model_implementation(model_name)

    def analyze_model(self, model_name: str) -> Optional[Dict]:
        """
        Analyze a specific model from the API documentation.
        Returns model info including properties and relationships.
        """
        impl, file_path = self._find_swift_model(model_name)
        if not impl:
            self.not_found_models.add(model_name)
            return None

        logger.info(f"🔍 Analyzing model: {model_name}")

        if self.mode == AnalysisMode.SWIFT_PARSER:
            try:
                # Use Swift parser
                properties = self.swift_parser.parse_properties(file_path, model_name)
                if not properties:
                    logger.warning(f"⚠️ No properties found for model {model_name} in {file_path}")
                    logger.debug(f"Model implementation:\n{impl}")
                    return None

                result = self.swift_parser.properties_to_dict(properties)
                if not result.get('properties'):
                    logger.warning(f"⚠️ Properties dictionary empty for model {model_name}")
                    return None

                result['name'] = model_name
                result['path'] = file_path
                return result

            except Exception as e:
                logger.error(f"❌ Error analyzing model {model_name}: {str(e)}")
                return None
        else:
            # Use GPT for analysis
            prompt = f"""Analyze this Swift model implementation and extract:
            1. All properties with their types
            2. Any relationships with other models
            3. Basic description of each property

            Code:
            {impl}
            """
            
            try:
                response = self.openai_client.chat.completions.create(
                    model="gpt-4",
                    messages=[{"role": "user", "content": prompt}],
                    temperature=0
                )
                
                analysis = json.loads(response.choices[0].message.content)
                if not analysis.get('properties'):
                    logger.warning(f"⚠️ No properties found in GPT analysis for model {model_name}")
                    return None

                analysis['name'] = model_name
                analysis['path'] = file_path
                return analysis

            except Exception as e:
                logger.error(f"❌ Error in GPT analysis for model {model_name}: {str(e)}")
                return None

    def analyze_documentation(self, doc_path: str) -> Dict:
        """
        Analyze the API documentation and generate an inventory of models and endpoints.
        """
        logger.info(f"📚 Starting analysis of API documentation: {doc_path}")
        
        with open(doc_path, 'r') as f:
            self.api_doc = json.load(f)
        
        # Extract model names and endpoints
        model_names = self._extract_model_names()
        endpoints = self._extract_endpoints()
        
        logger.info(f"📋 Found {len(model_names)} models to analyze")
        logger.info(f"🌐 Found {len(endpoints)} endpoints")
        
        # Analyze each model
        models = []
        model_info = {}
        relationships = set()
        
        for model_name in model_names:
            if model_name in model_info:
                continue
                
            result = self.analyze_model(model_name)
            if not result:
                logger.warning(f"⚠️ Failed to analyze model: {model_name}")
                continue
                
            models.append(result)
            model_info[model_name] = result
            
            # Track relationships
            if 'relationships' in result:
                for rel in result['relationships']:
                    # Extract the target model name from the relationship dictionary
                    target_model = rel.get('target_type') if isinstance(rel, dict) else rel
                    if target_model:
                        relationships.add((model_name, target_model))
                        # Analyze related model if not already done
                        if target_model not in model_info and target_model not in self.not_found_models:
                            rel_result = self.analyze_model(target_model)
                            if rel_result:
                                models.append(rel_result)
                                model_info[target_model] = rel_result
        
        # Log analysis results
        logger.info(f"✅ Successfully analyzed {len(models)} models")
        if self.not_found_models:
            logger.warning(f"⚠️ Could not find {len(self.not_found_models)} models: {', '.join(self.not_found_models)}")
        
        # Generate inventory
        inventory = {
            'models': models,
            'relationships': [{'source': src, 'target': tgt} for src, tgt in relationships],
            'endpoints': endpoints
        }
        
        return inventory

    def _extract_model_names(self) -> Set[str]:
        """Extract model names from API documentation"""
        model_names = set()

        # Extract from REST endpoints
        for category in self.api_doc.get('api_methods', {}).values():
            for endpoint_data in category.values():
                if 'signature' in endpoint_data:
                    model_name = self._extract_model_from_signature(endpoint_data['signature'])
                    if model_name:
                        model_names.add(model_name)

        # Extract from WebSocket endpoints
        for endpoint_data in self.api_doc.get('websocket_methods', {}).values():
            if 'signature' in endpoint_data:
                model_name = self._extract_model_from_signature(endpoint_data['signature'])
                if model_name:
                    model_names.add(model_name)

        # Also add any models found in Swift files
        for file_path in self.swift_files:
            if 'Models' in file_path:
                content = self.swift_files[file_path]
                # Find struct/class declarations
                matches = re.finditer(r'(?:struct|class|protocol)\s+(\w+)', content)
                for match in matches:
                    model_names.add(match.group(1))

        logger.info(f"Extracted {len(model_names)} model names")
        return model_names

    def _extract_model_from_signature(self, signature: str) -> Optional[str]:
        """Extract model name from a function signature"""
        if not signature:
            return None

        # Extract return type from signature
        return_match = re.search(r'->\s*(.+)$', signature)
        if not return_match:
            return None

        return_type = return_match.group(1).strip()

        # Handle AnyPublisher<T, Error>
        publisher_match = re.search(r'AnyPublisher\s*<\s*([^,]+)\s*,\s*[^>]+>', return_type)
        if publisher_match:
            inner_type = publisher_match.group(1).strip()
            # Handle arrays and other nested types
            array_match = re.match(r'\[(.*?)\]', inner_type)
            if array_match:
                return array_match.group(1).strip()
            return inner_type

        # Handle direct array types
        array_match = re.match(r'\[(.*?)\]', return_type)
        if array_match:
            return array_match.group(1).strip()

        return return_type

    def _extract_endpoints(self) -> Dict[str, List[str]]:
        """Extract REST and WebSocket endpoints from documentation"""
        rest_endpoints = []
        websocket_endpoints = []

        # Extract REST endpoints
        for category in self.api_doc.get('api_methods', {}).values():
            rest_endpoints.extend(category.keys())

        # Extract WebSocket endpoints
        websocket_endpoints.extend(self.api_doc.get('websocket_methods', {}).keys())

        logger.info(f"Found {len(rest_endpoints)} REST endpoints and {len(websocket_endpoints)} WebSocket endpoints")
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

    print(f"✅ Analysis complete. Results written to {output_path}")
    if analyzer.not_found_models:
        print(f"⚠️ Models not found: {', '.join(analyzer.not_found_models)}")

if __name__ == '__main__':
    main()