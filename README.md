# GOMA Gaming Sportsbook - iOS Workspace

A sophisticated multi-project iOS workspace for sports betting applications, featuring modular architecture with multiple branded app targets and a comprehensive UI component library.

## Requirements

* Xcode 15.0+
* iOS 15.0+
* [SwiftLint](https://github.com/realm/SwiftLint)
* [Fastlane](https://docs.fastlane.tools/) (optional)

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

This workspace contains **three main projects** and **ten Swift packages**, organized for scalable multi-client development:

### Main Projects

#### 1. **BetssonFranceApp** (`BetssonFranceApp/Sportsbook.xcodeproj`)
*Legacy multi-target project - 80% of the codebase*

**Structure:**
- **Core/**: Shared application logic, screens, services, and utilities
- **Clients/**: Brand-specific implementations for multiple markets
  - **BetssonCM**: Cameroon (DEV/STG/PROD variants)
  - **BetssonFR**: France (UAT/PROD variants)
  - **Demo**: Development and testing target
  - **SportRadar**: Alternative provider integration
  - **ArchivedClients/**: Legacy clients (ATP, Crocobet, DAZN, PMU, etc.)

**Available Schemes:**
- `BetssonCM DEV`, `BetssonCM STG`, `BetssonCM PROD`
- `Betsson UAT`, `Betsson PROD`
- `Demo`
- `SportRadar UAT`, `SportRadar PROD`

#### 2. **BetssonCameroonApp** (`BetssonCameroonApp/BetssonCameroonApp.xcodeproj`)
*Modern standalone project - Target architecture*

**Key Features:**
- Clean, modern iOS project structure
- Heavy integration with GomaUI component library
- Protocol-driven MVVM architecture with mock support
- Direct Swift Package Manager dependencies
- Streamlined development approach

**Available Schemes:**
- `BetssonCameroonApp`

#### 3. **GomaUICatalog** (`Frameworks/GomaUI/GomaUICatalog.xcodeproj`)
*Component testing and preview application*

**Purpose:**
- Live preview and testing of GomaUI components
- Component gallery with different states and configurations
- Development playground for new component creation
- Integration testing environment

**Available Schemes:**
- `GomaUICatalog`

### Swift Package Ecosystem

#### Core Packages

##### **GomaUI** (`Frameworks/GomaUI/`)
Comprehensive UI component library with 50+ reusable components.

**Architecture:**
- Protocol-driven MVVM design pattern
- Centralized theming via StyleProvider
- SwiftUI preview support for UIKit components
- Comprehensive component documentation

**Key Components:**
- **Navigation**: AdaptiveTabBarView, CustomNavigationView, QuickLinksTabBar
- **Match Display**: TallOddsMatchCardView, MatchHeaderView, MatchHeaderCompactView
- **Betting Interface**: OutcomeItemView, MarketOutcomesLineView, MarketInfoLineView
- **Forms**: BorderedTextFieldView, PinDigitEntryView, CustomSliderView
- **Filters**: GeneralFilterBarView, SportGamesFilterView, TimeSliderView

##### **ServicesProvider** (`Frameworks/ServicesProvider/`)
Backend abstraction layer supporting multiple data providers.

**Supported Providers:**
- **Goma**: Primary provider with REST APIs and WebSocket real-time updates
- **SportRadar**: Alternative provider with Poseidon APIs and socket connections
- **EveryMatrix**: WAMP protocol with entity store architecture

**Provider Protocols:**
- `ManagedContentProvider`: Home templates, banners, promotions
- `EventsProvider`: Sports events, matches, markets, live data
- `BettingProvider`: Bet placement, history, cashout, bonuses
- `PrivilegedAccessManager`: User authentication, profile, payments
- `AnalyticsProvider`: Event tracking and user analytics

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
- Phone number validation and country selection

##### **CountrySelectionFeature** (`Frameworks/CountrySelectionFeature/`)
Dedicated country selection interface with phone prefix support.

#### Specialized Packages

##### **AdresseFrancaise** (`Frameworks/AdresseFrancaise/`)
French government address API integration (France-specific).

##### **HeaderTextField** (`Frameworks/HeaderTextField/`)
UITextField wrapper with header labels and currency formatting.

##### **PresentationProvider** (`Frameworks/PresentationProvider/`)
Future CMS-based configuration system (currently placeholder).

#### Legacy Packages

##### **SharedModels** (`Frameworks/SharedModels/`)
Minimal package containing only Country model.

##### **Theming** (`Frameworks/Theming/`)
Legacy theming system (superseded by GomaUI StyleProvider).

## Build Instructions

### Building Specific Projects

**GomaUI Component Testing:**
```bash
xcodebuild -workspace Sportsbook.xcworkspace -scheme GomaUICatalog -destination 'platform=iOS Simulator,name=iPhone 16' build
```

**BetssonCameroonApp (Modern Architecture):**
```bash
xcodebuild -workspace Sportsbook.xcworkspace -scheme BetssonCameroonApp -destination 'platform=iOS Simulator,name=iPhone 16' build
```

**BetssonFranceApp (Legacy Multi-Target):**
```bash
# Development
xcodebuild -workspace Sportsbook.xcworkspace -scheme "Betsson UAT" -destination 'platform=iOS Simulator,name=iPhone 16' build

# Production
xcodebuild -workspace Sportsbook.xcworkspace -scheme "Betsson PROD" -destination 'platform=iOS Simulator,name=iPhone 16' build
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
- **Firebase**: Analytics, Auth, Crashlytics, Database, Messaging
- **IQKeyboardManagerSwift**: Keyboard management
- **Reachability**: Network status monitoring
- **PhraseSDK**: Localization management
- **Lottie**: Animations (via packages)

### Internal Dependencies
All projects use Swift Package Manager for internal dependencies, with clear separation between:
- UI components (GomaUI)
- Business logic (ServicesProvider)
- Utilities (Extensions, specialized features)

## Testing

### Unit Testing
- Each Swift package includes comprehensive unit tests
- Mock implementations provided for all protocols
- Test coverage focuses on business logic and data transformations

### Integration Testing
- GomaUICatalog provides visual testing for components
- Real device testing recommended for performance validation
- Network layer testing with mock responses

## Development Tools

### Recommended Tools
- [QuickType IO](https://app.quicktype.io/) - JSON to Swift Codable conversion
- [JSONEditorOnline](http://jsoneditoronline.org/) - JSON formatting and validation
- [StackEdit](https://stackedit.io/) - Markdown preview and editing

### Code Quality
- SwiftLint integration for style consistency
- Automated formatting and validation
- Protocol-oriented design enforcement

## Documentation

### Development Guides
- **[API Development Guide](Documentation/API_DEVELOPMENT_GUIDE.md)** - Complete guide for adding new API endpoints with proper 3-layer architecture
- **[MVVM Architecture](Documentation/MVVM.md)** - Detailed explanation of the MVVM pattern used throughout the project
- **[UI Component Guide](Documentation/UI_COMPONENT_GUIDE.md)** - Instructions for creating new GomaUI components

### Architecture Documentation
- **[ServicesProvider Framework](Documentation/architecture/services_provider.md)** - Backend abstraction layer architecture
- **[Data Flow Diagrams](Documentation/sportsbook-ios-data-flow-diagrams.md)** - Visual representation of data flow patterns

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

### Why GomaUI?
- **Consistency**: Unified design system across all applications
- **Efficiency**: Reusable components reduce development time
- **Quality**: Thoroughly tested and documented components
- **Flexibility**: Protocol-based design allows customization

This workspace represents a sophisticated evolution from monolithic to modular architecture, enabling scalable multi-client development while maintaining code quality and consistency.