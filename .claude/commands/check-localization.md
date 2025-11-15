---
description: Check and fix missing localization in production code (skips previews/tests)
model: sonnet
argument-hint: <file-paths> (optional - defaults to git status modified files)
---

# Check Localization Command

You are an expert iOS localization specialist. Your task is to check Swift files for hardcoded user-facing strings and ensure they are properly localized using `LocalizationProvider.string()`.

## Input Processing

If the user provides file paths as arguments, use those files. Otherwise, check all modified files from `git status`.

## Core Principles

1. **Production Code Only**: Only localize strings in production code (classes, structs, enums, extensions)
2. **Skip Preview/Test Code**: Ignore strings in:
   - SwiftUI `#Preview` blocks
   - `#if DEBUG` blocks
   - Classes/functions with "Preview", "Mock", "Test", or "Demo" in their names
   - Any code inside `@available(iOS 17.0, *) #Preview` blocks
3. **Search by String Value First**: Before creating new keys, search existing .strings files by the ACTUAL STRING VALUE to find if it's already localized under a different key name
4. **Follow Existing Patterns**: Use the project's established localization key naming conventions

## Step-by-Step Process

### Step 1: Identify Files to Check

```bash
# If no arguments provided, get modified Swift files from git
git status --short | grep '\.swift$' | awk '{print $2}'
```

### Step 2: For Each File

1. **Read the file** and identify hardcoded strings
2. **Skip non-production code sections**:
   - Lines inside `#Preview` blocks
   - Lines inside `#if DEBUG` blocks
   - Classes/methods with Preview/Mock/Test/Demo in names
3. **Identify hardcoded user-facing strings**:
   - String literals assigned to UI properties: `label.text = "..."`
   - Button titles: `.setTitle("...", for:)`
   - Placeholder text: `.placeholder = "..."`
   - Alert/error messages
   - Any string that users will see in the UI

### Step 3: Check Existing Localization Keys

**CRITICAL**: Search by STRING VALUE, not by key name!

For each hardcoded string found (e.g., `"Add Selection"`):

1. **Search for the actual string value** in localization files:
   ```bash
   # Search for exact string value
   grep '= "Add Selection"' BetssonCameroonApp/App/Resources/Language/en.lproj/Localizable.strings

   # Also try case-insensitive search for variations
   grep -i 'add.*selection' BetssonCameroonApp/App/Resources/Language/en.lproj/Localizable.strings

   # if not found
   # try similar values, values that clearly mean the same and wore simple written in other way
   ```

2. **If string value is found**: Extract the existing key name and use it
   - Example result: `"button_add_selection" = "Add Selection";`
   - Use: `LocalizationProvider.string("button_add_selection")`

3. **If string value not found**: Proceed to Step 4 to create new key

**Example:**
```swift
// Found in code: label.text = "Your Selection"
// Search: grep '= "Your Selection"' en.lproj/Localizable.strings
// Found: "your_selection" = "Your Selection";
// Use existing key: label.text = LocalizationProvider.string("your_selection")
```

### Step 4: Create New Localization Keys

For new strings that need localization:

1. **Generate appropriate key name** following project conventions:
   - Use snake_case
   - Be descriptive but concise
   - Group related keys with common prefixes
   - Examples: `betslip_add_selection`, `odds_boost_activated`, `error_invalid_selection`

2. **Add to English localization file** (`en.lproj/Localizable.strings`):
   ```
   "generated_key" = "Original English Text";
   ```

3. **Add to French localization file** (`fr.lproj/Localizable.strings`):
   ```
   "generated_key" = "[FR] Original English Text";
   ```
   *(Prefix with [FR] to indicate translation needed)*

### Step 5: Update Production Code

Replace hardcoded strings with localized versions:

**Before:**
```swift
label.text = "Your Selection"
```

**After:**
```swift
label.text = LocalizationProvider.string("your_selection")
```

### Step 6: Report Changes

Provide a comprehensive summary:

1. **Files Checked**: List of all files analyzed
2. **Hardcoded Strings Found**: Count and locations
3. **Preview/Test Strings Skipped**: Count (for transparency)
4. **Existing Keys Reused**: List with file:line references
5. **New Keys Created**: List with file:line references
6. **Code Updated**: Files modified with change counts
7. **Action Required**: List keys that need French translation (marked with [FR])

## Localization File Paths

Ussually called Localizable.strings, in each language folder, in the workspace/project the current chat is happening.

## Important Rules

1. **Never modify preview/test code** - these can have hardcoded strings
2. **Always search by STRING VALUE first** to find existing keys
3. **Follow alphabetical order** when adding keys to .strings files
4. **Use descriptive key names** that indicate purpose
5. **Handle string interpolation**: For strings with variables, use placeholders:
   - Original: `"Add \(count) more selections"`
   - Key value: `"Add {count} more selections"`
   - Usage: `.replacingOccurrences(of: "{count}", with: "\(count)")`

## String Pattern Detection

Identify these patterns as user-facing strings:

```swift
// Direct assignments
label.text = "Hardcoded"
textField.placeholder = "Enter value"
button.setTitle("Click Me", for: .normal)

// String properties
let title = "Page Title"
let message = "Error occurred"

// Alert/error messages
UIAlertController(title: "Alert", message: "Something happened", ...)
```

**Do NOT localize:**
- API keys or identifiers
- Debug/log messages
- Asset names or resource identifiers
- Technical strings not shown to users
- Strings in preview/test code

## Output Format

Provide a clear, structured report:

```markdown
## Localization Check Results

### Files Analyzed
- File1.swift
- File2.swift

### Production Code Findings
- **Total hardcoded strings**: X
- **Already localized**: Y
- **Existing keys reused**: Z
- **New localizations needed**: W

### Changes Made

#### Existing Keys Reused
1. `existing_key` for "Some Text" (File.swift:123)

#### New Localization Keys Added
1. `new_key` = "English Text" (File.swift:456)

#### Code Updated
- File.swift: 3 strings localized
- AnotherFile.swift: 2 strings localized

### Preview/Test Code (Skipped)
- X hardcoded strings in preview code (left unchanged)

### Action Required
French translations needed for:
- `new_key`

(These have been marked with [FR] prefix in fr.lproj/Localizable.strings)
```

## Begin Analysis

Start by identifying the files to check, then proceed through each step systematically. Remember to search by STRING VALUE, not key names!
