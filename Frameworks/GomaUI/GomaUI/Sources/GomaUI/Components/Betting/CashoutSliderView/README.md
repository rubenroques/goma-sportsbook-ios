# CashoutSliderView

A slider component for selecting partial cashout amounts with integrated action button.

## Overview

CashoutSliderView provides an interactive slider for users to select a cashout amount between minimum and maximum values. It displays the current range, updates the cashout button title dynamically as the slider moves, and includes a built-in ButtonView for executing the cashout action.

## Component Relationships

### Used By (Parents)
- `TicketBetInfoView` - partial cashout interface within bet tickets

### Uses (Children)
- `ButtonView` - cashout action button

## Features

- Interactive UISlider with customizable range
- Dynamic min/max value labels
- Real-time button title updates reflecting selected amount
- Custom thumb image (circle icon)
- Highlight primary color for slider track and thumb
- 12pt container corner radius
- Enable/disable state support
- Reactive updates via Combine publisher

## Usage

```swift
let viewModel = MockCashoutSliderViewModel.defaultMock()
let sliderView = CashoutSliderView(viewModel: viewModel)

viewModel.onCashoutTap = {
    print("Cashout requested")
}
```

## Data Model

```swift
struct CashoutSliderData: Equatable {
    let title: String
    let minimumValue: Float
    let maximumValue: Float
    let currentValue: Float
    let currency: String
    let isEnabled: Bool
}

protocol CashoutSliderViewModelProtocol {
    var dataPublisher: AnyPublisher<CashoutSliderData, Never> { get }
    var buttonViewModel: ButtonViewModelProtocol { get }

    func updateSliderValue(_ value: Float)
    func handleCashoutTap()
    func setEnabled(_ isEnabled: Bool)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundPrimary` - container background
- `StyleProvider.Color.highlightPrimary` - slider minimum track and thumb
- `StyleProvider.Color.backgroundSecondary` - slider maximum track
- `StyleProvider.Color.textPrimary` - title and value labels
- `StyleProvider.fontWith(type: .regular, size: 12)` - title font
- `StyleProvider.fontWith(type: .regular, size: 14)` - value labels font

## Mock ViewModels

Available presets:
- `.defaultMock()` - XAF 0.1 to 200, current at 200
- `.maximumMock()` - slider at maximum value
- `.minimumMock()` - slider at minimum value
- `.customMock(title:minimumValue:maximumValue:currentValue:currency:)` - custom configuration
