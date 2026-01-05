# PromotionalBonusCardsScrollView

A horizontal scrolling carousel of promotional bonus cards.

## Overview

PromotionalBonusCardsScrollView displays multiple PromotionalBonusCardView components in a horizontally scrolling container. Each card takes up 85% of the screen width, allowing users to peek at the next card and encouraging horizontal scrolling. The component manages card creation, callbacks, and cleanup automatically.

## Component Relationships

### Used By (Parents)
- Home screens
- Bonus listing pages

### Uses (Children)
- `PromotionalBonusCardView`

## Features

- Horizontal scrolling carousel
- Fast deceleration for card-like snapping
- 85% screen width cards (peek at next)
- Multiple card support
- Per-card claim and terms callbacks
- Dynamic card creation from data
- Card spacing (16pt)
- Content insets (16pt horizontal)
- Reactive updates via Combine publishers

## Usage

```swift
let cardsData = PromotionalBonusCardsData(
    id: "promo_carousel",
    cards: [card1, card2, card3, card4]
)
let viewModel = MockPromotionalBonusCardsScrollViewModel(cardsData: cardsData)
let scrollView = PromotionalBonusCardsScrollView(viewModel: viewModel)

// Handle card actions
scrollView.onCardClaimBonus = { cardData in
    processBonus(cardData)
}

scrollView.onCardTermsTapped = { cardData in
    showTerms(for: cardData)
}
```

## Data Model

```swift
struct PromotionalBonusCardsData: Equatable {
    let id: String
    let cards: [PromotionalBonusCardData]
}

protocol PromotionalBonusCardsScrollViewModelProtocol {
    var cardsDataPublisher: AnyPublisher<PromotionalBonusCardsData, Never> { get }

    func cardClaimBonusTapped(cardId: String)
    func cardTermsTapped(cardId: String)
}
```

## Styling

StyleProvider properties used:
- Background: clear (inherits from parent)

Layout constants:
- Card width: 85% of screen width
- Card spacing: 16pt
- Content insets: 16pt leading/trailing
- Scroll indicators: hidden
- Deceleration rate: fast

Scroll behavior:
- No paging (continuous scroll)
- Fast deceleration for card-like feel
- Horizontal scroll only

## Mock ViewModels

Available presets:
- `.defaultMock` - 4 cards (Betsson Double, Welcome Bonus, Weekend Special, VIP Bonus)
- `.shortListMock` - 2 cards (Quick Start, Daily Special)
