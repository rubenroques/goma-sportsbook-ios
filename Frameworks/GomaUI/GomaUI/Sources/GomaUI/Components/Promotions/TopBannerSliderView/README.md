# TopBannerSliderView

A horizontally pageable banner slider displaying promotional and match banners with page indicators.

## Overview

TopBannerSliderView displays a horizontally scrolling collection of banner cards using paging behavior. It supports multiple banner types including promotional info banners (SingleButtonBannerView) and match highlight banners (MatchBannerView). The component includes a page control indicator in the top-right corner and supports tap-to-page navigation. It is used for home page hero promotions and featured content carousels.

## Component Relationships

### Used By (Parents)
- Home page screens
- Promotional sections
- Featured content areas

### Uses (Children)
- `SingleButtonBannerView` (via SingleButtonBannerViewCell)
- `MatchBannerView` (via MatchBannerViewCell)

## Features

- Horizontal paging UICollectionView
- Multiple banner type support (info, casino, match)
- Page control indicator with tap-to-select
- Banner tap callbacks
- Page change callbacks
- Visibility and interaction control
- Optimized reload (only when banners change)
- Configurable page indicator visibility
- Synchronous state access for UITableView sizing
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockTopBannerSliderViewModel.defaultMock
let bannerSlider = TopBannerSliderView(viewModel: viewModel)

// Handle banner taps
bannerSlider.onBannerTapped = { index in
    navigateToBanner(at: index)
}

// Handle page changes
bannerSlider.onPageChanged = { index in
    trackPageView(index)
}

// Scroll to specific page
bannerSlider.scrollToPage(2, animated: true)

// Reconfigure with new ViewModel
bannerSlider.configure(with: newViewModel)

// Clear content
bannerSlider.clearContent()
```

## Data Model

```swift
enum BannerType: Equatable {
    case info(SingleButtonBannerViewModelProtocol)
    case casino(SingleButtonBannerViewModelProtocol)
    case match(MatchBannerViewModelProtocol)
}

struct TopBannerSliderData: Equatable {
    let banners: [BannerType]
    let showPageIndicators: Bool
    let currentPageIndex: Int
}

struct TopBannerSliderDisplayState: Equatable {
    let sliderData: TopBannerSliderData
    let isVisible: Bool
    let isUserInteractionEnabled: Bool
}

protocol TopBannerSliderViewModelProtocol {
    var currentDisplayState: TopBannerSliderDisplayState { get }
    var displayStatePublisher: AnyPublisher<TopBannerSliderDisplayState, Never> { get }

    func didScrollToPage(_ pageIndex: Int)
    func bannerTapped(at index: Int)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundPrimary` - container background
- `StyleProvider.Color.highlightPrimary` - active page indicator
- `StyleProvider.Color.highlightPrimary.withAlphaComponent(0.3)` - inactive indicators

Layout constants:
- Banner height: 140pt (static constant)
- Collection view flow layout: horizontal, no spacing
- Page control top margin: 9pt
- Page control trailing margin: 11pt
- Collection view: full size of container

Page control:
- Position: top-right
- Hidden for single page
- Tap-to-navigate support

## Mock ViewModels

Available presets:
- `.defaultMock` - 3 info banners with page indicators
- `.singleBannerMock` - Single info banner (no visible indicators)
- `.noIndicatorsMock` - 2 banners without page indicators
- `.disabledInteractionMock` - Disabled interaction state
- `.mixedBannersMock` - Mix of info and match banners
- `.matchOnlyMock` - Only match banners

Methods:
- `didScrollToPage(_:)` - Handle page scroll
- `bannerTapped(at:)` - Handle banner tap
- `updateSliderData(_:)` - Update banner data
- `updateVisibility(_:)` - Toggle visibility
- `updateUserInteraction(_:)` - Toggle interaction
