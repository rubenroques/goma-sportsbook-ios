# GomaUI Component Creation Guide

This guide outlines the recommended approach for creating new reusable UI components for the GomaUI library. Following these patterns will ensure consistency and maintainability across the codebase.

## Component Design Philosophy

GomaUI components follow these key principles:

1. **MVVM Architecture** - Clear separation between UI and business logic
2. **Protocol-Based Design** - View models defined by protocols for flexibility
3. **Reactive Programming** - Using Combine for state updates
4. **Consistent Styling** - Using centralized StyleProvider
5. **Easy Testability** - Mock implementations provided for all components

## Component Structure

Each UI component should consist of the following files organized in a dedicated directory:

```
GomaUI/Sources/GomaUI/YourComponentName/
├── YourComponentNameViewModelProtocol.swift
├── YourComponentNameView.swift
├── MockYourComponentNameViewModel.swift
└── Documentation/
    └── README.md
```

## Step-by-Step Creation Process

### 1. Create the View Model Protocol

Start by defining the data structures and protocol requirements:

```swift
import Combine
import UIKit

// MARK: - Data Models
public struct YourComponentData: Equatable, Hashable {
    // Define your component's data model properties
    public let id: String
    public let title: String

    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

// MARK: - Display State
public struct YourComponentDisplayState: Equatable {
    // Define how your component's visual state should be represented
    public let items: [YourComponentData]
    public let selectedItemId: String?

    public init(items: [YourComponentData], selectedItemId: String? = nil) {
        self.items = items
        self.selectedItemId = selectedItemId
    }
}

// MARK: - View Model Protocol
public protocol YourComponentViewModelProtocol {
    // Publisher for reactive updates
    var displayStatePublisher: AnyPublisher<YourComponentDisplayState, Never> { get }

    // User interaction methods
    func selectItem(withId id: String)
    func performAction()
}
```

### 2. Create the Component View

Implement the UI with the following structure:

```swift
import UIKit
import Combine
import SwiftUI

final public class YourComponentView: UIView {
    // MARK: - Private Properties
    private let containerView = UIView()
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: YourComponentViewModelProtocol

    // MARK: - Public Properties
    public var onItemSelected: ((String) -> Void) = { _ in }

    // MARK: - Initialization
    public init(viewModel: YourComponentViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupSubviews() {
        backgroundColor = StyleProvider.Color.backgroundPrimary

        // Add and configure subviews here
        // Use StyleProvider for colors and fonts
        // Ensure all constraints are properly set
    }

    private func setupBindings() {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(state: displayState)
            }
            .store(in: &cancellables)
    }

    // MARK: - Rendering
    private func render(state: YourComponentDisplayState) {
        // Update the UI based on the display state
    }

    // MARK: - Public Methods
    public func somePublicMethod() {
        // Public methods for external control of the component
    }
}

// MARK: - Preview Provider
#if DEBUG

#Preview("Default") {
    PreviewUIViewController {
        let vc = UIViewController()
        let component = YourComponentView(viewModel: MockYourComponentViewModel.defaultMock)
        component.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(component)

        NSLayoutConstraint.activate([
            component.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            component.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            component.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])

        return vc
    }
}

#endif
```

### 3. Create the Mock View Model

Provide a test implementation with sample data:

```swift
import Combine
import UIKit

/// Mock implementation of `YourComponentViewModelProtocol` for testing.
final public class MockYourComponentViewModel: YourComponentViewModelProtocol {

    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<YourComponentDisplayState, Never>
    public var displayStatePublisher: AnyPublisher<YourComponentDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }

    // Internal state
    private var internalData: [YourComponentData]
    private var selectedItemId: String?

    // MARK: - Initialization
    public init(items: [YourComponentData], selectedItemId: String? = nil) {
        self.internalData = items
        self.selectedItemId = selectedItemId

        // Create initial display state
        let initialState = YourComponentDisplayState(items: items, selectedItemId: selectedItemId)
        self.displayStateSubject = CurrentValueSubject(initialState)
    }

    // MARK: - YourComponentViewModelProtocol
    public func selectItem(withId id: String) {
        selectedItemId = id
        publishNewState()
    }

    public func performAction() {
        // Example action implementation
        publishNewState()
    }

    // MARK: - Helper Methods
    private func publishNewState() {
        let newState = YourComponentDisplayState(
            items: internalData,
            selectedItemId: selectedItemId
        )
        displayStateSubject.send(newState)
    }
}

// MARK: - Mock Factory
extension MockYourComponentViewModel {
    public static var defaultMock: MockYourComponentViewModel {
        // Create sample data for testing/preview
        let sampleItems = [
            YourComponentData(id: "item1", title: "First Item"),
            YourComponentData(id: "item2", title: "Second Item"),
            YourComponentData(id: "item3", title: "Third Item")
        ]

        return MockYourComponentViewModel(items: sampleItems, selectedItemId: "item1")
    }
}
```

