# Cashout Root Cause Analysis

> **Date**: 2025-12-19
> **Status**: Investigation Complete - Pending Fixes
> **Source Analysis**: Web (branch: mm/cashout) vs iOS (branch: rr/cashout_fixes)
> **Test Account**: 653333000/1234 (STG)

---

## Problem Statement

iOS cashout feature is not displaying cashout values for open bets, while the Web implementation works correctly for the same user and bets.

**Visual Evidence:**
- iOS shows "Rebet" and "Cashout" buttons but Cashout appears disabled with no value
- Web shows active cashout with value XAF 80.00 and partial cashout slider

---

## Root Causes Identified

### Summary Table

| Priority | Issue | Severity | Files Affected |
|----------|-------|----------|----------------|
| **0** | Chicken-and-egg SSE subscription logic | **CRITICAL** | `TicketBetInfoViewModel.swift`, `MyBet.swift` |
| **1** | SSE `code == 100` filter drops valid messages | **CRITICAL** | `EveryMatrixBettingProvider.swift` |
| **2** | `partialCashOutEnabled` defaults to `false` (Web: `true`) | **CRITICAL** | `EveryMatrixModelMapper+CashoutSSE.swift` |
| **3** | `partialCashOutEnabled` read from wrong JSON location | **MEDIUM** | `EveryMatrixModelMapper+CashoutSSE.swift` |
| **4** | Missing `userId` header (Web sends both `X-user-id` + `userId`) | **LOW-MEDIUM** | `EveryMatrixSSEConnector.swift` |

---

## Issue #0: Chicken-and-Egg SSE Subscription (CRITICAL - PRIMARY ROOT CAUSE)

### Problem Description

iOS only subscribes to SSE for cashout values when `canCashOut` is already `true`. But `canCashOut` depends on `partialCashoutReturn` from the MyBets API, which returns `null` for most bets.

This creates a chicken-and-egg problem: we need SSE to get cashout values, but we only subscribe to SSE if we already have a cashout value.

### Evidence from API Testing

```bash
curl -s -X GET "https://sports-api-stage.everymatrix.com/bets-api/v1/4093/open-bets?limit=5" \
  -H "x-session-id: ..." -H "x-user-id: ..." | jq '.[] | {id, status, overallCashoutAmount}'
```

**Results:**
```json
{"id": "7de60e2d-...", "status": "OPEN", "overallCashoutAmount": 0.40}
{"id": "e8308c59-...", "status": "OPEN", "overallCashoutAmount": null}
{"id": "3c080ec3-...", "status": "OPEN", "overallCashoutAmount": null}
{"id": "ce01157a-...", "status": "OPEN", "overallCashoutAmount": null}
```

Most bets return `overallCashoutAmount: null` from the API.

**But SSE returns valid cashout for bets with null API value:**
```bash
curl -X POST ".../cashout-value-updates" -d '{"betIds":["e8308c59-..."]}' --max-time 5
```
```
data:{"betId":"e8308c59-...","cashoutValue":1.00,"details":{"code":100,"message":"Success"},...}
```

### iOS Implementation (INCORRECT)

**File**: `BetssonCameroonApp/App/Models/Betting/MyBet.swift` (lines 131-133)

```swift
var canCashOut: Bool {
    return state == .opened && partialCashoutReturn != nil && partialCashoutReturn! > 0
}
```

**File**: `BetssonCameroonApp/App/Screens/MyBets/ViewModels/TicketBetInfoViewModel.swift` (lines 98-100)

```swift
// Subscribe to SSE for real-time cashout value updates
if myBet.canCashOut {
    subscribeToCashoutUpdates()  // Only called if API already has value!
}
```

### Web Implementation (CORRECT)

Web subscribes to SSE for ALL open bets, regardless of whether the initial API response has a cashout value. The SSE stream determines cashout availability.

### Required Fix

**Option A - Subscribe to SSE for all open bets:**
```swift
// TicketBetInfoViewModel.swift
// Subscribe to SSE for ALL open bets (matches Web behavior)
if myBet.isActive {
    subscribeToCashoutUpdates()
}
```

**Option B - Change canCashOut to not require initial value:**
```swift
// MyBet.swift
var canCashOut: Bool {
    return state == .opened  // Let SSE determine actual availability
}
```

---

## Issue #1: SSE Code Filtering (CRITICAL)

