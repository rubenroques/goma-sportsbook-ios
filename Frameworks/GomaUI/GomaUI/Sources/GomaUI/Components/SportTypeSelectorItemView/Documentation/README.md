# SportTypeSelectorItemView

A reusable UI component that displays a single sport type with an icon and label. Used as an individual item in sport selection interfaces.

## Features

- Clean icon + text layout with consistent styling
- 24x24 icon display with system icon mapping
- 12pt text label below icon
- 56px fixed height with rounded corners
- Tap gesture support with callback
- Reactive state management via Combine
- StyleProvider integration for theming

## Usage Example

```swift
// Create a view model (or use a mock for testing)
let sportData = SportTypeData(id: "football", name: "Football", iconName: "football")
let viewModel = MockSportTypeSelectorItemViewModel(sportData: sportData)

// Create the component
let sportItemView = SportTypeSelectorItemView(viewModel: viewModel)

// Handle tap events
sportItemView.onTap = { sportData in
    print("Selected sport: \(sportData.name)")
    // Perform navigation or other actions
}

// Add to your view hierarchy
parentView.addSubview(sportItemView)

// Set up constraints
NSLayoutConstraint.activate([
    sportItemView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
    sportItemView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
    sportItemView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor),
    sportItemView.heightAnchor.constraint(equalToConstant: 56)
])
```

## Data Models

### SportTypeData
```swift
public struct SportTypeData: Equatable, Hashable {
    public let id: String        // Unique identifier
    public let name: String      // Display name (e.g., "Football")
    public let iconName: String  // Icon identifier
}
```

### SportTypeSelectorItemDisplayState
```swift
public struct SportTypeSelectorItemDisplayState: Equatable {
    public let sportData: SportTypeData
}
```

## View Model Protocol

```swift
public protocol SportTypeSelectorItemViewModelProtocol {
    var displayStatePublisher: AnyPublisher<SportTypeSelectorItemDisplayState, Never> { get }
}
```

## Mock Implementation

The `MockSportTypeSelectorItemViewModel` provides ready-to-use mock data for various sports:

```swift
// Pre-built sport mocks
let footballMock = MockSportTypeSelectorItemViewModel.footballMock
let basketballMock = MockSportTypeSelectorItemViewModel.basketballMock
let tennisMock = MockSportTypeSelectorItemViewModel.tennisMock
// ... and more

// Custom sport data
let customSport = SportTypeData(id: "custom", name: "Custom Sport", iconName: "customIcon")
let customMock = MockSportTypeSelectorItemViewModel(sportData: customSport)
```

## Icon Mapping

The component maps sport icon names to system icons:

- "football"/"soccer" → `soccerball`
- "basketball" → `basketball`
- "tennis" → `tennisball`
- "baseball" → `baseball`
- "hockey" → `hockey.puck`
- "golf" → `golf.stick.and.ball`
- "volleyball" → `volleyball`
- Default → `sportscourt`

## Styling

The component uses StyleProvider for consistent theming:

- **Background**: `StyleProvider.Color.backgroundSecondary` (#f6f6f8)
- **Text Color**: `StyleProvider.Color.textPrimary` (#252634)
- **Icon Tint**: `StyleProvider.Color.textPrimary` (#252634)
- **Font**: `StyleProvider.fontWith(type: .regular, size: 12)`
- **Corner Radius**: 8pt
- **Padding**: 12pt horizontal, 2pt vertical

## SwiftUI Previews

The component includes comprehensive SwiftUI previews:

```swift
#Preview("Default") {
    PreviewUIView {
        SportTypeSelectorItemView(viewModel: MockSportTypeSelectorItemViewModel.footballMock)
    }
    .frame(width: 150, height: 56)
}
```

## Integration Notes

- This component is designed to be reusable across the app
- Can be used standalone or within collection views
- Integrates seamlessly with `SportTypeSelectorView` for full selection flows
- Follows GomaUI architecture patterns with MVVM + Combine