# View Components

This document describes the Swift UIView subclasses that form the visual part of the `QuickLinksTabBar` component: `QuickLinksTabBarView` and `QuickLinkTabBarItemView`.

## 1. `QuickLinksTabBarView.swift`

* **Inherits from**: `UIView`
* **Purpose**: The main container view that displays a horizontal row of quick link items. It manages the overall layout and handles the communication between the view model and individual item views.

### Key Responsibilities and Behavior:

#### Properties
* **Private Properties**:
  * `stackView: UIStackView`: A horizontal stack view that holds all the quick link item views.
  * `viewModel: QuickLinksTabBarViewModelProtocol`: The view model that provides the quick links data.
  * `cancellables: Set<AnyCancellable>`: Stores Combine subscriptions.

* **Public Properties**:
  * `onQuickLinkSelected: ((QuickLinkType) -> Void)`: A callback closure that's executed when a quick link is tapped, allowing consumers to respond to selections.

#### Initialization
* **Initializer**: 
  * Takes an object conforming to `QuickLinksTabBarViewModelProtocol`.
  * Sets up the UI and bindings.

#### Key Methods
* **`setupSubviews()`**: 
  * Configures the view's appearance and layout.
  * Sets the fixed height of 40 points.
  * Adds and configures the `stackView`.

* **`setupBindings()`**: 
  * Subscribes to the view model's `quickLinksPublisher`.
  * When new links are received, calls `render(quickLinks:)`.

* **`render(quickLinks: [QuickLinkItem])`**: 
  * Clears existing item views from the stack view.
  * Creates a new `QuickLinkTabBarItemView` for each quick link item.
  * Configures each item view with its corresponding data.
  * Sets up tap handling to forward taps to the view model and through the `onQuickLinkSelected` callback.
  * Adds each configured item view to the stack view.

### Code Structure

```swift
final public class QuickLinksTabBarView: UIView {
    // MARK: - Private Properties
    private let stackView: UIStackView
    private let viewModel: QuickLinksTabBarViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    var onQuickLinkSelected: ((QuickLinkType) -> Void) = { _ in }
    
    // MARK: - Initialization
    public init(viewModel: QuickLinksTabBarViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupSubviews() {
        // Configure the view's appearance and layout
        // Set fixed height of 40 points
    }
    
    private func setupBindings() {
        // Subscribe to viewModel.quickLinksPublisher
        // Call render(quickLinks:) when new links are received
    }
    
    private func render(quickLinks: [QuickLinkItem]) {
        // Clear existing item views
        // Create and configure a new QuickLinkTabBarItemView for each quick link
        // Set up tap handling
        // Add item views to the stack view
    }
}
```

## 2. `QuickLinkTabBarItemView.swift`

* **Inherits from**: `UIView`
* **Purpose**: Represents a single, tappable quick link item within the bar. It displays an icon and a title.

### Key Responsibilities and Behavior:

#### Properties
* **UI Elements**:
  * `iconImageView: UIImageView`: Displays the item's icon.
  * `titleLabel: UILabel`: Displays the item's title.
  * `containerStackView: UIStackView`: A vertical stack view that arranges the icon above the title.

* **Public Properties**:
  * `onTap: (() -> Void)?`: A callback closure that's executed when the item is tapped.

* **Private Properties**:
  * `linkType: QuickLinkType?`: Stores the type of the quick link this view represents.

#### Key Methods
* **`configure(with: QuickLinkItem)`**: 
  * Sets the view's content based on the provided quick link item.
  * Stores the link type.
  * Sets the icon image and title text.

* **`setupSubviews()`**: 
  * Adds and configures the container stack view, icon image view, and title label.
  * Sets up the view hierarchy.

* **`setupGestures()`**: 
  * Adds a tap gesture recognizer to the view.
  * Configures the view to be user-interactive.

* **`handleTap()`**: 
  * Called when the view is tapped.
  * Executes the `onTap` closure if it's set.

### Code Structure

```swift
final public class QuickLinkTabBarItemView: UIView {
    // MARK: - UI Elements
    private lazy var iconImageView: UIImageView
    private lazy var titleLabel: UILabel
    private lazy var containerStackView: UIStackView

    // MARK: - Properties
    public var onTap: (() -> Void)?
    private(set) var linkType: QuickLinkType?

    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupGestures()
    }

    // MARK: - Configuration
    public func configure(with item: QuickLinkItem) {
        self.linkType = item.type
        self.iconImageView.image = item.icon
        self.titleLabel.text = item.title
    }

    // MARK: - Private Methods
    private func setupSubviews() {
        // Add and configure subviews
    }

    private func setupGestures() {
        // Add tap gesture recognizer
    }

    @objc private func handleTap() {
        onTap?()
    }
}
```

## Interaction Between Components

1. **Initialization Flow**:
   * `QuickLinksTabBarView` is initialized with a view model.
   * It subscribes to the view model's publisher to receive quick link items.
   * When quick link items are received, it creates and configures `QuickLinkTabBarItemView` instances.

2. **User Interaction Flow**:
   * User taps a `QuickLinkTabBarItemView`.
   * The item view executes its `onTap` closure.
   * This closure (set by `QuickLinksTabBarView`) notifies the view model via `didTapQuickLink(type:)` and executes the `onQuickLinkSelected` callback.
   * The consumer of `QuickLinksTabBarView` can respond to the selection through the callback.

3. **Update Flow**:
   * The view model publishes new quick link items.
   * `QuickLinksTabBarView` receives these items and calls `render(quickLinks:)`.
   * The view clears existing item views and creates new ones for the updated items.

This component design keeps responsibilities clearly separated, with `QuickLinksTabBarView` handling overall layout and coordination, while `QuickLinkTabBarItemView` focuses on displaying and handling interactions for individual items. 