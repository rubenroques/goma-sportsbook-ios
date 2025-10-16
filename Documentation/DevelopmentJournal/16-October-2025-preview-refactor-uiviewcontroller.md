## Date
16 October 2025

### Project / Branch
sportsbook-ios / rr/oddsboost_ui

### Goals for this session
- Refactor GomaUI component previews from `PreviewUIView` to `PreviewUIViewController`
- Target 4 betslip-related components: BetslipHeaderView, BetslipTypeTabItemView, BetslipTypeSelectorView, BetslipTicketView
- Improve preview rendering fidelity to match actual runtime behavior

### Achievements
- [x] Refactored BetslipHeaderView (2 previews: "Not Logged In", "Logged In")
- [x] Refactored BetslipTypeTabItemView (4 previews: selected/unselected states for Sports/Virtuals)
- [x] Refactored BetslipTypeSelectorView (2 previews: Sports/Virtuals selected states)
- [x] Refactored BetslipTicketView (4 previews: Typical, Increased Odds, Decreased Odds, Disabled)
- [x] Total of 12 previews successfully migrated to PreviewUIViewController pattern

### Issues / Bugs Hit
None encountered during refactoring - straightforward pattern application

### Key Decisions
- **Pattern consistency**: Used BetslipFloatingView as reference implementation for PreviewUIViewController pattern
- **Layout strategy**: Applied Auto Layout constraints instead of SwiftUI `.frame()` modifiers
  - Components use leading/trailing constraints with 20pt padding
  - Vertical positioning varies by component (center vs top/bottom anchoring)
  - Explicit height constraints preserve original frame heights
- **Background color**: Changed from `StyleProvider.Color.backgroundPrimary` to `UIColor.gray` (user modification in BetslipHeaderView)
- **Constraint positioning**: Adjusted some components to use `topAnchor` instead of `bottomAnchor` for more natural preview layout

### Experiments & Notes
**Why PreviewUIViewController is superior to PreviewUIView:**

1. **Actual UIKit code execution** - Same Auto Layout constraint solving, intrinsic content size calculations, and view lifecycle methods as runtime
2. **StyleProvider consistency** - Theming system works identically without mocking or approximation
3. **Protocol-driven ViewModels** - Uses same ViewModel initialization path (only difference: Mock vs Production)
4. **Layout engine parity** - Auto Layout constraints resolve exactly as they would in production
5. **No impedance mismatch** - Eliminates SwiftUI ↔ UIKit translation layer issues (sizing quirks, trait collection propagation differences)

**Practical benefit**: "What you see IS what you get" - no surprises when moving from preview to simulator/device

### Useful Files / Links
- [BetslipHeaderView](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipHeaderView/BetslipHeaderView.swift) - Auth state toggling (logged in/out)
- [BetslipTypeTabItemView](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipTypeTabItemView/BetslipTypeTabItemView.swift) - Individual tab item with selection states
- [BetslipTypeSelectorView](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipTypeSelectorView/BetslipTypeSelectorView.swift) - Tab selector container
- [BetslipTicketView](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipTicketView/BetslipTicketView.swift) - Ticket card with odds change indicators
- [BetslipFloatingView](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipFloatingView/BetslipFloatingView.swift) - Reference implementation pattern
- [UI Component Guide](../Documentation/UI_COMPONENT_GUIDE.md) - Should be updated to reflect PreviewUIViewController best practice

### Next Steps
1. Test all refactored previews in Xcode to verify rendering matches runtime
2. Consider updating UI_COMPONENT_GUIDE.md to mandate PreviewUIViewController pattern for all new components
3. Plan systematic migration of remaining GomaUI components still using PreviewUIView (50+ components in library)
4. Document PreviewUIViewController pattern benefits in component development guidelines
