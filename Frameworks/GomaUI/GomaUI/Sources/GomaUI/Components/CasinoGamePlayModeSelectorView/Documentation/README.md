# CasinoGamePlayModeSelectorView

A sophisticated reusable component for displaying casino game details with configurable play mode buttons. This component adapts to different user states and provides flexible button configurations for various casino game scenarios.

## Features

- **Configurable Button States**: Support for primary, secondary, and tertiary buttons with different styles (filled, outlined, text)
- **Dynamic Button Management**: Buttons can be enabled, disabled, or show loading states
- **Rich Game Display**: Shows game image, title, description, volatility, and minimum stake
- **Adaptive Layout**: Responsive design that works across different screen sizes
- **StyleProvider Integration**: Uses centralized theming for consistent appearance
- **Reactive State Management**: Uses Combine publishers for seamless state updates
- **Accessibility Support**: Full accessibility support with appropriate labels and hints

## Usage Example

### Basic Usage

```swift
// Create game data
let gameData = CasinoGamePlayModeSelectorGameData(
    id: "surging-7s",
    name: "Surging 7s",
    imageURL: "https://example.com/game-image.jpg",
    provider: "Pragmatic Play",
    volatility: "Medium",
    minStake: "XAF 1",
    description: "Engross yourself into the world of Surging 7s..."
)

// Configure buttons for logged-out user
let buttons = [
    CasinoGamePlayModeButton(
        id: "login",
        type: .primary,
        title: "LOGIN_TO_PLAY",
        state: .enabled,
        style: .filled
    ),
    CasinoGamePlayModeButton(
        id: "practice",
        type: .secondary,
        title: "PRACTICE_PLAY",
        state: .enabled,
        style: .outlined
    )
]

// Create view model
let viewModel = MockCasinoGamePlayModeSelectorViewModel(
    gameData: gameData,
    buttons: buttons
)

// Create the component
let selectorView = CasinoGamePlayModeSelectorView(viewModel: viewModel)

// Add to your view hierarchy
parentView.addSubview(selectorView)

// Set up constraints
NSLayoutConstraint.activate([
    selectorView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor),
    selectorView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
    selectorView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
    selectorView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
])

// Handle button taps
selectorView.onButtonTapped = { buttonId in
    switch buttonId {
    case "login":
        // Navigate to login screen
        break
    case "practice":
        // Start practice mode
        break
    case "play":
        // Start real money play
        break
    default:
        break
    }
}
```

## Button Configuration Scenarios

### Logged-Out User
```swift
let buttons = [
    CasinoGamePlayModeButton(
        id: "login",
        type: .primary,
        title: "LOGIN_TO_PLAY",
        state: .enabled,
        style: .filled
    ),
    CasinoGamePlayModeButton(
        id: "practice",
        type: .secondary,
        title: "PRACTICE_PLAY",
        state: .enabled,
        style: .outlined
    )
]
```

### Logged-In User with Funds
```swift
let buttons = [
    CasinoGamePlayModeButton(
        id: "play",
        type: .primary,
        title: "PLAY_NOW",
        state: .enabled,
        style: .filled
    ),
    CasinoGamePlayModeButton(
        id: "practice",
        type: .secondary,
        title: "PRACTICE_MODE",
        state: .enabled,
        style: .outlined
    )
]
```

### Insufficient Funds
```swift
let buttons = [
    CasinoGamePlayModeButton(
        id: "deposit",
        type: .primary,
        title: "DEPOSIT_TO_PLAY",
        state: .enabled,
        style: .filled
    ),
    CasinoGamePlayModeButton(
        id: "practice",
        type: .secondary,
        title: "PRACTICE_PLAY",
        state: .enabled,
        style: .outlined
    )
]
```

