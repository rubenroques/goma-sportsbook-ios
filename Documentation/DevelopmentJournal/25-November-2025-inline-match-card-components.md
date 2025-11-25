# Development Journal - Inline Match Card Components

## Date
25 November 2025

### Project / Branch
sportsbook-ios / rr/boot_performance

### Goals for this session
- Create 4 new GomaUI components for compact inline match card design
- Replace TallOddsMatchCardView with more compact InlineMatchCardView
- Follow MVVM + Combine + Protocol architecture
- Make all mocks internal to prevent production usage
- Add comprehensive previews similar to ScoreView component

### Achievements
- [x] Created InlineScoreView - compact inline score display for live events
  - Horizontal layout with separator support
  - Supports tennis (sets + game), football (single score), basketball (quarters)
  - Bold font for .bothHighlight mode, regular/light for other modes
- [x] Created CompactMatchHeaderView - header with date/time or LIVE badge
  - Pre-live mode: date/time text
  - Live mode: LIVE badge + game status
  - Icons row + market count (pattern from MarketInfoLineView)
- [x] Created CompactOutcomesLineView - single row of 2-3 outcomes
  - Supports .double (2-way) and .triple (3-way) outcome layouts
  - No market name pill (simpler than MarketOutcomesLineView)
  - Reuses OutcomeItemView for individual outcomes
- [x] Created InlineMatchCardView - main composite component
  - Combines header, participants, score, and outcomes
  - Protocol-driven with dual-access pattern (current* + *Publisher)
  - Supports configureImmediately() for UITableView sizing
- [x] Created InlineMatchCardTableViewCell - UITableView wrapper
  - Container view with 13pt horizontal margins
  - Corner radius handling for grouped cells (first/middle/last/single)
  - Full UITableView preview with multiple states
- [x] Made all new mocks `internal` (not `public`) to prevent production misuse
- [x] Added comprehensive previews to InlineScoreColumnView
  - Highlighting modes section
  - Sport-specific examples (tennis, football, basketball)
  - Edge cases (zero scores, large numbers, special notation)
- [x] Added comprehensive previews to InlineScoreView
  - Tennis examples (live match, advantage, early set)
  - Football examples (live, high scoring, draw)
  - Basketball examples (live with quarters, tied, early game)
  - Visibility & edge cases
- [x] Added horizontal spacing to InlineScoreView separator (2px on each side)

### Issues / Bugs Hit
- [x] Initially used `.medium` font for scores - changed to `.light` for non-highlighted and `.bold` for highlighted
- [x] Separator was touching score columns - wrapped in container with 2px spacing

### Key Decisions
- **Mock visibility**: Changed all new mocks from `public` to `internal`
  - Prevents accidental usage in production apps (BetssonCameroonApp)
  - Still works for SwiftUI previews within GomaUI package
  - Trade-off: Won't work in GomaUIDemo (separate target) without being public
- **Font weight strategy**: Only `.bothHighlight` mode uses bold font
  - `.bothHighlight` → `.bold` (current/active scores: football match, tennis current game)
  - `.winnerLoser` → `.light` (completed sets/periods)
  - `.noHighlight` → `.light` (neutral informational scores)
- **Separator spacing**: Wrapped 1px line in container with 2px margins
  - Total width: 5px (2px + 1px + 2px)
  - Improves visual separation without cluttering
- **Preview detail level**: Matched ScoreView's comprehensive preview style
  - Section headers for organization
  - Title + description for each example
  - Multiple sport scenarios and edge cases

### Experiments & Notes
- Compared with existing ScoreView component for patterns
  - ScoreView always uses `.bold` font (for vertical display)
  - InlineScoreView uses variable font weight (more compact, less emphasis)
- InlineScoreColumnView highlighting modes:
  - `.winnerLoser`: Compare scores to show winner in primary, loser dimmed
  - `.bothHighlight`: Both scores in highlight color (orange) with bold font
  - `.noHighlight`: Both scores in primary color, neutral styling

### Useful Files / Links
- [ScoreView](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ScoreView/ScoreView.swift) - Reference for score display patterns
- [ScoreViewModelProtocol](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ScoreView/ScoreViewModelProtocol.swift) - ScoreDisplayData model
- [TallOddsMatchCardView](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TallOddsMatchCardView/) - Original component being replaced
- [TallOddsMatchCardTableViewCell](BetssonCameroonApp/App/Screens/NextUpEvents/TallOddsMatchCardTableViewCell.swift) - Cell wrapper pattern
- [MarketInfoLineView](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MarketInfoLineView/) - Icons + market count pattern
- [OutcomeItemView](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/OutcomeItemView/) - Individual outcome button
- [Plan File](~/.claude/plans/bright-rolling-bengio.md) - Original implementation plan (258 lines)

### Component Architecture

**Component Hierarchy:**
```
InlineMatchCardView (composite)
├── CompactMatchHeaderView (header)
│   ├── Left: Date/time OR LIVE badge + status
│   └── Right: Icons row + market count
└── ContentRow (horizontal)
    ├── Left: Participants + InlineScoreView
    │   ├── Home participant label
    │   ├── Away participant label
    │   └── InlineScoreView (visible only when live)
    │       └── InlineScoreColumnView (1+ columns)
    └── Right: CompactOutcomesLineView
        └── OutcomeItemView (2-3 outcomes)
```

**Files Created:**
- `InlineScoreView/InlineScoreViewModelProtocol.swift`
- `InlineScoreView/InlineScoreView.swift`
- `InlineScoreView/InlineScoreColumnView.swift`
- `InlineScoreView/MockInlineScoreViewModel.swift`
- `InlineScoreView/Documentation/README.md`
- `CompactMatchHeaderView/CompactMatchHeaderViewModelProtocol.swift`
- `CompactMatchHeaderView/CompactMatchHeaderView.swift`
- `CompactMatchHeaderView/MockCompactMatchHeaderViewModel.swift`
- `CompactMatchHeaderView/Documentation/README.md`
- `CompactOutcomesLineView/CompactOutcomesLineViewModelProtocol.swift`
- `CompactOutcomesLineView/CompactOutcomesLineView.swift`
- `CompactOutcomesLineView/MockCompactOutcomesLineViewModel.swift`
- `CompactOutcomesLineView/Documentation/README.md`
- `InlineMatchCardView/InlineMatchCardViewModelProtocol.swift`
- `InlineMatchCardView/InlineMatchCardView.swift`
- `InlineMatchCardView/MockInlineMatchCardViewModel.swift`
- `InlineMatchCardView/InlineMatchCardTableViewCell.swift`
- `InlineMatchCardView/Documentation/README.md`

### Next Steps
1. Build GomaUI scheme to verify all components compile correctly
2. Add components to GomaUIDemo gallery for interactive testing
3. Integration in BetssonCameroonApp:
   - Replace TallOddsMatchCardTableViewCell with InlineMatchCardTableViewCell
   - Create production view model factories (not mocks)
   - Add betslip synchronization (like TallOddsMatchCardTableViewCell has)
4. Consider adding fontWeight parameter to InlineScoreColumnData if more granular control needed
5. Test in real app with live data to verify all highlighting modes work as expected
