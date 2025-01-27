import os
import json
import logging
import subprocess
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple
from dataclasses import dataclass

logger = logging.getLogger('APIDocAnalyzer')

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
    def __init__(self):
        """Initialize the Swift parser"""
        self._script_dir = Path(os.path.dirname(os.path.abspath(__file__)))
        self._swift_parser_path = self._script_dir / '.build/debug/ModelParser'

        # Build the Swift parser if it doesn't exist
        if not self._swift_parser_path.exists():
            self._build_swift_parser()

    def _build_swift_parser(self):
        """Build the Swift parser executable"""
        logger.info("🔨 Building Swift parser...")
        try:
            result = subprocess.run(
                ['swift', 'build'],
                cwd=str(self._script_dir),
                capture_output=True,
                text=True
            )
            if result.returncode != 0:
                logger.error(f"❌ Failed to build Swift parser: {result.stderr}")
                raise RuntimeError("Failed to build Swift parser")
            logger.info("✅ Swift parser built successfully")
        except Exception as e:
            logger.error(f"❌ Error building Swift parser: {str(e)}")
            raise

    def parse_properties(self, file_path: str, type_name: str) -> List[SwiftProperty]:
        """Parse properties from a Swift file using the Swift parser"""
        logger.info(f"🔍 Parsing properties for {type_name} in {file_path}")

        try:
            # Run the Swift parser
            result = subprocess.run(
                [str(self._swift_parser_path), file_path, type_name],
                capture_output=True,
                text=True
            )

            if result.returncode != 0:
                logger.error(f"❌ Swift parser failed: {result.stderr}")
                return []

            # Parse the JSON output
            try:
                type_info = json.loads(result.stdout)
                logger.debug(f"📋 Swift parser output: {type_info}")

                # Convert the Swift parser output to SwiftProperty objects
                properties = []
                for prop in type_info.get('properties', []):
                    properties.append(SwiftProperty(
                        name=prop['name'],
                        type=prop['type'],
                        is_optional=prop['isOptional'],
                        is_array=prop['isArray'],
                        is_dictionary=prop['isDictionary'],
                        key_type=prop.get('keyType'),
                        value_type=prop.get('valueType')
                    ))
                return properties

            except json.JSONDecodeError as e:
                logger.error(f"❌ Error parsing Swift parser output: {str(e)}")
                logger.debug(f"Raw output: {result.stdout}")
                return []

        except Exception as e:
            logger.error(f"❌ Error running Swift parser: {str(e)}")
            return []

    def properties_to_dict(self, properties: List[SwiftProperty]) -> Dict:
        """Convert properties to a dictionary format"""
        result = {
            'properties': [],
            'relationships': []
        }

        for prop in properties:
            # Determine the property type and any relationships
            prop_type = prop.type
            if prop.is_array:
                prop_type = f"[{prop_type}]"
            elif prop.is_dictionary:
                prop_type = f"[{prop.key_type}: {prop.value_type}]"
            if prop.is_optional:
                prop_type = f"{prop_type}?"

            # Add property info
            prop_info = {
                'name': prop.name,
                'type': prop_type,
                'description': f"The {prop.name} of the model"  # Basic description
            }
            result['properties'].append(prop_info)

            # Track relationships (custom types)
            base_type = prop.type
            if base_type not in {'String', 'Int', 'Double', 'Bool', 'Date', 'Data'}:
                result['relationships'].append({
                    'source_property': prop.name,
                    'target_type': base_type
                })

            # If it's a dictionary with a custom value type, track that relationship too
            if prop.is_dictionary and prop.value_type not in {'String', 'Int', 'Double', 'Bool', 'Date', 'Data'}:
                result['relationships'].append({
                    'source_property': f"{prop.name} values",
                    'target_type': prop.value_type
                })

        return result