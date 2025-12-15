# Build System Guide

## Quick Build Commands
```bash
# Standard build with LLM-friendly output (use this)
./Scripts/build.py -s "Betsson PROD" --llm-mode

# Build with code signing when needed
./Scripts/build.py -s "Betsson PROD" --llm-mode --enable-code-signing
```

## Available Schemes
1. Primary Scheme:
   - Betsson PROD ( <--- use this one)

2. Other Apps:
   - Betsson UAT
   - GOMASports

3. Core Components:
   - ServicesProvider
   - SharedModels
   - Extensions

4. Tests:
   - SportsbookTests

## Build Output Format
When using `--llm-mode`:
```
BUILD_STATUS: RUNNING
BUILD_STATUS: FAILED/SUCCESS
ERRORS:
  FILE: path/to/file
    Line:123: Error message
```

## Key Build Flags
- `--llm-mode`: Machine-readable output
- `--enable-code-signing`: Enable when needed
- `--clean`: Clean before building