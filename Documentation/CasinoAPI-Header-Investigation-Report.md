# Casino API Header Implementation Investigation Report

**Date:** 22 October 2025
**Status:** ⚠️ CRITICAL ISSUE IDENTIFIED - Cookie Header Implementation is WRONG
**Priority:** HIGH - Affects all Casino API calls

---

## Executive Summary

During investigation of Casino API error 4004 (InvalidXSessionId), we discovered that the iOS app is using **incorrect HTTP headers** for Casino API authentication. The web app (which works correctly) uses standard `X-SessionId` headers, while our iOS implementation incorrectly adds a `Cookie` header.

**Impact:**
- All authenticated Casino API calls may be using wrong authentication method
- Error 4004 may be related to incorrect header usage
- Need to validate and fix header implementation across all EveryMatrix REST APIs

---

## Critical Finding: Cookie Header is WRONG

### Current iOS Implementation (INCORRECT)

**File:** `/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CasinoAPI/EveryMatrixCasinoConnector.swift`

**Lines 182-204:**
```swift
private func addAuthenticationHeaders(to request: inout URLRequest,
                                      session: EveryMatrixSessionResponse,
                                      endpoint: Endpoint) {
    // Add session token header
    if let sessionIdKey = endpoint.authHeaderKey(for: .sessionId) {
        request.setValue(session.sessionId, forHTTPHeaderField: sessionIdKey)
        print("[EveryMatrix-Casino] Added session token with key: \(sessionIdKey)")
    } else {
        // Default header for session token
        request.setValue(session.sessionId, forHTTPHeaderField: "X-SessionId")
    }

    // Add user ID header if needed
    if let userIdKey = endpoint.authHeaderKey(for: .userId) {
        request.setValue(session.userId, forHTTPHeaderField: userIdKey)
        print("[EveryMatrix-Casino] Added user ID with key: \(userIdKey)")
    }

    // Special handling for Casino API (uses Cookie header) ← ❌ WRONG!
    request.setValue("sessionId=\(session.sessionId)", forHTTPHeaderField: "Cookie")
    print("[EveryMatrix-Casino] Added session as Cookie header")
}
```

**Problem:** Line 202 adds `Cookie: sessionId=<sessionId>` header

---

### Web App Implementation (CORRECT)

**Source:** Betsson Africa web app codebase analysis

**Authentication Headers Pattern:**
```javascript
// For ALL authenticated Casino endpoints
headers: {
  'X-SessionId': sessionId,        // ✅ REQUIRED for auth
  'X-Session-Type': 'others'       // ✅ Context type
}

// NO Cookie header! ❌
```

**Example from web app:**
```javascript
// src/api/everymatrix/modules/casino.js:237-277
async getRecentlyPlayed(params = {}) {
  const sessionId = useCookies.getCookie('sessionId')
  const userId = userStore.user.id

  // API call
  GET /v1/player/${userId}/games/last-played?language=en&platform=PC

  // Headers
  {
    headers: {
      'X-SessionId': sessionId,
      'X-Session-Type': 'others'
    }
  }
}
```

---

## Test Evidence

### Successful cURL Test (2025-10-22)

We tested the Casino API with the following cURL (which worked):

```bash
curl --request POST \
  --url https://betsson-api.stage.norway.everymatrix.com/v1/player/legislation/login \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data '{"username":"+237699198921","password":"1234"}'

# Login Response:
{
  "sessionId": "63e64aeb-4375-453d-a39a-fc8938c75180",
  "id": "689cdb08-75fc-4431-b434-0260cc298d04",
  "userId": 7054250
}

# Then tested recommended games:
curl -X GET "https://betsson-api.stage.norway.everymatrix.com/v1/casino/recommendedGames?language=en&platform=iPhone" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "User-Agent: GOMA/native-app/iOS" \
  -H "X-Session-Type: others" \
  -H "X-SessionId: 63e64aeb-4375-453d-a39a-fc8938c75180"

# SUCCESS - Returned 3 games ✅
```

**Key Observation:** No Cookie header was used in the successful test!

---

## Architecture Context

### Current Connector Structure (Post-Consolidation)

```
EveryMatrixBaseConnector (Standard REST connector)
├─ Used by: EveryMatrixBettingProvider (OddsMatrix API)
├─ Used by: EveryMatrixPrivilegedAccessManager (PlayerAPI)
└─ Used by: EveryMatrixProvider (REST calls)

EveryMatrixCasinoConnector (Casino-specific with pre-parse logic)
└─ Used by: EveryMatrixCasinoProvider (Casino API)
```

### Recent Changes (22 October 2025)

During connector consolidation, the Cookie header logic was moved from `EveryMatrixBaseConnector` to `EveryMatrixCasinoConnector`:

