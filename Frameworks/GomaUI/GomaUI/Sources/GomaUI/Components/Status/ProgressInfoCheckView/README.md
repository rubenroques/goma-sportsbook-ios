# ProgressInfoCheckView

A card component displaying progress information with icon, title, subtitle, and segmented progress bar.

## Overview

ProgressInfoCheckView shows progress-related information in a card format with an icon, header text, title, subtitle, and a segmented progress bar. It's commonly used to display gamification features like win boosts or achievement progress, showing users how close they are to unlocking rewards.

## Component Relationships

### Used By (Parents)
- Betslip screens
- Bonus progress displays
- Achievement trackers

### Uses (Children)
- None (leaf component)

## Features

- Header label with highlight color
- Icon display (SF Symbols or custom images)
- Title and subtitle labels
- Segmented progress bar (filled/empty segments)
- Complete and incomplete states
- Enabled/disabled states (alpha 0.5 when disabled)
- Rounded card container
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockProgressInfoCheckViewModel.winBoostMock()
let progressView = ProgressInfoCheckView(viewModel: viewModel)

// Update progress state
viewModel.updateState(.incomplete(completedSegments: 2, totalSegments: 3))

// Show complete state
viewModel.updateState(.complete)

// Update text content
viewModel.updateHeaderText("Almost there!")
viewModel.updateTitle("Get a 5% Win Boost")
viewModel.updateSubtitle("Add 1 more selection")

// Disable the component
viewModel.setEnabled(false)
```

## Data Model

```swift
enum ProgressInfoCheckState: Equatable {
    case incomplete(completedSegments: Int, totalSegments: Int)
    case complete
}

struct ProgressInfoCheckData: Equatable {
    let state: ProgressInfoCheckState
    let headerText: String
    let title: String
    let subtitle: String
    let icon: String?
    let isEnabled: Bool
}

protocol ProgressInfoCheckViewModelProtocol {
    var dataPublisher: AnyPublisher<ProgressInfoCheckData, Never> { get }
    var currentData: ProgressInfoCheckData { get }

    func updateState(_ state: ProgressInfoCheckState)
    func updateHeaderText(_ text: String)
    func updateTitle(_ title: String)
    func updateSubtitle(_ subtitle: String)
    func updateIcon(_ icon: String?)
    func setEnabled(_ isEnabled: Bool)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundSecondary` - container background
- `StyleProvider.Color.highlightPrimary` - header label, icon tint
- `StyleProvider.Color.highlightSecondary` - completed segment fill
- `StyleProvider.Color.backgroundPrimary` - empty segment fill
- `StyleProvider.Color.textPrimary` - title, subtitle text
- `StyleProvider.fontWith(type: .bold, size: 12)` - header font
- `StyleProvider.fontWith(type: .bold, size: 16)` - title font
- `StyleProvider.fontWith(type: .regular, size: 12)` - subtitle font

Layout constants:
- Container corner radius: 8pt
- Container padding: 16pt vertical, 12pt horizontal
- Main stack spacing: 16pt
- Content stack spacing: 12pt
- Text stack spacing: 4pt
- Icon size: 24pt x 24pt
- Progress segment height: 8pt
- Progress segment corner radius: 4pt
- Progress segment spacing: 4pt

Progress bar:
- Segments fill equally within container width
- Completed segments use highlight secondary color
- Empty segments use background primary color
- Default 3 segments for complete state

## Mock ViewModels

Available presets:
- `.winBoostMock()` - 1/3 segments complete, "Get a 3% Win Boost"
- `.completeMock()` - All segments complete, "Win Boost Activated"
- `.disabledMock()` - 0/3 segments, disabled state
