# BetssonFrance V2 - Core Infrastructure Jira Tickets

> **Project**: Betsson France V2 - New MVVM-C Application
> **Generated**: December 11, 2025
> **Total Core Tickets**: 15 infrastructure tasks (8+ man-hours each)
> **Reference Architecture**: BetssonCameroonApp

---

## Executive Summary

This document contains all Jira tickets needed to create the **core infrastructure** for a new BetssonFrance V2 project using modern MVVM-C architecture. These are foundational structural tasks - the skeleton of the app that UI components will be assembled into.

**Excluded from scope** (per requirements):
- Chat / Group Chat / Social features
- Tips
- Rankings

### Story Points Legend
- **5 SP**: ~8 hours (1 day)
- **8 SP**: ~2-3 days
- **13 SP**: ~1 week

---

## Feature Area 1: Project Foundation (3 tickets)

### INFRA-01: Create BetssonFranceV2App Xcode Project

| Field | Value |
|-------|-------|
| **Summary** | [iOS] BF-V2 - Create new BetssonFranceV2App Xcode project with package dependencies |
| **Story Points** | 8 |
| **Priority** | Highest |
| **Labels** | `ios`, `BF`, `BF-V2`, `infrastructure` |

**Description**:
Create a new standalone Xcode project for BetssonFrance V2 following BetssonCameroonApp architecture. This will be a clean, modern project separate from the legacy BetssonFranceApp.

**Acceptance Criteria**:
- [ ] New project `BetssonFranceV2App` created in workspace root
- [ ] Project added to `Sportsbook.xcworkspace`
- [ ] Swift Package dependencies configured:
  - GomaUI
  - ServicesProvider
  - Extensions
  - RegisterFlow
  - CountrySelectionFeature
- [ ] Build configurations: Debug, Release
- [ ] Schemes created: `BetssonFranceV2 DEV`, `BetssonFranceV2 STG`, `BetssonFranceV2 PROD`
- [ ] Info.plist configured with France-specific bundle ID
- [ ] Asset catalog created with placeholder app icon
- [ ] Project builds successfully on iOS 18.2+ simulator
- [ ] Directory structure follows BCM pattern:
  ```
  BetssonFranceV2App/
  ├── App/
  │   ├── Boot/
  │   ├── Coordinators/
  │   └── Configuration/
  ├── Screens/
  ├── ViewModels/
  ├── Resources/
  └── Supporting Files/
  ```

**Dependencies**: None (first task)

**Reference**: `/BetssonCameroonApp/BetssonCameroonApp.xcodeproj`

---

### INFRA-02: Configure Environment and ServicesProvider

| Field | Value |
|-------|-------|
| **Summary** | [iOS] BF-V2 - Configure Environment with ServicesProvider for France market |
| **Story Points** | 8 |
| **Priority** | Highest |
| **Labels** | `ios`, `BF`, `BF-V2`, `infrastructure`, `services` |

**Description**:
Set up the Environment class and ServicesProvider configuration for Betsson France market. This connects the app to EveryMatrix backend APIs and Goma CMS.

**Acceptance Criteria**:
- [ ] `Environment.swift` created with lazy ServicesProvider initialization
- [ ] `TargetVariables.swift` configured:
  - `serviceProviderType = .everymatrix`
  - `cmsClientBusinessUnit = .betssonFrance`
  - `serviceProviderEnvironment` based on build config
- [ ] `Configuration.Builder` properly configured for France:
  - Correct EveryMatrix operator/domain IDs
  - France WAMP WebSocket endpoints
  - France REST API base URLs
  - Goma CMS environment set to `.betsson`
- [ ] Device UUID generation and storage
- [ ] Language manager integration (French/English)
- [ ] Build configurations map to environments:
  - DEV → `.development`
  - STG → `.staging`
  - PROD → `.production`
- [ ] ServicesProvider connects successfully in DEV environment

**Dependencies**: INFRA-01

**Reference**:
- `/BetssonCameroonApp/App/Boot/Environment.swift`
- `/Frameworks/ServicesProvider/Sources/ServicesProvider/Configuration/`

