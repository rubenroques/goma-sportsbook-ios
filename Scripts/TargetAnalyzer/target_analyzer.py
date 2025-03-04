#!/usr/bin/env python3

import re
import json
import sys
import argparse
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional
from dataclasses import dataclass, field
import logging
from rich.console import Console
from rich.table import Table

@dataclass
class PackageDependency:
    name: str
    source: str
    version: Optional[str] = None
    products: Set[str] = field(default_factory=set)

@dataclass
class Target:
    id: str
    name: str
    dependencies: Set[str] = field(default_factory=set)
    build_phases: List[str] = field(default_factory=list)
    build_settings: Dict[str, str] = field(default_factory=dict)

class XcodeProjectAnalyzer:
    def __init__(self, project_path: str, verbose: bool = False):
        self.project_path = project_path
        self.targets: Dict[str, Target] = {}
        self.package_dependencies: Dict[str, PackageDependency] = {}
        self.console = Console()

        # Setup logging
        level = logging.DEBUG if verbose else logging.INFO
        logging.basicConfig(
            level=level,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger(__name__)

    # ... (previous methods remain the same until extract_package_dependencies)
        def extract_targets(self, content: str) -> None:
        # Find all target sections
        target_pattern = r'\/\* Begin PBXNativeTarget section \\/\n(.?)\/\* End PBXNativeTarget section \*\/'
        target_sections = re.findall(target_pattern, content, re.DOTALL)

        if target_sections:
            # Extract individual targets
            target_entry_pattern = r'([A-F0-9]{24})\s+\/\\s+(.?)\s+\\/\s+=\s+{[^}]?name\s+=\s+(.*?);'
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
        dependency_pattern = r'([A-F0-9]{24})\s+\/\\s+(.?)\s+\\/\s+=\s+{[^}]?target\s+=\s+([A-F0-9]{24})'
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
            package_refs = re.finditer(r'([A-F0-9]{24})\s+\/\\s+(.?)\s+\*\/', section)
            for ref in package_refs:
                package_name = ref.group(2).strip()
                if package_name not in self.package_dependencies:
                    self.package_dependencies[package_name] = set()

    def extract_package_dependencies(self, content: str) -> None:
        # Find package references section
        package_refs_pattern = r'\/\* XCRemoteSwiftPackageReference section \*\/\n(.*?)\/\* End XCRemoteSwiftPackageReference section \*\/'
        package_refs_section = re.search(package_refs_pattern, content, re.DOTALL)

        if package_refs_section:
            # Extract individual package references
            package_pattern = r'([A-F0-9]{24})\s+\/\*\s+(.*?)\s+\*\/\s+=\s+{(.*?)};'
            packages = re.finditer(package_pattern, package_refs_section.group(1), re.DOTALL)

            for package in packages:
                package_id = package.group(1)
                package_name = package.group(2).strip()
                package_info = package.group(3)

                # Extract repository URL
                repo_url = re.search(r'repositoryURL\s+=\s+"(.*?)"', package_info)
                source = repo_url.group(1) if repo_url else "Unknown source"

                # Extract version requirement
                version = re.search(r'requirement\s+=\s+{.*?kind\s+=\s+(.*?);.*?}', package_info, re.DOTALL)
                version_str = version.group(1).strip() if version else None

                self.package_dependencies[package_id] = PackageDependency(
                    name=package_name,
                    source=source,
                    version=version_str
                )
                self.logger.debug(f"Found package: {package_name} from {source}")

        # Find local package references
        local_package_pattern = r'\/\* XCLocalSwiftPackageReference section \*\/\n(.*?)\/\* End XCLocalSwiftPackageReference section \*\/'
        local_packages_section = re.search(local_package_pattern, content, re.DOTALL)

        if local_packages_section:
            local_package_entry = r'([A-F0-9]{24})\s+\/\*\s+(.*?)\s+\*\/\s+=\s+{.*?relativePath\s+=\s+(.*?);.*?}'
            local_packages = re.finditer(local_package_entry, local_packages_section.group(1), re.DOTALL)

            for package in local_packages:
                package_id = package.group(1)
                package_name = package.group(2).strip()
                relative_path = package.group(3).strip().strip('"')

                self.package_dependencies[package_id] = PackageDependency(
                    name=package_name,
                    source=f"Local: {relative_path}"
                )
                self.logger.debug(f"Found local package: {package_name} at {relative_path}")

        # Link package products to their packages
        products_pattern = r'\/\* XCSwiftPackageProductDependency section \*\/\n(.*?)\/\* End XCSwiftPackageProductDependency section \*\/'
        products_section = re.search(products_pattern, content, re.DOTALL)

        if products_section:
            product_entry = r'.*?package\s+=\s+([A-F0-9]{24}).*?product\s+=\s+(.*?);'
            products = re.finditer(product_entry, products_section.group(1), re.DOTALL)

            for product in products:
                package_id = product.group(1)
                product_name = product.group(2).strip().strip('"')

                if package_id in self.package_dependencies:
                    self.package_dependencies[package_id].products.add(product_name)
                    self.logger.debug(f"Linked product {product_name} to package {self.package_dependencies[package_id].name}")

    def print_results(self, result: Dict) -> None:
        # ... (previous table printing code remains the same)

        # Create and print package dependencies table with sources
        if result['package_dependencies']:
            package_table = Table(title="Package Dependencies")
            package_table.add_column("Package Name", style="cyan")
            package_table.add_column("Source", style="yellow")
            package_table.add_column("Version", style="magenta")
            package_table.add_column("Products", style="green")

            for package in result['package_dependencies'].values():
                package_table.add_row(
                    package['name'],
                    package['source'],
                    package['version'] or "Not specified",
                    "\n".join(package['products']) if package['products'] else "None"
                )

            self.console.print("\n")
            self.console.print(package_table)

        # ... (rest of the method remains the same)
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

    def analyze(self) -> Dict:
        content = self.read_project_file()
        self.extract_targets(content)
        self.extract_dependencies(content)
        self.extract_package_dependencies(content)
        self.extract_build_phases(content)
        self.extract_build_settings(content)

        cycles = self.detect_circular_dependencies()
        if cycles:
            self.logger.warning("Circular dependencies detected:")
            for cycle in cycles:
                cycle_names = [self.targets[target_id].name for target_id in cycle]
                self.logger.warning(f"  {' -> '.join(cycle_names)}")

        result = {
            'targets': {
                target_id: {
                    'name': target.name,
                    'dependencies': list(target.dependencies),
                    'build_phases': target.build_phases,
                    'build_settings': target.build_settings
                }
                for target_id, target in self.targets.items()
            },
            'package_dependencies': {
                package_id: {
                    'name': package.name,
                    'source': package.source,
                    'version': package.version,
                    'products': list(package.products)
                }
                for package_id, package in self.package_dependencies.items()
            },
            'circular_dependencies': [
                [self.targets[target_id].name for target_id in cycle]
                for cycle in cycles
            ]
        }

        return result

    def print_results(self, result: Dict) -> None:
        # Create and print targets table
        target_table = Table(title="Xcode Project Targets")
        target_table.add_column("Target Name", style="cyan")
        target_table.add_column("Dependencies", style="green")
        target_table.add_column("Build Phases", style="yellow")

        for target_info in result['targets'].values():
            dep_names = [
                result['targets'][dep]['name']
                for dep in target_info['dependencies']
                if dep in result['targets']
            ]
            target_table.add_row(
                target_info['name'],
                "\n".join(dep_names) if dep_names else "None",
                "\n".join(target_info['build_phases']) if target_info['build_phases'] else "None"
            )

        self.console.print(target_table)

        # Create and print package dependencies table
        if result['package_dependencies']:
            package_table = Table(title="Package Dependencies")
            package_table.add_column("Package Name", style="cyan")
            package_table.add_column("Products", style="green")

            for package, deps in result['package_dependencies'].items():
                package_table.add_row(
                    package,
                    "\n".join(deps) if deps else "None"
                )

            self.console.print("\n")
            self.console.print(package_table)

        # Print circular dependencies warnings
        if result['circular_dependencies']:
            self.console.print("\n[red]Warning: Circular Dependencies Detected[/red]")
            for cycle in result['circular_dependencies']:
                self.console.print(f"[yellow]  {' -> '.join(cycle)}[/yellow]")

def parse_arguments():
    parser = argparse.ArgumentParser(
        description='Analyze Xcode project targets and their dependencies.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  %(prog)s path/to/project.pbxproj
  %(prog)s ../MyApp.xcodeproj/project.pbxproj --verbose
        '''
    )
    parser.add_argument('project_path',
                       type=str,
                       help='Path to the project.pbxproj file')
    parser.add_argument('--verbose', '-v',
                       action='store_true',
                       help='Enable verbose logging')
    parser.add_argument('--output', '-o',
                       type=str,
                       help='Output JSON file path')

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

    analyzer = XcodeProjectAnalyzer(str(project_path), verbose=args.verbose)
    result = analyzer.analyze()

    # Print results to console
    analyzer.print_results(result)

    # Save to JSON file if requested
    if args.output:
        try:
            with open(args.output, 'w', encoding='utf-8') as f:
                json.dump(result, f, indent=2)
            print(f"\nResults saved to {args.output}")
        except Exception as e:
            print(f"Error saving results: {e}")

if __name__ == '__main__':
    main()