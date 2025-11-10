---
description: "Compare release notes between two time periods to show development velocity and feature evolution"
arguments:
  - name: "current-period"
    description: "Current time period (e.g., 'last 2 weeks', 'since 2025-10-24')"
    default: "2 weeks"
  - name: "previous-period"
    description: "Previous time period to compare against (e.g., 'previous 2 weeks', '2 weeks before that')"
    default: "previous 2 weeks"
disable-model-invocation: false
---

# MISSION

Generate a **comparative analysis** of development activity between two time periods for the sportsbook-ios project:
- **Current Period**: $1
- **Previous Period**: $2

This enables stakeholders to understand development velocity, feature priorities, and team productivity trends.

---

# EXECUTION REQUIREMENTS

## 1. Time Period Calculation

### Parse Arguments

**Current Period**: "$1"
- Convert to absolute date range (start_date to today)
- Example: "2 weeks" → 2025-10-24 to 2025-11-07

**Previous Period**: "$2"
- Calculate relative to current period
- "previous 2 weeks" → 2025-10-10 to 2025-10-23
- "2 weeks before that" → (current_start - duration) to current_start

**Validation**:
- Ensure no overlap between periods
- Verify both periods have commits
- Confirm chronological order (previous < current)

---

## 2. Data Collection (Dual Execution)

### For EACH period, collect:

**Git Commits**:
```bash
# Current period
git log --since="<CURRENT_START>" --until="<CURRENT_END>" --all --pretty=format:"%H|%an|%ad|%s" --date=short

# Previous period
git log --since="<PREVIOUS_START>" --until="<PREVIOUS_END>" --all --pretty=format:"%H|%an|%ad|%s" --date=short
```

**Statistics to track**:
- Total commit count
- Unique authors
- Lines added/deleted (from git diff --stat)
- Files changed count
- JIRA issues referenced

**Categorization**:
- Apply same categorization logic as `/release-notes`
- Count items per category for each period

---

## 3. Comparative Metrics

### Calculate Deltas

For each metric, compute:
```
delta = current_value - previous_value
percentage_change = ((current - previous) / previous) * 100
trend = "↑" if delta > 0 else "↓" if delta < 0 else "→"
```

**Key Metrics**:
- Commit velocity (commits/day)
- Feature count
- Bug fix count
- Contributors active
- JIRA issues completed
- Category distribution shifts

---

## 4. Output Format

### Header Section
```markdown
## Release Comparison Analysis

**Current Period**: <CURRENT_RANGE> (<CURRENT_DAYS> days)
**Previous Period**: <PREVIOUS_RANGE> (<PREVIOUS_DAYS> days)

**Generated**: <TIMESTAMP>

---

## 📊 Summary Metrics

| Metric | Current | Previous | Change | Trend |
|--------|---------|----------|--------|-------|
| Total Commits | X | Y | +Z (+W%) | ↑ |
| Features | X | Y | +Z (+W%) | ↑ |
| Bug Fixes | X | Y | -Z (-W%) | ↓ |
| Contributors | X | Y | +Z | ↑ |
| JIRA Issues | X | Y | +Z (+W%) | ↑ |
| Avg Commits/Day | X.Y | A.B | +C.D | ↑ |

---

## 📈 Category Breakdown

### Current Period Distribution
- Features: X items (Y%)
- Bug Fixes: A items (B%)
- UI/UX: C items (D%)
- Backend: E items (F%)
- Infrastructure: G items (H%)

### Previous Period Distribution
- Features: X items (Y%)
- Bug Fixes: A items (B%)
- UI/UX: C items (D%)
- Backend: E items (F%)
- Infrastructure: G items (H%)

### Key Shifts
- ↑ **Features**: Increased by X items (+Y%)
- ↓ **Bug Fixes**: Decreased by A items (-B%)
- → **Infrastructure**: Stable at C items

---

## 🔥 Current Period Highlights

### Top Features (Latest)
1. [JIRA-KEY] Feature description
2. [JIRA-KEY] Feature description
(Top 5-10 items)

### Critical Bug Fixes
1. [JIRA-KEY] Bug fix description
2. [JIRA-KEY] Bug fix description
(Top 3-5 items)

---

## 📅 Previous Period Highlights

### Top Features (Previous)
1. [JIRA-KEY] Feature description
2. [JIRA-KEY] Feature description
(Top 5-10 items)

### Critical Bug Fixes
1. [JIRA-KEY] Bug fix description
(Top 3-5 items)

---

## 👥 Contributor Analysis

### Current Period
| Developer | Commits | Features | Bugs | Main Focus |
|-----------|---------|----------|------|------------|
| Ruben | X | Y | Z | Infrastructure, Features |
| André | A | B | C | Features, UI/UX |
| Claude | D | E | F | Bug Fixes, Refactoring |

### Previous Period
| Developer | Commits | Features | Bugs | Main Focus |
|-----------|---------|----------|------|------------|
| Ruben | X | Y | Z | Features, Backend |
| André | A | B | C | UI/UX, Features |

### Contribution Trends
- **Ruben**: ↑ +15 commits, shifted focus from Features to Infrastructure
- **André**: → Stable ~20 commits, consistent UI/UX focus
- **Claude**: New contributor this period

---

## 🎯 Development Focus Comparison

### Current Period Priorities
1. **Infrastructure** (increased +40%) - CI/CD improvements, tooling
2. **Features** (increased +20%) - BetBuilder, Bonus system
3. **Bug Fixes** (decreased -15%) - Stability improvements working

### Previous Period Priorities
1. **Features** (dominant) - Core functionality build-out
2. **Bug Fixes** (higher) - Post-release stabilization
3. **UI/UX** (moderate) - Design implementation

### Strategic Insights
- Team shifting from **feature velocity** to **infrastructure investment**
- Bug fix reduction suggests **improved code quality**
- JIRA integration increasing (X% to Y%) shows **better process adherence**

---

## 📉 Velocity Trends

### Commit Velocity
- Current: X.Y commits/day
- Previous: A.B commits/day
- Trend: {Increasing/Decreasing/Stable}

**Analysis**: {Context about why velocity changed}

### Feature Delivery Rate
- Current: X features / week
- Previous: Y features / week
- Trend: {Analysis}

### Bug Fix Rate
- Current: X bugs / week
- Previous: Y bugs / week
- Trend: {Analysis - e.g., "Decreasing bug rate suggests stabilization"}

---

## 🔍 Notable Differences

### New Areas of Development (Current Period Only)
- XtremPush integration
- Responsible Gaming components
- Advanced BetBuilder features

### Discontinued/Reduced Areas
- Legacy architecture migration (completed)
- Initial setup tasks (less frequent)

### Consistency Areas (Both Periods)
- GomaUI component development
- MVVM-C architecture adherence
- Continuous CI/CD improvements

---

## 🎓 Recommendations

Based on comparative analysis:

1. **{Recommendation based on trends}**
   - Example: "Maintain current infrastructure focus to reduce technical debt"

2. **{Recommendation based on velocity}**
   - Example: "Bug fix rate trending down - consider allocating resources to new features"

3. **{Recommendation based on distribution}**
   - Example: "JIRA integration improving - enforce key in all commit messages"

---

## 📋 Full Release Notes

### Current Period (Detailed)
{Generate full release notes using /release-notes format for current period}

### Previous Period (Detailed)
{Generate full release notes using /release-notes format for previous period}
```

