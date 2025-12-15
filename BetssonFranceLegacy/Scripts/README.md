# GOMA Sportsbook iOS Build Scripts

This directory contains scripts for building the GOMA Sportsbook iOS project from the command line.

# Build Scripts Documentation

## Overview

The build system consists of two main scripts:

1. `build.py`: An enhanced build tool for building individual schemes with advanced error reporting and output formatting.
2. `build_all.py`: A script that builds all schemes in the correct order, reusing the functionality from `build.py`.

Both scripts provide better error reporting, incremental build optimizations, and structured output formats. They wrap `xcodebuild` with additional features and improved user experience.

## Features

- Multiple output modes for different use cases
- Structured error reporting with file and line information
- Progress indicators during builds
- Incremental build optimizations
- Integration with xcbeautify for better formatting
- Support for cleaning DerivedData
- LLM-friendly output mode for automation
- Organized build order for multiple schemes

## Individual Build Usage (build.py)

```bash
./Scripts/build.py -s <scheme> [options]
```

### Required Arguments

- `-s, --scheme`: Build scheme name (e.g., "Betsson PROD")

### Optional Arguments

- `-c, --configuration`: Build configuration (`Debug` or `Release`, default: `Debug`)
- `-d, --destination`: Build destination (default: `platform=iOS Simulator,name=iPhone 16`)
- `-a, --action`: Build action (`build`, `test`, or `clean`, default: `build`)
- `--clean`: Clean DerivedData before building

## Build All Usage (build_all.py)

```bash
./Scripts/build_all.py [options]
```

### Optional Arguments

- `-c, --configuration`: Build configuration (`Debug` or `Release`, default: `Debug`)
- `-d, --destination`: Build destination (default: `platform=iOS Simulator,name=iPhone 16`)
- `--clean`: Clean DerivedData before building
- `--continue-on-error`: Continue building remaining schemes even if some fail

### Build Order

The build_all script follows this predefined order:

1. Core frameworks:
   - ServicesProvider
   - SharedModels
   - DictionaryCoding
   - Extensions
   - GomaAssets
   - Theming

2. Features:
   - HeaderTextField
   - CountrySelectionFeature
   - RegisterFlow
   - AdresseFrancaise
   - NotificationsService

3. Sports data:
   - SportRadar PROD
   - SportRadar UAT
   - GomaSportRadar

4. Client apps:
   - ATP
   - Betsson PROD
   - Betsson UAT
   - Crocobet
   - DAZN
   - EveryMatrix
   - GOMASports

5. Tests:
   - SportsbookTests

## Build Script Documentation

### Overview

The `build.py` script is an enhanced build tool for the Sportsbook iOS project that provides better error reporting, incremental build optimizations, and structured output formats. It wraps `xcodebuild` with additional features and improved user experience.

### Features

- Multiple output modes for different use cases
- Structured error reporting with file and line information
- Progress indicators during builds
- Incremental build optimizations
- Integration with xcbeautify for better formatting
- Support for cleaning DerivedData
- LLM-friendly output mode for automation

### Usage

```bash
./Scripts/build.py -s <scheme> [options]
```

### Required Arguments

- `-s, --scheme`: Build scheme name (e.g., "Betsson PROD")

### Optional Arguments

- `-c, --configuration`: Build configuration (`Debug` or `Release`, default: `Debug`)
- `-d, --destination`: Build destination (default: `platform=iOS Simulator,name=iPhone 16`)
- `-a, --action`: Build action (`build`, `test`, or `clean`, default: `build`)
- `--clean`: Clean DerivedData before building

### Output Modes

The script supports several output modes to suit different needs:

1. **Normal Mode** (default)
   - Shows all build output with beautification
   - Includes warnings and errors
   - Uses xcbeautify for better formatting

2. **Verbose Mode** (`-v, --verbose`)
   - Shows all output including commands
   - Displays raw build output
   - Useful for debugging build issues

