## Prompt
You are a senior iOS developer. You are given a XIB file and you need to migrate it to programmatic UI.
You need to follow the steps below to migrate the UI from XIB to programmatic UI.
You need to be very accurate and detailed in the migration.
No placeholders or comments, write all the code needed.
Avoid any explanation, or follow up questions, just write the code.

## Overview
This document provides a systematic approach to migrating UIKit views from Interface Builder (XIB) files to programmatic UI in iOS applications. The process ensures a 1:1 visual match while maintaining all functionality.

## Prerequisites
- Access to the original XIB file
- Understanding of Auto Layout constraints
- Knowledge of UIKit components
- Understanding of view hierarchies

## Migration Process

### 1. Analysis Phase

#### 1.1 XIB File Analysis
- Open the XIB file and identify:
  - All UI elements and their hierarchies
  - Custom classes and their connections
  - IBOutlets and IBActions
  - Constraint relationships and constants
  - View tags and accessibility identifiers
  - Custom properties (corner radius, background colors, etc.)
  - Font specifications and text properties
  - Content mode settings for images
  - Layer properties (borders, shadows, etc.)

#### 1.2 Constraint Documentation
- Document all constraints with their:
  - Source and target views
  - Constraint types (leading, trailing, top, bottom, etc.)
  - Constants and multipliers
  - Priorities
  - Relationships (equal, greater than, less than)
  - Constraint variations for different states (if any)

### 2. Implementation Phase

#### 2.1 Property Declaration
```swift
// MARK: - Views
private lazy var mainView: UIView = Self.createMainView()
private lazy var contentView: UIView = Self.createContentView()
// ... declare all views as lazy properties
```

#### 2.2 View Creation Methods
- Create static factory methods for each view:
```swift
private static func createMainView() -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    // Set all view properties
    return view
}
```

#### 2.3 View Setup Rules
1. Always set `translatesAutoresizingMaskIntoConstraints = false`
2. Set all properties before adding constraints
3. Maintain the same view hierarchy as in XIB
4. Set accessibility identifiers if present
5. Configure gesture recognizers if needed
6. Set up delegates and data sources
7. Register cells for collections/tables
8. Configure layer properties

#### 2.4 Constraint Setup
1. Group constraints logically:
```swift
// Main container constraints
NSLayoutConstraint.activate([
    mainView.topAnchor.constraint(equalTo: view.topAnchor),
    mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    // ...
])

// Content constraints
NSLayoutConstraint.activate([
    // ...
])
```

2. Maintain constraint priorities
3. Store constraints that need to be modified later as properties
4. Use the same constants as in XIB
5. Consider safe area and layout margins
6. Handle dynamic constraints (height/width based on content)

### 3. View Hierarchy Setup

#### 3.1 Setup Order
1. Create all views using factory methods
2. Add subviews in correct order (bottom to top for z-index)
3. Set up constraints
4. Configure initial state
5. Set up gesture recognizers
6. Initialize delegates and data sources

#### 3.2 View Controller Setup
```swift
override func loadView() {
    view = UIView()
    view.backgroundColor = .systemBackground
}

override func viewDidLoad() {
    super.viewDidLoad()
    setupSubviews()
    initConstraints()
    setupInitialState()
}
```
#### 3.3 Code Organization
1. All this three methods setupSubviews, initConstraints, setupInitialState should be in an extension of the view controller/view at the bottom of the file
2. All the view creation methods should be in that extension of the view at the bottom of the file
3. All the constraints setup should be in that extension of the view at the bottom of the file

### 4. State Management

#### 4.1 Dynamic Properties
- Store constraints that change based on state
- Create methods for state transitions
- Maintain animation durations from XIB
- Handle state-dependent layout changes

#### 4.2 Animation Handling
```swift
UIView.animate(withDuration: 0.3) {
    self.someConstraint.constant = newValue
    self.view.layoutIfNeeded()
}
```

### 5. Best Practices

#### 5.1 Code Organization
- Group related properties together
- Use MARK comments for sections
- Keep view creation methods together
- Separate constraint setup into logical groups
- Document complex constraint relationships

#### 5.2 Naming Conventions
- Use descriptive names matching XIB
- Maintain consistent suffix patterns:
  - Views: `xxxView`
  - Labels: `xxxLabel`
  - Buttons: `xxxButton`
  - Constraints: `xxxConstraint`

#### 5.3 Memory Management
- Use `weak` references appropriately
- Clean up observers and gesture recognizers
- Handle view lifecycle properly

#### 5.4 Error Prevention
- Verify all constraints are active
- Check for constraint conflicts
- Validate view hierarchy
- Test all state transitions
- Verify dynamic behavior matches XIB

### 6. Testing and Verification

#### 6.1 Visual Testing
- Compare with XIB version in:
  - Different screen sizes
  - Light/dark mode
  - Different content sizes
  - RTL layouts
  - Dynamic type sizes

#### 6.2 Functional Testing
- Verify all interactions work
- Test state transitions
- Validate animations
- Check accessibility
- Verify dynamic content handling

### 7. Common Pitfalls

#### 7.1 Layout Issues
- Missing constraints
- Conflicting constraints
- Incorrect priorities
- Wrong anchor points
- Forgotten safe area/layout margins

#### 7.2 State Management
- Incorrect initial states
- Missing state updates
- Animation glitches
- Constraint deactivation issues

### 8. Migration Checklist

#### 8.1 Pre-Migration
- [ ] Document all XIB elements
- [ ] Map view hierarchy
- [ ] List all constraints
- [ ] Note custom properties
- [ ] Document state changes

#### 8.2 During Migration
- [ ] Create view properties
- [ ] Implement factory methods
- [ ] Set up view hierarchy
- [ ] Add constraints
- [ ] Configure initial state
- [ ] Add interactions
- [ ] Handle state changes

#### 8.3 Post-Migration
- [ ] Visual verification
- [ ] Functional testing
- [ ] Performance testing
- [ ] Accessibility check
- [ ] Code review
- [ ] Documentation update

### 9. Example Migration

```swift
// Original XIB outlet
@IBOutlet weak var containerView: UIView!

// Becomes:
private lazy var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .systemBackground
    view.layer.cornerRadius = 8
    return view
}()

// Original XIB constraint
// <constraint firstItem="containerView" firstAttribute="top" secondItem="view" secondAttribute="top" constant="20"/>

// Becomes:
NSLayoutConstraint.activate([
    containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)
])
```

## Conclusion
Successful migration requires attention to detail, systematic approach, and thorough testing. Follow this guide to ensure accurate reproduction of XIB functionality in programmatic UI.