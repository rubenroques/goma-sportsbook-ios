# Coordinator Refactor Plan for BetssonCameroonApp

## Overview
This document outlines the complete refactoring plan to implement the Coordinator pattern with proper AppStateManager architecture for BetssonCameroonApp, while preserving all existing custom UI components and functionality.

## Current Architecture Problems

### 1. Bootstrap Issues
- **Mixed Responsibilities**: Handles both business logic (services, theme loading) AND view controller creation
- **Tight Coupling**: Direct view controller instantiation violates MVVM-Coordinator principles
- **Hard to Test**: Business logic mixed with UI creation makes testing difficult

### 2. Router Issues (Router.swift)
- **God Object**: 385 lines handling everything from window management to deep linking
- **Empty Methods**: Placeholder methods that do nothing (showMatchDetailScreen, showBetslip, etc.)
- **Knowledge Violation**: Direct knowledge of specific ViewControllers
- **Mixed Concerns**: UI presentation, deep linking, app lifecycle, push notifications

### 3. RootAdaptiveViewController Issues
- **Massive Class**: 1,236 lines doing everything
- **Mixed Concerns**: View presentation, navigation, authentication, modal management
- **Global Dependencies**: Hardcoded `Env` usage throughout

### 4. SplashInformativeViewController Issues
- **Business Logic in UI**: Theme fetching, configuration loading, sports data subscription
- **Wrong Layer**: UI component handling app initialization concerns

## New Architecture Design

### Core Principles
1. **Single Responsibility**: Each class has one clear purpose
2. **AppStateManager Pattern**: Central state management drives navigation decisions
3. **Coordinator Pattern**: Navigation logic separated from view logic  
4. **MVVM Compliance**: ViewModels never handle navigation
5. **Dependency Injection**: No global singletons in coordinators

### App State Flow
```
App Launch → Firebase Init → Remote Config Check → Parallel Service Loading → Main App

Blocking States: Maintenance Mode (full screen root)
Modal States: Required Update (undismissible modal), Available Update (dismissible modal)
```

## Detailed Refactor Plan

### Phase 1: Create AppStateManager (Evolution of Bootstrap)

#### 1.1 App States Definition
```swift
enum AppState {
    case initializing
    case splashLoading
    case maintenanceMode(message: String)           // Full screen root
    case updateRequired(version: String)            // Undismissible modal
    case updateAvailable(version: String)           // Dismissible modal
    case servicesConnecting                         // Parallel loading
    case ready(sportsData: [Sport])                 // Main app ready
    case error(AppError)
}

enum AppError {
    case sportsLoadingFailed(Error)
    case serviceConnectionFailed(Error)
    case configurationLoadFailed(Error)
}
```

#### 1.2 AppStateManager Implementation
**File**: `BetssonCameroonApp/App/State/AppStateManager.swift`

**Responsibilities**:
- App initialization and Firebase setup
- Remote config monitoring for maintenance/updates
- **Parallel service loading** (theme, configuration, sports data)
- Business settings socket connection management
- **Publishing app state changes** (not handling UI)

**Key Methods**:
- `initialize()` - Start app initialization sequence with Firebase
- `loadServicesInParallel()` - Load theme, config, and sports data concurrently
- `retryFromError()` - Retry after error states
- `dismissAvailableUpdate()` - Continue after dismissing optional update

**Parallel Loading Strategy**:
Based on existing Bootstrap.swift and SplashInformativeViewController.swift logic:

```swift
// After maintenance mode check passes, load services in parallel
func loadServicesInParallel() {
    // Start theme loading (from SplashInformativeViewController:79)
    ThemeService.shared.fetchThemeFromServer()
    
    // Start configuration loading (from SplashInformativeViewController:82)
    Env.presentationConfigurationStore.loadConfiguration()
    
    // Connect service provider (from Bootstrap:85-98)
    environment.servicesProvider.connect()
    environment.betslipManager.start()
    
    // Wait for events connection, then request sports data
    environment.servicesProvider.eventsConnectionStatePublisher
        .filter { $0 == .connected }
        .flatMap { _ in Env.sportsStore.activeSportsPublisher }
        .sink { [weak self] sportsState in
            if case .loaded(let sports) = sportsState {
                self?.transitionToReady(sports: sports)
            }
        }
}
```

This maintains the existing parallel loading behavior while centralizing state management.

### Phase 2: Create Coordinator Infrastructure

#### 2.1 Base Coordinator Protocol
**File**: `BetssonCameroonApp/App/Coordinators/Coordinator.swift`

```swift
protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
    func finish()
}
```

#### 2.2 AppCoordinator (Root Navigation Logic)
**File**: `BetssonCameroonApp/App/Coordinators/AppCoordinator.swift`

**Responsibilities**:
- React to AppStateManager state changes
- Delegate to appropriate coordinators based on state
- **No business logic** - only navigation decisions
- Handle coordinator lifecycle management

**State Handling**:
- `.splashLoading` → SplashCoordinator
- `.maintenanceMode` → MaintenanceCoordinator (full screen root)
- `.updateRequired` → RequiredUpdateCoordinator (undismissible modal)
- `.updateAvailable` → AvailableUpdateModalCoordinator (dismissible modal)
- `.ready` → MainCoordinator (main app)

