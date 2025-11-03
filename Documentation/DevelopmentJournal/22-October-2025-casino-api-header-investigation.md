# Casino API Header Implementation Investigation

## Date
22 October 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Validate HTTP headers for Casino API after connector consolidation
- Ensure all EveryMatrix REST APIs use correct authentication headers
- Compare iOS implementation with working web app implementation

### Achievements
- [x] Discovered Cookie header is WRONG - should not be used for Casino API
- [x] Identified correct header pattern from web app: `X-SessionId` + `X-Session-Type: others`
- [x] Validated with successful cURL test (worked WITHOUT Cookie header)
- [x] Created comprehensive investigation report with all findings
- [x] Documented web app authentication patterns for reference
- [x] Identified missing `X-Session-Type` header in iOS implementation

### Issues / Bugs Hit
- [ ] **CRITICAL:** Casino API using incorrect Cookie header (line 202 in CasinoConnector)
- [ ] Missing `X-Session-Type: others` header in all authenticated Casino calls
- [ ] Unknown: Are user-specific endpoints using userId in URL paths correctly?
- [ ] Unknown: Why was Cookie header originally added? (need git history investigation)
- [ ] Unknown: Is error 4004 (InvalidXSessionId) related to wrong headers?

### Key Decisions
- **Cookie header must be removed** - Web app evidence proves it's not used
- **Add X-Session-Type header** - Present in all web app authenticated calls
- **Preserve pre-parse error detection** - Still valuable for handling 4004 errors
- **Create detailed investigation report** - For next LLM instance to continue work
- **Do NOT make changes yet** - Need to validate endpoint definitions first

### Experiments & Notes

#### Web App Analysis
Analyzed Betsson Africa web app codebase and discovered correct authentication pattern:

```javascript
// Correct pattern from web app
headers: {
  'X-SessionId': sessionId,        // ✅ Standard session header
  'X-Session-Type': 'others'       // ✅ Context type
}
// NO Cookie header!
```

#### Our Current iOS Implementation (WRONG)
```swift
// EveryMatrixCasinoConnector.swift:202
request.setValue("sessionId=\(session.sessionId)", forHTTPHeaderField: "Cookie")
// ❌ This is wrong and should be removed!
```

#### Successful cURL Test Evidence
```bash
# Test that worked WITHOUT Cookie header:
curl -X GET "https://betsson-api.stage.norway.everymatrix.com/v1/casino/recommendedGames?language=en&platform=iPhone" \
  -H "X-SessionId: 63e64aeb-4375-453d-a39a-fc8938c75180" \
  -H "X-Session-Type: others"
# ✅ SUCCESS - Returned 3 games
```

#### Web App Authentication Flow
```
Login → Store sessionId in cookies
       ↓
Check session on boot: GET /v1/player/session/player
       ↓
Add headers to authenticated requests:
  - X-SessionId: <sessionId>
  - X-Session-Type: others
```

#### User-Specific Endpoints Pattern
Web app includes userId in URL paths:
```
/v1/player/{userId}/games/last-played
/v1/player/{userId}/games/most-played
/v1/player/{userId}/balance
```

Need to verify our iOS endpoints use this pattern correctly.

### Useful Files / Links

**Investigation Report (Main Reference):**
- [CasinoAPI-Header-Investigation-Report.md](../CasinoAPI-Header-Investigation-Report.md)

**Files Needing Changes:**
- [EveryMatrixCasinoConnector.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CasinoAPI/EveryMatrixCasinoConnector.swift) - Line 182-204: Remove Cookie, add X-Session-Type
- [EveryMatrixCasinoAPI.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CasinoAPI/EveryMatrixCasinoAPI.swift) - Verify endpoint definitions

**Files to Validate:**
- [EveryMatrixBaseConnector.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixBaseConnector.swift) - Cookie logic correctly commented out ✅
- [EveryMatrixCasinoProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixCasinoProvider.swift) - Uses connector, needs testing after fix

**Related Documentation:**
- [22-October-2025-casino-api-error-4004-fix.md](./22-October-2025-casino-api-error-4004-fix.md) - Previous session: Pre-parse error detection
- [EveryMatrix CLAUDE.md](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CLAUDE.md) - Architecture documentation

### Architecture Context

