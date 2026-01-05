# TimeSliderView

A time filter slider with labeled time options for filtering events by time period.

## Overview

TimeSliderView provides a horizontal slider with discrete time option labels (e.g., "All", "1h", "8h", "Today", "48h") positioned below the track. Users can drag the slider to select a time filter, and the selected label is highlighted. The component is used for filtering sports events, matches, or other time-based content.

## Component Relationships

### Used By (Parents)
- Filter screens
- Event listing headers
- Sports filtering panels

### Uses (Children)
- None (leaf component)

## Features

- Horizontal slider with discrete stops
- Custom time option labels positioned below track
- Selected label highlighting in accent color
- Custom slider thumb image support
- Fallback circular thumb generation
- Header with icon and title
- Dynamic label positioning based on slider width
- Reactive updates via Combine publishers

## Usage

```swift
let timeOptions = [
    TimeOption(title: "All", value: 0),
    TimeOption(title: "1h", value: 1),
    TimeOption(title: "8h", value: 2),
    TimeOption(title: "Today", value: 3),
    TimeOption(title: "48h", value: 4)
]
let viewModel = MockTimeSliderViewModel(
    title: "Filter by Time",
    timeOptions: timeOptions,
    selectedValue: 0
)
let timeSlider = TimeSliderView(viewModel: viewModel)

// Handle value changes
timeSlider.onSliderValueChange = { value in
    filterEvents(byTimeIndex: Int(value))
}

// Fewer options
let shortOptions = [
    TimeOption(title: "Now", value: 0),
    TimeOption(title: "Soon", value: 1),
    TimeOption(title: "Later", value: 2)
]
let shortSlider = TimeSliderView(
    viewModel: MockTimeSliderViewModel(
        title: "Match Time",
        timeOptions: shortOptions,
        selectedValue: 1
    )
)
```

## Data Model

```swift
struct TimeOption {
    let title: String
    let value: Float
}

protocol TimeSliderViewModelProtocol {
    var title: String { get }
    var timeOptions: [TimeOption] { get }
    var selectedTimeValue: CurrentValueSubject<Float, Never> { get }

    func didChangeValue(_ value: Float)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundTertiary` - container background
- `StyleProvider.Color.highlightPrimary` - slider track, selected label, icon tint
- `StyleProvider.Color.textPrimary` - title, unselected labels
- `StyleProvider.fontWith(type: .bold, size: 12)` - title font
- `StyleProvider.fontWith(type: .regular, size: 12)` - option label font

Layout constants:
- Container corner radius: 8pt
- Header top padding: 16pt
- Header leading padding: 16pt
- Icon size: 16pt
- Header to slider spacing: 16pt
- Slider horizontal padding: 16pt
- Label to slider spacing: 6pt
- Label bottom padding: 12pt
- Track inset: 16pt

Slider customization:
- Minimum track: highlightPrimary
- Maximum track: systemGray5
- Thumb: custom image "slider_handle_icon" or generated circular

Icons:
- Header: "filterPerHour" from bundle

## Mock ViewModels

Factory initialization:
```swift
MockTimeSliderViewModel(
    title: String,
    timeOptions: [TimeOption],
    selectedValue: Float = 0
)
```

Common configurations:
- 5 options: "All", "1h", "8h", "Today", "48h"
- 3 options: "Now", "Soon", "Later"

Methods:
- `didChangeValue(_:)` - Handle slider value changes (rounds to nearest integer)
