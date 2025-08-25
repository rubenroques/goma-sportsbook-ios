# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Behaviour
<IMPORTANT>
 In this conversation, treat yourself as my senior colleague—someone I rely on for critical, thoughtful, and sometimes challenging feedback. Your primary goal isn't agreement; it's to provide honest assessments, ask probing questions, suggest alternatives, and discuss technical or architectural decisions thoroughly. Avoid defaulting to "yes" or passive validation. Your critical perspective is essential to our collaboration and directly impacts the quality and outcome of our work together. do not be a yes man.
</IMPORTANT>

## Overview

This is a **sophisticated multi-project iOS workspace** for sports betting applications, featuring a modular architecture that has evolved from a single monolithic project into three distinct projects with a comprehensive Swift package ecosystem. The workspace enables rapid multi-client deployment while maintaining code consistency through shared UI components and backend abstractions.

## Workspace Architecture

The workspace follows a **multi-project + Swift Package** architecture designed for scalable white-label development:

### Core Projects Structure

#### **1. BetssonFranceApp** (`BetssonFranceApp/Sportsbook.xcodeproj`)
*Legacy multi-target project containing 80% of the codebase*

- **Architecture**: Monolithic Core + Multi-Client targeting
- **Core Framework** (`BetssonFranceApp/Core/`): Shared application logic, 40+ screens, services, and utilities
- **Client Layer** (`BetssonFranceApp/Clients/`): Brand-specific implementations for multiple markets
- **Pattern**: 90% MVVM with mixed legacy and modern approaches (no Coordinator)
- **Complexity**: 977 directories, 3425 files - represents technical complexity and architectural evolution

#### **2. BetssonCameroonApp** (`BetssonCameroonApp/BetssonCameroonApp.xcodeproj`)  
*Modern standalone project representing target architecture*

- **Architecture**: Clean iOS project with heavy GomaUI integration
- **Pattern**: Protocol-driven MVVM with comprehensive mock support
- **Complexity**: 253 directories, 646 files - streamlined and focused
- **Key Features**: Direct Swift Package dependencies, modern project organization, GomaUI StyleProvider theming

#### **3. GomaUIDemo** (`Frameworks/GomaUI/GomaUIDemo.xcodeproj`)
*Component testing and preview application*

- **Purpose**: Live component gallery, development playground, integration testing
- **Architecture**: Dedicated testing app with 50+ component controllers
- **Usage**: Essential for GomaUI component development and validation

### Swift Package Ecosystem

#### **Core Packages**

##### **GomaUI** (`Frameworks/GomaUI/`)
*Comprehensive UI component library - 204 directories, 528 files*

**Architecture Pattern** (consistent across 50+ components):
```
ComponentView/
├── ComponentView.swift              # UIKit implementation
├── ComponentViewModelProtocol.swift # Protocol interface
├── MockComponentViewModel.swift     # Testing/preview mock
└── Documentation/                   # Component documentation
```

**Key Features**:
- Protocol-driven MVVM design enabling flexible implementations
- StyleProvider system for centralized theming and customization
- SwiftUI preview support via PreviewUIView wrapper
- Reactive programming with Combine publishers
- Comprehensive component documentation

**Component Categories**:
- **Navigation**: AdaptiveTabBarView, CustomNavigationView, QuickLinksTabBar
- **Match Display**: TallOddsMatchCardView, MatchHeaderView, MatchHeaderCompactView
- **Betting Interface**: OutcomeItemView, MarketOutcomesLineView, MarketInfoLineView
- **Forms & Input**: BorderedTextFieldView, PinDigitEntryView, CustomSliderView
- **Filters & Search**: GeneralFilterBarView, SportGamesFilterView, TimeSliderView

##### **ServicesProvider** (`Frameworks/ServicesProvider/`)
*Backend abstraction layer - 144 directories, 404 files*

**Multi-Provider Architecture**:
- **Goma Provider**: Primary provider with REST APIs and WebSocket real-time updates
- **SportRadar Provider**: Alternative provider with Poseidon APIs and socket connections  
- **EveryMatrix Provider**: WAMP protocol with sophisticated entity store architecture

