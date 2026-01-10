# GOMA Gaming Sportsbook - iOS Workspace

A sophisticated multi-project iOS workspace for sports betting applications, featuring modular architecture with multiple branded app targets and a comprehensive UI component library.

## Requirements

* **Xcode 15.0+** (required for iOS 17 support)
* **iOS 17.0+** deployment target
* **Swift 5.9+**
* [SwiftLint](https://github.com/realm/SwiftLint) - code quality enforcement
* [xcbeautify](https://github.com/cpisciotta/xcbeautify) - build output formatting
* [Fastlane](https://docs.fastlane.tools/) - CI/CD automation

## Installation

Clone this repository:
```bash
git clone git@github.com:gomagaming/sportsbook-ios.git
cd sportsbook-ios
```

Install SwiftLint for code quality enforcement:
```bash
brew install swiftlint
```

Open the workspace:
```bash
open Sportsbook.xcworkspace
```

## Workspace Architecture

This workspace contains **five main projects** and **fourteen Swift packages**, organized for scalable multi-client development:

### Main Projects

#### 1. **BetssonCameroonApp** (`BetssonCameroonApp/BetssonCameroonApp.xcodeproj`)
*Modern standalone project - Primary development focus*

The **main focus of active development**, representing the target architecture for all future work.

**Key Features:**
- Clean MVVM-C (Model-View-ViewModel-Coordinator) architecture
- Heavy integration with GomaUI component library (138 components)
- Protocol-driven design with comprehensive mock support
- Direct Swift Package Manager dependencies
- UIScene-based lifecycle
- Per-environment app icons (STG/UAT/PROD visual badges)

**Available Schemes:**
- `BetssonCameroonApp`

**Release Tag Format:** `bcm-vVERSION(BUILD)` (e.g., `bcm-v0.3.2(3120)`)

#### 2. **BetssonFrance** (`BetssonFrance/BetssonFrance.xcodeproj`)
*Modern standalone project for France market*

New standalone project following the same modern architecture as BetssonCameroonApp.

**Available Schemes:**
- `BetssonFrance`

#### 3. **BetssonFranceLegacy** (`BetssonFranceLegacy/Sportsbook.xcodeproj`)
*Legacy multi-target project (formerly BetssonFranceApp)*

Contains the original monolithic codebase with multiple client targets.

**Structure:**
- **Core/**: Shared application logic, screens, services, and utilities
- **Clients/**: Brand-specific implementations
  - **BetssonFR**: France (UAT/PROD variants)
  - **Demo**: Development and testing target
  - **SportRadar**: Alternative provider integration
  - **ArchivedClients/**: Legacy clients (ATP, Crocobet, DAZN, EveryMatrix, PMU, etc.)

**Available Schemes:**
- `Betsson UAT`, `Betsson PROD`
- `Demo`
- `SportRadar UAT`, `SportRadar PROD`

#### 4. **Showcase** (`Showcase/`)
*Independent showcase project*

Demonstration project containing all client configurations for showcasing and testing purposes.

#### 5. **GomaUICatalog** (`Frameworks/GomaUI/GomaUICatalog.xcodeproj`)
*Component testing and preview application*

**Purpose:**
- Live preview and testing of 138 GomaUI components
- Component gallery with different states and configurations
- Snapshot testing environment (50+ components covered)
- Development playground for new component creation

**Available Schemes:**
- `GomaUICatalog`

### Swift Package Ecosystem

#### Core Packages

##### **GomaUI** (`Frameworks/GomaUI/`)
Comprehensive UI component library with **138 reusable components**, organized into feature-based category folders.

**Architecture:**
- Protocol-driven MVVM design pattern
- Centralized theming via StyleProvider and LocalizationProvider
- SwiftUI preview support for UIKit components (PreviewUIView wrapper)
- Comprehensive snapshot testing (50+ components)
- Component metadata catalog (`catalog-metadata.json`)

**Key Component Categories:**
- **Navigation**: AdaptiveTabBarView, CustomNavigationView, QuickLinksTabBar
- **Match Display**: TallOddsMatchCardView, MatchHeaderView, MatchHeaderCompactView
- **Betting Interface**: OutcomeItemView, MarketOutcomesLineView, MarketInfoLineView
- **Forms**: BorderedTextFieldView, PinDigitEntryView, CustomSliderView
- **Filters**: GeneralFilterBarView, SportGamesFilterView, TimeSliderView
- **Feedback**: ToasterView (with scheduler injection pattern)

##### **ServicesProvider** (`Frameworks/ServicesProvider/`)
Backend abstraction layer supporting multiple data providers with 3-layer architecture.

**Supported Providers:**
- **Goma**: Primary provider with REST APIs and WebSocket real-time updates
- **SportRadar**: Alternative provider with Poseidon APIs and socket connections
- **EveryMatrix**: WAMP protocol with entity store architecture and RPC calls

**Provider Protocols:**
- `ManagedContentProvider`: Home templates, banners, promotions
- `EventsProvider`: Sports events, matches, markets, live data
- `BettingProvider`: Bet placement, history, cashout, bonuses, betting options validation
- `PrivilegedAccessManager`: User authentication, profile, payments
- `AnalyticsProvider`: Event tracking and user analytics

**Data Flow:** API Request → Internal Models → Model Mappers → Domain Models → UI

##### **GomaLogger** (`Frameworks/GomaLogger/`) *NEW*
Centralized logging framework with structured logging API.

- Static API with subsystems and categories
- Hierarchical filtering (debug/info/error levels only)
- Pluggable destinations for flexible output

##### **GomaPerformanceKit** (`Frameworks/GomaPerformanceKit/`) *NEW*
Centralized performance monitoring and tracking across all features and layers.

#### Active Utility Packages

##### **Extensions** (`Frameworks/Extensions/`)
Utility library with UI extensions and Combine support.
- UIKit extensions (UIView, UIButton, UIColor)
- Combine publishers and reactive programming helpers
- String and Array utility extensions

##### **RegisterFlow** (`Frameworks/RegisterFlow/`)
Complete customizable registration flow with forms and animations.
- Multi-step registration process
- Lottie animations and custom assets
- Phone number validation (PhoneNumberKit integration)
- Optimove SDK integration

##### **CountrySelectionFeature** (`Frameworks/CountrySelectionFeature/`)
Dedicated country selection interface with phone prefix support.

#### Specialized Packages

##### **AdresseFrancaise** (`Frameworks/AdresseFrancaise/`)
French government address API integration (France-specific).

##### **HeaderTextField** (`Frameworks/HeaderTextField/`)
UITextField wrapper with header labels and currency formatting.

##### **PresentationProvider** (`Frameworks/PresentationProvider/`)
Future CMS-based configuration system (currently placeholder).

##### **GomaPlatform** (`Frameworks/GomaPlatform/`) *NEW*
Platform infrastructure utilities (in early development).

#### Legacy Packages

##### **SharedModels** (`Frameworks/SharedModels/`)
Minimal package containing only Country model.

##### **Theming** (`Frameworks/Theming/`)
Legacy theming system (superseded by GomaUI StyleProvider).

## Build Instructions

### Simulator Setup

**Important:** `xcodebuild` requires specific simulator device IDs, not simulator names.

```bash
# 1. List available simulators to find device IDs
xcrun simctl list devices available | grep -E "iPhone"

# 2. Look for iPhone 15/16 Pro with iOS 17+ and copy the device ID
#    Example output: iPhone 16 Pro (229F70D9-99F6-411E-870A-23C4B153C01E) (Shutdown)

# 3. If no suitable simulator exists, create one:
xcrun simctl create "iPhone 16 Pro" "iPhone 16 Pro" "com.apple.CoreSimulator.SimRuntime.iOS-18-2"
```

### Building Specific Projects

Replace `YOUR_DEVICE_ID` with the actual device ID from `xcrun simctl list devices`.

**GomaUI Component Testing:**
```bash
xcodebuild -workspace Sportsbook.xcworkspace \
  -scheme GomaUICatalog \
  -destination 'platform=iOS Simulator,id=YOUR_DEVICE_ID' \
  build 2>&1 | xcbeautify --quieter
```

**BetssonCameroonApp (Modern Architecture):**
```bash
xcodebuild -workspace Sportsbook.xcworkspace \
  -scheme BetssonCameroonApp \
  -destination 'platform=iOS Simulator,id=YOUR_DEVICE_ID' \
  build 2>&1 | xcbeautify --quieter
```

**BetssonFrance (Modern Architecture):**
```bash
xcodebuild -workspace Sportsbook.xcworkspace \
  -scheme BetssonFrance \
  -destination 'platform=iOS Simulator,id=YOUR_DEVICE_ID' \
  build 2>&1 | xcbeautify --quieter
```

**BetssonFranceLegacy (Legacy Multi-Target):**
```bash
# Development
xcodebuild -workspace Sportsbook.xcworkspace \
  -scheme "Betsson UAT" \
  -destination 'platform=iOS Simulator,id=YOUR_DEVICE_ID' \
  build 2>&1 | xcbeautify --quieter

# Production
xcodebuild -workspace Sportsbook.xcworkspace \
  -scheme "Betsson PROD" \
  -destination 'platform=iOS Simulator,id=YOUR_DEVICE_ID' \
  build 2>&1 | xcbeautify --quieter
```

### Development Workflows

## Development Guidelines

This project follows a strict set of architectural and UI development guidelines to ensure consistency and quality. Please refer to the following documents for more information:

*   **MVVM Architecture**: For a detailed explanation of the MVVM architecture used in this project, please see [Documentation/MVVM.md](Documentation/MVVM.md).
*   **UI Component Guide**: For instructions on how to create new UI components, please see [Documentation/UI_COMPONENT_GUIDE.md](Documentation/UI_COMPONENT_GUIDE.md).

**For New Feature Development:**
1. Use **BetssonCameroonApp** as the reference architecture
2. Leverage **GomaUI** components for consistent UI
3. Test components in **GomaUICatalog** before integration
4. Follow protocol-driven MVVM patterns

**For Legacy Maintenance:**
1. Work within **BetssonFranceApp/Core** for shared functionality
2. Client-specific changes go in respective **Clients/** directories
3. Consider migrating to GomaUI components when possible

## Project Structure Conventions

### Component Architecture (GomaUI)
```
ComponentView/
├── ComponentView.swift              # UIKit implementation
├── ComponentViewModelProtocol.swift # Protocol interface
├── MockComponentViewModel.swift     # Testing/preview mock
└── Documentation/                   # Component documentation
```

### Screen Organization (Modern Apps)
```
ScreenName/
├── ScreenViewController.swift       # Main view controller
├── ScreenViewModel.swift           # View model implementation
├── ScreenViewModelProtocol.swift   # Protocol definition
└── MockScreenViewModel.swift       # Mock for testing/previews
```

## Architectural Migration

### Current State
- **BetssonCameroonApp**: Represents target modern architecture
- **BetssonFranceApp**: Legacy codebase being gradually modernized
- **GomaUI**: Established component library driving consistency

### Migration Strategy
1. **New Development**: Use BetssonCameroonApp patterns
2. **Legacy Updates**: Gradually adopt GomaUI components
3. **Shared Logic**: Extract to Swift packages when appropriate
4. **UI Consistency**: Migrate custom views to GomaUI components

## Dependencies

### External Dependencies

**Firebase Ecosystem (v10.29.0):**
- FirebaseAnalytics, FirebaseAuth, FirebaseCrashlytics
- FirebaseDatabase, FirebaseMessaging
- FirebaseAppCheck, FirebaseRemoteConfig

**Payment Processing:**
- **Adyen iOS** (v5.22.x) - Primary payment processor
- Adyen 3DS2, Authentication, Networking, WeChat Pay
- **Cash App Pay SDK** (v0.6.x)

**Analytics & Marketing:**
- **Optimove SDK** (v6.3.x) - Customer engagement
- **Adjust SDK** (v5.5.x) - Attribution tracking
- **Xtremepush SDK** (v5.10.x) - Push notifications
- Google Ads On-Device Conversion SDK

**Real-time & Networking:**
- **Socket.io-client-swift** (v16.x) - WebSocket connections
- **Starscream** (v4.x) - WebSocket client (custom fork)
- **swift-eventsource** (v3.3.x) - Server-Sent Events (SSE)
- **Reachability.swift** - Network status monitoring

**UI & Media:**
- **Lottie** - Animations
- **Kingfisher** (v7.12.x) - Image caching and loading
- **IQKeyboardManager** (v6.5.x) - Keyboard management

**Localization & Phone:**
- **Phrase SDK** (v5.1.x) - OTA localization with local bundle fallback
- **PhoneNumberKit** (v3.7.x) - Phone number validation

**KYC & Compliance:**
- **IdensicMobileSDK** (v1.40.x) - Identity verification

**Utilities:**
- swift-collections, swift-protobuf, DictionaryCoding, Curry

### Internal Dependencies
All projects use Swift Package Manager for internal dependencies, with clear separation between:
- UI components (GomaUI - 138 components)
- Business logic (ServicesProvider)
- Infrastructure (GomaLogger, GomaPerformanceKit)
- Utilities (Extensions, specialized features)

## Testing

### Unit Testing
- Each Swift package includes comprehensive unit tests
- Mock implementations provided for all protocols (protocol witness pattern)
- Test coverage focuses on business logic and data transformations
- BetssonCameroonApp uses testable architecture with protocol-driven design

### Snapshot Testing
GomaUI includes comprehensive snapshot testing using **swift-snapshot-testing**:
- 50+ components covered with visual regression tests
- Scheduler injection pattern for async Combine operations
- Light/Dark mode variants captured
- Multiple device configurations tested

Run snapshot tests:
```bash
xcodebuild test -workspace Sportsbook.xcworkspace \
  -scheme GomaUICatalog \
  -destination 'platform=iOS Simulator,id=YOUR_DEVICE_ID' \
  2>&1 | xcbeautify --quieter
```

### Integration Testing
- GomaUICatalog provides visual testing for 138 components
- Real device testing recommended for performance validation
- Network layer testing with mock responses

## Development Tools

### Project Tools (`tools/`)

**cWAMP** - cURL-like CLI for WAMP WebSocket interactions:
```bash
# Test EveryMatrix WAMP RPC endpoints
./tools/wamp-client/cwamp call "/sports#tournaments" '{"sportId": 1}'

# Subscribe to live match updates
./tools/wamp-client/cwamp subscribe "/sports/op/en/live-matches"
```

### Recommended External Tools
- [QuickType IO](https://app.quicktype.io/) - JSON to Swift Codable conversion
- [JSONEditorOnline](http://jsoneditoronline.org/) - JSON formatting and validation
- [StackEdit](https://stackedit.io/) - Markdown preview and editing

### Code Quality
- SwiftLint integration (consolidated root config, build fails if not installed)
- Automated formatting and validation
- Protocol-oriented design enforcement

## Documentation

### Development Guides
- **[API Development Guide](Documentation/API_DEVELOPMENT_GUIDE.md)** - Complete guide for adding new API endpoints with proper 3-layer architecture
- **[MVVM Architecture](Documentation/MVVM.md)** - Detailed explanation of the MVVM-C pattern used throughout the project
- **[UI Component Guide](Documentation/UI_COMPONENT_GUIDE.md)** - Instructions for creating new GomaUI components
- **[Testing Guide](Documentation/TESTING_GUIDE.md)** - Testing strategies, mock patterns, and best practices

### Architecture Documentation
- **[ServicesProvider Framework](Documentation/architecture/services_provider.md)** - Backend abstraction layer architecture
- **[Data Flow Diagrams](Documentation/sportsbook-ios-data-flow-diagrams.md)** - Visual representation of data flow patterns

### Release Documentation
- **[BetssonCameroonApp Auto Distribute](BetssonCameroonApp/fastlane/AUTO_DISTRIBUTE.md)** - Tag-based release workflow

### Development Journal
- **[Development Journal](Documentation/DevelopmentJournal/)** - Session-by-session development logs and decision tracking

## Contributing

### Guidelines
- Follow existing architectural patterns
- Use GomaUI components for new UI development
- Maintain protocol-driven design
- Include comprehensive documentation
- Add unit tests for new functionality

### Code Style
- Follow SwiftLint rules
- Use meaningful variable and function names
- Maintain consistent file organization
- Document complex business logic

## Architecture Decisions

### Why Multiple Projects?
- **Scalability**: Different clients have diverging requirements
- **Maintainability**: Clear separation between legacy and modern code
- **Development Speed**: Parallel development on different architectures
- **Risk Management**: Isolated changes reduce cross-project impact

### Why MVVM-C?
- **Coordination**: Coordinators handle navigation, ViewControllers never create Coordinators
- **Testability**: Protocol-driven ViewModels with mock implementations
- **Separation**: Clear boundaries between UI, business logic, and navigation
- **Reusability**: ViewModels and Coordinators can be reused across screens

### Why GomaUI?
- **Consistency**: Unified design system with 138 components across all applications
- **Efficiency**: Reusable components reduce development time
- **Quality**: Snapshot-tested and documented components
- **Flexibility**: Protocol-based design with StyleProvider theming and LocalizationProvider

### Why Dedicated Logging & Performance Packages?
- **GomaLogger**: Centralized logging with debug/info/error levels only (no .warning())
- **GomaPerformanceKit**: Consistent performance tracking across all features
- **Separation**: Infrastructure concerns isolated from business logic

## CI/CD

### GitHub Actions
- **macOS 26 runners** with Swift 6 support
- **SPM caching** for faster builds
- **Automated Jira notifications** on release
- **Discord notifications** with changelog formatting
- **dSYM upload** to Crashlytics for crash symbolication

### Fastlane
- Tag-based release workflow for BetssonCameroonApp
- Dual release workflow support
- Per-environment builds (STG/UAT/PROD)

---

This workspace represents a sophisticated evolution from monolithic to modular architecture, enabling scalable multi-client development while maintaining code quality and consistency through 14 Swift packages and 138 reusable UI components.