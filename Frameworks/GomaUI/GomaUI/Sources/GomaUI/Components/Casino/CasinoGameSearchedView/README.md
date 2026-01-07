# CasinoGameSearchedView

A compact search result row for casino games with thumbnail, title, provider, and play icon.

## Overview

CasinoGameSearchedView displays a horizontal row for casino game search results. It shows a square game image on the left, game title and provider in the center, and a play icon on the right. The component handles image loading states and provides tap interaction for game selection.

## Component Relationships

### Used By (Parents)
- None (standalone component for search result lists)

### Uses (Children)
- None (leaf component)

## Features

- Fixed 56pt row height
- Square 56pt game image with rounded corners
- Image loading with activity indicator
- Image failure state with "?" placeholder
- Game title (semibold 18pt, single line)
- Provider name (regular 14pt, optional)
- Play/chevron icon on right side
- 16pt corner radius on container
- Secondary background color
- Tap gesture for game selection
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockCasinoGameSearchedViewModel.normal
let searchedView = CasinoGameSearchedView(viewModel: viewModel)

searchedView.onGameSelected = {
    print("Game selected")
}
```

## Data Model

```swift
struct CasinoGameSearchedData: Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let provider: String?
    let iconURL: String?
}

struct CasinoGameSearchedDisplayState: Equatable {
    let isLoading: Bool
    let imageLoadingFailed: Bool
}

protocol CasinoGameSearchedViewModelProtocol: AnyObject {
    var dataPublisher: AnyPublisher<CasinoGameSearchedData, Never> { get }
    var displayStatePublisher: AnyPublisher<CasinoGameSearchedDisplayState, Never> { get }
    var onSelected: AnyPublisher<String, Never> { get }

    func didSelect()
    func imageLoadingSucceeded()
    func imageLoadingFailed()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundSecondary` - container background
- `StyleProvider.Color.backgroundPrimary` - image failure background
- `StyleProvider.Color.textPrimary` - title text color
- `StyleProvider.Color.textSecondary` - provider text and failure "?" color
- `StyleProvider.Color.highlightPrimary` - play icon tint
- `StyleProvider.fontWith(type: .semibold, size: 18)` - title font
- `StyleProvider.fontWith(type: .regular, size: 14)` - provider font
- `StyleProvider.fontWith(type: .bold, size: 18)` - failure label font

Layout constants:
- Row height: 56pt
- Image size: 56pt
- Container corner radius: 16pt
- Icon size: 16pt
- Horizontal padding: 16pt
- Vertical spacing: 4pt

## Mock ViewModels

Available presets:
- `.loading` - loading state
- `.normal` - normal state with image
- `.imageError` - image loading failed state
