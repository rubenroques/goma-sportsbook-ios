# Betslip Floating View: Thin and Tall Variants Refactor

## Date
16 October 2025

### Project / Branch
sportsbook-ios / rr/oddsboost_ui

### Goals for this session
- Refactor existing `BetslipFloatingView` into two variants: Thin (compact) and Tall (prominent odds boost)
- Match Figma design specifications exactly for the Tall variant
- Maintain same ViewModel protocol for both variants
- Update all references in app to use renamed Thin view

### Achievements
- [x] Renamed `BetslipFloatingView.swift` → `BetslipFloatingThinView.swift` using `git mv`
- [x] Updated class name from `BetslipFloatingView` → `BetslipFloatingThinView`
- [x] Updated all SwiftUI previews in thin view to use new class name
- [x] Created new `BetslipFloatingTallView.swift` matching Figma design exactly
- [x] Updated `MainTabBarViewController.swift` to use `BetslipFloatingThinView` (lines 31, 105)
- [x] Updated `MatchDetailsTextualViewController.swift` to use `BetslipFloatingThinView` (lines 88-89)

### Issues / Bugs Hit
- [x] **Initial misunderstanding of Figma design layout** - First implementation incorrectly added bottom bar with selection count/odds/open button (should only be in Thin view)
- [x] **Incorrect icon placement** - Initially had icon and title side-by-side in top section; Figma shows icon + text stack in middle section only

### Key Decisions
- **File organization**: Both views live in same `BetslipFloatingView/` folder since they share protocol and data model
- **Shared components**: Both views reuse `ProgressSegmentView` and `updateProgressSegments()` animation logic
- **View model unchanged**: `BetslipFloatingViewModelProtocol` works for both variants without modifications
- **Visibility logic**: Tall view hides completely when `totalEligibleCount = 0` (no odds boost available)

### Architecture Breakdown

#### BetslipFloatingThinView (Existing - Renamed)
**Layout:**
- Circular button state (no tickets)
- Horizontal detailed state (with tickets):
  - Selection count badge
  - Odds capsule
  - Win boost capsule (conditional)
  - Open betslip button
  - Bottom section with CTA + progress segments (conditional)

**Purpose:** Compact always-visible betslip indicator

#### BetslipFloatingTallView (New)
**Layout (matches Figma exactly):**
```
┌─────────────────────────────────────────┐
│ [16px padding all sides]                │
│                                         │
│  You're almost there!  (12px bold ●)   │ ← Section 1: Standalone title
│  [16px gap]                            │
│  ┌────┐  Get a 3% Win Boost (16px B)  │ ← Section 2: Icon + Text Stack
│  │ 🎁 │  by adding 2 more legs to     │   (12px gap between icon & text)
│  └────┘  your betslip (1.2 min odds). │   (0px spacing in text stack)
│  32x32   (12px regular gray)           │
│  [16px gap]                            │
│  ████████ ░░░░░░░░ ░░░░░░░░           │ ← Section 3: Progress (8px, 2px gaps)
│                                         │
└─────────────────────────────────────────┘
```

**Purpose:** Prominent gamification view to encourage adding more legs for odds boost

**Key constraints:**
- Icon: 32x32, top-aligns with heading, bottom-aligns with description
- Text stack spacing: 0px (lines flow naturally)
- Progress segments: `fillEqually` distribution, 2px spacing, 8px height
- Container: 12px corner radius, shadow (offset: 0,2 / radius: 4 / opacity: 0.2)

### Experiments & Notes
- **Figma MCP integration**: Used `mcp__figma-dev-mode-mcp-server__get_design_context` and `get_screenshot` to extract exact specs
- **Progress animation**: Reused wave-effect animation (50ms stagger) from thin view implementation
- **Font sizes confirmed**: Title 12px, Heading 16px, Description 12px (not 14px as initially assumed)
- **Color mapping**: Orange = `highlightPrimary`, White = `textPrimary`, Gray = `textSecondary`

### Useful Files / Links
- [BetslipFloatingThinView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipFloatingView/BetslipFloatingThinView.swift)
- [BetslipFloatingTallView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipFloatingView/BetslipFloatingTallView.swift)
- [BetslipFloatingViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipFloatingView/BetslipFloatingViewModelProtocol.swift)
- [ProgressSegmentView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipFloatingView/ProgressSegmentView.swift)
- [MainTabBarViewController.swift](../../BetssonCameroonApp/App/Screens/MainTabBar/MainTabBarViewController.swift)
- [MatchDetailsTextualViewController.swift](../../BetssonCameroonApp/App/Screens/MatchDetailsTextual/MatchDetailsTextualViewController.swift)
- [Figma Design](https://www.figma.com/design/oGh41UArYBfHuXB2RCSPTC/betsson.cm-Version-1.3--Goma---Copy-?node-id=2208-202980&m=dev)
- [Previous Session: Odds Boost UI Integration](./16-October-2025-odds-boost-ui-integration.md)

### Related Context
- **Odds boost data pipeline already implemented**: `BetslipManager.oddsBoostStairsPublisher` → `BetslipFloatingViewModel.combineLatest` → UI
- **Mock ViewModel works for both**: `MockBetslipFloatingViewModel` provides test data for previews
- **StyleProvider used throughout**: No hardcoded colors, all themed via StyleProvider

### Next Steps
1. **Implement conditional view switching logic** - Determine when to show Thin vs Tall variant based on UX requirements
2. **Add Tall view to demo app** - Create entry in `GomaUIDemo/ComponentsTableViewController`
3. **Test animations in simulator** - Verify progress segment wave effect on real devices
4. **Update documentation** - Add component usage examples to GomaUI README
5. **Consider accessibility** - Add VoiceOver labels for progress segments
6. **Performance test** - Profile view creation/animation with multiple rapid state changes

### Technical Debt / Future Improvements
- [ ] Localize all hardcoded strings (`"You're almost there!"`, `"Get a X% Win Boost"`, etc.)
- [ ] Extract magic numbers to constants (16px padding, 32px icon size, 8px segment height)
- [ ] Consider custom icon asset instead of fallback to `flame.fill` system icon
- [ ] Add unit tests for progress segment diff calculation logic
- [ ] Document which ViewControllers should use Thin vs Tall variant