**Provider Protocols**:
- `ManagedContentProvider`: Home templates, banners, promotions, news
- `EventsProvider`: Sports events, matches, markets, live data subscriptions
- `BettingProvider`: Bet placement, history, cashout, bonus management
- `PrivilegedAccessManager`: User authentication, profile, payments, KYC
- `AnalyticsProvider`: Event tracking and user analytics

**Data Flow Architecture**:
```
API Request → Internal Models → Model Mappers → Domain Models → UI Components
```

#### **Active Utility Packages**

- **Extensions** (`Frameworks/Extensions/`): UI extensions, Combine helpers, utility protocols
- **RegisterFlow** (`Frameworks/RegisterFlow/`): Complex feature with multi-step registration process
- **CountrySelectionFeature** (`Frameworks/CountrySelectionFeature/`): Focused feature module
- **AdresseFrancaise** (`Frameworks/AdresseFrancaise/`): France-specific address lookup API client

#### **Legacy/Minimal Packages**

- **SharedModels** (`Frameworks/SharedModels/`): Minimal (only Country model)
- **Theming** (`Frameworks/Theming/`): Legacy theming (superseded by GomaUI StyleProvider)
- **HeaderTextField** (`Frameworks/HeaderTextField/`): Simple UITextField wrapper
- **PresentationProvider** (`Frameworks/PresentationProvider/`): Future CMS system (placeholder)

## Build System & Commands

### Workspace Build Structure

**Working Directory**: Always `/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios`
**Workspace**: `Sportsbook.xcworkspace` (contains all projects and packages)

### Build Commands Reference

**GomaUI Component Testing**:
```bash
cd /Users/rroques/Desktop/GOMA/iOS/sportsbook-ios
xcodebuild -workspace Sportsbook.xcworkspace -scheme DemoGomaUI -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | xcbeautify --quieter
```

**BetssonCameroonApp (Modern Architecture)**:
```bash
cd /Users/rroques/Desktop/GOMA/iOS/sportsbook-ios
xcodebuild -workspace Sportsbook.xcworkspace -scheme BetssonCameroonApp -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | xcbeautify --quieter
```

**BetssonFranceApp (Legacy Multi-Target)**:
```bash
cd /Users/rroques/Desktop/GOMA/iOS/sportsbook-ios
# Development schemes
xcodebuild -workspace Sportsbook.xcworkspace -scheme "Betsson UAT" -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | xcbeautify --quieter
xcodebuild -workspace Sportsbook.xcworkspace -scheme "Demo" -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | xcbeautify --quieter

# Production schemes  
xcodebuild -workspace Sportsbook.xcworkspace -scheme "Betsson PROD" -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | xcbeautify --quieter
```

### Available Schemes by Project

**BetssonFranceApp**:
- `BetssonCM DEV`, `BetssonCM STG`, `BetssonCM PROD` (Cameroon variants)
- `Betsson UAT`, `Betsson PROD` (France variants)
- `Demo` (Demo target with some feature no client has enabled like chat and rankings)
- `SportRadar UAT`, `SportRadar PROD` (Alternative provider target)

**BetssonCameroonApp**:
- `BetssonCameroonApp` (Single modern target)

**GomaUIDemo**:
- `DemoGomaUI` (Demo APP for the GomaUI Swift Package, for testing and preview in the simulator the components)

### Build Context Guidelines

- **DemoGomaUI**: Use for testing GomaUI components in isolation
- **BetssonCameroonApp**: Camerron Client, use as reference for modern architecture patterns
- **Betsson UAT**: France Client, default development scheme for legacy codebase work
- **Demo**: Use for general development, testing on new features that no client uses, with multiple provider support

**Mandatory Requirements**:
- Always use `xcbeautify --quieter` for LLM-readable output
- Standard destination: `platform=iOS Simulator,name=iPhone 16`
- Working directory: `/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios`

## Development Guidance

### Architectural Principles

1.  **Project Selection Strategy**:
    *   **New Development**: Use BetssonCameroonApp patterns and architecture
    *   **Legacy Maintenance**: Work within BetssonFranceApp while migrating to modern patterns
    *   **Component Development**: Use GomaUIDemo for testing and validation

*For a detailed explanation of the MVVM architecture, refer to [Documentation/MVVM.md](Documentation/MVVM.md).*

