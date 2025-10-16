# CLAUDE.md - EveryMatrix Provider

This file provides guidance to Claude Code (claude.ai/code) when working with the EveryMatrix provider implementation.

## Overview

The EveryMatrix provider implements a **hybrid architecture** combining real-time WebSocket communication (WAMP protocol) with traditional REST APIs for comprehensive sports betting operations.

### Key Characteristics

- **WAMP Protocol (WebSocket)**: Real-time sports data via pub/sub + RPC over WebSocket
- **REST APIs**: Betting operations, authentication, casino games, AI recommendations
- **Entity-Store Pattern**: In-memory relational store for efficient real-time updates
- **3-Layer Model Architecture**: DTO → Internal → Domain transformation pipeline
- **Automatic Token Refresh**: Transparent session management across all HTTP APIs
- **Change Record System**: Delta updates for bandwidth-efficient real-time data

---

## Architecture: WAMP vs REST

### WAMP Protocol (WebSocket)

**Purpose**: Real-time sports data with live odds updates

**Used For**:
- Live match data and scores
- Pre-live match listings
- Betting markets and outcomes
- Real-time odds changes
- Tournament and sports listings
- Search functionality

**Communication Patterns**:
1. **RPC (Remote Procedure Call)**: One-time data requests
2. **Pub/Sub (Subscriptions)**: Continuous real-time updates

**Key Components**:
- **WAMPManager**: Central session and connection manager
- **WAMPRouter**: Route definitions (60+ endpoints)
- **EntityStore**: In-memory storage for WebSocket data
- **Subscription Managers**: Orchestrate complex subscription flows

**Why WAMP?**
EveryMatrix uses WAMP for sports data because it efficiently delivers real-time odds updates to thousands of concurrent users. A single WebSocket connection provides all live sports data, drastically reducing bandwidth compared to REST polling.

### REST APIs (HTTP)

**Purpose**: Transactional operations and non-real-time data

**Four Separate APIs**:

1. **OddsMatrix API** (`/OddsMatrixAPI/`)
   - Base URL: `https://sports-api-stage.everymatrix.com`
   - **Operations**: Place bets, bet history, cashout
   - **Authentication**: Session token headers
   - **Special**: SSE streaming for real-time cashout values

2. **PlayerAPI** (`/PlayerAPI/`)
   - Base URL: `https://betsson-api.stage.norway.everymatrix.com`
   - **Operations**: Login, registration, profile, payments, transactions
   - **Authentication**: Session token headers
   - **Critical**: Stores credentials for auto token refresh

3. **CasinoAPI** (`/CasinoAPI/`)
   - Base URL: `https://betsson-api.stage.norway.everymatrix.com` (same as PlayerAPI)
   - **Operations**: Game catalog, search, recommendations, game launch URLs
   - **Authentication**: Cookie header (not session token)
   - **Note**: Different auth mechanism than other APIs

4. **RecsysAPI** (`/RecsysAPI/`)
   - Base URL: `https://recsys-api-gateway-test-bshwjrve.ew.gateway.dev`
   - **Operations**: AI-powered bet recommendations (single and combo bets)
   - **Authentication**: API key in query parameters (no session token)
   - **Note**: Separate microservice infrastructure

**Why Multiple APIs?**
Each API serves a distinct domain with different infrastructure, authentication, and scaling requirements. They were built by different EveryMatrix teams at different times.

---

## Two Different Data Flows: WebSocket vs REST

### The Critical Distinction

EveryMatrix uses **two completely different model architectures** depending on the data source:

1. **WebSocket (WAMP)**: Sends **normalized, flat data** requiring reconstruction
2. **REST APIs**: Send **hierarchical data** already nested and complete

### WebSocket Data Flow (4 Layers)

**Why DTOs Exist**: WebSocket sends **normalized data** - entities reference each other by ID, not by nesting.

**What We Receive** (flat, normalized):
- Match: `{ id: "123", sportId: "1", marketIds: ["m1", "m2"] }`
- Market: `{ id: "m1", outcomeIds: ["o1", "o2"] }`
- Outcome: `{ id: "o1", bettingOfferId: "b1" }`
- BettingOffer: `{ id: "b1", decimalOdds: 2.5 }`

