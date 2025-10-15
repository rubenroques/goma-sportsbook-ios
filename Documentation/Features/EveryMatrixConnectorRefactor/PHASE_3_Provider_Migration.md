# Phase 3: Provider Migration

## Objective

Migrate all four EveryMatrix providers to use `EveryMatrixUnifiedConnector` instead of their dedicated connector classes. This is done **gradually** with feature flags to enable instant rollback if issues arise.

**Duration:** 3-5 days
**Risk Level:** **HIGH** (touches production betting, payment, and authentication flows)
**Breaking Changes:** None (feature-flagged)

---

## Prerequisites

✅ **Phase 1 completed:** Authentication strategy pattern implemented
✅ **Phase 2 completed:** EveryMatrixUnifiedConnector created and tested
✅ **All tests passing:** Unit + integration tests verified
✅ **Code review approved:** Phases 1 & 2 reviewed and merged

---

## Migration Strategy

### Staged Rollout Approach

We will migrate **one API at a time** in this order:

1. **RecsysAPI** (Day 1) - Lowest risk, no session tokens
2. **OddsMatrix** (Days 2-3) - Highest risk, extensive testing needed
3. **PlayerAPI** (Day 4) - Critical authentication flow
4. **Casino** (Day 5) - Final validation, special Cookie auth

### Feature Flag Pattern

Each API gets its own feature flag in `Client.swift`:

```swift
// Feature flags for gradual migration
private let useUnifiedConnector_Recsys = false
private let useUnifiedConnector_OddsMatrix = false
private let useUnifiedConnector_PlayerAPI = false
private let useUnifiedConnector_Casino = false
```

**Rollout stages:**
1. Deploy with flag = `false` (no change)
2. Enable in staging (flag = `true`)
3. Test thoroughly
4. Enable in production at 10%
5. Monitor for 24 hours
6. Increase to 50%
7. Monitor for 24 hours
8. Increase to 100%
9. Keep flag for 1 week, then remove

---

## Implementation: Per-Provider Migration

### Migration 1: RecsysAPI (Lowest Risk)

**Why first?**
- No session token (simplest authentication)
- Not revenue-critical
- Used only for recommendations display

**File to modify:**
`Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift`

**Current code (lines 96-143):**
```swift
case .everymatrix:
    let sessionCoordinator = EveryMatrixSessionCoordinator()
    // ... other setup ...

    let everyMatrixEventsProvider = EveryMatrixEventsProvider(
        connector: everyMatrixConnector,
        sessionCoordinator: sessionCoordinator
    )
```

**Context:**
`EveryMatrixEventsProvider` creates its own RecsysConnector in its initializer:
```swift
// EveryMatrixProvider.swift:19
private let recsysConnector: EveryMatrixRecsysAPIConnector

init(connector: EveryMatrixConnector, sessionCoordinator: EveryMatrixSessionCoordinator) {
    self.recsysConnector = EveryMatrixRecsysAPIConnector(sessionCoordinator: sessionCoordinator)
}
```

**What to change:**

1. **Add feature flag to Client.swift:**
   ```swift
   private let useUnifiedConnector_Recsys = false  // Add near top of class
   ```

2. **Update EveryMatrixProvider.swift initializer:**
   - Add optional `recsysConnector` parameter
   - Default to creating old connector if not provided
   - Use provided connector if given

3. **Update Client.swift connector creation:**
   ```swift
   let recsysConnector: EveryMatrixRecsysAPIConnector
   if useUnifiedConnector_Recsys {
       recsysConnector = EveryMatrixUnifiedConnector(
           apiType: .recsys,
           sessionCoordinator: sessionCoordinator
       )
   } else {
       recsysConnector = EveryMatrixRecsysAPIConnector(
           sessionCoordinator: sessionCoordinator
       )
   }

   let everyMatrixEventsProvider = EveryMatrixEventsProvider(
       connector: everyMatrixConnector,
       sessionCoordinator: sessionCoordinator,
       recsysConnector: recsysConnector  // Pass explicit connector
   )
   ```

