# CustomSliderView

A customizable slider with configurable track, thumb, and step snapping behavior.

## Overview

CustomSliderView provides a flexible slider component with support for custom thumb images, configurable track appearance, step-based value snapping, and accessibility features. It supports both pan and tap gestures for value adjustment and provides callbacks for value changes and editing completion.

## Component Relationships

### Used By (Parents)
- None (standalone input component)

### Uses (Children)
- None (leaf component)

## Features

- Configurable minimum and maximum values
- Step-based value snapping
- Custom thumb image support (SF Symbols or asset images)
- Configurable thumb size and tint color
- Configurable track height and corner radius
- Pan gesture for continuous adjustment
- Tap gesture for direct value selection
- Enable/disable state with alpha dimming
- Haptic feedback support
- Shadow effect on thumb
- Accessibility support (adjustable trait)
- Reactive updates via Combine publisher

## Usage

```swift
let viewModel = MockCustomSliderViewModel.defaultMock
let sliderView = CustomSliderView(viewModel: viewModel)

sliderView.onValueChanged = { value in
    print("Value changed to: \(value)")
}

sliderView.onEditingEnded = { finalValue in
    print("Editing ended at: \(finalValue)")
}
```

## Data Model

```swift
struct SliderConfiguration: Equatable {
    let minimumValue: Float
    let maximumValue: Float
    let numberOfSteps: Int
    let trackHeight: CGFloat
    let trackCornerRadius: CGFloat
    let thumbSize: CGFloat
    let thumbImageName: String?
    let thumbTintColor: UIColor?
}

struct CustomSliderDisplayState: Equatable {
    let configuration: SliderConfiguration
    let currentValue: Float
    let isEnabled: Bool
}

protocol CustomSliderViewModelProtocol {
    var displayStatePublisher: AnyPublisher<CustomSliderDisplayState, Never> { get }

    func updateValue(_ value: Float)
    func snapToNearestStep()
    func setEnabled(_ enabled: Bool)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightSecondary` (30% alpha) - track background
- `StyleProvider.Color.highlightPrimary` - default thumb tint

Layout constants:
- Minimum touch area: 44pt
- Default track height: 4pt
- Default track corner radius: 2pt
- Default thumb size: 24pt
- Thumb shadow radius: 4pt
- Thumb shadow offset: (0, 2)
- Thumb shadow opacity: 0.2

## Mock ViewModels

Available presets:
- `.defaultMock` - standard slider (0-1, 5 steps, value 0.0)
- `.midPositionMock` - slider at 50% position
- `.timeFilterMock` - time filter slider (All, 1h, 8h, Today, 48h)
- `.disabledMock` - disabled slider at 30%
- `.customImageMock` - blue circle thumb at 25%
- `.volumeSliderMock` - volume slider (0-10, green speaker icon, value 7.0)
- `.customMock(configuration:initialValue:isEnabled:)` - custom configuration
