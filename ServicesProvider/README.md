# ServicesProvider

## Overview

The ServicesProvider package is a core component of the GOMA iOS application that handles all external API communication and data transformation. It follows a clean architecture pattern that separates API data models from domain models, providing a robust and maintainable interface for the application to consume remote data.

## Architecture

The package implements a layered architecture with clear separation of concerns:

```
API Request → Internal GomaModels → GomaModelMapper → Domain Models
```

### Key Components

#### API Clients
- **GomaPromotionsAPIClient**: Handles all HTTP requests to the promotions endpoints
- **GomaAPIAuthenticator**: Manages authentication tokens for API requests

#### Content Providers
- **ManagedContentProvider**: Protocol defining the interface for content retrieval
- **GomaManagedContentProvider**: Implementation of the provider that coordinates API requests and data transformation

#### Models
- **Internal Models** (`GomaModels+*.swift`): Direct representations of API JSON responses
- **Domain Models** (`HomeTemplate.swift`, `Banner.swift`, etc.): Clean models used by the application UI

#### Mappers
- **GomaModelMapper**: Transforms internal API models into domain models

## Provider Protocols

The package is organized around several provider protocols that define clear interfaces for different aspects of the application:

### Connector
The base protocol for all providers that maintain a connection state:
- Provides a publisher for connection state changes (connected/disconnected)
- Serves as the foundation for other provider protocols

### ManagedContentProvider
Handles retrieval of promotional and templated content:
- **Home Template**: Configuration for the home screen layout
- **Alert Banners**: Time-sensitive notifications
- **Banners**: Promotional banners for marketing campaigns
- **Sport Banners**: Sport-specific promotional content
- **Boosted Odds Banners**: Special odds promotions
- **Hero Cards**: Featured promotional content
- **Stories**: Ephemeral promotional content
- **News**: Articles and updates with pagination support
- **Pro Choices**: Expert betting tips

### AnalyticsProvider
Manages tracking of user events and interactions:
- Tracks events with optional user identification
- Supports custom event types with associated data

### BettingProvider
Handles all betting-related operations:
- Bet history and details retrieval
- Bet placement and calculation
- Cashout functionality
- Freebet and bonus management
- Shared ticket functionality

### EventsProvider
Manages sports events data:
- Live and pre-live match subscriptions
- Sport types and competition data
- Market and outcome information
- Event details and statistics
- Favorites management

### PrivilegedAccessManager
Handles user authentication and account management:
- User login and registration
- Profile management
- Payment processing
- Responsible gaming limits
- KYC verification
- Social features (friends, followers)

### PromotionsProvider
Manages promotional content and campaigns:
- User session management
- Device identification
- Anonymous and authenticated access to promotions
- Sign-up through promotions

## Provider Implementations

The package includes implementations for different backend systems:

### Goma Providers
- **GomaManagedContentProvider**: Implements the ManagedContentProvider protocol for the Goma API
- **GomaAPIClient**: Base client for Goma API requests
- **GomaConnector**: Manages connection state for Goma services

### Sportsradar Providers
- **SportRadarManagedContentProvider**: Alternative implementation for Sportsradar backend
- **SportRadarBettingProvider**: Handles betting operations through Sportsradar
- **SportRadarEventsProvider**: Manages sports events data from Sportsradar
- **SportRadarAnalyticsProvider**: Tracks analytics through Sportsradar

## Service Provider Client

The **ServicesProviderClient** class serves as the main entry point for the application:
- Initializes and configures the appropriate providers based on configuration
- Provides a unified interface to access all provider functionality
- Manages connection state and authentication
- Handles provider switching and reconnection

## Data Flow

1. **API Request Stage**:
   - The application requests data through the `ManagedContentProvider` interface
   - `GomaManagedContentProvider` initiates an API request using `GomaPromotionsAPIClient`
   - Authentication is applied via `GomaAPIAuthenticator`

2. **Internal Model Decoding Stage**:
   - JSON responses are decoded into internal `GomaModels` structs
   - These models directly map to the API's JSON structure

3. **Model Transformation Stage**:
   - `GomaModelMapper` transforms internal models to domain models
   - Data types are converted, optionals are handled, and structures are made app-friendly

4. **Domain Model Return Stage**:
   - Clean domain models are returned to the application via Combine publishers

## Supported Endpoints

The package supports multiple content endpoints:

- Home Template
- Alert Banners
- Banners
- Sport Banners
- Boosted Odds Banners
- Hero Cards
- Stories
- News (with pagination)
- Pro Choices

## Usage Example

```swift
// Access the managed content provider
let contentProvider: ManagedContentProvider = GomaManagedContentProvider()

// Request home template data
contentProvider.getHomeTemplate()
    .sink(
        receiveCompletion: { completion in
            // Handle completion
        },
        receiveValue: { homeTemplate in
            // Use the domain model
        }
    )
    .store(in: &cancellables)
```

## Testing

The package includes comprehensive tests:

- **Unit Tests**: Test individual components in isolation
- **Integration Tests**: Verify the entire flow from API request to domain model
- **Mock Responses**: Real API responses are captured and stored as JSON files for testing

For detailed information on the integration testing approach, see the [Integration Tests documentation](Docs/IntegrationTests.md).

## Dependencies

- **Combine**: Used for asynchronous data flow
- **Foundation**: Networking and data parsing

## Project Structure

```
ServicesProvider/
├── Sources/
│   ├── API/
│   │   ├── GomaPromotionsAPIClient.swift
│   │   └── GomaAPIAuthenticator.swift
│   ├── Models/
│   │   ├── Internal/
│   │   │   └── GomaModels+*.swift
│   │   └── Domain/
│   │       ├── HomeTemplate.swift
│   │       ├── Banner.swift
│   │       └── ...
│   ├── Mappers/
│   │   └── GomaModelMapper+*.swift
│   ├── Protocols/
│   │   ├── Connector.swift
│   │   ├── ManagedContentProvider.swift
│   │   ├── AnalyticsProvider.swift
│   │   ├── BettingProvider.swift
│   │   ├── EventsProvider.swift
│   │   ├── PrivilegedAccessManager.swift
│   │   └── PromotionsProvider.swift
│   ├── Providers/
│   │   ├── Goma/
│   │   │   ├── GomaManagedContentProvider.swift
│   │   │   ├── GomaAPIClient.swift
│   │   │   └── ...
│   │   └── Sportsradar/
│   │       ├── SportRadarManagedContentProvider.swift
│   │       ├── SportRadarBettingProvider.swift
│   │       └── ...
│   └── ServiceProviderClient.swift
├── Tests/
│   ├── Unit/
│   └── Integration/
└── Docs/
    └── IntegrationTests.md
```
