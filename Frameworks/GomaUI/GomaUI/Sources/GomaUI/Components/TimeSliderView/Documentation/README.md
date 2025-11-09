# TimeSliderView

A customizable time slider component for iOS that allows users to select from predefined time options using a slider interface.

![TimeSliderView Preview](./preview.png)

## Overview

TimeSliderView is a UIKit-based component that provides an intuitive slider interface for time-based filtering. It displays time options as labels below the slider and visually highlights the currently selected option.

## Features

- ✅ **Customizable Time Options**: Define your own time intervals and labels
- ✅ **Visual Feedback**: Selected time option is highlighted with accent color
- ✅ **Reactive Design**: Uses Combine framework for reactive state management
- ✅ **Custom Styling**: Integrates with StyleProvider for consistent theming
- ✅ **Accessibility**: Proper label positioning and readable fonts
- ✅ **Preview Support**: Includes SwiftUI preview for development

## Architecture

The component follows MVVM architecture pattern:

```
TimeSliderView (UIView)
    ↓
TimeSliderViewModelProtocol
    ↓
MockTimeSliderViewModel (Concrete Implementation)
    ↓
TimeOption (Data Model)
```

## Files Structure

```
TimeSliderView/
├── TimeSliderView.swift                    # Main UI component
├── TimeSliderViewModelProtocol.swift       # View model protocol
├── MockTimeSliderViewModel.swift           # Mock implementation
├── Models/
│   └── TimeSliderViewModels.swift         # Data models
└── README.md                              # This file
```

## Usage

### Basic Implementation

```swift


// 1. Create time options
let timeOptions = [
    TimeOption(title: "All", value: 0),
    TimeOption(title: "1h", value: 1),
    TimeOption(title: "8h", value: 8),
    TimeOption(title: "Today", value: 24),
    TimeOption(title: "48h", value: 48)
]

// 2. Create view model
let viewModel = MockTimeSliderViewModel(
    title: "Filter by Time",
    timeOptions: timeOptions,
    selectedValue: 0
)

// 3. Create and configure the view
let timeSliderView = TimeSliderView(viewModel: viewModel)
timeSliderView.translatesAutoresizingMaskIntoConstraints = false

// 4. Handle value changes
timeSliderView.onSliderValueChange = { selectedValue in
    let selectedIndex = Int(selectedValue)
    let selectedOption = timeOptions[selectedIndex]
    print("Selected: \(selectedOption.title) - Value: \(selectedOption.value)")
}

// 5. Add to your view hierarchy
view.addSubview(timeSliderView)
NSLayoutConstraint.activate([
    timeSliderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
    timeSliderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
    timeSliderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
])
```

### Reactive Implementation with Combine

```swift
import Combine

class FilterViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    private let timeSliderView: TimeSliderView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Subscribe to value changes
        timeSliderView.viewModel.selectedTimeValue
            .sink { [weak self] value in
                self?.handleTimeSelectionChange(value)
            }
            .store(in: &cancellables)
    }
    
    private func handleTimeSelectionChange(_ value: Float) {
        // Handle the selection change
    }
}
```

## API Reference

### TimeSliderView

The main UI component that displays the time slider interface.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `onSliderValueChange` | `((Float) -> Void)?` | Callback triggered when slider value changes |

#### Methods

| Method | Description |
|--------|-------------|
| `init(viewModel: TimeSliderViewModelProtocol)` | Initializes the view with a view model |

### TimeSliderViewModelProtocol

Protocol defining the interface for time slider view models.

#### Required Properties

| Property | Type | Description |
|----------|------|-------------|
| `title` | `String` | The title displayed at the top of the component |
| `timeOptions` | `[TimeOption]` | Array of available time options |
| `selectedTimeValue` | `CurrentValueSubject<Float, Never>` | Reactive property for selected value |

#### Required Methods

| Method | Description |
|--------|-------------|
| `didChangeValue(_ value: Float)` | Called when the slider value changes |

