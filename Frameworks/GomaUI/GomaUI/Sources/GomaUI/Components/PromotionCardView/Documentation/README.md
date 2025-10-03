# PromotionCardView

A comprehensive promotion card component designed for displaying promotional content with image, tag, title, description, call-to-action button, and read more functionality.

## Overview

The `PromotionCardView` is a versatile component that displays promotional information in a card format. It's perfect for promotion listings, marketing campaigns, and promotional content display across the application.

## Features

- **Image Display**: Shows promotional images with proper aspect ratio and loading
- **Tag Support**: Optional tag overlay on the image (e.g., "Limited", "Casino", "Sportsbook")
- **Rich Content**: Title and description with proper text wrapping
- **Interactive Elements**: Call-to-action button and read more link
- **Flexible Layout**: Adapts to different content lengths and screen sizes
- **Theme Support**: Fully integrated with StyleProvider for consistent theming

## Visual Structure

```
┌─────────────────────────────────────┐
│  [IMAGE AREA - 131px height]        │
│  ┌─────────┐                        │
│  │   TAG   │                        │
│  └─────────┘                        │
├─────────────────────────────────────┤
│  Title of the promotion             │
│                                     │
│  Description text that can wrap     │
│  to multiple lines as needed...     │
│                                     │
│  ┌─────────────────────────────────┐ │
│  │         CTA BUTTON              │ │
│  └─────────────────────────────────┘ │
│                                     │
│            Read more                │
└─────────────────────────────────────┘
```

## Usage

### Basic Implementation

```swift
// Create view model with promotion data
let viewModel = MockPromotionCardViewModel.defaultMock

// Initialize the view
let cardView = PromotionCardView(viewModel: viewModel)

// Add to view hierarchy
view.addSubview(cardView)
```

### With Custom Data

```swift
// Create custom promotion data
let promotionData = PromotionCardData(
    id: "promo_123",
    title: "Welcome Bonus",
    description: "Get a 100% match bonus up to $500 on your first deposit.",
    imageURL: "https://example.com/promo-image.jpg",
    tag: "Limited",
    ctaText: "Claim Bonus",
    ctaURL: "https://example.com/claim",
    showReadMoreButton: true
)

// Create view model
let viewModel = MockPromotionCardViewModel(cardData: promotionData)

// Initialize view
let cardView = PromotionCardView(viewModel: viewModel)
```

### In Table View Cell

The `PromotionTableViewCell` in `BetssonCameroonApp` shows how to integrate the component:

```swift
class PromotionTableViewCell: UITableViewCell {
    private var promotionCardView: PromotionCardView?
    
    func configure(viewModel: PromotionCellViewModel) {
        // Convert PromotionInfo to PromotionCardData
        let cardData = PromotionCardData(
            id: String(viewModel.promotionInfo.id),
            title: viewModel.promotionInfo.title,
            description: viewModel.promotionInfo.listDisplayDescription ?? "",
            imageURL: viewModel.promotionInfo.listDisplayImageUrl,
            tag: viewModel.promotionInfo.tag,
            ctaText: viewModel.promotionInfo.ctaText,
            ctaURL: viewModel.promotionInfo.ctaUrl,
            showReadMoreButton: viewModel.promotionInfo.hasReadMoreButton
        )
        
        // Create ViewModel with callback setup
        let cardViewModel = MockPromotionCardViewModel(cardData: cardData)
        
        // Setup callbacks for button actions
        if let ctaButtonViewModel = cardViewModel.ctaButtonViewModel as? MockButtonViewModel {
            ctaButtonViewModel.onButtonTapped = { [weak self] in
                self?.didTapPromotionAction?()
            }
        }
        
        // Create and configure the card view
        let cardView = PromotionCardView(viewModel: cardViewModel)
        // ... setup constraints and add to view hierarchy
    }
}
```

## Data Models

### PromotionCardData

```swift
public struct PromotionCardData: Equatable, Hashable {
    public let id: String
    public let title: String
    public let description: String
    public let imageURL: String
    public let tag: String?
    public let ctaText: String?
    public let ctaURL: String?
    public let showReadMoreButton: Bool
}
```

### PromotionCardDisplayState

