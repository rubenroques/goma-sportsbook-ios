# SingleButtonBannerView

A customizable banner component with a full-width background image, message text, and an optional action button. Designed to be used in horizontal scroll views and implements the `TopBannerProtocol` for banner management.

## Features

- **Full-width background image** - Customizable background with aspect fill scaling
- **Customizable message text** - Multi-line support with configurable styling
- **Optional action button** - Highly customizable button with optional styling overrides
- **TopBanner protocol compliance** - Can be used in banner carousel/scroll views
- **Visibility control** - Can be shown/hidden dynamically
- **MVVM architecture** - Clean separation of concerns with reactive updates
- **StyleProvider integration** - Consistent styling with theme support

## Usage Example

```swift


// Create button configuration
let buttonConfig = ButtonConfig(
    title: "Get Started",
    backgroundColor: .systemBlue,
    textColor: .white,
    cornerRadius: 12
)

// Create banner data
let bannerData = SingleButtonBannerData(
    type: "welcome_banner",
    isVisible: true,
    backgroundImage: UIImage(named: "banner_background"),
    messageText: "Get 2X the action,\ndouble your first\ndeposit!",
    buttonConfig: buttonConfig
)

// Create view model (or use a mock for testing)
let viewModel = MockSingleButtonBannerViewModel(bannerData: bannerData)

// Create the banner view
let bannerView = SingleButtonBannerView(viewModel: viewModel)

// Add to your view hierarchy
parentView.addSubview(bannerView)
bannerView.translatesAutoresizingMaskIntoConstraints = false

// Set up constraints
NSLayoutConstraint.activate([
    bannerView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
    bannerView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
    bannerView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor),
    bannerView.heightAnchor.constraint(equalToConstant: 200)
])

// Handle button taps
bannerView.onButtonTapped = {
    print("Banner button tapped!")
    // Perform navigation or other actions
}
```

## Configuration Options

### SingleButtonBannerData

The main data model for configuring the banner:

```swift
let bannerData = SingleButtonBannerData(
    type: "unique_banner_id",           // Identifier for the banner type
    isVisible: true,                    // Whether the banner should be visible
    backgroundImage: myImage,           // Background image (optional)
    messageText: "Your message here",   // Main message text
    buttonConfig: buttonConfiguration   // Button configuration (optional)
)
```

### ButtonConfig

Configure the optional action button:

```swift
let buttonConfig = ButtonConfig(
    title: "Button Text",                      // Button title
    backgroundColor: UIColor.systemBlue,       // Custom background color (optional)
    textColor: UIColor.white,                  // Custom text color (optional)
    cornerRadius: 12.0                         // Custom corner radius (optional)
)
```

### TopBannerProtocol Compliance

The component implements `TopBannerProtocol` for use in banner carousels:

```swift
// Access banner properties
let bannerType = bannerData.type        // "welcome_banner"
let isVisible = bannerData.isVisible    // true/false
```

## Layout Behavior

- **Background Image**: Scales to fill the entire banner area using `scaleAspectFill`
- **Message Label**: Positioned in the top-left with multi-line support
- **Action Button**: Positioned in the bottom-left, automatically hidden if no `buttonConfig` is provided
- **Content Padding**: 20pt padding on all sides for content within the banner

## Mock View Models

Several mock implementations are provided for testing and previews:

### Available Mocks

```swift
// Default banner with gradient background and button
let defaultMock = MockSingleButtonBannerViewModel.defaultMock

// Banner without button (message only)
let noButtonMock = MockSingleButtonBannerViewModel.noButtonMock

// Banner with custom button styling
let customStyledMock = MockSingleButtonBannerViewModel.customStyledMock

// Banner with disabled button
let disabledMock = MockSingleButtonBannerViewModel.disabledMock

// Hidden banner
let hiddenMock = MockSingleButtonBannerViewModel.hiddenMock
```

### Creating Custom Mocks

```swift
let customBannerData = SingleButtonBannerData(
    type: "custom_banner",
    isVisible: true,
    backgroundImage: myCustomImage,
    messageText: "Custom message text",
    buttonConfig: myButtonConfig
)

let customMock = MockSingleButtonBannerViewModel(
    bannerData: customBannerData,
    isButtonEnabled: true
)
```

## Styling Customization

The component uses StyleProvider for consistent theming:

```swift
// The component will automatically use:
StyleProvider.Color.backgroundPrimary     // For fallback background
StyleProvider.Color.primaryTextColor    // For message text
StyleProvider.Color.highlightPrimary        // For default button background
StyleProvider.fontWith(type: .bold, size: 24)      // For message text
StyleProvider.fontWith(type: .medium, size: 16)    // For button text
```

Override button styling through `ButtonConfig` properties when needed.

## Integration with Horizontal Scroll Views

When using in banner carousels, the component's `TopBannerProtocol` compliance allows for easy management:

```swift
func displayBanner(_ bannerData: any TopBannerProtocol) {
    if bannerData.isVisible {
        // Add banner to scroll view based on type
        switch bannerData.type {
        case "welcome_banner":
            // Handle welcome banner
        case "promo_banner":
            // Handle promotional banner
        default:
            break
        }
    }
}
```

## Accessibility

The component includes built-in accessibility support:

- Message label is automatically accessible
- Button includes proper accessibility labels and hints
- VoiceOver navigation works seamlessly

## Requirements

- iOS 15.0+
- Swift 5.7+
- UIKit framework 