### 4. Write Documentation

Create a README.md file explaining usage:

```markdown
# YourComponent

Brief description of what this component does and when to use it.

## Features

- Key feature 1
- Key feature 2
- Key feature 3

## Usage Example

```swift
// Create a view model (or use a mock for testing)
let viewModel = MockYourComponentViewModel.defaultMock

// Create the component
let componentView = YourComponentView(viewModel: viewModel)

// Add to your view hierarchy
parentView.addSubview(componentView)

// Set up constraints
NSLayoutConstraint.activate([
    componentView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
    componentView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
    componentView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor)
])

// Handle item selection
componentView.onItemSelected = { itemId in
    print("Item selected: \(itemId)")
    // Perform navigation or other actions
}
```

## Configuration Options

Describe the various properties and methods available for customization.
```

## Styling Guidelines

1. **Use StyleProvider** - Always use StyleProvider for colors and fonts instead of hardcoded values:
   ```swift
   // Correct
   backgroundColor = StyleProvider.Color.backgroundPrimary
   label.font = StyleProvider.fontWith(type: .medium, size: 14)

   // Incorrect
   backgroundColor = .white
   label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
   ```

2. **Auto Layout** - Always use Auto Layout constraints and avoid frame-based layout:
   ```swift
   view.translatesAutoresizingMaskIntoConstraints = false
   NSLayoutConstraint.activate([
       view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
       view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
       view.topAnchor.constraint(equalTo: containerView.topAnchor),
       view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
   ])
   ```

## Preview Helpers

GomaUI includes several helper classes to make it easier to preview your components in SwiftUI previews. These are located in the `GomaUI/Sources/GomaUI/Helpers/PreviewsHelper` directory.

### PreviewUIViewController (Recommended)

**Always prefer `PreviewUIViewController` over `PreviewUIView`** for previewing UIKit components. This wrapper provides a proper UIKit view hierarchy that more accurately represents how your component will behave in production:

**Why PreviewUIViewController is better:**
- **Proper AutoLayout behavior**: Constraints attach to a real UIViewController's view, behaving exactly as they would at runtime
- **Safe area support**: Access to `safeAreaLayoutGuide` for proper layout under navigation bars and notches
- **Resize detection**: Easier to spot layout issues when the container resizes
- **Real-world testing**: The preview environment matches production more closely

```swift
#Preview("Component Preview") {
    PreviewUIViewController {
        let vc = UIViewController()
        let component = YourComponentView(viewModel: MockYourComponentViewModel.defaultMock)
        component.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(component)

        NSLayoutConstraint.activate([
            component.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            component.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            component.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])

        return vc
    }
}
```

For multiple component states:

```swift
#Preview("Component States") {
    PreviewUIViewController {
        let vc = UIViewController()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(stackView)

        // Add multiple component states
        stackView.addArrangedSubview(YourComponentView(viewModel: MockYourComponentViewModel.stateMock1))
        stackView.addArrangedSubview(YourComponentView(viewModel: MockYourComponentViewModel.stateMock2))
        stackView.addArrangedSubview(YourComponentView(viewModel: MockYourComponentViewModel.stateMock3))

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])

        return vc
    }
}
```

### PreviewUIView (Simple Cases Only)

Use `PreviewUIView` only for very simple components where you just need a quick visual check and AutoLayout behavior is not critical:

```swift
#Preview("Quick Check") {
    PreviewUIView {
        YourSimpleView(viewModel: MockViewModel.defaultMock)
    }
    .frame(height: 100)
}
```

