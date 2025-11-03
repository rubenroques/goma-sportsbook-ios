# EveryMatrix SSE Cashout Implementation - Authentication Integration

## Date
15 October 2025

### Project / Branch
sportsbook-ios / rr/register_fields_fix

### Goals for this session
- Fix 7 compilation errors in SSE cashout implementation
- Understand EveryMatrix authentication architecture
- Integrate SSE support into base connector with proper auth
- Follow established patterns from existing HTTP request implementation

### Achievements
- [x] Analyzed EveryMatrix authentication architecture (`publisherWithValidToken()` pattern)
- [x] Integrated SSE support directly into `EveryMatrixBaseConnector`
- [x] Fixed all 7 compilation errors
- [x] Unified authentication logic - SSE now uses same pattern as HTTP requests
- [x] Added stub implementations to Goma and SportRadar providers
- [x] Fixed SubscribableContent enum cases (`.connected(subscription:)`, `.disconnected`)

### Issues / Bugs Hit
- [x] **ServiceProviderError.invalidURL doesn't exist** - Used `.errorMessage(message: "Invalid URL")` instead
- [x] **sessionCoordinator.sessionId/userId wrong access pattern** - These are methods returning Publishers, not properties. Used `publisherWithValidToken()` instead
- [x] **SubscribableContent wrong case names** - Used `.connect` instead of `.connected(subscription:)` and `.disconnect` instead of `.disconnected`
- [x] **Combine type mismatch in flatMap** - flatMap was returning `AnyPublisher<SSEEvent<T>, ServiceProviderError>` but should return `AnyPublisher<SSEEvent<T>, Error>`, then use final `.mapError` to convert to ServiceProviderError

### Key Decisions
- **Integrated SSE into EveryMatrixBaseConnector** instead of custom auth in OddsMatrixAPIConnector
  - **Rationale**: Reuses existing `publisherWithValidToken()` infrastructure, supports automatic token refresh on 401/403, follows DRY principle
  - **Impact**: Reduced OddsMatrixAPIConnector from ~45 lines to 5 lines, centralized auth logic

- **Used existing Subscription(id:) initializer** instead of creating new class
  - **Rationale**: Subscription.swift already has simple `init(id: String)` for basic cases
  - **Impact**: No new classes needed, cleaner implementation

- **Followed exact error handling pattern from request() method**
  - **Rationale**: Consistency across codebase, proven pattern that works
  - **Pattern**: `publisherWithValidToken()` → `flatMap` returning Error → final `mapError` converting to ServiceProviderError

### Architecture Notes

**EveryMatrix Session Coordinator Pattern**:
```swift
// SessionCoordinator stores full session response (sessionId + userId together)
struct EveryMatrixSessionResponse {
    let sessionId: String
    let userId: String
}

// publisherWithValidToken() returns complete session, handles refresh automatically
func publisherWithValidToken(forceRefresh: Bool = false) -> AnyPublisher<EveryMatrixSessionResponse, Error>
```

**Token Distribution**:
- `playerSessionToken` and `oddsMatrixSessionToken` are NOT different tokens
- They're the same `sessionId` distributed to different publisher channels
- Both use `currentSession.sessionId` internally

**Authentication Flow**:
1. Get session via `publisherWithValidToken()` (auto-refreshes if needed)
2. Extract sessionId and userId from response
3. Use `endpoint.authHeaderKey(for:)` to get correct header names per API
4. Different APIs use different header formats:
   - Place Bet API: `x-sessionid` (no hyphen)
   - MyBets APIs: `x-session-id` (with hyphen)
   - New Cashout API: `X-SessionId` (capitalized), `userId` (no x- prefix)

### Code Changes

**Files Modified (7)**:
- `EveryMatrixBaseConnector.swift` - Added SSE support with authentication
- `EveryMatrixOddsMatrixAPIConnector.swift` - Simplified to delegate to base connector
- `EveryMatrixBettingProvider.swift` - Fixed SubscribableContent cases
- `GomaProvider.swift` - Added cashout method stubs
- `SportRadarBettingProvider.swift` - Added cashout method stubs

**Key Implementation**:
```swift
// EveryMatrixBaseConnector.swift
func requestSSE<T: Decodable>(
    _ endpoint: Endpoint,
    decodingType: T.Type
) -> AnyPublisher<SSEEvent<T>, ServiceProviderError> {

    if endpoint.requireSessionKey {
        return sessionCoordinator.publisherWithValidToken()
            .flatMap { [weak self] session -> AnyPublisher<SSEEvent<T>, Error> in
                // Add auth headers using session response
                var headers = endpoint.headers ?? [:]
                self?.addAuthenticationHeadersToDict(&headers, session: session, endpoint: endpoint)

                // Make SSE request
                return self.sseManager.subscribe(...)
                    .mapError { error -> Error in
                        // Map to generic Error inside flatMap
                        return ServiceProviderError.errorMessage(...)
                    }
            }
            .mapError { error -> ServiceProviderError in
                // Final conversion to ServiceProviderError
                if let serviceError = error as? ServiceProviderError {
                    return serviceError
                }
                return ServiceProviderError.errorMessage(message: error.localizedDescription)
            }
    }
}
```

### Useful Files / Links
- [EveryMatrixBaseConnector.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixBaseConnector.swift) - Core SSE integration
- [EveryMatrixSessionCoordinator.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixSessionCoordinator.swift) - Token management
- [BettingProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/BettingProvider.swift) - Protocol with SSE methods
- [EveryMatrixBettingProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixBettingProvider.swift) - SSE implementation
- [Subscription.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Common/Subscription.swift) - Used for SubscribableContent

### Experiments & Notes
- Initially tried accessing `sessionCoordinator.sessionId` as property → compilation error
- Discovered sessionId is a method returning Publisher, not a stored property
- Found that `publisherWithValidToken()` is the correct pattern used throughout EveryMatrix code
- Realized SSE needs same error handling pattern as HTTP requests (Error → ServiceProviderError conversion)

### Next Steps
1. Test SSE cashout in runtime with actual EveryMatrix API
2. Verify automatic token refresh works for SSE requests (401/403 scenarios)
3. Consider adding retry logic for SSE connection failures
4. Document SSE usage patterns for future API integrations
5. Add integration tests for SSE authentication flow
