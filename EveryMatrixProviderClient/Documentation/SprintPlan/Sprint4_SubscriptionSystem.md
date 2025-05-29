# Sprint 4: Subscription System & Real-time Updates

## Sprint Goal
Build a robust topic subscription system with real-time update handling, matching the web's register/unregister pattern.

## Duration: 2 weeks

## Epic 4.1: Subscription Infrastructure (3 days)

### Task 4.1.1: Create Subscription Manager
- **File**: `Sources/Subscriptions/SubscriptionManager.swift`
- **Description**: Core subscription lifecycle management
- **Acceptance Criteria**:
  - Topic subscription/unsubscription
  - Active subscription tracking
  - Reference counting for shared topics
  - Thread-safe operations
  - Automatic cleanup on disconnect

### Task 4.1.2: Implement Topic Registry
- **File**: `Sources/Subscriptions/TopicRegistry.swift`
- **Description**: Manage active topic subscriptions
- **Acceptance Criteria**:
  - Track subscription instances
  - Handle multiple listeners per topic
  - Listener reference management
  - Subscription metadata storage

### Task 4.1.3: Build Subscription Builder
- **File**: `Sources/Subscriptions/SubscriptionBuilder.swift`
- **Description**: Build subscription URLs and parameters
- **Acceptance Criteria**:
  - Dynamic topic URL construction
  - Parameter interpolation (operator, language)
  - Topic types (sports, events, etc.)
  - Validation of parameters

## Epic 4.2: Initial Dump & Updates (3 days)

### Task 4.2.1: Create Initial Dump Handler
- **File**: `Sources/Subscriptions/InitialDumpHandler.swift`
- **Description**: Handle initial data dumps
- **Acceptance Criteria**:
  - Request initial dump via RPC
  - Parse chunked responses
  - Invoke initial dump callbacks
  - Error handling for failed dumps

### Task 4.2.2: Implement Update Stream Handler
- **File**: `Sources/Subscriptions/UpdateStreamHandler.swift`
- **Description**: Process real-time updates
- **Acceptance Criteria**:
  - EVENT message processing
  - Version tracking
  - Update deduplication
  - Out-of-order handling

### Task 4.2.3: Build Update Processor
- **File**: `Sources/Updates/UpdateProcessor.swift`
- **Description**: Process and apply updates
- **Acceptance Criteria**:
  - CREATE/UPDATE/DELETE operations
  - Entity-specific update logic
  - Batch update support
  - Performance optimization

## Epic 4.3: Callback System (2 days)

### Task 4.3.1: Design Callback Interfaces
- **File**: `Sources/Subscriptions/SubscriptionCallbacks.swift`
- **Description**: Callback protocols and types
- **Acceptance Criteria**:
  - onInitialDump callback
  - onUpdate callback
  - afterInitialDump callback
  - Error callback support
  - Generic type support

### Task 4.3.2: Implement Callback Dispatcher
- **File**: `Sources/Subscriptions/CallbackDispatcher.swift`
- **Description**: Dispatch callbacks efficiently
- **Acceptance Criteria**:
  - Main thread dispatching option
  - Background processing support
  - Callback ordering guarantees
  - Exception isolation

### Task 4.3.3: Create Listener Management
- **File**: `Sources/Subscriptions/ListenerManager.swift`
- **Description**: Manage subscription listeners
- **Acceptance Criteria**:
  - Add/remove listeners
  - Weak reference support
  - Listener lifecycle management
  - Memory leak prevention

## Epic 4.4: Topic-Specific Implementations (2 days)

### Task 4.4.1: Sports Topic Handler
- **File**: `Sources/Subscriptions/Topics/SportsTopicHandler.swift`
- **Description**: Handle sports-specific subscriptions
- **Acceptance Criteria**:
  - Pre-live sports subscription
  - Live sports subscription
  - Context handling (live/popular)
  - Sport filtering options

### Task 4.4.2: Events Topic Handler
- **File**: `Sources/Subscriptions/Topics/EventsTopicHandler.swift`
- **Description**: Handle event subscriptions
- **Acceptance Criteria**:
  - Popular events aggregator
  - Live events aggregator
  - Market count configuration
  - Event count limits

### Task 4.4.3: Registration Revival Handler
- **File**: `Sources/Subscriptions/RegistrationRevivalHandler.swift`
- **Description**: Handle stalled registration revival
- **Acceptance Criteria**:
  - Subscribe to /registrationDismissed
  - Automatic re-registration
  - Retry logic
  - State recovery

## Epic 4.5: Subscription Options (1 day)

### Task 4.5.1: Implement Chunking Options
- **File**: `Sources/Subscriptions/ChunkingOptions.swift`
- **Description**: Configure response chunking
- **Acceptance Criteria**:
  - Entity type chunking
  - Chunk size configuration
  - Order preservation
  - Performance optimization

### Task 4.5.2: Create Subscription Configuration
- **File**: `Sources/Subscriptions/SubscriptionConfiguration.swift`
- **Description**: Subscription behavior configuration
- **Acceptance Criteria**:
  - callOnUpdateOnInitialDump flag
  - wrapIntoArray option
  - Retry configuration
  - Timeout settings

## Epic 4.6: Testing & Monitoring (1 day)

### Task 4.6.1: Build Subscription Monitor
- **File**: `Sources/Debug/SubscriptionMonitor.swift`
- **Description**: Monitor subscription health
- **Acceptance Criteria**:
  - Active subscription list
  - Update frequency tracking
  - Error rate monitoring
  - Debug logging

### Task 4.6.2: Create Mock Subscription System
- **File**: `Tests/Mocks/MockSubscriptionManager.swift`
- **Description**: Testing infrastructure
- **Acceptance Criteria**:
  - Simulate subscriptions
  - Trigger mock updates
  - Control update timing
  - Error injection

## Deliverables
1. Complete subscription management system
2. Real-time update processing
3. Topic-specific handlers
4. Callback system with proper memory management
5. Comprehensive test suite

## Definition of Done
- [ ] Feature parity with web $wregister system
- [ ] All topic types implemented
- [ ] No memory leaks in callback system
- [ ] Update processing performance targets met
- [ ] Integration tests with mock server
- [ ] Documentation for subscription patterns 