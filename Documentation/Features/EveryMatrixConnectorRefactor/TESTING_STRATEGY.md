# Testing Strategy for EveryMatrix Connector Refactor

## Overview

This document provides a comprehensive testing strategy for all 4 phases of the EveryMatrix connector refactor. Each phase has specific testing requirements to ensure no regressions are introduced.

---

## General Testing Principles

### Test Pyramid

```
           /\
          /  \         E2E Manual Tests (10%)
         /    \        - Critical user flows
        /------\       - Smoke tests in staging/production
       /        \
      /  Integr  \     Integration Tests (30%)
     /   ation    \    - API calls with real endpoints
    /    Tests     \   - Authentication flows
   /--------------  \
  /                  \ Unit Tests (60%)
 /      Unit Tests    \ - Logic validation
/____________________\ - Mock interactions
```

### Testing Environments

1. **Local Development:** Unit tests, mocked API calls
2. **Staging:** Integration tests, end-to-end flows
3. **Production:** Smoke tests, monitoring, gradual rollout

---

## Phase 1: Authentication Strategy Tests

### Unit Tests

**File:** `EveryMatrixAuthenticationStrategyTests.swift`

#### SessionTokenAuthStrategy Tests

```swift
func testSessionTokenAuth_AddsStandardHeaders()
// Verify: X-SessionId header added

func testSessionTokenAuth_AddsUserIdWhenRequired()
// Verify: X-UserId header added when endpoint requests it

func testSessionTokenAuth_RespectsCustomHeaderNames()
// Verify: Uses endpoint.authHeaderKey() for custom names

func testSessionTokenAuth_WorksForURLRequest()
// Verify: Modifies URLRequest correctly

func testSessionTokenAuth_WorksForDictionary()
// Verify: Modifies header dictionary (for SSE)

func testSessionTokenAuth_HandlesNilUserId()
// Verify: Doesn't crash when userId is nil
```

#### CookieAuthStrategy Tests

```swift
func testCookieAuth_AddsCookieHeader()
// Verify: Cookie: sessionId={token} format

func testCookieAuth_DoesNotAddSessionIdHeader()
// Verify: No X-SessionId header added

func testCookieAuth_WorksForURLRequest()
// Verify: Modifies URLRequest correctly

func testCookieAuth_WorksForDictionary()
// Verify: Modifies header dictionary (for SSE)
```

#### APIKeyAuthStrategy Tests

```swift
func testAPIKeyAuth_DoesNotModifyRequest()
// Verify: No headers added (API key in query params)

func testAPIKeyAuth_WorksForURLRequest()
// Verify: No-op for URLRequest

func testAPIKeyAuth_WorksForDictionary()
// Verify: No-op for dictionary
```

### Integration Tests

**File:** `EveryMatrixBaseConnectorIntegrationTests.swift`

```swift
func testSessionTokenAuthWithRealAPI()
// Make real call to PlayerAPI with SessionTokenAuth
// Verify: Request succeeds

func testCookieAuthWithRealAPI()
// Make real call to CasinoAPI with CookieAuth
// Verify: Request succeeds

func testAPIKeyAuthWithRealAPI()
// Make real call to RecsysAPI with APIKeyAuth
// Verify: Request succeeds
```

### Manual Testing Checklist

- [ ] Login with PlayerAPI (SessionToken)
- [ ] Get casino categories (Cookie)
- [ ] Get recommendations (API Key)
- [ ] Check HTTP logs for correct header format
- [ ] Test in staging environment
- [ ] Test in production environment

---

## Phase 2: Unified Connector Tests

### Unit Tests

**File:** `EveryMatrixUnifiedConnectorTests.swift`

#### Configuration Tests

```swift
func testOddsMatrixConfiguration()
// Verify: Correct base URL, identifier, auth strategy

func testPlayerAPIConfiguration()
// Verify: Correct base URL, identifier, auth strategy

func testCasinoConfiguration()
// Verify: Correct base URL, identifier, auth strategy

func testRecsysConfiguration()
// Verify: Correct base URL, identifier, auth strategy
```

