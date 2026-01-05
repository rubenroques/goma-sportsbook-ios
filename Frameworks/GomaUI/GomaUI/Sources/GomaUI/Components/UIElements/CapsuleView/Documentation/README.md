# CapsuleView

A versatile UIKit component that creates perfectly rounded capsule/pill-shaped containers with automatic shape management and customizable styling.

## Overview

`CapsuleView` is designed for displaying badges, status indicators, count labels, and other pill-shaped UI elements. It automatically maintains a perfect capsule shape regardless of content size and provides extensive customization options.

## Key Features

- **Perfect Capsule Shape**: Automatically calculates corner radius as half the view height
- **Automatic Layout**: Self-managing shape that updates when content changes
- **Flexible Content**: Supports text with customizable fonts, colors, and padding
- **Themeable**: Uses StyleProvider for consistent design system integration
- **Performance**: Efficient layout updates only when bounds change
- **Stack View Friendly**: Works seamlessly in UIStackView and Auto Layout

## Visual Examples

### Live Badge
Green capsule with "LIVE" text for match status indicators

### Count Badge
Orange capsule with numbers for notification counts or item quantities

### Status Badge
Customizable capsules for various status states

## Usage

### Basic Usage
```swift
// Create view model
let viewModel = MockCapsuleViewModel.liveBadge
let capsuleView = CapsuleView(viewModel: viewModel)

// Add to your view hierarchy
stackView.addArrangedSubview(capsuleView)
```

### Custom Configuration
```swift
let customData = CapsuleData(
    text: "Custom Badge",
    backgroundColor: .systemBlue,
    textColor: .white,
    font: StyleProvider.fontWith(type: .bold, size: 12),
    horizontalPadding: 16.0,
    verticalPadding: 6.0
)
let viewModel = MockCapsuleViewModel(data: customData)
let capsuleView = CapsuleView(viewModel: viewModel)
```

### Dynamic Updates
```swift
// Update text dynamically
let newData = CapsuleData(
    text: "Updated",
    backgroundColor: capsuleView.viewModel.data.backgroundColor,
    textColor: capsuleView.viewModel.data.textColor
)
capsuleView.viewModel.configure(with: newData)
```

## Customization Options

### CapsuleData Properties

- **text**: The text to display (optional)
- **backgroundColor**: Capsule background color
- **textColor**: Text color
- **font**: Text font
- **horizontalPadding**: Left/right padding around text
- **verticalPadding**: Top/bottom padding around text
- **minimumHeight**: Optional minimum height constraint

### Default Values
- Horizontal padding: 12pt
- Vertical padding: 4pt
- Uses StyleProvider colors and fonts for consistency

## Pre-built Configurations

The component includes several factory methods for common use cases:

### Live Badge
```swift
MockCapsuleViewModel.liveBadge
// Green background, white text, "LIVE"
```

### Count Badge
```swift
MockCapsuleViewModel.countBadge
// Orange background, white text, "16"
```

### Status Badge
```swift
MockCapsuleViewModel.statusBadge
// Blue background, white text, "Active"
```

### Warning Badge
```swift
MockCapsuleViewModel.warningBadge
// Yellow background, dark text, "Warning"
```

### Notification Badge
```swift
MockCapsuleViewModel.notificationBadge
// Red background, white text, "3"
```

## Implementation Details

### Automatic Shape Management
The view uses a self-contained approach where the shape is managed in `layoutSubviews`:

```swift
override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = bounds.height / 2
    layer.masksToBounds = true
}
```

### Constraint-Based Layout
The view uses Auto Layout with proper content hugging and compression resistance:
- Text label with configurable padding
- Minimum height constraints when specified
- Intrinsic content sizing

### Performance Considerations
- Shape updates only when bounds actually change
- Efficient text measurement and layout
- No unnecessary constraint activation/deactivation

## Design System Integration

The component integrates with GomaUI's design system:

```swift
// Uses StyleProvider colors
backgroundColor: StyleProvider.Color.highlightSecondary
textColor: StyleProvider.Color.buttonTextPrimary

// Uses StyleProvider fonts
font: StyleProvider.fontWith(type: .bold, size: 10)
```

## Common Use Cases

1. **Live Match Indicators**: "LIVE", "1st Half, 41mins"
2. **Notification Badges**: Count indicators on tabs or buttons
3. **Status Labels**: "Active", "Pending", "Completed"
4. **Category Tags**: Pill-shaped category labels
5. **Action Badges**: "New", "Updated", "Hot"

## SwiftUI Previews

The component includes comprehensive SwiftUI previews showing:
- Different badge types and configurations
- Various text lengths and styles
- Color combinations and themes
- Sizing variations

## Best Practices

1. **Consistent Styling**: Use factory methods or StyleProvider for consistency
2. **Appropriate Sizing**: Consider minimum touch targets for interactive elements
3. **Color Contrast**: Ensure sufficient contrast between background and text
4. **Content Length**: Keep text concise for optimal pill shape
5. **Accessibility**: Provide appropriate accessibility labels when needed

## Related Components

- **PillItemView**: For interactive pill-shaped buttons
- **StatusNotificationView**: For larger status displays
- **MarketNamePillLabelView**: For specific betting market labels

## Testing

Use the Demo app to test different configurations and see live examples of all badge types and customization options.