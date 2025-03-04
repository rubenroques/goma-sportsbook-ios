# ServicesProvider Framework Architecture

## Overview

The ServicesProvider is a crucial framework in the GOMA Sportsbook iOS application that abstracts all backend communications through a clean, protocol-oriented architecture. It provides a unified interface for accessing authentication, betting, and sports data services regardless of the underlying backend implementation.

## Core Design Principles

1. **Protocol-First Design**: All service interfaces are defined as protocols
2. **Implementation Agnosticism**: Client code interacts only with protocol interfaces
3. **Reactive Programming**: All operations return Combine publishers
4. **Connection State Management**: Handles connection lifecycle automatically
5. **Centralized Error Handling**: Unified error model across all services

## Component Architecture

```
┌───────────────────────────────────────────────────┐
│              ServicesProviderClient               │
│                                                   │
│  ┌───────────────┐   ┌───────────────────────┐   │
│  │ Configuration │   │ Connection Management │   │
│  └───────────────┘   └───────────────────────┘   │
└─────────┬─────────────────────┬─────────────────┬┘
          │                     │                 │
          ▼                     ▼                 ▼
┌─────────────────┐   ┌─────────────────┐ ┌─────────────────┐
│ Privileged      │   │ Events          │ │ Betting         │
│ Access Manager  │   │ Provider        │ │ Provider        │
└────────┬────────┘   └────────┬────────┘ └────────┬────────┘
         │                     │                   │
         │                     │                   │
┌────────▼────────┐   ┌────────▼────────┐ ┌────────▼────────┐
│  SportRadar     │   │  SportRadar     │ │  SportRadar     │
│  PAM Impl       │   │  Events Impl    │ │  Betting Impl   │
└────────┬────────┘   └────────┬────────┘ └────────┬────────┘
         │                     │                   │
         ▼                     ▼                   ▼
┌────────────────────────────────────────────────────────────┐
│                       Session Coordinator                   │
└────────────────────────────────────────────────────────────┘
         │                     │                   │
         ▼                     ▼                   ▼
┌────────────────┐   ┌────────────────┐   ┌────────────────┐
│   REST API     │   │  WebSocket     │   │  REST API      │
│  Connector     │   │  Connector     │   │  Connector     │
└────────────────┘   └────────────────┘   └────────────────┘
```

## Key Components

### 1. ServicesProviderClient

The main entry point and facade for all services:

```swift
public class ServicesProviderClient {
    public enum ProviderType {
        case everymatrix
        case sportradar
    }
    
    // Connection state publishers
    public var privilegedAccessManagerConnectionStatePublisher: AnyPublisher<ConnectorState, Never>
    public var eventsConnectionStatePublisher: AnyPublisher<ConnectorState, Never>
    public var bettingConnectionStatePublisher: AnyPublisher<ConnectorState, Never>
    
    public init(providerType: ProviderType, configuration: ServicesProviderConfiguration)
    public func connect()
    public func disconnect()
    public func reconnectIfNeeded()
    
    // Various service methods forwarded to appropriate providers
}
```

### 2. Core Protocol Interfaces

#### PrivilegedAccessManager

```swift
protocol PrivilegedAccessManager: Connector {
    var userSessionStatePublisher: AnyPublisher<UserSessionStatus, Error> { get }
    var userProfilePublisher: AnyPublisher<UserProfile?, Error> { get }
    
    func login(username: String, password: String) -> AnyPublisher<UserProfile, ServiceProviderError>
    func getUserProfile(withKycExpire: String?) -> AnyPublisher<UserProfile, ServiceProviderError>
    
    // User management functions
    // Payment processing functions
    // Document verification functions
    // Consent management functions
}
```

#### EventsProvider

```swift
protocol EventsProvider: Connector {
    func subscribeLiveMatches(forSportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>
    func subscribePreLiveMatches(forSportType: SportType, initialDate: Date?, endDate: Date?, eventCount: Int?, sortType: EventListSort) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>
    
    // Sports data functions
    // Real-time subscription functions
    // Search and filter functions
}
```