**What We Need** (hierarchical):
```
Match {
  sport: Sport { ... }
  markets: [
    Market {
      outcomes: [
        Outcome {
          bettingOffer: BettingOffer { decimalOdds: 2.5 }
        }
      ]
    }
  ]
}
```

**Why Normalized?**
- **Bandwidth Efficiency**: When odds change, send only `{ id: "b1", decimalOdds: 2.8 }` (tiny)
- **No Duplication**: A sport referenced by 1000 matches is sent once
- **Selective Updates**: Update one outcome without resending entire match tree

**The 4-Layer Transformation**:

**Layer 1: DTOs (Data Transfer Objects)** - `Models/DataTransferObjects/`
- **Only WebSocket entities use this term**
- Flat structures matching WebSocket wire format exactly
- Stored in EntityStore indexed by type and ID
- Contains foreign keys (IDs) to related entities
- 14 DTO types: MatchDTO, MarketDTO, OutcomeDTO, BettingOfferDTO, SportDTO, etc.
- **Suffix "DTO"** exclusively identifies WebSocket entities

**Layer 2: Hierarchical Internal Models** - `Models/Composed/`
- Built on-demand via Builder pattern (MatchBuilder, MarketBuilder, etc.)
- Builders resolve foreign keys by looking up entities in EntityStore
- Navigable object graph: `match.sport.name`, `outcome.bettingOffer.decimalOdds`
- 8 composed types: Match, Market, Outcome, Sport, etc.

**Layer 3: Model Mapper** - `Models/Mappers/EveryMatrixModelMapper+*.swift`
- Transforms hierarchical internal models to domain models
- Extensions handle different entity types

**Layer 4: Domain Models** - ServicesProvider public API
- Provider-agnostic models: Event, Market, Outcome, SportType
- Shared across all providers (Goma, SportRadar, EveryMatrix)
- Used by application ViewModels and UI

**Complete Flow**:
```
WebSocket JSON
    ↓
MatchDTO (flat, stored in EntityStore)
    ↓
MatchBuilder.build(from: matchDTO, store: entityStore)
    ↓
Match (hierarchical internal model with nested sport, markets, outcomes)
    ↓
EveryMatrixModelMapper.event(fromInternalMatch: match)
    ↓
Event (domain model)
```

### REST API Data Flow (2 Layers)

**Why No DTOs**: REST APIs send **complete, hierarchical JSON** - no reconstruction needed.

**What We Receive** (already hierarchical):
```json
{
  "bet": {
    "id": "b123",
    "stake": 10.0,
    "selections": [
      {
        "eventName": "Team A vs Team B",
        "outcome": "Team A Win",
        "odds": 2.5
      }
    ]
  }
}
```

**The 2-Layer Transformation**:

**Layer 1: Internal Models** - `Models/Shared/EveryMatrix+*.swift`
- **NOT called DTOs** - that term is exclusive to WebSocket
- Decoded directly from JSON (no foreign keys to resolve)
- Already hierarchical and complete
- Examples: `EveryMatrix.PlaceBetResponse`, `EveryMatrix.PhoneLoginResponse`, `EveryMatrix.CasinoGamesResponseDTO`
- **Never stored in EntityStore**
- **No Builders needed**

**Layer 2: Domain Models** - ServicesProvider public API
- Same domain models as WebSocket flow
- Transformed via EveryMatrixModelMapper

**Complete Flow**:
```
REST JSON Response
    ↓
EveryMatrix.PlaceBetResponse (internal model, already hierarchical)
    ↓
EveryMatrixModelMapper.placedBetsResponse(from: response)
    ↓
PlacedBetsResponse (domain model)
```

### Summary: When Each Flow Is Used

| Data Source | Layers | Uses EntityStore? | Uses Builders? | Uses DTOs? |
|-------------|--------|-------------------|----------------|------------|
| **WebSocket (WAMP)** | 4 layers | ✅ Yes | ✅ Yes | ✅ Yes |
| **REST APIs** | 2 layers | ❌ No | ❌ No | ❌ No |

