# ProfileMenuListView

A configurable profile menu component that displays a list of interactive menu items with different types and behaviors.

## Overview

ProfileMenuListView is a comprehensive profile menu solution that supports multiple item types, JSON configuration, and reactive updates. It consists of two main components:

- **ProfileMenuListView**: Main container that manages the list of menu items
- **ProfileMenuItemView**: Individual menu item with icon, title, optional value, and chevron

## Features

- **Multiple Item Types**: Navigation, Action, and Selection items
- **JSON Configuration**: Load menu structure from external JSON files
- **Reactive Updates**: Real-time language selection updates
- **Interactive Feedback**: Visual tap feedback and callbacks
- **StyleProvider Integration**: Full theming support
- **MVVM Architecture**: Protocol-driven with comprehensive mocks

## Item Types

### Navigation Items
- Shows chevron arrow
- Used for items that navigate to other screens
- Examples: Notifications, Transaction History, Help Center

### Action Items  
- No chevron arrow
- Used for immediate actions
- Examples: Logout

### Selection Items
- Shows current value + chevron arrow
- Used for settings with current state display
- Examples: Language selection showing "English"

## Usage

### Basic Usage

```swift


// Create with default configuration
let viewModel = MockProfileMenuListViewModel.defaultMock
let profileMenu = ProfileMenuListView(viewModel: viewModel)

// Add to view hierarchy
view.addSubview(profileMenu)
```

### JSON Configuration

```swift
// Load from custom JSON file
let viewModel = MockProfileMenuListViewModel.jsonConfigurationMock(fileName: "CustomMenuConfig")
let profileMenu = ProfileMenuListView(viewModel: viewModel)
```

### Custom Implementation

```swift
class MyProfileMenuViewModel: ProfileMenuListViewModelProtocol {
    @Published private var menuItems: [ProfileMenuItem] = []
    @Published private var currentLanguage: String = "English"
    
    var menuItemsPublisher: AnyPublisher<[ProfileMenuItem], Never> {
        $menuItems.eraseToAnyPublisher()
    }
    
    var currentLanguagePublisher: AnyPublisher<String, Never> {
        $currentLanguage.eraseToAnyPublisher()
    }
    
    func didSelectItem(_ item: ProfileMenuItem) {
        // Handle item selection
        switch item.action {
        case .notifications:
            // Navigate to notifications
        case .logout:
            // Perform logout
        case .changeLanguage:
            // Show language picker
        default:
            break
        }
    }
    
    func loadConfiguration(from jsonFileName: String?) {
        // Load menu configuration
    }
    
    func updateCurrentLanguage(_ language: String) {
        currentLanguage = language
    }
}
```

## JSON Configuration Format

```json
{
  "menuItems": [
    {
      "id": "notifications",
      "icon": "bell",
      "title": "Notifications",
      "type": "navigation",
      "action": "notifications"
    },
    {
      "id": "change_language",
      "icon": "globe", 
      "title": "Change Language",
      "type": "selection",
      "value": "English",
      "action": "changeLanguage"
    },
    {
      "id": "logout",
      "icon": "rectangle.portrait.and.arrow.right",
      "title": "Logout",
      "type": "action",
      "action": "logout"
    }
  ]
}
```

## Data Models

### ProfileMenuItem

```swift
struct ProfileMenuItem: Codable, Identifiable {
    let id: String              // Unique identifier
    let icon: String            // SF Symbol or custom icon name
    let title: String           // Display title
    let type: ProfileMenuItemType  // Item behavior type
    let action: ProfileMenuAction  // Action identifier
}
```

### ProfileMenuItemType

```swift
enum ProfileMenuItemType: Codable {
    case navigation             // Shows chevron, navigates
    case action                // No chevron, immediate action
    case selection(String)     // Shows value + chevron
}
```

### ProfileMenuAction

```swift
enum ProfileMenuAction: String, Codable {
    case notifications
    case transactionHistory
    case changeLanguage
    case responsibleGaming
    case helpCenter
    case changePassword
    case logout
}
```

## Styling

The component uses StyleProvider for consistent theming:

- **Container Background**: `StyleProvider.Color.backgroundPrimary` (#03061b)
- **Item Background**: `StyleProvider.Color.backgroundSecondary` (#1f2147) 
- **Text Color**: `StyleProvider.Color.textPrimary` (white)
- **Icon Tint**: `StyleProvider.Color.highlightPrimary` (#ff6600)
- **Chevron Tint**: `StyleProvider.Color.iconSecondary`

## Layout Specifications

- **Container**: 8px padding, 16px corner radius
- **Item Height**: 48px with 8px spacing between items
- **Item Padding**: 12px horizontal, 9px vertical
- **Icon Size**: 22x22px container with up to 18x18px icon
- **Chevron Size**: 18x18px

## Mock ViewModels

### Available Mocks

```swift
// Default configuration with all menu items
MockProfileMenuListViewModel.defaultMock

// Load from JSON configuration
MockProfileMenuListViewModel.jsonConfigurationMock(fileName: "ProfileMenuConfiguration")

// French language preset
MockProfileMenuListViewModel.frenchLanguageMock

// Interactive demo with logging
MockProfileMenuListViewModel.interactiveMock

// Custom callback handling
MockProfileMenuListViewModel.customCallbackMock { item in
    print("Selected: \(item.title)")
}
```

## Interactive Features

### Language Selection
- Tapping "Change Language" cycles through available languages
- Value display updates reactively
- All instances update when language changes

### Visual Feedback
- Scale animation on tap (95% scale)
- Immediate callback execution
- Console logging in mock implementations

### Action Handling
Different actions trigger different behaviors:
- **Navigation**: Typically shows new screen
- **Action**: Performs immediate operation (e.g., logout)
- **Selection**: Shows picker or cycles through options

## Demo Integration

The component is integrated into GomaUIDemo with:
- Interactive configuration switching
- Real-time language updates
- Action logging display
- Multiple mock scenarios

## Requirements

- iOS 13.0+
- UIKit framework
- Combine framework
- GomaUI StyleProvider

## File Structure

```
ProfileMenuListView/
├── ProfileMenuListView.swift              # Main container component
├── ProfileMenuItemView.swift              # Individual menu item
├── ProfileMenuListViewModelProtocol.swift # Protocol definition
├── MockProfileMenuListViewModel.swift     # Mock implementation
└── README.md                             # This documentation
```

## Best Practices

1. **Always use ViewModels**: Don't create views directly, use the protocol-based approach
2. **Handle all actions**: Implement proper callbacks for all menu actions
3. **Update language reactively**: Use the currentLanguagePublisher for dynamic updates
4. **Use JSON for flexibility**: External configuration allows easy menu customization
5. **Test all item types**: Ensure navigation, action, and selection items work correctly
6. **Follow StyleProvider**: Never hardcode colors or fonts

## Example Implementation

See `ProfileMenuListViewController` in the GomaUIDemo app for a complete implementation example with interactive features and real-time updates.