---

## 5. Analysis Guidelines

### Trend Interpretation

**Velocity Changes**:
- ↑ +50%: "Significant acceleration"
- ↑ +20-50%: "Increased pace"
- ↑ 0-20%: "Slight increase"
- → ±5%: "Stable"
- ↓ 0-20%: "Slight decrease"
- ↓ 20-50%: "Reduced pace"
- ↓ >50%: "Significant slowdown"

**Category Shifts**:
- Increasing Features + Decreasing Bugs = "Stability achieved, focusing on growth"
- Increasing Bugs + Decreasing Features = "Stabilization phase, addressing issues"
- Increasing Infrastructure = "Technical debt paydown / tooling investment"

### Context Awareness

Consider:
- Sprint cycles (velocity may vary by sprint phase)
- Release schedules (pre-release = more bugs, post-release = more features)
- Team changes (new members = learning period)
- Holiday periods (reduced velocity expected)

---

## 6. Visual Indicators

Use emoji/symbols for clarity:
- ↑ Increase
- ↓ Decrease
- → Stable/No change
- 🔥 Hot area (high activity)
- 📈 Trending up
- 📉 Trending down
- ✅ Completed
- 🔄 Ongoing
- ⚠️ Attention needed

---

## 7. JIRA Integration (Optional)

If JIRA MCP available:
- Fetch sprint information for both periods
- Compare sprint velocity (story points if available)
- Track issue completion rates
- Identify blockers or bottlenecks

---

## 8. Error Handling

**Insufficient Data**:
```
If either period has <5 commits:
  Warning: "Limited data for <PERIOD>. Results may not be representative."
```

**Overlapping Periods**:
```
If periods overlap:
  Error: "Time periods overlap. Adjust dates and retry."
```

**No Previous Period Data**:
```
If git history doesn't extend to previous period:
  Use available history, note truncation
```

---

## 9. Performance Optimization

**Parallel Execution**:
- Collect current and previous period data simultaneously
- Use background processes for git operations
- Cache JIRA lookups across both periods

**Execution Time Target**: <45 seconds for typical 2-week comparison

---

## 10. Example Use Cases

**Sprint Retrospective**:
```bash
/release-compare "last 2 weeks" "previous 2 weeks"
```

**Monthly Review**:
```bash
/release-compare "last month" "previous month"
```

**Custom Date Ranges**:
```bash
/release-compare "since 2025-10-24" "2025-10-10 to 2025-10-23"
```

**Quarter Comparison**:
```bash
/release-compare "last 3 months" "previous 3 months"
```

---

## EXECUTION STRATEGY

1. **Parse** both time period arguments
2. **Calculate** absolute date ranges for each period
3. **Validate** no overlap and chronological order
4. **Collect** git data for both periods in parallel
5. **Categorize** commits for each period
6. **Calculate** all comparative metrics and deltas
7. **Analyze** trends and generate insights
8. **Format** comprehensive comparison report
9. **Present** with clear visual indicators and recommendations

---

## CONSTRAINTS

**Do NOT**:
- Compare overlapping time periods
- Make unsupported claims about causation
- Include personal judgments about contributors
- Omit context for significant changes

**Always**:
- Provide numerical backing for trends
- Explain percentage changes clearly
- Note any data limitations
- Maintain objective, professional tone
- Focus on actionable insights

---

**BEGIN COMPARATIVE ANALYSIS NOW**

Current Period: **$1**
Previous Period: **$2**