### MockTimeSliderViewModel

Concrete implementation of `TimeSliderViewModelProtocol` for testing and development.

#### Initializer

```swift
public init(
    title: String, 
    timeOptions: [TimeOption], 
    selectedValue: Float = 0
)
```

### TimeOption

Data model representing a time option in the slider.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `title` | `String` | Display label for the time option |
| `value` | `Float` | Actual time value (e.g., hours, days) |

#### Initializer

```swift
public init(title: String, value: Float)
```

## Customization

### Styling

The component uses `StyleProvider` for consistent theming. You can customize:

- **Colors**: Accent color, text colors, track colors
- **Fonts**: Title and label fonts
- **Spacing**: Margins and padding

### Custom Time Options

Create custom time intervals based on your needs:

```swift
// Minutes-based intervals
let minuteOptions = [
    TimeOption(title: "Now", value: 0),
    TimeOption(title: "15m", value: 15),
    TimeOption(title: "30m", value: 30),
    TimeOption(title: "1h", value: 60)
]

// Day-based intervals
let dayOptions = [
    TimeOption(title: "Today", value: 0),
    TimeOption(title: "3 days", value: 3),
    TimeOption(title: "1 week", value: 7),
    TimeOption(title: "1 month", value: 30)
]
```

### Custom View Model

Implement your own view model for advanced functionality:

```swift
class NetworkTimeSliderViewModel: TimeSliderViewModelProtocol {
    let title: String = "Network Time Filter"
    let timeOptions: [TimeOption]
    let selectedTimeValue: CurrentValueSubject<Float, Never>
    
    init(options: [TimeOption]) {
        self.timeOptions = options
        self.selectedTimeValue = .init(0)
    }
    
    func didChangeValue(_ value: Float) {
        let roundedValue = round(value)
        selectedTimeValue.send(roundedValue)
        
        // Trigger network request with new time filter
        fetchDataWithTimeFilter(roundedValue)
    }
    
    private func fetchDataWithTimeFilter(_ timeValue: Float) {
        // Implement your network logic
    }
}
```

## Integration Examples

### Filter Screen Integration

```swift
class FiltersViewController: UIViewController {
    private let timeSliderView: TimeSliderView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTimeSlider()
    }
    
    private func setupTimeSlider() {
        // Add to stack view or container
        stackView.addArrangedSubview(timeSliderView)
        
        // Configure constraints
        timeSliderView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
}
```

### Navigation Integration

```swift
// Pass selected time value between view controllers
let selectedTimeValue = timeSliderView.viewModel.selectedTimeValue.value
let nextVC = ResultsViewController(timeFilter: selectedTimeValue)
navigationController?.pushViewController(nextVC, animated: true)
```

## Best Practices

1. **Limit Options**: Keep time options to 3-7 items for optimal UX
2. **Clear Labels**: Use concise, understandable time labels
3. **Logical Order**: Arrange time options in ascending or logical order
4. **Default Selection**: Set a sensible default value
5. **Feedback**: Provide visual feedback for selection changes

## Accessibility

The component includes accessibility features:

- Proper label positioning for readability
- Color contrast compliance through StyleProvider
- Semantic font sizing
- Touch target optimization

## Requirements

- iOS 13.0+
- Swift 5.0+
- UIKit
- Combine framework

## Dependencies

- `StyleProvider`: For consistent theming and colors
- `Combine`: For reactive programming

## Notes

- The slider uses index-based values (0, 1, 2, etc.) internally
- The `value` property in `TimeOption` represents the actual time value
- Layout updates automatically when the view bounds change
- Component is fully compatible with Auto Layout

## Contributing

When contributing to this component:

1. Maintain the existing architecture pattern
2. Add tests for new functionality
3. Update this README with any API changes
4. Follow the established naming conventions
5. Ensure backward compatibility

## License

This component is part of the GomaUI library. See the main library license for details. 
