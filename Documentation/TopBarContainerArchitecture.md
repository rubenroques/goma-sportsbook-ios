# TopBarContainer Architecture

## Overview

The **TopBarContainerController** is a container view controller pattern designed to eliminate code duplication across screens that share a common top bar (MultiWidget toolbar). It manages the top bar UI, wallet status overlays, and popup presentations while keeping content view controllers clean and focused.

## Problem Statement

### Current Issues
- **~200 lines of duplicated code** across 4+ view controllers
- **Repeated UI setup** for top bar components in every screen
- **Duplicated callback handling** for authentication, wallet, and navigation
- **Inconsistent overlay management** across different screens
- **Maintenance burden** when updating top bar behavior

### Affected Files
- `MainTabBarViewController.swift` - 1154 lines (formerly RootTabBarViewController)
- `MatchDetailsTextualViewController.swift` - 748 lines
- `MyBetDetailViewController.swift` - 418 lines
- `CasinoCategoryGamesListViewController.swift` - 424 lines

## Architecture Design

### Core Concept

The TopBarContainerController acts as a **presentation container** that wraps content view controllers, providing:

1. **Centralized top bar management** - Single source of truth for MultiWidget toolbar
2. **Overlay capabilities** - Full-screen overlays for wallet status, deposits, etc.
3. **Clean separation** - Content VCs have zero top bar code
4. **Navigation independence** - Works with standard UINavigationController

### Visual Architecture

```
┌─────────────────────────────────────────┐
│     UINavigationController              │ ← Standard iOS navigation
│  ┌────────────────────────────────────┐ │
│  │  TopBarContainerController         │ │ ← Container (manages chrome)
│  │  ┌────────────────────────────────┐│ │
│  │  │ Top Safe Area (status bar bg)  ││ │
│  │  ├────────────────────────────────┤│ │
│  │  │ MultiWidget Toolbar            ││ │ ← Centralized top bar
│  │  ├────────────────────────────────┤│ │
│  │  │ Content Container              ││ │
│  │  │ ┌────────────────────────────┐ ││ │
│  │  │ │  Your ViewController       │ ││ │ ← Clean content VC
│  │  │ │  (No top bar code!)        │ ││ │
│  │  │ └────────────────────────────┘ ││ │
│  │  ├────────────────────────────────┤│ │
│  │  │ Overlay Container (full screen)││ │ ← Popups & overlays
│  │  └────────────────────────────────┘│ │
│  └────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### Layer Structure

```
Z-Index Layers:
┌─────────────────┐
│ 4. Overlays     │ ← Wallet status, deposits, popups
├─────────────────┤
│ 3. Top Bar      │ ← MultiWidget toolbar
├─────────────────┤
│ 2. Content      │ ← Your view controller
├─────────────────┤
│ 1. Background   │ ← Top safe area
└─────────────────┘
```

## Implementation

### TopBarContainerController

```swift
class TopBarContainerController: UIViewController {
    // MARK: - Core Components
    private let contentViewController: UIViewController
    private let contentContainerView = UIView()

    // MARK: - Top Bar
    private let multiWidgetToolbarView: MultiWidgetToolbarView
    private let multiWidgetViewModel: MultiWidgetToolbarViewModelProtocol

    // MARK: - Overlays
    private let overlayContainerView = UIView() // Full screen
    private let walletStatusView: WalletStatusView

    // MARK: - Navigation Callbacks
    var onLoginRequested: (() -> Void)?
    var onRegistrationRequested: (() -> Void)?
    var onDepositRequested: (() -> Void)?

    // MARK: - Public API
    func showWalletStatusOverlay()
    func hideWalletStatusOverlay()
    func showDepositPopup()
    func showCustomPopup(_ vc: UIViewController, style: PopupStyle)
}
```

### Content View Controller Extension

```swift
extension UIViewController {
    // Access to container from content VCs
    var topBarContainer: TopBarContainerController? { get }
}
```

## Usage Patterns

### 1. Basic Usage

```swift
// In Coordinator
func showMatchDetails() {
    // 1. Create content VC (clean, no top bar)
    let contentVC = MatchDetailsViewController(viewModel: matchVM)

    // 2. Wrap in container
    let container = TopBarContainerController(
        contentViewController: contentVC,
        multiWidgetViewModel: multiWidgetVM,
        walletStatusViewModel: walletVM
    )

    // 3. Setup callbacks
    container.onLoginRequested = { [weak self] in
        self?.showLogin()
    }

    // 4. Push using standard navigation
    navigationController.pushViewController(container, animated: true)
}
```

### 2. Content View Controller

```swift
// BEFORE: 200+ lines with top bar code
class MatchDetailsViewController: UIViewController {
    private lazy var topSafeAreaView = ...
    private lazy var multiWidgetToolbarView = ...
    // ... 200 lines of duplicate code
}

// AFTER: Clean, focused on content
class MatchDetailsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMatchDetailsUI() // Just your content!
    }

    // Can trigger container features if needed
    func showSpecialOffer() {
        topBarContainer?.showCustomPopup(offerVC, style: .halfScreen)
    }
}
```

### 3. Popup Presentation Styles

```swift
enum PopupStyle {
    case halfScreen    // iOS sheet presentation
    case fullScreen    // Modal full screen
    case overlay       // Custom overlay in container
    case bottomSheet   // Bottom sheet style
}

