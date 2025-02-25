# GOMA Sportsbook iOS Build Scripts

This directory contains scripts for building the GOMA Sportsbook iOS project from the command line.

## Available Scripts

### build.sh
A script for building individual schemes with customizable options.

```bash
./build.sh [options]
```

Options:
- `-s, --scheme <scheme>`: Build scheme (required)
- `-c, --configuration <config>`: Build configuration (Debug/Release, default: Debug)
- `-d, --destination <dest>`: Build destination (default: platform=iOS Simulator,name=iPhone 16)
- `-a, --action <action>`: Build action (build/test/clean, default: build)
- `--clean`: Clean build folder before building
- `-v, --verbose`: Show verbose output
- `-h, --help`: Show help message

Available schemes:

Core frameworks and services:
- ServicesProvider
- SharedModels
- DictionaryCoding
- Extensions
- GomaAssets
- Theming

Features and UI components:
- HeaderTextField
- CountrySelectionFeature
- RegisterFlow
- AdresseFrancaise
- NotificationsService

Sports data providers:
- SportRadar PROD
- SportRadar UAT
- GomaSportRadar

Client applications:
- ATP
- Betsson PROD
- Betsson UAT
- Crocobet
- DAZN
- EveryMatrix
- GOMASports

Tests:
- SportsbookTests

### build-all.sh
A script for building all schemes in the correct order.

```bash
./build-all.sh [configuration]
```

The script accepts an optional configuration parameter (Debug/Release). If not provided, it defaults to Debug.

## Examples

Build ServicesProvider in Debug configuration:
```bash
./build.sh --scheme ServicesProvider
```

Build ServicesProvider in Release configuration with verbose output:
```bash
./build.sh --scheme ServicesProvider --configuration Release --verbose
```

Build all schemes in Debug configuration:
```bash
./build-all.sh
```

Build all schemes in Release configuration:
```bash
./build-all.sh Release
```

## Requirements

- Xcode 14.0 or later
- Xcode Command Line Tools
- iOS 13.0 or later deployment target

## Troubleshooting

1. If you encounter build errors:
   - Clean DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData/*`
   - Use the `--clean` flag when building
   - Check the verbose output with `-v` flag

2. If xcodebuild is not found:
   ```bash
   xcode-select --install
   ```

3. For specific scheme build issues:
   - Try building with verbose output
   - Check scheme dependencies
   - Verify scheme configuration in Xcode

## VSCode Integration

You can integrate these build scripts with VSCode tasks by adding the following to your `.vscode/tasks.json`:

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Build All (Debug)",
            "type": "shell",
            "command": "./scripts/build-all.sh",
            "group": {
                "kind": "build",
                "isDefault": true
            }
        },
        {
            "label": "Build All (Release)",
            "type": "shell",
            "command": "./scripts/build-all.sh Release",
            "group": "build"
        },
        {
            "label": "Build ServicesProvider",
            "type": "shell",
            "command": "./scripts/build.sh --scheme ServicesProvider",
            "group": "build"
        },
        {
            "label": "Build SharedModels",
            "type": "shell",
            "command": "./scripts/build.sh --scheme SharedModels",
            "group": "build"
        },
        {
            "label": "Build GOMASports",
            "type": "shell",
            "command": "./scripts/build.sh --scheme GOMASports",
            "group": "build"
        },
        {
            "label": "Clean DerivedData",
            "type": "shell",
            "command": "rm -rf ~/Library/Developer/Xcode/DerivedData/*",
            "group": "build"
        }
    ]
} 