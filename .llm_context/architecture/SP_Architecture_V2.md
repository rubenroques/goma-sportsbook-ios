# ServicesProvider Architecture

## Table of Contents
1. [Overview](#overview)
2. [Core Components](#core-components)
3. [Session Management](#session-management)
4. [Provider Implementation](#provider-implementation)
5. [Configuration System](#configuration-system)
6. [Request Flow Patterns](#request-flow-patterns)
7. [Implementation Examples](#implementation-examples)

## Overview

ServicesProvider is a framework that abstracts third-party service integrations through a protocol-oriented architecture. It enables applications to interact with multiple providers (like Goma, SportRadar) through a unified interface while maintaining clear separation between different service domains.

### Key Features
- Multiple provider support per domain
- Centralized session management
- Protocol-based API abstraction
- Automatic token refresh handling
- Cross-provider state sharing
- Domain-specific subset isolation

### Architecture Diagram

```mermaid
classDiagram
    class ServicesProvider {
        +List<Provider> providers
        +SessionCoordinator coordinator
        +configure()
        +getSubset(domain)
    }
    class SessionCoordinator {
        +Map<String, Publisher> tokenPublishers
        +Map<String, Subscriber> tokenSubscribers
        +registerPublisher(key, publisher)
        +registerSubscriber(key, subscriber)
        +shareToken(key, token)
    }
    class Provider {
        +String name
        +Connector connector
        +List<Subset> subsets
    }
    class GomaProvider {
        +GomaConnector connector
        +GomaPromotionsSubset promotions
        +GomaAnalyticsSubset analytics
    }
    class SportRadarProvider {
        +SportRadarConnector connector
        +SportRadarBettingSubset betting
        +SportRadarEventsSubset events
    }
    class Connector {
        +authenticate()
        +refreshToken()
        +handleConnection()
    }
    class Subset {
        +Schema schema
        +Connector connector
    }
    class Schema {
        +List<Endpoint> endpoints
        +URLConfiguration config
    }
    
    ServicesProvider *-- SessionCoordinator
    ServicesProvider *-- Provider
    SessionCoordinator --> Provider
    Provider <|-- GomaProvider
    Provider <|-- SportRadarProvider
    Provider *-- Connector
    Provider *-- Subset
    Subset --> Schema
```

## Core Components

### ServicesProvider
The main entry point for the framework that:
- Manages provider instances
- Coordinates cross-provider communication
- Handles domain-to-provider mapping
- Maintains global configuration

### Provider
A concrete implementation of a third-party service integration:
- Maintains its own Connector instance
- Offers multiple domain-specific Subsets
- Can implement multiple domains
- Examples: `GomaProvider`, `SportRadarProvider`

### Connector
Handles provider-specific connection management:
```swift
protocol Connector {
    var connectionState: AnyPublisher<ConnectionState, Never> { get }
    func authenticate() -> AnyPublisher<Void, Error>
    func refreshToken() -> AnyPublisher<Void, Error>
    func handleConnection()
}
```

### Subset
Implements domain-specific functionality:
- Uses provider's Connector for authentication
- Follows a defined Schema
- Maps to specific Domain
- Examples: `GomaPromotionsSubset`, `SportRadarBettingSubset`

### Schema
Defines the API contract:
Check file: ServicesProvider/Sources/ServicesProvider/Providers/Goma/APIs/GomaAPIPromotionsSchema.swift

### Domain
Available business domains:
```swift
enum Domain {
    case playerAccountManagement    // Handles user account operations
    case bets                      // Manages betting operations
    case bonus                     // Handles bonus and promotion features
    case liveEvents               // Manages real-time sporting events
    case preLiveEvents            // Handles upcoming/scheduled events
    case payments                 // Manages financial transactions
    case responsibleGaming        // Handles responsible gaming features
    case customerSupport          // Manages customer service functionality
    case analytics               // Handles analytics and tracking
}
```

## Session Management

### SessionCoordinator
Manages cross-provider session state:

```swift
final class SessionCoordinator {
    // Token Publishers
    func registerPublisher(_ publisher: Provider, forKey key: String)
    func publishToken(_ token: String, forKey key: String)
    
    // Token Subscribers
    func registerSubscriber(_ subscriber: Provider, forKey key: String)
    func token(forKey key: String) -> AnyPublisher<String?, Never>
    
    // Token Management
    func invalidateToken(forKey key: String)
    func clearAllTokens()
}
```

### Token Sharing Flow
```mermaid
sequenceDiagram
    participant Application
    participant ServicesProvider
    participant SessionCoordinator
    participant PAMProvider
    participant BettingProvider

    Application->>ServicesProvider: Login
    ServicesProvider->>PAMProvider: Authenticate
    PAMProvider->>SessionCoordinator: Publish session token
    SessionCoordinator-->>BettingProvider: Notify new session token
    
    Application->>ServicesProvider: Place bet
    ServicesProvider->>BettingProvider: Process bet
    BettingProvider->>SessionCoordinator: Request PAM token
    SessionCoordinator-->>BettingProvider: Return current PAM token
    BettingProvider->>BettingProvider: Use token for authentication
```

## Provider Implementation

### Implementation Flow
```mermaid
flowchart LR
    A[Application] --> B[ServicesProvider]
    B --> C[GomaProvider]
    B --> D[SportRadarProvider]
    
    C --> E[GomaConnector]
    C --> F[GomaPromotionsSubset]
    C --> G[GomaAnalyticsSubset]
    
    D --> H[SportRadarConnector]
    D --> I[SportRadarBettingSubset]
    D --> J[SportRadarEventsSubset]
    
    F --> K[GomaPromotionsSchema]
    G --> L[GomaAnalyticsSchema]
    I --> M[SportRadarBettingSchema]
    J --> N[SportRadarEventsSchema]
```

### Provider Example
```swift
final class GomaProvider: Provider {
    private let connector: GomaConnector
    private let sessionCoordinator: SessionCoordinator
    
    let promotionsSubset: GomaPromotionsSubset
    let analyticsSubset: GomaAnalyticsSubset
    
    init(credentials: ProviderCredentials, sessionCoordinator: SessionCoordinator) {
        self.connector = GomaConnector(credentials: credentials)
        self.sessionCoordinator = sessionCoordinator
        
        self.promotionsSubset = GomaPromotionsSubset(connector: connector)
        self.analyticsSubset = GomaAnalyticsSubset(connector: connector)
        
        // Register for PAM session tokens
        sessionCoordinator.registerSubscriber(self, forKey: "pam.session")
    }
}
```

## Configuration System

### Builder Pattern
```swift
let config = Configuration.Builder()
    // Player Account Management through SportRadar
    .useProvider(.sportRadar, forDomain: .playerAccountManagement)
    .withCredentials(.sportRadar, apiKey: "sr-pam-key", secret: "sr-pam-secret")
    
    // Betting operations through SportRadar
    .useProvider(.sportRadar, forDomain: .myBets)
    
    // Bonus management through Goma
    .useProvider(.goma, forDomain: .bonus)
    .withCredentials(.goma, apiKey: "goma-key", secret: "goma-secret")
    
    // Analytics through Goma
    .useProvider(.goma, forDomain: .analytics)
    
    .withEnvironment(.production)
    .withDeviceUUID("device-uuid")
    .build()
```

## Request Flow Patterns

### Standard Request Flow
```mermaid
sequenceDiagram
    participant Application
    participant ServicesProvider
    participant GomaProvider
    participant GomaPromotionsSubset
    participant GomaConnector
    participant GomaAPI

    Application->>ServicesProvider: Get promotions provider
    ServicesProvider->>GomaProvider: Get promotions subset
    GomaProvider->>GomaPromotionsSubset: Handle request
    GomaPromotionsSubset->>GomaConnector: Validate authentication
    GomaConnector-->>GomaPromotionsSubset: Token valid
    GomaPromotionsSubset->>GomaAPI: HTTP request (GomaPromotionsSchema.allPromotions)
    GomaAPI-->>GomaPromotionsSubset: JSON Response
    GomaPromotionsSubset-->>Application: Parsed PromotionsModel

    alt Token expired
        GomaConnector->>GomaAPI: Refresh authentication token
        GomaAPI-->>GomaConnector: New authentication token
        GomaConnector-->>GomaPromotionsSubset: Updated token
    end
```

## Implementation Examples

### Schema Implementation
```swift
enum GomaPromotionsSchema: Schema {
    // Home Template
    case homeTemplate
    case allPromotions
    case alertBanner
    case banners
    case sportBanners
    case boostedOdds
    case topImageCards
    case heroCards
    case stories
    case news(pageIndex: Int, pageSize: Int)
    case proChoices
    case topCompetitions
    
    var endpoint: String {
        switch self {
            case .homeTemplate: return "/v1/template/home"
            case .allPromotions: return "/v1/promotions"
            // ... other cases
        }
    }
    
    var method: HTTP.Method {
        switch self {
            case .homeTemplate, .allPromotions: return .get
            // ... other cases
        }
    }
    
    // Additional Schema protocol requirements...
}
```
