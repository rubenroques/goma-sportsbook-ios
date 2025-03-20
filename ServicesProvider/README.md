# ServicesProvider Framework

## Overview

ServicesProvider is a protocol-oriented abstraction layer that provides a unified interface for accessing various backend services in the GOMA Sportsbook iOS application. This framework handles authentication, data fetching, real-time updates, betting operations, and more through a reactive programming model.

## Table of Contents

- [Architecture](#architecture)
- [Key Components](#key-components)
- [Providers](#providers)
- [Data Flow](#data-flow)
- [Authentication](#authentication)
- [Network Layer](#network-layer)
- [Error Handling](#error-handling)
- [Usage Examples](#usage-examples)
- [Extension Points](#extension-points)

## Architecture

ServicesProvider follows a clean protocol-oriented architecture that separates interfaces from implementations:

```
ServicesProvider
├── Protocols (Interfaces)
├── Providers (Implementations)
├── Models (Data structures)
├── Network (Communication layer)
└── Helpers (Utility classes)
```

The core principle is to define clear protocol boundaries that client applications can use without depending on specific implementations. This allows for:

1. **Substitutability**: Different backend implementations can be swapped without changing client code
2. **Testability**: Services can be easily mocked for testing
3. **Decoupling**: UI and business logic remain independent from backend specifics

## Key Components

### ServicesProviderClient

`ServicesProviderClient` serves as the main entry point and facade for all services:

- Manages initialization and configuration of service providers
- Maintains connection state across different services
- Provides access to all service interfaces through a unified API
- Handles provider type selection (SportRadar, EveryMatrix)
- Manages environment configuration (Production, Staging, Development)

### Core Protocol Interfaces

The framework is built around four key service domain protocols:

#### PrivilegedAccessManager

Responsible for all user-related operations:
- Authentication (login, signup)
- User profile management
- Account verification
- Responsible gaming limits
- Document upload and KYC verification
- Payment processing
- Consent management

#### EventsProvider

Handles all sports data operations:
- Sports/competition/event listings
- Real-time event updates
- Market and odds information
- Live data streaming
- Event statistics
- Search functionality
- Favorites management

#### BettingProvider

Manages all betting operations:
- Bet placement
- Bet history retrieval
- Potential returns calculation
- Cashout functionality
- Betslip management
- Bet sharing
- BetBuilder operations

#### AnalyticsProvider

Provides tracking and analytics support:
- User action tracking
- Event recording
- Analytics integration

### Configuration

`ServicesProviderConfiguration` handles environment-specific settings:
- Environment selection (Production, Staging, Development)
- API endpoints management
- Feature flags

## Providers

The framework includes implementations for multiple backend providers:

### SportRadar Implementation

Complete implementation of all service interfaces:
- `SportRadarPrivilegedAccessManager`: Authentication and user management
- `SportRadarEventsProvider`: Sports data and events
- `SportRadarBettingProvider`: Betting operations
- `SportRadarAnalyticsProvider`: Analytics tracking

Includes supporting components:
- `SportRadarSessionCoordinator`: Manages session tokens and authentication state
- `SportRadarConfiguration`: Environment-specific configuration

### EveryMatrix Implementation

Alternative implementation with different backend:
- `EverymatrixProvider`: Combined implementation of service interfaces

## Data Flow

ServicesProvider uses a reactive approach with Combine framework:

1. **Publishers**: Services expose AnyPublisher streams that clients can subscribe to
2. **Real-time Updates**: WebSocket connections deliver live updates through the subscription model
3. **Request-Response**: Standard HTTP requests are wrapped in publishers for consistency

Example data flow:
```
Client App → ServicesProviderClient → EventsProvider → WebSocket/REST API → Backend Services
```

Return data flows:
```
Backend → WebSocketClientStream/NetworkManager → Provider Implementation → Data Models → Client
```

## Authentication

Authentication is handled through the session management system:

1. `PrivilegedAccessManager` provides authentication methods
2. `SportRadarSessionCoordinator` maintains auth tokens
3. Services use tokens from the coordinator for authenticated requests
4. Token refresh is handled automatically when needed
5. Authentication state is exposed through publishers

## Network Layer

The framework includes a comprehensive network layer:

- `NetworkManager`: Handles HTTP requests and responses
- `WebSocketClientStream`: Manages WebSocket connections for real-time data
- `Endpoint`: Protocol defining API endpoints
- `MultipartRequest`: Support for file uploads and multipart requests
- Error handling and response parsing

## Error Handling

ServicesProvider provides a unified error handling approach:

- `ServiceProviderError` enumeration for all service errors
- Error mapping from underlying network/backend errors
- Descriptive error messages
- Proper error propagation through Combine publishers

## Usage Examples

### Initializing the Services Provider

```swift
let configuration = ServicesProviderConfiguration(environment: .production)
let serviceProvider = ServicesProviderClient(providerType: .sportradar, configuration: configuration)
serviceProvider.connect()
```

### Authenticating a User

```swift
serviceProvider.login(username: "user@example.com", password: "password")
    .sink(receiveCompletion: { completion in
        if case .failure(let error) = completion {
            // Handle error
        }
    }, receiveValue: { userProfile in
        // Handle successful login
    })
    .store(in: &cancellables)
```

### Subscribing to Live Events

```swift
serviceProvider.subscribeLiveMatches(forSportType: sportType)
    .sink(receiveCompletion: { completion in
        if case .failure(let error) = completion {
            // Handle error
        }
    }, receiveValue: { content in
        switch content {
        case .initial(let events):
            // Handle initial data
        case .update(let events):
            // Handle update
        case .complete:
            // Handle completion
        }
    })
    .store(in: &cancellables)
```

### Placing a Bet

```swift
serviceProvider.placeBets(betTickets: [betTicket], useFreebetBalance: false)
    .sink(receiveCompletion: { completion in
        if case .failure(let error) = completion {
            // Handle error
        }
    }, receiveValue: { response in
        // Handle successful bet placement
    })
    .store(in: &cancellables)
```

## Extension Points

The framework is designed to be extensible in several ways:

### Adding New Providers

To add a new backend provider:

1. Create a new implementation of the protocol interfaces
2. Add a new provider type to the `ServicesProviderClient.ProviderType` enum
3. Update the `connect()` method to initialize your new provider when selected

### Adding New Functionality

To add new functionality:

1. Extend the appropriate protocol with new methods
2. Implement the new methods in provider implementation classes
3. Expose the new functionality through the client interface

### Custom Data Models

To add custom data models:

1. Create new model classes/structs in the Models directory
2. Ensure they conform to `Codable` for serialization
3. Update provider implementations to use the new models
