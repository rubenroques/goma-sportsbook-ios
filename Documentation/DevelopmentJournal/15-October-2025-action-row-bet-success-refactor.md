## Date
15 October 2025

### Project / Branch
sportsbook-ios / rr/bettingOfferSubscription

### Goals for this session
- Refactor ProfileMenuItemView to generic ActionRowView component
- Remove UIKit dependency from ActionRowItem data model
- Implement unified bet success screen with 3 action rows
- Add native iOS sharing functionality for bet booking codes

### Achievements
- [x] Renamed ProfileMenuItemView → ActionRowView for generic reusability
- [x] Extracted enums to separate files per GomaUI standards (ActionRowItemType, ActionRowAction, ActionRowItem)
- [x] Added customization properties to ActionRowItem (trailingIcon, isTappable)
- [x] Moved backgroundColor from data model to view layer (customBackgroundColor property)
- [x] Updated all GomaUI references (ProfileMenuListView, Mock implementations)
- [x] Updated all BetssonCameroonApp references (ProfileWalletViewModel, ProfileMenuListViewModel, ProfileWalletCoordinator)
- [x] Replaced StatusNotificationView with 3 ActionRowView instances in BetSuccessViewController
- [x] Implemented native UIActivityViewController for bet sharing
- [x] Added betId property flow from bet placement through to success screen

### Issues / Bugs Hit
- [x] ActionRowItem initially imported UIKit with UIColor property (violates data model separation)
- [x] Missing `.custom` case in switch statements after adding new ActionRowAction enum case
- [x] BetPlacedState enum needed to include betId for sharing functionality

### Key Decisions
- **View-level styling**: Moved `backgroundColor: UIColor?` from ActionRowItem to ActionRowView as `customBackgroundColor` property
  - Keeps data model UI-framework agnostic
  - Allows ActionRowItem to be Codable without UIKit dependency
  - Follows proper MVVM separation of concerns

- **Native sharing over custom grid**: Chose UIActivityViewController instead of custom social media button grid
  - iOS automatically filters to installed apps only
  - Better user experience (familiar iOS pattern)
  - Less maintenance burden
  - Works on iPad with proper popover configuration

- **Unified component approach**: Used ActionRowView for all 3 rows in bet success screen
  - Green "Bet Placed" banner (non-tappable, custom background)
  - "Open Betslip Details" button (tappable, chevron icon)
  - "Share your Betslip" button (tappable, share icon)
  - Visual consistency through single component base

- **BetPlacedState enhancement**: Changed from `case success` to `case success(betId: String?)`
  - Enables booking code sharing
  - Maintains optional for graceful handling when betId unavailable
  - Extracted from BetPlacedDetails response in SportsBetslipViewModel

### Experiments & Notes
- ActionRowView now supports 3 customization modes:
  1. Default profile menu style (icon + title + chevron)
  2. Custom trailing icon (share, chevron, any SF Symbol)
  3. Custom background with automatic contrast text colors

- Protocol-driven design allows mock implementations to work perfectly in SwiftUI previews

- BetSuccessViewController now has 3 navigation closures:
  - `onContinueRequested`: Close success modal
  - `onOpenDetails`: Navigate to bet details (placeholder for future implementation)
  - `onShareBetslip`: Present native share sheet with booking code

### Useful Files / Links
**GomaUI Components:**
- [ActionRowView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ActionRowView/ActionRowView.swift)
- [ActionRowItem](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ActionRowView/ActionRowItem.swift)
- [ActionRowItemType](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ActionRowView/ActionRowItemType.swift)
- [ActionRowAction](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ActionRowView/ActionRowAction.swift)
- [ProfileMenuListView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ProfileMenuListView/ProfileMenuListView.swift)

**BetssonCameroonApp:**
- [BetSuccessViewController](../../BetssonCameroonApp/App/Screens/Betslip/BetSuccessScreen/BetSuccessViewController.swift)
- [BetSuccessViewModel](../../BetssonCameroonApp/App/Screens/Betslip/BetSuccessScreen/BetSuccessViewModel.swift)
- [BetslipCoordinator](../../BetssonCameroonApp/App/Coordinators/Screens/BetslipCoordinator.swift)
- [SportsBetslipViewModel](../../BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/SportsBetslipViewModel.swift)

**Documentation:**
- [GomaUI Component Guide](../../Frameworks/GomaUI/CLAUDE.md)
- [MVVM Architecture](../../Documentation/MVVM.md)

### Next Steps
1. Test bet placement flow end-to-end with real betId
2. Implement "Open Betslip Details" navigation to bet history screen
3. Consider adding betslip share image generation (visual card with bet details)
4. Update ActionRowView documentation with new customization examples
5. Add SwiftUI preview showing all ActionRowView customization modes
