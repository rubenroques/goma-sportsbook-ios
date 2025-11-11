## Date
08 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Replace mock AdaptiveTabBarViewModel usage in production with proper production ViewModel
- Follow MVVM-C architecture pattern with coordinator-based dependency injection
- Maintain exact same functionality as mock but in BetssonCameroonApp project

### Achievements
- [x] Created production `AdaptiveTabBarViewModel` in `BetssonCameroonApp/App/ViewModels/`
- [x] Implemented exact same logic as `MockAdaptiveTabBarViewModel` (already production-quality)
- [x] Added `defaultConfiguration` static factory method with default tab structure
- [x] Updated `MainTabBarCoordinator.start()` to instantiate and inject production ViewModel
- [x] Removed default mock parameter from `MainTabBarViewModel` initializer
- [x] Fixed Bundle reference from `Bundle.gomaUI` to `Bundle.main` for BetssonCameroonApp context

### Issues / Bugs Hit
- [x] Initial implementation used `Bundle.gomaUI` for icon loading - corrected to `Bundle.main` since icons are in BetssonCameroonApp's asset catalog, not GomaUI framework
- [x] Minor localization key fix: Changed "home" to "casino" for casino home tab (line 150)

### Key Decisions
- **Coordinator creates ViewModel**: Following proper MVVM-C pattern, `MainTabBarCoordinator` instantiates `AdaptiveTabBarViewModel.defaultConfiguration` and injects it into `MainTabBarViewModel`
- **Exact mock implementation**: Since `MockAdaptiveTabBarViewModel` was already production-quality with complete state management logic, copied implementation verbatim to avoid regression
- **Default configuration pattern**: Used static factory method `defaultConfiguration` similar to other production ViewModels in the project (e.g., `QuickLinksTabBarViewModel`)
- **No callbacks needed**: ViewModel only manages state through protocol - navigation handled by coordinator via `MainTabBarViewModel.setupTabBarBinding()`

### Architecture Pattern
```
MainTabBarCoordinator.start()
  ├─ Creates AdaptiveTabBarViewModel.defaultConfiguration
  ├─ Injects into MainTabBarViewModel(adaptiveTabBarViewModel:)
  └─ MainTabBarViewModel observes displayStatePublisher for tab bar switches
```

### Useful Files / Links
- [AdaptiveTabBarViewModel](../../BetssonCameroonApp/App/ViewModels/AdaptiveTabBarViewModel.swift) - New production ViewModel
- [MainTabBarCoordinator](../../BetssonCameroonApp/App/Coordinators/MainTabBarCoordinator.swift) - Coordinator instantiation (line 68-72)
- [MainTabBarViewModel](../../BetssonCameroonApp/App/Screens/MainTabBar/MainTabBarViewModel.swift) - Removed default mock (line 46-49)
- [MockAdaptiveTabBarViewModel](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/AdaptiveTabBarView/MockAdaptiveTabBarViewModel.swift) - Reference implementation
- [AdaptiveTabBarViewModelProtocol](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/AdaptiveTabBarView/AdaptiveTabBarViewModelProtocol.swift) - Protocol definition

### Next Steps
1. Build and test BetssonCameroonApp to verify no regressions
2. Verify tab switching between home (.home) and casino (.casino) still works correctly
3. Verify floating overlay messages appear on tab bar context switches
4. Consider extracting tab configuration to a separate config file if multiple coordinators need different tab structures in the future