---

### INFRA-03: Create AppStateManager for Bootstrap Flow

| Field | Value |
|-------|-------|
| **Summary** | [iOS] BF-V2 - Create AppStateManager for app initialization and state management |
| **Story Points** | 8 |
| **Priority** | Highest |
| **Labels** | `ios`, `BF`, `BF-V2`, `infrastructure`, `boot` |

**Description**:
Create the AppStateManager class that handles app initialization, maintenance mode detection, and state transitions. This is the brain of the boot sequence.

**Acceptance Criteria**:
- [ ] `AppStateManager.swift` created with state machine:
  ```swift
  enum AppState {
      case initializing
      case splashLoading
      case maintenanceMode
      case updateRequired(UpdateInfo)
      case updateAvailable(UpdateInfo)
      case ready
  }
  ```
- [ ] Combine publisher for state changes: `currentStatePublisher`
- [ ] Network connectivity monitoring (Reachability)
- [ ] Maintenance mode check via RealtimeSocketClient
- [ ] App version check against minimum required version
- [ ] Parallel services loading when maintenance check passes
- [ ] State transitions:
  - App launch → `initializing` → `splashLoading`
  - Network available → check maintenance
  - Maintenance active → `maintenanceMode`
  - Update required → `updateRequired`
  - All clear → `ready`
- [ ] Unit tests for state transitions

**Dependencies**: INFRA-02

**Reference**: `/BetssonCameroonApp/App/Boot/AppStateManager.swift`

---

## Feature Area 2: Coordinator Infrastructure (5 tickets)

### COORD-01: Create Coordinator Base Protocol

| Field | Value |
|-------|-------|
| **Summary** | [iOS] BF-V2 - Create Coordinator protocol and base implementation |
| **Story Points** | 5 |
| **Priority** | Highest |
| **Labels** | `ios`, `BF`, `BF-V2`, `infrastructure`, `coordinator` |

**Description**:
Create the base Coordinator protocol that all coordinators will conform to. This establishes the navigation architecture pattern.

**Acceptance Criteria**:
- [ ] `Coordinator.swift` protocol created:
  ```swift
  protocol Coordinator: AnyObject {
      var childCoordinators: [Coordinator] { get set }
      var navigationController: UINavigationController { get set }
      func start()
      func finish()
  }
  ```
- [ ] Protocol extension with helper methods:
  - `addChildCoordinator(_ coordinator: Coordinator)`
  - `removeChildCoordinator(_ coordinator: Coordinator)`
- [ ] Documentation comments explaining coordinator pattern
- [ ] MVVM-C compliance: ViewControllers NEVER create Coordinators

**Dependencies**: INFRA-01

**Reference**: `/BetssonCameroonApp/App/Coordinators/Coordinator.swift`

---

### COORD-02: Create AppCoordinator (Root Coordinator)

| Field | Value |
|-------|-------|
| **Summary** | [iOS] BF-V2 - Create AppCoordinator as root coordinator managing app lifecycle |
| **Story Points** | 13 |
| **Priority** | Highest |
| **Labels** | `ios`, `BF`, `BF-V2`, `infrastructure`, `coordinator` |

**Description**:
Create the root AppCoordinator that manages the entire app lifecycle, window setup, and top-level state transitions based on AppStateManager.

**Acceptance Criteria**:
- [ ] `AppCoordinator.swift` created conforming to `Coordinator`
- [ ] Owns `UIWindow` and sets root view controller
- [ ] Observes `AppStateManager.currentStatePublisher` for state changes
- [ ] Child coordinator management:
  - `splashCoordinator: SplashCoordinator?`
  - `maintenanceCoordinator: MaintenanceCoordinator?`
  - `updateCoordinator: UpdateCoordinator?`
  - `mainTabBarCoordinator: MainTabBarCoordinator?`
- [ ] State handling methods:
  - `.splashLoading` → show SplashCoordinator
  - `.maintenanceMode` → show MaintenanceCoordinator
  - `.updateRequired/.updateAvailable` → show UpdateCoordinator
  - `.ready` → show MainTabBarCoordinator
