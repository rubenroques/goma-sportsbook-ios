## Date
15 November 2025

### Project / Branch
sportsbook-ios / rr/breadcrumb

### Goals for this session
- Investigate reported Jira bug: My Bets screen table view content hidden behind tab bar
- Analyze view hierarchy and constraint setup
- Fix bottom inset to preserve glass effect while showing all content

### Achievements
- [x] Confirmed bug exists in BetssonCameroonApp MyBetsViewController
- [x] Traced root cause: mainContainerView extends behind tab bar (56pt) + safe area for glass effect
- [x] Researched existing bottom inset patterns across the codebase
- [x] Identified inconsistent patterns (60pt, 160pt, 32pt hardcoded values)
- [x] Implemented dynamic bottom inset calculation: `tabBarHeight + safeAreaInsets.bottom`
- [x] Added scroll indicator extra padding (+6pt) for better visibility

### Issues / Bugs Hit
- Initial confusion about safe area handling in child view controllers
- Found no shared helper methods or constants for tab bar height (hardcoded in MainTabBarViewController:940)
- Discovered inconsistent bottom inset patterns across different screens

### Key Decisions
- **Dynamic calculation over hardcoded value**: Chose to calculate `tabBarHeight + safeAreaInsets.bottom` dynamically in `viewDidLayoutSubviews()` for robustness across different devices
- **Scroll indicator extra padding**: Added +6pt to scroll indicator insets following MarketGroupCardsViewController pattern for better visibility
- **viewDidLayoutSubviews approach**: Updates insets on layout changes, handles rotation and safe area changes automatically

### Experiments & Notes
- View hierarchy investigation revealed:
  ```
  MainTabBarViewController.view
  ├── mainContainerView (extends to view.bottomAnchor for glass effect)
  │   └── myBetsBaseView (fills mainContainerView)
  │       └── MyBetsViewController.view (embedded child)
  │           └── contentView (constrained to safeAreaLayoutGuide)
  │               └── tableView
  ├── tabBarView (56pt height)
  └── bottomSafeAreaView (home indicator area)
  ```
- Child view controller's safeAreaLayoutGuide doesn't account for parent's tab bar when embedded in container that extends behind it
- Other screens use varying approaches:
  - CasinoCategoriesListViewController: 60pt hardcoded
  - MarketGroupCardsViewController: 160pt (for betslip, not tab bar)
  - SportsBetslipViewController: 32pt
- Tab bar has blur effect (`combinedTabBarBlurView`) spanning tab bar + safe area for glass morphism

### Useful Files / Links
- [MyBetsViewController](BetssonCameroonApp/App/Screens/MyBets/MyBetsViewController.swift)
- [MainTabBarViewController](BetssonCameroonApp/App/Screens/MainTabBar/MainTabBarViewController.swift)
- [MainTabBarCoordinator](BetssonCameroonApp/App/Coordinators/MainTabBarCoordinator.swift)
- [CasinoCategoriesListViewController](BetssonCameroonApp/App/Screens/Casino/CasinoCategoriesList/CasinoCategoriesListViewController.swift) - 60pt pattern reference
- [MarketGroupCardsViewController](BetssonCameroonApp/App/Screens/NextUpEvents/MarketGroupCardsViewController.swift) - +6pt scroll indicator pattern

### Code Changes

**Added to MyBetsViewController.swift:**

1. **Constant** (line 12):
   ```swift
   private let tabBarHeight: CGFloat = 56 // Matches MainTabBarViewController.swift:940
   ```

2. **Lifecycle method** (lines 184-187):
   ```swift
   override func viewDidLayoutSubviews() {
       super.viewDidLayoutSubviews()
       updateTableViewInsets()
   }
   ```

3. **Helper method** (lines 205-212):
   ```swift
   private func updateTableViewInsets() {
       let safeAreaBottom = view.safeAreaInsets.bottom
       let bottomContentInset = tabBarHeight + safeAreaBottom
       let bottomIndicatorInset = bottomContentInset + 6 // +6pt for better visibility

       tableView.contentInset.bottom = bottomContentInset
       tableView.scrollIndicatorInsets.bottom = bottomIndicatorInset
   }
   ```

### Next Steps
1. Build and test on simulator to verify fix works correctly
2. Test on devices with different safe area configurations (iPhone with/without notch)
3. Verify glass effect still visible with content showing through blurred tab bar
4. Consider creating shared constant for tab bar height to prevent future inconsistencies
5. Future refactor: Consider standardizing bottom inset handling across all main tab screens