### Problem Description

iOS filters out SSE messages where `details.code != 100`, dropping messages with other codes entirely.
Web processes ALL messages regardless of `details.code` value.

### Web Implementation (CORRECT)

**File**: `web-app/src/api/everymatrix/modules/betting.js` (lines 2059-2067)

```javascript
// Only filters by messageType, NOT by code
if (message.messageType && message.messageType !== 'CASHOUT_VALUE') {
  return
}

// Only process messages that have actual cashout data
if (typeof message.cashoutValue === 'undefined') {
  return
}

// NO CODE CHECK - processes all messages including code 103
const cashoutValue = message.cashoutValue
```

**Key Behavior**:
- Filters by `messageType === 'CASHOUT_VALUE'` only
- Filters by `cashoutValue !== undefined`
- Does NOT filter by `details.code`

### iOS Implementation (INCORRECT)

**File**: `Frameworks/ServicesProvider/.../EveryMatrixBettingProvider.swift` (lines 219-223)

```swift
// Filter 2: Only emit messages with code 100 (ignore code 103)
guard response.details.code == 100 else {
    print("⏳ Code 103 - still loading odds...")
    return nil  // ❌ DROPS the message entirely
}
```

### Evidence from SSE Testing

```
id:3JJtrlTcy6cX4wbaeRG14r
data:{"betId":"...","messageType":"AUTOCASHOUT_RULE"}

id:5U2q8HuvUUtPeKKM7MfKQ0
data:{"betId":"...","details":{"code":105,"message":"Cashout value is less than minimum required"},...}

id:7m2Afeu9qAlk5yPJMrdTKN
data:{"betId":"...","cashoutValue":1.00,"details":{"code":100,"message":"Success"},...}
```

SSE sends multiple messages with different codes before the final code 100.

### Required Fix

**File**: `EveryMatrixBettingProvider.swift`

```swift
// BEFORE (incorrect):
guard response.details.code == 100 else {
    print("⏳ Code 103 - still loading odds...")
    return nil
}

// AFTER (matches Web):
// Log non-100 codes for debugging but don't filter them out
if response.details.code != 100 {
    print("⚠️ SSE code \(response.details.code): \(response.details.message)")
}

// Only filter if cashoutValue is nil (matches Web)
guard response.cashoutValue != nil else {
    print("⏳ No cashout value yet - waiting...")
    return nil
}
```

---

## Issue #2: partialCashOutEnabled Default Logic (CRITICAL)

### Problem Description

Web defaults `partialCashOutEnabled` to `true` when not explicitly `false`.
iOS defaults `partialCashOutEnabled` to `false` when `nil`.

### Web Implementation (CORRECT)

**File**: `web-app/src/api/everymatrix/modules/betting.js` (lines 2074-2075)

```javascript
const cashoutSettings = message?.cashoutValueSettings || {}
const partialCashOutEnabled = cashoutSettings?.partialCashOutEnabled !== false
```

**Logic Table**:
| `partialCashOutEnabled` value | Result |
|-------------------------------|--------|
| `undefined` | `true` (enabled) |
| `null` | `true` (enabled) |
| `true` | `true` (enabled) |
| `false` | `false` (disabled) |

### iOS Implementation (INCORRECT)

**File**: `Frameworks/ServicesProvider/.../EveryMatrixModelMapper+CashoutSSE.swift` (line 25)

```swift
partialCashOutEnabled: response.partialCashOutEnabled ?? false,
```

**Logic Table**:
| `partialCashOutEnabled` value | Result |
|-------------------------------|--------|
| `nil` | `false` (disabled) |
| `true` | `true` (enabled) |
| `false` | `false` (disabled) |

### Required Fix

```swift
// BEFORE:
partialCashOutEnabled: response.partialCashOutEnabled ?? false,

// AFTER:
partialCashOutEnabled: response.partialCashOutEnabled ?? true,
```

---

## Issue #3: partialCashOutEnabled Source Location (MEDIUM)

### Problem Description

Web extracts `partialCashOutEnabled` from the **nested** `cashoutValueSettings` object.
iOS extracts from the **root-level** `partialCashOutEnabled` field.

### Web Implementation (CORRECT)

```javascript
const cashoutSettings = message?.cashoutValueSettings || {}
const partialCashOutEnabled = cashoutSettings?.partialCashOutEnabled !== false
// ✅ Reads from: message.cashoutValueSettings.partialCashOutEnabled
```