**Files to modify:**
- `Client.swift` (lines ~78, ~92)
- `EveryMatrixProvider.swift` (lines ~19, ~42-46)

**Testing checklist:**
- [ ] Get single bet recommendations
- [ ] Get combo bet recommendations
- [ ] Verify recommendations display in UI
- [ ] Check API logs for correct base URL
- [ ] Verify no session token sent (API key only)
- [ ] Test with staging environment
- [ ] Test with production environment

**Rollback:** Set `useUnifiedConnector_Recsys = false`

---

### Migration 2: OddsMatrix (Highest Risk)

**Why second?**
- Most critical API (betting operations)
- Handles real money transactions
- Extensive testing required

**File to modify:**
`Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift`

**Current code (lines 110-112):**
```swift
let everyMatrixBettingProvider = EveryMatrixBettingProvider(
    sessionCoordinator: sessionCoordinator
)
```

**Context:**
`EveryMatrixBettingProvider` creates its own OddsMatrixConnector:
```swift
// EveryMatrixBettingProvider.swift:14
private var connector: EveryMatrixOddsMatrixAPIConnector

init(sessionCoordinator: EveryMatrixSessionCoordinator, connector: EveryMatrixOddsMatrixAPIConnector? = nil) {
    if let providedConnector = connector {
        self.connector = providedConnector
    } else {
        self.connector = EveryMatrixOddsMatrixAPIConnector(sessionCoordinator: sessionCoordinator)
    }
}
```

**Good news:** BettingProvider already supports dependency injection!

**What to change:**

1. **Add feature flag to Client.swift:**
   ```swift
   private let useUnifiedConnector_OddsMatrix = false
   ```

2. **Update Client.swift connector creation:**
   ```swift
   let oddsMatrixConnector: EveryMatrixOddsMatrixAPIConnector
   if useUnifiedConnector_OddsMatrix {
       oddsMatrixConnector = EveryMatrixUnifiedConnector(
           apiType: .oddsMatrix,
           sessionCoordinator: sessionCoordinator
       )
   } else {
       oddsMatrixConnector = EveryMatrixOddsMatrixAPIConnector(
           sessionCoordinator: sessionCoordinator
       )
   }

   let everyMatrixBettingProvider = EveryMatrixBettingProvider(
       sessionCoordinator: sessionCoordinator,
       connector: oddsMatrixConnector  // Inject connector
   )
   ```

**Files to modify:**
- `Client.swift` (lines ~78, ~110-112)

**Files NOT to modify:**
- `EveryMatrixBettingProvider.swift` (already supports DI)

**Testing checklist (CRITICAL):**
- [ ] **Place single bet** (most important!)
- [ ] **Place multiple bet**
- [ ] **Get open bets** (pagination)
- [ ] **Get settled bets**
- [ ] **Get won bets**
- [ ] **Calculate cashout**
- [ ] **Execute cashout**
- [ ] **SSE cashout streaming** (real-time updates)
- [ ] **Verify authentication headers** (check logs for correct x-sessionid format)
- [ ] **Test with invalid session** (verify token refresh works)
- [ ] **Test bet placement failure scenarios**
- [ ] **Test with staging environment**
- [ ] **Test with production environment (10% rollout)**

**Monitoring metrics:**
- Bet placement success rate
- API error rate (401/403/409/500)
- Cashout execution success rate
- Average response time

**Rollback:** Set `useUnifiedConnector_OddsMatrix = false`

**⚠️ CAUTION:** This affects revenue. Monitor closely during rollout.

---

### Migration 3: PlayerAPI (Critical)

**Why third?**
- Handles authentication (login/registration)
- Required for all authenticated operations
- Failure blocks entire user experience

**File to modify:**
`Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift`

**Current code (lines 96-103):**
```swift
let everyMatrixPlayerAPIConnector = EveryMatrixPlayerAPIConnector(
    sessionCoordinator: sessionCoordinator
)

let everyMatrixPrivilegedAccessManager = EveryMatrixPrivilegedAccessManager(
    connector: everyMatrixPlayerAPIConnector,
    sessionCoordinator: sessionCoordinator
)
```

