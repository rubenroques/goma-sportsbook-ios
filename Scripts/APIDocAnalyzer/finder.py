import os
import glob
import re
from typing import Dict, Optional
from logger_config import setup_logger

class SwiftFileFinder:
    """Handles finding and loading Swift files from a directory structure"""

    def __init__(self, root_folder: str):
        self.root_folder = root_folder
        self.swift_files: Dict[str, str] = {}  # Cache for Swift file contents
        self.logger = setup_logger('APIDocAnalyzer.finder')

    def load_swift_files(self) -> Dict[str, str]:
        """
        Load all Swift files from the root folder and its subfolders into memory.
        Returns: Dictionary mapping file paths to their contents
        """
        self.logger.info(f"Loading Swift files from {self.root_folder}")
        try:
            # Use glob to recursively find all .swift files
            pattern = os.path.join(self.root_folder, '**/*.swift')
            swift_files = glob.glob(pattern, recursive=True)
            self.logger.info(f"Found {len(swift_files)} Swift files")

            for file_path in swift_files:
                try:
                    with open(file_path, 'r') as f:
                        content = f.read()
                        self.swift_files[file_path] = content
                        self.logger.debug(f"Loaded {file_path}")
                except Exception as e:
                    self.logger.warning(f"Failed to load {file_path}: {str(e)}")

            self.logger.info(f"Successfully loaded {len(self.swift_files)} Swift files")
            return self.swift_files
        except Exception as e:
            self.logger.error(f"Error loading Swift files: {str(e)}")
            return {}

    def find_model_implementation(self, model_name: str, swift_models_cache: Optional[Dict] = None) -> tuple[Optional[str], Optional[str]]:
        """
        Search for Swift implementation of a model in the loaded Swift files.
        Args:
            model_name: Name of the model to search for
            swift_models_cache: Optional cache of previously found models
        Returns:
            Tuple of (Swift code implementation if found, file path where found), (None, None) if not found
        """
        # First check cache if provided
        if swift_models_cache and model_name in swift_models_cache:
            self.logger.debug(f"Found {model_name} in Swift models cache")
            return swift_models_cache[model_name]

        self.logger.debug(f"Searching for Swift implementation of {model_name}")
        search_terms = [
            f"struct {model_name}",
            f"class {model_name}",
            f"protocol {model_name}",
            f"enum {model_name}"
        ]

        for file_path, content in self.swift_files.items():
            for term in search_terms:
                if term in content:
                    self.logger.debug(f"Found {term} in {file_path}")
                    # Find the model definition
                    start_idx = content.find(term)
                    if start_idx != -1:
                        # Extract the full implementation
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
                            return implementation, file_path

        return None, None