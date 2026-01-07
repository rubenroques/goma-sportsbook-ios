# EmptyStateActionView

An empty state display with image, title, and optional action button.

## Overview

EmptyStateActionView displays a centered empty state layout with an optional image, descriptive title text, and a configurable action button. The component supports logged-in vs logged-out states, automatically showing or hiding the action button based on the current state. It's commonly used for empty betslips, search results, or list states.

## Component Relationships

### Used By (Parents)
- None (standalone empty state component)

### Uses (Children)
- None (leaf component)

## Features

- Centered image (200x80pt, system or asset image)
- Multi-line title text
- Action button (visible only in logged-out state)
- Logged-in/logged-out state handling
- Enable/disable state with alpha dimming
- Secondary background color
- 16pt padding
- Reactive updates via Combine publisher

## Usage

```swift
let viewModel = MockEmptyStateActionViewModel.loggedOutMock()
let emptyStateView = EmptyStateActionView(viewModel: viewModel)

viewModel.onActionButtonTapped = {
    print("Navigate to login")
}
```

## Data Model

```swift
enum EmptyStateActionState: Equatable {
    case loggedOut
    case loggedIn
}

struct EmptyStateActionData: Equatable {
    let state: EmptyStateActionState
    let title: String
    let actionButtonTitle: String
    let image: String?
    let isEnabled: Bool
}

protocol EmptyStateActionViewModelProtocol {
    var dataPublisher: AnyPublisher<EmptyStateActionData, Never> { get }
    var currentData: EmptyStateActionData { get }

    func updateState(_ state: EmptyStateActionState)
    func updateTitle(_ title: String)
    func updateActionButtonTitle(_ title: String)
    func updateImage(_ image: String?)
    func setEnabled(_ isEnabled: Bool)

    var onActionButtonTapped: (() -> Void)? { get set }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundSecondary` - container background
- `StyleProvider.Color.textPrimary` - title text color
- `StyleProvider.Color.highlightPrimary` - image tint
- `StyleProvider.Color.highlightSecondary` - button background
- `StyleProvider.Color.buttonTextPrimary` - button text color
- `StyleProvider.fontWith(type: .regular, size: 14)` - title font
- `StyleProvider.fontWith(type: .bold, size: 14)` - button font

Layout constants:
- Image size: 200x80pt
- Button height: 48pt
- Button corner radius: 4pt
- Stack spacing: 16pt
- Content padding: 16pt

## Mock ViewModels

Available presets:
- `.loggedOutMock()` - logged out with "Log in to bet" button, ticket image
- `.loggedInMock()` - logged in (button hidden), ticket image
- `.disabledMock()` - disabled state with 50% alpha
