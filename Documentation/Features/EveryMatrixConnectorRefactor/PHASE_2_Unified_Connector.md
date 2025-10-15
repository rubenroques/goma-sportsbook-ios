# Phase 2: Introduce Unified Connector

## Objective

Create a new unified connector that consolidates all four existing connectors into a single, configurable implementation using an API type enum. This phase is **additive only** - existing connectors remain untouched.

**Duration:** 2-3 days
**Risk Level:** Low
**Breaking Changes:** None

---

## Prerequisites

✅ **Phase 1 must be completed first**
- Authentication strategy pattern is implemented
- All tests pass
- No hardcoded auth logic in base class

---

## Current State After Phase 1

We have 4 connector subclasses:
```
EveryMatrixOddsMatrixAPIConnector    → apiIdentifier: "OddsMatrix"
EveryMatrixPlayerAPIConnector        → apiIdentifier: "PlayerAPI"
EveryMatrixCasinoConnector           → apiIdentifier: "Casino"
EveryMatrixRecsysAPIConnector        → apiIdentifier: "RecsysAPI"
```

Each connector:
- Passes a string identifier to base class
- Injects appropriate authentication strategy
- Adds minimal (or no) unique logic

---

## Target Architecture

### Single Unified Connector

Instead of 4 classes, we'll have:
```swift
let oddsMatrixConnector = EveryMatrixUnifiedConnector(
    apiType: .oddsMatrix,
    sessionCoordinator: coordinator
)

let playerConnector = EveryMatrixUnifiedConnector(
    apiType: .playerAPI,
    sessionCoordinator: coordinator
)

let casinoConnector = EveryMatrixUnifiedConnector(
    apiType: .casino,
    sessionCoordinator: coordinator
)

let recsysConnector = EveryMatrixUnifiedConnector(
    apiType: .recsys,
    sessionCoordinator: coordinator
)
```

All API-specific configuration lives in the enum.

---

## Implementation Steps

### Step 1: Create EveryMatrixAPIType Enum

**Create new file:**
`Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixAPIType.swift`

**What to implement:**

1. **Enum Cases:**
   ```swift
   enum EveryMatrixAPIType {
       case oddsMatrix
       case playerAPI
       case casino
       case recsys
   }
   ```

2. **Computed Properties:**
   - `baseURL: String` - Returns appropriate base URL from `EveryMatrixUnifiedConfiguration`
   - `identifier: String` - Returns API identifier for logging
   - `authenticationStrategy: EveryMatrixAuthenticationStrategy` - Returns appropriate auth strategy
   - `defaultTimeout: TimeInterval` - Returns timeout (30 seconds default)

**Base URL Mapping:**

Reference: `EveryMatrixUnifiedConfiguration.swift`

```swift
// Staging environment URLs:
case .oddsMatrix:
    return EveryMatrixUnifiedConfiguration.shared.oddsMatrixBaseURL
    // → "https://sports-api-stage.everymatrix.com"

case .playerAPI:
    return EveryMatrixUnifiedConfiguration.shared.playerAPIBaseURL
    // → "https://betsson-api.stage.norway.everymatrix.com"

case .casino:
    return EveryMatrixUnifiedConfiguration.shared.casinoAPIBaseURL
    // → "https://betsson-api.stage.norway.everymatrix.com"
    // NOTE: Same as PlayerAPI!

case .recsys:
    return EveryMatrixUnifiedConfiguration.shared.recsysAPIBaseURL
    // → "https://recsys-api-gateway-test-bshwjrve.ew.gateway.dev"
```

**Authentication Strategy Mapping:**

```swift
case .oddsMatrix, .playerAPI:
    return SessionTokenAuthStrategy()

case .casino:
    return CookieAuthStrategy()

case .recsys:
    return APIKeyAuthStrategy()
```

**Key Context:**

The enum encapsulates what was previously spread across 4 separate classes:
- Base URLs (from configuration)
- API identifiers (previously hardcoded in each connector)
- Auth strategies (from Phase 1)