### iOS Implementation (INCOMPLETE)

```swift
partialCashOutEnabled: response.partialCashOutEnabled ?? false,
// ❌ Reads from: response.partialCashOutEnabled (root level only)
// Does NOT check: response.cashoutValueSettings?.partialCashOutEnabled
```

### SSE Response Model Reference

**File**: `EveryMatrix+CashoutValueSSEResponse.swift`

```swift
struct CashoutValueSSEResponse: Decodable {
    // Root level (may be nil)
    let partialCashOutEnabled: Bool?

    // Nested in settings (may also exist here)
    let cashoutValueSettings: CashoutValueSettings?

    struct CashoutValueSettings: Decodable {
        let partialCashOutEnabled: Bool?  // ← Web reads from here
    }
}
```

### Required Fix

```swift
// BEFORE:
partialCashOutEnabled: response.partialCashOutEnabled ?? false,

// AFTER (check both locations, match Web default):
partialCashOutEnabled: response.cashoutValueSettings?.partialCashOutEnabled
                    ?? response.partialCashOutEnabled
                    ?? true,
```

---

## Issue #4: Missing userId Header (LOW-MEDIUM)

### Problem Description

Web sends BOTH `X-user-id` AND `userId` headers for backward compatibility.
iOS only sends `x-user-id`.

### Web Implementation

**SSE Subscription** (`betting.js:2042-2048`):
```javascript
headers: {
  'X-language': recurrentProps.value.lang,
  'X-session-id': sessionId,
  'X-operator-id': ucsOperatorId,
  'X-user-id': userStore.userId,
  'userId': userStore.userId,  // ← EXTRA header for backward compatibility
}
```

### iOS Implementation

**File**: `EveryMatrixSSEConnector.swift` (lines 188-191)

```swift
// Add user ID header if needed
if let userIdKey = endpoint.authHeaderKey(for: .userId) {
    updatedHeaders[userIdKey] = session.userId  // Only x-user-id
}
// ❌ Missing: updatedHeaders["userId"] = session.userId
```

### Required Fix

**File**: `EveryMatrixSSEConnector.swift`

```swift
// Add user ID header if needed
if let userIdKey = endpoint.authHeaderKey(for: .userId) {
    updatedHeaders[userIdKey] = session.userId
}

// Add userId header for backward compatibility (matches Web)
updatedHeaders["userId"] = session.userId
```

---

## Complete Comparison Tables

### SSE Subscription Comparison

| Aspect | Web (Working) | iOS (Failing) | Status |
|--------|---------------|---------------|--------|
| **Endpoint** | `bets-api/v1/{operatorId}/cashout-value-updates` | `bets-api/v1/{operatorId}/cashout-value-updates` | Match |
| **Method** | POST | POST | Match |
| **Request Body** | `{ betIds: ["id1", "id2"] }` | `{ "betIds": ["id"] }` | Match |
| **When to Subscribe** | ALL open bets | Only if `canCashOut == true` | **ISSUE #0** |
| **Message Type Filter** | `messageType !== 'CASHOUT_VALUE'` skip | `messageType == "CASHOUT_VALUE"` process | Match |
| **Code Filter** | **NONE** - processes all codes | `code == 100` required | **ISSUE #1** |
| **Null Value Handling** | `cashoutValue === undefined` skip | `cashoutValue != nil` required | Match |

### SSE Message Filtering Comparison

| Filter | Web | iOS | Status |
|--------|-----|-----|--------|
| **Filter 1** | `messageType !== 'CASHOUT_VALUE'` skip | `messageType == "CASHOUT_VALUE"` continue | Same logic |
| **Filter 2** | **NONE** | `code == 100` required | **iOS MORE RESTRICTIVE** |
| **Filter 3** | `cashoutValue === undefined` skip | `cashoutValue != nil` continue | Match |

### Headers Comparison

| Header | Web | iOS | Status |
|--------|-----|-----|--------|
| `Content-Type` | `application/json` | `application/json` | Match |
| `Accept` (SSE) | `text/event-stream` | `text/event-stream` | Match |
| `X-operator-id` | lowercase with hyphen | `x-operator-id` | Match |
| `X-session-id` | lowercase with hyphen | `x-session-id` | Match |
| `X-user-id` | `userId.toString()` | `x-user-id` | Match |
| `X-language` | `lang \|\| 'en'` | `x-language` | Match |
| `userId` | **EXTRA** for backward compat | **MISSING** | **ISSUE #4** |

