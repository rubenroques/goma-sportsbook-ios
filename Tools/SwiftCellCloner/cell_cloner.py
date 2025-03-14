#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
SwiftCellCloner - A tool for cloning Swift UICollectionViewCell files with their XIB files
"""

import os
import sys
import yaml
import re
import argparse
from pathlib import Path


def load_config(config_path):
    """Load the YAML configuration file"""
    try:
        with open(config_path, 'r') as file:
            return yaml.safe_load(file)
    except Exception as e:
        print(f"Error loading config file: {e}")
        sys.exit(1)


def create_directory(directory_path):
    """Create directory if it doesn't exist"""
    try:
        os.makedirs(directory_path, exist_ok=True)
        return True
    except Exception as e:
        print(f"Error creating directory {directory_path}: {e}")
        return False


def read_file(file_path):
    """Read file content"""
    try:
        with open(file_path, 'r') as file:
            return file.read()
    except Exception as e:
        print(f"Error reading file {file_path}: {e}")
        sys.exit(1)


def write_file(file_path, content):
    """Write content to file"""
    try:
        with open(file_path, 'w') as file:
            file.write(content)
        return True
    except Exception as e:
        print(f"Error writing to file {file_path}: {e}")
        return False


def clone_swift_file(source_content, base_class_name, new_class_name):
    """Clone Swift file with new class name"""
    # Replace class name in the content
    pattern = rf'class\s+{base_class_name}\s*:'
    replacement = f'class {new_class_name} :'
    
    # Replace the class name
    modified_content = re.sub(pattern, replacement, source_content)
    
    # Update the file header comment
    header_pattern = rf'//\s*{base_class_name}\.swift'
    header_replacement = f'//  {new_class_name}.swift'
    modified_content = re.sub(header_pattern, header_replacement, modified_content)
    
    return modified_content


def clone_xib_file(source_content, base_class_name, new_class_name):
    """Clone XIB file with new class references"""
    # Replace class name in the XIB content
    # This pattern looks for the customClass attribute with the base class name
    pattern = rf'customClass="{base_class_name}"'
    replacement = f'customClass="{new_class_name}"'
    
    return source_content.replace(pattern, replacement)


def process_case(config, case_name):
    """Process a single case"""
    source_swift_path = config['source']['swift_file']
    source_xib_path = config['source']['xib_file']
    base_class_name = config['source']['base_class_name']
    base_directory = config['output']['base_directory']
    
    # Create the new class name
    new_class_name = f"{case_name}{base_class_name}"
    
    # Create the target directory
    target_directory = os.path.join(base_directory, case_name)
    if not create_directory(target_directory):
        return False
    
    # Read source files
    swift_content = read_file(source_swift_path)
    xib_content = read_file(source_xib_path)
    
    # Clone files
    new_swift_content = clone_swift_file(swift_content, base_class_name, new_class_name)
    new_xib_content = clone_xib_file(xib_content, base_class_name, new_class_name)
    
    # Write new files
    target_swift_path = os.path.join(target_directory, f"{new_class_name}.swift")
    target_xib_path = os.path.join(target_directory, f"{new_class_name}.xib")
    
    swift_success = write_file(target_swift_path, new_swift_content)
    xib_success = write_file(target_xib_path, new_xib_content)
    
    if swift_success and xib_success:
        print(f"✅ Successfully created {new_class_name} in {target_directory}")
        return True
    else:
        print(f"❌ Failed to create {new_class_name}")
        return False


def main():
    """Main function"""
    parser = argparse.ArgumentParser(description='Clone Swift UICollectionViewCell files with their XIB files')
    parser.add_argument('--config', '-c', default='config.yaml', help='Path to the YAML configuration file')
    args = parser.parse_args()
    
    # Load configuration
    config = load_config(args.config)
    
    print(f"🚀 Starting SwiftCellCloner with config: {args.config}")
    
    # Process each case
    success_count = 0
    for case in config['target_cases']:
        if process_case(config, case):
            success_count += 1
    
    total_cases = len(config['target_cases'])
    print(f"\n📊 Summary: Successfully processed {success_count}/{total_cases} cases")
    
    if success_count == total_cases:
        print("✨ All cases were processed successfully!")
        return 0
    else:
        print("⚠️ Some cases failed to process. Check the logs above for details.")
        return 1


if __name__ == "__main__":
    sys.exit(main()) 