**Key Insight**: The term "DTO" and the complex 4-layer transformation exist **only** because WebSocket sends normalized data. REST APIs bypass all of that complexity because they send complete hierarchies.

---

## EntityStore: WebSocket Data Storage Only

### Purpose

In-memory relational database **exclusively for WebSocket DTOs** with reactive observation capabilities.

**Critical**: EntityStore is ONLY used for WebSocket data. REST API responses are never stored here.

### Key Features

1. **Type-Safe Storage**: Entities indexed by type and ID
2. **Order Preservation**: Maintains insertion order for lists
3. **Reactive Publishers**: Combine publishers for entity observation
4. **Change Processing**: Handles CREATE/UPDATE/DELETE operations
5. **Property Merging**: Efficient partial updates via JSON encoding

### Storage Structure

Entities stored in nested dictionaries:
- Outer key: Entity type (e.g., "MATCH", "OUTCOME")
- Inner key: Entity ID
- Value: The DTO entity

### Change Record System

**Purpose**: Process delta updates from WebSocket efficiently

**Three Change Types**:
- **CREATE**: New entity received, store it
- **UPDATE**: Partial update received, merge changed properties into existing entity
- **DELETE**: Entity removed, delete from store and notify observers

**How UPDATE Works**:
1. WebSocket sends only changed properties: `{ id: "o1", decimalOdds: 2.8 }`
2. EntityStore encodes existing entity to JSON
3. Merges changed properties into JSON
4. Decodes back to entity (preserves unchanged fields)
5. Notifies all observers of this entity

**Why This Approach?**
Handles dynamic property updates without knowing entity structure at compile time. Works for all 14 entity types without custom merge logic.

### Observation System

**Per-Entity Observation**: Watch specific entity for updates
- Publisher emits `Optional<Entity>` (nil when deleted)
- Used by UI cells to react to single outcome odds changes

**Collection Observation**: Watch related entities (e.g., all outcomes for a market)
- Used for coordinated updates

**Store Isolation**: Subscription managers create isolated EntityStores for independent lifecycle management (e.g., market groups).

---

## Subscription Managers: Orchestrating Complex Flows

### Purpose

Encapsulate multi-step subscription logic that's too complex for simple provider methods.

### When to Use Managers

- **Multi-Stage Subscriptions**: Initial dump + continuous updates
- **Related Entity Coordination**: Match + markets + outcomes + live data
- **Isolated Stores**: Market groups need independent EntityStore instances
- **Pagination**: Load more while maintaining real-time updates

### Key Managers

**MatchDetailsManager** (`/SubscriptionManagers/MatchDetailsManager.swift`)
- Subscribes to single match with all markets, outcomes, and live data
- Uses multiple EntityStores (main + per-market-group stores)
- Provides observation methods for specific markets/outcomes

**LiveMatchesPaginator** (`/SubscriptionManagers/LiveMatchesPaginator.swift`)
- Paginated live matches with real-time updates
- Loads next page while maintaining subscription to existing matches

**PreLiveMatchesPaginator** (`/SubscriptionManagers/PreLiveMatchesPaginator.swift`)
- Paginated upcoming matches
- Time-based filtering for match lists

**SportsManager**, **LocationsManager**, **TournamentsManager**
- Simpler managers for sports/countries/tournaments lists
- Real-time availability updates

**SingleOutcomeSubscriptionManager**, **EventWithBalancedMarketSubscriptionManager**
- Track specific outcomes/markets for betslip
- Used when user adds bet to betslip to monitor odds changes

### Manager Lifecycle

Managers own their subscriptions and EntityStores. They must be:
- Created per subscription
- Stored by provider to maintain lifecycle
- Cleaned up (unsubscribe) when no longer needed
- Automatically cleaned via `deinit` when released

---

## Provider Implementations

### EveryMatrixProvider (EventsProvider)

**Responsibility**: Sports events data (live/pre-live matches, tournaments, markets)

**Architecture**: Uses WAMP connector exclusively

