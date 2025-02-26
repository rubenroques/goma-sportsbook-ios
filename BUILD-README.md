# Build System Usage Guide

This document describes the usage of our iOS project build system (`Scripts/build.py`). The system provides sophisticated build, test, and code validation capabilities with special support for automated analysis.

## Basic Build Commands

1. **Standard Build**:
```bash
./Scripts/build.py -s "SCHEME_NAME"
```
Replace SCHEME_NAME with one of the available schemes (e.g., "Betsson PROD", "SportsbookTests", etc.)

2. **LLM-Friendly Mode** (recommended for automated analysis):
```bash
./Scripts/build.py -s "SCHEME_NAME" --llm-mode
```
This mode provides machine-readable output optimized for automated processing.

## Key Features

### 1. Error Detection
- The system provides structured error output including:
  - File paths
  - Line numbers
  - Error messages
  - Error severity (error/warning)

### 2. Build Status Monitoring
When using `--llm-mode`, you'll receive status updates like:
- `BUILD_STATUS: RUNNING`
- `BUILD_STATUS: COMPILING`
- `BUILD_STATUS: FAILED` (with error details)
- `BUILD_STATUS: SUCCESS`

### 3. Performance Optimizations
Available flags:
- `--no-block-provisioning-checks`: Use when code signing is needed
- `--enable-code-signing`: Enable when building for distribution
- `--clean`: Clean build folder before building

## Best Practices for Code Validation

1. **After Making Code Changes**:
   - Always run a build to validate changes
   - Use `--llm-mode` for structured output
   - Parse error messages to identify issues

2. **Error Resolution Workflow**:
   a. Run build with LLM mode
   b. If errors occur, analyze the structured output
   c. Fix reported issues
   d. Rebuild to verify fixes

3. **Command Structure for Validation**:
```bash
./Scripts/build.py -s "SCHEME_NAME" --llm-mode [additional_flags]
```

## Available Schemes
The build system supports various scheme categories:
1. Core frameworks and services
   - ServicesProvider
   - SharedModels
   - DictionaryCoding
   - Extensions
   - GomaAssets
   - Theming

2. Features and UI components
   - HeaderTextField
   - CountrySelectionFeature
   - RegisterFlow
   - AdresseFrancaise
   - NotificationsService

3. Client applications
   - ATP
   - Betsson PROD
   - Betsson UAT
   - Crocobet
   - DAZN
   - EveryMatrix
   - GOMASports
   - SportRadar PROD
   - SportRadar UAT
   - GomaSportRadar

4. Tests
   - SportsbookTests

## Error Output Format
When using `--llm-mode`, errors are formatted as:
```
ERRORS:
  FILE: path/to/file
    Line:123: Error message
```

## Response Protocol
When using this build system, you should:
1. Run builds after suggesting code changes
2. Parse and analyze any error output
3. Propose fixes for any build failures
4. Verify fixes with another build
5. Report success or continue error resolution

## Example Error Resolution Flow
1. Make code changes
2. Run build
3. If errors occur:
   - Analyze error location and message
   - Propose specific fixes
   - Run build again to verify
4. Continue until build succeeds

## Output Levels

The build system supports different output levels through flags:
- `-v, --verbose`: Show all output including commands
- `-w, --warnings-up`: Show warnings and errors (default)
- `-eo, --errors-only`: Show only error messages
- `--llm-mode`: Machine-readable format optimized for automated processing

## Additional Build Options

- `-c, --configuration`: Choose between Debug (default) and Release builds
- `-d, --destination`: Specify build destination (default: "platform=iOS Simulator,name=iPhone 16")
- `-a, --action`: Specify build action (build/test/clean, default: build)
- `--clean`: Clean build folder before building

## Performance Features

1. **Code Signing Optimization**:
   - Disabled by default for faster builds
   - Enable with `--enable-code-signing` when needed for distribution

2. **Provisioning Checks**:
   - Blocked by default to speed up builds
   - Disable blocking with `--no-block-provisioning-checks`

3. **Build System Optimizations**:
   - Uses modern build system
   - Enables parallel target building
   - Skips unavailable actions
   - Hides shell script environment

Remember to use the `--llm-mode` flag for consistent, parseable output that helps you understand and fix build issues systematically.