#### Initialization Tests

```swift
func testInitializationWithOddsMatrix()
// Verify: Connector initializes without error

func testInitializationWithPlayerAPI()
// Verify: Connector initializes without error

func testInitializationWithCasino()
// Verify: Connector initializes without error

func testInitializationWithRecsys()
// Verify: Connector initializes without error
```

#### Delegation Tests

```swift
func testRequestDelegatesToBaseConnector()
// Verify: request() forwards to base connector

func testRequestSSEDelegatesToBaseConnector()
// Verify: requestSSE() forwards to base connector

func testConnectionStateForwardsFromBase()
// Verify: Connection state changes propagate

func testUpdateSessionTokenUpdatesCoordinator()
// Verify: Helper method updates session coordinator
```

### Integration Tests

**File:** `EveryMatrixUnifiedConnectorIntegrationTests.swift`

```swift
func testOddsMatrixAPIIntegration()
// Make real request to staging OddsMatrix API
// Verify: Authentication, response parsing

func testPlayerAPIIntegration()
// Make real login request
// Verify: Session token returned

func testCasinoAPIIntegration()
// Make real request to get categories
// Verify: Cookie header, response parsing

func testRecsysAPIIntegration()
// Make real request for recommendations
// Verify: No session token, API key works
```

### Manual Testing Checklist

- [ ] Create all 4 unified connectors
- [ ] Verify initialization without errors
- [ ] Check base URLs in logs
- [ ] Verify auth strategies are correct types
- [ ] No functional testing yet (not integrated)

---

## Phase 3: Provider Migration Tests

### Per-Provider Test Suites

#### RecsysAPI Migration Tests

**Manual testing:**
- [ ] Get single bet recommendations
- [ ] Get combo bet recommendations
- [ ] Verify recommendations display in UI
- [ ] Check API logs for correct base URL
- [ ] Verify no session token sent
- [ ] Test with feature flag ON
- [ ] Test with feature flag OFF
- [ ] Compare behavior (should be identical)

**Monitoring:**
- API response time < 1s
- No errors

#### OddsMatrix Migration Tests (CRITICAL)

**Manual testing:**
- [ ] **Place single bet** (revenue-critical!)
- [ ] **Place multiple bet**
- [ ] Get open bets (with pagination)
- [ ] Get settled bets
- [ ] Get won bets
- [ ] **Calculate cashout**
- [ ] **Execute cashout** (real money!)
- [ ] **SSE cashout streaming** (real-time updates)
- [ ] Test with invalid session (verify token refresh)
- [ ] Test bet placement failures
- [ ] Compare with old connector behavior
- [ ] Test with feature flag ON/OFF

**Monitoring:**
- Bet placement success rate > 99.5%
- API error rate < 0.5%
- Average bet placement time < 2s
- Cashout execution success rate > 99%

#### PlayerAPI Migration Tests (CRITICAL)

**Manual testing:**
- [ ] **User login** (blocks all access!)
- [ ] User registration (multi-step)
- [ ] Get user profile
- [ ] **Get user balance** (post-login)
- [ ] Get transaction history
  - [ ] Banking transactions
  - [ ] Wagering transactions
- [ ] Get banking web view (payments)
- [ ] Create booking code (share bet)
- [ ] Retrieve booking code
- [ ] Get recently played casino games
- [ ] Get most played casino games
- [ ] **Test token refresh on 401**
- [ ] Compare with old connector behavior
- [ ] Test with feature flag ON/OFF

**Monitoring:**
- Login success rate > 98%
- Registration completion rate (no decrease)
- Token refresh success rate > 99%

#### Casino Migration Tests

