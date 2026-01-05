# MatchHeaderView

A compact match header with favorites button, sport icon, country flag, competition name, match time, and live indicator.

## Overview

MatchHeaderView displays a single-line match header commonly used in match cards and lists. It shows a favorites star button, sport type icon, country flag (circular), competition name, optional match time, and a pill-shaped live indicator. The component uses a pluggable image resolver for loading sport and country icons, and supports individual visibility control for each element.

## Component Relationships

### Used By (Parents)
- `TallOddsMatchCardView` - match card header
- Match list cells
- Match detail headers

### Uses (Children)
- None (leaf component)

## Features

- Favorites star button with toggle action
- Sport type icon with template rendering
- Circular country flag with border
- Competition name label (truncates for long names)
- Match time label (right-aligned)
- Pill-shaped live indicator ("LIVE" + play icon)
- Pluggable image resolver for icons
- Individual element visibility control
- 40pt touch target for favorites button
- 17pt fixed height
- Configure method for cell reuse
- Cleanup method for proper cell recycling
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockMatchHeaderViewModel.premierLeagueHeader
let imageResolver = DefaultMatchHeaderImageResolver()
let headerView = MatchHeaderView(viewModel: viewModel, imageResolver: imageResolver)

// Toggle favorite callback
viewModel.favoriteToggleCallback = { isFavorite in
    updateFavoriteStatus(isFavorite)
}

// Update individual properties
viewModel.updateMatchTime("45 Min")
viewModel.updateIsLive(true)

// Control visibility
viewModel.setCountryFlagVisible(false)
viewModel.setSportIconVisible(false)
viewModel.setFavoriteButtonVisible(false)

// For cell reuse
headerView.cleanupForReuse()
headerView.configure(with: newViewModel)
```

## Data Model

```swift
struct MatchHeaderData: Equatable, Hashable {
    let id: String
    let competitionName: String
    let countryFlagImageName: String?
    let sportIconImageName: String?
    let isFavorite: Bool
    let matchTime: String?
    let isLive: Bool
}

protocol MatchHeaderImageResolver {
    func countryFlagImage(for countryCode: String) -> UIImage?
    func sportIconImage(for sportId: String) -> UIImage?
    func favoriteIcon(isFavorite: Bool) -> UIImage?
    func liveIndicatorIcon() -> UIImage?
}

protocol MatchHeaderViewModelProtocol {
    // Content publishers
    var competitionNamePublisher: AnyPublisher<String, Never> { get }
    var countryFlagImageNamePublisher: AnyPublisher<String?, Never> { get }
    var sportIconImageNamePublisher: AnyPublisher<String?, Never> { get }
    var isFavoritePublisher: AnyPublisher<Bool, Never> { get }
    var matchTimePublisher: AnyPublisher<String?, Never> { get }
    var isLivePublisher: AnyPublisher<Bool, Never> { get }

    // Visibility publishers
    var isCountryFlagVisiblePublisher: AnyPublisher<Bool, Never> { get }
    var isSportIconVisiblePublisher: AnyPublisher<Bool, Never> { get }
    var isFavoriteButtonVisiblePublisher: AnyPublisher<Bool, Never> { get }

    // Actions
    func toggleFavorite()
    func updateCompetitionName(_ name: String)
    func updateCountryFlag(_ imageName: String?)
    func updateSportIcon(_ imageName: String?)
    func updateMatchTime(_ time: String?)
    func updateIsLive(_ isLive: Bool)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightPrimary` - competition name, sport icon tint, live indicator background
- `StyleProvider.Color.highlightTertiary` - match time text color
- `StyleProvider.Color.favorites` - star icon tint
- `StyleProvider.Color.textSecondary` - fallback icon tint
- `StyleProvider.fontWith(type: .medium, size: 11)` - competition name font
- `StyleProvider.fontWith(type: .bold, size: 10)` - match time font
- `StyleProvider.fontWith(type: .semibold, size: 10)` - live indicator font

Layout constants:
- View height: 17pt
- Icon spacing: 8pt (main), 4pt (left stack), 6pt (right stack)
- Icon size: 17pt x 17pt
- Favorites button touch area: 40pt x 40pt
- Country flag border: 0.5pt (dark gray)
- Live indicator height: 17pt
- Live indicator padding: 6pt horizontal, 3pt vertical
- Play icon size: 8pt x 8pt

Content priorities:
- Competition name: Lower hugging (249), lower compression (749)
- Match time: Higher hugging (251), higher compression (751)

## Mock ViewModels

Available presets:
- `.defaultMock` - Basic "League" header
- `.premierLeagueHeader` - Premier League, GB flag, football icon
- `.laLigaFavoriteHeader` - La Liga, ES flag, favorited, live (1st Half 44 Min)
- `.serieABasketballHeader` - Serie A Basketball, IT flag, basketball icon
- `.disabledNBAHeader` - NBA, US flag, favorited
- `.minimalModeHeader` - Champions League, EU flag
- `.favoriteOnlyHeader` - ATP Tennis, FR flag, favorited
- `.longNameHeader` - "UEFA Europa Conference League Championship"
- `.basicHeader` - No country flag or sport icon
- `.noCountryFlagHeader` - Country flag hidden
- `.noSportIconHeader` - Sport icon hidden
- `.noFavoriteButtonHeader` - Favorite button hidden
- `.minimalVisibilityHeader` - All icons hidden