- [ ] Session expiration handling via UserSessionStore observer
- [ ] Deep linking support via `openRoute(_ route: DeepLinkRoute)` method
- [ ] Navigation controller factory method with correct styling
- [ ] SceneDelegate integration point

**Dependencies**: COORD-01, INFRA-03

**Reference**: `/BetssonCameroonApp/App/Coordinators/AppCoordinator.swift`

---

### COORD-03: Create MainTabBarCoordinator

| Field | Value |
|-------|-------|
| **Summary** | [iOS] BF-V2 - Create MainTabBarCoordinator managing main tab navigation |
| **Story Points** | 13 |
| **Priority** | Highest |
| **Labels** | `ios`, `BF`, `BF-V2`, `infrastructure`, `coordinator`, `navigation` |

**Description**:
Create the MainTabBarCoordinator that manages the main tab bar UI and lazy-loads screen coordinators. This is the hub of the main app navigation.

**Acceptance Criteria**:
- [ ] `MainTabBarCoordinator.swift` created conforming to `Coordinator`
- [ ] Manages `MainTabBarViewController` (custom tab bar, not UITabBarController)
- [ ] Lazy-loaded child coordinators for each tab:
  - `homeCoordinator: HomeCoordinator?`
  - `preLiveEventsCoordinator: PreLiveEventsCoordinator?`
  - `inPlayEventsCoordinator: InPlayEventsCoordinator?`
  - `myBetsCoordinator: MyBetsCoordinator?`
  - `searchCoordinator: SportsSearchCoordinator?`
- [ ] Modal coordinators:
  - `betslipCoordinator: BetslipCoordinator?`
  - `profileWalletCoordinator: ProfileWalletCoordinator?`
  - `bankingCoordinator: BankingCoordinator?`
- [ ] Tab selection handling:
  - `handleTabSelection(_ tab: TabItem)`
  - Create coordinator if nil, call `start()`, get `viewController`
  - Pass to MainTabBarViewController for display
- [ ] Cross-coordinator communication:
  - Sport selection changes broadcast
  - Filter state management
  - Match detail navigation
- [ ] Authentication flow methods:
  - `showLogin()` - present PhoneLoginViewController
  - `showRegistration()` - present PhoneRegistrationViewController
- [ ] Deep link routing to appropriate coordinator
- [ ] Closure-based callbacks for child coordinator events

**Dependencies**: COORD-02, TAB-01

**Reference**: `/BetssonCameroonApp/App/Coordinators/MainTabBarCoordinator.swift`

---

### COORD-04: Create SplashCoordinator and MaintenanceCoordinator

| Field | Value |
|-------|-------|
| **Summary** | [iOS] BF-V2 - Create Splash and Maintenance coordinators for boot states |
| **Story Points** | 5 |
| **Priority** | High |
| **Labels** | `ios`, `BF`, `BF-V2`, `infrastructure`, `coordinator` |

**Description**:
Create simple coordinators for splash screen and maintenance mode display. These handle the pre-main-app states.

**Acceptance Criteria**:
- [ ] `SplashCoordinator.swift`:
  - Displays `SplashInformativeViewController`
  - Shows loading indicator and app logo
  - No navigation, just display
- [ ] `MaintenanceCoordinator.swift`:
  - Displays `MaintenanceViewController`
  - Shows maintenance message from server
  - Retry button to re-check maintenance status
  - Callback for retry action
- [ ] `UpdateCoordinator.swift`:
  - Displays `UpdateViewController`
  - Shows update required/available message
  - "Update Now" button opens App Store
  - "Later" button (if update optional) dismisses
- [ ] All coordinators conform to `Coordinator` protocol
- [ ] ViewControllers use GomaUI styling

**Dependencies**: COORD-01

**Reference**:
- `/BetssonCameroonApp/App/Coordinators/SplashCoordinator.swift`
- `/BetssonCameroonApp/App/Coordinators/MaintenanceCoordinator.swift`

---

### COORD-05: Create TopBarContainerController Pattern