### Loading State
```swift
let buttons = [
    CasinoGamePlayModeButton(
        id: "login",
        type: .primary,
        title: "LOGIN_TO_PLAY",
        state: .loading,
        style: .filled
    ),
    CasinoGamePlayModeButton(
        id: "practice",
        type: .secondary,
        title: "PRACTICE_PLAY",
        state: .disabled,
        style: .outlined
    )
]
```

## Data Models

### CasinoGamePlayModeSelectorGameData
- **id**: Unique identifier for the game
- **name**: Display name of the game
- **imageURL**: Optional URL for the game image
- **provider**: Game provider name (e.g., "Pragmatic Play")
- **volatility**: Game volatility level (e.g., "Low", "Medium", "High")
- **minStake**: Minimum stake required (e.g., "XAF 1")
- **description**: Optional game description

### CasinoGamePlayModeButton
- **id**: Unique identifier for the button
- **type**: Button hierarchy (.primary, .secondary, .tertiary)
- **title**: Button text
- **state**: Button state (.enabled, .disabled, .loading)
- **style**: Visual style (.filled, .outlined, .text)

## State Management

The component uses reactive state management through Combine publishers:

```swift
// Listen to state changes
viewModel.displayStatePublisher
    .sink { displayState in
        // Component automatically updates UI
        print("Game: \(displayState.gameData.name)")
        print("Buttons: \(displayState.buttons.count)")
        print("Loading: \(displayState.isLoading)")
    }
    .store(in: &cancellables)

// Update states programmatically
viewModel.setLoading(true)
viewModel.refreshGameData()
```

## Mock Implementations

The component includes several pre-configured mock implementations:

- `MockCasinoGamePlayModeSelectorViewModel.defaultMock` - Logged-out user state
- `MockCasinoGamePlayModeSelectorViewModel.loggedInMock` - Logged-in user with funds
- `MockCasinoGamePlayModeSelectorViewModel.insufficientFundsMock` - User needs to deposit
- `MockCasinoGamePlayModeSelectorViewModel.loadingMock` - Loading state
- `MockCasinoGamePlayModeSelectorViewModel.disabledMock` - Maintenance mode
- `MockCasinoGamePlayModeSelectorViewModel.interactiveMock` - Interactive demo

## Integration with Navigation

The component works seamlessly with coordinator-based navigation:

```swift
// In your coordinator
selectorView.onButtonTapped = { [weak self] buttonId in
    switch buttonId {
    case "login":
        self?.showLogin()
    case "practice":
        self?.showGamePlay(mode: .practice)
    case "play":
        self?.showGamePlay(mode: .realMoney)
    case "deposit":
        self?.showDeposit()
    default:
        break
    }
}
```

## Design Specifications

- **Layout**: Scrollable vertical layout with centered game image
- **Image Size**: 200x120pt game image with 12pt corner radius
- **Typography**: 
  - Title: Bold 24pt
  - Description: Regular 14pt
  - Details: Medium 12pt
- **Spacing**: 24pt margins, 12pt internal spacing
- **Button Height**: 50pt with 8pt corner radius
- **Colors**: Uses StyleProvider for consistent theming

## Accessibility

The component provides comprehensive accessibility support:

- **Dynamic Labels**: Button titles and states are properly announced
- **Semantic Roles**: Buttons have appropriate accessibility roles
- **State Changes**: Loading and disabled states are announced
- **Touch Targets**: All buttons meet minimum 44pt touch target requirements

## Testing

Use the mock implementations for testing different scenarios:

```swift
func testLoggedOutUser() {
    let viewModel = MockCasinoGamePlayModeSelectorViewModel.defaultMock
    let selectorView = CasinoGamePlayModeSelectorView(viewModel: viewModel)
    
    // Test button configuration
    XCTAssertEqual(viewModel.buttons.count, 2)
    XCTAssertEqual(viewModel.buttons[0].id, "login")
    XCTAssertEqual(viewModel.buttons[1].id, "practice")
}
```

This component provides a professional, flexible solution for casino game pre-play screens that adapts to different user states while maintaining consistent design patterns and accessibility standards.