**Manual testing:**
- [ ] Get casino categories
- [ ] Get games by category (with pagination)
- [ ] Get game details
- [ ] Search casino games
- [ ] Get recommended games (authenticated)
- [ ] **Launch casino game** (verify URL)
- [ ] Check HTTP logs for Cookie header
- [ ] Test fun mode (guest)
- [ ] Test real money mode (authenticated)
- [ ] Compare with old connector behavior
- [ ] Test with feature flag ON/OFF

**Monitoring:**
- Casino game launch success rate > 99%
- Category load time < 3s

### Regression Test Suite

**File:** `EveryMatrixMigrationRegressionTests.swift`

Run this test suite after each migration:

```swift
func testBettingFlowEndToEnd()
// Login → Place bet → Check history → Cashout

func testAuthenticationFlow()
// Login → Get balance → Logout

func testCasinoFlow()
// Login → Get categories → Get games → Launch game

func testRecommendationsFlow()
// Get recommendations → Display in UI
```

### Automated Smoke Tests

**File:** `EveryMatrixSmokeTests.swift`

Run automatically after each deployment:

```swift
func testLogin()
func testPlaceBet()
func testGetBetHistory()
func testCalculateCashout()
func testGetCasinoCategories()
func testGetRecommendations()
```

**CI/CD Integration:**
```bash
# Run smoke tests after deployment
xcodebuild test -workspace Sportsbook.xcworkspace \
  -scheme BetssonCameroonApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:EveryMatrixSmokeTests
```

---

## Phase 4: Cleanup Tests

### Compilation Tests

```bash
# Clean build
xcodebuild clean -workspace Sportsbook.xcworkspace \
  -scheme BetssonCameroonApp

# Full build
xcodebuild build -workspace Sportsbook.xcworkspace \
  -scheme BetssonCameroonApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

**Expected:** No errors, no warnings

### Unit Tests

Run full test suite:
```bash
xcodebuild test -workspace Sportsbook.xcworkspace \
  -scheme BetssonCameroonApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

**Expected:** All tests pass

### Integration Tests

**Smoke test checklist:**
- [ ] Login works
- [ ] Place bet works
- [ ] Get bet history works
- [ ] Cashout works
- [ ] Casino games load
- [ ] Recommendations display

**Run in:** Staging first, then production

---

## Test Data Setup

### Staging Environment

**Test accounts:**
- Username: `testuser_staging`
- Password: (stored in test configuration)

**Test scenarios:**
- Valid credentials
- Invalid credentials
- Expired session token
- New user registration

### Mocked Data

**For unit tests:**

```swift
// Mock session response
let mockSession = EveryMatrixSessionResponse(
    sessionId: "mock-session-id-12345",
    userId: "12345"
)

// Mock credentials
let mockCredentials = EveryMatrixCredentials(
    username: "testuser",
    password: "testpass123"
)

// Mock endpoints
let mockLoginEndpoint = EveryMatrixPlayerAPI.login(
    username: "test",
    password: "test"
)
```

---

## Monitoring & Observability

### Key Metrics to Track

**API Health:**
- Success rate (target: > 99%)
- Average response time (target: < 2s)
- Error rate by status code (401, 403, 404, 500)

**Business Metrics:**
- Bet placement rate
- Login success rate
- Cashout execution rate
- Casino game launch rate

### Logging Strategy

**Add structured logs:**

```swift
print("🔄 [EveryMatrix-\(apiType.identifier)] Request: \(endpoint.endpoint)")
print("✅ [EveryMatrix-\(apiType.identifier)] Success: \(statusCode)")
print("❌ [EveryMatrix-\(apiType.identifier)] Error: \(error)")
print("🔑 [EveryMatrix-\(apiType.identifier)] Auth: \(authStrategy)")
```

**Log aggregation:**
- Collect logs from all API connectors
- Filter by API identifier
- Track error patterns

---

## Performance Testing

### Load Tests

**Scenario 1: Concurrent Bets**
- 100 concurrent bet placements
- Measure: Success rate, response time

**Scenario 2: High-Frequency Login**
- 50 logins per second
- Measure: Token refresh rate, failures