| Field | Value |
|-------|-------|
| **Summary** | [iOS] BF-V2 - Create TopBarContainerController wrapper for content screens |
| **Story Points** | 8 |
| **Priority** | High |
| **Labels** | `ios`, `BF`, `BF-V2`, `infrastructure`, `navigation`, `ui` |

**Description**:
Create the TopBarContainerController that wraps content screens with a consistent top bar (logo, search, profile/wallet). This centralizes authentication and profile callbacks.

**Acceptance Criteria**:
- [ ] `TopBarContainerController.swift`:
  - Container view controller with top bar area + content area
  - Top bar with: Logo, Search button, Profile/Wallet section
  - Child view controller embedded in content area
- [ ] `TopBarContainerViewModel.swift`:
  - `UserSessionStore` observer for logged/anonymous state
  - Balance publisher for wallet display
  - Profile image publisher
- [ ] Logged-in state:
  - Profile picture button → `onProfileRequested`
  - Balance display → `onDepositRequested`
- [ ] Anonymous state:
  - Login button → `onLoginRequested`
  - Register button → `onRegisterRequested`
- [ ] Navigation callbacks set by coordinator:
  - `onLoginRequested: (() -> Void)?`
  - `onRegisterRequested: (() -> Void)?`
  - `onProfileRequested: (() -> Void)?`
  - `onDepositRequested: (() -> Void)?`
  - `onSearchRequested: (() -> Void)?`
- [ ] StyleProvider theming
- [ ] Usage pattern documented for coordinators

**Dependencies**: COORD-01

**Reference**: `/BetssonCameroonApp/App/Screens/Containers/TopBarContainerController.swift`

---

## Feature Area 3: Main Tab Bar UI (2 tickets)

### TAB-01: Create MainTabBarViewController

| Field | Value |
|-------|-------|
| **Summary** | [iOS] BF-V2 - Create MainTabBarViewController custom tab bar |
| **Story Points** | 13 |
| **Priority** | Highest |
| **Labels** | `ios`, `BF`, `BF-V2`, `infrastructure`, `ui`, `navigation` |

**Description**:
Create the custom MainTabBarViewController that manages tab selection and content display. This is NOT UITabBarController - it's a custom implementation with base views for each tab.

**Acceptance Criteria**:
- [ ] `MainTabBarViewController.swift`:
  - Custom tab bar at bottom (not UITabBarController)
  - Container views for each tab content
  - Tab buttons with icons and labels
- [ ] `TabItem` enum defining available tabs:
  ```swift
  enum TabItem: CaseIterable {
      case home
      case preLive  // Sports/Pre-live
      case live     // In-play
      case myBets
      case search
  }
  ```
- [ ] Tab button configuration:
  - Icon image (selected/unselected states)
  - Title label
  - Badge support (for live count, betslip count)
- [ ] Base views for lazy content embedding:
  - `homeBaseView`, `preLiveBaseView`, `liveBaseView`, etc.
- [ ] Tab selection:
  - `onTabSelected: ((TabItem) -> Void)?` callback
  - Visual state update (alpha, color changes)
  - Content view visibility toggling
- [ ] Methods for coordinator to embed content:
  - `showHomeScreen(with viewController: UIViewController)`
  - `showPreLiveScreen(with viewController: UIViewController)`
  - etc.
- [ ] Badge update methods:
  - `updateLiveBadge(count: Int)`
  - `updateBetslipBadge(count: Int)`
- [ ] StyleProvider theming
- [ ] Floating action buttons area (betslip FAB)

**Dependencies**: COORD-01

**Reference**: `/BetssonCameroonApp/App/Screens/MainTabBar/MainTabBarViewController.swift`

---

### TAB-02: Create MainTabBarViewModel

| Field | Value |
|-------|-------|
| **Summary** | [iOS] BF-V2 - Create MainTabBarViewModel for tab state management |
| **Story Points** | 5 |
| **Priority** | High |
| **Labels** | `ios`, `BF`, `BF-V2`, `infrastructure`, `viewmodel` |

**Description**:
Create the ViewModel for MainTabBarViewController managing tab state, badges, and user session display.

