#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Swift Project Comparer
----------------------
A tool that compares Swift types (classes, structs, enums, typealiases) between two project folders
and reports what exists in the legacy project but is missing in the base project.
"""

import os
import re
import sys
import yaml
import glob
import argparse
from pathlib import Path
from typing import List, Dict, Set, Tuple
from dataclasses import dataclass
from enum import Enum, auto

class SwiftTypeKind(Enum):
    CLASS = auto()
    STRUCT = auto()
    ENUM = auto()
    TYPEALIAS = auto()
    PROTOCOL = auto()
    EXTENSION = auto()
    
    @classmethod
    def from_string(cls, type_str):
        mapping = {
            "class": cls.CLASS,
            "struct": cls.STRUCT,
            "enum": cls.ENUM,
            "typealias": cls.TYPEALIAS,
            "protocol": cls.PROTOCOL,
            "extension": cls.EXTENSION
        }
        return mapping.get(type_str.lower())
    
    def __str__(self):
        return self.name.lower()

@dataclass
class SwiftType:
    name: str
    kind: SwiftTypeKind
    file_path: str
    line_number: int
    
    def __hash__(self):
        return hash((self.name, self.kind))
    
    def __eq__(self, other):
        if not isinstance(other, SwiftType):
            return False
        return self.name == other.name and self.kind == other.kind

def load_config(config_path: str) -> Dict:
    """Load the YAML configuration file"""
    with open(config_path, 'r') as file:
        return yaml.safe_load(file)

def find_swift_files(directory: str, excluded_dirs: List[str] = None) -> List[str]:
    """Find all Swift files in a directory and its subdirectories"""
    if excluded_dirs is None:
        excluded_dirs = []
        
    swift_files = []
    
    for root, dirs, files in os.walk(directory):
        # Skip excluded directories
        dirs[:] = [d for d in dirs if d not in excluded_dirs]
        
        for file in files:
            if file.endswith('.swift'):
                swift_files.append(os.path.join(root, file))
                
    return swift_files

def should_ignore_type(swift_type: SwiftType, ignored_types: Dict) -> bool:
    """
    Check if a Swift type should be ignored based on configuration
    """
    # If there are no ignore rules, don't ignore anything
    if not ignored_types:
        return False
        
    type_name = swift_type.name
    type_kind = str(swift_type.kind)
    
    # Check exact name matches (for any type)
    if type_name in ignored_types.get('names', []):
        return True
        
    # Check type-specific ignore lists
    type_specific_list = ignored_types.get(type_kind + 's', [])
    if type_name in type_specific_list:
        return True
        
    # Check pattern matches
    for pattern in ignored_types.get('patterns', []):
        if re.match(pattern, type_name):
            return True
            
    return False

def extract_swift_types(file_path: str) -> List[SwiftType]:
    """Extract all Swift types from a file"""
    swift_types = []
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading file {file_path}: {e}")
        return []
    
    # Regular expressions for different Swift types
    # Handles public/internal/private/fileprivate modifiers
    class_pattern = re.compile(r'(?:^|\n)\s*(?:public\s+|internal\s+|private\s+|fileprivate\s+)*(?:final\s+)?class\s+([A-Za-z0-9_]+)', re.MULTILINE)
    struct_pattern = re.compile(r'(?:^|\n)\s*(?:public\s+|internal\s+|private\s+|fileprivate\s+)*struct\s+([A-Za-z0-9_]+)', re.MULTILINE)
    enum_pattern = re.compile(r'(?:^|\n)\s*(?:public\s+|internal\s+|private\s+|fileprivate\s+)*enum\s+([A-Za-z0-9_]+)', re.MULTILINE)
    typealias_pattern = re.compile(r'(?:^|\n)\s*(?:public\s+|internal\s+|private\s+|fileprivate\s+)*typealias\s+([A-Za-z0-9_]+)', re.MULTILINE)
    protocol_pattern = re.compile(r'(?:^|\n)\s*(?:public\s+|internal\s+|private\s+|fileprivate\s+)*protocol\s+([A-Za-z0-9_]+)', re.MULTILINE)
    extension_pattern = re.compile(r'(?:^|\n)\s*(?:public\s+|internal\s+|private\s+|fileprivate\s+)*extension\s+([A-Za-z0-9_]+)', re.MULTILINE)
    
    # Find all matches for each type
    for pattern, type_kind in [
        (class_pattern, SwiftTypeKind.CLASS),
        (struct_pattern, SwiftTypeKind.STRUCT),
        (enum_pattern, SwiftTypeKind.ENUM),
        (typealias_pattern, SwiftTypeKind.TYPEALIAS),
        (protocol_pattern, SwiftTypeKind.PROTOCOL),
        (extension_pattern, SwiftTypeKind.EXTENSION)
    ]:
        for match in pattern.finditer(content):
            type_name = match.group(1)
            # Get line number by counting newlines before the match
            line_number = content[:match.start()].count('\n') + 1
            swift_types.append(SwiftType(
                name=type_name,
                kind=type_kind,
                file_path=file_path,
                line_number=line_number
            ))
    
    return swift_types

def analyze_project(directory: str, excluded_dirs: List[str] = None, ignored_types: Dict = None) -> Dict[SwiftTypeKind, Set[SwiftType]]:
    """Analyze a project and extract all Swift types"""
    if excluded_dirs is None:
        excluded_dirs = []
        
    if ignored_types is None:
        ignored_types = {}
        
    result = {
        SwiftTypeKind.CLASS: set(),
        SwiftTypeKind.STRUCT: set(),
        SwiftTypeKind.ENUM: set(),
        SwiftTypeKind.TYPEALIAS: set(),
        SwiftTypeKind.PROTOCOL: set(),
        SwiftTypeKind.EXTENSION: set()
    }
    
    swift_files = find_swift_files(directory, excluded_dirs)
    print(f"Found {len(swift_files)} Swift files in {directory}")
    
    ignored_count = 0
    for file_path in swift_files:
        types = extract_swift_types(file_path)
        for swift_type in types:
            # Skip ignored types
            if should_ignore_type(swift_type, ignored_types):
                ignored_count += 1
                continue
                
            result[swift_type.kind].add(swift_type)
    
    if ignored_count > 0:
        print(f"Ignored {ignored_count} types based on configuration")
    
    return result

def compare_projects(base_types: Dict[SwiftTypeKind, Set[SwiftType]], 
                    legacy_types: Dict[SwiftTypeKind, Set[SwiftType]]) -> Dict[SwiftTypeKind, List[SwiftType]]:
    """Compare two projects and find types that exist in legacy but not in base"""
    missing_types = {
        SwiftTypeKind.CLASS: [],
        SwiftTypeKind.STRUCT: [],
        SwiftTypeKind.ENUM: [],
        SwiftTypeKind.TYPEALIAS: [],
        SwiftTypeKind.PROTOCOL: [],
        SwiftTypeKind.EXTENSION: []
    }
    
    for type_kind in SwiftTypeKind:
        # For each type in legacy, check if it exists in base
        for legacy_type in legacy_types[type_kind]:
            if legacy_type not in base_types[type_kind]:
                missing_types[type_kind].append(legacy_type)
    
    return missing_types

def generate_report(missing_types: Dict[SwiftTypeKind, List[SwiftType]], output_path: str = None):
    """Generate a report of missing types, organized by folder structure"""
    total_missing = sum(len(types) for types in missing_types.values())
    
    report_lines = [
        "# Swift Project Comparison Report",
        f"\n## Summary",
        f"\nTotal missing types: {total_missing}",
    ]
    
    # First generate the standard type-based report
    report_lines.append("\n## Missing Types by Type")
    for type_kind in SwiftTypeKind:
        missing = missing_types[type_kind]
        if missing:
            report_lines.append(f"\n### {type_kind}s: {len(missing)}")
            # Sort by name for consistency
            missing.sort(key=lambda x: x.name)
            for swift_type in missing:
                report_lines.append(f"- **{swift_type.name}** (Line: {swift_type.line_number})")
    
    # Then generate the folder-based report
    report_lines.append("\n## Missing Types by Folder Structure")
    
    # Combine all missing types into a single list
    all_missing = []
    for type_list in missing_types.values():
        all_missing.extend(type_list)
    
    # Create a nested dictionary structure to represent the folder hierarchy
    folder_structure = {}
    for swift_type in all_missing:
        # Get relative path to make it more readable
        path_parts = os.path.normpath(swift_type.file_path).split(os.sep)
        
        # Navigate the folder structure
        current_level = folder_structure
        for part in path_parts[:-1]:  # Exclude the filename
            if part not in current_level:
                current_level[part] = {'files': {}}
            current_level = current_level[part]
        
        # Get the filename
        filename = path_parts[-1]
        if filename not in current_level['files']:
            current_level['files'][filename] = []
        
        # Add the type to the file
        current_level['files'][filename].append(swift_type)
    
    # Recursive function to print the folder structure
    def print_folder_structure(structure, indent=0, path=""):
        # Sort folders and files alphabetically
        items = sorted([k for k in structure.keys() if k != 'files'])
        
        for item in items:
            # Calculate full path for this item
            item_path = os.path.join(path, item) if path else item
            
            # Print folder name with indent using underscores
            report_lines.append(f"{'_' * (indent * 2)}📂 **{item}**")
            
            # Recursively print subfolders
            print_folder_structure(structure[item], indent + 1, item_path)
        
        # Print files in this folder
        if 'files' in structure:
            files = sorted(structure['files'].keys())
            for file in files:
                report_lines.append(f"{'_' * (indent * 2)}📄 **{file}**")
                
                # Sort types by line number
                types = sorted(structure['files'][file], key=lambda x: x.line_number)
                for swift_type in types:
                    report_lines.append(f"{'_' * ((indent + 1) * 2)}• {swift_type.kind} **{swift_type.name}** (Line: {swift_type.line_number})")
    
    # Print the folder structure starting from root
    print_folder_structure(folder_structure)
    
    report = "\n".join(report_lines)
    
    if output_path:
        try:
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(report)
            print(f"Report saved to {output_path}")
        except Exception as e:
            print(f"Error writing report to {output_path}: {e}")
            print(report)  # Print to console as fallback
    else:
        print(report)
    
    return total_missing

def main():
    parser = argparse.ArgumentParser(
        description='Compare Swift types between base and legacy projects'
    )
    parser.add_argument(
        'config_path',
        help='Path to the YAML configuration file'
    )
    args = parser.parse_args()
    
    config = load_config(args.config_path)
    
    base_dir = config['base_directory']
    legacy_dir = config['legacy_directory']
    excluded_dirs = config.get('excluded_directories', [])
    ignored_types = config.get('ignored_types', {})
    output_path = config.get('output_report')
    
    print(f"Analyzing base project: {base_dir}")
    base_types = analyze_project(base_dir, excluded_dirs, ignored_types)
    
    print(f"Analyzing legacy project: {legacy_dir}")
    legacy_types = analyze_project(legacy_dir, excluded_dirs, ignored_types)
    
    print("\nComparing projects...")
    missing_types = compare_projects(base_types, legacy_types)
    
    print("\nGenerating report...")
    total_missing = generate_report(missing_types, output_path)
    
    # Return non-zero exit code if there are missing types
    if total_missing > 0:
        sys.exit(1)
    
if __name__ == "__main__":
    main() 