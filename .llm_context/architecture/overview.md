# GOMA Sportsbook iOS Architecture Overview

## System Architecture

The GOMA Sportsbook iOS application follows a modular, protocol-oriented architecture that separates core functionality from client-specific implementations. This enables efficient white-labeling while maintaining a consistent core codebase.

```
┌───────────────────────────────────────────────────────────────┐
│                         Client App                            │
│                                                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐   │
│  │ UI Layer    │  │ Screen      │  │ Client-specific     │   │
│  │ Components  │  │ Controllers │  │ Customizations      │   │
│  └─────────────┘  └─────────────┘  └─────────────────────┘   │
│             │            │                   │                │
└─────────────┼────────────┼───────────────────┼────────────────┘
              │            │                   │
┌─────────────┼────────────┼───────────────────┼────────────────┐
│             ▼            ▼                   ▼                │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │                     Core Framework                      │  │
│  │                                                         │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │  │
│  │  │ Models      │  │ Services    │  │ Business Logic  │  │  │
│  │  └─────────────┘  └─────────────┘  └─────────────────┘  │  │
│  │          │               │                  │           │  │
│  └──────────┼───────────────┼──────────────────┼───────────┘  │
│             │               │                  │              │
└─────────────┼───────────────┼──────────────────┼───────────────┘
              │               │                  │
┌─────────────┼───────────────┼──────────────────┼───────────────┐
│             ▼               ▼                  ▼               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │               ServicesProvider Framework                │   │
│  │                                                         │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │   │
│  │  │ Network     │  │ Protocol    │  │ Provider        │  │   │
│  │  │ Layer       │  │ Interfaces  │  │ Implementations │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────────┘  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                               │                                 │
└───────────────────────────────┼─────────────────────────────────┘
                                │
                                ▼
                      ┌───────────────────┐
                      │  Backend Services │
                      └───────────────────┘
```

## Key Design Principles

1. **Modularity**: The application is divided into distinct modules with specific responsibilities.

2. **Protocol-Oriented**: Interfaces are defined as protocols, allowing different implementations to be swapped without affecting client code.

3. **Reactive Programming**: Uses Combine framework for data flow and asynchronous operations.

4. **MVVM+Coordinator**: UI layer follows MVVM pattern with coordinators handling navigation flow.

5. **White-label Architecture**: Core functionality is separated from brand-specific customizations.

## Core Components

### 1. Core Framework

Contains shared functionality used across all client implementations:

- **App**: Bootstrap, routing, environment configuration
- **Models**: Data structures for the application domain
- **Services**: Business logic and service implementations
- **Screens**: View controllers and UI components
- **Views**: Reusable UI elements
- **Constants**: Shared configuration values
- **Tools**: Utilities and extensions

### 2. ServicesProvider Framework 

Abstracts communication with backend services:

- **Protocol Interfaces**: Defines service boundaries 
- **Provider Implementations**: Concrete implementations for different backend systems
- **Models**: Data transfer objects and domain entities
- **Network Layer**: Communication infrastructure
- **Helpers**: Utility classes for common operations

### 3. Client Implementations

Brand-specific customizations:

- **Assets**: Brand-specific images and resources
- **Configuration**: Environment and feature settings
- **Launch Screen**: Custom launch experience
- **Target Variables**: Build-time configuration

## Data Flow Architecture

The application follows a unidirectional data flow:

1. **UI Events**: User actions trigger events in the UI layer
2. **Business Logic**: Core services process these events
3. **API Calls**: ServicesProvider makes network requests
4. **State Updates**: Response data updates application state
5. **UI Updates**: UI reacts to state changes via Combine publishers

## Authentication System

The authentication system uses token-based authentication:

- **PrivilegedAccessManager**: Handles user authentication
- **Session Coordinator**: Manages authentication tokens
- **Secure Storage**: Tokens stored in the Keychain
- **Auto-refresh**: Automatic token refresh when needed

## Dependency Management

The project uses a combination of:

- **Swift Package Manager**: For modular packages
- **CocoaPods**: For third-party dependencies
- **Internal Frameworks**: For code sharing between components

## Key Technology Choices

- **UIKit + SwiftUI**: Hybrid approach with UIKit for foundation and SwiftUI for newer components
- **Combine**: For reactive programming
- **CoreLocation**: For geolocation services
- **WebKit**: For embedded web content
- **SwiftLint**: For code style enforcement
- **Fastlane**: For CI/CD automation 