**Acceptance Criteria**:
- [ ] `MainTabBarViewModelProtocol.swift`:
  - `selectedTabPublisher: AnyPublisher<TabItem, Never>`
  - `liveCountPublisher: AnyPublisher<Int, Never>`
  - `betslipCountPublisher: AnyPublisher<Int, Never>`
  - `userSessionPublisher: AnyPublisher<UserSessionStatus, Never>`
  - `balancePublisher: AnyPublisher<String?, Never>`
- [ ] `MainTabBarViewModel.swift` implementing protocol:
  - BetslipManager integration for betslip count
  - EventsProvider subscription for live match count
  - UserSessionStore for login state
  - Balance formatting
- [ ] `MockMainTabBarViewModel.swift` for previews
- [ ] Tab visibility rules (can add feature flags later)

**Dependencies**: TAB-01, INFRA-02

**Reference**: `/BetssonCameroonApp/App/Screens/MainTabBar/`

---

## Feature Area 4: Core Screen Coordinators (5 tickets)

### SCREEN-01: Create HomeCoordinator

| Field | Value |
|-------|-------|
| **Summary** | [iOS] BF-V2 - Create HomeCoordinator for home screen navigation |
| **Story Points** | 13 |
| **Priority** | Highest |
| **Labels** | `ios`, `BF`, `BF-V2`, `coordinator`, `home` |

**Description**:
Create the HomeCoordinator managing the home/sportsbook feed screen and its navigation flows.

**Acceptance Criteria**:
- [ ] `HomeCoordinator.swift` conforming to `Coordinator`
- [ ] Creates and owns `HomeViewController`
- [ ] Creates `HomeViewModel` with ServicesProvider
- [ ] Navigation closures for MainTabBarCoordinator:
  - `onShowMatchDetail: ((Match) -> Void)?`
  - `onShowCompetition: ((Competition) -> Void)?`
  - `onShowBetslip: (() -> Void)?`
  - `onShowLogin: (() -> Void)?`
  - `onShowBannerURL: ((String, String?) -> Void)?`
- [ ] Public API:
  - `var viewController: UIViewController?`
  - `func refresh()`
- [ ] ViewModel callback wiring:
  - Match selection → `onShowMatchDetail`
  - Banner tap → `onShowBannerURL`
- [ ] Wrapped with TopBarContainerController

**Dependencies**: COORD-03, COORD-05

**Reference**: `/BetssonCameroonApp/App/Coordinators/Screens/` (pattern from NextUpEventsCoordinator)

---

### SCREEN-02: Create PreLiveEventsCoordinator and InPlayEventsCoordinator

| Field | Value |
|-------|-------|
| **Summary** | [iOS] BF-V2 - Create sports events coordinators for pre-live and live tabs |
| **Story Points** | 13 |
| **Priority** | Highest |
| **Labels** | `ios`, `BF`, `BF-V2`, `coordinator`, `events` |

**Description**:
Create coordinators for pre-live (upcoming) and in-play (live) sports events tabs. These share similar structure but different data sources.

**Acceptance Criteria**:
- [ ] `PreLiveEventsCoordinator.swift`:
  - Creates `PreLiveEventsViewController` + `PreLiveEventsViewModel`
  - Subscribes to pre-live events via EventsProvider
  - Sport selection support
  - Filter support
- [ ] `InPlayEventsCoordinator.swift`:
  - Creates `InPlayEventsViewController` + `InPlayEventsViewModel`
  - Subscribes to live events via EventsProvider
  - Real-time updates
  - Sport selection support
- [ ] Shared navigation closures:
  - `onShowMatchDetail: ((Match) -> Void)?`
  - `onShowSportsSelector: (() -> Void)?`
  - `onShowFilters: (() -> Void)?`
  - `onShowBetslip: (() -> Void)?`
- [ ] Public API for both:
  - `var viewController: UIViewController?`
  - `func refresh()`
  - `func updateSport(_ sport: Sport)`
  - `func updateFilters(_ filters: AppliedEventsFilters)`
- [ ] Wrapped with TopBarContainerController

**Dependencies**: COORD-03, COORD-05

