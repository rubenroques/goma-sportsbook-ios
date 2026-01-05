# PromotionalBonusCardView

A promotional bonus card with background image, gradient overlay, user avatars, and action buttons.

## Overview

PromotionalBonusCardView displays a large promotional card for bonus offers with a customizable background image, gradient overlay, header text, main title, user avatar indicators showing how many players have claimed the bonus, and two action buttons (Claim Bonus and Terms & Conditions). It's used on home screens and promotion pages to highlight available bonuses.

## Component Relationships

### Used By (Parents)
- `PromotionalBonusCardsScrollView`

### Uses (Children)
- `ButtonView` - Claim and Terms buttons
- `GradientView` - Background gradient overlay

## Features

- Background image with async loading
- Gradient overlay (diagonal, 70% alpha)
- Header text label
- Main title label (multi-line)
- User avatars stack with overlap effect
- Players count label (e.g., "12.6k players chose this bonus")
- Claim Bonus button (solid style)
- Terms & Conditions button (transparent style)
- Fixed card height (415pt)
- Rounded corners (16pt)
- Button tap callbacks
- Reactive updates via Combine publishers

## Usage

```swift
let cardData = PromotionalBonusCardData(
    id: "welcome_bonus",
    headerText: "The Betsson Double",
    mainTitle: "Deposit XAF 1000 and play with XAF 2000",
    userAvatars: [
        UserAvatar(id: "user1", imageName: "avatar1"),
        UserAvatar(id: "user2", imageName: "avatar2")
    ],
    playersCount: "12.6k",
    backgroundImageName: "promo_background",
    bonusAmount: 1000
)
let viewModel = MockPromotionalBonusCardViewModel(cardData: cardData)
let cardView = PromotionalBonusCardView(viewModel: viewModel)

// Handle button taps
cardView.onClaimBonus = {
    processBonus()
}

cardView.onTermsTapped = {
    showTermsAndConditions()
}
```

## Data Model

```swift
struct UserAvatar: Equatable, Hashable {
    let id: String
    let imageUrl: String?
    let imageName: String?
}

struct PromotionalBonusCardData: Equatable, Hashable {
    let id: String
    let headerText: String
    let mainTitle: String
    let userAvatars: [UserAvatar]
    let playersCount: String
    let backgroundImageName: String?
    let hasGradientView: Bool
    let claimButtonTitle: String
    let termsButtonTitle: String
    let bonusAmount: Double
}

protocol PromotionalBonusCardViewModelProtocol {
    var cardDataPublisher: AnyPublisher<PromotionalBonusCardData, Never> { get }

    func claimBonusTapped()
    func termsTapped()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.topBarGradient1/2/3` - gradient overlay colors
- `StyleProvider.Color.buttonTextPrimary` - header, title, players label text
- `StyleProvider.Color.backgroundSecondary` - avatar placeholder background
- `StyleProvider.Color.textSecondary` - avatar placeholder icon tint
- `StyleProvider.fontWith(type: .regular, size: 12)` - header, players label font
- `StyleProvider.fontWith(type: .bold, size: 20)` - title font

Layout constants:
- Card height: 415pt
- Corner radius: 16pt
- Container padding: 16pt horizontal, 24pt top, 20pt bottom
- Header-title gap: 20pt
- Title-avatars gap: 20pt
- Avatar size: 40pt x 40pt
- Avatar corner radius: 20pt
- Avatar overlap: -8pt spacing
- Avatar border: 2pt white
- Avatars-count gap: 12pt
- Button stack spacing: 6pt

Gradient configuration:
- Direction: Inverted diagonal
- Colors: topBarGradient1 (33%), topBarGradient2 (66%), topBarGradient3 (100%)
- Alpha: 0.7

Avatar display:
- Maximum 4 avatars displayed
- Overlapping stack effect
- System person icon placeholder

## Mock ViewModels

Available presets:
- `.defaultMock` - "The Betsson Double" with 4 avatars, 12.6k players
- `.noGradientMock` - Same content without gradient overlay
