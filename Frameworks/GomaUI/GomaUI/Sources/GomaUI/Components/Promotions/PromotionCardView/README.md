# PromotionCardView

A promotional content card with image, tag badge, title, description, and action buttons.

## Overview

PromotionCardView displays promotional content in a visually appealing card format with a header image, optional tag badge, title, description, and call-to-action buttons. It supports both CTA buttons and "Read More" links, making it suitable for marketing promotions, bonus offers, and featured content in casino and sportsbook applications.

## Component Relationships

### Used By (Parents)
- Promotion list screens
- Home screen promotional sections
- Offer pages

### Uses (Children)
- `ButtonView` - CTA and Read More buttons

## Features

- Header image with async loading (Kingfisher)
- Optional tag badge with rounded corners
- Title and description labels
- Primary CTA button
- Read More button
- Card tap gesture handler
- Rounded container with border
- Visibility control for buttons
- Reactive updates via Combine publishers

## Usage

```swift
let cardData = PromotionCardData(
    id: "promo_1",
    title: "Welcome Bonus",
    description: "Get 100% match on your first deposit",
    imageURL: "https://example.com/promo.jpg",
    tag: "Limited",
    ctaText: "Claim Now",
    ctaURL: "https://example.com/claim",
    showReadMoreButton: true
)
let viewModel = MockPromotionCardViewModel(cardData: cardData)
let cardView = PromotionCardView(viewModel: viewModel)

// Handle callbacks
viewModel.onCTATapped = { url in
    openURL(url)
}

viewModel.onReadMoreTapped = {
    showPromotionDetails()
}

viewModel.onCardTapped = {
    navigateToPromotion()
}

// Update card data
viewModel.configure(with: newCardData)
```

## Data Model

```swift
struct PromotionCardData: Equatable, Hashable {
    let id: String
    let title: String
    let description: String
    let imageURL: String
    let tag: String?
    let ctaText: String?
    let ctaURL: String?
    let showReadMoreButton: Bool
}

struct PromotionCardDisplayState: Equatable {
    let cardData: PromotionCardData
    let isVisible: Bool

    // Convenience accessors
    var id: String
    var title: String
    var description: String
    var imageURL: String
    var tag: String?
    var ctaText: String?
    var ctaURL: String?
    var showReadMoreButton: Bool
}

protocol PromotionCardViewModelProtocol {
    var displayStatePublisher: AnyPublisher<PromotionCardDisplayState, Never> { get }
    var ctaButtonViewModel: ButtonViewModelProtocol { get }
    var readMoreButtonViewModel: ButtonViewModelProtocol { get }

    func didTapCTAButton()
    func didTapReadMoreButton()
    func didTapCard()
    func configure(with cardData: PromotionCardData)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundCards` - container background
- `StyleProvider.Color.backgroundBorder` - container border
- `StyleProvider.Color.backgroundSecondary` - image placeholder background
- `StyleProvider.Color.highlightPrimary` - tag background, Read More text
- `StyleProvider.Color.allWhite` - tag text
- `StyleProvider.Color.textPrimary` - title, description text
- `StyleProvider.fontWith(type: .semibold, size: 12)` - tag font
- `StyleProvider.fontWith(type: .bold, size: 16)` - title font
- `StyleProvider.fontWith(type: .regular, size: 16)` - description font

Layout constants:
- Container corner radius: 8pt
- Container border width: 1pt
- Image height: 131pt
- Tag top offset: 15pt
- Tag height: 20pt
- Tag corner radius: 4pt (right corners only)
- Tag horizontal padding: 8pt
- Content horizontal padding: 24pt
- Title top margin: 16pt
- Title-description gap: 8pt
- Buttons top margin: 26pt
- Buttons bottom margin: 16pt
- Content stack spacing: 8pt

Tag corner masking:
- `.layerMaxXMinYCorner` (top-right)
- `.layerMaxXMaxYCorner` (bottom-right)

## Mock ViewModels

Available presets:
- `.defaultMock` - Welcome bonus with all features
- `.casinoMock` - Casino tournament promotion
- `.sportsbookMock` - Sports betting bonus (no Read More)
- `.noCTAMock` - Information only, no CTA button
- `.longTitleMock` - Long title for wrapping test
- `.noTagMock` - Promotion without tag badge