---

### Step 2: Create EveryMatrixUnifiedConnector

**Create new file:**
`Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixUnifiedConnector.swift`

**What to implement:**

1. **Wrapper around EveryMatrixBaseConnector:**
   - Stores `apiType: EveryMatrixAPIType`
   - Stores reference to `baseConnector: EveryMatrixBaseConnector`
   - Delegates all method calls to base connector

2. **Initializer:**
   ```swift
   init(
       apiType: EveryMatrixAPIType,
       sessionCoordinator: EveryMatrixSessionCoordinator,
       session: URLSession = .shared,
       decoder: JSONDecoder = JSONDecoder()
   )
   ```

   - Creates `EveryMatrixBaseConnector` with:
     - `apiIdentifier: apiType.identifier`
     - `authStrategy: apiType.authenticationStrategy`
     - Other parameters passed through

3. **Public API Methods:**
   ```swift
   func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, ServiceProviderError>
   func requestSSE<T: Decodable>(_ endpoint: Endpoint, decodingType: T.Type) -> AnyPublisher<SSEEvent<T>, ServiceProviderError>
   ```

   - Both methods delegate to `baseConnector`
   - No additional logic needed

4. **Connection State:**
   ```swift
   var connectionStatePublisher: AnyPublisher<ConnectorState, Never>
   ```

   - Forwards from `baseConnector.connectionStatePublisher`

5. **Helper Methods (from PlayerAPIConnector):**
   ```swift
   func updateSessionToken(sessionId: String, userId: String)
   ```

   - This method exists in `EveryMatrixPlayerAPIConnector.swift:27-34`
   - It's useful, so include it in unified connector
   - Delegates to `sessionCoordinator.updateSession()`

**Important Design Decision:**

The unified connector is a **wrapper**, not a subclass:
```
❌ DON'T: class EveryMatrixUnifiedConnector: EveryMatrixBaseConnector
✅ DO:    class EveryMatrixUnifiedConnector {
            private let baseConnector: EveryMatrixBaseConnector
          }
```

**Why?**
- Composition over inheritance
- Easier to test (can mock base connector)
- Clearer separation of concerns

---

### Step 3: Create Unit Tests

**Create test file:**
`Frameworks/ServicesProvider/Tests/ServicesProviderTests/Providers/Everymatrix/EveryMatrixUnifiedConnectorTests.swift`

**Test cases to implement:**

1. **API Type Configuration Tests:**
   ```swift
   func testOddsMatrixConfiguration()
   func testPlayerAPIConfiguration()
   func testCasinoConfiguration()
   func testRecsysConfiguration()
   ```

   Each test verifies:
   - Correct base URL
   - Correct identifier
   - Correct auth strategy type

2. **Initialization Tests:**
   ```swift
   func testInitializationWithOddsMatrix()
   func testInitializationWithPlayerAPI()
   func testInitializationWithCasino()
   func testInitializationWithRecsys()
   ```

   Each test verifies:
   - Connector initializes without errors
   - Base connector is configured correctly
   - Session coordinator is passed through

3. **Request Delegation Tests:**
   ```swift
   func testRequestDelegatesToBaseConnector()
   func testRequestSSEDelegatesToBaseConnector()
   ```

   Verify that method calls forward to base connector.

4. **Connection State Tests:**
   ```swift
   func testConnectionStatePublisherForwardsFromBase()
   ```

   Verify connection state changes propagate.

5. **Helper Method Tests:**
   ```swift
   func testUpdateSessionTokenUpdatesCoordinator()
   ```

**Mocking Strategy:**

Use a mock `EveryMatrixBaseConnector` that records method calls.

---

## File References Summary

### Files to CREATE:

