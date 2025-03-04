#!/usr/bin/env python3

import os
import re
import sys
import argparse
import json
from collections import defaultdict

def find_swift_files(root_dir):
    """Find all Swift files in the project, excluding build and dependency folders."""
    print("Searching for Swift files...")

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

    print(f"Found {len(swift_files)} Swift files.")
    return swift_files

def should_ignore_type(name, content=None):
    """Determine if a type should be ignored in the analysis."""
    # List of types to ignore
    ignored_types = [
        'CodingKeys',  # Common for Codable conformance
        'Constants',   # Often used for static values
        'Keys',        # Often used for dictionary keys
        'Notification.Name', # Extension on Notification.Name
    ]

    # Check if the name is in the ignored list
    if name in ignored_types:
        return True

    # Check if it's a nested CodingKeys enum (common pattern)
    if name.endswith('CodingKeys'):
        return True

    return False

def parse_swift_file(file_path):
    """Parse a Swift file to extract type declarations."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

            # Extract file content metrics
            lines = content.split('\n')
            line_count = len(lines)

            # Find all class, struct, and enum declarations
            # This regex looks for class/struct/enum declarations that are not inside comments
            # and are at the beginning of a line (possibly with whitespace)
            class_pattern = r'^\s*(public|private|internal|fileprivate|open)?\s*(final)?\s*class\s+(\w+)'
            struct_pattern = r'^\s*(public|private|internal|fileprivate|open)?\s*struct\s+(\w+)'
            enum_pattern = r'^\s*(public|private|internal|fileprivate|open)?\s*enum\s+(\w+)'

            # Find all matches
            classes = []
            structs = []
            enums = []

            # Process line by line to better handle comments and nested types
            in_comment_block = False
            for i, line in enumerate(lines):
                # Skip comment lines
                if '/*' in line:
                    in_comment_block = True
                if '*/' in line:
                    in_comment_block = False
                    continue
                if in_comment_block or line.strip().startswith('//'):
                    continue

                # Check for class declarations
                class_match = re.search(class_pattern, line)
                if class_match:
                    access = class_match.group(1) or 'internal'
                    is_final = bool(class_match.group(2))
                    name = class_match.group(3)

                    # Skip ignored types
                    if should_ignore_type(name, content):
                        continue

                    classes.append({
                        'name': name,
                        'line': i + 1,
                        'access': access,
                        'is_final': is_final
                    })

                # Check for struct declarations
                struct_match = re.search(struct_pattern, line)
                if struct_match:
                    access = struct_match.group(1) or 'internal'
                    name = struct_match.group(2)

                    # Skip ignored types
                    if should_ignore_type(name, content):
                        continue

                    structs.append({
                        'name': name,
                        'line': i + 1,
                        'access': access
                    })

                # Check for enum declarations
                enum_match = re.search(enum_pattern, line)
                if enum_match:
                    access = enum_match.group(1) or 'internal'
                    name = enum_match.group(2)

                    # Skip ignored types
                    if should_ignore_type(name, content):
                        continue

                    enums.append({
                        'name': name,
                        'line': i + 1,
                        'access': access
                    })

            # Determine if file has multiple top-level declarations
            total_declarations = len(classes) + len(structs) + len(enums)
            has_multiple_declarations = total_declarations > 1

            return {
                'file_path': file_path,
                'line_count': line_count,
                'classes': classes,
                'structs': structs,
                'enums': enums,
                'total_declarations': total_declarations,
                'has_multiple_declarations': has_multiple_declarations
            }

    except Exception as e:
        print(f"Error parsing {file_path}: {e}")
        return {
            'file_path': file_path,
            'line_count': 0,
            'classes': [],
            'structs': [],
            'enums': [],
            'total_declarations': 0,
            'has_multiple_declarations': False,
            'error': str(e)
        }

def analyze_swift_files(swift_files):
    """Analyze all Swift files and collect data about types."""
    print("Analyzing Swift files...")

    files_data = []
    files_with_multiple_declarations = []

    for file_path in swift_files:
        file_data = parse_swift_file(file_path)
        files_data.append(file_data)

        if file_data.get('has_multiple_declarations', False):
            files_with_multiple_declarations.append(file_data)

    print(f"Analysis complete. Found {len(files_with_multiple_declarations)} files with multiple declarations.")
    return files_data, files_with_multiple_declarations

def generate_report(files_data, files_with_multiple_declarations, root_dir):
    """Generate a report of Swift types and files with multiple declarations."""
    print("Generating report...")

    # Collect statistics
    total_files = len(files_data)
    total_classes = sum(len(file_data['classes']) for file_data in files_data)
    total_structs = sum(len(file_data['structs']) for file_data in files_data)
    total_enums = sum(len(file_data['enums']) for file_data in files_data)
    total_types = total_classes + total_structs + total_enums

    # Generate report
    report = "# Swift Types Analysis Report\n\n"

    # Summary section
    report += "## Summary\n\n"
    report += f"- **Total Swift Files**: {total_files}\n"
    report += f"- **Total Types**: {total_types}\n"
    report += f"  - Classes: {total_classes}\n"
    report += f"  - Structs: {total_structs}\n"
    report += f"  - Enums: {total_enums}\n"
    report += f"- **Files with Multiple Declarations**: {len(files_with_multiple_declarations)}\n\n"

    # Add Mermaid chart for type distribution
    if total_types > 0:
        report += "## Type Distribution\n\n"
        report += "```mermaid\n"
        report += "pie\n"
        report += f'    title "Swift Type Distribution"\n'
        report += f'    "Classes" : {total_classes}\n'
        report += f'    "Structs" : {total_structs}\n'
        report += f'    "Enums" : {total_enums}\n'
        report += "```\n\n"

    # Files with multiple declarations
    if files_with_multiple_declarations:
        report += "## Files with Multiple Declarations\n\n"
        report += "| File | Types | Classes | Structs | Enums | Line Count |\n"
        report += "|------|-------|---------|---------|-------|------------|\n"

        for file_data in sorted(files_with_multiple_declarations, key=lambda x: x['total_declarations'], reverse=True):
            rel_path = os.path.relpath(file_data['file_path'], root_dir)
            report += f"| {rel_path} | {file_data['total_declarations']} | {len(file_data['classes'])} | {len(file_data['structs'])} | {len(file_data['enums'])} | {file_data['line_count']} |\n"

        report += "\n"

        # Add bar chart for files with multiple declarations
        report += "### Multiple Declarations Visualization\n\n"
        report += "```mermaid\n"
        report += "bar\n"
        report += f'    title "Files with Multiple Declarations"\n'
        report += "    axis x Types\n"
        report += "    axis y File\n"

        # Limit to top 10 files for readability
        for file_data in sorted(files_with_multiple_declarations, key=lambda x: x['total_declarations'], reverse=True)[:10]:
            rel_path = os.path.basename(file_data['file_path'])
            report += f'    "{rel_path}" : {file_data["total_declarations"]}\n'

        report += "```\n\n"

        # Detailed breakdown of files with multiple declarations
        report += "## Detailed Breakdown of Files with Multiple Declarations\n\n"

        for file_data in sorted(files_with_multiple_declarations, key=lambda x: x['total_declarations'], reverse=True):
            rel_path = os.path.relpath(file_data['file_path'], root_dir)
            report += f"### {rel_path}\n\n"

            if file_data['classes']:
                report += "**Classes:**\n\n"
                for cls in file_data['classes']:
                    report += f"- `{cls['name']}` (line {cls['line']}, {cls['access']})\n"
                report += "\n"

            if file_data['structs']:
                report += "**Structs:**\n\n"
                for struct in file_data['structs']:
                    report += f"- `{struct['name']}` (line {struct['line']}, {struct['access']})\n"
                report += "\n"

            if file_data['enums']:
                report += "**Enums:**\n\n"
                for enum in file_data['enums']:
                    report += f"- `{enum['name']}` (line {enum['line']}, {enum['access']})\n"
                report += "\n"

            report += "**Recommendation**: Consider splitting these types into separate files for better maintainability.\n\n"

    # All types summary
    report += "## All Types Summary\n\n"
    report += "| Type | Count | Percentage |\n"
    report += "|------|-------|------------|\n"

    # Avoid division by zero
    if total_types > 0:
        report += f"| Classes | {total_classes} | {total_classes/total_types*100:.1f}% |\n"
        report += f"| Structs | {total_structs} | {total_structs/total_types*100:.1f}% |\n"
        report += f"| Enums | {total_enums} | {total_enums/total_types*100:.1f}% |\n"
    else:
        report += f"| Classes | {total_classes} | 0.0% |\n"
        report += f"| Structs | {total_structs} | 0.0% |\n"
        report += f"| Enums | {total_enums} | 0.0% |\n"

    return report

def generate_html_report(files_data, files_with_multiple_declarations, root_dir):
    """Generate an HTML report with interactive charts."""
    print("Generating HTML report...")

    # Collect statistics
    total_files = len(files_data)
    total_classes = sum(len(file_data['classes']) for file_data in files_data)
    total_structs = sum(len(file_data['structs']) for file_data in files_data)
    total_enums = sum(len(file_data['enums']) for file_data in files_data)
    total_types = total_classes + total_structs + total_enums

    # Generate HTML report
    html = """<!DOCTYPE html>