// Usage
container.showCustomPopup(depositVC, style: .halfScreen)
```

## Migration Guide

### Phase 1: Setup Infrastructure
1. Create `TopBarContainerController.swift`
2. Create `PopupStyle.swift` enum
3. Add `UIViewController+TopBarContainer.swift` extension

### Phase 2: Pilot Migration (1 screen)
1. Choose `MatchDetailsTextualViewController` as pilot
2. Create clean version without top bar code
3. Update coordinator to use container
4. Test all functionality

### Phase 3: Gradual Migration
1. Migrate one screen at a time
2. Keep old code during transition
3. Update coordinators progressively
4. Remove duplicate code after verification

### Phase 4: Cleanup
1. Remove all duplicate top bar code
2. Delete unused view models
3. Update documentation

## Migration Checklist

### Per Screen Migration

- [ ] Create backup of original VC
- [ ] Remove top bar UI components
- [ ] Remove wallet overlay code
- [ ] Remove authentication callbacks
- [ ] Remove deposit handling
- [ ] Update coordinator to use container
- [ ] Test all user flows
- [ ] Remove backup after verification

### Code to Remove

```swift
// Remove from each VC:
- private lazy var topSafeAreaView
- private lazy var topBarContainerBaseView
- private lazy var multiWidgetToolbarView
- private lazy var walletStatusOverlayView
- private lazy var walletStatusView
- var onLoginRequested: (() -> Void)?
- var onRegistrationRequested: (() -> Void)?
- var onDepositRequested: (() -> Void)?
- func showWalletStatusOverlay()
- func hideWalletStatusOverlay()
- func setupMultiWidgetToolbarView()
- func handleWidgetSelection()
```

## Benefits

### Immediate Benefits
- **Eliminate ~800 lines** of duplicate code
- **Single source of truth** for top bar behavior
- **Consistent overlay behavior** across all screens
- **Simplified testing** - Test container once

### Long-term Benefits
- **Easier maintenance** - Update in one place
- **Faster feature development** - New screens get top bar for free
- **Better separation of concerns** - Content VCs focus on content
- **Reusable pattern** - Can apply to other shared UI

## Best Practices

### DO ✅
- Keep content VCs completely free of top bar code
- Use coordinator pattern for navigation callbacks
- Configure container in coordinator, not in content VC
- Use consistent popup styles across the app
- Test overlay dismissal and memory management

### DON'T ❌
- Don't access multiWidgetToolbarView directly from content VC
- Don't handle navigation in the container
- Don't create multiple containers for the same screen
- Don't forget to set up callbacks in coordinator
- Don't mix old pattern with new pattern

## Testing Strategy

### Unit Tests
```swift
class TopBarContainerControllerTests: XCTestCase {
    func testContentEmbedding()
    func testOverlayPresentation()
    func testCallbackExecution()
    func testMemoryManagement()
}
```

### Integration Tests
```swift
class TopBarIntegrationTests: XCTestCase {
    func testNavigationFlow()
    func testWalletOverlayFlow()
    func testDepositPopupFlow()
    func testAuthenticationFlow()
}
```

## Future Enhancements

### Potential Features
1. **Dynamic top bar configuration** - Hide/show based on content
2. **Animated transitions** - Custom animations for overlays
3. **Gesture support** - Swipe to dismiss overlays
4. **Theme switching** - Dark/light mode in container
5. **A/B testing** - Different top bar variants

### Extensibility
```swift
// Future: TopBarConfiguration
struct TopBarConfiguration {
    var isVisible: Bool = true
    var walletEnabled: Bool = true
    var profileEnabled: Bool = true
    var backgroundColor: UIColor?
}

// Content VC could configure:
override func viewWillAppear() {
    topBarContainer?.configure(TopBarConfiguration(
        walletEnabled: false // Hide wallet for this screen
    ))
}
```

## Conclusion

The TopBarContainerController architecture provides a clean, maintainable solution to eliminate code duplication while maintaining flexibility. It follows iOS patterns, works with existing navigation, and significantly reduces the codebase complexity.

### Metrics
- **Code reduction**: ~800 lines removed
- **Files simplified**: 4+ view controllers
- **Maintenance effort**: 75% reduction
- **New screen setup**: From 200 lines to 5 lines

---

## Updates

### September 17, 2025 - MainTabBar Rename
- **Renamed** `RootTabBarViewController` → `MainTabBarViewController` for architectural clarity
- **Renamed** `RootTabBarViewModel` → `MainTabBarViewModel`
- **Renamed** `RootTabBarCoordinator` → `MainTabBarCoordinator`
- **Moved** from `/Screens/Root/` to `/Screens/Main/` directory
- **Rationale**: After TopBarContainerController became the actual root container, "MainTabBar" better reflects the component's role as the main tab navigation manager

---

*Architecture documented on September 16, 2025*
*Updated on September 17, 2025 - MainTabBar rename*