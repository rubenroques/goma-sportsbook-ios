#!/usr/bin/env python3

import re
import os
from collections import defaultdict

def extract_unused_closure_params(swiftlint_file):
    """Extract unused closure parameter warnings from SwiftLint output file."""
    unused_params = []
    
    with open(swiftlint_file, 'r') as f:
        for line in f:
            if 'unused_closure_parameter' in line:
                # Extract file path, line number, and warning message
                match = re.search(r'([^:]+):(\d+):\d+: warning: (.*)', line.strip())
                if match:
                    file_path, line_num, message = match.groups()
                    unused_params.append({
                        'file_path': file_path,
                        'line_num': int(line_num),
                        'message': message
                    })
    
    return unused_params

def generate_markdown_todo(unused_params):
    """Generate a Markdown to-do list from the extracted warnings."""
    if not unused_params:
        return "# No unused closure parameters found\n"
    
    # Group by file for better organization
    files_dict = defaultdict(list)
    for param in unused_params:
        files_dict[param['file_path']].append(param)
    
    markdown = "# Unused Closure Parameters To-Do List\n\n"
    
    for file_path, params in sorted(files_dict.items()):
        rel_path = os.path.relpath(file_path)
        markdown += f"## {rel_path}\n\n"
        
        for param in sorted(params, key=lambda x: x['line_num']):
            line_num = param['line_num']
            message = param['message']
            # Extract parameter name from the message
            param_match = re.search(r'Parameter \'(\w+)\' not used', message)
            param_name = param_match.group(1) if param_match else "unknown"
            
            markdown += f"- [ ] Line {line_num}: Replace unused parameter `{param_name}` with underscore `_`\n"
        
        markdown += "\n"
    
    return markdown

def generate_llm_prompt(unused_count):
    """Generate a prompt for an LLM to fix the unused closure parameters."""
    prompt = f"""# Task: Fix Unused Closure Parameters

## Instructions

Your task is to fix {unused_count} instances of unused closure parameters in Swift code. Follow these strict guidelines:

1. **ONLY replace unused parameter names with underscores (`_`).**
2. **DO NOT modify any other code.**
3. **DO NOT refactor or change anything else in the files.**
4. **DO NOT add or remove any functionality.**

For each item in the to-do list:
- Locate the specified file and line number
- Find the closure parameter that is not being used
- Replace ONLY that parameter name with an underscore (`_`)
- Leave all other code exactly as it is

## Example

If you see:
```swift
button.addAction { (sender) in
    print("Button tapped")
}
```

Change it to:
```swift
button.addAction { (_) in
    print("Button tapped")
}
```

Please work through the to-do list systematically, making only these specific changes.
"""
    return prompt

def main():
    swiftlint_file = 'swiftlint_output.txt'
    
    if not os.path.exists(swiftlint_file):
        print(f"Error: {swiftlint_file} not found.")
        return
    
    unused_params = extract_unused_closure_params(swiftlint_file)
    
    # Generate and save the Markdown to-do list
    todo_markdown = generate_markdown_todo(unused_params)
    with open('unused_closure_params_todo.md', 'w') as f:
        f.write(todo_markdown)
    
    # Generate and save the LLM prompt
    llm_prompt = generate_llm_prompt(len(unused_params))
    with open('unused_closure_params_prompt.md', 'w') as f:
        f.write(llm_prompt)
    
    print(f"Found {len(unused_params)} unused closure parameters.")
    print("To-do list saved to 'unused_closure_params_todo.md'")
    print("LLM prompt saved to 'unused_closure_params_prompt.md'")

if __name__ == "__main__":
    main() 