<html>
<head>
    <title>Swift Types Analysis Report</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        h1, h2, h3 {
            color: #0066cc;
        }
        table {
            border-collapse: collapse;
            width: 100%;
            margin: 20px 0;
        }
        th, td {
            text-align: left;
            padding: 12px;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #f2f2f2;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        .chart-container {
            width: 600px;
            height: 400px;
            margin: 20px 0;
        }
        .summary-box {
            background-color: #f8f9fa;
            border-radius: 5px;
            padding: 15px;
            margin-bottom: 20px;
        }
        .recommendation {
            background-color: #e6f7ff;
            border-left: 4px solid #1890ff;
            padding: 10px;
            margin: 10px 0;
        }
        .type-name {
            font-family: monospace;
            background-color: #f0f0f0;
            padding: 2px 4px;
            border-radius: 3px;
        }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <h1>Swift Types Analysis Report</h1>

    <div class="summary-box">
        <h2>Summary</h2>
        <ul>
            <li><strong>Total Swift Files:</strong> {total_files}</li>
            <li><strong>Total Types:</strong> {total_types}
                <ul>
                    <li>Classes: {total_classes}</li>
                    <li>Structs: {total_structs}</li>
                    <li>Enums: {total_enums}</li>
                </ul>
            </li>
            <li><strong>Files with Multiple Declarations:</strong> {files_with_multiple_declarations_count}</li>
        </ul>
    </div>

    <h2>Type Distribution</h2>
    <div class="chart-container">
        <canvas id="typeDistributionChart"></canvas>
    </div>

    <script>
        // Type distribution chart
        const typeCtx = document.getElementById('typeDistributionChart').getContext('2d');
        const typeChart = new Chart(typeCtx, {{
            type: 'pie',
            data: {{
                labels: ['Classes', 'Structs', 'Enums'],
                datasets: [{{
                    data: [{total_classes}, {total_structs}, {total_enums}],
                    backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56']
                }}]
            }},
            options: {{
                responsive: true,
                plugins: {{
                    title: {{
                        display: true,
                        text: 'Swift Type Distribution'
                    }}
                }}
            }}
        }});
    </script>
