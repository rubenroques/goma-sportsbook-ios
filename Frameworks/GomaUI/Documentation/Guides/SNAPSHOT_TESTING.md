# Snapshot Testing Guide

This guide documents the patterns for creating **snapshot tests** for GomaUI components using [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing).

## Table of Contents
- [Overview](#overview)
- [File Structure](#file-structure)
- [Configuration](#configuration)
- [Creating Snapshot Tests](#creating-snapshot-tests)
- [Component Categories Pattern](#component-categories-pattern)
- [Light & Dark Mode Testing](#light--dark-mode-testing)
- [Synchronous Rendering (Critical)](#synchronous-rendering-critical-for-snapshot-tests)
  - [The Root Cause](#the-root-cause)
  - [Point-Free's Solution: Scheduler Injection](#point-frees-recommended-solution-scheduler-injection)
    - [Reference Implementation: ToasterView](#reference-implementation-toasterview)
  - [Our Solution: currentDisplayState + dropFirst()](#our-solution-currentdisplaystate--dropfirst)
  - [Test-Side Workaround](#test-side-workaround-quick-fix)
  - [Known Framework Limitations](#known-framework-limitations)
  - [Migration Strategy](#migration-strategy)
  - [Components Status](#components-status)
- [Reference: ButtonView](#reference-buttonview)

## Overview

Snapshot testing captures visual representations of UI components and compares them against reference images. This ensures visual consistency and catches unintended UI regressions.

### Architecture

Snapshot tests follow a **two-file pattern**:

1. **SnapshotViewController** (in Sources) - Displays component variants with labels
2. **SnapshotTests** (in Tests) - Runs snapshot assertions for light/dark modes

```
GomaUI/
├── Sources/GomaUI/Components/ButtonView/
│   └── ButtonViewSnapshotViewController.swift   ← VC with variants
│
└── Tests/GomaUITests/SnapshotTests/
    ├── SnapshotTestConfig.swift                  ← Shared config
    └── ButtonView/
        ├── ButtonViewSnapshotTests.swift         ← Test functions
        └── __Snapshots__/                        ← Reference images
```

## File Structure

### SnapshotTestConfig.swift

Central configuration for all snapshot tests:

```swift
import SnapshotTesting
import UIKit

enum SnapshotTestConfig {
    static let device: ViewImageConfig = .iPhone8
    static let size: CGSize = CGSize(width: 414, height: 860)
    static let record: Bool = false  // Set true to record new references

    static let lightTraits = UITraitCollection(userInterfaceStyle: .light)
    static let darkTraits = UITraitCollection(userInterfaceStyle: .dark)
}
```

### SnapshotViewController Pattern

```swift
import UIKit

final class ComponentViewSnapshotViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundTestColor
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "ComponentName"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        // Add variants
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default State",
            view: ComponentView(viewModel: MockComponentViewModel.defaultMock)
        ))
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let variantLabel = UILabel()
        variantLabel.text = label
        variantLabel.font = StyleProvider.fontWith(type: .medium, size: 12)
        variantLabel.textColor = StyleProvider.Color.textSecondary

        let stack = UIStackView(arrangedSubviews: [variantLabel, view])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview { ComponentViewSnapshotViewController() }
#endif
```

## Configuration

### Recording Reference Images

1. Set `SnapshotTestConfig.record = true`
2. Run the tests
3. Verify generated images in `__Snapshots__/` folder
4. Set `SnapshotTestConfig.record = false`
5. Commit the reference images

### Background Color

Always use `.backgroundTestColor` - a neutral gray that adapts to light/dark mode.

## Creating Snapshot Tests

### Step 1: Create SnapshotViewController

Place in `Sources/GomaUI/Components/{ComponentName}/`:
- Title label with component name
- Stack view with labeled variants
- Include all meaningful states (default, selected, disabled, loading, error)

### Step 2: Create Test File

Place in `Tests/GomaUITests/SnapshotTests/{ComponentName}/`:

```swift
import XCTest
import SnapshotTesting
@testable import GomaUI

final class ComponentViewSnapshotTests: XCTestCase {

    func testComponentView_Light() throws {
        let vc = ComponentViewSnapshotViewController()
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testComponentView_Dark() throws {
        let vc = ComponentViewSnapshotViewController()
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
```

## Component Categories Pattern

For components with many variants (10+), split into **categories**:

### Define Category Enum

```swift
enum ButtonSnapshotCategory: String, CaseIterable {
    case basicStyles = "Basic Styles"
    case disabledStates = "Disabled States"
    case commonActions = "Common Actions"
}
```

### Configurable ViewController

```swift
final class ButtonViewSnapshotViewController: UIViewController {
    private let category: ButtonSnapshotCategory

    init(category: ButtonSnapshotCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "ButtonView - \(category.rawValue)"
        // ... setup stack

        switch category {
        case .basicStyles: addBasicStylesVariants(to: stackView)
        case .disabledStates: addDisabledStatesVariants(to: stackView)
        case .commonActions: addCommonActionsVariants(to: stackView)
        }
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview("Basic Styles") { ButtonViewSnapshotViewController(category: .basicStyles) }

@available(iOS 17.0, *)
#Preview("Disabled States") { ButtonViewSnapshotViewController(category: .disabledStates) }
#endif
```

### Category-Based Tests

```swift
final class ButtonViewSnapshotTests: XCTestCase {

    // MARK: - Basic Styles

    func testButtonView_BasicStyles_Light() throws {
        let vc = ButtonViewSnapshotViewController(category: .basicStyles)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testButtonView_BasicStyles_Dark() throws {
        let vc = ButtonViewSnapshotViewController(category: .basicStyles)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Disabled States
    // ... repeat for each category
}
```

## Light & Dark Mode Testing

Every component must be tested in **both** light and dark mode.

**Naming Convention**: Use `_Light` and `_Dark` suffixes:
- `testButtonView_BasicStyles_Light`
- `testButtonView_BasicStyles_Dark`

## Synchronous Rendering (Critical for Snapshot Tests)

Components using Combine with `.receive(on: DispatchQueue.main)` render asynchronously. **Snapshots capture empty/unconfigured views** because the render happens on the next run loop iteration.

### The Root Cause

Even when you're already on the main thread AND using `CurrentValueSubject` (which has a value ready), `.receive(on: DispatchQueue.main)` **always schedules delivery for the NEXT run loop iteration**:

```swift
// This is equivalent to:
DispatchQueue.main.async {
    // Runs AFTER the current call stack completes
}
```

**Timeline of the bug:**
1. `init()` → `setupBindings()` → subscribes to publisher
2. Publisher emits value → **scheduled for next run loop**
3. `init()` returns → view added to hierarchy
4. **Snapshot is taken** ← View is EMPTY!
5. Next run loop → `render()` finally called ← Too late

### Point-Free's Recommended Solution: Scheduler Injection

The creators of swift-snapshot-testing address this in their [combine-schedulers](https://github.com/pointfreeco/combine-schedulers) library:

> "The moment you use any schedulers in your reactive code you instantly make the publisher asynchronous and therefore much harder to test"

**Their solution**: Inject the scheduler as a dependency:

```swift
// Protocol accepts scheduler
protocol ToasterViewModelProtocol {
    var scheduler: AnySchedulerOf<DispatchQueue> { get }
    var dataPublisher: AnyPublisher<ToasterData, Never> { get }
}

// View uses injected scheduler
viewModel.dataPublisher
    .receive(on: viewModel.scheduler)  // Not hardcoded!
    .sink { ... }

// Production: DispatchQueue.main
let viewModel = ToasterViewModel(scheduler: DispatchQueue.main.eraseToAnyScheduler())

// Tests: ImmediateScheduler (synchronous!)
let viewModel = MockToasterViewModel(scheduler: DispatchQueue.immediate.eraseToAnyScheduler())
```

From [CombineSchedulers docs](https://pointfreeco.github.io/combine-schedulers/ImmediateScheduler/):
> "This scheduler forces the publisher to emit immediately rather than needing to wait for thread hops"

**Pros**: Architecturally correct, follows Point-Free's TCA patterns
**Cons**: Requires updating protocol, mock, view, and production implementations

#### Reference Implementation: ToasterView

**ToasterView has been migrated to scheduler injection** and serves as the reference implementation for this pattern. The changes required are documented below:

**Step 1: Add combine-schedulers to Package.swift**
```swift
dependencies: [
    // ... existing dependencies
    .package(url: "https://github.com/pointfreeco/combine-schedulers", from: "1.0.0"),
],
targets: [
    .target(
        name: "GomaUI",
        dependencies: [
            // ... existing dependencies
            .product(name: "CombineSchedulers", package: "combine-schedulers"),
        ],
    ),
]
```

**Step 2: Update the Protocol** (`ToasterViewModelProtocol.swift`)
```swift
import CombineSchedulers

public protocol ToasterViewModelProtocol {
    var dataPublisher: AnyPublisher<ToasterData, Never> { get }
    var currentData: ToasterData { get }

    /// Scheduler for receiving updates. Use `.main` in production, `.immediate` in tests.
    var scheduler: AnySchedulerOf<DispatchQueue> { get }
}
```

**Step 3: Update the Mock** (`MockToasterViewModel.swift`)
```swift
import CombineSchedulers

public final class MockToasterViewModel: ToasterViewModelProtocol {
    public let scheduler: AnySchedulerOf<DispatchQueue>

    public init(
        data: ToasterData = ...,
        scheduler: AnySchedulerOf<DispatchQueue> = .immediate  // ← Synchronous for tests!
    ) {
        self.scheduler = scheduler
        // ...
    }
}
```

**Step 4: Update the View** (`ToasterView.swift`)
```swift
private func setupBindings() {
    viewModel.dataPublisher
        .receive(on: viewModel.scheduler)  // ← Was: DispatchQueue.main
        .sink { [weak self] data in
            self?.render(data: data)
        }
        .store(in: &cancellables)
}
```

**Step 5: Update Production Implementation** (if exists outside GomaUI)
```swift
import CombineSchedulers

final class AppToasterViewModel: ToasterViewModelProtocol {
    let scheduler: AnySchedulerOf<DispatchQueue>

    init(
        initialData: ToasterData = ...,
        scheduler: AnySchedulerOf<DispatchQueue> = .main  // ← Production default
    ) {
        self.scheduler = scheduler
        // ...
    }
}
```

**Result**: Snapshot tests capture fully rendered content because `ImmediateScheduler` (`.immediate`) executes synchronously without scheduling to the next run loop.

### Our Solution: `currentDisplayState` + `dropFirst()`

A less invasive approach that works well for our codebase:

1. **Protocol** exposes both async publisher AND synchronous state:

```swift
public protocol ComponentViewModelProtocol {
    // Synchronous access (for immediate rendering)
    var currentDisplayState: ComponentDisplayState { get }

    // Async updates (for reactive changes)
    var displayStatePublisher: AnyPublisher<ComponentDisplayState, Never> { get }
}
```

2. **ViewModel** uses `CurrentValueSubject` to back both:

```swift
final class ComponentViewModel: ComponentViewModelProtocol {
    private let stateSubject = CurrentValueSubject<ComponentDisplayState, Never>(.initial)

    var currentDisplayState: ComponentDisplayState {
        stateSubject.value  // Synchronous read
    }

    var displayStatePublisher: AnyPublisher<ComponentDisplayState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
}
```

3. **View** renders synchronously FIRST, then subscribes with `dropFirst()`:

```swift
public init(viewModel: ComponentViewModelProtocol) {
    self.viewModel = viewModel
    super.init(frame: .zero)
    setupSubviews()
    renderInitialState()  // ← Synchronous render
    setupBindings()
}

private func renderInitialState() {
    render(state: viewModel.currentDisplayState)
}

private func setupBindings() {
    viewModel.displayStatePublisher
        .dropFirst()  // ← Skip initial - already rendered synchronously
        .receive(on: DispatchQueue.main)
        .sink { [weak self] state in self?.render(state: state) }
        .store(in: &cancellables)
}
```

**Why `dropFirst()`?** Without it, the view renders twice: once synchronously, once async. With `dropFirst()`, the async subscription only fires for *subsequent* state changes.

**Reference implementation**: See `BorderedTextFieldView` (commit `5c2ff2368`)

### Test-Side Workaround (Quick Fix)

For components not yet refactored, flush the run loop before snapshotting:

```swift
func testLegacyComponent_Light() throws {
    let vc = LegacyComponentSnapshotViewController()
    _ = vc.view  // Trigger viewDidLoad
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))  // Let Combine emit

    assertSnapshot(of: vc, as: .image(...), record: SnapshotTestConfig.record)
}
```

**Pros**: No production code changes needed
**Cons**: Timing-dependent, slower tests, doesn't fix underlying architecture

### Known Framework Limitations

From [swift-snapshot-testing Discussion #669](https://github.com/pointfreeco/swift-snapshot-testing/discussions/669):
- The `.wait(for:on:)` strategy **does not work** reliably with async code
- SwiftUI views with async/await have the same issue
- No official solution provided by Point-Free for this specific case

### Would Swift 6 / async-await Fix This?

**No.** The same issue exists with async/await:

```swift
Task { @MainActor in
    // Still schedules for next iteration, not synchronous
}
```

The fundamental issue is *deferred execution*, not Combine specifically.

### Migration Strategy

1. **Immediate**: Use RunLoop flush in tests for components with empty snapshots
2. **Gradual**: Apply `currentDisplayState + dropFirst()` when touching components
3. **New Components**: Consider scheduler injection for maximum testability

### Components Status

**Fixed with Scheduler Injection:**
- ✅ **ToasterView** - Reference implementation for scheduler injection pattern

**Fixed with currentDisplayState + dropFirst():**
- ✅ **BorderedTextFieldView** - Reference implementation (commit `5c2ff2368`)

**Pending Fix** (use `.receive(on: DispatchQueue.main)` without synchronous initial render):
- ⚠️ ScoreView
- ⚠️ Any component where snapshots show empty/partial content

When fixing pending components, choose one approach:
1. **Scheduler Injection** (recommended for new components) - See ToasterView
2. **currentDisplayState + dropFirst()** (good for existing components) - See BorderedTextFieldView

### Additional Resources

- [pointfreeco/combine-schedulers](https://github.com/pointfreeco/combine-schedulers) - Testable Combine schedulers
- [Open Sourcing CombineSchedulers](https://www.pointfree.co/blog/posts/45-open-sourcing-combineschedulers) - Point-Free blog post
- [Discussion #543](https://github.com/pointfreeco/swift-snapshot-testing/discussions/543) - `.wait` strategy issues

## Reference: ButtonView

See the complete implementation at:
- `Sources/GomaUI/Components/ButtonView/ButtonViewSnapshotViewController.swift`
- `Tests/GomaUITests/SnapshotTests/ButtonView/ButtonViewSnapshotTests.swift`

ButtonView demonstrates:
- 6 category enum for organizing 22 variants
- Light/Dark mode tests for each category (12 total tests)
- `currentDisplayState` for synchronous rendering
- Multiple `#Preview` blocks per category