2.  **UI Development Guidelines**:
    *   **Always prefer GomaUI components** over custom UI implementations
    *   Use StyleProvider for all theming and customization
    *   Follow protocol-driven MVVM pattern with mock implementations
    *   Include SwiftUI previews (that render UIKit) for rapid development iteration

*For instructions on how to create new UI components, refer to [Documentation/UI_COMPONENT_GUIDE.md](Documentation/UI_COMPONENT_GUIDE.md).*

3. **Backend Integration**:
   - Use ServicesProvider protocols for all backend communication
   - Never directly integrate with APIs - use provider abstractions
   - Leverage provider switching capabilities for multi-client support

### Code Organization Patterns

#### **Modern Screen Architecture** (BetssonCameroonApp style):
```
ScreenName/
├── ScreenViewController.swift       # Main view controller with GomaUI integration
├── ScreenViewModelProtocol.swift   # Protocol defining interface
├── ScreenViewModel.swift           # Production implementation
└── MockScreenViewModel.swift       # Testing/preview mock
```

#### **Component Integration Pattern**:
```swift
// Always use GomaUI components
import GomaUI

class ModernViewController: UIViewController {
    private let viewModel: ScreenViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // Use GomaUI components
    private lazy var headerView = MatchHeaderCompactView(viewModel: viewModel.headerViewModel)
    private lazy var outcomeView = MarketOutcomesLineView(viewModel: viewModel.outcomesViewModel)
    
    // Reactive binding with Combine
    private func setupBindings() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state: state)
            }
            .store(in: &cancellables)
    }
}
```

### Important Memories & Guidelines

#### **Project Architecture**:
- **Multi-project workspace**: Not a single project anymore
- **GomaUI**: Established component library with 50+ components
- **BetssonCameroonApp**: Target architecture for new development
- **BetssonFranceApp**: Legacy codebase requiring gradual modernization

#### **UI Development**:
- **UIKit Only**: No SwiftUI views - use GomaUI components instead
- **StyleProvider Mandatory**: Never hardcode colors/fonts - always use StyleProvider theming
- **Protocol-Driven**: All components use protocol-based ViewModels with mocks
- **Preview Support**: Include SwiftUI previews using PreviewUIView wrapper

#### **Code Quality**:
- **Swift Package Structure**: Each package must be manually added to Xcode project
- **Dependency Management**: Use Swift Package Manager for internal dependencies
- **Testing**: Comprehensive mock implementations for all protocols
- **Documentation**: Each GomaUI component includes dedicated documentation

## Debugging & Development Workflow

### Systematic Investigation Process

1. **Observe**: Document symptoms vs root causes
2. **Isolate**: Determine if issue is in GomaUI, ServicesProvider, or app-specific code
3. **Test**: Use appropriate project/scheme for testing (GomaUIDemo for UI, BetssonCameroonApp for modern patterns)
4. **Verify**: Ensure fixes work across relevant projects

### Debugging Tools by Problem Type

- **UI/Layout Issues**: Test in GomaUIDemo, check StyleProvider configuration, verify constraint setup
- **Data Flow Issues**: Check ServicesProvider integration, verify protocol implementations, test with mocks
- **Build Issues**: Verify workspace dependencies, check scheme configurations, ensure Swift Package integration
- **Performance Issues**: Profile in appropriate target, check reactive binding patterns, verify memory management

### Development Environment Setup

- **Primary Development**: BetssonCameroonApp for new features
- **Component Development**: GomaUIDemo for UI component work  
- **Legacy Maintenance**: BetssonFranceApp with gradual migration to modern patterns
- **Testing**: Use mock implementations extensively for isolated testing

## Migration Strategy

### Current Architectural State

- **BetssonCameroonApp**: Modern architecture (target state)
- **BetssonFranceApp**: Legacy architecture (migration source)
- **GomaUI**: Established component library (architectural foundation)
- **ServicesProvider**: Mature backend abstraction (stable foundation)

### Development Approach

1. **New Features**: Implement in BetssonCameroonApp first, then adapt for BetssonFranceApp if needed
2. **UI Updates**: Migrate custom views to GomaUI components when possible
3. **Backend Changes**: Work through ServicesProvider protocols - never directly modify API clients
4. **Shared Logic**: Extract common functionality to appropriate Swift packages

