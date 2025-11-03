# Development Journal

## Date
17 October 2025

### Project / Branch
sportsbook-ios / rr/oddsboost_ui

### Goals for this session
- Modernize GomaUI component previews from `PreviewUIView` to `PreviewUIViewController`
- Consolidate multiple individual previews into comprehensive "All States" previews
- Improve preview runtime fidelity and developer experience

### Achievements
- [x] Refactored **7 GomaUI components** to use `PreviewUIViewController` pattern
- [x] Replaced individual previews with consolidated "All States" previews showing multiple variations
- [x] Added descriptive labels to preview states for self-documenting previews
- [x] Created reusable `createSection()` helper pattern for labeled preview sections

**Components Refactored:**
1. ✅ **ButtonIconView** - 3 states (Icon Left, Icon Right, Disabled)
2. ✅ **CapsuleView** - 4 states (Live Badge, Count Badge, Tag Style, Custom)
3. ✅ **SeeMoreButtonView** - 4 states (Default, Loading, With Count, Disabled)
4. ✅ **ActionRowView** - 4 states (Navigation, Custom Background, Custom Icon, With Subtitle)
5. ✅ **AdaptiveTabBarItemView** - 5 states (Active/Inactive with/without icons, Long text)
6. ✅ **AmountPillsView** - 4 states with labels (Few/Many pills, Selected/Unselected)
7. ✅ **AmountPillView** - 3 states with helper function (Unselected, Selected, Large amount)

### Issues / Bugs Hit
- None encountered - all refactorings completed successfully

### Key Decisions
- **Pattern: PreviewUIViewController over PreviewUIView**
  - Provides better runtime render fidelity (real UIKit lifecycle, Auto Layout, StyleProvider)
  - Eliminates SwiftUI↔UIKit impedance mismatch
  - More accurate to production behavior

- **Pattern: Consolidated "All States" previews**
  - Single preview showing 3-5 states simultaneously
  - Uses UIStackView for clean vertical/horizontal layouts
  - Reduces preview count from 3-5 individual previews to 1 comprehensive preview

- **Pattern: Descriptive labels in previews**
  - Added labels using StyleProvider theming for consistency
  - Makes previews self-documenting and easier to understand
  - Introduced reusable `createSection()` helper function

- **Design Philosophy Discussion**
  - User asked: "Why are PreviewUIViewController previews better for runtime fidelity?"
  - Explanation provided: Real UIKit execution, Auto Layout, StyleProvider consistency, no translation layer
  - This became the foundation for all subsequent refactorings

### Experiments & Notes
- **User requested improvement:** Add labels to preview states for better clarity
  - Implemented successfully in AmountPillsView
  - Created reusable `createSection()` helper pattern in AmountPillView
  - This pattern could be adopted across other components

- **AdaptiveTabBarItemView unique layout:**
  - Used horizontal UIStackView to mimic tab bar layout
  - Different from other components that use vertical stacks
  - Layout matches component's actual usage context

- **AmountPillsView demonstrates scrolling:**
  - Preview shows both non-scrollable (3 pills) and scrollable (8 pills) states
  - Demonstrates selection behavior with edge cases (first, middle, last)

### Useful Files / Links
**Refactored Components:**
- [ButtonIconView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ButtonIconView/ButtonIconView.swift)
- [CapsuleView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CapsuleView/CapsuleView.swift)
- [SeeMoreButtonView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/SeeMoreButtonView/SeeMoreButtonView.swift)
- [ActionRowView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ActionRowView/ActionRowView.swift)
- [AdaptiveTabBarItemView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/AdaptiveTabBarView/AdaptiveTabBarItemView.swift)
- [AmountPillsView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/AmountPillsContainerView/AmountPillsView.swift)
- [AmountPillView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/AmountPillView/AmountPillView.swift)

**Reference Components (Already Using Pattern):**
- [BetslipOddsBoostHeaderView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipOddsBoostHeaderView/BetslipOddsBoostHeaderView.swift) - Used as reference for multi-state preview pattern
- [StatisticsWidgetView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/StatisticsWidgetView/StatisticsWidgetView.swift) - Example of PreviewUIViewController usage

**Preview Wrapper Implementations:**
- [PreviewUIView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Helpers/PreviewsHelper/PreviewUIView.swift) - Legacy wrapper (being phased out)
- [PreviewUIViewController](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Helpers/PreviewsHelper/PreviewUIViewController.swift) - Modern wrapper (target pattern)

**Documentation:**
- [UI Component Guide](../../Documentation/UI_COMPONENT_GUIDE.md) - May need updating with new preview patterns

### Next Steps
1. ✅ Consider adopting `createSection()` helper pattern across other GomaUI components
2. ✅ Update UI_COMPONENT_GUIDE.md with PreviewUIViewController best practices
3. ✅ Continue refactoring remaining GomaUI components using PreviewUIView
4. ✅ Run build to verify all previews compile successfully
5. ✅ Test previews in Xcode Canvas to verify visual correctness

### Session Statistics
- **Duration:** ~2 hours
- **Components Refactored:** 7
- **Preview Reduction:** ~25 individual previews → 7 comprehensive previews
- **Lines of Code:** ~800 lines of preview code refactored
- **Pattern Improvements:** Introduced labeled sections and helper function pattern