**Git Diff Evidence:**
```diff
// EveryMatrixBaseConnector.swift (line 295-303)
+ /*
+  needs to be moved to the casino own connector
+
- // Special handling for Casino API (uses Cookie header)
- if apiIdentifier == "Casino" {
-     request.setValue("sessionId=\(session.sessionId)", forHTTPHeaderField: "Cookie")
- }
+ */
```

The Cookie header was preserved and moved to `EveryMatrixCasinoConnector` based on the assumption it was required. **This assumption is now proven WRONG.**

---

## Missing Header: X-Session-Type

### Web App Pattern

All authenticated Casino API calls in the web app include:
```javascript
headers: {
  'X-SessionId': sessionId,
  'X-Session-Type': 'others'  // ← We're missing this!
}
```

### Current iOS Implementation

**File:** `/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CasinoAPI/EveryMatrixCasinoConnector.swift`

The `X-Session-Type` header is **NOT** added anywhere in `addAuthenticationHeaders()`.

**Check if it's added at endpoint level:**
Need to verify in Casino API endpoint definitions.

---

## User ID in URL Paths

### Web App Pattern

User-specific endpoints include userId in the URL path:
```javascript
// Pattern: /v1/player/${userId}/games/...
GET /v1/player/7054250/games/last-played
GET /v1/player/7054250/games/most-played
GET /v1/player/7054250/details
GET /v1/player/7054250/balance
```

### iOS Implementation

**Need to verify:** Do our Casino API endpoints include userId in paths?

**Files to check:**
- `/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CasinoAPI/EveryMatrixCasinoAPI.swift`

---

## API Endpoint Comparison

### Casino API Base URLs

**Web App (Betsson Africa Production):**
```
VITE_APP_API_URL = "https://betsson.nwacdn.com"
```

**iOS App (Staging):**
```
https://betsson-api.stage.norway.everymatrix.com
```

### Endpoint Examples from Web App

| Endpoint | Auth Required | Headers | URL Path |
|----------|---------------|---------|----------|
| `GET /v1/casino/recommendedGames` | ✅ Yes | X-SessionId, X-Session-Type | No userId |
| `GET /v1/player/{userId}/games/last-played` | ✅ Yes | X-SessionId, X-Session-Type | Includes userId |
| `GET /v1/player/{userId}/games/most-played` | ✅ Yes | X-SessionId, X-Session-Type | Includes userId |
| `GET /v2/casino-new/groups/Lobby1` | ❌ No | None | Public |
| `GET /v2/casino/groups/Lobby1/{categoryId}` | ❌ No | None | Public |

---

## Required Actions

### Priority 1: Fix Casino Connector Headers

**File:** `EveryMatrixCasinoConnector.swift`

**Changes Required:**

1. **REMOVE Cookie header** (line 202)
2. **ADD X-Session-Type header**
3. **Verify X-SessionId is correct**

**Before:**
```swift
// Line 202
request.setValue("sessionId=\(session.sessionId)", forHTTPHeaderField: "Cookie")
```

**After:**
```swift
// Remove Cookie header entirely

// Add X-Session-Type header
request.setValue("others", forHTTPHeaderField: "X-Session-Type")
```

### Priority 2: Validate Endpoint Definitions

**File:** `EveryMatrixCasinoAPI.swift`

**Verify:**
1. User-specific endpoints include `{userId}` in path
2. Public endpoints don't require authentication
3. All endpoints have correct `requireSessionKey` flag

### Priority 3: Validate Other REST API Connectors

**Files to check:**
- `EveryMatrixBaseConnector.swift` - Used by PlayerAPI and OddsMatrixAPI
- Verify they use correct headers (X-SessionId only, NO Cookie)

**Git diff showed:**
```diff
+ /*
+  needs to be moved to the casino own connector
...
+ */
```

The Cookie logic was correctly commented out in BaseConnector ✅

### Priority 4: Test All Casino Endpoints

After header fix, test:
1. ✅ `getRecommendedGames()` - Already tested with cURL (worked without Cookie)
2. ⚠️ `searchGames()` - Need to test
3. ⚠️ `getGameBySlug()` - Need to test
4. ⚠️ `getGamesByCategory()` - Need to test
5. ⚠️ Recently played games (user-specific endpoint)
6. ⚠️ Most played games (user-specific endpoint)

---

## Web App Session Management (Reference)

### Session Storage
```javascript
// Cookies (not localStorage)
useCookies.setCookie('sessionId', sessionId, { expires: expiryDate })
useCookies.setCookie('id', id, { expires: expiryDate })
```

### Session Validation
```javascript
// On app boot: src/api/everymatrix/modules/boot.js:160
await oddsApi.user.checkIfPlayerIsLoggedIn()

// Implementation:
GET /v1/player/session/player
Headers: { 'X-SessionId': sessionId }

Response: { IsAuthenticated: true, UserID: "12345" }
```

