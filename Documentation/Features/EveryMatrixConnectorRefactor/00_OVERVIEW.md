# EveryMatrix Connector Refactor - Migration Overview

## Executive Summary

This migration refactors the EveryMatrix HTTP connector architecture from **4 separate subclass connectors** to a **single unified connector** with pluggable authentication strategies. The goal is to eliminate code duplication, remove hardcoded logic from the base class, and simplify future API additions.

---

## Current Architecture Problems

### 1. Unnecessary Subclass Proliferation
Four connector subclasses exist that add minimal value:
- `EveryMatrixOddsMatrixAPIConnector` - Only passes `"OddsMatrix"` identifier
- `EveryMatrixPlayerAPIConnector` - Only adds `updateSessionToken()` helper
- `EveryMatrixCasinoConnector` - Shares base URL with PlayerAPI, has broken network monitoring
- `EveryMatrixRecsysAPIConnector` - Only passes `"RecsysAPI"` identifier

### 2. Hardcoded Special Cases
`EveryMatrixBaseConnector` contains hardcoded Casino-specific logic:
```swift
// Line 299-303 in EveryMatrixBaseConnector.swift
if apiIdentifier == "Casino" {
    request.setValue("sessionId=\(session.sessionId)", forHTTPHeaderField: "Cookie")
}
```

This violates the Open/Closed Principle.

### 3. Mixed Responsibilities
Some connectors share base URLs but exist as separate classes:
- PlayerAPI: `https://betsson-api.stage.norway.everymatrix.com`
- CasinoAPI: `https://betsson-api.stage.norway.everymatrix.com` ← Same URL!

---

## Target Architecture

### Single Unified Connector
```
EveryMatrixUnifiedConnector
├── Wraps EveryMatrixBaseConnector
├── Takes EveryMatrixAPIType enum parameter
└── Injects appropriate AuthenticationStrategy
```

### API Type Enum
Encapsulates all API-specific configuration:
- Base URL
- API identifier
- Authentication strategy
- Timeout configuration

### Authentication Strategy Pattern
Removes hardcoded auth logic via protocol-based strategies:
- `SessionTokenAuth` - Standard X-SessionId header
- `CookieAuth` - Cookie: sessionId={token} header
- `APIKeyAuth` - Query parameter-based auth (Recsys)

---

## Migration Phases

### Phase 1: Extract Auth Strategy (1-2 days)
**Goal:** Remove hardcoded Casino logic from base class
**Risk:** Low
**Breaking Changes:** None

### Phase 2: Introduce Unified Connector (2-3 days)
**Goal:** Add new connector alongside existing ones
**Risk:** Low
**Breaking Changes:** None (additive only)

### Phase 3: Migrate Providers (3-5 days)
**Goal:** Switch providers to unified connector with feature flags
**Risk:** High (touches critical flows)
**Breaking Changes:** None (feature-flagged)

### Phase 4: Remove Legacy Code (1 day)
**Goal:** Delete old connectors after successful migration
**Risk:** Low
**Breaking Changes:** None (already migrated)

**Total Duration:** 2-3 weeks with proper testing

---

## Key Architectural Decisions

### Decision 1: Keep EveryMatrixBaseConnector Intact
**Rationale:** Base class handles complex retry logic, SSE streaming, and token refresh. Don't touch what works.

**Approach:** Wrap it, don't replace it.

### Decision 2: Feature Flags Per API Type
**Rationale:** Enables instant rollback if an API migration fails.

**Implementation:**
```swift
// In Client.swift
let useUnifiedConnector_OddsMatrix = true
let useUnifiedConnector_PlayerAPI = false
```

### Decision 3: Staged Rollout
**Rationale:** Betting and payment flows are revenue-critical.

**Rollout Order:**
1. Recsys (low risk - no session tokens)
2. OddsMatrix (high risk - extensive testing)
3. PlayerAPI (critical - authentication)
4. Casino (final - special auth)

---

## File Structure

### Documentation Files (This Folder)
```
Documentation/Features/EveryMatrixConnectorRefactor/
├── 00_OVERVIEW.md                    ← You are here
├── PHASE_1_Auth_Strategy.md          ← Phase 1 implementation guide
├── PHASE_2_Unified_Connector.md      ← Phase 2 implementation guide
├── PHASE_3_Provider_Migration.md     ← Phase 3 implementation guide
├── PHASE_4_Legacy_Cleanup.md         ← Phase 4 implementation guide
└── TESTING_STRATEGY.md               ← Comprehensive test plan
```

