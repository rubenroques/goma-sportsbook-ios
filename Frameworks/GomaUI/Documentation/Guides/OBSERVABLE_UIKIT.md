# @Observable UIKit Components Guide

This guide documents the **@Observable + layoutSubviews()** pattern for building reactive UIKit components without Combine.

## Table of Contents

- [The Problem: Combine's Async Rendering](#the-problem-combines-async-rendering)
- [The Solution: @Observable + layoutSubviews()](#the-solution-observable--layoutsubviews)
- [How It Works](#how-it-works)
- [Requirements](#requirements)
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

Apple introduced **automatic observation tracking** for UIKit in iOS 18 (backportable to iOS 18 with Info.plist key). This eliminates Combine entirely for UI bindings.

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

### Minimum iOS Versions

| Feature | iOS Version |
|---------|-------------|
| `@Observable` macro | iOS 17+ |
| UIKit auto-tracking (with Info.plist) | iOS 18+ |
| Native UIKit auto-tracking | iOS 26+ |

### Info.plist Configuration

Add this key to enable automatic observation tracking on iOS 18+:

```xml
<key>UIObservationTrackingEnabled</key>
<true/>
```

**Location:** `Frameworks/GomaUI/Catalog/Assets/Info.plist`

> **Note:** This key is already added to GomaUICatalog. Production apps targeting iOS 18+ should also add this key.

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

The **@Observable + layoutSubviews()** pattern replaces Combine for UIKit reactive bindings:

| What | How |
|------|-----|
| ViewModel | `@Observable` class conforming to protocol |
| View property | `var viewModel: (any Protocol)?` |
| Initial render | `setNeedsLayout()` in `configure()` |
| Reactive updates | Read properties in `layoutSubviews()` |
| Requirements | iOS 17+ (`@Observable`), iOS 18+ (`UIObservationTrackingEnabled`) |

**Result:** Simpler code, synchronous rendering, no Combine complexity, snapshot tests that just work.