""".format(
        total_files=total_files,
        total_types=total_types,
        total_classes=total_classes,
        total_structs=total_structs,
        total_enums=total_enums,
        files_with_multiple_declarations_count=len(files_with_multiple_declarations)
    )

    # Files with multiple declarations
    if files_with_multiple_declarations:
        # Prepare data for the chart
        file_names = []
        declaration_counts = []
        class_counts = []
        struct_counts = []
        enum_counts = []

        for file_data in sorted(files_with_multiple_declarations, key=lambda x: x['total_declarations'], reverse=True)[:10]:
            file_names.append(os.path.basename(file_data['file_path']))
            declaration_counts.append(file_data['total_declarations'])
            class_counts.append(len(file_data['classes']))
            struct_counts.append(len(file_data['structs']))
            enum_counts.append(len(file_data['enums']))

        html += """
    <h2>Files with Multiple Declarations</h2>
    <div class="chart-container">
        <canvas id="multipleDeclarationsChart"></canvas>
    </div>

    <script>
        // Multiple declarations chart
        const mdCtx = document.getElementById('multipleDeclarationsChart').getContext('2d');
        const mdChart = new Chart(mdCtx, {{
            type: 'bar',
            data: {{
                labels: {file_names},
                datasets: [
                    {{
                        label: 'Classes',
                        data: {class_counts},
                        backgroundColor: '#FF6384'
                    }},
                    {{
                        label: 'Structs',
                        data: {struct_counts},
                        backgroundColor: '#36A2EB'
                    }},
                    {{
                        label: 'Enums',
                        data: {enum_counts},
                        backgroundColor: '#FFCE56'
                    }}
                ]
            }},
            options: {{
                responsive: true,
                plugins: {{
                    title: {{
                        display: true,
                        text: 'Files with Multiple Declarations'
                    }}
                }},
                scales: {{
                    x: {{
                        stacked: true,
                    }},
                    y: {{
                        stacked: true
                    }}
                }}
            }}
        }});
    </script>

    <h2>Files with Multiple Declarations</h2>
    <table>
        <tr>
            <th>File</th>
            <th>Total Types</th>
            <th>Classes</th>
            <th>Structs</th>
            <th>Enums</th>
            <th>Line Count</th>
        </tr>