### Technical Debt Management

- **BetssonFranceApp Complexity**: Over 970 directories indicate significant technical complexity
- **Screen Proliferation**: 40+ screens suggest need for consolidation
- **Mixed Patterns**: Gradual migration from legacy patterns to protocol-driven architecture
- **Package Optimization**: Some packages (SharedModels, Theming) need consolidation or deprecation

## MCP Server Tools

### Available MCP Servers

This workspace has two specialized MCP (Model Context Protocol) servers configured:

#### **1. SwiftLens** (`mcp__swiftlens__*`)
*Compiler-accurate Swift code analysis using SourceKit-LSP*

**Core Capabilities**:
- **Symbol Analysis**: Parse and understand Swift AST with compiler accuracy
- **Cross-file References**: Find all usages of symbols across entire codebase
- **Type-aware Navigation**: Jump to exact definitions, understand protocols and inheritance
- **Code Modification**: Safely replace symbol bodies while preserving signatures
- **Pattern Search**: Regex-based searches with line/character positions

**When to Use SwiftLens**:
- Finding all references to a class, method, or property across the codebase
- Navigating to exact symbol definitions (not just text matches)
- Understanding type relationships, protocol conformances, inheritance chains
- Refactoring symbol implementations (rename, replace method bodies)
- Getting accurate symbol counts and file structure
- Validating Swift syntax and compilation errors

**Example Use Cases**:
```bash
# Find all references to a ViewModel across the project
mcp__swiftlens__swift_find_symbol_references_files

# Get detailed symbol structure of a file
mcp__swiftlens__swift_analyze_files

# Replace a method implementation
mcp__swiftlens__swift_replace_symbol_body

# Validate Swift file compilation
mcp__swiftlens__swift_validate_file
```

#### **2. iOS Simulator MCP** (`mcp__ios-simulator-mcp__*`)
*Automated iOS Simulator interaction and UI testing*

**Core Capabilities**:
- **UI Interaction**: Tap, swipe, type text into simulator
- **Accessibility Testing**: Describe UI elements and screen structure
- **Visual Capture**: Take screenshots, record videos
- **Element Inspection**: Get information about UI elements at coordinates

**When to Use iOS Simulator MCP**:
- Automated UI testing and validation
- Capturing screenshots for documentation
- Testing user flows and interactions
- Accessibility compliance verification
- Visual regression testing
- Debugging UI layout issues

**Example Use Cases**:
```bash
# Take a screenshot of current screen
mcp__ios-simulator-mcp__screenshot

# Tap on specific coordinates
mcp__ios-simulator-mcp__ui_tap

# Get accessibility description of entire screen
mcp__ios-simulator-mcp__ui_describe_all

# Input text into focused field
mcp__ios-simulator-mcp__ui_type
```

### SwiftLens vs Built-in Tools Decision Matrix

| Task | Use SwiftLens | Use Built-in Tools |
|------|---------------|-------------------|
| Find all symbol references | ✅ Precise, cross-file | ❌ Text-based, may miss |
| Read full file contents | ❌ Only symbols | ✅ Complete context |
| Navigate to definitions | ✅ Type-aware | ⚠️ Text search |
| Search comments/TODOs | ❌ Code only | ✅ All text |
| Understand business logic | ❌ Structure only | ✅ Full implementation |
| Refactor symbol names | ✅ Safe, precise | ⚠️ Manual verification |
| Edit multiple files | ⚠️ Limited | ✅ Full flexibility |
| Non-Swift files | ❌ Swift only | ✅ Any file type |
| Quick exploration | ❌ Needs index | ✅ Immediate |

### MCP Setup & Maintenance

**Index Building** (Required after significant changes):
```bash
# Build SwiftLens index for BetssonCameroonApp
xcodebuild -workspace Sportsbook.xcworkspace \
  -scheme "BetssonCameroonApp" \
  -configuration Debug \
  build \
  COMPILER_INDEX_STORE_ENABLE=YES \
  INDEX_ENABLE_DATA_STORE=YES \
  -derivedDataPath .build
```

