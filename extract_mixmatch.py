#!/usr/bin/env python3
import os
import subprocess
import re

def run_command(cmd):
    """Run a shell command and return the output."""
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    stdout, stderr = process.communicate()
    return stdout.decode('utf-8', errors='replace')

def extract_file_references():
    """Extract all files containing MixMatch references."""
    cmd = 'grep -r -l -i "mixmatch\\|MixMatch\\|mix-match\\|Mix Match" --include="*.swift" .'
    output = run_command(cmd)
    return [line.strip() for line in output.splitlines() if line.strip()]

def extract_lines_from_file(file_path):
    """Extract line numbers containing MixMatch references from a file."""
    cmd = f'grep -n -i "mixmatch\\|MixMatch\\|mix-match\\|Mix Match" "{file_path}"'
    output = run_command(cmd)
    
    matches = []
    for line in output.splitlines():
        parts = line.split(':', 1)
        if len(parts) >= 2:
            try:
                line_number = int(parts[0])
                content = parts[1]
                matches.append((line_number, content))
            except ValueError:
                continue
    
    return matches

def get_surrounding_code(file_path, line_number, context=5):
    """Get surrounding code for a specific line in a file."""
    start_line = max(1, line_number - context)
    end_line = line_number + context
    
    cmd = f'sed -n "{start_line},{end_line}p" "{file_path}"'
    output = run_command(cmd)
    
    lines = output.splitlines()
    result = []
    
    for i, line in enumerate(lines):
        result.append((start_line + i, line))
    
    return result

def generate_markdown(files_with_matches):
    """Generate markdown content from files with matches."""
    markdown = "# MixMatch Functionality in Sportsbook iOS\n\n"
    markdown += "This document contains all references to MixMatch functionality in the codebase.\n\n"
    
    for file_path, matches in files_with_matches.items():
        markdown += f"## {file_path}\n\n"
        
        # Track lines we've already included to avoid duplicates
        included_lines = set()
        
        for line_number, content in matches:
            # Get surrounding code
            surrounding_code = get_surrounding_code(file_path, line_number)
            
            # Check if we've already included these lines
            line_range = set(line[0] for line in surrounding_code)
            if any(line in included_lines for line in line_range):
                continue
                
            # Add these lines to our tracking set
            included_lines.update(line_range)
            
            markdown += f"### Line {line_number}\n\n"
            markdown += "```swift\n"
            for line_num, line_content in surrounding_code:
                if line_num == line_number:
                    markdown += f"{line_num}: {line_content} ← MATCH\n"
                else:
                    markdown += f"{line_num}: {line_content}\n"
            markdown += "```\n\n"
    
    return markdown

def main():
    # Get all files with MixMatch references
    files = extract_file_references()
    
    # Extract line numbers and content from each file
    files_with_matches = {}
    for file_path in files:
        matches = extract_lines_from_file(file_path)
        if matches:
            files_with_matches[file_path] = matches
    
    # Generate markdown
    markdown_content = generate_markdown(files_with_matches)
    
    # Write to file
    with open("mixmatch_references.md", "w") as f:
        f.write(markdown_content)
    
    print(f"Generated mixmatch_references.md with references from {len(files_with_matches)} files.")

if __name__ == "__main__":
    main() 