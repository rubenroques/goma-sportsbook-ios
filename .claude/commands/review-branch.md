# Branch Review Command

You are performing a comprehensive code review of a colleague's branch, including technical debt analysis and architecture compliance checks.

**Branch to review:** {{arg1}}

## Execution Steps

Follow these steps systematically. Use TodoWrite to track your progress through all steps.

### 1. Pre-flight Checks
- Verify current branch is clean (no uncommitted changes)
- If not clean, warn the user and stop
- Record the current branch name for restoration later

### 2. Fetch Latest Changes
- Run `git fetch origin` to get the latest branches
- Verify the target branch exists on origin

### 3. Apply Changes for Review
- Run `git merge --no-commit --no-ff origin/{{arg1}}`
- Document any merge conflicts that occur
- List all files that were modified, added, or deleted

### 4. Technical Debt Analysis
- For EACH modified Swift file in BetssonCameroonApp, run the SlashCommand tool with `/check-tech-debt <file-path>`
- Collect all technical debt findings
- Group findings by severity

### 5. Comprehensive Code Review
Analyze the changes for:

**Architecture & Design:**
- MVVM-C pattern compliance
- Protocol-driven design adherence
- Coordinator responsibilities (ViewControllers should NEVER create Coordinators)
- Separation of concerns
- Dependency injection patterns

**Code Quality:**
- Code duplication
- Complex methods that need refactoring
- Naming conventions
- SwiftLint compliance
- Magic numbers or hardcoded values

**GomaUI Usage:**
- Proper use of GomaUI components vs custom UI
- StyleProvider usage (no hardcoded colors/fonts)
- Protocol-based ViewModels with mocks
- Correct component integration patterns

**ServicesProvider Integration:**
- Proper use of provider protocols
- No direct API calls (must use ServicesProvider abstractions)
- Correct error handling
- Proper async/await or Combine usage

**Potential Issues:**
- Race conditions or threading issues
- Memory leaks (retain cycles, missing weak/unowned)
- Force unwraps or unsafe operations
- Missing error handling
- Edge cases not covered
- Performance concerns

**Testing & Documentation:**
- Missing unit tests for new functionality
- Missing mock implementations
- Incomplete or missing documentation
- SwiftUI preview support

**Security & Privacy:**
- Sensitive data handling
- API key or credential exposure
- User data privacy concerns

### 6. Generate Structured Report

Create a comprehensive markdown report with the following structure:

```markdown
# Branch Review Report: {{arg1}}

## Executive Summary
**Branch:** {{arg1}}
**Reviewer:** Claude Code
**Date:** [Current date]
**Files Changed:** X files
**Merge Conflicts:** Yes/No (X files)
**Overall Recommendation:** ✅ Approve / ⚠️ Approve with Comments / 🔴 Request Changes

---

## 🔴 Critical Issues (Must Fix Before Merge)
*Issues that could cause bugs, crashes, security problems, or major architecture violations*

1. [Issue description]
   - **File:** path/to/file.swift:line
   - **Impact:** [Description of impact]
   - **Recommendation:** [How to fix]

---

## 🟡 Important Issues (Should Address)
*Issues that affect code quality, maintainability, or follow architectural patterns*

1. [Issue description]
   - **File:** path/to/file.swift:line
   - **Impact:** [Description of impact]
   - **Recommendation:** [How to fix]

---

## 🟢 Minor Issues (Nice to Have)
*Small improvements, style issues, or optimization opportunities*

1. [Issue description]
   - **File:** path/to/file.swift:line
   - **Recommendation:** [How to fix]

---

## 📊 Technical Debt Analysis
*Findings from /check-tech-debt command*

### By File:
[Group technical debt findings by file]

### Summary:
- Total violations: X
- High priority: X
- Medium priority: X
- Low priority: X

---

## ✨ Positive Highlights
*Good practices, clean code, and well-implemented features*

- [List positive aspects of the code]

---

## 📋 Merge Conflicts
*If any conflicts were detected*

The following files have merge conflicts with your current branch:
1. path/to/file.swift
2. path/to/another.swift

These will need to be resolved during the actual merge.

---

## 🎯 Final Recommendation

[Provide a clear, actionable recommendation with reasoning]

**Next Steps:**
- [ ] [Action item 1]
- [ ] [Action item 2]

---

## 📁 Files Changed

### Modified Files (X):
- path/to/file.swift
- path/to/another.swift

### New Files (X):
- path/to/new/file.swift

### Deleted Files (X):
- path/to/deleted.swift
```

### 7. Cleanup
- Run `git reset --merge` to abort the merge and restore clean state
- Run `git status` to verify the branch is clean
- Confirm to the user that cleanup is complete

## Important Notes

- **DO NOT commit anything** - this is review only
- **Track progress** - use TodoWrite for all steps
- **Be thorough** - this is a production codebase
- **Be specific** - include file paths and line numbers when possible
- **Be constructive** - provide actionable recommendations, not just criticism
- **Prioritize correctly** - critical issues are those that could break functionality or security

## Error Handling

- If merge fails, document the failure and proceed with cleanup
- If /check-tech-debt fails on a file, note it and continue with other files
- If cleanup fails, provide manual cleanup instructions to the user