**Key Methods**:
- `subscribeLiveMatches()`: Real-time live matches
- `subscribePreLiveMatches()`: Upcoming matches
- `subscribeEventDetails()`: Single match with all markets
- `subscribeSportTypes()`: Sports list
- `getSearchEvents()`: Search functionality (RPC)

**Pattern**: Creates subscription managers, maintains their lifecycle, exposes domain models

### EveryMatrixBettingProvider (BettingProvider)

**Responsibility**: Bet placement, history, cashout

**Architecture**: Uses OddsMatrix REST API

**Key Methods**:
- `placeBet()`: Place single/combo bets
- `getOpenBets()`: Active bets
- `getSettledBets()`: Historical bets
- `getCashoutValueSSE()`: Real-time cashout via SSE streaming
- `executeCashoutV2()`: Cash out bet

**Special**: Supports SSE (Server-Sent Events) for real-time cashout values as odds change

### EveryMatrixPrivilegedAccessManager (PrivilegedAccessManager)

**Responsibility**: User authentication, profile, payments

**Architecture**: Uses PlayerAPI REST API

**Key Methods**:
- `login()`: Authenticate user, store credentials for auto-refresh
- `register()`: Multi-step registration
- `getUserBalance()`: Wallet balance
- `getBankingWebView()`: Payment session for deposits/withdrawals
- `getTransactions()`: Transaction history

**Critical**: Stores credentials on login to enable automatic token refresh

### EveryMatrixCasinoProvider (CasinoProvider)

**Responsibility**: Casino games catalog

**Architecture**: Uses CasinoAPI REST API

**Key Methods**:
- `getCasinoCategories()`: Game categories
- `getGamesByCategory()`: Games with pagination
- `searchGames()`: Search by name
- `buildGameLaunchUrl()`: Generate game launch URL

**Note**: Uses Cookie authentication instead of session token headers

---

## Configuration & Session Management

### EveryMatrixUnifiedConfiguration

**Purpose**: Centralized configuration for all APIs and environments

**Singleton**: `EveryMatrixUnifiedConfiguration.shared`

**Environment Types**:
- `.production`: Live production
- `.staging`: Staging/UAT (most development)
- `.development`: Local testing

**Key Properties**:
- Base URLs for all 4 REST APIs
- WAMP WebSocket configuration
- Domain ID (e.g., "4093")
- Default language, timeout, platform

**Note**: Set once at app startup in `Client.swift`, don't change mid-session

### EveryMatrixSessionCoordinator

**Purpose**: Manages session tokens and user credentials

**Responsibilities**:
- Store/retrieve session ID and user ID
- Store credentials for auto token refresh
- Provide valid tokens to all connectors
- Thread-safe token operations

**Critical For**: Automatic token refresh when sessions expire (401/403 errors)

### Token Refresh Architecture

**How It Works**:
1. API request fails with 401/403 (session expired)
2. `EveryMatrixBaseConnector` intercepts error
3. Calls `sessionCoordinator.publisherWithValidToken(forceRefresh: true)`
4. SessionCoordinator re-authenticates with stored credentials
5. Original request retried with new token
6. Result returned transparently to caller

**Thread Safety**: Serial dispatch queue prevents concurrent refresh attempts

**Single Retry**: Only one retry per request to prevent infinite loops

**Transparent**: ViewModels and UI never see 401/403 errors, they just get data

See `Documentation/TokenRefreshArchitecture.md` for complete implementation details.

---

## Directory Structure