#### BettingProvider

```swift
protocol BettingProvider: Connector {
    func getBetHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError>
    func calculatePotentialReturn(forBetTicket: BetTicket) -> AnyPublisher<BetslipPotentialReturn, ServiceProviderError>
    func placeBets(betTickets: [BetTicket], useFreebetBalance: Bool) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError>
    
    // Bet processing functions
    // Cashout functions
    // BetBuilder functions
}
```

### 3. Provider Implementations

#### SportRadar Implementation

The SportRadar implementation provides concrete implementations of all service interfaces:

- `SportRadarPrivilegedAccessManager`: Implements user authentication and profile management
- `SportRadarEventsProvider`: Implements sports data and real-time events
- `SportRadarBettingProvider`: Implements betting operations

#### Session Management

The `SportRadarSessionCoordinator` handles token management and session state:

```swift
class SportRadarSessionCoordinator {
    func saveToken(_ token: String, withKey key: SessionCoordinatorKey)
    func clearToken(withKey key: SessionCoordinatorKey)
    func token(forKey key: SessionCoordinatorKey) -> AnyPublisher<String?, Never>
    func registerUpdater(_ updater: SportRadarSessionTokenUpdater, forKey key: SessionCoordinatorKey)
    func forceTokenRefresh(forKey key: SessionCoordinatorKey) -> AnyPublisher<String?, Never>?
}
```

### 4. Network Layer

#### REST API Communication

The REST API communication is handled through the `NetworkManager`:

```swift
class NetworkManager {
    func request<T: Codable>(_ endpoint: Endpoint) -> AnyPublisher<T, ServiceProviderError>
}
```

#### WebSocket Communication

Real-time updates use WebSockets through the `WebSocketClientStream`:

```swift
public class WebSocketClientStream: AsyncSequence {
    public init(url: URL)
    public func connect()
    public func close()
    public func send(remoteMessage: String) async throws
}
```

### 5. Data Models

The framework includes comprehensive data models for all domain entities:

- **Sports Models**: Sport types, events, markets, outcomes
- **User Models**: User profile, authentication, preferences
- **Betting Models**: Bet types, bet history, potential returns
- **Subscription Models**: Real-time update containers

## Reactive Data Flow

### 1. Connection Flow

```
App Starts → ServicesProviderClient.connect() → 
Provider Implementations Initialize → 
Connectors Established → Connection State Publishers Updated
```

### 2. Authentication Flow

```
Login Request → PrivilegedAccessManager.login() → 
REST API Request → Token Received → 
Token Stored in SessionCoordinator → 
User Profile Publisher Updated
```

### 3. Real-time Data Flow

```
Subscribe Request → EventsProvider.subscribeLiveMatches() → 
WebSocket Connection → Initial Data Received → 
Data Mapped to Models → Publisher Emits Initial Value → 
Updates Received → Publisher Emits Updates
```

## Error Handling

The framework provides a unified error model through the `ServiceProviderError` enum:

```swift
enum ServiceProviderError: Error {
    case eventsProviderNotFound
    case invalidRequestFormat
    case unauthorized
    case forbidden
    case resourceUnavailableOrDeleted
    case decodingError(message: String)
    case invalidResponse
    case emptyData
    case unknown
}
```

## Configuration System

Environment-specific settings are managed through the `ServicesProviderConfiguration`:

```swift
public struct ServicesProviderConfiguration {
    public enum Environment {
        case production
        case staging
        case development
    }
    
    private(set) var environment: Environment
    
    public init(environment: Environment = .production)
}
```

## Extension Points

The framework is designed to be extended in several ways:

1. **New Provider Types**: Add new provider implementations for different backend systems
2. **Enhanced Protocol Interfaces**: Extend existing protocols with new functionality
3. **Custom Data Models**: Add new models for additional domain entities
4. **Alternative Network Implementations**: Replace network layer components with custom implementations 