**Reference**:
- `/BetssonCameroonApp/App/Coordinators/NextUpEventsCoordinator.swift`
- `/BetssonCameroonApp/App/Coordinators/InPlayEventsCoordinator.swift`

---

### SCREEN-03: Create MyBetsCoordinator

| Field | Value |
|-------|-------|
| **Summary** | [iOS] BF-V2 - Create MyBetsCoordinator for betting history tab |
| **Story Points** | 8 |
| **Priority** | Highest |
| **Labels** | `ios`, `BF`, `BF-V2`, `coordinator`, `mybets` |

**Description**:
Create the coordinator for My Bets tab showing user's betting history and active tickets.

**Acceptance Criteria**:
- [ ] `MyBetsCoordinator.swift` conforming to `Coordinator`
- [ ] Creates `MyBetsViewController` + `MyBetsViewModel`
- [ ] Navigation closures:
  - `onShowLogin: (() -> Void)?`
  - `onNavigateToBetDetail: ((MyBet) -> Void)?`
  - `onNavigateToBetslip: ((Int?, Int?) -> Void)?` (success/fail counts)
  - `onShareTicket: ((BettingTicket) -> Void)?`
- [ ] Public API:
  - `var viewController: UIViewController?`
  - `func refresh()`
- [ ] Anonymous state handling (show login prompt)
- [ ] Wrapped with TopBarContainerController

**Dependencies**: COORD-03, COORD-05

**Reference**: `/BetssonCameroonApp/App/Coordinators/MyBetsCoordinator.swift`

---

### SCREEN-04: Create BetslipCoordinator

| Field | Value |
|-------|-------|
| **Summary** | [iOS] BF-V2 - Create BetslipCoordinator for bet placement modal |
| **Story Points** | 13 |
| **Priority** | Highest |
| **Labels** | `ios`, `BF`, `BF-V2`, `coordinator`, `betslip` |

**Description**:
Create the coordinator for the betslip modal where users review and place bets.

**Acceptance Criteria**:
- [ ] `BetslipCoordinator.swift` conforming to `Coordinator`
- [ ] Creates `BetslipViewController` + `BetslipViewModel`
- [ ] Modal presentation (not push navigation)
- [ ] Navigation closures:
  - `onCloseBetslip: (() -> Void)?`
  - `onShowRegistration: (() -> Void)?`
  - `onShowLogin: (() -> Void)?`
  - `onBetPlaced: (([BettingTicket]) -> Void)?`
- [ ] Success flow:
  - Bet placed → show `BetSuccessViewController`
  - Success screen callbacks: continue, view details, share
- [ ] Booking code/share flow:
  - Create booking code via API
  - Present `ShareBookingCodeViewController`
- [ ] BetslipManager integration for selections
- [ ] Bonus selection support (FreeBet, OddsBoost)
- [ ] Error handling and display

**Dependencies**: COORD-03

**Reference**: `/BetssonCameroonApp/App/Coordinators/Screens/BetslipCoordinator.swift`

---

### SCREEN-05: Create ProfileWalletCoordinator and BankingCoordinator

| Field | Value |
|-------|-------|
| **Summary** | [iOS] BF-V2 - Create profile and banking modal coordinators |
| **Story Points** | 8 |
| **Priority** | High |
| **Labels** | `ios`, `BF`, `BF-V2`, `coordinator`, `profile`, `banking` |

**Description**:
Create coordinators for profile/wallet display and banking (deposit/withdraw) modals.

**Acceptance Criteria**:
- [ ] `ProfileWalletCoordinator.swift`:
  - Modal presentation with dedicated navigation controller
  - Creates `ProfileWalletViewController`
  - Shows user profile, balance, quick actions
  - Navigation closures:
    - `onProfileDismiss: (() -> Void)?`
    - `onDepositRequested: (() -> Void)?`
    - `onWithdrawRequested: (() -> Void)?`
    - `onSettingsRequested: (() -> Void)?`
    - `onLogoutRequested: (() -> Void)?`
