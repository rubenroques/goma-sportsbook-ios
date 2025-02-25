# GomaGaming Sportsbook - iOS Client

GOMA Sportsbook is a sophisticated multi-sport betting application for iOS. This white-label solution powers multiple betting brands through a core framework with customizable client implementations.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Project Architecture](#project-architecture)
  - [Core Framework](#core-framework)
  - [ServicesProvider Framework](#servicesprovider-framework)
  - [Client Implementations](#client-implementations)
  - [SwiftUI Integration](#swiftui-integration)
- [Development Workflow](#development-workflow)
  - [Code Style Guidelines](#code-style-guidelines)
  - [ViewController Structure](#viewcontroller-structure)
  - [Testing Strategy](#testing-strategy)
- [White-Labeling](#white-labeling)
  - [Creating a New Client](#creating-a-new-client)
  - [Customization Points](#customization-points)
- [Key Frameworks](#key-frameworks)
- [CI/CD Pipeline](#cicd-pipeline)
- [Tools and Utilities](#tools-and-utilities)
- [Troubleshooting](#troubleshooting)

## Requirements

* Xcode 14+
* iOS 14+
* [SwiftLint](https://github.com/realm/SwiftLint) for code style enforcement
* [Fastlane](https://docs.fastlane.tools/) for CI/CD
* [CocoaPods](https://cocoapods.org/) for dependency management

## Installation

1. Clone this repository:
```bash
git clone git@github.com:gomagaming/sportsbook-ios.git
```

2. Install SwiftLint if not already installed:
```bash
brew install swiftlint
```

3. Install Fastlane if not already installed:
```bash
gem install fastlane
```

4. Set up Ruby environment (using bundler):
```bash
bundle install
```

5. Open `Sportsbook.xcodeproj` file to start development.

## Project Architecture

The Sportsbook iOS client follows a modular architecture that separates core functionality from client-specific implementations, enabling efficient white-labeling.

### Core Framework

The **Core** directory contains the main functionality of the app:

#### App
Global application classes including:
- `AppDelegate`: Application lifecycle management
- `Bootstrap`: Initialization and dependency setup
- `Router`: Navigation and routing management
- `Environment`: Environment configuration and management

#### Services
External services and utilities including:
- `AppSession`: Manages user session state
- `BetslipManager`: Handles betting slip operations
- `FavoritesManager`: Manages user favorites
- `GeoLocationManager`: Handles geographical location services
- `Networking`: Network communication layer
- `RealtimeSocketClient`: Real-time data communication
- Various service helpers

#### Models
Data structures organized by different APIs and services:
- `App`: Application-specific models
- `EveryMatrixAPI`: Betting provider models
- `GGAPI`: GomaGaming API models
- `ModelMappers`: Transformation between different model types
- `Shared`: Common models used across the app

#### Screens
UI screens and associated logic, including:
- Account management screens
- Betting screens
- Competition and event screens
- Casino screens
- User profile screens
- Live event screens
- Various utility screens

#### Views
Reusable UI components including:
- Custom buttons and inputs
- Card views
- Alert views
- Dialog views
- Navigation components
- Various specialized visual elements

#### Constants
Constant values used throughout the application:
- `Colors`: Color definitions
- `Fonts`: Font definitions
- `Theme`: Theming constants
- `UserDefaults`: UserDefaults keys
- `UserSettings`: User preference constants

#### Tools
Helper utilities and extensions:
- `Extensions`: Swift standard library and UIKit extensions
- `Functional`: Functional programming helpers
- `MiscHelpers`: Various utility functions
- `SwiftUI`: SwiftUI integration helpers
- `ExternalLibs`: Third-party library integrations

#### Resources
Assets and localization files:
- `Animations`: Animation files
- `Fonts`: Font files
- `Localization`: String localizations
- `SharedAssets`: Shared image assets
- Various asset catalogs for different resource types

### ServicesProvider Framework

The ServicesProvider framework abstracts communication with backend services through a protocol-oriented architecture.

#### Key Components

- **ServicesProviderClient**: Main entry point that coordinates access to all services
- **PrivilegedAccessManager**: Handles authentication and user profile management
- **EventsProvider**: Provides sports event data and real-time updates
- **BettingProvider**: Processes bet operations and manages betting history
- **AnalyticsProvider**: Handles user tracking and analytics

#### Data Flow Architecture

The ServicesProvider uses a reactive approach with Combine framework:
- Publishers expose data streams that the UI can subscribe to
- Real-time updates flow through WebSocket connections
- REST APIs handle non-streaming operations

#### Implementation Providers

- **SportRadar**: Complete implementation of all service interfaces
- **EveryMatrix**: Alternative betting platform integration

### Client Implementations

The **Clients** directory contains different brand implementations:

- **ATP**: Tennis-focused client
- **Betsson**: Betting operator implementation
- **Crocobet**: Georgian market implementation
- **DAZN**: Sports streaming service integration
- **EveryMatrix**: Betting platform
- **GOMASports**: Main implementation
- **SportRadar**: Sports data provider implementation
- **Showcase**: Demo client (template for new clients)

Each client contains:
- Client-specific variables and configurations
- Custom assets and branding
- Environment-specific settings (PROD/UAT)
- Launch screen configurations

### SwiftUI Integration

The app uses a hybrid approach with UIKit as the foundation but incorporates SwiftUI where appropriate:
- SwiftUI views wrapped in UIHostingController for integration
- SwiftUI for new features and complex UI components
- UIKit for core navigation and legacy screens

## Development Workflow

### Code Style Guidelines

This project uses SwiftLint to enforce consistent code style. Key principles include:
- Follow Swift API Design Guidelines
- Use clear, descriptive naming
- Keep functions small and focused
- Prefer value types where appropriate
- Use access control appropriately
- Document public interfaces

### ViewController Structure

ViewControllers should be structured using the following pattern with `//MARK:` comments:

```swift
class ExampleViewController: UIViewController {
    // MARK: - Types
    // Enumerations and internal structs

    // MARK: - Properties
    // All properties (IBOutlet, let, var, etc.)

    // MARK: - Lifetime and Cycle
    // init, deinit, viewDidLoad, viewWillAppear, etc.

    // MARK: - Layout and Theme
    // layoutSubviews methods and theme application

    // MARK: - Setup
    // View and data initialization

    // MARK: - Bindings
    // Connect to publishers and data sources

    // MARK: - Actions
    // User-initiated actions (IBAction, gestures, etc.)

    // MARK: - Notifications
    // Notification handling methods

    // MARK: - Convenience
    // Helper methods and interface updates

    // MARK: - Delegates
    // Protocol implementations and delegate methods
}
```

### Testing Strategy

The project includes several test targets:
- **Unit Tests**: Test individual components in isolation
- **Integration Tests**: Test interaction between components
- **UI Tests**: Test user interface functionality

## White-Labeling

### Creating a New Client

To create a new white-label client:

1. Duplicate the **Showcase** directory in the **Clients** folder
2. Update the `ClientVariables.swift` file with brand-specific settings
3. Replace assets in the Assets folder with brand-specific assets
4. Configure `TargetVariables.swift` for each environment (PROD/UAT)
5. Update the launch screen with the brand's styling

### Customization Points

Major customization points include:
- Brand colors and fonts (via Theme)
- Assets and imagery
- Environment URLs and API endpoints
- Feature flags and configurations
- Launch screen and app icons

## Key Frameworks

The project utilizes several key frameworks and libraries:

- **Combine**: For reactive programming and data flow
- **SwiftUI**: For modern UI components
- **CoreLocation**: For geolocation services
- **WebKit**: For embedded web content
- **AVFoundation**: For media playback
- **ServicesProvider**: For backend communication
- **SharedModels**: For common data structures
- **Extensions**: For Swift standard library extensions
- **Theming**: For consistent visual styling

## CI/CD Pipeline

The project uses Fastlane for continuous integration and deployment:

- **Lanes**:
  - `beta`: Builds and distributes beta versions to TestFlight
  - `release`: Prepares and submits app for App Store review
  - `test`: Runs the test suite
  - `lint`: Runs SwiftLint checks

- **Configuration**:
  - Environment-specific build settings
  - Automatic versioning
  - Code signing management
  - Slack notifications

## Tools and Utilities

Helpful development tools:

* [QuickType IO](https://app.quicktype.io/) - Convert JSON to Swift `Codable` structs
* [JSONEditorOnline](http://jsoneditoronline.org/) - JSON formatter and viewer
* [JSON Generator](https://json-generator.com/) - Generate test JSON data
* [StackEdit](https://stackedit.io/) - Markdown preview
* [Charles Proxy](https://www.charlesproxy.com/) - Network debugging

## Troubleshooting

### Common Issues

#### Build Errors
- Check that SwiftLint is installed correctly
- Verify that all dependencies are up to date
- Clear derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`

#### Runtime Errors
- Verify environment configuration
- Check network connectivity
- Ensure proper API credentials are configured

### Getting Help

If you encounter issues:
1. Check the project documentation
2. Review relevant JIRA tickets
3. Contact the development team on Slack