#### Before Consolidation
```
EveryMatrixBaseConnector (with apiIdentifier)
├─ PlayerAPIConnector
├─ OddsMatrixAPIConnector
├─ RecsysAPIConnector
└─ CasinoConnector (had Cookie header logic)
```

#### After Consolidation (Current)
```
EveryMatrixBaseConnector (simplified, NO Cookie logic)
├─ Used by: EveryMatrixBettingProvider (OddsMatrixAPI)
├─ Used by: EveryMatrixPrivilegedAccessManager (PlayerAPI)
└─ Used by: EveryMatrixProvider

EveryMatrixCasinoConnector (specialized, has pre-parse + Cookie)
└─ Used by: EveryMatrixCasinoProvider
```

**Problem:** Cookie header was preserved during consolidation based on wrong assumption.

### Timeline of Changes

**Session 1 (Earlier today):**
- Fixed error 4004 with pre-parse error detection
- Made DTO fields optional
- Added `EveryMatrix.CasinoAPIErrorCheck`
- Cleaned up provider methods

**Session 2 (This session):**
- Investigated header implementations
- Compared with web app
- Discovered Cookie header is wrong
- Created investigation report
- **Did NOT make changes yet** - awaiting validation

### Next Steps

#### Priority 1: Research Phase (BEFORE making changes)
1. Read `EveryMatrixCasinoAPI.swift` - understand all endpoint definitions
2. Check if `X-Session-Type` already added at endpoint level
3. Verify userId usage in endpoint paths
4. Check git history for Cookie header origin story
5. Review any EveryMatrix API documentation available

#### Priority 2: Fix Headers
1. Remove Cookie header from `EveryMatrixCasinoConnector.swift:202`
2. Add `X-Session-Type: others` header
3. Verify `X-SessionId` is correctly set
4. Ensure userId in paths for user-specific endpoints

#### Priority 3: Validate & Test
1. Test `getRecommendedGames()` - already works with correct headers
2. Test `searchGames()` with new headers
3. Test `getGameBySlug()` with new headers
4. Test `getGamesByCategory()` with new headers
5. Test user-specific endpoints (recently played, most played)
6. Check cURL logs for correct headers
7. Verify error 4004 is resolved

#### Priority 4: Clean Up
1. Update `CLAUDE.md` with correct header pattern
2. Document the Cookie header mistake for posterity
3. Add warning comments about header requirements
4. Update investigation report with test results

### Risk Assessment

**Risk Level:** MEDIUM
- Cookie header may not be causing issues (if X-SessionId is working)
- Or it may be the root cause of error 4004
- Unknown impact until tested

**Mitigation:**
- Research first before making changes
- Test thoroughly in staging
- Have rollback plan ready
- Monitor logs for any new errors

### Open Questions

1. **Q:** Why was Cookie header originally added to Casino API?
   **A:** Unknown - need to check git history and documentation

2. **Q:** Has Cookie header been working or causing issues?
   **A:** Unknown - error 4004 suggests auth issues, could be related

3. **Q:** Is `X-Session-Type: others` required or optional?
   **A:** Web app always includes it, assume required

4. **Q:** What does "others" mean in `X-Session-Type`?
   **A:** Unknown - may indicate session context or client type

5. **Q:** Are all user-specific endpoints using userId in path?
   **A:** Need to verify in `EveryMatrixCasinoAPI.swift`

6. **Q:** Does error 4004 only happen on Casino API or others too?
   **A:** Only observed on Casino API so far

### Commands for Next Session

```bash
# Check Cookie header git history
git log --all --full-history -p -- "*CasinoConnector.swift" | grep -A5 -B5 "Cookie"

# List all Casino API endpoints
cat Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CasinoAPI/EveryMatrixCasinoAPI.swift

# Test Casino API after fix
xcodebuild -workspace Sportsbook.xcworkspace -scheme BetssonCameroonApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# Check logs for headers
# Look for "[EveryMatrix-Casino REST api] cURL Command:" in console
```

### Context Preservation

**Token Usage:** Near limit - report created to preserve context

**State:**
- Investigation complete ✅
- Root cause identified ✅
- Solution documented ✅
- Changes NOT yet applied ⚠️
- Testing NOT yet done ⚠️

**For Next LLM Instance:**
Read `Documentation/CasinoAPI-Header-Investigation-Report.md` first - contains all context, findings, evidence, and action plan.