### Source Code Locations
```
Frameworks/ServicesProvider/Sources/ServicesProvider/
├── Providers/Everymatrix/
│   ├── EveryMatrixBaseConnector.swift              ← Core logic (DO NOT BREAK)
│   ├── EveryMatrixOddsMatrixAPIConnector.swift     ← Delete in Phase 4
│   ├── EveryMatrixPlayerAPIConnector.swift         ← Delete in Phase 4
│   ├── EveryMatrixCasinoConnector.swift            ← Delete in Phase 4
│   ├── EveryMatrixRecsysAPIConnector.swift         ← Delete in Phase 4
│   ├── EveryMatrixSessionCoordinator.swift         ← Token management (READ ONLY)
│   ├── EveryMatrixBettingProvider.swift            ← Uses OddsMatrix connector
│   ├── EveryMatrixPrivilegedAccessManager.swift    ← Uses PlayerAPI connector
│   ├── EveryMatrixCasinoProvider.swift             ← Uses Casino connector
│   └── EveryMatrixProvider.swift                   ← Uses Recsys connector (EventsProvider)
└── Client.swift                                     ← Initializes all connectors
```

---

## Critical Context for All Phases

### Authentication Flow
1. Request made with current session token
2. If 401/403 error → `sessionCoordinator.publisherWithValidToken(forceRefresh: true)`
3. Session coordinator performs login with stored credentials
4. Retry original request with new token
5. **Only one retry attempt per request**

### Session Management
**EveryMatrixSessionCoordinator** (line 30-311):
- Stores `EveryMatrixSessionResponse(sessionId: String, userId: String)`
- Stores `EveryMatrixCredentials(username: String, password: String)` for re-auth
- Thread-safe via serial dispatch queue
- Provides `publisherWithValidToken()` for auto-refresh
- Shared across all HTTP connectors

### SSE (Server-Sent Events) Support
**Used for cashout value streaming** (EveryMatrixBettingProvider.swift:191-239):
- Endpoint: `GET /cashout/v1/cashout-value/{betId}`
- Returns real-time cashout value updates as odds change
- Uses `SSEManager` internally
- Same authentication as REST requests

### API Base URLs (Staging Environment)
```swift
// EveryMatrixUnifiedConfiguration.swift
playerAPIBaseURL:      "https://betsson-api.stage.norway.everymatrix.com"
oddsMatrixBaseURL:     "https://sports-api-stage.everymatrix.com"
casinoAPIBaseURL:      "https://betsson-api.stage.norway.everymatrix.com"
recsysAPIBaseURL:      "https://recsys-api-gateway-test-bshwjrve.ew.gateway.dev"
recsysComboAPIBaseURL: "https://recsys-combo-api-gateway-test-bshwjrve.nw.gateway.dev"
```

**Note:** PlayerAPI and CasinoAPI share the same base URL!

### Provider Dependencies
**Who uses which connector:**

| Provider | Connector | File Location |
|----------|-----------|---------------|
| EveryMatrixBettingProvider | OddsMatrixAPIConnector | EveryMatrixBettingProvider.swift:14 |
| EveryMatrixPrivilegedAccessManager | PlayerAPIConnector | EveryMatrixPrivilegedAccessManager.swift:14 |
| EveryMatrixCasinoProvider | CasinoConnector | EveryMatrixCasinoProvider.swift:6 |
| EveryMatrixEventsProvider | RecsysAPIConnector | EveryMatrixProvider.swift:19 |

**Initialization happens in:** `Client.swift:73-143`

---

## Success Criteria

✅ **All existing functionality works identically**
✅ **No increase in API error rates**
✅ **Code reduction: ~150 lines deleted**
✅ **Authentication logic centralized and testable**
✅ **Easier to add new EveryMatrix APIs** (just add enum case)
✅ **No hardcoded special cases in base class**

---

## Rollback Strategy

### Instant Rollback (< 5 minutes)
1. Flip feature flag in Client.swift
2. Redeploy app or server restart
3. Old connectors remain functional

### Per-API Rollback
Each API can be rolled back independently:
```swift
// Rollback just OddsMatrix if betting fails
let useUnifiedConnector_OddsMatrix = false  // ← Flip to false
let useUnifiedConnector_PlayerAPI = true    // ← Others stay enabled
```

### No Data Migration
This is a pure code refactor - no database changes, no data loss risk.

---

## Dependencies Between Phases

```
Phase 1 (Auth Strategy)
    ↓ (Depends on auth protocol)
Phase 2 (Unified Connector)
    ↓ (Uses unified connector)
Phase 3 (Provider Migration)
    ↓ (Safe after migration complete)
Phase 4 (Cleanup)
```

**You must complete phases in order.**

---

## Next Steps

1. Read `PHASE_1_Auth_Strategy.md` for detailed implementation guide
2. Each phase document contains:
   - Complete file references
   - Line number context
   - Before/after architecture
   - Testing requirements
   - Risk mitigation strategies

---

## Questions or Issues?

If you encounter issues during implementation:
1. Check the specific phase documentation
2. Review `TESTING_STRATEGY.md` for debugging approaches
3. Refer back to this overview for architectural context
4. Check git history for recent changes to connector files

**Remember:** This is production code handling betting and payments. Test thoroughly.