**Scenario 3: Casino Game Launches**
- 200 concurrent game launches
- Measure: URL generation time, load time

### Stress Tests

**Scenario 1: Token Expiration**
- Force all tokens to expire
- Verify: Automatic refresh works
- Measure: Refresh latency

**Scenario 2: Network Failures**
- Simulate network disconnection
- Verify: Proper error handling
- Measure: Reconnection time

---

## Security Testing

### Authentication Tests

```swift
func testTokenNotLeakedInLogs()
// Verify: Session tokens are not logged in plain text

func testCredentialsNotStored()
// Verify: Passwords are never persisted

func testCookieHttpOnly()
// Verify: Cookie header security

func testAPIKeyNotInLogs()
// Verify: Recsys API key not exposed
```

### Penetration Tests

- [ ] Test with invalid session tokens
- [ ] Test with expired tokens
- [ ] Test with malformed requests
- [ ] Test with SQL injection attempts
- [ ] Test with XSS attempts

---

## Test Coverage Goals

### Phase 1: Authentication Strategy
- **Target:** 100% code coverage
- **Unit tests:** All strategy implementations
- **Integration tests:** Real API calls

### Phase 2: Unified Connector
- **Target:** 100% code coverage
- **Unit tests:** All public methods
- **Integration tests:** All 4 API types

### Phase 3: Provider Migration
- **Target:** No decrease in overall coverage
- **Regression tests:** All critical flows
- **Manual tests:** Extensive user flows

### Phase 4: Cleanup
- **Target:** No decrease in coverage
- **Verify:** All tests still pass

---

## Test Execution Schedule

### Daily (Automated)

- Run unit test suite on every commit
- Run smoke tests on every deployment
- Monitor production metrics

### Weekly (Manual)

- Run full regression test suite
- Performance tests in staging
- Security scan

### Per-Phase (Manual)

- Comprehensive manual testing
- Stakeholder demo
- Production smoke tests

---

## Test Failure Handling

### Unit Test Failure

1. **Identify failing test**
2. **Debug locally**
3. **Fix issue**
4. **Verify fix**
5. **Push fix**

### Integration Test Failure

1. **Check staging environment**
2. **Verify API connectivity**
3. **Check credentials**
4. **Review API logs**
5. **Fix or escalate**

### Production Issue

1. **Immediate rollback** (flip feature flag)
2. **Investigate logs**
3. **Identify root cause**
4. **Fix in staging**
5. **Re-test**
6. **Deploy fix**

---

## Success Criteria

### Phase 1
✅ All auth strategy tests pass
✅ Integration tests confirm real API calls work
✅ No increase in error rates

### Phase 2
✅ All unified connector tests pass
✅ 100% code coverage
✅ Integration tests pass for all API types

### Phase 3
✅ All provider migration tests pass
✅ No regressions in functionality
✅ Production metrics remain stable
✅ Gradual rollout completes successfully

### Phase 4
✅ All tests pass after cleanup
✅ No compilation errors
✅ Production remains stable

---

## Test Artifacts

### Generated During Testing

- Test reports (XCTest results)
- Code coverage reports (Xcode coverage)
- Performance test results
- API logs (staging and production)
- Monitoring dashboards

### Archived After Completion

- Test execution logs
- Bug reports and fixes
- Performance baseline data
- Migration validation reports

---

## Continuous Improvement

### Post-Migration Review

After Phase 4 completion:

1. **Analyze test effectiveness**
   - Which tests caught bugs?
   - Which tests were too slow?
   - Any gaps in coverage?

2. **Update test strategy**
   - Add missing test cases
   - Remove redundant tests
   - Optimize slow tests

3. **Document lessons learned**
   - What went well?
   - What could be improved?
   - Best practices identified

---

This testing strategy ensures that the EveryMatrix connector refactor is thoroughly validated at every phase, minimizing risk and maximizing confidence in the production deployment.