""".format(
            file_names=json.dumps(file_names),
            class_counts=json.dumps(class_counts),
            struct_counts=json.dumps(struct_counts),
            enum_counts=json.dumps(enum_counts)
        )

        for file_data in sorted(files_with_multiple_declarations, key=lambda x: x['total_declarations'], reverse=True):
            rel_path = os.path.relpath(file_data['file_path'], root_dir)
            html += f"""
        <tr>
            <td>{rel_path}</td>
            <td>{file_data['total_declarations']}</td>
            <td>{len(file_data['classes'])}</td>
            <td>{len(file_data['structs'])}</td>
            <td>{len(file_data['enums'])}</td>
            <td>{file_data['line_count']}</td>
        </tr>"""

        html += """
    </table>

    <h2>Detailed Breakdown of Files with Multiple Declarations</h2>
"""

        for file_data in sorted(files_with_multiple_declarations, key=lambda x: x['total_declarations'], reverse=True):
            rel_path = os.path.relpath(file_data['file_path'], root_dir)
            html += f"""
    <h3>{rel_path}</h3>
"""

            if file_data['classes']:
                html += """
    <h4>Classes:</h4>
    <ul>
"""
                for cls in file_data['classes']:
                    html += f"""
        <li><span class="type-name">{cls['name']}</span> (line {cls['line']}, {cls['access']})</li>"""
                html += """
    </ul>
"""

            if file_data['structs']:
                html += """
    <h4>Structs:</h4>
    <ul>
"""
                for struct in file_data['structs']:
                    html += f"""
        <li><span class="type-name">{struct['name']}</span> (line {struct['line']}, {struct['access']})</li>"""
                html += """
    </ul>
"""

            if file_data['enums']:
                html += """
    <h4>Enums:</h4>
    <ul>
"""
                for enum in file_data['enums']:
                    html += f"""
        <li><span class="type-name">{enum['name']}</span> (line {enum['line']}, {enum['access']})</li>"""
                html += """
    </ul>
"""

            html += """
    <div class="recommendation">
        <strong>Recommendation:</strong> Consider splitting these types into separate files for better maintainability.
    </div>
"""

    # All types summary
    html += """
    <h2>All Types Summary</h2>
    <table>
        <tr>
            <th>Type</th>
            <th>Count</th>
            <th>Percentage</th>
        </tr>
"""

    # Avoid division by zero
    if total_types > 0:
        class_percentage = total_classes/total_types*100
        struct_percentage = total_structs/total_types*100
        enum_percentage = total_enums/total_types*100
    else:
        class_percentage = 0
        struct_percentage = 0
        enum_percentage = 0

    html += f"""
        <tr>
            <td>Classes</td>
            <td>{total_classes}</td>
            <td>{class_percentage:.1f}%</td>
        </tr>
        <tr>
            <td>Structs</td>
            <td>{total_structs}</td>
            <td>{struct_percentage:.1f}%</td>
        </tr>
        <tr>
            <td>Enums</td>
            <td>{total_enums}</td>
            <td>{enum_percentage:.1f}%</td>
        </tr>
    </table>
