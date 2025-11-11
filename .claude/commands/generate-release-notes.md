---
description: "Generate comprehensive release notes from git commits with JIRA enrichment for a specified time period"
arguments:
  - name: "time-period"
    description: "Time period for analysis (e.g., '2 weeks', 'since 2025-01-01', 'last month', '30 days')"
    default: "2 weeks"
disable-model-invocation: false
---

# MISSION

You are tasked with generating professional, stakeholder-ready release notes for the **sportsbook-ios** project covering the **$1** time period.

---

# EXECUTION REQUIREMENTS

## 1. Time Period Interpretation

Parse the user-provided time period: **"$1"**

**Valid formats**:
- Relative: "2 weeks", "last month", "30 days", "1 week"
- Absolute: "since 2025-10-24", "since 2025-01-01"
- Default: "2 weeks" if not specified or invalid

Convert to git-compatible `--since` parameter.

---

## 2. Data Collection Phase

### 2.1 Extract Git Commit History

**Command**:
```bash
git log --since="<PARSED_TIME_PERIOD>" --all --pretty=format:"%H|%an|%ad|%s" --date=short
```

**Requirements**:
- Process ALL commits in the time period
- Parse format: `commit_hash|author|date|subject`
- Track unique authors for attribution
- Count total commits for summary statistics

### 2.2 Extract Project Version and Build Number

**For iOS Project** (BetssonCameroonApp):
```bash
grep -E "MARKETING_VERSION|CURRENT_PROJECT_VERSION" BetssonCameroonApp/BetssonCameroonApp.xcodeproj/project.pbxproj | head -4
```

**Extract**:
- `MARKETING_VERSION` → Version (e.g., "0.1.9")
- `CURRENT_PROJECT_VERSION` → Build (e.g., "1937")

**Fallback**: If not found, use "N/A" for both values

### 2.3 JIRA Key Extraction

**Scan commit messages** for JIRA issue keys matching patterns:
- `SPOR-1234` (uppercase letters, dash, numbers)
- `[PROJ-456]` (in brackets)
- `(TASK-789)` (in parentheses)

**Regex**: `[A-Z]+-\d+`

**Actions**:
- Extract all unique JIRA keys
- Create mapping: `{jira_key: [associated_commits]}`
- Track keys for optional JIRA enrichment

---

## 3. JIRA Enrichment (OPTIONAL)

**Only if MCP JIRA tools are available**:

For each unique JIRA key:
1. Fetch issue details via MCP JIRA integration
2. Extract: title, type (Bug/Story/Task), status, assignee
3. Build URL: `https://[domain].atlassian.net/browse/[KEY]`
4. Cache results to avoid duplicate API calls

**If JIRA unavailable**:
- Proceed with git-only analysis
- Add note in output: "(JIRA enrichment unavailable)"

---

## 4. Intelligent Categorization

**Categorize each commit** using these rules (first match wins):

### Category Definitions

**Features** - New functionality, enhancements
- Keywords: "add", "implement", "create", "new", "feature", "enhance"
- JIRA type: Story, Epic
- Examples: BetBuilder implementation, bonus system

**UI/UX Improvements** - Design changes, user-facing updates
- Keywords: "redesign", "layout", "icon", "animation", "footer", "view"
- File patterns: GomaUI components, assets, XIB files
- Examples: MatchHeaderCompactView redesign, footer component

**Bug Fixes** - Corrections, patches, crash fixes
- Keywords: "fix", "bug", "patch", "correct", "resolve", "crash"
- JIRA type: Bug
- Examples: Multithread crash fix, EventOddsRangeCollection fix

**Backend/API Integration** - Services, endpoints, providers
- Keywords: "API", "endpoint", "integration", "provider", "mapper", "socket"
- File patterns: *Provider.swift, *API.swift, *Connector.swift
- Examples: EveryMatrix betting options API, WAMP endpoints

**Architecture & Refactoring** - Code quality, patterns, performance
- Keywords: "refactor", "optimize", "architecture", "protocol", "MVVM"
- Examples: Banner protocol refactoring, MVVM-C migration

**CI/CD & Infrastructure** - Build systems, deployment, tooling
- Keywords: "CI", "CD", "build", "deploy", "GitHub Actions", "Fastlane"
- File patterns: .yml, .github/, Fastfile
- Examples: macOS-26 upgrade, SPM caching

**Localization & Configuration** - i18n, settings, environment
- Keywords: "localization", "translation", "language", "config"
- File patterns: .strings, .xcstrings, Info.plist
- Examples: Fixed localization issues, language button

**Other** - Everything else
- Merge commits, version bumps, unclear changes

---

## 5. Commit Deduplication and Merging

### Merge Strategy

**Group related commits** when they:
- Reference the same JIRA key
- Modify the same component/files
- Are sequential by same author within 24 hours
- Have >70% subject similarity

**Skip commits** matching:
- "Merge branch", "Merge commit"
- "WIP", "work in progress"
- "Clean up", "cleanup" (unless significant)
- "Trigger test", "test commit"
- Pure whitespace/formatting changes

### Example Merging
```
Input commits:
- "Add bonus coordinator"
- "Bonus coordinator fixes"
- "Update bonus coordinator banking flow"

Merged output:
- "Bonus coordinator with banking flow integration (fixes, flow updates)"
```

