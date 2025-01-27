import subprocess
import json
import logging
from typing import Dict, List, Optional, Set, Tuple
import re
from dataclasses import dataclass
import os
from pathlib import Path

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%H:%M:%S'
)
logger = logging.getLogger('SwiftParser')

@dataclass
class SwiftProperty:
    name: str
    type: str
    is_optional: bool
    is_array: bool
    is_dictionary: bool
    key_type: Optional[str] = None
    value_type: Optional[str] = None

class SwiftParser:
    """Parser for Swift model definitions"""

    SWIFT_PRIMITIVE_TYPES = {
        'String', 'Int', 'Double', 'Float', 'Bool', 'Date', 'Data',
        'Int32', 'Int64', 'UInt', 'UInt32', 'UInt64'
    }

    def __init__(self):
        self._custom_types: Set[str] = set()
        self._script_dir = Path(__file__).parent
        self._swift_parser_path = self._script_dir / '.build/debug/ModelParser'

        # Build Swift parser if not already built
        if not self._swift_parser_path.exists():
            self._build_swift_parser()

    def _build_swift_parser(self):
        """Build the Swift parser executable"""
        try:
            logger.info("Building Swift parser...")
            subprocess.run(
                ['swift', 'build'],
                cwd=str(self._script_dir),
                check=True,
                capture_output=True,
                text=True
            )
            logger.info("Swift parser built successfully")
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to build Swift parser: {e.stderr}")
            raise

    def _is_custom_type(self, type_name: str) -> bool:
        """Check if a type is custom (not primitive)"""
        primitive_types = {
            'String', 'Int', 'Double', 'Float', 'Bool', 'Date', 'Data',
            'Dictionary', 'Array', 'Set', 'URL', 'UUID', 'Character'
        }
        return type_name not in primitive_types

    def _parse_type(self, type_str: str) -> Tuple[str, bool, bool, bool]:
        """Parse a Swift type string into its components"""
        is_optional = type_str.endswith('?')
        is_array = type_str.startswith('[') and type_str.endswith(']') and ':' not in type_str
        is_dictionary = type_str.startswith('[') and ':' in type_str

        # Clean up type string
        if is_optional:
            type_str = type_str[:-1]
        if is_array:
            type_str = type_str[1:-1]
        if is_dictionary:
            type_str = 'Dictionary'

        return type_str, is_optional, is_array, is_dictionary

    def parse_properties(self, swift_file_path: str, type_name: str) -> List[SwiftProperty]:
        """Parse properties from a Swift file using the Swift parser script"""
        try:
            # Run Swift parser executable
            result = subprocess.run(
                [str(self._swift_parser_path), swift_file_path, type_name],
                capture_output=True,
                text=True,
                check=True
            )

            # Parse JSON output
            type_info = json.loads(result.stdout)
            properties = []

            for prop in type_info['properties']:
                swift_prop = SwiftProperty(
                    name=prop['name'],
                    type=prop['type'],
                    is_optional=prop['isOptional'],
                    is_array=prop['isArray'],
                    is_dictionary=prop['isDictionary'],
                    key_type=prop.get('keyType'),
                    value_type=prop.get('valueType')
                )

                # Track custom types
                if self._is_custom_type(swift_prop.type):
                    self._custom_types.add(swift_prop.type)
                if swift_prop.key_type and self._is_custom_type(swift_prop.key_type):
                    self._custom_types.add(swift_prop.key_type)
                if swift_prop.value_type and self._is_custom_type(swift_prop.value_type):
                    self._custom_types.add(swift_prop.value_type)

                properties.append(swift_prop)

            return properties

        except subprocess.CalledProcessError as e:
            logger.error(f"Error running Swift parser: {e.stderr}")
            return []
        except json.JSONDecodeError as e:
            logger.error(f"Error parsing Swift parser output: {e}")
            return []
        except Exception as e:
            logger.error(f"Unexpected error: {e}")
            return []

    def properties_to_dict(self, properties: List[SwiftProperty]) -> Dict:
        """Convert parsed properties into a dictionary format"""
        result = {
            'properties': {},
            'relationships': []
        }

        for prop in properties:
            prop_type = prop.type
            description = []

            if prop.is_optional:
                description.append("Optional")
            if prop.is_array:
                description.append("Array of")
            if prop.is_dictionary:
                description.append("Dictionary")

            if prop.is_dictionary and prop.key_type and prop.value_type:
                prop_type = f"[{prop.key_type}: {prop.value_type}]"
                description.append(f"with {prop.key_type} keys and {prop.value_type} values")

            # Add property to properties dictionary
            result['properties'][prop.name] = {
                'type': prop_type + ('?' if prop.is_optional else ''),
                'description': f"{' '.join(description)} {prop_type} property".strip()
            }

            # Add relationships if property type is custom
            base_type = prop.value_type if prop.is_dictionary else prop.type
            if self._is_custom_type(base_type):
                result['relationships'].append({
                    'via': prop.name,
                    'target': base_type,
                })

        return result