# Phase 1: Extract Authentication Strategy Pattern

## Objective

Remove hardcoded Casino authentication logic from `EveryMatrixBaseConnector` and replace it with a pluggable authentication strategy pattern.

**Duration:** 1-2 days
**Risk Level:** Low
**Breaking Changes:** None

---

## Current Problem

### Hardcoded Logic in Base Class

**File:** `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixBaseConnector.swift`

**Lines 299-303:**
```swift
// Special handling for Casino API (uses Cookie header)
if apiIdentifier == "Casino" {
    request.setValue("sessionId=\(session.sessionId)", forHTTPHeaderField: "Cookie")
    print("[EveryMatrix-\(apiIdentifier)] Added session as Cookie header")
}
```

**Why this is bad:**
1. Base class knows about specific subclass requirements (violates Liskov Substitution Principle)
2. Adding new auth types requires modifying base class (violates Open/Closed Principle)
3. Makes testing harder (can't mock auth behavior)
4. String comparison on `apiIdentifier` is fragile

---

## Target Architecture

### Strategy Pattern

```
┌─────────────────────────────────────┐
│ EveryMatrixBaseConnector            │
│                                     │
│ - authStrategy: AuthenticationStrategy │ ← Injected dependency
│                                     │
│ func addAuthHeaders(to request)    │
│   authStrategy.apply(to: request)  │ ← Delegates to strategy
└─────────────────────────────────────┘
                  ↓
        ┌─────────────────┐
        │ AuthStrategy    │ ← Protocol
        │ (protocol)      │
        └─────────────────┘
                  ↑
         ┌────────┼────────┐
         │        │        │
    ┌────────┐ ┌────────┐ ┌────────┐
    │Session │ │Cookie  │ │APIKey  │
    │Token   │ │Auth    │ │Auth    │
    └────────┘ └────────┘ └────────┘
```

---

## Implementation Steps

### Step 1: Create Authentication Strategy Protocol

**Create new file:**
`Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Authentication/EveryMatrixAuthenticationStrategy.swift`

**What to implement:**

1. **Protocol Definition:**
   - Method to add authentication headers to URLRequest
   - Method to add authentication headers to dictionary (for SSE)
   - Required session/credential parameters

2. **SessionTokenAuthStrategy:**
   - Default strategy for most APIs
   - Adds `X-SessionId` header
   - Optionally adds `X-UserId` header
   - Uses endpoint's `authHeaderKey(for:)` for custom header names

3. **CookieAuthStrategy:**
   - Used by Casino API
   - Adds `Cookie: sessionId={token}` header
   - Same functionality as current hardcoded logic

4. **APIKeyAuthStrategy:**
   - Used by Recsys API
   - Does NOT use session tokens
   - Auth handled via query parameters (not headers)
   - Strategy can be no-op for headers

**Key Context:**

Current auth header logic is in `EveryMatrixBaseConnector.swift`:
- Lines 280-304: `addAuthenticationHeaders(to request:session:endpoint:)`
- Lines 306-330: `addAuthenticationHeadersToDict(_:session:endpoint:)`

You need to **extract** this logic into strategy implementations.

**Important endpoint customization:**
```swift
// Endpoints can customize header keys via:
endpoint.authHeaderKey(for: .sessionId)  // Returns custom header name or nil
endpoint.authHeaderKey(for: .userId)     // Returns custom header name or nil
```

---

### Step 2: Modify EveryMatrixBaseConnector

**File:** `EveryMatrixBaseConnector.swift`

**What to change:**

1. **Add authStrategy property:**
   ```swift
   /// Authentication strategy for this connector
   private let authStrategy: EveryMatrixAuthenticationStrategy
   ```

2. **Update initializer:**
   - Add `authStrategy` parameter with default value
   - Default should be `SessionTokenAuthStrategy()`

3. **Replace hardcoded logic:**
   - Lines 280-304: Replace with `authStrategy.apply(to: &request, session: session, endpoint: endpoint)`
   - Lines 306-330: Replace with `authStrategy.apply(to: &headers, session: session, endpoint: endpoint)`
   - **Remove the `if apiIdentifier == "Casino"` block entirely**

4. **Keep everything else unchanged:**
   - Request retry logic (lines 64-168)
   - SSE streaming (lines 170-276)
   - Error handling (lines 332-419)
   - Connection state management

**Critical:** Do NOT change the method signatures of:
- `request<T>(_ endpoint:)` (line 67)
- `requestSSE<T>(_ endpoint:decodingType:)` (line 175)

These are public APIs used by all providers.

---

### Step 3: Update Casino Connector

**File:** `EveryMatrixCasinoConnector.swift`

**Current code (lines 8-17):**
```swift
init(sessionCoordinator: EveryMatrixSessionCoordinator,
     session: URLSession = .shared,
     decoder: JSONDecoder = JSONDecoder()) {
    super.init(sessionCoordinator: sessionCoordinator,
               apiIdentifier: "Casino",
               session: session,
               decoder: decoder)

    setupNetworkMonitoring()
}
```

**What to change:**

1. Inject `CookieAuthStrategy()` into super.init
2. Keep everything else the same
3. Leave `setupNetworkMonitoring()` as-is (will be addressed in Phase 4)

---

### Step 4: Update Other Connectors (Optional but Recommended)

**Files to update:**
- `EveryMatrixOddsMatrixAPIConnector.swift`
- `EveryMatrixPlayerAPIConnector.swift`
- `EveryMatrixRecsysAPIConnector.swift`

**What to change:**

Add explicit `SessionTokenAuthStrategy()` to super.init for clarity:
```swift
super.init(
    sessionCoordinator: sessionCoordinator,
    apiIdentifier: "OddsMatrix",
    authStrategy: SessionTokenAuthStrategy(),  // ← Add this line
    session: session,
    decoder: decoder
)
```

**Note:** This is optional if you made `SessionTokenAuthStrategy()` the default in EveryMatrixBaseConnector.

---

## File References Summary

### Files to CREATE:
```
Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Authentication/
└── EveryMatrixAuthenticationStrategy.swift (NEW)
```

### Files to MODIFY:
```
Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/
├── EveryMatrixBaseConnector.swift
│   ├── Line 29: Add authStrategy property
│   ├── Lines 51-60: Update init to accept authStrategy
│   ├── Lines 280-304: Replace with strategy.apply()
│   ├── Lines 306-330: Replace with strategy.apply()
│   └── Remove: Lines 299-303 (Casino special case)
│
├── EveryMatrixCasinoConnector.swift
│   └── Lines 8-17: Inject CookieAuthStrategy
│
├── EveryMatrixOddsMatrixAPIConnector.swift (optional)
│   └── Lines 15-21: Inject SessionTokenAuthStrategy explicitly
│
├── EveryMatrixPlayerAPIConnector.swift (optional)
│   └── Lines 15-22: Inject SessionTokenAuthStrategy explicitly
│
└── EveryMatrixRecsysAPIConnector.swift (optional)
    └── Lines 12-18: Inject SessionTokenAuthStrategy explicitly
```

### Files to READ for context:
```
EveryMatrixSessionCoordinator.swift
├── Lines 169-177: getSessionToken() and getUserId()
└── Lines 180-188: updateSession()

Endpoint protocol:
└── authHeaderKey(for:) method - defines custom header names per endpoint
```

---

## Testing Requirements

### Unit Tests to Write

**Create test file:**
`Frameworks/ServicesProvider/Tests/ServicesProviderTests/Providers/Everymatrix/EveryMatrixAuthenticationStrategyTests.swift`

**Test cases:**

1. **SessionTokenAuthStrategy Tests:**
   - ✅ Adds X-SessionId header with correct value
   - ✅ Adds X-UserId header when endpoint requires it
   - ✅ Respects custom header names from endpoint.authHeaderKey()
   - ✅ Applies to both URLRequest and Dictionary

2. **CookieAuthStrategy Tests:**
   - ✅ Adds Cookie header in format: `sessionId={token}`
   - ✅ Does NOT add X-SessionId header
   - ✅ Applies to both URLRequest and Dictionary

3. **APIKeyAuthStrategy Tests:**
   - ✅ Does not modify request headers (no-op)
   - ✅ Applies to both URLRequest and Dictionary without errors

### Integration Tests

**Existing test file:**
`Frameworks/ServicesProvider/Tests/ServicesProviderTests/Providers/Everymatrix/EveryMatrixBaseConnectorTests.swift`

**Update these tests:**
1. Mock authentication strategy
2. Verify strategy.apply() is called
3. Verify no hardcoded Casino logic remains

### Manual Testing Checklist

**Casino API:**
- [ ] Launch casino game (verify Cookie header works)
- [ ] Get casino categories
- [ ] Search casino games
- [ ] Get recommended games (authenticated)

**OddsMatrix API:**
- [ ] Place a bet
- [ ] Get bet history
- [ ] Calculate cashout
- [ ] Execute cashout

**PlayerAPI:**
- [ ] Login
- [ ] Get user balance
- [ ] Get transaction history

**Recsys API:**
- [ ] Get single bet recommendations
- [ ] Get combo recommendations

---

## Context: How Authentication Currently Works

### Standard Flow (SessionToken)

1. Provider calls `connector.request(endpoint)`
2. Connector checks `endpoint.requireSessionKey`
3. If true, calls `sessionCoordinator.publisherWithValidToken()`
4. Gets `EveryMatrixSessionResponse(sessionId, userId)`
5. Adds headers via `addAuthenticationHeaders()`:
   ```swift
   request.setValue(session.sessionId, forHTTPHeaderField: "X-SessionId")
   // Optionally:
   request.setValue(session.userId, forHTTPHeaderField: "X-UserId")
   ```
6. Makes HTTP request
7. If 401/403, refreshes token and retries

### Casino Flow (Cookie - Special Case)

Same as above, but step 5 becomes:
```swift
request.setValue("sessionId=\(session.sessionId)", forHTTPHeaderField: "Cookie")
```

### Recsys Flow (API Key - No Session)

1. Provider calls `connector.request(endpoint)`
2. Endpoint has `requireSessionKey: false`
3. No authentication headers added
4. API key is in **query parameters**, not headers:
   ```swift
   URLQueryItem(name: "key", value: recsysAPIKey)
   ```

---

## Endpoint Authentication Customization

**Important:** Some endpoints use custom header names!

**Example from OddsMatrixAPI:**
```swift
case placeBet:
    headers = [
        "x-sessionid",      // ← Lowercase, no dash
        "x-operatorid"
    ]

case getOpenBets:
    headers = [
        "x-session-id",     // ← Lowercase, WITH dash
        "x-user-id",
        "x-operator-id"
    ]

case executeCashoutV2:
    headers = [
        "X-SessionId",      // ← Title case
        "userId",           // ← camelCase
        "X-OperatorId"
    ]
```

The strategy must respect these variations via `endpoint.authHeaderKey(for:)`.

---

## Success Criteria

After Phase 1 is complete:

✅ **No hardcoded `if apiIdentifier == "Casino"` logic in base class**
✅ **All authentication logic extracted into strategy classes**
✅ **Casino API still works with Cookie authentication**
✅ **All other APIs work with SessionToken authentication**
✅ **Recsys API works with no session token**
✅ **All existing tests pass**
✅ **New unit tests written for all 3 strategies**
✅ **Manual testing confirms no regressions**

---

## Rollback Plan

If Phase 1 causes issues:

1. **Immediate rollback** (< 5 minutes):
   - Revert commits related to Phase 1
   - Restore hardcoded Casino logic in EveryMatrixBaseConnector

2. **Partial rollback**:
   - Keep strategy pattern but revert CasinoConnector changes
   - Add back hardcoded Casino logic as fallback

**Risk is LOW because:**
- Changes are localized to connector classes
- No provider code changes
- Existing behavior is preserved

---

## Common Pitfalls

⚠️ **Don't forget SSE authentication**
The `addAuthenticationHeadersToDict()` method is used by SSE streaming (cashout). Make sure your strategy implements both URLRequest and Dictionary variants.

⚠️ **Respect endpoint header customization**
Don't hardcode "X-SessionId" - use `endpoint.authHeaderKey(for: .sessionId)`.

⚠️ **Test with real API credentials**
Unit tests with mocks aren't enough - manually test each API in staging environment.

⚠️ **Check capitalization**
HTTP headers are case-insensitive per spec, but EveryMatrix APIs have specific expectations. Match existing behavior exactly.

---

## Next Phase

After Phase 1 is complete and tested:
→ Proceed to `PHASE_2_Unified_Connector.md`