**When to Rebuild Index**:
- After adding new Swift files
- After changing public interfaces
- When symbol references seem incomplete
- After major refactoring

**Configuration Location**: `.mcp.json` in project root

## Tool Usage Guidelines

### When to Use Concurrent Tool Calls

- Reading multiple project files simultaneously (e.g., BetssonCameroonApp + BetssonFranceApp + GomaUI)
- Adding debug code across multiple packages in same investigation
- Running parallel bash commands for different schemes/targets
- Gathering information from multiple Swift packages concurrently
- Combining SwiftLens analysis with built-in file reading for complete context

### Workspace-Specific Operations

- **Always specify workspace**: Use `Sportsbook.xcworkspace` for all operations
- **Scheme-specific work**: Choose appropriate scheme based on development context
- **Package dependency**: Remember manual Xcode project integration for new Swift packages
- **Multi-project impact**: Consider changes across BetssonCameroonApp and BetssonFranceApp
- **MCP Integration**: Use SwiftLens for precise Swift operations, built-in tools for exploration

## cWAMP - WebSocket WAMP Client Tool

### Overview

**cWAMP** (`tools/wamp-client/`) is a cURL-like command-line tool for interacting with WAMP (WebSocket Application Messaging Protocol) servers, specifically designed for the EveryMatrix sports betting API.

### Installation & Setup

```bash
# Install globally
cd tools/wamp-client
npm install -g .

# Configure (creates ~/.cwamp.env)
cp .cwamp.env.example ~/.cwamp.env
# Edit ~/.cwamp.env with your credentials
```

### Usage Examples

```bash
# Test connection
cwamp test

# Make RPC calls (like cURL for WAMP)
cwamp rpc -p "/sports#tournaments" -k '{"lang":"en","sportId":"1"}' --pretty

# Subscribe to real-time updates
cwamp subscribe -t "/sports/1/en/live-matches" -d 5000 --max-messages 10

# Interactive mode for exploration
cwamp interactive

# With verbose logging
cwamp rpc -p "/sports#operatorInfo" --verbose --timestamp
```

### Key Features

- **RPC Calls**: Execute remote procedures on WAMP server
- **Subscriptions**: Listen to real-time WebSocket updates
- **Configuration Override**: Use `--url`, `--realm`, `--cid` to override defaults
- **Structured Logging**: `--verbose` for RPC tracking, `--debug` for full WAMP messages
- **Environment Flexibility**: Supports `.cwamp.env` in current dir, home dir, or project

### Common EveryMatrix Endpoints

**RPC Procedures:**
- `/sports#tournaments` - Get tournaments for a sport
- `/sports#matches` - Get match details
- `/sports#odds` - Get betting odds
- `/sports#searchV2` - Search for events

**Subscription Topics:**
- `/sports/{op}/{lang}/live-matches-aggregator-main/{sport}/...` - Live match updates
- `/sports/{op}/{lang}/{matchId}/match-odds` - Specific match odds updates

### When to Use cWAMP

- **API Testing**: Quick verification of EveryMatrix WebSocket endpoints
- **Real-time Monitoring**: Subscribe to live match updates during development
- **Data Exploration**: Use interactive mode to explore available endpoints
- **Debugging**: Verbose/debug modes help troubleshoot WebSocket issues
- **Automation**: Script WebSocket interactions just like cURL scripts for HTTP

## Root Cause Analysis Framework

### Project-Specific Debugging

1. **GomaUI Issues**: Test in GomaUIDemo, check component protocol implementations
2. **ServicesProvider Issues**: Verify provider configurations, check protocol conformance
3. **BetssonCameroonApp Issues**: Modern patterns - check protocol bindings, StyleProvider usage
4. **BetssonFranceApp Issues**: Legacy patterns - check for mixed architectural approaches

### Systematic Approach

- **Symptoms**: UI rendering, data loading, navigation, build failures
- **Root Causes**: Component misconfiguration, provider integration, architectural mixing, dependency issues
- **Resolution**: Fix at appropriate architectural layer (UI → GomaUI, Data → ServicesProvider, App → specific project)

This workspace represents a sophisticated evolution from monolithic to modular architecture, enabling scalable multi-client development while maintaining code quality through established component libraries and backend abstractions.