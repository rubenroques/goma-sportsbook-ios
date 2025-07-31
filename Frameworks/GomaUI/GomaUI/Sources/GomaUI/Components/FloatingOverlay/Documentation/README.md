# FloatingOverlay

A modern floating overlay component that displays contextual messages with smooth animations. Perfect for notifying users about their current context (Sportsbook, Casino, or custom states).

## Features

- **Multiple Modes**: Built-in Sportsbook and Casino modes, plus custom mode support
- **Content-Adaptive**: Automatically sizes to fit icon and message content
- **Smooth Animations**: Slide-up entrance with fade and scale effects
- **Flexible Dismissal**: Auto-dismiss with timer or tap to dismiss
- **Single Instance**: Ensures only one overlay is visible at a time
- **Customizable**: Support for custom icons and messages

## Usage Example

### Basic Usage

```swift
// Create a view model
let viewModel = MockFloatingOverlayViewModel.sportsbookMode

// Create the overlay
let overlay = FloatingOverlayView(viewModel: viewModel)

// Add to your view hierarchy
view.addSubview(overlay)

// Position it (parent is responsible for positioning)
overlay.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
    overlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    overlay.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
])

// Show the overlay with auto-dismiss after 3 seconds
viewModel.show(mode: .sportsbook, duration: 3.0)
```

### Custom Mode

```swift
let customIcon = UIImage(systemName: "star.fill") ?? UIImage()
viewModel.show(mode: .custom(icon: customIcon, message: "Welcome to VIP! ⭐"), duration: 5.0)
```

### Manual Dismissal

```swift
// Show without auto-dismiss
viewModel.show(mode: .casino, duration: nil)

// Hide manually
viewModel.hide()
```

### Handle Tap Events

```swift
overlay.onTap = {
    print("Overlay was tapped!")
    // Perform additional actions if needed
}
```

## Configuration Options

### Modes

1. **Sportsbook**: Shows soccer ball icon with "You're in Sportsbook 🔥"
2. **Casino**: Shows dice icon with "You're in Casino 🎲"
3. **Custom**: Provide your own icon and message

### Duration

- Pass a `TimeInterval` for auto-dismiss
- Pass `nil` for manual dismiss only
- Tapping always dismisses regardless of duration

## Positioning

The parent view/controller is responsible for positioning the overlay. Common patterns:

```swift
// Bottom center (most common)
NSLayoutConstraint.activate([
    overlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    overlay.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
])

// Top center
NSLayoutConstraint.activate([
    overlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    overlay.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
])

// Center of screen
NSLayoutConstraint.activate([
    overlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    overlay.centerYAnchor.constraint(equalTo: view.centerYAnchor)
])
```

## Animation Details

- **Show**: Slides up 50pts + fades in + scales from 0.95 to 1.0
- **Hide**: Slides down 50pts + fades out + scales from 1.0 to 0.95
- **Duration**: 0.4s show, 0.3s hide
- **Spring**: Damping 0.8 for natural bounce

## Best Practices

1. **Single Instance**: Only show one overlay at a time
2. **Context Awareness**: Use appropriate mode for current app section
3. **Duration**: 3-5 seconds is typically sufficient for auto-dismiss
4. **Positioning**: Keep consistent positioning across your app
5. **Accessibility**: The component includes proper accessibility support