**Context:**
`EveryMatrixPrivilegedAccessManager` requires a `EveryMatrixPlayerAPIConnector`:
```swift
// EveryMatrixPrivilegedAccessManager.swift:14
var connector: EveryMatrixPlayerAPIConnector

init(connector: EveryMatrixPlayerAPIConnector, sessionCoordinator: EveryMatrixSessionCoordinator) {
    self.connector = connector
    self.sessionCoordinator = sessionCoordinator
}
```

**What to change:**

1. **Add feature flag to Client.swift:**
   ```swift
   private let useUnifiedConnector_PlayerAPI = false
   ```

2. **Update Client.swift connector creation:**
   ```swift
   let playerAPIConnector: EveryMatrixPlayerAPIConnector
   if useUnifiedConnector_PlayerAPI {
       playerAPIConnector = EveryMatrixUnifiedConnector(
           apiType: .playerAPI,
           sessionCoordinator: sessionCoordinator
       )
   } else {
       playerAPIConnector = EveryMatrixPlayerAPIConnector(
           sessionCoordinator: sessionCoordinator
       )
   }

   let everyMatrixPrivilegedAccessManager = EveryMatrixPrivilegedAccessManager(
       connector: playerAPIConnector,
       sessionCoordinator: sessionCoordinator
   )
   ```

**Files to modify:**
- `Client.swift` (lines ~78, ~96-103)

**Files NOT to modify:**
- `EveryMatrixPrivilegedAccessManager.swift`

**Testing checklist (CRITICAL):**
- [ ] **User login** (most important!)
- [ ] **User registration** (multi-step flow)
- [ ] **Get user profile**
- [ ] **Get user balance** (after login)
- [ ] **Get transaction history**
  - [ ] Banking transactions
  - [ ] Wagering transactions
- [ ] **Get banking web view** (payments)
- [ ] **Create booking code** (share bet)
- [ ] **Retrieve booking code**
- [ ] **Get recently played casino games**
- [ ] **Get most played casino games**
- [ ] **Token refresh on 401** (critical auth flow)
- [ ] **Test with staging environment**
- [ ] **Test with production environment (10% rollout)**

**Monitoring metrics:**
- Login success rate
- Registration completion rate
- API error rate
- Session token refresh rate

**Rollback:** Set `useUnifiedConnector_PlayerAPI = false`

**⚠️ CAUTION:** Login failures block all user access. Monitor authentication metrics closely.

---

### Migration 4: Casino (Final)

**Why last?**
- Special Cookie authentication
- Final validation that auth strategy pattern works
- Less critical than betting/auth

**File to modify:**
`Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift`

**Current code (lines 105-108):**
```swift
let everyMatrixCasinoConnector = EveryMatrixCasinoConnector(
    sessionCoordinator: sessionCoordinator
)
let everyMatrixCasinoProvider = EveryMatrixCasinoProvider(
    connector: everyMatrixCasinoConnector
)
```

**Context:**
`EveryMatrixCasinoProvider` requires a `EveryMatrixCasinoConnector`:
```swift
// EveryMatrixCasinoProvider.swift:6
private let connector: EveryMatrixCasinoConnector

init(connector: EveryMatrixCasinoConnector) {
    self.connector = connector
}
```

**What to change:**

1. **Add feature flag to Client.swift:**
   ```swift
   private let useUnifiedConnector_Casino = false
   ```

2. **Update Client.swift connector creation:**
   ```swift
   let casinoConnector: EveryMatrixCasinoConnector
   if useUnifiedConnector_Casino {
       casinoConnector = EveryMatrixUnifiedConnector(
           apiType: .casino,
           sessionCoordinator: sessionCoordinator
       )
   } else {
       casinoConnector = EveryMatrixCasinoConnector(
           sessionCoordinator: sessionCoordinator
       )
   }

   let everyMatrixCasinoProvider = EveryMatrixCasinoProvider(
       connector: casinoConnector
   )
   ```

