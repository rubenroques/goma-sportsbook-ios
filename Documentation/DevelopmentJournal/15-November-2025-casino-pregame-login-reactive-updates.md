## Date
15 November 2025

### Project / Branch
sportsbook-ios / rr/breadcrumb

### Goals for this session
- Fix Casino Pre-Game "Login to Play" button not triggering navigation
- Implement reactive UI updates after user login
- Ensure proper MVVM-C architecture compliance with dependency injection

### Achievements
- [x] Fixed "Login to Play" button navigation flow (CasinoCoordinator → MainTabBarCoordinator → showLogin)
- [x] Added proper UserSessionStore dependency injection to CasinoGamePrePlayViewModel
- [x] Implemented reactive subscription to userProfileStatusPublisher for automatic UI updates
- [x] Refactored CasinoSearchCoordinator to use individual dependencies instead of full Environment
- [x] Removed all global Env usage in Casino pre-game flow
- [x] Fixed type annotation issues in closure parameters

### Issues / Bugs Hit
- [x] Button tap worked but stopped at coordinator level (TODO comment instead of navigation)
- [x] Screen didn't update after login (no reactive subscription to UserSessionStore)
- [x] CasinoSearchCoordinator had wrong DI pattern (received full Environment object)
- [x] Type inference errors in closure parameters for CasinoSearchCoordinator

### Key Decisions
- **Proper Dependency Injection**: Coordinators receive individual dependencies (servicesProvider, userSessionStore) instead of full Environment object
- **Reactive Updates**: Used `userProfileStatusPublisher.removeDuplicates()` pattern from BetslipManager for consistency
- **MVVM-C Navigation**: Login request flows through closure chain: ViewModel → CasinoCoordinator → MainTabBarCoordinator
- **No Global Env in ViewModels**: All dependencies passed through init parameters following BetssonCameroonApp patterns

### Experiments & Notes
- Investigated proper DI patterns by analyzing WalletStatusViewModel, ProfileWalletViewModel, and MatchDetailsTextualViewModel
- Confirmed pattern: Coordinator has Environment → extracts dependencies → passes to ViewModels
- Found 5 locations where CasinoCoordinator is instantiated in MainTabBarCoordinator (all needed onLoginRequested wiring)
- UserSessionStore provides multiple publishers: userProfileStatusPublisher (preferred), userProfilePublisher, userWalletPublisher

