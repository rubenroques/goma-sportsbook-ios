# SeeMoreButtonView

A reusable button component for "Load More" functionality with loading states.

## Overview

SeeMoreButtonView displays a button for loading additional content with support for loading states, remaining count display, and multiple visual styles. The button shows a loading indicator when fetching data and can display a count of remaining items (e.g., "Load 15 more games"). It supports solid background and bordered styles with proper enabled/disabled states.

## Component Relationships

### Used By (Parents)
- Casino category sections
- Game lists
- Content grids

### Uses (Children)
- None (leaf component)

## Features

- Loading state with activity indicator
- Remaining count display ("Load X more games")
- Two visual styles: solidBackground, bordered
- Enabled/disabled states with visual feedback
- Accessibility support
- Button tap callback
- Cell reuse support via configure method
- Reactive updates via Combine publishers

## Usage

```swift
// Default load more button
let viewModel = MockSeeMoreButtonViewModel.defaultMock
let button = SeeMoreButtonView(viewModel: viewModel)

// Button with remaining count
let countViewModel = MockSeeMoreButtonViewModel.withCountMock
let countButton = SeeMoreButtonView(viewModel: countViewModel)

// Handle button tap
button.onButtonTapped = {
    loadMoreGames()
}

// Set loading state
viewModel.setLoading(true)

// Update remaining count
viewModel.updateRemainingCount(15)

// Configure for cell reuse
button.configure(with: newViewModel)
```

## Data Model

```swift
enum SeeMoreButtonStyle {
    case solidBackground
    case bordered
}

struct SeeMoreButtonData: Equatable, Hashable {
    let id: String
    let title: String
    let remainingCount: Int?
    let style: SeeMoreButtonStyle
}

struct SeeMoreButtonDisplayState: Equatable {
    let isLoading: Bool
    let isEnabled: Bool
    let buttonData: SeeMoreButtonData

    static func normal(buttonData:) -> SeeMoreButtonDisplayState
    static func loading(buttonData:) -> SeeMoreButtonDisplayState
    static func disabled(buttonData:) -> SeeMoreButtonDisplayState
}

protocol SeeMoreButtonViewModelProtocol: AnyObject {
    var displayStatePublisher: AnyPublisher<SeeMoreButtonDisplayState, Never> { get }

    func setLoading(_ loading: Bool)
    func setEnabled(_ enabled: Bool)
    func updateRemainingCount(_ count: Int?)
    func buttonTapped()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightPrimary` - solid background button color
- `StyleProvider.Color.buttonTextPrimary` - solid background text/indicator color
- `StyleProvider.Color.buttonDisablePrimary` - disabled background color
- `StyleProvider.Color.buttonTextDisablePrimary` - disabled text color
- `StyleProvider.Color.buttonBorderTertiary` - bordered style border/text color
- `StyleProvider.fontWith(type: .medium, size: 13)` - button title font

Layout constants:
- Button height: 44pt (standard iOS touch target)
- Corner radius: 8pt
- Horizontal padding: 16pt
- Border width (bordered style): 2pt

Disabled state:
- Alpha: 0.6
- Uses disabled color palette

## Mock ViewModels

Available presets:
- `.defaultMock` - Basic "Load More Games" button
- `.loadingMock` - Button in loading state
- `.withCountMock` - Button showing 25 remaining items
- `.disabledMock` - Disabled button state
- `.interactiveMock` - Interactive demo with count decrement
- `.errorStateMock` - "Retry Loading" button
- `.categoryMock(categoryId:remainingCount:)` - Category-specific button

Methods:
- `setLoading(_ loading:)` - Toggle loading state
- `setEnabled(_ enabled:)` - Toggle enabled state
- `updateRemainingCount(_ count:)` - Update displayed count
