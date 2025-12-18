# Snapshot Testing Guide

This guide documents the patterns for creating **snapshot tests** for GomaUI components using [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing).

## Table of Contents
- [Overview](#overview)
- [File Structure](#file-structure)
- [Configuration](#configuration)
- [Creating Snapshot Tests](#creating-snapshot-tests)
- [Component Categories Pattern](#component-categories-pattern)
- [Light & Dark Mode Testing](#light--dark-mode-testing)
- [Synchronous Rendering](#synchronous-rendering)
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

## Synchronous Rendering

Components using Combine with `.receive(on: DispatchQueue.main)` render asynchronously. Snapshots may capture empty states.

### Solution: `currentDisplayState`

1. **Protocol** exposes synchronous state:

```swift
public protocol ComponentViewModelProtocol {
    var currentDisplayState: ComponentDisplayState { get }
    var displayStatePublisher: AnyPublisher<ComponentDisplayState, Never> { get }
}
```

2. **View** renders synchronously first:

```swift
public init(viewModel: ComponentViewModelProtocol) {
    self.viewModel = viewModel
    super.init(frame: .zero)
    setupSubviews()
    configureImmediately()  // Sync render
    setupBindings()
}

private func configureImmediately() {
    render(state: viewModel.currentDisplayState)
}

private func setupBindings() {
    viewModel.displayStatePublisher
        .dropFirst()  // Skip - already rendered
        .receive(on: DispatchQueue.main)
        .sink { [weak self] state in self?.render(state: state) }
        .store(in: &cancellables)
}
```

### Legacy Workaround

For components not yet refactored:

```swift
func testLegacyComponent_Light() throws {
    let vc = LegacyComponentSnapshotViewController()
    vc.loadViewIfNeeded()
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))  // Wait for async render

    assertSnapshot(of: vc, as: .image(...), record: SnapshotTestConfig.record)
}
```

## Reference: ButtonView

See the complete implementation at:
- `Sources/GomaUI/Components/ButtonView/ButtonViewSnapshotViewController.swift`
- `Tests/GomaUITests/SnapshotTests/ButtonView/ButtonViewSnapshotTests.swift`

ButtonView demonstrates:
- 6 category enum for organizing 22 variants
- Light/Dark mode tests for each category (12 total tests)
- `currentDisplayState` for synchronous rendering
- Multiple `#Preview` blocks per category