```
Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/
├── EveryMatrixAPIType.swift (NEW)
│   ├── Enum definition with 4 cases
│   ├── baseURL computed property
│   ├── identifier computed property
│   ├── authenticationStrategy computed property
│   └── defaultTimeout computed property
│
└── EveryMatrixUnifiedConnector.swift (NEW)
    ├── Wrapper class around EveryMatrixBaseConnector
    ├── init(apiType:sessionCoordinator:...)
    ├── request<T>() method
    ├── requestSSE<T>() method
    ├── connectionStatePublisher
    └── updateSessionToken() helper

Frameworks/ServicesProvider/Tests/ServicesProviderTests/Providers/Everymatrix/
└── EveryMatrixUnifiedConnectorTests.swift (NEW)
    ├── Configuration tests (4 tests)
    ├── Initialization tests (4 tests)
    ├── Delegation tests (2 tests)
    ├── Connection state tests (1 test)
    └── Helper method tests (1 test)
```

### Files to READ for Context:

```
EveryMatrixUnifiedConfiguration.swift
├── Lines 20-40: Environment enum (.production, .staging, .development)
├── Lines 50-70: Base URL properties
│   ├── oddsMatrixBaseURL
│   ├── playerAPIBaseURL
│   ├── casinoAPIBaseURL
│   └── recsysAPIBaseURL
└── Lines 80-90: Default configuration values

EveryMatrixBaseConnector.swift
├── Lines 51-60: Initializer signature
├── Lines 67-168: request<T>() implementation
├── Lines 170-276: requestSSE<T>() implementation
└── Lines 10-14: connectionStatePublisher

EveryMatrixOddsMatrixAPIConnector.swift (Reference for pattern)
├── Lines 15-21: Simple initialization pattern
└── Note: Only passes identifier to base class

EveryMatrixPlayerAPIConnector.swift
└── Lines 27-34: updateSessionToken() implementation
```

### Files NOT to MODIFY:

```
✅ Keep these unchanged:
├── EveryMatrixOddsMatrixAPIConnector.swift
├── EveryMatrixPlayerAPIConnector.swift
├── EveryMatrixCasinoConnector.swift
├── EveryMatrixRecsysAPIConnector.swift
├── EveryMatrixBettingProvider.swift
├── EveryMatrixPrivilegedAccessManager.swift
├── EveryMatrixCasinoProvider.swift
├── EveryMatrixProvider.swift
└── Client.swift
```

Phase 2 is **additive only** - no existing code is modified.

---

## Testing Requirements

### Unit Test Coverage Goals

- **EveryMatrixAPIType:** 100% coverage
  - All enum cases
  - All computed properties
  - Different environment configurations

- **EveryMatrixUnifiedConnector:** 100% coverage
  - All public methods
  - Delegation to base connector
  - Error propagation

### Integration Tests

**Create integration test:**
`EveryMatrixUnifiedConnectorIntegrationTests.swift`

**Test scenarios:**

1. **OddsMatrix API Integration:**
   - Make real request to staging API
   - Verify authentication headers
   - Verify response parsing

2. **PlayerAPI Integration:**
   - Login flow
   - Get user balance
   - Verify session token handling

3. **Casino API Integration:**
   - Get casino categories
   - Verify Cookie header
   - Verify response parsing

4. **Recsys API Integration:**
   - Get recommendations
   - Verify no session token
   - Verify API key in query params

**Important:** These tests require:
- Staging environment access
- Valid test credentials
- Network connectivity

Run these tests manually, not in CI/CD (to avoid flaky network failures).

### Manual Testing Checklist

After implementing Phase 2:

**Smoke Tests:**
- [ ] Create OddsMatrix unified connector
- [ ] Create PlayerAPI unified connector
- [ ] Create Casino unified connector
- [ ] Create Recsys unified connector
- [ ] Verify all 4 initialize without errors
- [ ] Verify base URLs are correct for staging
- [ ] Verify auth strategies are correct types

**No Functional Testing Yet:**
Phase 2 is additive - we're not using the unified connector in production yet.
Functional testing happens in Phase 3 when we migrate providers.

---

## Context: Configuration Management

### EveryMatrixUnifiedConfiguration

**File:** `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixUnifiedConfiguration.swift`

