#!/usr/bin/env python3

import re
import json
import sys
import argparse
from pathlib import Path
from typing import Dict, List, Set, Tuple

class XcodeProjectAnalyzer:
    def __init__(self, project_path: str):
        self.project_path = project_path
        self.targets: Dict[str, Dict] = {}
        self.dependencies: Dict[str, Set[str]] = {}
        self.package_dependencies: Dict[str, Set[str]] = {}

    def read_project_file(self) -> str:
        try:
            with open(self.project_path, 'r', encoding='utf-8') as f:
                return f.read()
        except FileNotFoundError:
            print(f"Error: Could not find project file at {self.project_path}")
            sys.exit(1)
        except Exception as e:
            print(f"Error reading project file: {e}")
            sys.exit(1)

    def extract_targets(self, content: str) -> None:
        # Find all target sections
        target_pattern = r'\/\* Begin PBXNativeTarget section \*\/\n(.*?)\/\* End PBXNativeTarget section \*\/'
        target_sections = re.findall(target_pattern, content, re.DOTALL)

        if target_sections:
            # Extract individual targets
            target_entry_pattern = r'([A-F0-9]{24})\s+\/\*\s+(.*?)\s+\*\/\s+=\s+{[^}]*?name\s+=\s+(.*?);'
            for section in target_sections:
                matches = re.finditer(target_entry_pattern, section)
                for match in matches:
                    target_id = match.group(1)
                    target_name = match.group(3).strip().strip('"')
                    self.targets[target_id] = {
                        'name': target_name,
                        'dependencies': set()
                    }

    def extract_dependencies(self, content: str) -> None:
        # Find target dependencies
        dependency_pattern = r'([A-F0-9]{24})\s+\/\*\s+(.*?)\s+\*\/\s+=\s+{[^}]*?target\s+=\s+([A-F0-9]{24})'
        dependencies = re.finditer(dependency_pattern, content)

        for dep in dependencies:
            source_target = dep.group(1)
            target_dependency = dep.group(3)
            if source_target in self.targets:
                self.targets[source_target]['dependencies'].add(target_dependency)

    def extract_package_dependencies(self, content: str) -> None:
        # Find package product dependencies
        package_pattern = r'packageProductDependencies\s+=\s+\((.*?)\);'
        package_sections = re.findall(package_pattern, content, re.DOTALL)

        for section in package_sections:
            package_refs = re.finditer(r'([A-F0-9]{24})\s+\/\*\s+(.*?)\s+\*\/', section)
            for ref in package_refs:
                package_name = ref.group(2).strip()
                if package_name not in self.package_dependencies:
                    self.package_dependencies[package_name] = set()

    def analyze(self) -> Dict:
        content = self.read_project_file()
        self.extract_targets(content)
        self.extract_dependencies(content)
        self.extract_package_dependencies(content)

        # Convert sets to lists for JSON serialization
        result = {
            'targets': {
                target_id: {
                    'name': info['name'],
                    'dependencies': list(info['dependencies'])
                }
                for target_id, info in self.targets.items()
            },
            'package_dependencies': {
                name: list(deps) for name, deps in self.package_dependencies.items()
            }
        }

        return result

def parse_arguments():
    parser = argparse.ArgumentParser(
        description='Analyze Xcode project targets and their dependencies.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  %(prog)s path/to/project.pbxproj
  %(prog)s ../Sportsbook.xcodeproj/project.pbxproj
        '''
    )
    parser.add_argument('project_path',
                       type=str,
                       help='Path to the project.pbxproj file')

    return parser.parse_args()

def main():
    args = parse_arguments()
    project_path = Path(args.project_path)

    if not project_path.exists():
        print(f"Error: Project file not found at {project_path}")
        print("Please provide a valid path to project.pbxproj")
        sys.exit(1)

    if not project_path.name == 'project.pbxproj':
        print("Warning: The specified file doesn't appear to be a project.pbxproj file")
        print(f"Filename: {project_path.name}")
        response = input("Do you want to continue anyway? [y/N]: ")
        if response.lower() != 'y':
            sys.exit(0)

    analyzer = XcodeProjectAnalyzer(str(project_path))
    result = analyzer.analyze()

    # Print results in a formatted way
    print("\nXcode Project Target Analysis")
    print("=" * 30)

    print("\nTargets:")
    for target_id, info in result['targets'].items():
        print(f"\n• {info['name']}")
        if info['dependencies']:
            print("  Dependencies:")
            for dep in info['dependencies']:
                target_name = next((t['name'] for t in result['targets'].values()
                                 if dep in result['targets']), dep)
                print(f"    - {target_name}")

    print("\nPackage Dependencies:")
    for package, deps in result['package_dependencies'].items():
        print(f"\n• {package}")
        if deps:
            print("  Products:")
            for dep in deps:
                print(f"    - {dep}")

if __name__ == '__main__':
    main()