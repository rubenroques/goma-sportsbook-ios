# FloatingOverlayView

A floating notification overlay with icon and message for mode switching feedback.

## Overview

FloatingOverlayView displays a pill-shaped floating notification that animates in/out to provide feedback when switching between app modes (Sportsbook/Casino). It includes an icon on the left and a message, with support for auto-dismiss timers and tap-to-dismiss interaction.

## Component Relationships

### Used By (Parents)
- None (standalone overlay component, added to view hierarchy)

### Uses (Children)
- None (leaf component)

## Features

- Pill-shaped container with shadow
- Icon and message horizontal layout
- Spring animation for show (0.4s)
- Ease-in animation for hide (0.3s)
- Scale and translation transform during animation
- Auto-dismiss timer support
- Tap-to-dismiss interaction
- Tertiary background color
- 16pt corner radius
- Shadow effect (offset 0,4, radius 8, opacity 0.2)
- Reactive updates via Combine publisher

## Usage

```swift
let viewModel = MockFloatingOverlayViewModel.sportsbookMode
let overlayView = FloatingOverlayView(viewModel: viewModel)

// Add to view hierarchy
view.addSubview(overlayView)

// Show the overlay
viewModel.show(mode: .sportsbook, duration: 3.0)

overlayView.onTap = {
    print("Overlay tapped")
}
```

## Data Model

```swift
enum FloatingOverlayMode: Equatable {
    case sportsbook    // Soccer icon, "You're in Sportsbook"
    case casino        // Dice icon, "You're in Casino"
    case custom(icon: UIImage, message: String)
}

struct FloatingOverlayDisplayState: Equatable {
    let mode: FloatingOverlayMode
    let duration: TimeInterval?
    let isVisible: Bool
}

protocol FloatingOverlayViewModelProtocol {
    var displayStatePublisher: AnyPublisher<FloatingOverlayDisplayState, Never> { get }

    func show(mode: FloatingOverlayMode, duration: TimeInterval?)
    func hide()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundTertiary` - container background
- `StyleProvider.Color.highlightPrimary` - icon tint, default container background (95% alpha)
- `StyleProvider.Color.textPrimary` - message text color
- `StyleProvider.fontWith(type: .medium, size: 16)` - message font

Layout constants:
- Container corner radius: 16pt
- Icon size: 24pt
- Stack spacing: 8pt
- Vertical padding: 12pt
- Horizontal padding: 16pt
- Shadow offset: (0, 4)
- Shadow radius: 8pt
- Shadow opacity: 0.2

## Mock ViewModels

Available presets:
- `.sportsbookMode` - sportsbook mode with 3s auto-dismiss
- `.casinoMode` - casino mode without auto-dismiss
- `.customMode` - custom star icon with "Welcome to VIP Lounge" message
- `.alwaysVisible` - sportsbook mode, always visible (for previews)