### Phase 3: Specific Coordinators

#### 3.1 SplashCoordinator (Pure UI Management)
**File**: `BetssonCameroonApp/App/Coordinators/SplashCoordinator.swift`

**Responsibilities**:
- Display splash screen UI with existing animations
- Handle splash-specific UI interactions (network alerts)
- **No business logic** - only UI presentation
- Use existing SplashInformativeViewController (refactored)

#### 3.2 MaintenanceCoordinator
**File**: `BetssonCameroonApp/App/Coordinators/MaintenanceCoordinator.swift`

**Responsibilities**:
- Present maintenance screen as **full screen root** (not modal)
- Display maintenance message from remote config
- Handle maintenance screen dismissal (when maintenance ends)
- Block all other app functionality during maintenance

#### 3.3 Update Coordinators
**Files**: 
- `BetssonCameroonApp/App/Coordinators/RequiredUpdateCoordinator.swift`
- `BetssonCameroonApp/App/Coordinators/AvailableUpdateModalCoordinator.swift`

**RequiredUpdateCoordinator** (Undismissible Modal):
- **Modal presentation** over any current screen
- User cannot dismiss or proceed without updating
- Blocks all app functionality until update
- Handles App Store redirection

**AvailableUpdateModalCoordinator** (Dismissible Modal):
- **Modal presentation** over main app
- User can dismiss and continue using app
- Handles App Store redirection
- Can be presented over normal app flow

#### 3.4 MainCoordinator (Tab Management)
**File**: `BetssonCameroonApp/App/Coordinators/MainCoordinator.swift`

**Responsibilities**:
- Manage RootAdaptiveViewController integration
- Handle tab switching between screens using closures
- Lazy loading of screen coordinators
- Modal navigation coordination

### Phase 4: Screen Coordinators

#### 4.1 Base Screen Coordinator
**File**: `BetssonCameroonApp/App/Coordinators/Base/BaseScreenCoordinator.swift`

**Responsibilities**:
- Handle view controller embedding in existing base views
- Manage dependencies and lifecycle
- Abstract common screen coordinator functionality

#### 4.2 Screen-Specific Coordinators
**Files**:
- `BetssonCameroonApp/App/Coordinators/Screens/NextUpEventsCoordinator.swift`
- `BetssonCameroonApp/App/Coordinators/Screens/InPlayEventsCoordinator.swift`

**Pattern**:
```swift
class NextUpEventsCoordinator: BaseScreenCoordinator {
    // Navigation closures (instead of delegates)
    var onShowMatchDetail: ((String) -> Void)?
    var onShowCompetition: ((String) -> Void)?
    
    override func start() {
        let viewModel = NextUpEventsViewModel(/* inject dependencies */)
        let viewController = NextUpEventsViewController(viewModel: viewModel)
        
        // Setup navigation closures in ViewModel
        viewModel.onMatchSelected = { [weak self] matchId in
            self?.onShowMatchDetail?(matchId)
        }
        
        embedViewController(viewController)
    }
}
```

### Phase 5: Refactor Existing Components

#### 5.1 SplashInformativeViewController Refactor
**File**: `BetssonCameroonApp/App/Screens/Splash/SplashInformativeViewController.swift`

**Remove (Move to AppStateManager)**:
- Theme fetching logic (`ThemeService.shared.fetchThemeFromServer()`)
- Configuration loading (`Env.presentationConfigurationStore.loadConfiguration()`)
- Sports data subscription (`Env.sportsStore.activeSportsPublisher`)
- Direct Environment dependencies
- All business logic from viewDidAppear

**Keep**:
- UI presentation and gradient animations
- Timer-based loading message rotation
- Network connectivity UI alerts (user-facing)
- Activity indicators and brand display

#### 5.2 Bootstrap Integration
**File**: `BetssonCameroonApp/App/Boot/Bootstrap.swift`

**Changes**:
- Remove direct view controller creation
- Keep GomaUI setup and theme configuration
- Initialize AppCoordinator instead of Router flow
- Maintain existing service registration

#### 5.3 RootAdaptiveViewController Simplification
**File**: `BetssonCameroonApp/App/Screens/Root/RootAdaptiveViewController.swift`

**Changes**:
- Remove tab selection handling logic (move to MainCoordinator)
- Make `hideAllScreens()` and base views accessible to coordinators
- Keep all existing UI structure and animations
- Remove navigation logic, keep only view presentation

#### 5.4 Router Deprecation Strategy
**File**: `BetssonCameroonApp/App/Boot/Router.swift`

**Phase 1**: Keep existing Router for deep linking compatibility
**Phase 2**: Gradually migrate deep linking to coordinators
**Future**: Complete Router removal after deep linking migration

## Implementation Steps

### Step 1: Create AppStateManager
- [x] Create `AppStateManager.swift` with state enum and reactive publishers
- [x] Implement parallel loading strategy combining Bootstrap + Splash logic
- [x] Add maintenance mode monitoring from businessSettingsSocket
- [x] Add update checking from Firebase remote config
- [ ] Test parallel service loading and state transitions

