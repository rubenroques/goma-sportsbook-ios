# Sprint 5: API Modules - Core Betting Operations

## Sprint Goal
Implement all API modules for betting operations, sports data, and configuration management matching the web implementation.

## Duration: 2 weeks

## Epic 5.1: Boot Module (2 days)

### Task 5.1.1: Create Boot Manager
- **File**: `Sources/API/Modules/BootManager.swift`
- **Description**: Application initialization sequence
- **Acceptance Criteria**:
  - Initialize connection
  - Fetch operator info
  - Setup session subscriptions
  - Load initial configuration
  - Handle maintenance mode

### Task 5.1.2: Implement Session State Subscription
- **File**: `Sources/API/Modules/SessionStateSubscription.swift`
- **Description**: Monitor session state changes
- **Acceptance Criteria**:
  - Subscribe to /sessionStateChange
  - Handle all state codes (0-6)
  - Coordinate with auth system
  - Auto-logout implementation

### Task 5.1.3: Create Client Identity Handler
- **File**: `Sources/API/Modules/ClientIdentityHandler.swift`
- **Description**: Manage client identity
- **Acceptance Criteria**:
  - Call /connection#getClientIdentity
  - Store CID securely
  - Recovery on reconnect
  - Session restoration

## Epic 5.2: Betting Module (3 days)

### Task 5.2.1: Implement Sports API
- **File**: `Sources/API/Modules/Betting/SportsAPI.swift`
- **Description**: Sports data operations
- **Acceptance Criteria**:
  - getPreLiveSports()
  - getLiveSports()
  - subscribeToPreLiveSports()
  - subscribeToLiveSports()
  - Virtual sports support

### Task 5.2.2: Create Events API
- **File**: `Sources/API/Modules/Betting/EventsAPI.swift`
- **Description**: Event subscription and management
- **Acceptance Criteria**:
  - subscribeToPreLiveEvents()
  - subscribeToLiveEvents()
  - Event count configuration
  - Market count limits
  - Aggregator topic support

### Task 5.2.3: Build Markets & Odds Handler
- **File**: `Sources/API/Modules/Betting/MarketsAPI.swift`
- **Description**: Market and betting offer operations
- **Acceptance Criteria**:
  - Market group handling
  - Main market identification
  - Odds format support
  - Asian handicap handling

### Task 5.2.4: Implement Data Aggregation
- **File**: `Sources/API/Modules/Betting/DataAggregator.swift`
- **Description**: Aggregate and organize betting data
- **Acceptance Criteria**:
  - Entity relationship building
  - Orphaned entity handling
  - Performance optimization
  - Memory efficiency

## Epic 5.3: Configuration Module (2 days)

### Task 5.3.1: Create Config Manager
- **File**: `Sources/API/Modules/ConfigManager.swift`
- **Description**: Load and manage configurations
- **Acceptance Criteria**:
  - loadRegisterConfig()
  - loadBetslipConfig()
  - loadNavbarsConfig()
  - loadTopBarConfig()
  - Action replacement logic

### Task 5.3.2: Implement Config Mappers
- **File**: `Sources/API/Modules/Config/ConfigMappers.swift`
- **Description**: Transform configuration data
- **Acceptance Criteria**:
  - Map navigation config
  - Map UI components
  - Handle dynamic actions
  - Theme configuration

### Task 5.3.3: Build Config Storage
- **File**: `Sources/API/Modules/Config/ConfigStorage.swift`
- **Description**: Store and cache configurations
- **Acceptance Criteria**:
  - Memory caching
  - Disk persistence
  - Version tracking
  - Update notifications

## Epic 5.4: User & Account Module (2 days)

### Task 5.4.1: Create User API
- **File**: `Sources/API/Modules/UserAPI.swift`
- **Description**: User account operations
- **Acceptance Criteria**:
  - getSessionInfo()
  - getProfileInfo()
  - User activation
  - Balance management

### Task 5.4.2: Implement Social Features
- **File**: `Sources/API/Modules/SocialAPI.swift`
- **Description**: Social betting features
- **Acceptance Criteria**:
  - getFriends()
  - getFollowing()
  - Tips management
  - Social interactions

## Epic 5.5: Promotions Module (1 day)

### Task 5.5.1: Create Promotions API
- **File**: `Sources/API/Modules/PromotionsAPI.swift`
- **Description**: Promotions and bonuses
- **Acceptance Criteria**:
  - getPromotionBanners()
  - getPromotions()
  - getPromotionDetails()
  - Banner mapping

## Epic 5.6: API Integration Layer (2 days)

### Task 5.6.1: Build API Coordinator
- **File**: `Sources/API/EveryMatrixAPICoordinator.swift`
- **Description**: Coordinate all API modules
- **Acceptance Criteria**:
  - Module initialization
  - Dependency injection
  - Shared session management
  - Error propagation

### Task 5.6.2: Create API Factory
- **File**: `Sources/API/EveryMatrixAPIFactory.swift`
- **Description**: Factory for API instances
- **Acceptance Criteria**:
  - Singleton management
  - Configuration injection
  - Mock support for testing
  - Thread safety

### Task 5.6.3: Implement Request Queue
- **File**: `Sources/API/RequestQueue.swift`
- **Description**: Manage API request queuing
- **Acceptance Criteria**:
  - Priority queue support
  - Rate limiting
  - Request deduplication
  - Retry logic

## Deliverables
1. Complete betting API implementation
2. Configuration management system
3. User and social features
4. Promotions support
5. Integrated API layer

## Definition of Done
- [ ] All API methods match web implementation
- [ ] Proper error handling for all endpoints
- [ ] Request/response logging
- [ ] Performance metrics collection
- [ ] Integration tests for all modules
- [ ] API documentation generated 