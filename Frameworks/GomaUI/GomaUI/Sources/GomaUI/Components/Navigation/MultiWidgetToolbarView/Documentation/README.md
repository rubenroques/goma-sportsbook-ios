# MultiWidgetToolbarView

A highly configurable and dynamic toolbar for displaying various widgets in a customizable layout.

## Features

- Support for multiple widget types: images, buttons, wallet, avatar, etc.
- Dynamic layout that adapts to logged-in vs. logged-out states
- Flexible arrangement of widgets (flex/split modes)
- Customizable through JSON configuration
- Combine-based reactive architecture

## Usage

### Basic Usage

```swift
// Create a view model (or use a mock for testing)
let viewModel = MockMultiWidgetToolbarViewModel.defaultMock

// Create the toolbar view
let toolbarView = MultiWidgetToolbarView(viewModel: viewModel)

// Add to your view hierarchy
parentView.addSubview(toolbarView)

// Set up constraints
NSLayoutConstraint.activate([
    toolbarView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
    toolbarView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
    toolbarView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor)
])

// Handle widget selection
toolbarView.onWidgetSelected = { widgetID in
    print("Widget selected: \(widgetID)")
    // Perform navigation or other actions
}

// Change state based on user login
toolbarView.setLoggedInState(isUserLoggedIn)
```

### Configuration Format

The component uses a JSON-based configuration with this structure:

```json
{
  "name": "topbar",
  "widgets": [
    {
      "id": "logo",
      "type": "image",
      "src": "https://example.com/logo.png",
      "alt": "Company Logo"
    },
    {
      "id": "loginButton",
      "type": "button",
      "label": "Login",
      "route": "/login"
    }
    // More widgets...
  ],
  "layouts": {
    "loggedIn": {
      "lines": [
        {
          "mode": "flex",
          "widgets": ["logo", "flexSpace", "wallet", "avatar"]
        }
      ]
    },
    "loggedOut": {
      "lines": [
        {
          "mode": "flex",
          "widgets": ["logo", "flexSpace", "support"]
        },
        {
          "mode": "split",
          "widgets": ["loginButton", "registerButton"]
        }
      ]
    }
  }
}
```

### Custom ViewModel Implementation

To create a custom ViewModel implementation:

```swift
class MyMultiWidgetToolbarViewModel: MultiWidgetToolbarViewModelProtocol {
    // Implement the required properties and methods
    private let displayStateSubject: CurrentValueSubject<MultiWidgetToolbarDisplayState, Never>
    
    var displayStatePublisher: AnyPublisher<MultiWidgetToolbarDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }
    
    // Load configuration from API, file, or other source
    init(configURL: URL) {
        // Load config
        // Create initial state
    }
    
    func selectWidget(id: String) {
        // Handle widget selection
    }
    
    func setLayoutState(_ state: LayoutState) {
        // Update the layout state
    }
}
```

## Widget Types

The component supports these widget types:

- **image**: Displays an image (logo, icon)
- **wallet**: Shows balance with deposit button
- **avatar**: User profile picture/icon
- **support**: Support/help button
- **languageSwitcher**: Language selection
- **button**: Standard button with label
- **space**: Flexible spacing element

## Layout Modes

Two layout modes are available:

- **flex**: Distributes widgets with flexible spacing (some take more space than others)
- **split**: Distributes widgets equally across the available width 