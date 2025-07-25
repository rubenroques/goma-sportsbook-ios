# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### Building
```bash
# Standard build with LLM-friendly output (recommended)
./Scripts/build.py -s "Betsson PROD" --llm-mode

# Build with code signing when needed
./Scripts/build.py -s "Betsson PROD" --llm-mode --enable-code-signing

# Clean build
./Scripts/build.py -s "Betsson PROD" --llm-mode --clean
```

### Testing
```bash
# Run tests
./Scripts/build.py -s "SportsbookTests" --llm-mode

# Test specific target
xcodebuild test -workspace Sportsbook.xcworkspace -scheme SportsbookTests -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Linting
```bash
# Run SwiftLint (must be installed via Homebrew)
swiftlint

# Auto-fix SwiftLint issues where possible
swiftlint --fix
```

### Fastlane
```bash
# Build and deploy beta
bundle exec fastlane beta

# Run tests via fastlane
bundle exec fastlane test

# Run lint checks
bundle exec fastlane lint
```

## Architecture Overview

This is a sophisticated multi-brand iOS sportsbook application built with a modular, white-label architecture that supports multiple betting platforms.

### Core Framework Structure

The app follows a layered architecture with clear separation of concerns:

#### App Layer (`Core/App/`)
- **AppDelegate.swift**: Application lifecycle management
- **Bootstrap.swift**: Dependency injection and app initialization
- **Router.swift**: Navigation coordination and deep linking
- **Environment.swift**: Environment configuration management

#### Services Layer (`Core/Services/`)
- **ServicesProvider**: Abstracted backend communication layer supporting multiple providers (SportRadar, EveryMatrix)
- **UserSessionStore**: User authentication and session management
- **BetslipManager**: Betting slip operations and state management
- **FavoritesManager**: User favorites persistence
- **RealtimeSocketClient**: WebSocket connections for live data
- **GeoLocationManager**: Location services integration

#### Models Layer (`Core/Models/`)
- **App/**: Application-specific models (Match, Sport, BetType, etc.)
- **EveryMatrixAPI/**: Betting provider models
- **GGAPI/**: GomaGaming API models  
- **ModelMappers/**: Data transformation between different API formats
- **Shared/**: Common models used across the app

#### Presentation Layer (`Core/Screens/`, `Core/Views/`)
- UIKit-based ViewControllers with structured organization
- Reusable UI components and custom views
- Hybrid SwiftUI integration for modern components

### White-Label Client System

The app supports multiple brands through the `Clients/` directory:

- **Betsson**: Main production client (PROD/UAT environments)
- **SportRadar**: Sports data provider implementation
- **ATP**, **Crocobet**, **DAZN**: Specialized market implementations
- **Showcase**: Template for new client implementations

Each client contains:
- **TargetVariables.swift**: Environment-specific configuration
- **ClientVariables.swift**: Brand-specific settings
- **Assets/**: Brand-specific images, colors, fonts
- **LaunchScreen/**: Custom launch screens

### Service Provider Architecture

The `ServicesProvider` framework provides a protocol-oriented abstraction layer:

```swift
public protocol ServicesProviderClient {
    var privilegedAccessManager: PrivilegedAccessManager { get }
    var eventsProvider: EventsProvider { get }
    var bettingProvider: BettingProvider { get }
    var analyticsProvider: AnalyticsProvider { get }
}
```

Currently supports:
- **SportRadar**: Complete implementation for sports data and betting
- **EveryMatrix**: Alternative betting platform integration

### Key Dependencies

The project uses Swift Package Manager for internal modules and has these key frameworks:
- **Combine**: Reactive programming and data flow
- **SwiftUI**: Modern UI components (hybrid approach)
- **CoreLocation**: Geolocation services
- **WebKit**: Embedded web content
- **AVFoundation**: Media playback
- **Firebase**: Analytics and real-time database

## Development Guidelines

### Code Organization

Follow the established `//MARK:` pattern in ViewControllers:
```swift
class ExampleViewController: UIViewController {
    // MARK: - Types
    // MARK: - Properties  
    // MARK: - Lifetime and Cycle
    // MARK: - Layout and Theme
    // MARK: - Setup
    // MARK: - Bindings
    // MARK: - Actions
    // MARK: - Notifications
    // MARK: - Convenience
    // MARK: - Delegates
}
```

### Import Rules (from .cursor/rules/)
- **Same module, different folders**: No import needed
- **Different modules**: Use `import ModuleName`
- Never use relative file imports or paths

### Environment Configuration

Target variables are configured per client in `TargetVariables.swift`:
```swift
struct TargetVariables: SportsbookTarget {
    static var environmentType: EnvironmentType = .prod
    static var gomaGamingHost: String { "https://api.example.com" }
    // ... environment-specific settings
}
```

### Build System

The project uses a custom Python build script (`Scripts/build.py`) with LLM-friendly output:
- Use `--llm-mode` flag for machine-readable build output
- Primary scheme: "Betsson PROD"
- Test scheme: "SportsbookTests"

## Working with the Codebase

### Adding New Features
1. Implement in `Core/` for shared functionality
2. Add client-specific customizations in `Clients/[ClientName]/`
3. Follow the reactive architecture using Combine publishers
4. Use the established service provider abstractions

### Common File Locations
- Business logic: `Core/Services/`
- UI screens: `Core/Screens/[FeatureName]/`
- Reusable components: `Core/Views/`
- Models: `Core/Models/[ServiceName]/`
- Client config: `Clients/[ClientName]/TargetVariables.swift`
- Shared utilities: `Core/Tools/Extensions/`

### Testing
- Unit tests: `Core/Tests/`
- UI tests: Target-specific test schemes
- Use the build script with appropriate scheme selection

The codebase maintains high modularity with clear boundaries between white-label customization points and core functionality, enabling efficient multi-brand development.