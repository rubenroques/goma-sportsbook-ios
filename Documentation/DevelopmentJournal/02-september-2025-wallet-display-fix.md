## Date
02 September 2025

### Project / Branch
sportsbook-ios / rr/mybets_profile_features

### Goals for this session
- Fix wallet value display showing "-.--€" in MyBetDetail screen
- Investigate why opening Profile modal temporarily fixes the issue
- Implement proper view model architecture for MultiWidgetToolbar

### Achievements
- [x] Identified root cause: Both RootTabBar and MyBetDetail were using MockMultiWidgetToolbarViewModel from GomaUI
- [x] Created proper MultiWidgetToolbarViewModel implementation in BetssonCameroonApp
- [x] Created WalletWidgetViewModel (though not ultimately used in current solution)
- [x] Updated RootTabBarViewModel to use concrete MultiWidgetToolbarViewModel
- [x] Updated MyBetDetailViewModel to use concrete MultiWidgetToolbarViewModel
- [x] Added smart pending balance handling for timing issues

### Issues / Bugs Hit
- [ ] GomaUI MockMultiWidgetToolbarViewModel has improper coupling with MockWalletWidgetViewModel
- [ ] MultiWidgetToolbarView creates its own wallet widget internally, making it hard to inject proper view models
- [ ] Timing issue where wallet balance update arrives before wallet view model is assigned

### Key Decisions
- Use concrete MultiWidgetToolbarViewModel instead of protocol in app code
- Keep GomaUI components generic - don't modify them for app-specific needs
- Implement pending balance pattern to handle timing issues
- Created proper view models in app layer rather than relying on GomaUI mocks

### Experiments & Notes
- Initially tried to add wallet binding directly to MyBetDetailViewModel - didn't work
- Discovered the real issue was using mock view models in production code
- Profile modal fix was a red herring - it worked because it triggered wallet refresh
- GomaUI architecture creates widgets internally, making dependency injection challenging

### Useful Files / Links
- [MultiWidgetToolbarViewModel](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/BetssonCameroonApp/App/ViewModels/MultiWidgetToolbarViewModel.swift)
- [WalletWidgetViewModel](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/BetssonCameroonApp/App/ViewModels/WalletWidgetViewModel.swift)
- [MyBetDetailViewModel](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/BetssonCameroonApp/App/Screens/MyBetDetail/MyBetDetailViewModel.swift)
- [RootTabBarViewModel](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/BetssonCameroonApp/App/Screens/Root/RootTabBarViewModel.swift)
- [GomaUI MultiWidgetToolbarView](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MultiWidgetToolbarView/MultiWidgetToolbarView.swift)

### Next Steps
1. Consider refactoring GomaUI to allow widget view model injection
2. Remove improper coupling between MockMultiWidgetToolbarViewModel and MockWalletWidgetViewModel in GomaUI
3. Test wallet display in other screens that use MultiWidgetToolbar
4. Consider creating a shared toolbar service for consistent wallet display across app