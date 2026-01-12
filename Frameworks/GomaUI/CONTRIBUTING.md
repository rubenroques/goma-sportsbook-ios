# Contributing to GomaUI

Welcome to GomaUI! This guide will help you contribute successfully to our component library.

## Table of Contents

- [Quick Start Checklist](#quick-start-checklist)
- [Before You Start](#before-you-start)
- [Component Development Workflow](#component-development-workflow)
- [File Structure Requirements](#file-structure-requirements)
- [Code Standards](#code-standards)
- [ReusableView Pattern](#reusableview-pattern-required)
- [ImageSource and ImageResolver Patterns](#imagesource-and-imageresolver-patterns)
- [Snapshot Testing](#snapshot-testing)
- [Catalog Integration](#catalog-integration)
- [Metadata Registration](#metadata-registration)
- [Pre-Submission Checklist](#pre-submission-checklist)
- [Common Pitfalls](#common-pitfalls)
- [Reference Documentation](#reference-documentation)

---

## Quick Start Checklist

Use this checklist for every new component:

```
[ ] 1. Read this guide and CLAUDE.md
[ ] 2. Create component files (View, Protocol, Mock)
[ ] 3. Follow one-type-per-file rule
[ ] 4. Use StyleProvider for all colors/fonts
[ ] 5. Implement currentDisplayState + dropFirst() pattern
[ ] 6. Implement ReusableView pattern (optional VM, prepareForReuse, renderEmptyState)
[ ] 7. Use ImageSource enum for external images (if applicable)
[ ] 8. Create snapshot ViewController and tests (light + dark)
[ ] 9. Add demo ViewController to Catalog app
[ ] 10. Register in ComponentCategory.swift
[ ] 11. Update catalog-metadata.json
[ ] 12. Verify build passes: GomaUICatalog scheme
```

---

## Before You Start

### Required Reading

Before contributing, read these files in order:

1. **[CLAUDE.md](./CLAUDE.md)** - Critical development rules (file organization, architecture patterns)
2. **[Documentation/Guides/UIKIT_CODE_ORGANIZATION.md](./Documentation/Guides/UIKIT_CODE_ORGANIZATION.md)** - UIKit coding standards
3. **[Documentation/Guides/COMPONENT_CREATION.md](./Documentation/Guides/COMPONENT_CREATION.md)** - Step-by-step component creation

### Architecture Overview

GomaUI follows **Protocol-Driven MVVM**:

```
┌─────────────────────────────────────────────────────────────┐
│                        View (UIView)                        │
│  - Renders UI based on ViewModel state                      │
│  - Subscribes to displayStatePublisher                      │
│  - Uses currentDisplayState for synchronous initial render  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  ViewModelProtocol                          │
│  - Defines interface (publishers, methods)                  │
│  - Implemented by production VM and Mock VM                 │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
┌─────────────────────────┐     ┌─────────────────────────────┐
│   Production ViewModel   │     │       Mock ViewModel        │
│   (App layer)            │     │   (GomaUI - for testing)    │
└─────────────────────────┘     └─────────────────────────────┘
```

### Study Reference Components

Before creating your component, study these well-implemented examples:

| Component | Complexity | Learn About |
|-----------|------------|-------------|
| `ButtonView` | Simple | Basic MVVM, multiple states, snapshot categories |
| `OutcomeItemView` | Simple | Betting domain, state changes, odds display |
| `BorderedTextFieldView` | Medium | Form input, validation states, currentDisplayState pattern |
| `ToasterView` | Medium | Scheduler injection pattern for testing |
| `TallOddsMatchCardView` | Complex | Composite components, multiple child views |

---

## Component Development Workflow

### Step 1: Create Component Directory

```
GomaUI/Sources/GomaUI/Components/{Category}/{ComponentName}/
├── {ComponentName}.swift                      # Main UIView
├── {ComponentName}ViewModelProtocol.swift     # Protocol definition
├── Mock{ComponentName}ViewModel.swift         # Mock for testing/previews
├── {ComponentName}SnapshotViewController.swift # For snapshot tests
└── Documentation/
    └── README.md                              # Usage documentation
```

### Step 2: Define the Protocol

```swift
// {ComponentName}ViewModelProtocol.swift
import Combine
import UIKit

public struct {ComponentName}DisplayState: Equatable {
    // Define all visual state properties
    public let title: String
    public let isSelected: Bool
    // ...
}

public protocol {ComponentName}ViewModelProtocol {
    // REQUIRED: Synchronous state access (for snapshot tests & cell sizing)
    var currentDisplayState: {ComponentName}DisplayState { get }

    // REQUIRED: Reactive updates
    var displayStatePublisher: AnyPublisher<{ComponentName}DisplayState, Never> { get }

    // User interaction methods
    func didTap()
}
```

### Step 3: Create the Mock ViewModel

```swift
// Mock{ComponentName}ViewModel.swift
import Combine

public final class Mock{ComponentName}ViewModel: {ComponentName}ViewModelProtocol {

    // MARK: - State
    private let stateSubject: CurrentValueSubject<{ComponentName}DisplayState, Never>

    public var currentDisplayState: {ComponentName}DisplayState {
        stateSubject.value
    }

    public var displayStatePublisher: AnyPublisher<{ComponentName}DisplayState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization
    public init(state: {ComponentName}DisplayState) {
        self.stateSubject = CurrentValueSubject(state)
    }

    // MARK: - Protocol Methods
    public func didTap() {
        // Simulate realistic behavior - update state
        var newState = stateSubject.value
        // Modify state...
        stateSubject.send(newState)
    }
}

// MARK: - Factory Methods
extension Mock{ComponentName}ViewModel {

    public static var defaultMock: Mock{ComponentName}ViewModel {
        Mock{ComponentName}ViewModel(state: .init(
            title: "Sample Title",
            isSelected: false
        ))
    }

    public static var selectedMock: Mock{ComponentName}ViewModel {
        Mock{ComponentName}ViewModel(state: .init(
            title: "Selected Item",
            isSelected: true
        ))
    }
}
```

### Step 4: Implement the View

```swift
// {ComponentName}.swift
import UIKit
import Combine

public final class {ComponentName}: UIView {

    // MARK: - Private Properties
    private var viewModel: {ComponentName}ViewModelProtocol?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Elements (lazy with static factories)
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    // MARK: - Initialization
    public init(viewModel: {ComponentName}ViewModelProtocol) {
        super.init(frame: .zero)
        setupSubviews()
        configure(with: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    public func configure(with viewModel: {ComponentName}ViewModelProtocol) {
        self.viewModel = viewModel

        // CRITICAL: Render synchronously FIRST
        render(state: viewModel.currentDisplayState)

        // Then subscribe for future updates
        setupBindings()
    }

    // MARK: - Bindings
    private func setupBindings() {
        cancellables.removeAll()

        viewModel?.displayStatePublisher
            .dropFirst()  // Skip initial - already rendered synchronously
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state: state)
            }
            .store(in: &cancellables)
    }

    // MARK: - Rendering
    private func render(state: {ComponentName}DisplayState) {
        titleLabel.text = state.title
        backgroundColor = state.isSelected
            ? StyleProvider.Color.backgroundSelected
            : StyleProvider.Color.backgroundPrimary
    }
}

// MARK: - ReusableView
extension {ComponentName}: ReusableView {
    public func prepareForReuse() {
        cancellables.removeAll()
        viewModel = nil
        titleLabel.text = nil
    }
}

// MARK: - Subviews Setup
extension {ComponentName} {

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }

    private func setupSubviews() {
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17.0, *)
#Preview("Default") {
    PreviewUIView {
        {ComponentName}(viewModel: Mock{ComponentName}ViewModel.defaultMock)
    }
    .frame(height: 60)
}

@available(iOS 17.0, *)
#Preview("Selected") {
    PreviewUIView {
        {ComponentName}(viewModel: Mock{ComponentName}ViewModel.selectedMock)
    }
    .frame(height: 60)
}
#endif
```

---

## File Structure Requirements

### One Type Per File - NO EXCEPTIONS

This is the most critical rule. Every type (class, struct, enum, protocol) gets its own file.

```
# CORRECT
ThemeSwitcherView/
├── ThemeMode.swift                      # enum ThemeMode
├── ThemeSwitcherView.swift              # class ThemeSwitcherView
├── ThemeSegmentView.swift               # class ThemeSegmentView (helper)
├── ThemeSwitcherViewModelProtocol.swift # protocol
└── MockThemeSwitcherViewModel.swift     # mock class

# WRONG - Multiple types in one file
ThemeSwitcherView.swift containing:
  - enum ThemeMode        # Should be in ThemeMode.swift
  - class ThemeSwitcherView
  - class ThemeSegmentView # Should be in ThemeSegmentView.swift
```

### File Naming Convention

| Type | File Name |
|------|-----------|
| Main View | `{ComponentName}.swift` or `{ComponentName}View.swift` |
| Protocol | `{ComponentName}ViewModelProtocol.swift` |
| Mock | `Mock{ComponentName}ViewModel.swift` |
| Display State | `{ComponentName}DisplayState.swift` |
| Enums | `{EnumName}.swift` (e.g., `ThemeMode.swift`) |
| Helper Views | `{HelperName}.swift` (e.g., `ThemeSegmentView.swift`) |
| Snapshot VC | `{ComponentName}SnapshotViewController.swift` |

---

## Code Standards

### StyleProvider - MANDATORY

Never hardcode colors or fonts:

```swift
// CORRECT
backgroundColor = StyleProvider.Color.backgroundPrimary
label.font = StyleProvider.fontWith(type: .medium, size: 14)
label.textColor = StyleProvider.Color.textPrimary

// WRONG
backgroundColor = .white
label.font = UIFont.systemFont(ofSize: 14)
label.textColor = .black
```

### Lazy Properties with Static Factories

```swift
// CORRECT
private lazy var titleLabel: UILabel = Self.createTitleLabel()

private static func createTitleLabel() -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
}

// WRONG
private let titleLabel = UILabel()
```

### No Callback Properties Bypassing Protocol

```swift
// CORRECT - User actions go through protocol
func didTapButton() {
    viewModel?.didTap()
}

// WRONG - Bypassing protocol with callbacks
public var onTap: (() -> Void)?

func didTapButton() {
    onTap?()  // Protocol should handle this
}
```

### Production-Ready Mocks

Mocks must simulate realistic behavior:

```swift
// CORRECT - Mock simulates real behavior
public func didTap() {
    var currentState = stateSubject.value
    currentState.isSelected.toggle()
    stateSubject.send(currentState)
}

// WRONG - Mock does nothing useful
public func didTap() {
    print("Tapped")  // Never use print in production code
}
```

### FontProvider

StyleProvider includes a customizable font system:

```swift
// Access fonts
label.font = StyleProvider.fontWith(type: .medium, size: 14)
titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)

// Available font types
StyleProvider.FontType.thin
StyleProvider.FontType.light
StyleProvider.FontType.regular
StyleProvider.FontType.medium
StyleProvider.FontType.semibold
StyleProvider.FontType.bold
StyleProvider.FontType.heavy

// Apps can customize the font provider at startup
StyleProvider.setFontProvider { type, size in
    switch type {
    case .bold:
        return UIFont(name: "CustomFont-Bold", size: size) ?? .systemFont(ofSize: size, weight: .bold)
    // ... other cases
    }
}
```

---

## ReusableView Pattern (Required)

All GomaUI components must support safe cell reuse in UITableView/UICollectionView. This is a **required pattern**, not a formal protocol.

### Requirements

1. **ViewModel must be optional** - Component handles `nil` gracefully (shows empty/blank state)
2. **`configure(with:)` accepts optional** - Allows clearing configuration
3. **`prepareForReuse()` clears all state** - Prevents stale data in recycled cells

### Implementation Pattern

```swift
public final class ComponentView: UIView {

    // MARK: - Properties
    private var viewModel: ComponentViewModelProtocol?  // OPTIONAL
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Configuration (accepts optional)
    public func configure(with viewModel: ComponentViewModelProtocol?) {
        // Clear previous state
        cancellables.removeAll()

        self.viewModel = viewModel

        // Handle nil case - render empty state
        guard let viewModel = viewModel else {
            renderEmptyState()
            return
        }

        // Render synchronously first
        render(state: viewModel.currentDisplayState)
        setupBindings()
    }

    // MARK: - Reuse Support
    public func prepareForReuse() {
        // 1. Cancel all subscriptions
        cancellables.removeAll()

        // 2. Clear ViewModel reference
        viewModel = nil

        // 3. Reset all callbacks
        onItemSelected = { _ in }

        // 4. Clear child components
        childView.prepareForReuse()

        // 5. Reset UI to empty state
        renderEmptyState()
    }

    private func renderEmptyState() {
        titleLabel.text = nil
        imageView.image = nil
        descriptionLabel.text = nil
        // Reset all visual properties to defaults
    }
}
```

### Why This Matters

Without proper reuse support:
- **Stale data**: Recycled cells show previous content before new data loads
- **Memory leaks**: Old Combine subscriptions remain active
- **Crashes**: Callbacks fire on deallocated objects

---

## ImageSource and ImageResolver Patterns

For components displaying external images (banners, team logos, game thumbnails), use the **ImageSource + ImageResolver** pattern for better testability.

### ImageSource Enum

Location: `Components/Shared/ImageSource.swift`

```swift
public enum ImageSource: Equatable, Hashable {
    /// Image loaded from a remote URL
    case url(URL)

    /// Image loaded from a bundle asset by name
    case bundleAsset(String)

    /// No image available - show placeholder
    case none
}

// Convenience initializer
extension ImageSource {
    public static func url(string: String) -> ImageSource {
        guard let url = URL(string: string) else { return .none }
        return .url(url)
    }
}
```

### ImageResolver Protocol

ImageResolver is a **domain-specific protocol** that returns `ImageSource`:

```swift
// Protocol definition (in your component)
public protocol GameImageResolver {
    func imageSource(for gameId: String) -> ImageSource
}

// Production implementation (in app layer)
struct ProductionGameImageResolver: GameImageResolver {
    func imageSource(for gameId: String) -> ImageSource {
        guard let url = URL(string: "https://cdn.example.com/games/\(gameId).png") else {
            return .none
        }
        return .url(url)
    }
}

// Mock implementation (for testing/previews)
struct MockGameImageResolver: GameImageResolver {
    func imageSource(for gameId: String) -> ImageSource {
        return .bundleAsset("mock_game_thumbnail")
    }
}
```

### View Handling

The view handles each `ImageSource` case explicitly:

```swift
private func loadImage(from source: ImageSource) {
    switch source {
    case .url(let url):
        // Load from network (use your image loading library)
        loadFromNetwork(url)

    case .bundleAsset(let name):
        // Load from bundle - instant, no network
        imageView.image = UIImage(named: name, in: .module, compatibleWith: nil)

    case .none:
        // Show placeholder or empty state
        imageView.image = placeholderImage
    }
}
```

### Benefits

| Benefit | Explanation |
|---------|-------------|
| **Testability** | Mocks return `.bundleAsset` - no network calls in tests |
| **Type Safety** | Explicit enum cases instead of optional URLs |
| **Flexibility** | Easy to switch between remote and local images |
| **Clarity** | View code explicitly handles each case |

### When to Use

Use ImageSource + ImageResolver for:
- Team/club logos
- Game thumbnails
- Banner images
- User avatars
- Any image from external URLs

**Do NOT use** for static UI assets (icons, decorative images) - use `UIImage(named:)` directly.

---

## Snapshot Testing

Every component needs snapshot tests for visual regression testing.

### Step 1: Create Snapshot ViewController

Location: `GomaUI/Sources/GomaUI/Components/{Category}/{ComponentName}/{ComponentName}SnapshotViewController.swift`

```swift
import UIKit

final class {ComponentName}SnapshotViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundTestColor
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "{ComponentName}"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
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

        // Add all meaningful states
        stackView.addArrangedSubview(createVariant(label: "Default", viewModel: .defaultMock))
        stackView.addArrangedSubview(createVariant(label: "Selected", viewModel: .selectedMock))
        // Add more states as needed
    }

    private func createVariant(label: String, viewModel: Mock{ComponentName}ViewModel) -> UIStackView {
        let variantLabel = UILabel()
        variantLabel.text = label
        variantLabel.font = StyleProvider.fontWith(type: .medium, size: 12)
        variantLabel.textColor = StyleProvider.Color.textSecondary

        let component = {ComponentName}(viewModel: viewModel)

        let stack = UIStackView(arrangedSubviews: [variantLabel, component])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview { {ComponentName}SnapshotViewController() }
#endif
```

### Step 2: Create Snapshot Tests

Location: `GomaUI/Tests/GomaUITests/SnapshotTests/{ComponentName}/{ComponentName}SnapshotTests.swift`

```swift
import XCTest
import SnapshotTesting
@testable import GomaUI

final class {ComponentName}SnapshotTests: XCTestCase {

    func test{ComponentName}_Light() throws {
        let vc = {ComponentName}SnapshotViewController()
        assertSnapshot(
            of: vc,
            as: .image(
                on: SnapshotTestConfig.device,
                size: SnapshotTestConfig.size,
                traits: SnapshotTestConfig.lightTraits
            ),
            record: SnapshotTestConfig.record
        )
    }

    func test{ComponentName}_Dark() throws {
        let vc = {ComponentName}SnapshotViewController()
        assertSnapshot(
            of: vc,
            as: .image(
                on: SnapshotTestConfig.device,
                size: SnapshotTestConfig.size,
                traits: SnapshotTestConfig.darkTraits
            ),
            record: SnapshotTestConfig.record
        )
    }
}
```

### Step 3: Record Reference Images

1. Set `SnapshotTestConfig.record = true`
2. Run tests: `cmd + U` in Xcode
3. Verify images in `__Snapshots__/` folder
4. Set `SnapshotTestConfig.record = false`
5. Commit reference images to git

**Important**: For details on the synchronous rendering problem with Combine and solutions, see [Documentation/Guides/SNAPSHOT_TESTING.md](./Documentation/Guides/SNAPSHOT_TESTING.md).

---

## Catalog Integration

The GomaUICatalog app serves as the live component gallery.

### Step 1: Create Demo ViewController

Location: `Catalog/Components/{Category}/{ComponentName}ViewController.swift`

```swift
import UIKit
import GomaUI

final class {ComponentName}ViewController: UIViewController {

    private lazy var componentView = {ComponentName}(
        viewModel: Mock{ComponentName}ViewModel.defaultMock
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "{ComponentName}"
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        setupUI()
    }

    private func setupUI() {
        componentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(componentView)

        NSLayoutConstraint.activate([
            componentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            componentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            componentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
```

### Step 2: Register in ComponentCategory

Location: `Catalog/Components/Shared/ComponentCategory.swift`

Add your component to the appropriate category's components array.

### Step 3: Add to Components List

Add a `UIComponent` entry with:
- Title
- Description
- ViewController class
- Preview factory

```swift
UIComponent(
    title: "{ComponentName}",
    description: "Brief description of what this component does",
    viewController: {ComponentName}ViewController.self,
    previewFactory: {
        let viewModel = Mock{ComponentName}ViewModel.defaultMock
        return {ComponentName}(viewModel: viewModel)
    }
)
```

---

## Metadata Registration

The component catalog metadata powers the web documentation.

### Update catalog-metadata.json

Location: `Documentation/Catalog/catalog-metadata.json`

Add an entry for your component:

```json
"{ComponentName}": {
  "status": "complete",
  "displayName": "{ComponentName}",
  "category": "Betting|MatchCards|Navigation|Forms|Filters|Status|Promotions|Casino|Wallet|Profile|UIElements",
  "subcategory": "Specific subcategory or null",
  "summary": "One-line description (max 100 chars)",
  "description": "2-3 sentence description explaining purpose and usage",
  "complexity": "simple|composite|complex",
  "maturity": "stable|beta|deprecated",
  "tags": ["domain-tag", "ui-type-tag", "behavior-tag"],
  "states": ["default", "selected", "loading", "error"],
  "similarTo": ["SimilarComponent1", "SimilarComponent2"],
  "oftenUsedWith": ["ParentComponent", "ChildComponent"]
}
```

### Field Guidelines

| Field | Values | Guidance |
|-------|--------|----------|
| `complexity` | `simple` | Few files, no child components |
| | `composite` | Uses other GomaUI components |
| | `complex` | Many files, multiple children |
| `maturity` | `stable` | Production-ready |
| | `beta` | Has TODOs or incomplete features |
| | `deprecated` | Being phased out |
| `tags` | | Domain: betting, casino, wallet, match, user |
| | | UI type: card, button, list, input, banner |
| | | Behavior: interactive, selectable, scrollable |

### Validate JSON

```bash
node -e "require('./Frameworks/GomaUI/Documentation/Catalog/catalog-metadata.json'); console.log('JSON valid')"
```

---

## Pre-Submission Checklist

Before submitting your component, verify ALL items:

### Architecture
- [ ] One type per file - no exceptions
- [ ] ViewModelProtocol with `currentDisplayState` AND `displayStatePublisher`
- [ ] Mock uses `CurrentValueSubject` backing both properties
- [ ] View uses `dropFirst()` pattern for bindings
- [ ] ViewModel property is **optional** (handles `nil` gracefully)
- [ ] `configure(with:)` accepts **optional** ViewModel
- [ ] `prepareForReuse()` implemented (clears cancellables, viewModel, callbacks, child views, UI)
- [ ] `renderEmptyState()` implemented for nil ViewModel case

### Code Quality
- [ ] StyleProvider used for ALL colors and fonts (including FontProvider)
- [ ] Lazy properties with static factory methods
- [ ] No `print()` statements or debug code
- [ ] No TODO/FIXME comments
- [ ] All user interactions go through protocol methods
- [ ] Mock provides realistic simulated behavior

### Images (if component displays external images)
- [ ] Uses `ImageSource` enum (not raw URL strings)
- [ ] ImageResolver returns `ImageSource` (not `UIImage?`)
- [ ] View explicitly handles all cases: `.url`, `.bundleAsset`, `.none`
- [ ] Mock resolver returns `.bundleAsset` for testability

### Testing
- [ ] SnapshotViewController created in Sources
- [ ] Snapshot tests created (light + dark mode)
- [ ] Reference images recorded and committed
- [ ] All meaningful states covered in snapshots

### Catalog
- [ ] Demo ViewController created in Catalog/Components
- [ ] Component registered in appropriate category
- [ ] Preview factory returns working component
- [ ] Catalog app builds successfully

### Documentation
- [ ] catalog-metadata.json updated with component entry
- [ ] JSON validates without errors
- [ ] Summary is accurate and under 100 chars
- [ ] Tags reflect actual usage context

### Build Verification

```bash
# Get simulator ID
xcrun simctl list devices available | grep -E "iPhone" | head -5

# Build catalog app (replace YOUR_DEVICE_ID)
cd /Users/rroques/Desktop/GOMA/iOS/sportsbook-ios
xcodebuild -workspace Sportsbook.xcworkspace -scheme GomaUICatalog -destination 'platform=iOS Simulator,id=YOUR_DEVICE_ID' build 2>&1 | xcbeautify --quieter
```

---

## Common Pitfalls

### 1. Empty Snapshots

**Problem**: Snapshots show blank/unconfigured components.

**Cause**: Using `.receive(on: DispatchQueue.main)` without synchronous initial render.

**Solution**: Implement `currentDisplayState` + `dropFirst()` pattern. See [SNAPSHOT_TESTING.md](./Documentation/Guides/SNAPSHOT_TESTING.md).

### 2. Multiple Types in One File

**Problem**: Build works but violates architecture.

**Solution**: Extract every type (enum, helper class, struct) to its own file.

### 3. Hardcoded Colors

**Problem**: Component doesn't theme correctly.

**Solution**: Use StyleProvider for every color and font.

### 4. Stale Data in Cells

**Problem**: Recycled cells show wrong content.

**Solution**: Implement `ReusableView.prepareForReuse()` properly - clear cancellables, nil viewModel, reset UI.

### 5. Callback Bypassing Protocol

**Problem**: View has `var onTap: (() -> Void)?` instead of protocol method.

**Solution**: Remove callbacks, add methods to protocol, call `viewModel?.didTap()`.

### 6. Mock Does Nothing

**Problem**: Mock methods are empty or just print.

**Solution**: Mocks must update state to simulate real behavior.

---

## Reference Documentation

| Topic | Document |
|-------|----------|
| Critical Rules | [CLAUDE.md](./CLAUDE.md) |
| Component Creation | [Documentation/Guides/COMPONENT_CREATION.md](./Documentation/Guides/COMPONENT_CREATION.md) |
| UIKit Patterns | [Documentation/Guides/UIKIT_CODE_ORGANIZATION.md](./Documentation/Guides/UIKIT_CODE_ORGANIZATION.md) |
| Snapshot Testing | [Documentation/Guides/SNAPSHOT_TESTING.md](./Documentation/Guides/SNAPSHOT_TESTING.md) |
| Catalog Integration | [Documentation/Guides/ADDING_CATALOG_COMPONENTS.md](./Documentation/Guides/ADDING_CATALOG_COMPONENTS.md) |
| Localization | [Documentation/Guides/LOCALIZATION.md](./Documentation/Guides/LOCALIZATION.md) |
| Reactive Patterns | [Documentation/Guides/OBSERVABLE_UIKIT.md](./Documentation/Guides/OBSERVABLE_UIKIT.md) |

---

## Getting Help

1. **Study existing components** - ButtonView, OutcomeItemView, BorderedTextFieldView are good references
2. **Check the catalog app** - Run GomaUICatalog to see all components in action
3. **Read the guides** - Detailed documentation exists for each topic
4. **Ask in code review** - Reviewers can help identify issues

---

**Remember**: GomaUI components are production code, not scaffolds. Every component should work perfectly with its mock implementation in the catalog app.