```
Everymatrix/
├── Libs/
│   ├── WAMPClient/           # WAMP protocol implementation (WebSocket)
│   └── SSEClient/            # Server-Sent Events (cashout streaming)
│
├── Store/
│   └── EntityStore.swift     # In-memory reactive entity storage
│
├── Models/
│   ├── DataTransferObjects/  # Layer 1: Flat DTOs matching WebSocket format
│   ├── Composed/             # Layer 2: Hierarchical internal models
│   ├── Response/             # WebSocket response wrappers
│   ├── Shared/               # HTTP request/response models
│   └── Mappers/              # Layer 3: Domain model transformations
│
├── Builders/                 # DTO → Internal model transformation
│   ├── MatchBuilder.swift
│   ├── MarketBuilder.swift
│   └── ...                   # 8 builders total
│
├── SubscriptionManagers/     # Complex subscription orchestration
│   ├── MatchDetailsManager.swift
│   ├── LiveMatchesPaginator.swift
│   └── ...                   # 9 managers total
│
├── OddsMatrixAPI/            # Sports betting REST API
├── PlayerAPI/                # Authentication REST API
├── CasinoAPI/                # Casino games REST API
├── RecsysAPI/                # Recommendations REST API
│
├── EveryMatrixProvider.swift              # EventsProvider (WAMP)
├── EveryMatrixBettingProvider.swift       # BettingProvider (REST)
├── EveryMatrixPrivilegedAccessManager.swift # Auth/Profile (REST)
├── EveryMatrixCasinoProvider.swift        # Casino (REST)
├── EveryMatrixConnector.swift             # WAMP abstraction
├── EveryMatrixBaseConnector.swift         # HTTP base with auto-retry
├── EveryMatrixSessionCoordinator.swift    # Session/token management
└── EveryMatrixUnifiedConfiguration.swift  # Configuration singleton
```

---

## Key Architectural Principles

### 1. Separation of Concerns

**WAMP for Real-Time**: Live sports data with continuous updates
**REST for Transactions**: Betting, authentication, payments (one-time operations)

### 2. Data Flow Isolation

**WebSocket Data**: Flows through EntityStore → Builders → Mappers → Domain Models
**REST Data**: Direct DTO → Mapper → Domain Model (no EntityStore)

### 3. Reactive Architecture

**EntityStore Publishers**: Real-time entity updates propagate via Combine
**Provider Publishers**: All methods return `AnyPublisher` for async operations

### 4. Protocol-Driven Design

**Provider Protocols**: Define interfaces independent of EveryMatrix
**Domain Models**: Shared across all providers (Goma, SportRadar, EveryMatrix)
**Swappable Implementations**: Can switch providers without changing UI code

### 5. Automatic Error Recovery

**Token Refresh**: Transparent session renewal on expiration
**Retry Logic**: Automatic retry on authentication failures
**No UI Impact**: ViewModels never see authentication errors

---

## Critical Implementation Rules

### EntityStore Usage

- **WebSocket DTOs only**: EntityStore is exclusively for WebSocket entities (the 14 DTO types)
- **Never store REST responses**: REST internal models bypass EntityStore completely
- **Builders required**: Always use builders to create hierarchical models from DTOs
- **Store reference**: Pass EntityStore to builders for foreign key resolution
- **Cleanup**: Unsubscribe and release managers to prevent memory leaks

### Model Transformation

- **WebSocket = 4 layers**: DTO → Builder → Hierarchical Internal → Mapper → Domain
- **REST = 2 layers**: Internal Model → Mapper → Domain (no DTO, no Builder, no EntityStore)
- **DTO term exclusive**: Only use "DTO" for WebSocket entities (suffix in class name)
- **No direct DTO exposure**: ViewModels only see domain models
- **Mappers for both flows**: EveryMatrixModelMapper handles both WebSocket hierarchical internal models AND REST internal models

### Subscription Management

- **Managers for complexity**: Use subscription managers for multi-step flows
- **Lifecycle management**: Store managers to maintain subscriptions
- **Cleanup on deinit**: Always unsubscribe when manager is released
- **Isolated stores**: Market groups use separate EntityStore instances

### HTTP Connector Usage

- **Never modify BaseConnector**: Complex retry logic used by all APIs
- **Credentials on login**: Always store credentials for auto token refresh
- **One API per connector**: Don't mix OddsMatrix and PlayerAPI calls

---

## Documentation References

For detailed implementation specifics:

- **TokenRefreshArchitecture.md**: Complete token refresh mechanism
- **granular-updates-implementation.md**: Change record system implementation
- **websocket-message-analysis.md**: Real WebSocket message examples
- **everymatrix_docs.md**: API endpoint catalog

---

This provider represents the most complex integration in the codebase due to the hybrid WebSocket/REST architecture and the 3-layer model transformation pipeline required to work with EveryMatrix's flat data model design.
