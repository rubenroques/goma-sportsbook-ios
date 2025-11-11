# ButtonView Component

A highly customizable, protocol-driven button component that supports three distinct visual styles with comprehensive color and typography customization options.

## Overview

ButtonView is a production-ready UIKit component that follows GomaUI's MVVM architecture patterns. It provides complete customization capabilities while maintaining backward compatibility and falling back to StyleProvider defaults.

## Features

### ✨ Core Capabilities
- **Three Button Styles**: Solid background, bordered, and transparent
- **Complete Color Customization**: Background, border, and text colors
- **Typography Control**: Font size and weight customization  
- **State Management**: Enabled/disabled states with proper visual feedback
- **Haptic Feedback**: Built-in tactile response on button press
- **Reactive Updates**: Combine-based state management
- **SwiftUI Previews**: Live preview support for rapid development

### 🎨 Visual Styles

#### 1. Solid Background (`.solidBackground`)
- Filled button with custom or default background color
- Supports custom text color
- Automatic disabled state styling

#### 2. Bordered (`.bordered`) 
- Outlined button with 2pt border
- Custom border and text colors
- Intelligent color fallback (uses border color for text if no explicit text color)
- Clear background

#### 3. Transparent (`.transparent`)
- Text-only button with underline styling
- Custom text color support
- Maintains underline in both enabled/disabled states

## Usage

### Basic Implementation

```swift


// Create a view model (production or mock)
let viewModel = MockButtonViewModel.solidBackgroundMock

// Initialize the button view
let buttonView = ButtonView(viewModel: viewModel)

// Add to your view hierarchy
view.addSubview(buttonView)
```

### Custom Color Examples

```swift
// Custom solid background button
let customSolidData = ButtonData(
    id: "custom_button",
    title: "Custom Button",
    style: .solidBackground,
    backgroundColor: UIColor.systemRed,
    textColor: UIColor.white
)

// Custom bordered button
let customBorderedData = ButtonData(
    id: "bordered_button", 
    title: "Custom Border",
    style: .bordered,
    borderColor: UIColor.systemBlue,
    textColor: UIColor.systemBlue
)

// Custom transparent button
let customTransparentData = ButtonData(
    id: "transparent_button",
    title: "Custom Link",
    style: .transparent,
    textColor: UIColor.systemPurple
)
```

### Font Customization Examples

```swift
// Large bold button
let largeFontData = ButtonData(
    id: "large_button",
    title: "Large Button",
    style: .solidBackground,
    fontSize: 24.0,
    fontType: .bold
)

// Small medium weight button
let smallFontData = ButtonData(
    id: "small_button", 
    title: "Small Button",
    style: .bordered,
    fontSize: 12.0,
    fontType: .medium
)

// Light weight button
let lightFontData = ButtonData(
    id: "light_button",
    title: "Light Button", 
    style: .solidBackground,
    fontSize: 18.0,
    fontType: .light
)
```

### Complete Customization Example

```swift
let fullyCustomData = ButtonData(
    id: "fully_custom",
    title: "Fully Custom",
    style: .solidBackground,
    backgroundColor: UIColor.systemGreen,
    textColor: UIColor.black,
    fontSize: 20.0,
    fontType: .semibold,
    isEnabled: true
)

let viewModel = MockButtonViewModel(buttonData: fullyCustomData)
let buttonView = ButtonView(viewModel: viewModel)
```

## ButtonData Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `id` | `String` | Unique identifier for the button | Required |
| `title` | `String` | Button text content | Required |
| `style` | `ButtonStyle` | Visual style (.solidBackground, .bordered, .transparent) | Required |
| `backgroundColor` | `UIColor?` | Custom background color (solid style only) | `StyleProvider.Color.buttonBackgroundPrimary` |
| `disabledBackgroundColor` | `UIColor?` | Custom disabled background color | `StyleProvider.Color.buttonDisablePrimary` |
| `borderColor` | `UIColor?` | Custom border color (bordered style) | `StyleProvider.Color.highlightPrimary` |
| `textColor` | `UIColor?` | Custom text color (all styles) | Style-specific StyleProvider color |
| `fontSize` | `CGFloat?` | Custom font size | `16.0` |
| `fontType` | `StyleProvider.FontType?` | Font weight (.thin, .light, .regular, .medium, .semibold, .bold, .heavy) | `.bold` |
| `isEnabled` | `Bool` | Button enabled state | `true` |

## Available Font Types

ButtonView supports all StyleProvider font types:

- `.thin` - Ultra-light weight
- `.light` - Light weight  
- `.regular` - Normal weight
- `.medium` - Medium weight
- `.semibold` - Semi-bold weight
- `.bold` - Bold weight (default)
- `.heavy` - Heavy/black weight

