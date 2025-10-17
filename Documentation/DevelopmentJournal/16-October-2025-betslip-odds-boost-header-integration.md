# Development Journal Entry

## Date
16 October 2025

### Project / Branch
sportsbook-ios / rr/oddsboost_ui

### Goals for this session
- Integrate BetslipOddsBoostHeaderView into SportsBetslipViewController
- Follow same architectural pattern as BetslipFloatingThinView in MainTabBarViewController
- Show header only when: user has selections + logged in + odds boost available
- Use stack-based layout for clean integration

### Achievements
- [x] Created production BetslipOddsBoostHeaderViewModel following BetslipFloatingViewModel pattern
- [x] Updated SportsBetslipViewModelProtocol to include header ViewModel and visibility publisher
- [x] Implemented visibility logic using Publishers.CombineLatest3 (tickets + user profile + odds boost)
- [x] Integrated header as UITableView tableHeaderView to maximize space for betting selections
- [x] Fixed suggested bets expansion issue - now pushes table up instead of covering content
- [x] Added dynamic header height recalculation for smooth show/hide animations
- [x] Maintained all existing constraints and functionality

### Issues / Bugs Hit
- [x] ~~Initial stack-based approach broke bottom actions positioning~~ - Fixed by using minimal stack (only button bar + odds boost)
- [x] ~~Limited table view space with fixed top section~~ - Fixed by moving to tableHeaderView (scrolls with content)
- [x] ~~Suggested bets expansion covered table content~~ - Fixed by changing table bottom constraint to suggestedBetsView.topAnchor
- [x] ~~Empty state view constraints broken~~ - User fixed independently, preserved in final implementation

### Key Decisions
- **Minimal Stack Approach**: Only buttonBarView + oddsBoostHeaderContainer in topSectionStackView, not entire layout
- **TableHeaderView Pattern**: Header scrolls with content instead of being fixed, providing maximum space for selections
- **Visibility Management**: ViewModel calculates visibility, ViewController displays (clean separation)
- **Constraint Strategy**: Changed table.bottomAnchor to suggestedBetsView.topAnchor to fix expansion behavior
- **Frame-Based Sizing**: Used `translatesAutoresizingMaskIntoConstraints = true` for tableHeaderView with manual frame sizing
- **Dynamic Height Updates**: Added viewDidLayoutSubviews() to handle rotation and split-screen scenarios

### Experiments & Notes
- Tried full stack-based layout initially → broke bottom actions pinning → reverted to hybrid approach
- Discovered tableHeaderView requires frame-based sizing, not AutoLayout constraints
- Added updateTableHeaderViewHeight() with proper width constraints for accurate sizing
- Used systemLayoutSizeFitting with horizontalFittingPriority: .required for reliable calculations

### Useful Files / Links
- [BetslipOddsBoostHeaderViewModel](../../../BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/BetslipOddsBoostHeaderViewModel.swift) - Production ViewModel implementation
- [SportsBetslipViewController](../../../BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/SportsBetslipViewController.swift) - Main integration point
- [BetslipFloatingViewModel](../../../BetssonCameroonApp/App/Screens/NextUpEvents/BetslipFloatingViewModel.swift) - Reference pattern for odds boost logic
- [BetslipOddsBoostHeaderView](../../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipOddsBoostHeaderView/BetslipOddsBoostHeaderView.swift) - GomaUI component

### Architecture Pattern Used

**MVVM-C with Reactive Visibility Management:**
```
SportsBetslipViewModel
  ├── betslipOddsBoostHeaderViewModel (production)
  └── oddsBoostHeaderVisibilityPublisher
          ↓
      Combines 3 publishers:
      - betslipManager.bettingTicketsPublisher
      - userSessionStore.userProfilePublisher
      - betslipManager.oddsBoostStairsPublisher
          ↓
      Visibility = hasTickets && isLoggedIn && hasOddsBoost
          ↓
SportsBetslipViewController
  └── updateOddsBoostHeaderVisibility()
      └── updateTableHeaderViewHeight() (smooth animation)
```

### Code Quality Notes
- Reused extractOddsBoostData() logic from BetslipFloatingViewModel for consistency
- All constraints preserved except intentional changes for table header integration
- Zero hardcoded values - uses StyleProvider throughout
- Proper weak self in all closures to prevent retain cycles
- Animated transitions with 0.3s duration for smooth UX

### Next Steps
1. Test odds boost visibility transitions with real data
2. Verify header scrolling behavior with various betslip sizes
3. Test suggested bets expansion with multiple matches
4. Validate on different device sizes and orientations
5. Consider adding header refresh on odds boost data updates