This is a **singleton** that manages environment-specific configuration:

```swift
// Usage:
EveryMatrixUnifiedConfiguration.shared.environment = .staging

// Then access base URLs:
let oddsURL = EveryMatrixUnifiedConfiguration.shared.oddsMatrixBaseURL
```

**Environment Types:**
1. `.production` - Live production APIs
2. `.staging` - Staging/UAT environment (most development)
3. `.development` - Local development/testing

**Key Properties:**
- `domainId: String` - EveryMatrix domain identifier (e.g., "4093")
- `defaultTimeout: TimeInterval` - Request timeout (30 seconds)
- `defaultLanguage: String` - API language (e.g., "en")
- `defaultPlatform: String` - Platform identifier (e.g., "iOS")

**Important:** Configuration is set once at app startup in `Client.swift:59-69`.

---

## Context: Why This Architecture?

### Benefits of Unified Connector

1. **Single Source of Truth:**
   - All API configuration in one enum
   - No scattered logic across 4 files

2. **Easier to Add New APIs:**
   - Add one enum case
   - Define baseURL, identifier, authStrategy
   - Done! No new class needed

3. **Better Testability:**
   - Mock API types easily
   - Test all configurations in one test suite

4. **Reduced Code Duplication:**
   - 4 nearly-identical classes → 1 unified class
   - ~150 lines of code eliminated

### Why Keep It As Separate Instances?

You might ask: "Why not make it a true singleton?"

**Answer:** Different providers need different instances:
- `BettingProvider` needs OddsMatrix connector
- `PrivilegedAccessManager` needs PlayerAPI connector
- `CasinoProvider` needs Casino connector
- `EventsProvider` needs Recsys connector

They can't share the same instance because they call different APIs.

The unification is at the **class level**, not the **instance level**.

---

## Success Criteria

After Phase 2 is complete:

✅ **EveryMatrixAPIType enum exists with 4 cases**
✅ **EveryMatrixUnifiedConnector class exists and compiles**
✅ **All unit tests pass (100% coverage)**
✅ **Integration tests pass in staging**
✅ **Manual smoke tests verify correct initialization**
✅ **No existing code modified (truly additive)**
✅ **Documentation updated**

---

## Rollback Plan

Phase 2 changes are **additive only**, so rollback is simple:

1. **If issues discovered:**
   - Don't use the new classes yet
   - They're not integrated into production flow

2. **If build breaks:**
   - Delete new files
   - No other changes to revert

**Risk is VERY LOW because:**
- No production code uses unified connector yet
- No existing files modified
- Can be safely deleted if not needed

---

## Common Pitfalls

⚠️ **Don't modify existing connectors**
This phase is additive only. Resist the temptation to "improve" existing code.

⚠️ **Don't forget combo Recsys URL**
Recsys has TWO base URLs (single bets and combo bets). The enum should handle the default; combo URL will be addressed in Phase 3.

⚠️ **Respect environment switching**
Base URLs change based on `EveryMatrixUnifiedConfiguration.shared.environment`. Test in both staging and production configurations.

⚠️ **Include updateSessionToken()**
This helper method from PlayerAPIConnector is useful. Include it in unified connector even though it's not strictly required.

---

## Validation Checklist

Before moving to Phase 3:

- [ ] EveryMatrixAPIType enum compiles and tests pass
- [ ] EveryMatrixUnifiedConnector compiles and tests pass
- [ ] All 4 API types can be initialized
- [ ] Base URLs match existing connector behavior
- [ ] Auth strategies match existing connector behavior
- [ ] Code review completed
- [ ] Documentation merged
- [ ] No existing code modified
- [ ] Git branch is clean and ready for Phase 3

---

## Next Phase

After Phase 2 is complete and validated:
→ Proceed to `PHASE_3_Provider_Migration.md`

**Phase 3 will:**
- Integrate unified connector into production
- Add feature flags for safe rollout
- Migrate providers one-by-one
- Monitor for issues