3. **Warnings-Up Mode** (`-w, --warnings-up`)
   - Shows warnings and errors only
   - Filters out less important information
   - Default mode for daily development

4. **Errors-Only Mode** (`--errors-only`)
   - Shows only error messages
   - Ideal for quick error checking

5. **LLM-Friendly Mode** (`--llm-mode`)
   - Machine-readable format
   - Structured error output
   - Progress indicators
   - Ideal for automation and LLM processing

### Error Reporting

The script provides detailed error information in a structured format:

```
BUILD_STATUS: FAILED
ERRORS:
  FILE: /path/to/file.swift
    Line:123: Error message here
    Line:456: Another error message
```

### Error Detection

The script can detect various types of errors:

1. xcbeautify formatted errors
2. Standard compiler errors
3. Raw build errors
4. Failed command errors
5. Build phase errors

### Examples

1. Normal build:
```bash
./Scripts/build.py -s "Betsson PROD"
```

2. Clean build with verbose output:
```bash
./Scripts/build.py -s "Betsson PROD" -v --clean
```

3. Release build with errors only:
```bash
./Scripts/build.py -s "Betsson PROD" -c Release --errors-only
```

4. Build with LLM-friendly output:
```bash
./Scripts/build.py -s "Betsson PROD" --llm-mode
```

### Build Optimizations

The script includes several optimizations for faster builds:

- Uses the modern build system (`-UseModernBuildSystem=YES`)
- Enables parallel target building (`-parallelizeTargets`)
- Skips unavailable actions (`-skipUnavailableActions`)
- Hides shell script environment (`-hideShellScriptEnvironment`)
- Optimizes for incremental builds

### Progress Indication

- Normal/Verbose modes: Full build output with color coding
- LLM mode: Structured progress updates (RUNNING, COMPILING, LINKING)
- Errors-only mode: Silent until errors occur

### Integration with xcbeautify

When available, the script uses xcbeautify to format the output:

- Better formatted compiler warnings and errors
- Color-coded output
- Cleaner, more readable build progress
- Grouped and categorized messages

### Error Output Structure

Errors are reported with the following information:
- File path
- Line number
- Column number (when available)
- Severity (error/warning/note)
- Detailed message
- Additional context (when available)

### Requirements

- Xcode 14.0 or later
- Xcode Command Line Tools
- iOS 13.0 or later deployment target
- Python 3.6 or later
- xcbeautify (optional, but recommended for better output formatting)

### Troubleshooting

1. If you encounter build errors:
   - Clean DerivedData using the `--clean` flag
   - Use verbose mode (`-v`) for detailed output
   - Check the error output in LLM mode for structured information

2. If xcodebuild is not found:
   ```bash
   xcode-select --install
   ```

3. For xcbeautify installation:
   ```bash
   brew install xcbeautify
   ```

### VSCode Integration

You can integrate the build script with VSCode tasks by adding the following to your `.vscode/tasks.json`:

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Build (Debug)",
            "type": "shell",
            "command": "./Scripts/build.py -s \"${input:scheme}\"",
            "group": {
                "kind": "build",
                "isDefault": true
            }
        },
        {
            "label": "Build (Release)",
            "type": "shell",
            "command": "./Scripts/build.py -s \"${input:scheme}\" -c Release",
            "group": "build"
        },
        {
            "label": "Build (Verbose)",
            "type": "shell",
            "command": "./Scripts/build.py -s \"${input:scheme}\" -v",
            "group": "build"
        },
        {
            "label": "Clean and Build",
            "type": "shell",
            "command": "./Scripts/build.py -s \"${input:scheme}\" --clean",
            "group": "build"
        }
    ],
    "inputs": [
        {
            "id": "scheme",
            "type": "promptString",
            "description": "Build scheme name"
        }
    ]
}
```

### Exit Codes

- 0: Build succeeded
- 1: Build failed
- 130: Build interrupted by user