- [ ] `BankingCoordinator.swift`:
  - Factory pattern for deposit vs withdraw:
    - `BankingCoordinator.forDeposit(...)`
    - `BankingCoordinator.forWithdraw(...)`
  - Payment methods display
  - Web view integration for payment forms
  - Navigation closures:
    - `onTransactionComplete: (() -> Void)?`
    - `onTransactionCancel: (() -> Void)?`
    - `onTransactionError: ((String) -> Void)?`
  - Bonus code support for deposits

**Dependencies**: COORD-03

**Reference**:
- `/BetssonCameroonApp/App/Coordinators/ProfileWalletCoordinator.swift`
- `/BetssonCameroonApp/App/Coordinators/BankingCoordinator.swift`

---

## Summary

### Total Infrastructure Tickets: 15

| Priority | Count | Story Points |
|----------|-------|--------------|
| Highest  | 10    | 97 SP        |
| High     | 5     | 34 SP        |
| **Total**| **15**| **131 SP**   |

### Estimated Timeline (assuming 1 SP ≈ 1 hour)
- **131 Story Points** ≈ **~16-17 working days** for one developer
- Recommended: 2 developers in parallel can complete in ~2 weeks

### Implementation Order

**Phase 1: Foundation (Week 1)**
1. INFRA-01: Create Xcode project
2. INFRA-02: Configure Environment/ServicesProvider
3. INFRA-03: Create AppStateManager
4. COORD-01: Coordinator protocol

**Phase 2: Core Navigation (Week 1-2)**
5. COORD-02: AppCoordinator
6. TAB-01: MainTabBarViewController
7. TAB-02: MainTabBarViewModel
8. COORD-03: MainTabBarCoordinator

**Phase 3: Supporting Coordinators (Week 2)**
9. COORD-04: Splash/Maintenance coordinators
10. COORD-05: TopBarContainerController

**Phase 4: Screen Coordinators (Week 2-3)**
11. SCREEN-01: HomeCoordinator
12. SCREEN-02: PreLive/InPlay coordinators
13. SCREEN-03: MyBetsCoordinator
14. SCREEN-04: BetslipCoordinator
15. SCREEN-05: Profile/Banking coordinators

---

## Critical Files for Reference

### BetssonCameroonApp Architecture
```
BetssonCameroonApp/
├── App/
│   ├── Boot/
│   │   ├── Environment.swift
│   │   ├── AppStateManager.swift
│   │   └── TargetVariables.swift
│   ├── Coordinators/
│   │   ├── Coordinator.swift
│   │   ├── AppCoordinator.swift
│   │   ├── MainTabBarCoordinator.swift
│   │   ├── SplashCoordinator.swift
│   │   ├── MaintenanceCoordinator.swift
│   │   └── Screens/
│   │       ├── NextUpEventsCoordinator.swift
│   │       ├── InPlayEventsCoordinator.swift
│   │       ├── MyBetsCoordinator.swift
│   │       ├── BetslipCoordinator.swift
│   │       ├── ProfileWalletCoordinator.swift
│   │       └── BankingCoordinator.swift
│   └── Screens/
│       ├── MainTabBar/
│       │   ├── MainTabBarViewController.swift
│       │   └── MainTabBarViewModel.swift
│       └── Containers/
│           └── TopBarContainerController.swift
```

### Key Patterns to Follow
1. **Closure-based navigation** (not delegates)
2. **Lazy coordinator loading** for tabs
3. **TopBarContainerController wrapper** for all content screens
4. **Protocol-driven ViewModels** with Mock implementations
5. **Combine publishers** for reactive state
6. **ViewControllers NEVER create Coordinators**

---

## Notes for YAML Generation

When creating Jira tickets from this document:

```yaml
# Example ticket structure
- summary: "[iOS] BF-V2 - {ticket title}"
  project_key: SPOR
  issuetype_name: Story
  story_points: {SP value}
  labels:
    - ios
    - BF
    - BF-V2
    - infrastructure
  priority: {Highest|High|Medium}
  flagged: {true if Highest priority}
  description: |
    {Description from ticket}

    **Acceptance Criteria:**
    {AC list}

    **Dependencies:** {deps}

    **Reference:** {file paths}
```
