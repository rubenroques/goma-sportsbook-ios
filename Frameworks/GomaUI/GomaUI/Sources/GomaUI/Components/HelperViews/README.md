# HelperViews (GradientView)

A versatile gradient background view supporting multiple gradient directions and animations.

## Overview

GradientView provides customizable gradient backgrounds with support for horizontal, vertical, diagonal, and radial gradient directions. It includes animation capabilities for dynamic visual effects and is used as a building block for other components requiring gradient backgrounds.

## Component Relationships

### Used By (Parents)
- `GradientHeaderView` - gradient backgrounds
- `ExtendedListFooterView` - internal backgrounds
- Various promotional components

### Uses (Children)
- None (leaf component using CAGradientLayer)

## Features

- Multiple gradient directions:
  - Horizontal (left to right)
  - Inverted horizontal (right to left)
  - Vertical (top to bottom)
  - Inverted vertical (bottom to top)
  - Diagonal (bottom-left to top-right)
  - Inverted diagonal (top-left to bottom-right)
  - Radial (center to edges)
- Customizable color stops with location values
- Configurable corner radius
- Gradient animation support (auto-reversing)
- Factory method for quick creation
- Start/stop animation control
- Dynamic bounds handling

## Usage

```swift
// Create with factory method
let gradient = GradientView.customGradient(colors: [
    (UIColor.systemBlue, 0.0),
    (UIColor.systemCyan, 1.0)
], gradientDirection: .horizontal)
gradient.cornerRadius = 8

// Manual configuration
let gradientView = GradientView()
gradientView.colors = [
    (color: UIColor.orange, location: 0.0 as NSNumber),
    (color: UIColor.red, location: 1.0 as NSNumber)
]
gradientView.setDiagonalGradient()
gradientView.cornerRadius = 12

// With animation
gradientView.startAnimation()
// Later...
gradientView.stopAnimation()
```

## Data Model

```swift
enum GradientDirection {
    case horizontal
    case invertedHorizontal
    case vertical
    case invertedVertical
    case diagonal
    case invertedDiagonal
    case radial
}
```

## Public Properties

- `colors: [(color: UIColor, location: NSNumber)]` - gradient color stops
- `startPoint: CGPoint` - gradient start point (0.0-1.0)
- `endPoint: CGPoint` - gradient end point (0.0-1.0)
- `cornerRadius: CGFloat` - corner radius for rounded appearance

## Public Methods

Direction setters:
- `setHorizontalGradient()` - left to right
- `setInvertedHorizontalGradient()` - right to left
- `setVerticalGradient()` - top to bottom
- `setInvertedVerticalGradient()` - bottom to top
- `setDiagonalGradient()` - bottom-left to top-right
- `setInvertedDiagonalGradient()` - top-left to bottom-right
- `setRadialGradient()` - center outward

Animation:
- `startAnimation()` - start gradient animation
- `stopAnimation()` - stop gradient animation

Factory:
- `static func customGradient(colors:gradientDirection:) -> GradientView`

## Styling

Default values:
- Default colors: orange with 80% alpha gradient
- Default direction: diagonal (top-left to bottom-right)
- Default corner radius: 0
- Animation duration: 2s with auto-reverse (4s total cycle)
- Animation repeat: infinite

## Mock ViewModels

No ViewModel - GradientView is configured directly via properties.
