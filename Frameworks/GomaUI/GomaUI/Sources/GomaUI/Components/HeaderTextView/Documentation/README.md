# HeaderTextView

A simple, reusable header text component that displays a centered title with customizable styling.

## Overview

`HeaderTextView` is a lightweight UI component designed to display section headers or titles with consistent styling. It follows the GomaUI component architecture with MVVM pattern, protocol-based design, and reactive updates.

## Features

- **Centered text display** with customizable title
- **Flexible styling** - customizable text color, background color, and font
- **Protocol-based design** for easy testing and mocking
- **Reactive updates** through view model binding
- **Consistent theming** using StyleProvider
- **Rounded corners** with 8pt radius for modern appearance

## Usage

### Basic Implementation

```swift
import GomaUI

// Create view model
let viewModel = MockHeaderTextViewViewModel()
viewModel.updateTitle("Suggested Events")

// Create and configure view
let headerView = HeaderTextView(viewModel: viewModel)
headerView.configure()
```

### Custom Styling

```swift
let viewModel = MockHeaderTextViewViewModel()
viewModel.updateTitle("Custom Header")
viewModel.updateColors(
    textColor: UIColor.systemBlue,
    backgroundColor: UIColor.systemGray6
)
viewModel.updateFont(UIFont.systemFont(ofSize: 20, weight: .bold))

let headerView = HeaderTextView(viewModel: viewModel)
headerView.configure()
```

### Custom ViewModel Implementation

```swift
class MyHeaderViewModel: HeaderTextViewViewModelProtocol {
    var title: String = "My Title"
    var textColor: UIColor? = UIColor.systemBlue
    var backgroundColor: UIColor? = UIColor.systemGray6
    var font: UIFont? = UIFont.systemFont(ofSize: 18, weight: .semibold)
    
    var refreshData: (() -> Void)?
    
    func updateTitle(_ title: String) {
        self.title = title
        self.refreshData?()
    }
    
    func updateColors(textColor: UIColor?, backgroundColor: UIColor?) {
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.refreshData?()
    }
    
    func updateFont(_ font: UIFont?) {
        self.font = font
        self.refreshData?()
    }
}
```

## Architecture

### Protocol Interface

The component uses `HeaderTextViewViewModelProtocol` to define the contract between the view and its view model:

- `title: String` - The text to display
- `textColor: UIColor?` - Optional custom text color
- `backgroundColor: UIColor?` - Optional custom background color
- `font: UIFont?` - Optional custom font
- `refreshData: (() -> Void)?` - Callback for reactive updates

### View Model Methods

- `updateTitle(_:)` - Updates the displayed title
- `updateColors(textColor:backgroundColor:)` - Updates text and background colors
- `updateFont(_:)` - Updates the font

## Styling

### Default Theme

- **Text Color**: `StyleProvider.Color.textPrimary`
- **Background**: `StyleProvider.Color.backgroundSecondary`
- **Font**: `StyleProvider.fontWith(type: .semibold, size: 16)`
- **Corner Radius**: 8pt

### Customization

All styling properties can be customized through the view model. The component will automatically apply custom styles when provided, falling back to default theme values when not specified.

## Layout

The component uses Auto Layout with:
- **Horizontal padding**: 16pt on leading and trailing edges
- **Vertical padding**: 12pt on top and bottom edges
- **Text alignment**: Centered
- **Single line**: Text is limited to one line with truncation

## Integration

### Adding to View Hierarchy

```swift
// Add to parent view
parentView.addSubview(headerView)

// Set up constraints
NSLayoutConstraint.activate([
    headerView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 16),
    headerView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -16),
    headerView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 20),
    headerView.heightAnchor.constraint(equalToConstant: 44) // Recommended minimum height
])
```

### Reactive Updates

The component automatically updates when the view model calls `refreshData?()`. This enables reactive programming patterns where the view responds to data changes.

## Testing

Use `MockHeaderTextViewViewModel` for testing and SwiftUI previews. The mock implementation provides all protocol methods and allows easy configuration of different states.

## Examples

See the SwiftUI preview in the component file for visual examples of different styling configurations.
