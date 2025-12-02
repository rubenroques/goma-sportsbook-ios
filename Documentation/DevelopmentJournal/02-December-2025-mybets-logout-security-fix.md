## Date
02 December 2025

### Project / Branch
BetssonCameroonApp / rr/fix/double_toggle_outcome

### Goals for this session
- Fix security vulnerability where MyBets data persists after logout
- Prevent next user from seeing previous user's betting history

### Achievements
- [x] Identified root cause: `MyBetsViewModel.betListDataCache` not cleared on logout
- [x] Added logout subscription in `MyBetsViewModel.setupBindings()` following `BetslipManager` pattern
- [x] Cache cleared and state reset to `.loading` when user status becomes `.anonymous`
- [x] Fresh data loaded when user logs in (`.logged` status)
- [x] Added changelog entry for the security fix

### Issues / Bugs Hit
- None encountered during implementation

### Key Decisions
- Followed existing `BetslipManager` pattern for handling logout events via `userProfileStatusPublisher`
- Chose to subscribe in ViewModel rather than destroying coordinator on logout (less disruptive, more targeted)
- Reset state to `.loading` on logout to ensure no stale data is displayed

### Experiments & Notes
- `UserSessionStore.logout()` clears: keychain, UserDefaults, favorites, user publishers
- `UserSessionStore.logout()` did NOT clear: `MyBetsViewModel.betListDataCache`
- `MyBetsCoordinator` is lazy-loaded and persists across logout/login cycles
- Even though `refresh()` is called when navigating to MyBets, there was a window where cached data could be visible

### Useful Files / Links
- [MyBetsViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/MyBetsViewModel.swift) - Added logout subscription
- [UserSessionStore.swift](../../BetssonCameroonApp/App/Services/UserSessionStore.swift) - Logout flow reference
- [BetslipManager.swift](../../BetssonCameroonApp/App/Services/BetslipManager.swift) - Pattern reference (lines 101-116)
- [MainTabBarCoordinator.swift](../../BetssonCameroonApp/App/Coordinators/MainTabBarCoordinator.swift) - Coordinator lifecycle

### Next Steps
1. Test logout/login flow manually to verify fix
2. Consider auditing other ViewModels with user-specific caches for similar issues
3. Note: XtremePush user clearing is still commented out per client request (separate security concern documented in UserSessionStore.swift:180-198)
