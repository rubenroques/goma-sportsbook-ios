## Date
16 September 2025

### Project / Branch
sportsbook-ios / rr/deposit

### Goals for this session
- Eliminate ~800 lines of duplicated MultiWidget top bar code across 4+ view controllers in BetssonCameroonApp
- Centralize top bar logic (MultiWidget toolbar, wallet overlays, authentication callbacks) in a single reusable component
- Maintain MVVM-C architecture pattern with proper separation of concerns
- Apply solution to both simple screens (MatchDetailsTextual) and complex container (MainTabBarViewController)

### Achievements
- [x] Created TopBarContainerController.swift - central container managing MultiWidget toolbar and overlays
- [x] Created TopBarContainerViewModel.swift - handles business logic for top bar (reactive wallet chain)
- [x] Created UIViewController+TopBarContainer.swift - extension for content VCs to access container
- [x] Refactored MatchDetailsTextualViewController - removed ~250 lines of duplicate top bar code
- [x] Implemented nested container architecture for MainTabBarViewController - stripped ~500 lines
- [x] Updated MainTabBarCoordinator to use TopBarContainerController wrapper pattern
- [x] Fixed compilation errors in MainTabBarViewController after component removal
- [x] Enhanced TopBarContainerController overlay tap gesture with proper outside-tap detection

### Issues / Bugs Hit
- [x] MVVM-C Pattern Violation - Initially placed setupTopBarWalletChain() business logic in MainTabBarCoordinator
- [x] Compilation errors in MainTabBarViewController - references to deleted top bar components (topSafeAreaView, topBarContainerBaseView, etc.)
- [x] Missing tap gesture refinement for wallet overlay dismissal

### Key Decisions
- **Chose Container View Controller Pattern over inheritance** - enables wrapping existing VCs without modification
- **Applied Nested Container Architecture** for MainTabBarViewController instead of component extraction - cleaner separation
- **Created TopBarContainerViewModel** to maintain MVVM-C pattern - business logic belongs in ViewModels, not coordinators
- **Used protocol-driven design** - all components use protocols with mock implementations for testing

### Experiments & Notes
- Tried placing reactive wallet chain setup in coordinator → violated MVVM-C, moved to ViewModel
- Container pattern works excellently for both simple screens and complex tab containers
- Nested architecture (TopBarContainer > RootTabBar > child screens) maintains clean responsibility separation

### Useful Files / Links
- [TopBarContainerController](BetssonCameroonApp/App/Components/TopBarContainerController/TopBarContainerController.swift)
- [TopBarContainerViewModel](BetssonCameroonApp/App/ViewModels/TopBarContainerViewModel.swift)
- [MainTabBarViewController](BetssonCameroonApp/App/Screens/Root/MainTabBarViewController.swift)
- [MainTabBarCoordinator](BetssonCameroonApp/App/Coordinators/MainTabBarCoordinator.swift)
- [Architecture Documentation](../TopBarContainerArchitecture.md)

### Architecture Transformation

**Before:**
```
MainTabBarCoordinator
    └── MainTabBarViewController (1154 lines)
           ├── Top bar (MultiWidget, wallet) - ~300 lines
           ├── Tab bar (bottom)
           └── Child screens
```

**After:**
```
MainTabBarCoordinator
    └── TopBarContainerController
           └── MainTabBarViewController (~600 lines)
                  ├── Tab bar (bottom)
                  └── Child screens
```

### Code Quality Results
- **~800 lines eliminated** from duplicated top bar code across 4+ view controllers
- **Single source of truth** for top bar logic in TopBarContainerController
- **Clean MVVM-C separation** - ViewModels handle business logic, controllers handle UI, coordinators handle navigation
- **Reusable architecture** - any ViewController can be wrapped in TopBarContainerController
- **Protocol-driven design** - enables testing with mocks and flexible implementations

### Next Steps
1. Apply TopBarContainerController to remaining screens (InPlayEventsViewController, etc.)
2. Consider extracting common overlay patterns to reusable components
3. Add unit tests for TopBarContainerViewModel reactive wallet chain
4. Document container pattern for team adoption

### Update (September 17, 2025)
**Note**: All references to `RootTabBar*` components in this document have been updated to `MainTabBar*` following the architectural rename completed on September 17, 2025. The renaming provides better clarity since TopBarContainerController became the actual root container.