</body>
</html>
"""

    return html

def generate_json_report(files_data, files_with_multiple_declarations, root_dir):
    """Generate a JSON report of Swift types and files with multiple declarations."""
    print("Generating JSON report...")

    # Collect statistics
    total_files = len(files_data)
    total_classes = sum(len(file_data['classes']) for file_data in files_data)
    total_structs = sum(len(file_data['structs']) for file_data in files_data)
    total_enums = sum(len(file_data['enums']) for file_data in files_data)
    total_types = total_classes + total_structs + total_enums

    # Prepare files with multiple declarations data
    multiple_declarations = []
    for file_data in files_with_multiple_declarations:
        rel_path = os.path.relpath(file_data['file_path'], root_dir)
        multiple_declarations.append({
            'file_path': rel_path,
            'total_declarations': file_data['total_declarations'],
            'classes': file_data['classes'],
            'structs': file_data['structs'],
            'enums': file_data['enums'],
            'line_count': file_data['line_count']
        })

    # Create JSON structure
    report_data = {
        'summary': {
            'total_files': total_files,
            'total_types': total_types,
            'total_classes': total_classes,
            'total_structs': total_structs,
            'total_enums': total_enums,
            'files_with_multiple_declarations': len(files_with_multiple_declarations)
        },
        'type_distribution': {
            'classes': total_classes,
            'structs': total_structs,
            'enums': total_enums
        },
        'files_with_multiple_declarations': multiple_declarations
    }

    return json.dumps(report_data, indent=2)

def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(description='Analyze Swift files for classes, structs, and enums.')
    parser.add_argument('folder', nargs='?', default=None,
                        help='Folder to scan (default: project root)')
    parser.add_argument('-o', '--output', default=None,
                        help='Output file path (default: swift_types_report.md in the script directory)')
    parser.add_argument('--format', choices=['markdown', 'html', 'json'], default='markdown',
                        help='Output format (default: markdown)')
    parser.add_argument('--top-files', type=int, default=20,
                        help='Number of top largest files to include in the report')
    return parser.parse_args()

def main():
    # Handle help command directly
    if len(sys.argv) > 1 and (sys.argv[1] == '--help' or sys.argv[1] == '-h'):
        parser = argparse.ArgumentParser(description='Analyze Swift files for classes, structs, and enums.')
        parser.add_argument('folder', nargs='?', default=None,
                            help='Folder to scan (default: project root)')
        parser.add_argument('-o', '--output', default=None,
                            help='Output file path (default: swift_types_report.md in the script directory)')
        parser.add_argument('--format', choices=['markdown', 'html', 'json'], default='markdown',
                            help='Output format (default: markdown)')
        parser.add_argument('--top-files', type=int, default=20,
                            help='Number of top largest files to include in the report')
        parser.print_help()
        return

    # Parse command line arguments
    args = parse_arguments()

    # Determine root directory
    script_dir = os.path.dirname(os.path.abspath(__file__))

    if args.folder:
        # Use the specified folder
        if os.path.isabs(args.folder):
            root_dir = args.folder
        else:
            # Relative to current working directory
            root_dir = os.path.abspath(args.folder)
    else:
        # Default: use project root (two levels up from the script)
        root_dir = os.path.abspath(os.path.join(script_dir, "../.."))

    print(f"Scanning project at: {root_dir}")

    # Find all Swift files
    swift_files = find_swift_files(root_dir)

    if not swift_files:
        print("No Swift files found. Exiting.")
        return

    # Analyze Swift files
    files_data, files_with_multiple_declarations = analyze_swift_files(swift_files)

    # Determine output format and generate report
    report_format = args.format.lower()

    if report_format == 'markdown':
        report_content = generate_report(files_data, files_with_multiple_declarations, root_dir)
        default_extension = '.md'
    elif report_format == 'html':
        report_content = generate_html_report(files_data, files_with_multiple_declarations, root_dir)
        default_extension = '.html'
    elif report_format == 'json':
        report_content = generate_json_report(files_data, files_with_multiple_declarations, root_dir)
        default_extension = '.json'
    else:
        print(f"Unsupported format: {report_format}. Using markdown.")
        report_content = generate_report(files_data, files_with_multiple_declarations, root_dir)
        default_extension = '.md'

    # Determine output path
    if args.output:
        if os.path.isabs(args.output):
            report_path = args.output
        else:
            report_path = os.path.abspath(args.output)
    else:
        report_path = os.path.join(script_dir, f'swift_types_report{default_extension}')

    # Save report
    with open(report_path, 'w') as f:
        f.write(report_content)

    print(f"Report saved to '{report_path}'")

if __name__ == "__main__":
    main()