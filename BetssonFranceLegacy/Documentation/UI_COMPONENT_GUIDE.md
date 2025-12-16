# UI Component Development Guide

This guide documents the standard patterns and conventions for creating custom **UI Views and View Controllers** in the Sportsbook iOS application. Both UIView components and UIViewController classes follow the same organizational principles.

## Table of Contents
- [Overview](#overview)
- [Component Structure](#component-structure)
- [Code Organization](#code-organization)
- [Implementation Steps](#implementation-steps)
- [View Controller Specific Patterns](#view-controller-specific-patterns)
- [Best Practices](#best-practices)
- [Common Patterns](#common-patterns)
- [Example Templates](#example-templates)

## Overview

This guide applies to both:
- **Custom UI Views** (`UIView` subclasses) - Reusable components
- **View Controllers** (`UIViewController` subclasses) - Screen-level components

Both follow the same organizational patterns with lazy property initialization and structured code organization.

## Component Structure

All custom UI components follow a consistent structure that promotes maintainability, readability, and adherence to the codebase's architectural principles.

### Standard File Organization

```swift
import UIKit

class ComponentNameView: UIView {
    
    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    // ... other UI components
    
    // MARK: - Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
        self.setupWithTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
        self.setupWithTheme()
    }
    
    func commonInit() {
        self.setupSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Dynamic layout updates (e.g., corner radius)
    }
    
    func setupWithTheme() {
        // Apply theme colors and styles
    }
    
    // MARK: Functions
    // Public API methods
}

// MARK: - Subviews Initialization and Setup
extension ComponentNameView {
    
    // Static factory methods
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    // Setup methods
    private func setupSubviews() {
        // Add subviews
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // All constraints in one place
        ])
    }
}
```

## Code Organization

### 1. Property Declaration

All UI components must be declared as `private lazy var` with static factory methods:

```swift
private lazy var componentName: ComponentType = Self.createComponentName()
```

**Benefits:**
- Deferred initialization (created only when accessed)
- Memory efficiency
- Clean separation between declaration and configuration
- Consistent initialization pattern

### 2. Initialization Flow

```swift
init (frame or coder)
    ↓
commonInit()
    ↓
setupSubviews()
    ↓
initConstraints()
    ↓
setupWithTheme()
```

### 3. MARK Comments Structure

Use MARK comments to clearly delineate sections:

```swift
// MARK: Private properties
// MARK: Public properties (if any)
// MARK: - Lifetime and Cycle
// MARK: Functions
// MARK: - Subviews Initialization and Setup
```

## Implementation Steps

### Step 1: Create the Class

**For UIView:**
```swift
import UIKit

class MyCustomView: UIView {
    // Start with the basic structure
}
```

**For UIViewController:**
```swift
import UIKit

class MyViewController: UIViewController {
    // Start with the basic structure
}
```

### Step 2: Define Lazy Properties

```swift
// MARK: Private properties
private lazy var stackView: UIStackView = Self.createStackView()
private lazy var titleLabel: UILabel = Self.createTitleLabel()
private lazy var iconImageView: UIImageView = Self.createIconImageView()
```

### Step 3: Implement Initializers

```swift
// MARK: - Lifetime and Cycle
override init(frame: CGRect) {
    super.init(frame: frame)
    self.commonInit()
    self.setupWithTheme()
}

required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.commonInit()
    self.setupWithTheme()
}

func commonInit() {
    self.setupSubviews()
}
```

### Step 4: Create Factory Methods

```swift
// MARK: - Subviews Initialization and Setup
extension MyCustomView {
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 1
        return label
    }
}
```

### Step 5: Setup View Hierarchy

```swift
private func setupSubviews() {
    self.addSubview(self.stackView)
    
    self.stackView.addArrangedSubview(self.iconImageView)
    self.stackView.addArrangedSubview(self.titleLabel)
    
    self.initConstraints()
}
```

### Step 6: Define Constraints

```swift
private func initConstraints() {
    NSLayoutConstraint.activate([
        self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
        self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
        self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
        self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
        
        self.iconImageView.widthAnchor.constraint(equalToConstant: 24),
        self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor)
    ])
}
```

### Step 7: Apply Theme

```swift
func setupWithTheme() {
    self.backgroundColor = UIColor.App.backgroundPrimary
    self.titleLabel.textColor = UIColor.App.textPrimary
    // Never use hardcoded colors!
}
```

### Step 8: Implement Public API

```swift
// MARK: Functions
func configure(title: String, icon: UIImage?) {
    self.titleLabel.text = title
    self.iconImageView.image = icon
}
```

## View Controller Specific Patterns

View Controllers follow the same lazy initialization and organization patterns but with some specific considerations:

### Standard View Controller Structure

```swift
import UIKit
import Combine

class MyViewController: UIViewController {
    
    // MARK: Private properties
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentView: UIView = Self.createContentView()
    private lazy var headerView: UIView = Self.createHeaderView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    
    // MARK: ViewModel/Coordinator
    private let viewModel: MyViewModelProtocol
    private weak var coordinator: MyCoordinatorProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializers
    init(viewModel: MyViewModelProtocol, coordinator: MyCoordinatorProtocol) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupWithTheme()
    }
    
    // MARK: - Setup
    private func setupView() {
        self.setupSubviews()
    }
    
    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary
        // Apply theme
    }
    
    private func setupBindings() {
        // Combine bindings
    }
    
    // MARK: Functions
    // Public methods
}

// MARK: - Subviews Initialization and Setup
extension MyViewController {
    // Factory methods and setup
}
```

### Key Differences for View Controllers

1. **Lifecycle Methods**
   - Use `viewDidLoad` instead of `commonInit()`
   - Theme setup often in `viewWillAppear` for dynamic theme changes
   - Binding setup separate from view setup

2. **Dependencies**
   - ViewModels and Coordinators injected via initializer
   - Combine cancellables for reactive bindings
   - Protocol-based dependencies

3. **Navigation Setup**
   ```swift
   override func viewDidLoad() {
       super.viewDidLoad()
       self.setupNavigationBar()
       self.setupView()
       self.setupBindings()
   }
   
   private func setupNavigationBar() {
       self.title = "Screen Title"
       self.navigationController?.navigationBar.prefersLargeTitles = false
   }
   ```

4. **Root View Setup**
   ```swift
   private func setupSubviews() {
       self.view.addSubview(self.scrollView)
       self.scrollView.addSubview(self.contentView)
       self.contentView.addSubview(self.headerView)
       // ... other subviews
       
       self.initConstraints()
   }
   ```

## Best Practices

### DO's ✅

1. **Always use lazy initialization** for UI components
2. **Always set** `translatesAutoresizingMaskIntoConstraints = false` in factory methods
3. **Always use** `NSLayoutConstraint.activate()` with an array of constraints
4. **Always use** theme colors (`UIColor.App.*`) and fonts (`AppFont.with()`)
5. **Always implement** both initializers (frame and coder)
6. **Always organize** code with proper MARK comments
7. **Always make** UI components private unless external access is required
8. **Always use** static factory methods prefixed with `create`

### DON'Ts ❌

1. **Never hardcode** colors, fonts, or dimensions
2. **Never access** UI components directly from outside the view
3. **Never put** business logic in views
4. **Never forget** to call `self.commonInit()` in both initializers
5. **Never activate** constraints individually
6. **Never create** UI components in the property declaration directly

## Common Patterns

### Container View Pattern

Most components use a container view for consistent spacing:

```swift
private lazy var containerView: UIView = Self.createContainerView()

// In setupSubviews:
self.addSubview(self.containerView)
// Add other views to containerView, not self
```

### Dynamic Layout Updates

Use `layoutSubviews()` for properties that depend on bounds:

```swift
override func layoutSubviews() {
    super.layoutSubviews()
    self.containerView.layer.cornerRadius = CornerRadius.button
}
```

### Reactive Updates (when needed)

For views that need to react to state changes:

```swift
import Combine

class ReactiveComponentView: UIView {
    private var cancellables = Set<AnyCancellable>()
    
    func bind(to viewModel: ComponentViewModel) {
        viewModel.$title
            .sink { [weak self] title in
                self?.titleLabel.text = title
            }
            .store(in: &cancellables)
    }
}
```

### Configuration Methods

Keep configuration methods simple and focused:

```swift
func configure(model: ComponentModel) {
    self.titleLabel.text = model.title
    self.subtitleLabel.text = model.subtitle
    self.iconImageView.image = model.icon
}
```

## Example Templates

### UIView Template

Here's a complete template for a new UI component:

```swift
//
//  MyComponentView.swift
//  Sportsbook
//
//  Created by [Your Name] on [Date].
//

import UIKit

class MyComponentView: UIView {
    
    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    
    // MARK: - Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
        self.setupWithTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
        self.setupWithTheme()
    }
    
    func commonInit() {
        self.setupSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.layer.cornerRadius = CornerRadius.small
    }
    
    func setupWithTheme() {
        self.containerView.backgroundColor = UIColor.App.backgroundSecondary
        self.titleLabel.textColor = UIColor.App.textPrimary
        self.subtitleLabel.textColor = UIColor.App.textSecondary
    }
    
    // MARK: Functions
    func configure(title: String, subtitle: String?) {
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
        self.subtitleLabel.isHidden = subtitle == nil
    }
}

// MARK: - Subviews Initialization and Setup
extension MyComponentView {
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 16)
        label.numberOfLines = 1
        return label
    }
    
    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 2
        return label
    }
    
    private func setupSubviews() {
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.subtitleLabel)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            // Title
            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 12),
            
            // Subtitle
            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 4),
            self.subtitleLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -12)
        ])
    }
}
```

### UIViewController Template

Here's a complete template for a new View Controller:

```swift
//
//  MyViewController.swift
//  Sportsbook
//
//  Created by [Your Name] on [Date].
//

import UIKit
import Combine

class MyViewController: UIViewController {
    
    // MARK: Private properties
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentView: UIView = Self.createContentView()
    private lazy var headerView: UIView = Self.createHeaderView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var actionButton: UIButton = Self.createActionButton()
    
    // MARK: ViewModel/Coordinator
    private let viewModel: MyViewModelProtocol
    private weak var coordinator: MyCoordinatorProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializers
    init(viewModel: MyViewModelProtocol, coordinator: MyCoordinatorProtocol) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupView()
        self.setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupWithTheme()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        self.title = "My Screen"
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupView() {
        self.setupSubviews()
    }
    
    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary
        self.headerView.backgroundColor = UIColor.App.backgroundSecondary
        self.titleLabel.textColor = UIColor.App.textPrimary
        self.subtitleLabel.textColor = UIColor.App.textSecondary
    }
    
    private func setupBindings() {
        // ViewModel bindings
        self.viewModel.titlePublisher
            .sink { [weak self] title in
                self?.titleLabel.text = title
            }
            .store(in: &cancellables)
        
        // Button actions
        self.actionButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.performAction()
            }
            .store(in: &cancellables)
    }
    
    // MARK: Functions
    func updateContent() {
        // Public methods for external updates
    }
}

// MARK: - Subviews Initialization and Setup
extension MyViewController {
    
    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }
    
    private static func createContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createHeaderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 24)
        label.numberOfLines = 1
        return label
    }
    
    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 16)
        label.numberOfLines = 0
        return label
    }
    
    private static func createActionButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Action", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 16)
        return button
    }
    
    private func setupSubviews() {
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.contentView)
        
        self.contentView.addSubview(self.headerView)
        self.headerView.addSubview(self.titleLabel)
        self.headerView.addSubview(self.subtitleLabel)
        self.contentView.addSubview(self.actionButton)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            // ContentView
            self.contentView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
            self.contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            self.contentView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),
            
            // HeaderView
            self.headerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.headerView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            
            // Title
            self.titleLabel.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor, constant: 16),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor, constant: -16),
            self.titleLabel.topAnchor.constraint(equalTo: self.headerView.topAnchor, constant: 20),
            
            // Subtitle
            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8),
            self.subtitleLabel.bottomAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: -20),
            
            // Action Button
            self.actionButton.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.actionButton.topAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: 32),
            self.actionButton.bottomAnchor.constraint(lessThanOrEqualTo: self.contentView.bottomAnchor, constant: -32),
            self.actionButton.heightAnchor.constraint(equalToConstant: 48),
            self.actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])
    }
}
```

## Important Reminders

1. **This is a UIKit-only project** - No SwiftUI views (previews are okay)
2. **Always use StyleProvider patterns** - Never hardcode colors or fonts
3. **Follow the 4-file structure** when creating complex components
4. **Add files to Xcode manually** - This project uses groups, not folder references
5. **Test on multiple screen sizes** - Ensure constraints work properly
6. **Keep views dumb** - Business logic belongs in ViewModels

---

*This guide should be updated as patterns evolve. When in doubt, look at existing components in the Core/Views directory for reference.*