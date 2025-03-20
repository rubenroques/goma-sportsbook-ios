#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
SwiftCellCloner - A tool for cloning Swift UICollectionViewCell files with their extensions
"""

import os
import sys
import yaml
import re
import argparse
import glob
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


def clone_extension_file(source_content, base_class_name, new_class_name, extension_type):
    """Clone Swift extension file with new class name"""
    # Replace extension name in the content
    pattern = rf'extension\s+{base_class_name}'
    replacement = f'extension {new_class_name}'
    
    # Replace the extension name
    modified_content = re.sub(pattern, replacement, source_content)
    
    # Update the file header comment
    header_pattern = rf'//\s*{base_class_name}\+{extension_type}\.swift'
    header_replacement = f'//  {new_class_name}+{extension_type}.swift'
    modified_content = re.sub(header_pattern, header_replacement, modified_content)
    
    return modified_content


def find_extension_files(source_dir, base_class_name):
    """Find all extension files for the base class in the Extensions directory"""
    extension_dir = os.path.join(source_dir, "Extensions")
    if not os.path.exists(extension_dir):
        print(f"⚠️ Extensions directory not found at {extension_dir}")
        return []
    
    extension_pattern = os.path.join(extension_dir, f"{base_class_name}+*.swift")
    return glob.glob(extension_pattern)


def extract_extension_type(file_path, base_class_name):
    """Extract the extension type from the file path"""
    filename = os.path.basename(file_path)
    match = re.match(rf'{base_class_name}\+(.*?)\.swift', filename)
    if match:
        return match.group(1)
    return None


def process_case(config, case_name):
    """Process a single case"""
    source_dir = os.path.dirname(config['source']['swift_file'])
    source_swift_path = config['source']['swift_file']
    base_class_name = config['source']['base_class_name']
    base_directory = config['output']['base_directory']
    
    # Create the new class name
    new_class_name = f"{case_name}{base_class_name}"
    
    # Create the target directory
    target_directory = os.path.join(base_directory, case_name)
    if not create_directory(target_directory):
        return False
    
    # Create Extensions directory inside the target directory
    extensions_directory = os.path.join(target_directory, "Extensions")
    if not create_directory(extensions_directory):
        return False
    
    # Read and clone the main Swift file
    swift_content = read_file(source_swift_path)
    new_swift_content = clone_swift_file(swift_content, base_class_name, new_class_name)
    
    # Write the main Swift file
    target_swift_path = os.path.join(target_directory, f"{new_class_name}.swift")
    swift_success = write_file(target_swift_path, new_swift_content)
    
    if not swift_success:
        print(f"❌ Failed to create {new_class_name}.swift")
        return False
    
    # Find and process all extension files
    extension_files = find_extension_files(source_dir, base_class_name)
    extension_success = True
    
    for ext_file in extension_files:
        ext_type = extract_extension_type(ext_file, base_class_name)
        if not ext_type:
            print(f"⚠️ Could not determine extension type for {ext_file}")
            continue
        
        ext_content = read_file(ext_file)
        new_ext_content = clone_extension_file(ext_content, base_class_name, new_class_name, ext_type)
        
        target_ext_path = os.path.join(extensions_directory, f"{new_class_name}+{ext_type}.swift")
        if not write_file(target_ext_path, new_ext_content):
            print(f"❌ Failed to create {new_class_name}+{ext_type}.swift")
            extension_success = False
    
    if swift_success and extension_success:
        print(f"✅ Successfully created {new_class_name} in {target_directory}")
        return True
    else:
        print(f"⚠️ Partially created {new_class_name} with some issues")
        return False


def main():
    """Main function"""
    parser = argparse.ArgumentParser(description='Clone Swift UICollectionViewCell files with their extensions')
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