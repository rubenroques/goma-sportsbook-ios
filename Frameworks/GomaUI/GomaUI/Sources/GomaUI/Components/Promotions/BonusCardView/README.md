# BonusCardView

A reusable card component for displaying bonus offers with call-to-action buttons and terms information.

## Overview

`BonusCardView` is a production-ready UI component that displays bonus promotions with rich content including an image, title, description, tag, CTA button, and terms text. It's similar to `PromotionCardView` but specifically designed for bonus offers that require terms and conditions display.

## Features

- **Image Display**: Shows a promotional image with optional tag overlay
- **Content Layout**: Title and description with multi-line support
- **CTA Button**: Always-visible call-to-action ButtonView with configurable text
- **Terms Button**: ButtonView for terms that is enabled/disabled based on URL availability
- **Optional Fields**: Tag, CTA URL, and terms URL are all optional
- **Reactive Updates**: Uses Combine publishers for state management
- **Themed Styling**: Uses StyleProvider for consistent theming

## Architecture

### Components

1. **BonusCardData**: Data model containing all card information
2. **BonusCardDisplayState**: Display state wrapper for reactive updates
3. **BonusCardViewModelProtocol**: Protocol defining the view model interface
4. **MockBonusCardViewModel**: Mock implementation for testing and demos
5. **BonusCardView**: Main UIView implementation

### Key Differences from PromotionCardView

- **Required CTA Text**: `ctaText` is always required (not optional)
- **Optional CTA URL**: `ctaURL` is optional
- **Terms Button Instead of Read More**: Uses a ButtonView for terms instead of a "Read More" button
- **Smart Terms Button**: Button is enabled only when `termsURL` is provided, disabled (non-interactive) when URL is nil

## Usage

### Basic Implementation

```swift
import GomaUI

// Create the data
let bonusData = BonusCardData(
    id: "bonus_1",
    title: "Welcome Bonus",
    description: "Get 100% match on your first deposit",
    imageURL: "https://example.com/image.jpg",
    tag: "Popular",
    ctaText: "Claim Bonus",
    ctaURL: "https://example.com/claim",
    termsText: "Terms & Conditions Apply",
    termsURL: "https://example.com/terms"
)

// Create the view model
let viewModel = MockBonusCardViewModel(cardData: bonusData)

// Create the view
let bonusCard = BonusCardView(viewModel: viewModel)

// Add to your view hierarchy
view.addSubview(bonusCard)
```

### Handling Actions

```swift
// Set up callbacks in your view model
viewModel.onCTATapped = { url in
    if let url = url {
        // Open the CTA URL
        print("Open CTA: \(url)")
    } else {
        // Handle CTA without URL
        print("CTA tapped without URL")
    }
}

viewModel.onTermsTapped = { url in
    if let url = url {
        // Open terms URL
        print("Open terms: \(url)")
    } else {
        // Terms text only (no URL)
        print("Terms has no URL")
    }
}

viewModel.onCardTapped = {
    // Handle card tap
    print("Card tapped")
}
```

### Using Factory Methods

```swift
// Default bonus with all features
let defaultCard = BonusCardView(
    viewModel: MockBonusCardViewModel.defaultMock
)

// Bonus without URLs
let noURLCard = BonusCardView(
    viewModel: MockBonusCardViewModel.noURLsMock
)

// Casino-specific bonus
let casinoCard = BonusCardView(
    viewModel: MockBonusCardViewModel.casinoBonusMock
)
```

## Data Model

### BonusCardData

```swift
public struct BonusCardData {
    public let id: String              // Unique identifier
    public let title: String           // Bonus title
    public let description: String     // Detailed description
    public let imageURL: String        // Image URL
    public let tag: String?            // Optional tag (e.g., "Popular", "VIP")
    public let ctaText: String         // CTA button text (required)
    public let ctaURL: String?         // Optional CTA destination URL
    public let termsText: String       // Terms text (required)
    public let termsURL: String?       // Optional terms URL
}
```

## Layout

```
┌─────────────────────────────┐
│   [Image with Tag]          │
├─────────────────────────────┤
│ Title                       │
│ Description text that can   │
│ span multiple lines         │
│                             │
│ [   Claim Bonus Button   ]  │
│ Terms & Conditions Apply    │ (underlined if URL exists)
└─────────────────────────────┘
```

## Customization

### Theming

The component uses `StyleProvider` for all visual properties:

- **Background Colors**: `backgroundCards`, `backgroundSecondary`
- **Border Colors**: `backgroundBorder`
- **Text Colors**: `textPrimary`, `textSecondary`, `allWhite`
- **Highlight Colors**: `highlightPrimary` (for tag background)
- **Fonts**: `bold` (16pt), `regular` (14pt), `semibold` (12pt)

### Size Constraints

- **Image Height**: Fixed at 131pt
- **Container**: Full width with 8pt corner radius
- **Padding**: 24pt horizontal, 16pt vertical
- **Spacing**: 8-16pt between elements

## Production Implementation

To use in production:

1. Implement `BonusCardViewModelProtocol` in your production view model
2. Connect to your data source and business logic
3. Implement proper error handling for image loading
4. Handle navigation/URL opening in callbacks
5. Add analytics tracking in action methods

```swift
class ProductionBonusCardViewModel: BonusCardViewModelProtocol {
    private let bonusService: BonusServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    
    func didTapCTAButton() {
        analyticsService.track(.bonusCTATapped)
        // Navigate or perform action
    }
    
    func didTapTerms() {
        analyticsService.track(.bonusTermsTapped)
        // Open terms sheet or web view
    }
}
```

## Mock Implementations

The component includes several mock variants:

- **defaultMock**: Full-featured bonus with all fields
- **noURLsMock**: Bonus without any URLs (text only)
- **casinoBonusMock**: Casino-specific bonus
- **sportsBonusMock**: Sports betting bonus
- **vipBonusMock**: VIP exclusive bonus
- **noTagMock**: Bonus without a tag

## Testing

Use the included mock view models for SwiftUI previews and testing:

```swift
@available(iOS 17.0, *)
#Preview("Default State") {
    PreviewUIViewController {
        let vc = UIViewController()
        let card = BonusCardView(
            viewModel: MockBonusCardViewModel.defaultMock
        )
        // Setup constraints
        return vc
    }
}
```

## Accessibility

The component supports:
- VoiceOver for all interactive elements
- Dynamic Type for text scaling
- High contrast mode through StyleProvider

## Requirements

- iOS 16.0+
- Swift 5.7+
- Kingfisher (for image loading)

## Related Components

- **PromotionCardView**: Similar card for general promotions with "Read More" button
- **ButtonView**: Used for both CTA and Terms buttons
- **StyleProvider**: Provides theming and styling