**Limitations of PreviewUIView:**
- SwiftUI controls sizing via `.frame()` modifiers, which can mask AutoLayout issues
- No access to `safeAreaLayoutGuide`
- Intrinsic content size calculations may not match runtime behavior
- Harder to detect resize/constraint issues

### PreviewTableViewController

A special helper for previewing components in a table view, useful for showing multiple states of a component:

```swift
// Define your component states
struct ComponentState: PreviewStateRepresentable {
    let title: String
    let subtitle: String?
    let cellHeight: CGFloat?

    // Sample data for the component
    let color: UIColor
    let text: String
}

#Preview("Component States in Table") {
    PreviewUIViewController {
        PreviewTableViewController(
            states: [
                ComponentState(title: "Default State", subtitle: "The basic appearance", cellHeight: 80, color: .systemBlue, text: "Default"),
                ComponentState(title: "Selected State", subtitle: "When an item is selected", cellHeight: 80, color: .systemGreen, text: "Selected"),
                ComponentState(title: "Disabled State", subtitle: "When component is disabled", cellHeight: 80, color: .systemGray, text: "Disabled")
            ],
            defaultCellHeight: UITableView.automaticDimension
        ) { cell, state, _ in
            // Configure a custom cell with your component
            let component = YourComponentView(viewModel: YourMockFactory.createMock(color: state.color, text: state.text))
            cell.contentView.addSubview(component)
            component.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                component.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
                component.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                component.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                component.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8)
            ])
        }
    }
}
```

These preview helpers make it easier to create comprehensive previews that showcase your component in various states and contexts, improving the development and review process.

## Testing Your Component

Add the component to the TestCase app by:

1. Creating a view controller in the TestCase directory:
   ```swift
   // YourComponentViewController.swift
   import UIKit
   import GomaUI

   class YourComponentViewController: UIViewController {
       private var componentView: YourComponentView!

       override func viewDidLoad() {
           super.viewDidLoad()
           setupViews()
       }

       private func setupViews() {
           let viewModel = MockYourComponentViewModel.defaultMock
           componentView = YourComponentView(viewModel: viewModel)
           componentView.translatesAutoresizingMaskIntoConstraints = false

           view.addSubview(componentView)
           NSLayoutConstraint.activate([
               componentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               componentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               componentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
           ])

           // Handle component events
           componentView.onItemSelected = { itemId in
               print("Item selected: \(itemId)")
           }
       }
   }
   ```

2. Adding your component to the ComponentsTableViewController:
   ```swift
   private let components: [UIComponent] = [
       // Existing components...
       UIComponent(
           title: "Your Component",
           description: "Brief description of your component",
           viewController: YourComponentViewController.self
       )
   ]
   ```

## Final Checklist

Before completing your component, ensure:

### Architecture
- [ ] All view model methods are implemented
- [ ] Protocol has both `currentDisplayState` AND `displayStatePublisher`
- [ ] View uses `dropFirst()` pattern to avoid double-render
- [ ] Mock uses `CurrentValueSubject` backing both state properties
- [ ] `ReusableView` protocol implemented with `prepareForReuse()`

### Code Quality
- [ ] StyleProvider is used for all colors and fonts
- [ ] Auto Layout constraints are properly set
- [ ] Component reacts correctly to state changes
- [ ] Mock view model provides realistic simulated behavior
- [ ] No `print()` statements or debug code
- [ ] No TODO/FIXME comments

### Testing & Documentation
- [ ] SwiftUI previews work correctly
- [ ] **Snapshot tests created** (light + dark mode) - See [SNAPSHOT_TESTING.md](./SNAPSHOT_TESTING.md)
- [ ] Reference images recorded and committed
- [ ] **Component added to GomaUICatalog** - See [ADDING_CATALOG_COMPONENTS.md](./ADDING_CATALOG_COMPONENTS.md)
- [ ] **catalog-metadata.json updated** with component entry
- [ ] Documentation README.md explains usage

### Build Verification
- [ ] GomaUICatalog scheme builds successfully

For the complete contribution workflow including all steps, see the **[CONTRIBUTING.md](../../CONTRIBUTING.md)** guide.

Following these guidelines will ensure your component integrates seamlessly with the GomaUI library and provides a consistent user experience across the application.