## Mock Examples

### Basic Styles
```swift
MockButtonViewModel.solidBackgroundMock
MockButtonViewModel.borderedMock  
MockButtonViewModel.transparentMock
```

### Color Customization
```swift
MockButtonViewModel.solidBackgroundCustomColorMock    // Red background, white text
MockButtonViewModel.borderedCustomColorMock           // Blue border and text
MockButtonViewModel.transparentCustomColorMock        // Purple text
MockButtonViewModel.redThemeMock                      // Red themed button
MockButtonViewModel.blueThemeMock                     // Blue themed button
MockButtonViewModel.greenThemeMock                    // Green themed button
MockButtonViewModel.orangeThemeMock                   // Orange themed button
```

### Font Customization  
```swift
MockButtonViewModel.largeFontMock                     // 24pt Bold
MockButtonViewModel.smallFontMock                     // 12pt Medium
MockButtonViewModel.lightFontMock                     // 18pt Light
MockButtonViewModel.heavyFontMock                     // 20pt Heavy
MockButtonViewModel.customFontStyleMock               // 16pt Semibold
```

## SwiftUI Previews

The component includes comprehensive SwiftUI previews:

- **"All Button States"** - Basic styles and disabled states
- **"Custom Color Examples"** - Color customization showcase
- **"Color Themes Comparison"** - Side-by-side theme comparison
- **"Font Customization Examples"** - Typography variations
- **"Font Weight Comparison"** - Font weight showcase

## Architecture

### MVVM Pattern
- **ButtonView**: UIView implementation
- **ButtonViewModelProtocol**: Reactive interface
- **MockButtonViewModel**: Comprehensive test implementation

### Protocol-Driven Design
```swift
protocol ButtonViewModelProtocol {
    var buttonDataPublisher: AnyPublisher<ButtonData, Never> { get }
    func buttonTapped()
    func setEnabled(_ isEnabled: Bool)
    func updateTitle(_ title: String)
    var onButtonTapped: (() -> Void)? { get set }
}
```

### Reactive Updates
ButtonView uses Combine for reactive state management:
```swift
viewModel.buttonDataPublisher
    .receive(on: DispatchQueue.main)
    .sink { [weak self] buttonData in
        self?.configure(buttonData: buttonData)
    }
    .store(in: &cancellables)
```

## Color Fallback Strategy

1. **Custom Colors First**: Uses provided custom colors when available
2. **StyleProvider Fallback**: Falls back to StyleProvider colors for consistency
3. **Intelligent Defaults**: Bordered buttons use border color for text when no explicit text color provided
4. **Disabled State Preservation**: Disabled states always use StyleProvider colors

## Best Practices

### ✅ Do
- Use mock implementations for testing and previews
- Leverage StyleProvider for consistent theming
- Provide meaningful button IDs for analytics
- Test different font sizes for accessibility
- Use appropriate button styles for context

### ❌ Don't  
- Hardcode colors - always use custom properties or StyleProvider
- Create buttons without proper enabled/disabled states
- Ignore font size accessibility considerations
- Mix button styles inconsistently within the same interface

## Testing

The component includes extensive testing support:

### Demo App Testing
Run `GomaUIDemo` target to see all button variations:
- 6 basic style examples
- 7 color customization examples  
- 5 font customization examples
- 18 total interactive examples

### SwiftUI Preview Testing
Use Xcode previews for rapid iteration:
- Individual component testing
- Color theme comparisons
- Font weight showcases
- State variation testing

## Integration

### Adding to GomaUIDemo
```swift
// Add to ButtonViewController
("Your Custom Button", MockButtonViewModel.yourCustomMock)
```

### Creating Custom Mocks
```swift
public static var yourCustomMock: MockButtonViewModel {
    let buttonData = ButtonData(
        id: "your_custom_id",
        title: "Your Title",
        style: .solidBackground,
        backgroundColor: UIColor.systemTeal,
        textColor: UIColor.white,
        fontSize: 18.0,
        fontType: .semibold,
        isEnabled: true
    )
    return MockButtonViewModel(buttonData: buttonData)
}
```

## Files Structure

```
ButtonView/
├── ButtonView.swift                     # Main UIView implementation
├── ButtonViewModelProtocol.swift        # Protocol + ButtonData model
├── MockButtonViewModel.swift            # Mock implementation with examples
└── README.md                           # This documentation
```

## Dependencies

- **UIKit**: Core UI framework
- **Combine**: Reactive programming  
- **StyleProvider**: GomaUI theming system
- **SwiftUI**: Preview support

## Backward Compatibility

All new customization properties are optional with sensible defaults, ensuring complete backward compatibility with existing implementations. Existing code continues to work without modification while gaining access to new customization capabilities.