### Session Expiration Handling
```javascript
// 401 error with specific error code
if (result.status === 401) {
  const errorCode = result.data?.data?.errorCode
  const thirdPartyCode = result.data?.data?.thirdPartyResponse?.errorCode

  if (errorCode === 1 && thirdPartyCode === 'InvalidSession') {
    // Clear session and show login
  }
}
```

**Note:** This differs from our error 4004 (InvalidXSessionId) pattern!

---

## iOS Implementation Files Reference

### Casino Connector
```
/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CasinoAPI/EveryMatrixCasinoConnector.swift
```
- Line 182-204: `addAuthenticationHeaders()` method
- Line 202: ❌ WRONG Cookie header
- Line 117-150: Pre-parse error detection logic (added 2025-10-22)

### Casino Provider
```
/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixCasinoProvider.swift
```
- Methods using connector:
  - Line 52: `getGamesByCategory()`
  - Line 104: `getGameDetails()` / `getGameBySlug()`
  - Line 138: `searchGames()`
  - Line 167: `getRecommendedGames()`

### Casino API Endpoint Definitions
```
/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CasinoAPI/EveryMatrixCasinoAPI.swift
```
- ⚠️ Need to verify endpoint paths and authentication flags

### Base Connector (Reference)
```
/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixBaseConnector.swift
```
- Line 279-298: `addAuthenticationHeaders()` method
- Line 295-303: Cookie logic correctly commented out ✅

---

## Questions to Investigate

### Q1: Why was Cookie header originally added?
- Check git history for when it was first introduced
- Check any documentation or comments
- Was it based on old EveryMatrix docs?

### Q2: Has it been working?
- If error 4004 is happening, maybe Cookie header never worked
- Or maybe it worked in some environments but not others
- Need to check production vs staging behavior

### Q3: X-Session-Type header
- Is this required or optional?
- What does "others" mean?
- Are there other valid values?

### Q4: User ID in endpoints
- Which endpoints need userId in path?
- Where do we get userId from? (SessionResponse only has string userId)
- Is it always available?

---

## Next Steps for Implementation

### Step 1: Research Phase (DO NOT SKIP)
1. Read `EveryMatrixCasinoAPI.swift` to understand all endpoints
2. Check if `X-Session-Type` is already added at endpoint level
3. Verify userId usage in endpoint paths
4. Check git history for Cookie header origin

### Step 2: Fix Headers
1. Remove Cookie header from `EveryMatrixCasinoConnector.swift:202`
2. Add `X-Session-Type: others` header
3. Verify `X-SessionId` is correctly set

### Step 3: Validate Endpoints
1. Ensure user-specific endpoints have userId in path
2. Ensure public endpoints don't require auth
3. Update endpoint definitions if needed

### Step 4: Test Everything
1. Test all Casino API endpoints with real API calls
2. Check cURL logs for correct headers
3. Verify no more error 4004
4. Test session expiration handling

### Step 5: Update Documentation
1. Update `CLAUDE.md` with correct header pattern
2. Document the Cookie header mistake
3. Add warning about future header changes

---

## Related Documentation

**Previous Session:**
- `/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Documentation/DevelopmentJournal/22-October-2025-casino-api-error-4004-fix.md`
- Documents the pre-parse error detection fix

**Architecture Reference:**
- `/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CLAUDE.md`
- Section: "EveryMatrixCasinoProvider (CasinoProvider)"

**Web App Reference Implementation:**
- Betsson Africa production web app
- Base URL: `https://betsson.nwacdn.com`
- Correct header pattern validated

---

## Git Context

**Current Branch:** `betsson-cm`

**Recent Commits:**
```
cfaa6b2e3 Merge commit '70d6f3935a7949d76e7b1e645934c71209923d5a' into betsson-cm
93fbc4a93 SP events from code
```

**Files Modified This Session (2025-10-22):**
1. ✅ `EveryMatrix+CasinoAPIErrorCheck.swift` (NEW)
2. ✅ `EveryMatrixCasinoConnector.swift` (Pre-parse logic added)
3. ✅ `CasinoGameDTO.swift` (Made items optional, added error fields)
4. ✅ `CasinoCategoryDTO.swift` (Made group fields optional)
5. ✅ `EveryMatrixModelMapper+Casino.swift` (Handle optional items)
6. ✅ `EveryMatrixCasinoProvider.swift` (Simplified methods)

**Uncommitted Changes:**
- All above files have changes ready to commit
- ⚠️ Cookie header issue NOT YET FIXED

---

## Conclusion

The iOS app is using incorrect HTTP headers for Casino API authentication. The Cookie header should be **removed** and replaced with standard `X-SessionId` + `X-Session-Type` headers as evidenced by the working web app implementation and successful cURL tests.

**Impact:** HIGH - All Casino API authenticated calls are affected
**Effort:** MEDIUM - Requires header changes and validation testing
**Risk:** LOW - Web app proves the correct pattern works

**Recommendation:** Fix headers immediately after validating endpoint definitions.
