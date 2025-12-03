## Date
02 December 2025

### Project / Branch
BetssonCameroonApp / main

### Goals for this session
- Fix My Bets screen showing technical error when user is not logged in
- Match web app behavior: show friendly "No bets to display" empty state

### Achievements
- [x] Identified root cause: API calls made without auth check + `setupBindings()` overwriting state with `.loading`
- [x] Added auth guard to `loadBets()` - returns `.loaded([])` for unauthenticated users
- [x] Added auth guard to `loadMoreBets()` - early return for unauthenticated users
- [x] Added auth guard to `refreshBets()` - returns `.loaded([])` for unauthenticated users
- [x] Fixed `setupBindings()` anonymous case: changed from `.loading` to `.loaded([])`
- [x] Updated localization strings (EN/FR) from "No bets found" to "No bets to display"

### Issues / Bugs Hit
- [x] Initial fix only added guards to load methods, but infinite loading persisted
- [x] Root cause: `userProfileStatusPublisher` subscription in `setupBindings()` was sending `.loading` state when user status was `.anonymous`, overwriting the empty state set by `loadBets()`

### Key Decisions
- Used existing `.loaded([])` state instead of adding new `.notLoggedIn` state - simpler and matches web behavior
- No login button on empty state - matches web exactly (just shows "No bets to display")

### Useful Files / Links
- [MyBetsViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/MyBetsViewModel.swift) - Auth guards + setupBindings fix
- [MyBetsViewController.swift](../../BetssonCameroonApp/App/Screens/MyBets/MyBetsViewController.swift) - Empty state view
- [Localizable.strings (EN)](../../BetssonCameroonApp/App/Resources/Language/en.lproj/Localizable.strings)
- [Localizable.strings (FR)](../../BetssonCameroonApp/App/Resources/Language/fr.lproj/Localizable.strings)

### Next Steps
1. Test login flow: verify bets load correctly after logging in
2. Test logout flow: verify empty state appears after logging out
3. Consider adding similar auth checks to other authenticated-only screens