```swift
public struct PromotionCardDisplayState: Equatable {
    public let cardData: PromotionCardData
    public let isVisible: Bool
}
```

## Protocols

### PromotionCardViewModelProtocol

```swift
public protocol PromotionCardViewModelProtocol {
    var displayStatePublisher: AnyPublisher<PromotionCardDisplayState, Never> { get }
    
    /// Button ViewModels for CTA and Read More buttons
    var ctaButtonViewModel: ButtonViewModelProtocol { get }
    var readMoreButtonViewModel: ButtonViewModelProtocol { get }
    
    func didTapCTAButton()
    func didTapReadMoreButton()
    func configure(with cardData: PromotionCardData)
}
```

## Mock Implementations

The component includes several mock implementations for testing and development:

- `MockPromotionCardViewModel.defaultMock` - Standard promotion card
- `MockPromotionCardViewModel.casinoMock` - Casino-themed promotion
- `MockPromotionCardViewModel.sportsbookMock` - Sports betting promotion
- `MockPromotionCardViewModel.noCTAMock` - Information-only promotion
- `MockPromotionCardViewModel.longTitleMock` - Long title test case
- `MockPromotionCardViewModel.noTagMock` - Promotion without tag

## Architecture

### MVVM with ButtonView Integration

The component follows GomaUI's MVVM pattern with proper ButtonView integration:

- **PromotionCardView**: Main UIView component
- **PromotionCardViewModelProtocol**: Defines the interface with ButtonView ViewModels
- **MockPromotionCardViewModel**: Creates and manages ButtonView ViewModels internally
- **ButtonView Integration**: Both CTA and Read More buttons use ButtonView with their own ViewModels

### ButtonView ViewModels

The component creates two ButtonView ViewModels:

1. **CTA Button**: `ButtonStyle.solidBackground` for primary actions
2. **Read More Button**: `ButtonStyle.transparent` for secondary actions

Both buttons are fully integrated with the PromotionCardViewModel's callback system.

## Styling

The component uses StyleProvider for all styling:

- **Colors**: `StyleProvider.Color.backgroundColor`, `StyleProvider.Color.primaryColor`, etc.
- **Fonts**: `StyleProvider.fontWith(type:size:)`
- **Layout**: Programmatic AutoLayout with consistent spacing

## Layout Specifications

- **Card Height**: Dynamic based on content (minimum ~300pt)
- **Image Area**: 40% of total card height
- **Content Area**: 60% of total card height
- **Margins**: 16pt horizontal, 8-20pt vertical
- **Tag**: 24pt height, 60pt minimum width
- **CTA Button**: 44pt height (ButtonView with solidBackground style)
- **Read More Button**: Auto height (ButtonView with transparent style)

## Accessibility

- Supports VoiceOver navigation
- Proper accessibility labels for interactive elements
- High contrast support through StyleProvider
- Dynamic Type support for text elements

## Integration with PromotionInfo

The component is designed to work seamlessly with the `PromotionInfo` model from the ServicesProvider:

```swift
extension PromotionInfo {
    func toPromotionCardData() -> PromotionCardData {
        return PromotionCardData(
            id: String(self.id),
            title: self.title,
            description: self.listDisplayDescription ?? "",
            imageURL: self.listDisplayImageUrl,
            tag: self.tag,
            ctaText: self.ctaText,
            ctaURL: self.ctaUrl,
            showReadMoreButton: self.hasReadMoreButton
        )
    }
}
```

## Best Practices

1. **Always use the ViewModel pattern** - Never bypass the protocol interface
2. **Handle image loading gracefully** - The component uses Kingfisher for async image loading
3. **Test with different content lengths** - Use the provided mock implementations
4. **Respect the card aspect ratio** - Allow the component to determine its own height
5. **Use consistent spacing** - Follow the 16pt margin pattern in your layouts

## Dependencies

- **UIKit**: Core UI framework
- **Combine**: Reactive programming for state management
- **Kingfisher**: Async image loading and caching
- **GomaUI**: StyleProvider for theming

## Testing

Use the demo app to test different states:
1. Navigate to "Promotional" category
2. Select "Promotion Card"
3. Test different mock implementations
4. Verify interactions and layout behavior

The component includes comprehensive SwiftUI previews for development and testing.
