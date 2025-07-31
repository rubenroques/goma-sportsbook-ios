# PillItemView

PillItemView is a flexible, pill-shaped component designed for use in navigation and filter interfaces. It features a customizable appearance with support for text, icons, and selection states.

## Features

- **Customizable Appearance**: Show or hide left icon and expand icon
- **Selection State**: Visual styling changes based on selection state
- **User Interaction**: Built-in tap handling with callback support
- **Accessibility**: Full accessibility support for screen readers

## Use Cases

- Category or filter selection in content feeds
- Segmented navigation controls
- Tag-based filtering systems
- Dropdown menu triggers

## Usage Example

```swift
// Create a view model (or use a mock for testing)
let viewModel = MockPillItemViewModel(
    pillData: PillData(
        id: "sports",
        title: "Sports",
        leftIconName: "sportscourt.fill",
        showExpandIcon: true,
        isSelected: false
    )
)

// Create the component
let pillItemView = PillItemView(viewModel: viewModel)
pillItemView.translatesAutoresizingMaskIntoConstraints = false

// Add to your view hierarchy
parentView.addSubview(pillItemView)

// Set up constraints
NSLayoutConstraint.activate([
    pillItemView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 16),
    pillItemView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: 16),
    pillItemView.heightAnchor.constraint(equalToConstant: 40),
    pillItemView.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
])

// Handle selection
pillItemView.onPillSelected = {
    print("Pill was selected")
    // Perform navigation or other actions
}
```

## Multiple Pills Example

```swift
// Create a horizontal stack to hold multiple pills
let pillsStackView = UIStackView()
pillsStackView.axis = .horizontal
pillsStackView.spacing = 8
pillsStackView.distribution = .fillProportionally
pillsStackView.alignment = .center
pillsStackView.translatesAutoresizingMaskIntoConstraints = false

// Add to your view hierarchy
parentView.addSubview(pillsStackView)

// Set up constraints
NSLayoutConstraint.activate([
    pillsStackView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 16),
    pillsStackView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -16),
    pillsStackView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: 16),
    pillsStackView.heightAnchor.constraint(equalToConstant: 50)
])

// Create and add multiple pills
let footballPill = PillItemView(viewModel: MockPillItemViewModel.footballPill)
let popularPill = PillItemView(viewModel: MockPillItemViewModel.popularPill)
let allPill = PillItemView(viewModel: MockPillItemViewModel.allPill)

pillsStackView.addArrangedSubview(footballPill)
pillsStackView.addArrangedSubview(popularPill)
pillsStackView.addArrangedSubview(allPill)

// Handle selections
footballPill.onPillSelected = {
    // Handle football selection
}

popularPill.onPillSelected = {
    // Handle popular selection
}

allPill.onPillSelected = {
    // Handle all selection
}
```

## Configuration Options

### PillData Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | Unique identifier for the pill |
| `title` | String | Text displayed in the pill |
| `leftIconName` | String? | Optional name of image/SF Symbol for left icon |
| `showExpandIcon` | Bool | Whether to show the expand chevron icon |
| `isSelected` | Bool | Whether the pill is in selected state |

### Styling

The PillItemView uses the StyleProvider for consistent styling:

```swift
// Customize colors for pills
StyleProvider.Color.customize(
    primaryColor: UIColor(named: "BrandPrimary"),
    secondaryColor: UIColor(named: "SecondaryGray"),
    contrastTextColor: .white
)
```

## Accessibility

The PillItemView component includes proper accessibility support:

- The entire pill is exposed as a single accessible element
- Appropriate button and selected traits are applied
- The pill's title is used as the accessibility label

## Implementation Notes

- The component automatically adjusts its layout based on which optional elements are shown
- Icons are tinted according to the pill's selection state
- A tap gesture recognizer handles user interaction
- The view model controls the pill's state through Combine publishers