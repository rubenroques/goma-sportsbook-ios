# Technical Debt Documentation

This folder contains detailed analysis reports of architectural violations, anti-patterns, and technical debt found in the codebase.

## Purpose

Technical debt reports provide:
- **Comprehensive analysis** of architectural violations
- **Severity ratings** (Critical, High, Medium, Low)
- **Detailed refactoring plans** with prioritized phases
- **Impact assessment** on testing, maintenance, and runtime
- **Code references** with exact line numbers

## How to Use

1. **Review Reports**: Start with reports marked [CRITICAL] in `TODO_TASKS.md`
2. **Follow Refactoring Plans**: Each report includes phased approach (Phase 1, 2, 3)
3. **Reference During Code Review**: Use reports to prevent similar violations
4. **Track Progress**: Update `TODO_TASKS.md` when issues are resolved

## Reports

### Active Technical Debt

- **[sports-betslip-mvvm-violations.md](sports-betslip-mvvm-violations.md)** - SportsBetslipViewController MVVM violations (11 issues, 3 critical)

## Guidelines

**When adding new reports:**
- Use descriptive filenames: `{component}-{issue-type}.md`
- Include severity ratings: 🔴 Critical, 🟠 High, 🟡 Medium, 🟢 Low
- Provide specific line numbers and code examples
- Create actionable refactoring plans
- Add entry to `TODO_TASKS.md` in root

**When resolving debt:**
- Archive report to `Documentation/Archive/TechnicalDebt/`
- Remove TODO checkbox from `TODO_TASKS.md`
- Document resolution in commit message
