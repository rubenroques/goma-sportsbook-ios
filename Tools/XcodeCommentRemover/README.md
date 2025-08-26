# Xcode Comment Remover

A Python tool to remove Xcode template header comments from Swift files in your project.

## Overview

When creating new Swift files in Xcode, template comments are automatically added:

```swift
//
//  FileName.swift
//  ModuleName
//
//  Created by Author Name on DD/MM/YYYY.
//
```

This tool automatically detects and removes these unnecessary template comments while preserving all other comments and code.

## Features

- ✅ **Safe dry-run mode by default** - Shows what would be changed without modifying files
- ✅ **Respects .gitignore** - Automatically skips ignored files and directories
- ✅ **Smart detection** - Only removes actual Xcode template comments, not other comments
- ✅ **Backup support** - Option to create backup files before modification
- ✅ **Recursive processing** - Searches all subdirectories for Swift files
- ✅ **Detailed reporting** - Shows exactly which files will be/were modified

## Installation

No installation required. The script is a standalone Python 3 file.

## Usage

### Basic Usage

```bash
# Dry run - see what would be changed (default mode)
python Tools/XcodeCommentRemover/remove_xcode_comments.py /path/to/project

# For this project specifically
python Tools/XcodeCommentRemover/remove_xcode_comments.py .
```

### Actually Remove Comments

```bash
# Remove comments from all Swift files
python Tools/XcodeCommentRemover/remove_xcode_comments.py . --apply

# Remove comments and create backup files
python Tools/XcodeCommentRemover/remove_xcode_comments.py . --apply --backup
```

### Examples

```bash
# Process only a specific directory
python Tools/XcodeCommentRemover/remove_xcode_comments.py BetssonCameroonApp/

# Process specific framework
python Tools/XcodeCommentRemover/remove_xcode_comments.py Frameworks/GomaUI/

# Full project with backups
python Tools/XcodeCommentRemover/remove_xcode_comments.py . --apply --backup
```

## Command Line Options

| Option | Description |
|--------|-------------|
| `path` | Path to the project directory (required) |
| `--apply` | Actually modify files (default is dry-run) |
| `--backup` | Create backup files before modifying (only with --apply) |
| `--verbose, -v` | Verbose output |
| `--help, -h` | Show help message |

## What Gets Removed

The tool detects and removes Xcode template comments that match this pattern:

```swift
//
//  [FileName].swift
//  [ModuleName]
//
//  Created by [Author] on [Date].
//
```

### Detection Criteria

- Must start with `//` comments at the beginning of the file
- Must contain a filename ending with `.swift`
- Must contain "Created by" text
- Must be followed by blank lines before actual code

### What's Preserved

- All other comments (documentation, MARK comments, etc.)
- All code and imports
- Copyright notices (if they don't match the template pattern)
- File structure and formatting

## Safety Features

### Dry Run Mode

By default, the tool runs in dry-run mode and shows you exactly what would be changed:

```
🔍 Would modify: BetssonCameroonApp/App/Boot/AppDelegate.swift
    Removing 5 lines of comments
🔍 Would modify: BetssonCameroonApp/App/Boot/Bootstrap.swift
    Removing 5 lines of comments
```

### .gitignore Respect

The tool automatically respects your `.gitignore` file and skips:
- Build directories (`build/`, `DerivedData/`, `.build/`)
- User data (`xcuserdata/`)
- Node modules (`node_modules/`)
- Any patterns in your `.gitignore` file

### Backup Option

Use `--backup` to create `.backup` files before modification:

```bash
python Tools/XcodeCommentRemover/remove_xcode_comments.py . --apply --backup
```

## Example Output

### Dry Run
```
🛠️  Xcode Comment Remover
📁 Target directory: .

🔎 Found 3132 Swift files to analyze
🚨 DRY RUN MODE - No files will be modified

  🔍 Would modify: BetssonCameroonApp/App/Boot/AppDelegate.swift
      Removing 5 lines of comments
  🔍 Would modify: Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/LanguageSelectorView/LanguageSelectorView.swift
      Removing 6 lines of comments

📊 Summary:
   Files analyzed: 3132
   Files with Xcode comments: 2847

💡 To actually remove the comments, run with --apply flag
```

### Actual Removal
```
🛠️  Xcode Comment Remover
📁 Target directory: .

🔎 Found 3132 Swift files to analyze

  ✅ Modified: BetssonCameroonApp/App/Boot/AppDelegate.swift
  ✅ Modified: BetssonCameroonApp/App/Boot/Bootstrap.swift
  📁 Backup created: AppDelegate.swift.backup

📊 Summary:
   Files analyzed: 3132
   Files with Xcode comments: 2847

✅ Successfully processed 2847 files
```

## Before and After Example

### Before
```swift
//
//  AppDelegate.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/07/2021.
//

import UIKit
import Firebase
// ... rest of the code
```

### After
```swift
import UIKit
import Firebase
// ... rest of the code
```

## Requirements

- Python 3.6 or later
- No additional dependencies required

## Safety Considerations

1. **Always run dry-run first** to see what will be changed
2. **Consider using --backup** for important projects
3. **Test on a small directory first** if you're unsure
4. **Commit your changes** before running the tool so you can easily revert

## Contributing

The tool is located at `Tools/XcodeCommentRemover/remove_xcode_comments.py` and can be modified as needed for your specific requirements.