# TopBannerSliderView

A horizontal collection view container that displays multiple TopBannerProtocol-compliant banner views with page indicators, auto-scroll functionality, and smooth transitions. Perfect for promotional content, announcements, and featured information.

## Features

- **Horizontal scrolling** - Smooth paging between banner items
- **Page indicators** - Dots in the top-right corner showing current position
- **Auto-scroll support** - Optional automatic progression through banners
- **Full-width banners** - Each banner takes the full width and height of the container
- **TopBannerProtocol compliance** - Works with any UIView that implements TopBannerViewProtocol
- **Visibility management** - Automatically filters out non-visible banners
- **MVVM architecture** - Clean separation with reactive updates
- **Factory pattern** - Lazy loading of banner views for performance

## Usage Example

```swift
import GomaUI

// Create banner view factories
let bannerFactories = [
    BannerViewFactory(id: "welcome_banner") {
        let viewModel = MockSingleButtonBannerViewModel.defaultMock
        return SingleButtonBannerView(viewModel: viewModel)
    },
    BannerViewFactory(id: "promo_banner") {
        let viewModel = MockSingleButtonBannerViewModel.customStyledMock
        return SingleButtonBannerView(viewModel: viewModel)
    },
    BannerViewFactory(id: "info_banner") {
        let viewModel = MockSingleButtonBannerViewModel.noButtonMock
        return SingleButtonBannerView(viewModel: viewModel)
    }
]

// Create slider data
let sliderData = TopBannerSliderData(
    bannerViewFactories: bannerFactories,
    isAutoScrollEnabled: true,
    autoScrollInterval: 5.0,
    showPageIndicators: true,
    currentPageIndex: 0
)

// Create view model
let viewModel = MockTopBannerSliderViewModel(sliderData: sliderData)

// Create the slider view
let sliderView = TopBannerSliderView(viewModel: viewModel)

// Add to your view hierarchy
parentView.addSubview(sliderView)
sliderView.translatesAutoresizingMaskIntoConstraints = false

// Set up constraints
NSLayoutConstraint.activate([
    sliderView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
    sliderView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
    sliderView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor),
    sliderView.heightAnchor.constraint(equalToConstant: 200)
])

// Handle events
sliderView.onBannerTapped = { index in
    print("Banner at index \(index) was tapped")
    // Handle banner tap
}

sliderView.onPageChanged = { pageIndex in
    print("Scrolled to page \(pageIndex)")
    // Handle page change
}
```

## Configuration Options

### TopBannerSliderData

The main data model for configuring the slider:

```swift
let sliderData = TopBannerSliderData(
    bannerViewFactories: bannerFactories,    // Array of banner view factories
    isAutoScrollEnabled: true,               // Enable automatic scrolling
    autoScrollInterval: 5.0,                 // Seconds between auto-scroll
    showPageIndicators: true,                // Show dots in top-right
    currentPageIndex: 0                      // Starting page index
)
```

### BannerViewFactory

Factory pattern for creating banner views:

```swift
let factory = BannerViewFactory(id: "unique_banner_id") {
    // Return any UIView that conforms to TopBannerViewProtocol
    let viewModel = YourBannerViewModel()
    return YourBannerView(viewModel: viewModel)
}
```

### TopBannerViewProtocol

Protocol that banner views must implement:

```swift
public protocol TopBannerViewProtocol: UIView, TopBannerProtocol {
    func bannerDidBecomeVisible()    // Called when banner becomes visible
    func bannerDidBecomeHidden()     // Called when banner becomes hidden
}
```

## Layout Behavior

- **Full-width banners**: Each banner occupies the full width and height of the slider
- **Page indicators**: Positioned in the top-right corner with 16pt margins
- **Horizontal scrolling**: Paging enabled for smooth transitions
- **Auto-scroll**: Automatically advances to the next banner when enabled
- **Visibility filtering**: Only visible banners (isVisible = true) are displayed

## Auto-Scroll Features

### Enabling Auto-Scroll

```swift
let sliderData = TopBannerSliderData(
    bannerViewFactories: factories,
    isAutoScrollEnabled: true,
    autoScrollInterval: 3.0,  // 3 seconds between transitions
    showPageIndicators: true,
    currentPageIndex: 0
)
```

### Controlling Auto-Scroll

```swift
// Start auto-scroll programmatically
sliderView.startAutoScroll()

// Stop auto-scroll
sliderView.stopAutoScroll()

// Auto-scroll automatically stops when user interacts with the slider
// and resumes after a brief pause
```

## Page Indicators

The page indicators (dots) appear in the top-right corner and:

- Show the current position among all banners
- Are automatically hidden for single banners
- Use StyleProvider colors for consistency
- Can be disabled via `showPageIndicators: false`
- Are tappable to jump to specific pages

## Mock View Models

Several mock implementations are provided for testing and previews:

### Available Mocks

```swift
// Default slider with multiple banners
let defaultMock = MockTopBannerSliderViewModel.defaultMock

// Single banner (no page indicators shown)
let singleBannerMock = MockTopBannerSliderViewModel.singleBannerMock

// Auto-scrolling slider
let autoScrollMock = MockTopBannerSliderViewModel.autoScrollMock

// Slider without page indicators
let noIndicatorsMock = MockTopBannerSliderViewModel.noIndicatorsMock

// Slider with disabled user interaction
let disabledMock = MockTopBannerSliderViewModel.disabledInteractionMock
```

### Creating Custom Mocks

```swift
let customFactories = [
    BannerViewFactory(id: "custom_1") {
        // Your custom banner view
        return CustomBannerView()
    },
    BannerViewFactory(id: "custom_2") {
        // Another custom banner view
        return AnotherCustomBannerView()
    }
]

let customSliderData = TopBannerSliderData(
    bannerViewFactories: customFactories,
    isAutoScrollEnabled: false,
    autoScrollInterval: 4.0,
    showPageIndicators: true,
    currentPageIndex: 0
)

let customMock = MockTopBannerSliderViewModel(sliderData: customSliderData)
```

## Performance Considerations

- **Factory pattern**: Banner views are created lazily when needed
- **Visibility filtering**: Non-visible banners are excluded from the collection view
- **Memory management**: Banner views are properly cleaned up when scrolled out of view
- **Auto-scroll optimization**: Timer is automatically managed and cleaned up

## Integration with Other Banner Types

The slider works with any UIView that implements TopBannerViewProtocol:

```swift
// Example with different banner types
let mixedFactories = [
    BannerViewFactory(id: "single_button") {
        SingleButtonBannerView(viewModel: singleButtonViewModel)
    },
    BannerViewFactory(id: "image_only") {
        ImageOnlyBannerView(viewModel: imageViewModel)
    },
    BannerViewFactory(id: "video_banner") {
        VideoBannerView(viewModel: videoViewModel)
    }
]
```

## Styling Customization

The component uses StyleProvider for consistent theming:

```swift
// Page indicators use:
StyleProvider.Color.primaryColor                    // For current page indicator
StyleProvider.Color.primaryColor.withAlphaComponent(0.3)  // For inactive indicators

// Background uses:
StyleProvider.Color.backgroundColor                 // For slider background
```

## Accessibility

The component includes built-in accessibility support:

- Page control is accessible with proper labels
- Banner views maintain their individual accessibility
- VoiceOver navigation works seamlessly
- Page indicators announce current position

## Requirements

- iOS 15.0+
- Swift 5.7+
- UIKit framework
- Banner views must conform to TopBannerViewProtocol 