### Useful Files / Links
- [CasinoGamePrePlayViewModel](BetssonCameroonApp/App/Screens/Casino/CasinoGamePrePlay/CasinoGamePrePlayViewModel.swift) - Parent ViewModel with navigation closures
- [CasinoGamePlayModeSelectorViewModel](BetssonCameroonApp/App/Screens/Casino/CasinoGamePrePlay/CasinoGamePrePlayViewModel.swift#L82-L308) - Nested ViewModel with button logic and reactive updates
- [CasinoCoordinator](BetssonCameroonApp/App/Coordinators/CasinoCoordinator.swift) - Casino navigation coordinator
- [CasinoSearchCoordinator](BetssonCameroonApp/App/Coordinators/CasinoSearchCoordinator.swift) - Search-specific casino coordinator
- [MainTabBarCoordinator](BetssonCameroonApp/App/Coordinators/MainTabBarCoordinator.swift) - Root coordinator with showLogin method
- [UserSessionStore](BetssonCameroonApp/App/Services/UserSessionStore.swift) - Session management with Combine publishers
- [BetslipManager](BetssonCameroonApp/App/Services/BetslipManager.swift#L101-L116) - Reference pattern for userProfileStatusPublisher usage

### Implementation Details

#### 1. Navigation Flow Fix
**Problem**: Button tap printed "Login requested" but didn't navigate

**Solution**:
- Added `onLoginRequested: (() -> Void)?` closure to CasinoCoordinator
- Wired it up in MainTabBarCoordinator to call `showLogin()`
- Updated all 5 CasinoCoordinator instantiation points (casino, virtuals, aviator, slots, crash)
- Applied same pattern to CasinoSearchCoordinator

**Files Modified**:
- CasinoCoordinator.swift (line 23, 169-171)
- MainTabBarCoordinator.swift (lines 972-974, 1013-1015, 1047-1049, 1107-1109, 1149-1151, 1088-1093)
- CasinoSearchCoordinator.swift (lines 20-21, 80-81)

#### 2. Reactive UI Updates
**Problem**: After login, Pre-Game screen still showed "Login to Play" button

**Solution**:
- Added `userSessionStore` property to both parent and child ViewModels
- Updated init signatures to accept userSessionStore parameter
- Created `setupUserSessionTracking()` method in CasinoGamePlayModeSelectorViewModel
- Subscribed to `userProfileStatusPublisher.removeDuplicates()`
- On status change, refresh display state by calling `createDisplayState()` and sending to `displayStateSubject`

**Files Modified**:
- CasinoGamePrePlayViewModel.swift:
  - Line 28: Added userSessionStore property
  - Line 35: Updated init signature
  - Lines 41-45: Pass userSessionStore to child ViewModel
- CasinoGamePlayModeSelectorViewModel.swift (nested):
  - Line 95: Added userSessionStore property
  - Line 112: Updated init signature
  - Lines 290-305: Added setupUserSessionTracking() method
  - Line 308: Replaced Env.userSessionStore with injected dependency

#### 3. Proper Dependency Injection
**Problem**: CasinoSearchCoordinator received full Environment object (anti-pattern)

**Solution**:
- Changed init from `init(navigationController, environment: Environment)` to `init(navigationController, servicesProvider, userSessionStore)`
- Removed `environment` property, replaced with individual dependencies
- Updated all references from `environment.servicesProvider` to `servicesProvider`
- Removed fallback to global `Env.servicesProvider` (lines 95, 97)
- Updated MainTabBarCoordinator instantiation to pass individual dependencies

**Files Modified**:
- CasinoSearchCoordinator.swift:
  - Lines 24-25: Replaced environment with individual properties
  - Line 36: Updated init signature
  - Line 44: Direct servicesProvider reference
  - Lines 78-79: Pass individual dependencies to ViewModel
  - Lines 98, 100: Use injected servicesProvider instead of Env fallback
- MainTabBarCoordinator.swift:
  - Lines 1083-1086: Pass individual dependencies instead of environment

### Code Patterns Established

**Coordinator Dependency Injection**:
```swift
// ✅ CORRECT
init(navigationController: UINavigationController,
     servicesProvider: ServicesProvider.Client,
     userSessionStore: UserSessionStore)

// ❌ WRONG
init(navigationController: UINavigationController,
     environment: Environment)
```

**ViewModel Reactive Subscription**:
```swift
private func setupUserSessionTracking() {
    userSessionStore.userProfileStatusPublisher
        .removeDuplicates()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] status in
            // Refresh UI state
            if let gameDetails = self?.gameDetails {
                let newState = self?.createDisplayState(from: gameDetails, isLoading: false)
                self?.displayStateSubject.send(newState)
            }
        }
        .store(in: &cancellables)
}
```

**Navigation Closure Chain**:
```swift
// ViewModel defines intent
var onLoginRequested: (() -> Void) = { }

// Coordinator wires to parent
coordinator.onLoginRequested = { [weak self] in
    self?.onLoginRequested?()  // Propagate to parent
}

// Root coordinator executes
coordinator.onLoginRequested = { [weak self] in
    self?.showLogin()  // Execute navigation
}
```

### Next Steps
1. Test the full flow: Launch app → Navigate to Casino → Select game → Tap "Login to Play" → Login → Verify buttons update
2. Consider refactoring CasinoCoordinator to use individual dependencies (currently still uses Environment)
3. Verify CasinoGamePlayViewController doesn't need similar reactive updates
4. Add same pattern to other pre-game flows if they exist (Live Casino, Virtual Sports)
5. Document this DI pattern in MVVM.md guide for future reference
