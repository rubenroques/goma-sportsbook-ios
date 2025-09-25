# CustomSliderView

CustomSliderView is a highly customizable slider component that provides precise control over appearance and behavior. Unlike the native UISlider, it offers complete visual customization with custom track and thumb styling, discrete step positioning, and smooth animations.

## Features

- **Custom Visual Design**: Full control over track height, corner radius, and thumb size
- **Custom Thumb Images**: Support for SF Symbols, custom images, or default circular thumb
- **Thumb Tinting**: Customizable thumb colors with automatic tinting support
- **Discrete Step Positioning**: Automatic snapping to predefined positions
- **Smooth Animations**: Fluid transitions between positions
- **Touch Interaction**: Supports both dragging and tapping for value changes
- **Accessibility**: Full VoiceOver support with appropriate traits
- **StyleProvider Integration**: Uses centralized styling system

## Use Cases

- Time-based filters with discrete options
- Rating selectors with specific values
- Volume controls with step increments
- Any slider requiring custom visual design
- Replacement for native UISlider when precise styling is needed

## Usage Example

```swift
// Create slider configuration
let configuration = SliderConfiguration(
    minimumValue: 0.0,
    maximumValue: 1.0,
    numberOfSteps: 5,
    trackHeight: 4.0,
    trackCornerRadius: 2.0,
    thumbSize: 24.0,
    thumbImageName: nil,        // Uses default circular thumb
    thumbTintColor: nil         // Uses StyleProvider.Color.highlightPrimary
)

// Create view model
let viewModel = MockCustomSliderViewModel.customMock(
    configuration: configuration,
    initialValue: 0.0,
    isEnabled: true
)

// Create the component
let customSlider = CustomSliderView(viewModel: viewModel)
customSlider.translatesAutoresizingMaskIntoConstraints = false

// Add to your view hierarchy
parentView.addSubview(customSlider)

// Set up constraints
NSLayoutConstraint.activate([
    customSlider.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 16),
    customSlider.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -16),
    customSlider.centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
    customSlider.heightAnchor.constraint(equalToConstant: 44)
])

// Handle value changes
customSlider.onValueChanged = { value in
    print("Slider value changing: \(value)")
    // Update UI during dragging
}

customSlider.onEditingEnded = { value in
    print("Final slider value: \(value)")
    // Apply final value when user stops interacting
}
```

## Integration with Time Filter

```swift
// Example: Using in TimeSliderFilterView
private func setupCustomSlider(with state: TimeSliderFilterDisplayState) {
    let sliderConfiguration = SliderConfiguration(
        minimumValue: 0.0,
        maximumValue: 1.0,
        numberOfSteps: state.options.count, // Number of time options
        trackHeight: 4.0,
        trackCornerRadius: 2.0,
        thumbSize: 24.0
    )
    
    let sliderViewModel = MockCustomSliderViewModel.customMock(
        configuration: sliderConfiguration,
        initialValue: state.sliderPosition,
        isEnabled: true
    )
    
    customSlider = CustomSliderView(viewModel: sliderViewModel)
    
    // Handle interactions
    customSlider.onEditingEnded = { [weak self] value in
        self?.handleSliderValueChange(value)
    }
}
```

## Configuration Options

### SliderConfiguration Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `minimumValue` | Float | Minimum slider value | 0.0 |
| `maximumValue` | Float | Maximum slider value | 1.0 |
| `numberOfSteps` | Int | Number of discrete positions | 5 |
| `trackHeight` | CGFloat | Height of the slider track | 4.0 |
| `trackCornerRadius` | CGFloat | Corner radius of the track | 2.0 |
| `thumbSize` | CGFloat | Size of the thumb (width & height) | 24.0 |
| `thumbImageName` | String? | Name of image/SF Symbol for thumb | nil |
| `thumbTintColor` | UIColor? | Custom tint color for thumb | nil |

### CustomSliderDisplayState Properties

| Property | Type | Description |
|----------|------|-------------|
| `configuration` | SliderConfiguration | Slider appearance and behavior settings |
| `currentValue` | Float | Current slider value (0.0 to 1.0) |
| `isEnabled` | Bool | Whether the slider is interactive |

### Interaction Methods

| Method | Description |
|--------|-------------|
| `updateValue(_:)` | Programmatically set slider value |
| `snapToNearestStep()` | Snap current value to nearest discrete step |
| `setEnabled(_:)` | Enable or disable slider interaction |

## Visual Design

The CustomSliderView provides exact visual control matching design specifications:

### Track Styling
- **Height**: Configurable (default 4px)
- **Corner Radius**: Configurable (default 2px)
- **Color**: Uses `StyleProvider.Color.highlightSecondary` with alpha
- **Background**: Transparent

### Thumb Styling
- **Size**: Configurable (default 24x24px)
- **Image**: Custom images, SF Symbols, or default circular shape
- **Tinting**: Automatic color tinting with custom or StyleProvider colors
- **Shadow**: Subtle drop shadow for depth
- **Animation**: Smooth position transitions

## Styling

The CustomSliderView uses StyleProvider for consistent theming:

```swift
// Customize colors
StyleProvider.Color.customize(
    primaryColor: UIColor(named: "BrandOrange"),    // Thumb color
    secondaryColor: UIColor(named: "TrackGray")     // Track color
)

// The component automatically applies:
// - primaryColor: Thumb background
// - secondaryColor (with alpha): Track background
```

## Accessibility

The CustomSliderView includes comprehensive accessibility support:

### VoiceOver Features
- **Adjustable Trait**: Exposed as adjustable element
- **Value Announcement**: Current value is announced
- **Gesture Support**: Swipe up/down to adjust value
- **Custom Hints**: Contextual interaction guidance

### Accessibility Identifiers
- `customSlider.slider` - Main slider element

## Available Mock Data

### Predefined Configurations

```swift
MockCustomSliderViewModel.defaultMock        // Basic 5-step slider at minimum
MockCustomSliderViewModel.midPositionMock    // 5-step slider at middle position
MockCustomSliderViewModel.timeFilterMock     // Configured for time filtering
MockCustomSliderViewModel.disabledMock       // Disabled state example
MockCustomSliderViewModel.customImageMock    // Blue circle SF Symbol thumb
MockCustomSliderViewModel.volumeSliderMock   // Green speaker icon thumb
```

### Custom Configuration

```swift
// Basic custom configuration
MockCustomSliderViewModel.customMock(
    configuration: SliderConfiguration(
        minimumValue: 0.0,
        maximumValue: 100.0,
        numberOfSteps: 11,
        trackHeight: 6.0,
        trackCornerRadius: 3.0,
        thumbSize: 28.0,
        thumbImageName: nil,
        thumbTintColor: nil
    ),
    initialValue: 50.0,
    isEnabled: true
)

// Custom thumb image with SF Symbol
MockCustomSliderViewModel.customMock(
    configuration: SliderConfiguration(
        minimumValue: 0.0,
        maximumValue: 1.0,
        numberOfSteps: 5,
        trackHeight: 4.0,
        trackCornerRadius: 2.0,
        thumbSize: 28.0,
        thumbImageName: "star.fill",        // SF Symbol
        thumbTintColor: UIColor.systemYellow
    ),
    initialValue: 0.5,
    isEnabled: true
)
```

## Implementation Notes

### Gesture Handling
- **Pan Gesture**: Continuous value updates during dragging
- **Tap Gesture**: Direct positioning by tapping on track
- **Touch Area**: Minimum 44pt touch target for accessibility
- **Smooth Tracking**: Real-time position updates

### Step Snapping
- **Automatic**: Snaps to nearest step on interaction end
- **Configurable**: Number of steps defined in configuration
- **Precise**: Calculated positioning for exact step alignment

### Performance Considerations
- **Efficient Rendering**: Minimal view hierarchy with UIView elements
- **Smooth Animations**: Uses Core Animation for position changes
- **Memory Management**: Proper cleanup of constraints and observers
- **Layout Updates**: Responsive to bounds changes

## Advanced Usage

### Custom Configurations

```swift
// Volume slider with 11 steps (0-10)
let volumeConfig = SliderConfiguration(
    minimumValue: 0.0,
    maximumValue: 10.0,
    numberOfSteps: 11,
    trackHeight: 6.0,
    trackCornerRadius: 3.0,
    thumbSize: 28.0
)

// Rating slider with 5 stars
let ratingConfig = SliderConfiguration(
    minimumValue: 1.0,
    maximumValue: 5.0,
    numberOfSteps: 5,
    trackHeight: 8.0,
    trackCornerRadius: 4.0,
    thumbSize: 32.0
)

// Progress indicator (read-only)
let progressConfig = SliderConfiguration(
    minimumValue: 0.0,
    maximumValue: 1.0,
    numberOfSteps: 100,
    trackHeight: 2.0,
    trackCornerRadius: 1.0,
    thumbSize: 0.0 // No thumb for progress bars
)
```

### Integration Patterns

```swift
// Coordinated sliders
class MultiSliderView: UIView {
    private let volumeSlider: CustomSliderView
    private let bassSlider: CustomSliderView
    private let trebleSlider: CustomSliderView
    
    private func setupSliders() {
        // Configure each slider with different parameters
        // Coordinate their interactions
        
        volumeSlider.onEditingEnded = { [weak self] value in
            self?.updateAudioSettings()
        }
    }
}

// Dynamic reconfiguration
func updateSliderForContext(_ context: FilterContext) {
    let newConfig = SliderConfiguration(
        numberOfSteps: context.availableOptions.count,
        trackHeight: context.isCompact ? 2.0 : 4.0,
        thumbSize: context.isCompact ? 16.0 : 24.0
    )
    
    // Update slider with new configuration
    sliderViewModel.updateConfiguration(newConfig)
}
```

## Best Practices

1. **Consistent Sizing**: Use standard thumb sizes (20-28pt) for touch targets
2. **Appropriate Steps**: Choose step counts that make sense for your data
3. **Visual Feedback**: Provide immediate visual response to user interaction
4. **Accessibility**: Always test with VoiceOver enabled
5. **Performance**: Avoid excessive step counts for smooth interaction

The CustomSliderView provides the foundation for creating pixel-perfect slider interfaces that match design specifications while maintaining excellent usability and accessibility. 