**Files to modify:**
- `Client.swift` (lines ~78, ~105-108)

**Files NOT to modify:**
- `EveryMatrixCasinoProvider.swift`

**Testing checklist:**
- [ ] **Get casino categories**
- [ ] **Get games by category** (with pagination)
- [ ] **Get game details**
- [ ] **Search casino games**
- [ ] **Get recommended games** (authenticated)
- [ ] **Launch casino game** (verify URL generation)
- [ ] **Verify Cookie header** (check logs for `Cookie: sessionId=...`)
- [ ] **Test fun mode** (guest)
- [ ] **Test real money mode** (authenticated)
- [ ] **Test with staging environment**
- [ ] **Test with production environment (10% rollout)**

**Monitoring metrics:**
- Casino game launch success rate
- Category load times
- Search result accuracy

**Rollback:** Set `useUnifiedConnector_Casino = false`

---

## File References Summary

### Files to MODIFY:

```
Frameworks/ServicesProvider/Sources/ServicesProvider/
└── Client.swift
    ├── Lines ~55-70: Add 4 feature flag properties
    ├── Lines ~78-143: Update connector creation in connect() method
    │
    ├── Recsys Migration (lines ~92):
    │   └── Create unified connector if flag enabled
    │
    ├── OddsMatrix Migration (lines ~110-112):
    │   └── Create unified connector if flag enabled
    │
    ├── PlayerAPI Migration (lines ~96-103):
    │   └── Create unified connector if flag enabled
    │
    └── Casino Migration (lines ~105-108):
        └── Create unified connector if flag enabled

Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/
└── EveryMatrixProvider.swift
    ├── Line ~19: Make recsysConnector injectable
    └── Lines ~42-46: Update initializer to accept connector parameter
```

### Files to READ for Context:

```
EveryMatrixBettingProvider.swift
└── Lines 22-35: Already supports connector injection (✅ Good!)

EveryMatrixPrivilegedAccessManager.swift
└── Lines 31-34: Requires connector in init

EveryMatrixCasinoProvider.swift
└── Lines 15-17: Requires connector in init

EveryMatrixProvider.swift
└── Lines 19, 42-46: Creates own recsysConnector
```

---

## Rollout Timeline

### Week 1: Recsys + OddsMatrix

**Monday:**
- Deploy Recsys migration to staging
- Test thoroughly
- Enable in production (10%)

**Tuesday:**
- Monitor Recsys (should be stable)
- Increase to 100%
- Deploy OddsMatrix to staging

**Wednesday:**
- Test OddsMatrix extensively (betting is critical)
- Enable in production (10%)
- **Monitor closely** (revenue impact)

**Thursday:**
- Increase OddsMatrix to 50%
- Monitor betting metrics

**Friday:**
- Increase OddsMatrix to 100%
- Monitor through weekend

### Week 2: PlayerAPI + Casino

**Monday:**
- Deploy PlayerAPI to staging
- Test authentication flows
- Enable in production (10%)

**Tuesday:**
- Monitor login/registration metrics
- Increase PlayerAPI to 50%

**Wednesday:**
- Increase PlayerAPI to 100%
- Deploy Casino to staging

**Thursday:**
- Test Casino thoroughly
- Enable in production (10%)

**Friday:**
- Monitor casino game launches
- Increase Casino to 100%

### Week 3: Stabilization

**Monday-Friday:**
- Monitor all metrics
- Keep feature flags enabled
- Prepare for Phase 4 (cleanup)

---

## Monitoring & Metrics

### Key Metrics to Watch

**OddsMatrix (Betting):**
- ✅ Bet placement success rate > 99.5%
- ✅ API error rate < 0.5%
- ✅ Average bet placement time < 2s
- ✅ Cashout execution success rate > 99%
- ⚠️ Any increase in 401/403 errors

**PlayerAPI (Authentication):**
- ✅ Login success rate > 98%
- ✅ Registration completion rate (no decrease)
- ✅ Token refresh success rate > 99%
- ⚠️ Any increase in authentication failures

