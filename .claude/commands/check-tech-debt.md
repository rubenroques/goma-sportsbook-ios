---
description: Analyze technical debt and MVVM-C violations in iOS files
argument-hint: <file-path>
allowed-tools: Read, Grep, Glob, Task
model: claude-3-5-sonnet-20241022
---

# Technical Debt Analysis Task

Analyze the file at **$ARGUMENTS** for architectural violations, MVVM-C anti-patterns, and iOS best practice violations.

## Analysis Scope

### 1. **Discover Related Files**
For the given file, automatically discover and read related files:
- If ViewController → find ViewModel, ViewModelProtocol, Coordinator
- If ViewModel → find ViewModelProtocol, Mock implementations, ViewController
- If View/Cell → find ViewModel, protocol, related components
- Search for associated test files

### 2. **MVVM-C Architectural Violations** (CRITICAL)

Check for these fundamental violations:

**ViewController Layer:**
- ✗ ViewControllers creating ViewModels (should be injected)
- ✗ ViewControllers creating Coordinators (parent coordinator's job)
- ✗ Business logic in ViewController (formatting, calculations, transformations)
- ✗ Direct property access instead of observing publishers
- ✗ UI logic in ViewModel callbacks
- ✗ Network calls or data persistence in ViewController

**ViewModel Layer:**
- ✗ Using Mock ViewModels in production code (MockXXX should be test/preview only)
- ✗ ViewModel importing UIKit (except for types like UIImage)
- ✗ ViewModel creating child ViewModels without protocol abstraction
- ✗ Mutable child ViewModels in protocols (`{ get set }` instead of `{ get }`)
- ✗ Exposing `CurrentValueSubject` instead of `AnyPublisher`
- ✗ Type casting from protocol to concrete implementation
- ✗ Callbacks instead of Combine publishers (architectural inconsistency)

**Protocol Violations:**
- ✗ App-specific ViewModels using protocol pattern (should be GomaUI only)
- ✗ Incomplete protocol contracts (missing methods that require type casting)
- ✗ Protocols with implementation-specific methods
- ✗ `{ get set }` on properties that should be `{ get }` only

**Coordinator Violations:**
- ✗ ViewControllers performing navigation (should delegate to Coordinator)
- ✗ ViewModels knowing about navigation flow
- ✗ Missing Coordinator for complex flows

### 3. **iOS Code Quality Issues** (LOW LEVEL OF CARE)

**Naming Conventions:**
- ✗ Non-descriptive variable names (`data`, `temp`, `x`, `vm`)
- ✗ Inconsistent naming patterns (camelCase vs snake_case)
- ✗ Abbreviations without clarity (`vc`, `vm`, `btn` vs `viewController`, `viewModel`, `button`)
- ✗ Generic names for specific purposes (`manager`, `handler`, `helper`)
- ✗ Naming not following Swift API Design Guidelines

**Formatting & Style:**
- ✗ Inconsistent indentation or spacing
- ✗ Missing MARK comments for organization
- ✗ Long methods (>50 lines) without clear separation
- ✗ Magic numbers without constants
- ✗ Hardcoded strings (should use localization or constants)
- ✗ Inconsistent access control (`private`, `public`, `internal`)
- ✗ Force unwrapping (`!`) without safety checks

**Best Practices:**
- ✗ `print()` statements in production (should use proper logging)
- ✗ Force try/unwrap without error handling
- ✗ Retain cycles (missing `[weak self]` or `[unowned self]`)
- ✗ Expensive operations on main thread
- ✗ DateFormatter/NumberFormatter created repeatedly (should cache)
- ✗ Optional chaining chains (`.?.?.?` indicates unclear data flow)
- ✗ TODO/FIXME comments without tracking (should be in TODO_TASKS.md)

**GomaUI Integration:**
- ✗ Custom UI instead of GomaUI components
- ✗ Not using StyleProvider for colors/fonts
- ✗ Missing SwiftUI previews for components
- ✗ Hardcoded UI values instead of theme constants

### 4. **Data Flow & Architecture:**
- ✗ Direct `Environment` dependency (should use protocol)
- ✗ Service calls from ViewController (should be in ViewModel/Coordinator)
- ✗ Model transformation in View layer
- ✗ State management outside ViewModel
- ✗ Utility functions in wrong layer (should be extensions/services)

## Output Format

Generate a comprehensive Markdown report in `Documentation/TechnicalDebt/` with:

### Report Structure:
```
# [ComponentName] Technical Debt Analysis
**Date:** [Current Date]
**Status:** 🔴/🟠/🟡 based on severity

## Executive Summary
- Total violations found
- Severity breakdown (Critical/High/Medium/Low)
- Overall assessment

## 🔴 CRITICAL VIOLATIONS
[List with file:line references, code examples, expected pattern, impact]

## 🟠 HIGH SEVERITY VIOLATIONS
[List with details]

## 🟡 MEDIUM SEVERITY VIOLATIONS
[List with details]

## 🟢 POSITIVE OBSERVATIONS
[Good patterns found]

## RECOMMENDED REFACTORING PRIORITY
### Phase 1: Critical Fixes (Must Do)
### Phase 2: Architecture Consistency (Should Do)
### Phase 3: Quality Improvements (Nice to Have)

## FILES ANALYZED
[List all files read]
```

### Add Entry to TODO_TASKS.md:

After creating the report, add a task to `TODO_TASKS.md` under "Refactors needed":

```markdown
- [ ] **[SEVERITY] Fix [ComponentName] Technical Debt** - [Brief summary]. **See detailed report:** `Documentation/TechnicalDebt/[filename].md`
  - CRITICAL #1: [Brief description]
  - CRITICAL #2: [Brief description]
  - Impact: [Summary]
  - Priority: [Guidance]
```

## Execution Instructions

1. **Read the target file** at $ARGUMENTS
2. **Discover related files** using Grep/Glob:
   - ViewModelProtocol files
   - ViewModel implementations
   - Mock implementations
   - Associated ViewControllers/Views
   - Coordinators if present
3. **Read all related files** in parallel
4. **Perform comprehensive analysis** following all checks above
5. **Generate detailed report** in `Documentation/TechnicalDebt/`
6. **Add TODO entry** with link to report
7. **Present summary** to user with key findings and priority

## Reference Documents

Use these project guidelines for context:
- `CLAUDE.md` - Project architecture and MVVM-C patterns
- `Documentation/MVVM.md` - MVVM architecture details
- `Frameworks/GomaUI/CLAUDE.md` - GomaUI component patterns
- `TODO_TASKS.md` - Existing technical debt tracking

## Important Notes

- Focus on **actionable violations** with specific line numbers
- Include **impact assessment** for each violation
- Be **honest and critical** - this is for improving code quality
- Reference the **exact patterns** from CLAUDE.md and MVVM.md
- Consider **testing implications** of architectural violations