### Step 2: Create Coordinator Infrastructure  
- [x] Create base `Coordinator.swift` protocol
- [x] Create `AppCoordinator.swift` with state observation
- [ ] Test coordinator creation and navigation controller setup

### Step 3: Create SplashCoordinator
- [ ] Create `SplashCoordinator.swift` for UI management
- [ ] Refactor `SplashInformativeViewController.swift` to remove business logic
- [ ] Test splash screen presentation

### Step 4: Create Maintenance/Update Coordinators
- [ ] Create `MaintenanceCoordinator.swift` (full screen root presentation)
- [ ] Create `RequiredUpdateCoordinator.swift` (undismissible modal)
- [ ] Create `AvailableUpdateModalCoordinator.swift` (dismissible modal)
- [ ] Test maintenance full screen vs modal update presentations

### Step 5: Create MainCoordinator
- [x] Create `MainCoordinator.swift` with tab management
- [x] Integrate with existing `RootAdaptiveViewController`
- [ ] Test tab switching and lazy loading

### Step 6: Create Screen Coordinators
- [x] ~~Create `BaseScreenCoordinator.swift`~~ (Removed - unnecessary complexity)
- [x] Create `NextUpEventsCoordinator.swift`
- [x] Create `InPlayEventsCoordinator.swift`
- [ ] Test screen presentation and navigation closures

### Step 7: Integration and Testing
- [x] Update `Bootstrap.swift` to use AppCoordinator
- [x] Update `AppDelegate.swift` entry point
- [ ] Test complete app flow from launch to main app
- [ ] Test all error states and edge cases

### Step 8: Validation
- [ ] Verify all existing functionality works
- [ ] Test deep linking still works
- [ ] Test push notifications still work
- [ ] Test authentication flows still work
- [ ] Test maintenance mode and update scenarios

## File Structure

```
BetssonCameroonApp/App/
├── Coordinators/
│   ├── Coordinator.swift                   # Base protocol
│   ├── AppCoordinator.swift               # Root coordinator
│   ├── SplashCoordinator.swift            # Splash UI management
│   ├── MainCoordinator.swift              # Tab management
│   ├── MaintenanceCoordinator.swift       # Maintenance screen
│   ├── RequiredUpdateCoordinator.swift    # Blocking update
│   ├── AvailableUpdateModalCoordinator.swift # Non-blocking update
│   ├── Base/
│   │   └── BaseScreenCoordinator.swift    # Screen coordinator base
│   └── Screens/
│       ├── NextUpEventsCoordinator.swift
│       └── InPlayEventsCoordinator.swift
├── State/
│   └── AppStateManager.swift              # Central state management
├── Boot/
│   ├── Bootstrap.swift                    # Refactored initialization
│   ├── AppDelegate.swift                 # Updated entry point
│   ├── Environment.swift                 # Keep existing
│   └── Router.swift                      # Deprecated gradually
└── Screens/
    ├── Root/
    │   └── RootAdaptiveViewController.swift # Simplified
    └── Splash/
        └── SplashInformativeViewController.swift # Refactored
```

## Benefits of This Architecture

### 1. Clean Separation of Concerns
- **AppStateManager**: Pure business logic and state management
- **Coordinators**: Pure navigation logic
- **ViewControllers**: Pure UI presentation
- **ViewModels**: Pure business logic with navigation signals

### 2. Better Testability
- **State Logic**: Test AppStateManager independently
- **Navigation Logic**: Test coordinators with mock dependencies
- **UI Logic**: Test view controllers with mock view models
- **Integration**: Test complete flows with coordinator integration

### 3. Maintainability
- **Single Responsibility**: Each component has one clear purpose
- **Easy Changes**: Modify app flow without touching UI components
- **Clear Dependencies**: No global state, explicit dependency injection
- **Debugging**: Clear state transitions and navigation decisions

### 4. User Experience
- **Proper Blocking**: Maintenance and required updates block appropriately
- **Non-Intrusive Updates**: Optional updates don't interrupt user flow
- **Smooth Transitions**: Clear state-driven navigation
- **Error Handling**: Proper error states with retry mechanisms

### 5. Preserved Functionality
- **Custom UI**: All existing sophisticated UI components maintained
- **Performance**: Lazy loading and memory efficiency preserved
- **Authentication**: Existing biometric and app state management kept
- **Deep Linking**: Existing Router functionality maintained during transition

## Risk Mitigation

### 1. Gradual Migration
- Implement new architecture alongside existing code
- Migrate one coordinator at a time
- Maintain existing functionality throughout transition
- Comprehensive testing at each step

### 2. Rollback Strategy
- Keep existing Router and Bootstrap as fallback
- Feature flags for coordinator vs legacy navigation
- Ability to quickly revert if issues arise

### 3. Testing Strategy
- Unit tests for AppStateManager state transitions
- Integration tests for coordinator navigation flows
- UI tests for existing functionality preservation
- Performance tests to ensure no regression

This refactoring transforms the app from a mixed, tightly-coupled architecture to a clean, testable, and maintainable MVVM-Coordinator pattern with proper state management.