**Casino:**
- ✅ Game launch success rate > 99%
- ✅ Category load time < 3s
- ⚠️ Any Cookie header issues

**Recsys:**
- ✅ Recommendation API response time < 1s
- ✅ No errors (low priority)

### Monitoring Tools

**Log searches:**
```
// Check for authentication errors
grep -r "401\|403" logs/

// Check bet placement
grep -r "placeBet\|PlaceBetResponse" logs/

// Check cashout
grep -r "cashout\|Cashout" logs/

// Check connector usage
grep -r "EveryMatrix.*Connector" logs/
```

**Alerts to set up:**
- Bet placement error rate > 1%
- Login error rate > 2%
- Cashout failure rate > 1%
- API response time > 5s

---

## Rollback Procedures

### Instant Rollback (< 5 minutes)

**If any critical issue detected:**

1. **Identify affected API** (Recsys, OddsMatrix, PlayerAPI, Casino)

2. **Flip feature flag in Client.swift:**
   ```swift
   private let useUnifiedConnector_OddsMatrix = false  // Disable
   ```

3. **Deploy immediately:**
   - Update flag in code
   - Commit and push
   - Deploy to production
   - Verify rollback successful

4. **No data loss** - this is purely a code change

### Partial Rollback

Can roll back individual APIs without affecting others:

```swift
// Roll back only OddsMatrix if betting fails
private let useUnifiedConnector_Recsys = true      // Keep
private let useUnifiedConnector_OddsMatrix = false // Rollback
private let useUnifiedConnector_PlayerAPI = true   // Keep
private let useUnifiedConnector_Casino = true      // Keep
```

### Escalation Path

**If immediate rollback doesn't resolve issue:**

1. Check logs for specific error
2. Review recent commits to unified connector
3. Compare behavior with old connector
4. May need to revert Phase 1/2 changes (worst case)

---

## Common Issues & Solutions

### Issue 1: Authentication Headers Wrong Format

**Symptoms:**
- 401/403 errors increase
- "Invalid session token" in logs

**Diagnosis:**
- Check HTTP logs for header format
- Compare with old connector behavior
- Verify auth strategy is correct type

**Solution:**
- Verify endpoint.authHeaderKey() implementation
- Check auth strategy apply() method
- May need to adjust header capitalization

### Issue 2: Base URL Incorrect

**Symptoms:**
- 404 errors
- "Host not found" errors

**Diagnosis:**
- Check EveryMatrixAPIType.baseURL
- Verify environment is correct (staging vs production)

**Solution:**
- Fix baseURL in EveryMatrixAPIType enum
- Verify EveryMatrixUnifiedConfiguration.environment

### Issue 3: SSE Streaming Broken

**Symptoms:**
- Real-time cashout values not updating
- SSE connection timeouts

**Diagnosis:**
- Check SSEManager logs
- Verify auth headers on SSE request

**Solution:**
- Verify authStrategy.apply() works for Dictionary (SSE headers)
- Check timeout configuration

### Issue 4: Token Refresh Loop

**Symptoms:**
- Excessive login requests
- 401 → refresh → 401 → refresh loop

**Diagnosis:**
- Check token refresh logic in base connector
- Verify credentials are stored

**Solution:**
- Ensure sessionCoordinator.updateCredentials() is called on login
- Verify only one retry attempt per request

---

## Success Criteria

After Phase 3 is complete:

✅ **All 4 APIs migrated to unified connector**
✅ **All feature flags enabled in production**
✅ **No increase in error rates**
✅ **No degradation in performance**
✅ **Monitoring dashboards show green metrics**
✅ **User-facing functionality unchanged**
✅ **Code is cleaner and more maintainable**

---

## Next Phase

After Phase 3 is complete and stable for 1 week:
→ Proceed to `PHASE_4_Legacy_Cleanup.md`

**Phase 4 will:**
- Remove feature flags
- Delete old connector classes
- Final cleanup and documentation
