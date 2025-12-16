## Date
15 December 2025

### Project / Branch
sportsbook-ios / main (planning session - no code changes)

### Goals for this session
- Analyze BetssonFrance Legacy codebase UI components
- Compare with existing GomaUI components to identify gaps
- Generate comprehensive Jira tickets for migration to BetssonFrance V2
- Create YAML file for automated Jira issue creation

### Achievements
- [x] Explored BetssonFrance Legacy worktree (`../betssonfrance-git-worktree`) - identified 100+ UI components
- [x] Categorized legacy components into 3 feature areas: Match/Event Cards, Betting/Betslip/MyBets, Filters/Forms/Registration
- [x] Analyzed GomaUI package - found 138+ existing components that can be reused
- [x] Created 44 Jira tickets for new GomaUI components needed for migration
- [x] Generated YAML file for Jira bulk import: `/Users/rroques/Desktop/Goma/Tools/JiraCreate/betsson_france_v2_migration.yaml`
- [x] Created comprehensive markdown documentation: `Documentation/BetssonFranceV2-Migration-JiraTickets.md`

### Issues / Bugs Hit
- [x] Initially included ViewController-level components (BetSubmissionSuccessView, QuickBetCardView) - these should NOT be GomaUI components
- [x] Fixed by removing QuickBetCardView/QuickBetSuccessView tickets and simplifying BetSubmissionSuccessView to BetSuccessHeaderView
- [x] FilterBadgeView had fake legacy reference (FilterCountView) - corrected to N/A

### Key Decisions
- **GomaUI is for reusable UI components only** - not ViewControllers with business logic
- Renamed `CashbackTooltipView` to `InfoTooltipDialogView` for reusability across cashback AND spin wheel tooltips
- Labels standardized to `[ios, BF, BF-V2]` for all migration tickets
- Complexity mapped to story points: S=1, M=3, L=5, XL=8

### Experiments & Notes
- Used 3 parallel Opus agents to analyze different feature areas simultaneously
- Legacy analysis revealed massive ViewControllers (QuickBetViewController: 1072 lines, BetSubmissionSuccessViewController: 1072 lines) - these contain business logic, not reusable UI
- Many legacy components already have GomaUI equivalents (OutcomeItemView, AmountPillView, BorderedTextFieldView, etc.)

### Useful Files / Links
- [YAML for Jira Import](/Users/rroques/Desktop/Goma/Tools/JiraCreate/betsson_france_v2_migration.yaml)
- [Migration Tickets Documentation](../BetssonFranceV2-Migration-JiraTickets.md)
- [Jira Create Tool](/Users/rroques/Desktop/Goma/Tools/JiraCreate/create_jira_issues.py)
- [BetssonFrance Legacy Worktree](../../../betssonfrance-git-worktree)
- [GomaUI Package](../../Frameworks/GomaUI/)

### Ticket Summary by Priority

| Priority | Count | Description |
|----------|-------|-------------|
| P1 | 22 | Critical for launch |
| P2 | 14 | Important for feature parity |
| P3 | 8 | Nice to have |

### Ticket Summary by Feature Area

| Area | Count |
|------|-------|
| Match/Event Cards | 13 |
| Betting/Betslip/MyBets | 14 |
| Filters/Forms/Registration | 17 |

### Next Steps
1. Run Jira import: `python create_jira_issues.py betsson_france_v2_migration.yaml --dry-run` to verify
2. Execute actual import: `python create_jira_issues.py betsson_france_v2_migration.yaml`
3. Prioritize P1 tickets for Sprint 1
4. Start implementation with foundation components (CheckboxView, RadioButtonView, etc.)
