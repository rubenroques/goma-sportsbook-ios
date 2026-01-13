# @Observable UIKit Components Guide

This guide documents patterns for building reactive UIKit components using Swift's Observation framework without Combine.

> **Important for Production Apps:** BetssonCameroon and BetssonFranceLegacy target **iOS 17+**. Apple's native UIKit auto-tracking requires **iOS 18+**. For iOS 17 support, use [Point-Free's `observe { }` pattern](#alternative-point-frees-observe---pattern) instead.

## Table of Contents

- [The Problem: Combine's Async Rendering](#the-problem-combines-async-rendering)
- [The Solution: @Observable + layoutSubviews()](#the-solution-observable--layoutsubviews)
- [How It Works](#how-it-works)
- [Requirements](#requirements)
- [Alternative: Point-Free's observe { } Pattern](#alternative-point-frees-observe---pattern)
- [Choosing an Approach](#choosing-an-approach)
- [Implementation Pattern](#implementation-pattern)
- [GomaUI Protocol Architecture](#gomaui-protocol-architecture)
- [Migration from Combine](#migration-from-combine)
- [Testing @Observable Components](#testing-observable-components)
- [References](#references)

---

## The Problem: Combine's Async Rendering

### Root Cause

Combine's `.receive(on: DispatchQueue.main)` **always schedules to the next run loop iteration**, even when already on the main thread. This is by design for thread safety, but causes significant issues:

```swift
// Combine pattern - ASYNC delivery
viewModel.statePublisher
    .receive(on: DispatchQueue.main)  // Always defers to next run loop!
    .sink { [weak self] state in
        self?.render(state)  // Runs AFTER current frame
    }
    .store(in: &cancellables)
```

### Symptoms

1. **Empty Snapshot Tests** - Snapshots capture views before Combine delivers values
2. **Broken UITableView/UICollectionView Cell Sizing** - Cells measured before content renders
3. **Visual Flicker** - Brief empty state visible before content appears

### Previous Workarounds

The Combine pattern required complex workarounds:

```swift
// Workaround: Synchronous initial state + async updates
protocol ViewModelProtocol {
    var currentDisplayState: DisplayState { get }      // Sync access
    var displayStatePublisher: AnyPublisher<...> { get } // Async updates
}

// View must render sync first, then subscribe with dropFirst()
func configure(with viewModel: ViewModelProtocol) {
    render(state: viewModel.currentDisplayState)  // Sync render

    viewModel.displayStatePublisher
        .dropFirst()  // Skip initial (already rendered)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] state in self?.render(state: state) }
        .store(in: &cancellables)
}
```

**Problems with this approach:**
- Easy to forget `dropFirst()` causing double renders
- Easy to forget sync initial render causing empty views
- Complex pattern that teammates don't understand
- Requires `CurrentValueSubject` (not `PassthroughSubject`)

---

## The Solution: @Observable + layoutSubviews()

Apple introduced **automatic observation tracking** for UIKit in **iOS 18** (enabled via Info.plist key). This eliminates Combine entirely for UI bindings.

> **iOS Version Clarification:**
> - **iOS 17**: `@Observable` macro available, but UIKit does NOT auto-track it
> - **iOS 18**: UIKit auto-tracks `@Observable` in `layoutSubviews()` (requires plist key)
> - **iOS 26**: Native auto-tracking (no plist key needed)
>
> If targeting iOS 17, see [Point-Free's `observe { }` Pattern](#alternative-point-frees-observe---pattern) which provides the tracking context that UIKit lacks until iOS 18.

### The Pattern

```swift
@Observable
class ScoreViewModel {
    var score: String = "0-0"
    var isLive: Bool = false
}

class ScoreView: UIView {
    var viewModel: ScoreViewModel?

    func configure(with viewModel: ScoreViewModel) {
        self.viewModel = viewModel
        setNeedsLayout()  // Trigger initial render
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let viewModel else { return }

        // Just read properties - UIKit tracks automatically!
        scoreLabel.text = viewModel.score
        liveIndicator.isHidden = !viewModel.isLive
    }
}
```

**That's it.** No Combine, no publishers, no subscriptions, no `setupBindings()`.

### Why It Works

When `UIObservationTrackingEnabled` is enabled:

1. UIKit wraps `layoutSubviews()` in an observation tracking context
2. Any `@Observable` property access is automatically tracked
3. When tracked properties change, UIKit calls `setNeedsLayout()` automatically
4. View re-renders with new values

### Benefits

| Aspect | Combine | @Observable |
|--------|---------|-------------|
| Rendering | Async (next run loop) | **Sync (immediate)** |
| Boilerplate | Protocol + Publishers + setupBindings() | **Just properties** |
| Snapshot tests | Requires workarounds | **Works out of box** |
| Cell sizing | Broken without hacks | **Works correctly** |
| Learning curve | High (reactive concepts) | **Low (just Swift)** |
| Code complexity | High | **Minimal** |

---

## How It Works

### Supported UIView Methods

UIKit automatically tracks `@Observable` property accesses in these methods:

| Method | Purpose |
|--------|---------|
| `layoutSubviews()` | Layout and rendering (most common) |
| `updateConstraints()` | Constraint updates |
| `draw(_:)` | Custom drawing |

### iOS 26+ Additional Method

```swift
// iOS 26+ only - runs before layoutSubviews()
override func updateProperties() {
    super.updateProperties()
    // Property-only updates (no layout changes)
    label.text = viewModel?.title
}
```

For iOS 18, use `layoutSubviews()` for all observation tracking.

---

## Requirements

### Understanding the iOS Version Gap

There are **two separate features** that work together:

| Feature | iOS Version | What It Provides |
|---------|-------------|------------------|
| **`@Observable` macro** | iOS 17+ | Makes classes observable (Swift Observation framework) |
| **UIKit auto-tracking** | iOS 18+ | UIKit automatically tracks `@Observable` in `layoutSubviews()` |
| **Native UIKit auto-tracking** | iOS 26+ | Same as above, but enabled by default (no plist key) |

**The Gap:** On iOS 17, you have `@Observable` but UIKit doesn't do anything with it. The `layoutSubviews()` pattern documented above **only works on iOS 18+**.

### For iOS 17+ Apps (BetssonCameroon, BetssonFranceLegacy)

Since production apps target iOS 17+, you have two options:

1. **Point-Free's `observe { }`** - Works on iOS 17+ with `@Observable` (recommended)
2. **Combine with `currentDisplayState + dropFirst()`** - The workaround pattern (existing approach)

See [Point-Free's `observe { }` Pattern](#alternative-point-frees-observe---pattern) for the recommended iOS 17+ solution.

### Info.plist Configuration (iOS 18+ only)

For apps or targets that can require iOS 18+, add this key:

```xml
<key>UIObservationTrackingEnabled</key>
<true/>
```

**Location:** `Frameworks/GomaUI/Catalog/Assets/Info.plist`

> **Note:** This key is added to GomaUICatalog for testing the `layoutSubviews()` pattern. Production apps targeting iOS 17+ should use Point-Free's `observe { }` instead.

---

## Alternative: Point-Free's observe { } Pattern

[Point-Free's swift-navigation](https://github.com/pointfreeco/swift-navigation) library provides an alternative approach that works on **iOS 13+** through their [Perception](https://github.com/pointfreeco/swift-perception) backport.

### The `observe { }` Function

Instead of relying on `layoutSubviews()`, Point-Free provides an explicit `observe { }` closure that automatically tracks property access:

```swift
class FeatureViewController: UIViewController {
    @UIBindable var model: FeatureModel

    override func viewDidLoad() {
        super.viewDidLoad()

        observe { [weak self] in
            guard let self else { return }

            countLabel.text = "Count: \(model.count)"
            factLabel.isHidden = model.fact == nil
            if let fact = model.fact {
                factLabel.text = fact
            }
            activityIndicator.isHidden = !model.isLoadingFact
        }
    }
}
```

### How It Works

From the [swift-navigation documentation](https://www.pointfree.co/blog/posts/149-swift-navigation-powerful-navigation-tools-for-all-swift-platforms):

> "Whichever fields are accessed inside `observe` are automatically tracked, so whenever they are mutated the trailing closure of `observe` will be invoked again, allowing us to update the UI with the freshest data."

**Key behavior:** Only fields accessed within the closure trigger re-execution. Unaccessed fields don't cause unnecessary updates.

### Using with @Observable or @Perceptible

```swift
// iOS 17+ - Use native @Observable
@Observable
class FeatureModel {
    var count = 0
    var isLoadingFact = false
    var fact: String?
}

// iOS 13-16 - Use @Perceptible backport
@Perceptible
class FeatureModel {
    var count = 0
    var isLoadingFact = false
    var fact: String?
}
```

### Platform Support via Perception

[Perception 2.0](https://www.pointfree.co/blog/posts/180-perception-2-0-an-updated-back-port-of-swift-s-observation-framework) backports Swift's Observation framework:

| Feature | Native | Perception Backport |
|---------|--------|---------------------|
| `@Observable` | iOS 17+ | N/A |
| `@Perceptible` | N/A | **iOS 13+** |
| `observe { }` | N/A | **iOS 13+** |
| UIKit auto-tracking | iOS 18+ | N/A |

### Package Dependencies

To use this approach, add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-navigation", from: "2.0.0"),
]

targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "UIKitNavigation", package: "swift-navigation"),
        ]
    ),
]
```

### Additional UIKit Tools

The library also provides:

- **`@UIBindable`** - Property wrapper for binding models to UI
- **`present(item:)`** - State-driven sheet presentations
- **`navigationDestination(item:)`** - State-driven drill-down navigation
- **`UIBinding`** - Two-way bindings for form controls

---

## Choosing an Approach

### Comparison Table

| Aspect | Apple Native (`layoutSubviews`) | Point-Free (`observe { }`) |
|--------|--------------------------------|---------------------------|
| **Min iOS** | **18** (with plist) / 26 (native) | **17** (with `@Observable`) / **13** (with `@Perceptible`) |
| **Dependencies** | None | swift-navigation |
| **Where observation happens** | `layoutSubviews()`, `updateConstraints()`, `draw(_:)` | **Explicit closure** |
| **Granularity** | Whole view layout cycle | **Closure-level** |
| **Re-execution trigger** | Any tracked property change | Any tracked property change |
| **Works in UIViewController** | `viewWillLayoutSubviews()` | **`viewDidLoad()` or anywhere** |
| **Macro** | `@Observable` | `@Observable` or `@Perceptible` |

### When to Use Apple's Native Approach

- ✅ Targeting **iOS 18+** only
- ✅ Building components for internal testing (GomaUICatalog)
- ✅ Want zero external dependencies
- ✅ Already using `layoutSubviews()` for rendering

### When to Use Point-Free's `observe { }`

- ✅ **Targeting iOS 17+** (BetssonCameroon, BetssonFranceLegacy)
- ✅ Building UIViewControllers with complex state
- ✅ Want explicit control over what's observed
- ✅ Need observation outside of layout methods
- ✅ Want to use `@Observable` on iOS 17 where UIKit doesn't auto-track

### Production Apps Recommendation

**For BetssonCameroon and BetssonFranceLegacy (iOS 17+):**

Use **Point-Free's `observe { }`** pattern:
- Works with `@Observable` on iOS 17+ without the iOS 18 plist requirement
- Provides explicit observation tracking in any method, not just `layoutSubviews()`
- Battle-tested in production by Point-Free's ecosystem

```swift
// This works on iOS 17+
@Observable
class FeatureModel {
    var count = 0
}

class FeatureViewController: UIViewController {
    let model = FeatureModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        observe { [weak self] in
            guard let self else { return }
            countLabel.text = "\(model.count)"  // Auto-tracked on iOS 17!
        }
    }
}
```

### GomaUICatalog (Testing)

For **GomaUICatalog** (internal testing app), both approaches work since:
- The catalog has the `UIObservationTrackingEnabled` plist key
- It's not shipped to production
- It can test both patterns for comparison

The `ObservableScoreView` example uses `layoutSubviews()` for demonstration, but production components in the apps should use `observe { }` until iOS 18+ is the minimum deployment target.

---

## Implementation Pattern

### 1. Create the Protocol

```swift
// ObservableScoreViewModelProtocol.swift

/// Protocol for ScoreView's ViewModel.
/// Implementations MUST be @Observable classes.
@MainActor
public protocol ObservableScoreViewModelProtocol: AnyObject {
    var visualState: ScoreDisplayData.VisualState { get }
    var scoreCells: [ScoreDisplayData] { get }
}
```

### 2. Create the Mock Implementation

```swift
// MockObservableScoreViewModel.swift

@Observable
@MainActor
public final class MockObservableScoreViewModel: ObservableScoreViewModelProtocol {

    public var visualState: ScoreDisplayData.VisualState = .idle
    public var scoreCells: [ScoreDisplayData] = []

    public init(
        visualState: ScoreDisplayData.VisualState = .idle,
        scoreCells: [ScoreDisplayData] = []
    ) {
        self.visualState = visualState
        self.scoreCells = scoreCells
    }
}

// MARK: - Factory Methods

extension MockObservableScoreViewModel {

    public static var tennisMatch: MockObservableScoreViewModel {
        MockObservableScoreViewModel(
            visualState: .display,
            scoreCells: [
                ScoreDisplayData(id: "set1", homeScore: "6", awayScore: "4", style: .simple),
                ScoreDisplayData(id: "set2", homeScore: "3", awayScore: "6", style: .simple)
            ]
        )
    }

    public static var loading: MockObservableScoreViewModel {
        MockObservableScoreViewModel(visualState: .loading)
    }

    public static var empty: MockObservableScoreViewModel {
        MockObservableScoreViewModel(visualState: .empty)
    }
}
```

### 3. Create the View

```swift
// ObservableScoreView.swift

public final class ObservableScoreView: UIView {

    // MARK: - ViewModel (Protocol Type)

    public var viewModel: (any ObservableScoreViewModelProtocol)?

    // MARK: - UI Components

    private lazy var scoreLabel: UILabel = { ... }()
    private lazy var loadingIndicator: UIActivityIndicatorView = { ... }()

    // MARK: - Configuration

    public func configure(with viewModel: any ObservableScoreViewModelProtocol) {
        self.viewModel = viewModel
        setNeedsLayout()  // Trigger initial render
    }

    // MARK: - The Magic: layoutSubviews()

    public override func layoutSubviews() {
        super.layoutSubviews()

        guard let viewModel else { return }

        // Just read properties - UIKit tracks automatically!
        updateVisualState(viewModel.visualState)
        updateScoreCells(viewModel.scoreCells)
    }

    // MARK: - Rendering

    private func updateVisualState(_ state: ScoreDisplayData.VisualState) {
        switch state {
        case .idle:
            // ...
        case .loading:
            loadingIndicator.startAnimating()
        case .display:
            // ...
        case .empty:
            // ...
        }
    }

    private func updateScoreCells(_ cells: [ScoreDisplayData]) {
        // Rebuild cell views...
    }
}
```

### File Structure

```
ScoreView/
├── ObservableScoreViewModelProtocol.swift   # Protocol interface
├── MockObservableScoreViewModel.swift       # Mock for previews/tests
├── ObservableScoreView.swift                # The UIView
├── ScoreDisplayData.swift                   # Data models (shared)
└── ScoreCellView.swift                      # Child views (shared)
```

---

## GomaUI Protocol Architecture

### Why Protocols Are Essential

GomaUI's protocol-based architecture enables:

1. **Dependency Injection** - Views accept any conforming implementation
2. **Client Flexibility** - BetssonCameroon, BetssonFrance can provide different implementations
3. **Testability** - Mock implementations for previews and unit tests
4. **Separation of Concerns** - View doesn't know about data sources

### Protocol Requirements

```swift
@MainActor
public protocol ObservableScoreViewModelProtocol: AnyObject {
    // Read-only properties for view consumption
    var visualState: ScoreDisplayData.VisualState { get }
    var scoreCells: [ScoreDisplayData] { get }
}
```

**Key points:**
- `@MainActor` ensures main thread access
- `AnyObject` constraint (classes only, required for @Observable)
- Properties are `{ get }` only - view reads, doesn't write
- No Combine publishers needed

### View Accepts Protocol Type

```swift
public var viewModel: (any ObservableScoreViewModelProtocol)?

public func configure(with viewModel: any ObservableScoreViewModelProtocol) {
    self.viewModel = viewModel
    setNeedsLayout()
}
```

### Production Implementation Example

```swift
// In BetssonCameroonApp

@Observable
@MainActor
final class LiveScoreViewModel: ObservableScoreViewModelProtocol {

    var visualState: ScoreDisplayData.VisualState = .loading
    var scoreCells: [ScoreDisplayData] = []

    private let matchService: MatchServiceProtocol
    private let matchId: String

    init(matchId: String, matchService: MatchServiceProtocol) {
        self.matchId = matchId
        self.matchService = matchService
    }

    func startObserving() {
        Task {
            for await scores in matchService.liveScores(matchId: matchId) {
                self.scoreCells = scores.map { ScoreDisplayData(from: $0) }
                self.visualState = .display
            }
        }
    }
}
```

---

## Migration from Combine

### Before (Combine)

```swift
// Protocol with publishers
protocol ScoreViewModelProtocol {
    var currentDisplayState: ScoreDisplayState { get }
    var displayStatePublisher: AnyPublisher<ScoreDisplayState, Never> { get }
}

// View with Combine bindings
class ScoreView: UIView {
    private var cancellables = Set<AnyCancellable>()

    func configure(with viewModel: ScoreViewModelProtocol) {
        self.viewModel = viewModel
        render(state: viewModel.currentDisplayState)  // Sync first
        setupBindings()
    }

    private func setupBindings() {
        viewModel?.displayStatePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state: state)
            }
            .store(in: &cancellables)
    }
}
```

### After (@Observable)

```swift
// Protocol with simple properties
protocol ScoreViewModelProtocol: AnyObject {
    var visualState: VisualState { get }
    var scoreCells: [ScoreDisplayData] { get }
}

// View with layoutSubviews()
class ScoreView: UIView {
    // No cancellables needed!

    func configure(with viewModel: any ScoreViewModelProtocol) {
        self.viewModel = viewModel
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let viewModel else { return }

        updateVisualState(viewModel.visualState)
        updateScoreCells(viewModel.scoreCells)
    }

    // No setupBindings() needed!
}
```

### Migration Checklist

- [ ] Create new protocol without publishers (just `{ get }` properties)
- [ ] Create `@Observable` Mock implementation with factory methods
- [ ] Update View to use `any Protocol` type
- [ ] Move rendering logic to `layoutSubviews()`
- [ ] Replace `setupBindings()` with `setNeedsLayout()` in `configure()`
- [ ] Remove `cancellables` property
- [ ] Remove Combine import
- [ ] Update snapshot tests (remove RunLoop workarounds)
- [ ] Delete old Combine-based files

---

## Testing @Observable Components

### Snapshot Tests

Snapshot tests work **without any workarounds**:

```swift
final class ObservableScoreViewSnapshotTests: XCTestCase {

    func testScoreView_TennisMatch_Light() throws {
        let vc = ScoreViewSnapshotViewController(category: .sportVariants)

        // NO RunLoop.main.run() needed!
        // View renders synchronously via layoutSubviews()

        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device),
            record: SnapshotTestConfig.record
        )
    }
}
```

### Interactive Testing

Use the interactive preview to verify automatic updates:

1. Open `ObservableScoreView.swift` in Xcode
2. Run the **"Interactive - Test @Observable Updates"** preview
3. Tap buttons to mutate ViewModel properties
4. View should update automatically without manual intervention

### Unit Tests

```swift
func testViewModelMutation_TriggersLayoutUpdate() {
    let viewModel = MockObservableScoreViewModel.empty
    let view = ObservableScoreView()
    view.configure(with: viewModel)

    // Force initial layout
    view.layoutIfNeeded()

    // Mutate ViewModel
    viewModel.visualState = .display
    viewModel.scoreCells = [ScoreDisplayData(id: "1", homeScore: "1", awayScore: "0")]

    // UIKit should have called setNeedsLayout() automatically
    // Next layout pass will render new state
    view.layoutIfNeeded()

    // Assert view state...
}
```

---

## References

### Articles

- **Peter Steinberger** - [Automatic Observation Tracking in UIKit and AppKit](https://steipete.me/posts/2025/automatic-observation-tracking-uikit-appkit)
  - Comprehensive guide on UIKit observation tracking
  - Info.plist key discovery
  - iOS 18 backport details

- **Jacob's Tech Tavern** - [The Year SwiftUI Died](https://blog.jacobstechtavern.com/p/the-year-swiftui-died)
  - iOS 26 UIKit updates overview
  - `updateProperties()` method
  - Apple's UIKit investment

### Point-Free Resources

- **[swift-navigation](https://github.com/pointfreeco/swift-navigation)** - GitHub repository
  - `observe { }` function for UIKit
  - `@UIBindable` property wrapper
  - State-driven navigation tools

- **[Perception](https://github.com/pointfreeco/swift-perception)** - @Observable backport for iOS 13+
  - `@Perceptible` macro (backport of `@Observable`)
  - Works with `observe { }` on older iOS versions

- **[Episode #283: Modern UIKit: Observation](https://www.pointfree.co/episodes/ep283-modern-uikit-observation)** - Point-Free video
  - Deep dive into `observe { }` implementation
  - Comparison with traditional UIKit patterns

- **[Swift Navigation Blog Post](https://www.pointfree.co/blog/posts/149-swift-navigation-powerful-navigation-tools-for-all-swift-platforms)**
  - Overview of UIKitNavigation library
  - Code examples and use cases

- **[Perception 2.0 Announcement](https://www.pointfree.co/blog/posts/180-perception-2-0-an-updated-back-port-of-swift-s-observation-framework)**
  - Latest backport improvements
  - Async sequences with `Perceptions`

### Apple Documentation

- [Observation Framework](https://developer.apple.com/documentation/observation)
- [@Observable Macro](https://developer.apple.com/documentation/observation/observable())

### GomaUI Examples

- `ObservableScoreView.swift` - First component using this pattern
- `ObservableScoreViewModelProtocol.swift` - Protocol example
- `MockObservableScoreViewModel.swift` - Mock implementation example
- `ObservableScoreViewSnapshotTests.swift` - Snapshot tests without workarounds

---

## Summary

### Two Patterns for @Observable in UIKit

| Pattern | Min iOS | Best For |
|---------|---------|----------|
| **Point-Free `observe { }`** | **iOS 17+** | Production apps (BetssonCameroon, BetssonFranceLegacy) |
| **Apple `layoutSubviews()`** | iOS 18+ | Internal testing, future apps |

### For iOS 17+ Production Apps (Recommended)

Use Point-Free's `observe { }`:

| What | How |
|------|-----|
| ViewModel | `@Observable` class conforming to protocol |
| Observation | `observe { }` closure in `viewDidLoad()` |
| Dependency | `swift-navigation` package |

### For iOS 18+ (Future)

Use Apple's native `layoutSubviews()`:

| What | How |
|------|-----|
| ViewModel | `@Observable` class conforming to protocol |
| View property | `var viewModel: (any Protocol)?` |
| Initial render | `setNeedsLayout()` in `configure()` |
| Reactive updates | Read properties in `layoutSubviews()` |
| Requirements | `UIObservationTrackingEnabled` plist key |

**Result:** Both patterns eliminate Combine complexity, provide synchronous rendering, and make snapshot tests work without workarounds.