### Cashout Execution Request Body Comparison

| Field | Web | iOS | Status |
|-------|-----|-----|--------|
| `betId` | string | String | Match |
| `cashoutValue` | `parseFloat(value.toFixed(2))` | Double | Match |
| `cashoutType` | `'FULL'` or `'PARTIAL'` | `"FULL"/"PARTIAL"` | Match |
| `cashoutChangeAcceptance` | `'WITHIN_THRESHOLD'` | `"WITHIN_THRESHOLD"` | Match |
| `operatorId` | **IN BODY** | **IN BODY** | Match |
| `language` | **IN BODY** | **IN BODY** | Match |
| `partialCashoutStake` | Only for partial | Only for partial | Match |

### partialCashOutEnabled Logic Comparison

| Scenario | Web Result | iOS Result | Status |
|----------|------------|------------|--------|
| Value is `undefined`/`nil` | `true` (enabled) | `false` (disabled) | **INVERTED** |
| Value is `null` | `true` (enabled) | `false` (disabled) | **INVERTED** |
| Value is `true` | `true` (enabled) | `true` (enabled) | Match |
| Value is `false` | `false` (disabled) | `false` (disabled) | Match |
| **Source location** | `cashoutValueSettings.partialCashOutEnabled` | `response.partialCashOutEnabled` (root) | **DIFFERENT** |

### Partial Cashout Formula Comparison

| Aspect | Web | iOS | Status |
|--------|-----|-----|--------|
| **Formula** | `(fullCashoutValue * sliderAmount) / totalStake` | `(fullCashoutValue * partialStake) / totalRemainingStake` | Match |
| **Default Slider** | 80% of remaining stake | 80% of remaining stake | Match |
| **Full Threshold** | `amount >= remainingStake` | `stakeValue >= (remainingStake - 0.01)` | Similar |

---

## Files to Modify

| File | Location | Change |
|------|----------|--------|
| `TicketBetInfoViewModel.swift` | lines 98-100 | Subscribe to SSE for ALL open bets, not just `canCashOut` |
| `EveryMatrixBettingProvider.swift` | lines 219-223 | Remove `code == 100` guard |
| `EveryMatrixModelMapper+CashoutSSE.swift` | line 25 | Change default from `false` to `true`, check `cashoutValueSettings` first |
| `EveryMatrixSSEConnector.swift` | lines 188-191 | Add `userId` header |

---

## Implementation Order

1. **Fix Issue #0 first** (SSE subscription logic) - Primary root cause
2. **Fix Issue #1** (SSE code filter) - Secondary root cause
3. **Fix Issue #2 + #3 together** (partialCashOutEnabled logic and source)
4. **Fix Issue #4** (userId header) - May or may not be required

---

## Testing Checklist

After implementing fixes:

- [ ] SSE subscription starts for ALL open bets (not just those with API cashout value)
- [ ] SSE connection establishes successfully
- [ ] SSE messages with `code: 103` are logged but not dropped
- [ ] SSE messages with `code: 100` emit cashout values
- [ ] Cashout value appears in UI for open bets
- [ ] Partial cashout slider is enabled by default
- [ ] Partial cashout calculation matches Web formula
- [ ] Full cashout execution succeeds
- [ ] Partial cashout execution succeeds
- [ ] Error states handled properly

---

## Reference Files

### Web (Working Implementation)
- `web-app/src/api/everymatrix/modules/betting.js` - SSE subscription and cashout execution
- `web-app/src/api/everymatrix/client.js` - SSE stream handling
- `web-app/src/composables/myBets/useMyBets.js` - Cashout state management

### iOS (Files to Fix)
- `BetssonCameroonApp/App/Screens/MyBets/ViewModels/TicketBetInfoViewModel.swift`
- `BetssonCameroonApp/App/Models/Betting/MyBet.swift`
- `Frameworks/ServicesProvider/.../EveryMatrixBettingProvider.swift`
- `Frameworks/ServicesProvider/.../EveryMatrixModelMapper+CashoutSSE.swift`
- `Frameworks/ServicesProvider/.../EveryMatrixSSEConnector.swift`
