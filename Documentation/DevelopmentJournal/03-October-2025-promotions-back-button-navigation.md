## Date
03 October 2025

### Project / Branch
sportsbook-ios / rr/bettingOfferSubscription

### Goals for this session
- Fix back button UX in PromotionsViewController to match MatchDetailsTextualViewController
- Ensure proper MVVM-C navigation pattern with coordinator-configured callbacks
- Maintain consistency in TopBarContainerController usage across coordinators

### Achievements
- [x] Refactored back button from separate UIButton + UILabel to container-based approach
- [x] Created backContainerView with backIconImageView and backLabel for larger tap area
- [x] Implemented UITapGestureRecognizer on container for entire area tappability
- [x] Updated PromotionsViewModel to use `onNavigateBack` closure pattern (matches MatchDetailsTextualViewModel)
- [x] Fixed MainTabBarCoordinator to configure `onNavigateBack` callback
- [x] Fixed ProfileWalletCoordinator to wrap PromotionsViewController in TopBarContainerController
- [x] Ensured navigation responsibility belongs to coordinator, not view controller

### Issues / Bugs Hit
- [x] Initial implementation had only tiny arrow tappable, label did nothing
- [x] PromotionsViewModel had wrong method name (`didTapBack` instead of `navigateBack`)
- [x] PromotionsViewModel used `onDismiss` instead of `onNavigateBack` closure
- [x] ProfileWalletCoordinator was pushing raw PromotionsViewController without TopBarContainerController wrapper

### Key Decisions
- **Container-based back button**: Used UIView container with tap gesture instead of oversized UIButton covering multiple elements
  - Cleaner architecture, matches GomaUI MatchDateNavigationBarView pattern
  - backContainerView contains backIconImageView + backLabel (PromotionsViewController.swift:18-20)
  - UITapGestureRecognizer makes entire area tappable (line 76-77)

- **Standardized closure naming**: Changed from `onDismiss` to `onNavigateBack` for consistency across view models
  - Matches MatchDetailsTextualViewModel pattern
  - Coordinator configures the closure, view model calls `navigateBack()` method

- **Mandatory TopBarContainerController wrapping**: PromotionsViewController must always be wrapped
  - MainTabBarCoordinator: Already correct (line 726-729)
  - ProfileWalletCoordinator: Fixed to wrap in TopBarContainerController (line 252-255)
  - Provides consistent top bar with user session management

### Experiments & Notes
- Explored using oversized backButton with constraints covering both icon and label
  - Rejected in favor of container approach for cleaner separation of concerns

- User suggested container-based solution (UIView with gesture recognizer)
  - This matches internal implementation of MatchDateNavigationBarView (lines 135-139)
  - More maintainable than button constraint tricks

### Useful Files / Links
- [PromotionsViewController](BetssonCameroonApp/App/Screens/Promotions/PromotionsViewController.swift)
  - Lines 18-20: New back button container components
  - Lines 76-77: Tap gesture recognizer setup
  - Lines 395-409: Container layout constraints
  - Line 181: Calls viewModel.navigateBack()

- [PromotionsViewModel](BetssonCameroonApp/App/Screens/Promotions/PromotionsViewModel.swift)
  - Line 26: onNavigateBack closure (configured by coordinator)
  - Line 162-164: navigateBack() method (called by view controller)

- [MainTabBarCoordinator](BetssonCameroonApp/App/Coordinators/MainTabBarCoordinator.swift)
  - Lines 716-718: Configures onNavigateBack closure
  - Lines 726-729: Wraps in TopBarContainerController

- [ProfileWalletCoordinator](BetssonCameroonApp/App/Coordinators/ProfileWalletCoordinator.swift)
  - Lines 242-244: Configures onNavigateBack closure
  - Lines 252-255: Wraps in TopBarContainerController
  - Lines 258-271: Sets up TopBarContainerController navigation callbacks

- [MatchDateNavigationBarView](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchDateNavigationBar/MatchDateNavigationBarView.swift)
  - Lines 135-139: Reference implementation for back button covering icon + label
  - Inspired the container-based approach

### Next Steps
1. Test back button UX in both coordinators (MainTabBar and ProfileWallet flows)
2. Verify TopBarContainerController displays correctly in ProfileWalletCoordinator context
3. Consider extracting back button container pattern to reusable GomaUI component if needed elsewhere
4. Validate that all screen-level navigation follows the same MVVM-C pattern
