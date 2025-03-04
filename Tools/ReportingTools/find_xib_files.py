#!/usr/bin/env python3

import os
import re
import glob
import xml.etree.ElementTree as ET
from collections import defaultdict

def find_xib_files(root_dir):
    """Find all XIB files in the project, excluding build and dependency folders."""
    print("Searching for XIB files...")
    
    # Directories to exclude
    exclude_dirs = ['.build', '.swiftpm', 'Pods', 'Carthage', 'DerivedData']
    exclude_patterns = [os.path.join(root_dir, d) for d in exclude_dirs]
    
    # Find all XIB files
    xib_files = []
    for root, dirs, files in os.walk(root_dir):
        # Skip excluded directories
        dirs[:] = [d for d in dirs if os.path.join(root, d) not in exclude_patterns]
        
        for file in files:
            if file.endswith('.xib'):
                xib_path = os.path.join(root, file)
                xib_files.append(xib_path)
    
    print(f"Found {len(xib_files)} XIB files.")
    return xib_files

def extract_class_from_xib(xib_path):
    """Extract the custom class name from a XIB file."""
    try:
        with open(xib_path, 'r', encoding='utf-8') as f:
            content = f.read()
            # Look for customClass attribute in the XIB file
            match = re.search(r'customClass="([^"]+)"', content)
            if match:
                return match.group(1)
    except Exception as e:
        print(f"Error reading {xib_path}: {e}")
    
    # If no custom class found, use the filename as a hint
    base_name = os.path.basename(xib_path)
    class_name = os.path.splitext(base_name)[0]
    return class_name

def analyze_xib_complexity(xib_path):
    """Analyze the complexity of a XIB file based on various metrics."""
    try:
        # Parse the XIB file as XML
        tree = ET.parse(xib_path)
        root = tree.getroot()
        
        # Count different types of UI elements
        ui_elements = {
            'views': len(root.findall(".//view")),
            'buttons': len(root.findall(".//button")),
            'labels': len(root.findall(".//label")),
            'textFields': len(root.findall(".//textField")),
            'imageViews': len(root.findall(".//imageView")),
            'tableViews': len(root.findall(".//tableView")),
            'collectionViews': len(root.findall(".//collectionView")),
            'stackViews': len(root.findall(".//stackView")),
            'scrollViews': len(root.findall(".//scrollView")),
            'constraints': len(root.findall(".//constraint"))
        }
        
        # Count total UI elements
        total_elements = sum(ui_elements.values())
        
        # Count connections (outlets, actions)
        connections = len(root.findall(".//connections/outlet")) + len(root.findall(".//connections/action"))
        
        # Calculate complexity score
        # This is a simple heuristic - you might want to adjust the weights
        complexity_score = (
            total_elements * 1.0 +
            connections * 1.5 +
            ui_elements['constraints'] * 0.5 +
            ui_elements['tableViews'] * 2.0 +
            ui_elements['collectionViews'] * 2.0
        )
        
        # Determine complexity level
        if complexity_score < 20:
            complexity_level = "Low"
        elif complexity_score < 50:
            complexity_level = "Medium"
        else:
            complexity_level = "High"
        
        return {
            'total_elements': total_elements,
            'connections': connections,
            'constraints': ui_elements['constraints'],
            'complexity_score': round(complexity_score, 1),
            'complexity_level': complexity_level,
            'ui_elements': ui_elements
        }
    except Exception as e:
        print(f"Error analyzing complexity of {xib_path}: {e}")
        return {
            'total_elements': 0,
            'connections': 0,
            'constraints': 0,
            'complexity_score': 0,
            'complexity_level': "Unknown",
            'ui_elements': {}
        }