---

## 6. Output Format Specification

### Header Format
```markdown
## Feature List - Last <TIME_PERIOD> (<TOTAL_COUNT> items)

**Version**: <VERSION> | **Build**: <BUILD>

---
```

### Category Format
```markdown
### <CATEGORY_NAME> (<COUNT>)
1. [JIRA-KEY] Description (detail1, detail2, detail3)
2. Description without JIRA (detail1, detail2, detail3)
```

### Entry Formatting Rules

**With JIRA enrichment**:
```
1. [SPOR-1234] Title (detail, detail, detail)
```

**Without JIRA**:
```
1. Title (detail, detail, detail)
```

**Line constraints**:
- Title: 5-10 words maximum
- Details in parentheses: 3-5 items, 2-4 words each
- Total line length: <120 characters
- No line breaks within entries

**Detail extraction guidelines**:
- Include specific components affected
- Add technical implementation notes
- Mention related features/dependencies
- Provide context for understanding impact

---

## 7. Ordering and Priority

### Category Order (Most Important First)
1. Features
2. UI/UX Improvements
3. Bug Fixes
4. Backend/API Integration
5. Architecture & Refactoring
6. Localization & Configuration
7. CI/CD & Infrastructure
8. Other

### Items Within Categories
**Sort by**:
1. JIRA priority (if available): Highest → Low
2. Impact scope: Large → Small
3. Recency: Newest → Oldest
4. Alphabetical (tiebreaker)

---

## 8. Quality Control

### Target Count Management

**Target**: 30-40 total items

**If > 40 items**:
- Merge related commits more aggressively
- Remove pure infrastructure items
- Combine sub-tasks under main features
- Prioritize user-facing changes

**If < 30 items**:
- Ungroup some merged commits
- Add more technical detail
- Include infrastructure changes
- Separate large features into components

### Final Checklist
- [ ] All commits accounted for and categorized
- [ ] No duplicate entries
- [ ] Version and build extracted (or "N/A")
- [ ] JIRA keys validated (if MCP available)
- [ ] Each line <120 characters
- [ ] Categories have counts
- [ ] Total count: 30-40 items
- [ ] Consistent formatting throughout
- [ ] No placeholder text

---

## 9. Error Handling

**Git Repository Not Found**:
```
Exit with: "Error: Not a git repository. Run from project root."
```

**No Commits in Period**:
```
Report: "No commits found for '<TIME_PERIOD>'. Try a longer period."
```

**JIRA MCP Unavailable**:
```
Continue with git-only analysis
Add note: "(JIRA enrichment unavailable - install JIRA MCP for enhanced output)"
```

**Version Detection Failed**:
```
Set Version/Build to "N/A"
Continue with release notes generation
```

---

## 10. Example Output

```markdown
## Feature List - Last 2 Weeks (34 items)

**Version**: 0.1.9 | **Build**: 1937

---

### Features (15)
1. [SPOR-6326] XtremPush integration (persist user ID on logout, polling on boot)
2. BetBuilder bet placement (validation, forbidden combinations, API integration)
3. Betslip ticket live odd updates with animations
4. Bonus coordinator with banking flow integration
5. BonusInfoCardView component (granted bonuses, status/expiry/amounts)

### UI/UX Improvements (7)
1. [SPOR-5432] MatchHeaderCompactView redesign (hide/show statistics option)
2. Extended list footer component (partners, regulators, operators, socials)
3. Footer assets (MTN, Orange, Boca, Inter, ECOGRA, EGBA icons)

### Bug Fixes (8)
1. Fixed multithread crash on home/live screens (Combine race conditions)
2. Fixed settings opening link (SettingsBundleHelper implementation)
3. Fixed localization system (migrated xcstrings to strings files)

### Backend/API Integration (5)
1. EveryMatrix betting options V2 API (BetBuilder support)
2. WAMP router BetBuilder endpoints and OddFormat enum
3. EveryMatrix model mappers (bonus, betting options, events)

### Architecture & Refactoring (4)
1. Banner protocol refactoring (callback chain: Banner → VM → Coordinator)
2. BannerType enum migration (concrete types, removed 'any' keyword)

### CI/CD & Infrastructure (3)
1. CI/CD infrastructure (macOS-26, Swift 6, SPM caching, Firebase auth)
```

---

## EXECUTION STRATEGY

1. **Parse** the time period argument
2. **Validate** git repository and time range
3. **Collect** git commits, version info, JIRA keys
4. **Enrich** with JIRA data (if available)
5. **Categorize** all commits intelligently
6. **Merge** related commits and deduplicate
7. **Format** according to specification
8. **Validate** output meets quality criteria
9. **Present** final release notes to user

---

## CONSTRAINTS

**Do NOT**:
- Modify any git history or files
- Skip commits without justification
- Fabricate JIRA keys or data
- Exceed 120 characters per line
- Include merge commits as features
- Use vague descriptions

**Always**:
- Verify data accuracy before output
- Provide technical context
- Link to JIRA when available
- Maintain professional tone
- Focus on value delivered
- Prioritize user-facing changes

---

**BEGIN EXECUTION NOW** for time period: **$1**