def find_swift_files_for_classes(root_dir, class_names):
    """Find Swift files that define the classes used in XIB files."""
    print("Searching for Swift files that use these XIB files...")
    
    # Directories to exclude
    exclude_dirs = ['.build', '.swiftpm', 'Pods', 'Carthage', 'DerivedData']
    exclude_patterns = [os.path.join(root_dir, d) for d in exclude_dirs]
    
    # Find all Swift files
    swift_files = []
    for root, dirs, files in os.walk(root_dir):
        # Skip excluded directories
        dirs[:] = [d for d in dirs if os.path.join(root, d) not in exclude_patterns]
        
        for file in files:
            if file.endswith('.swift'):
                swift_path = os.path.join(root, file)
                swift_files.append(swift_path)
    
    # Map class names to Swift files
    class_to_swift = {}
    for class_name in class_names:
        for swift_path in swift_files:
            try:
                with open(swift_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    # Look for class definition
                    if re.search(rf'class\s+{class_name}\s*:', content):
                        class_to_swift[class_name] = swift_path
                        break
            except Exception as e:
                print(f"Error reading {swift_path}: {e}")
    
    print(f"Found {len(class_to_swift)} Swift files associated with XIB files.")
    return class_to_swift

def generate_report(xib_files, class_to_swift, root_dir):
    """Generate a report of XIB files and their associated Swift classes."""
    print("Generating report...")
    
    report = "# XIB Files Report\n\n"
    report += "## Summary\n\n"
    
    # Analyze complexity for all XIB files
    print("Analyzing XIB file complexity...")
    complexity_data = {}
    complexity_levels = {"Low": 0, "Medium": 0, "High": 0, "Unknown": 0}
    
    for xib_path in xib_files:
        complexity = analyze_xib_complexity(xib_path)
        complexity_data[xib_path] = complexity
        complexity_levels[complexity['complexity_level']] += 1
    
    # Add summary statistics
    report += f"- **Total XIB Files**: {len(xib_files)}\n"
    report += f"- **Associated Swift Classes Found**: {len([v for v in class_to_swift.values() if v != 'Not found'])}\n"
    report += f"- **Complexity Distribution**:\n"
    report += f"  - Low Complexity: {complexity_levels['Low']} files\n"
    report += f"  - Medium Complexity: {complexity_levels['Medium']} files\n"
    report += f"  - High Complexity: {complexity_levels['High']} files\n"
    if complexity_levels['Unknown'] > 0:
        report += f"  - Unknown Complexity: {complexity_levels['Unknown']} files\n"
    
    report += "\n## Detailed XIB Files List\n\n"
    report += "| XIB File | Swift Class | Swift File Path | Complexity | UI Elements | Constraints | Connections |\n"
    report += "|----------|-------------|----------------|------------|-------------|-------------|-------------|\n"
    
    for xib_path in sorted(xib_files):
        rel_xib_path = os.path.relpath(xib_path, root_dir)
        class_name = extract_class_from_xib(xib_path)
        swift_path = class_to_swift.get(class_name, "Not found")
        
        if swift_path != "Not found":
            rel_swift_path = os.path.relpath(swift_path, root_dir)
        else:
            rel_swift_path = "Not found"
        
        complexity = complexity_data[xib_path]
        
        report += f"| {rel_xib_path} | {class_name} | {rel_swift_path} | {complexity['complexity_level']} ({complexity['complexity_score']}) | {complexity['total_elements']} | {complexity['constraints']} | {complexity['connections']} |\n"
    
    # Add detailed breakdown of high complexity XIBs
    high_complexity_xibs = [xib for xib in xib_files if complexity_data[xib]['complexity_level'] == 'High']
    if high_complexity_xibs:
        report += "\n## High Complexity XIB Files\n\n"
        for xib_path in sorted(high_complexity_xibs):
            rel_xib_path = os.path.relpath(xib_path, root_dir)
            complexity = complexity_data[xib_path]
            ui_elements = complexity['ui_elements']
            
            report += f"### {rel_xib_path}\n\n"
            report += f"- **Complexity Score**: {complexity['complexity_score']}\n"
            report += f"- **Total UI Elements**: {complexity['total_elements']}\n"
            report += f"- **Constraints**: {complexity['constraints']}\n"
            report += f"- **Connections**: {complexity['connections']}\n"
            report += f"- **UI Elements Breakdown**:\n"
            for element_type, count in sorted(ui_elements.items()):
                if count > 0:
                    report += f"  - {element_type}: {count}\n"
            report += "\n"
    
    return report

def main():
    # Use current directory as root
    root_dir = os.getcwd()
    print(f"Scanning project at: {root_dir}")
    
    # Find all XIB files
    xib_files = find_xib_files(root_dir)
    
    # Extract class names from XIB files
    class_names = set()
    for xib_path in xib_files:
        class_name = extract_class_from_xib(xib_path)
        class_names.add(class_name)
    
    print(f"Found {len(class_names)} unique class names in XIB files.")
    
    # Find Swift files for these classes
    class_to_swift = find_swift_files_for_classes(root_dir, class_names)
    
    # Generate report
    report = generate_report(xib_files, class_to_swift, root_dir)
    
    # Save report
    with open('xib_files_report.md', 'w') as f:
        f.write(report)
    
    print("Report saved to 'xib_files_report.md'")

if __name__ == "__main__":
    main() 