# Cashout API - Quick Reference Guide

**Environment:** Stage
**Base URLs:**
- Authentication: `https://betsson-api.stage.norway.everymatrix.com`
- Betting APIs: `https://sports-api-stage.everymatrix.com`

---

## 1. Authentication

### Endpoint
```
POST /v1/player/legislation/login
```

### Request
```bash
curl 'https://betsson-api.stage.norway.everymatrix.com/v1/player/legislation/login' \
  -H 'accept: application/json' \
  -H 'content-type: application/json' \
  --data-raw '{
    "username": "+237699198921",
    "password": "1234"
  }'
```

### Response
```json
{
  "sessionId": "a6cb79d5-82e1-4f8e-b895-09d91b159909",
  "id": "1c6b16c9-2d1a-49fc-a15e-ea39e128439b",
  "userId": 7054250,
  "sessionBlockers": [],
  "hasToAcceptTC": false,
  "hasToSetPass": false
}
```

### Extract for Next Steps
- **sessionId** → Use in `X-SessionId` header
- **userId** → Use in `userId` or `x-user-id` header

---

## 2. Get Open Bets

### Endpoint
```
GET /bets-api/v1/{operatorId}/open-bets
```

### Required Headers
```
accept: application/json
x-language: en
x-operator-id: 4093
x-session-id: {sessionId from login}
x-user-id: {userId from login}
```

### Query Parameters
- `limit` - Maximum number of bets to return (e.g., 20)
- `placedBefore` - ISO 8601 timestamp (e.g., 2025-10-19T16:00:00)

### Request
```bash
curl 'https://sports-api-stage.everymatrix.com/bets-api/v1/4093/open-bets?limit=20&placedBefore=2025-10-19T16:00:00' \
  -H 'accept: application/json' \
  -H 'x-language: en' \
  -H 'x-operator-id: 4093' \
  -H 'x-session-id: a6cb79d5-82e1-4f8e-b895-09d91b159909' \
  -H 'x-user-id: 7054250'
```

### Response
```json
[{
  "id": "63fd0b52-f6ef-40cc-8836-9fd79af0367d",
  "selections": [{
    "eventName": "Eintracht Frankfurt - Liverpool",
    "priceValue": 1.59,
    "betName": "Liverpool"
  }],
  "type": "SINGLE",
  "amount": 17263.00,
  "currency": "XAF",
  "maxWinning": 27448.17,
  "status": "OPEN",
  "betRemainingStake": 17263.00
}]
```

### Key Fields
- **id** → Bet ID for cashout requests
- **amount** → Original stake
- **maxWinning** → Potential payout if bet wins
- **betRemainingStake** → Current active stake (after any partial cashouts)

---

## 3. Get Cashout Value (SSE Stream)

### Endpoint
```
GET /cashout/v1/cashout-value/{betId}
```

### Required Headers
```
accept: text/event-stream
X-SessionId: {sessionId from login}
X-OperatorId: 4093
userId: {userId from login}
```

### Request
```bash
curl 'https://sports-api-stage.everymatrix.com/cashout/v1/cashout-value/63fd0b52-f6ef-40cc-8836-9fd79af0367d' \
  -H 'accept: text/event-stream' \
  -H 'X-SessionId: a6cb79d5-82e1-4f8e-b895-09d91b159909' \
  -H 'X-OperatorId: 4093' \
  -H 'userId: 7054250' \
  --max-time 4
```

### Response (Server-Sent Events)

The endpoint streams **3 messages**:

#### Message 1: Autocashout Rule
```
id:6Ei073US06y2pEcmxq0yzm
event:message
data:{"messageType":"AUTOCASHOUT_RULE","betId":"63fd0b52-f6ef-40cc-8836-9fd79af0367d","betHasAutoCashout":false}
```

#### Message 2: Initial Status (Code 103)
```
id:2JKWKlFcmcW8YKn9tVdDzl
event:message
data:{"messageType":"CASHOUT_VALUE","betId":"63fd0b52-f6ef-40cc-8836-9fd79af0367d","currentPossibleWinning":27448.17,"stake":17263.00,"details":{"code":103,"message":"Current odds not found"},"cashoutValueSettings":{"autoCashOutEnabled":null,"partialCashOutEnabled":null}}
```
**Ignore this** - temporary state while retrieving odds.

#### Message 3: Success (Code 100) ✅
```
id:7kHYoDfQnjUIGnKWhH7k6I
event:message
data:{"messageType":"CASHOUT_VALUE","betId":"63fd0b52-f6ef-40cc-8836-9fd79af0367d","cashoutValue":17263.00,"currentPossibleWinning":27448.17,"stake":17263.00,"autoCashOutEnabled":true,"partialCashOutEnabled":true,"details":{"code":100,"message":"Success"},"cashoutValueSettings":{"autoCashOutEnabled":true,"partialCashOutEnabled":true,"covValidationAcceptHigher":false,"covValidationAcceptLower":false}}
```

### Extract from Message 3
- **cashoutValue** → Full cashout payout amount
- **stake** → Total bet stake
- **partialCashOutEnabled** → Whether partial cashouts are allowed
- **autoCashOutEnabled** → Whether auto-cashout rules can be set

### Implementation Notes
- Use 4-5 second timeout for SSE connection
- Parse only the **final message with code 100**
- Cashout value may change over time - fetch fresh before executing

---

## 4. Execute Cashout

### Endpoint
```
POST /cashout/v1/cashout
```

### Required Headers
```
accept: application/json
content-type: application/json
X-SessionId: {sessionId from login}
X-OperatorId: 4093
userId: {userId from login}
```

### Request Types

#### A. Full Cashout
```bash
curl 'https://sports-api-stage.everymatrix.com/cashout/v1/cashout' \
  -X POST \
  -H 'accept: application/json' \
  -H 'content-type: application/json' \
  -H 'X-SessionId: a6cb79d5-82e1-4f8e-b895-09d91b159909' \
  -H 'X-OperatorId: 4093' \
  -H 'userId: 7054250' \
  --data-raw '{
    "betId": "63fd0b52-f6ef-40cc-8836-9fd79af0367d",
    "cashoutValue": 17263.00,
    "cashoutType": "FULL",
    "cashoutChangeAcceptanceType": "ACCEPT_ANY"
  }'
```

**Parameters:**
- `betId` - Bet identifier
- `cashoutValue` - Value from SSE response (exact value)
- `cashoutType` - "FULL"
- `cashoutChangeAcceptanceType` - "ACCEPT_ANY" (accepts odds changes)

#### B. Partial Cashout
```bash
curl 'https://sports-api-stage.everymatrix.com/cashout/v1/cashout' \
  -X POST \
  -H 'accept: application/json' \
  -H 'content-type: application/json' \
  -H 'X-SessionId: a6cb79d5-82e1-4f8e-b895-09d91b159909' \
  -H 'X-OperatorId: 4093' \
  -H 'userId: 7054250' \
  --data-raw '{
    "betId": "63fd0b52-f6ef-40cc-8836-9fd79af0367d",
    "cashoutValue": 5178.90,
    "cashoutType": "PARTIAL",
    "partialCashoutStake": 5178.90,
    "cashoutChangeAcceptanceType": "ACCEPT_ANY"
  }'
```

**Parameters:**
- `betId` - Bet identifier
- `cashoutValue` - **CALCULATED partial value** (see formula below)
- `cashoutType` - "PARTIAL"
- `partialCashoutStake` - Amount of stake to cash out
- `cashoutChangeAcceptanceType` - "ACCEPT_ANY"

**Critical Formula for Partial Cashout (Official Documentation):**

From EveryMatrix API documentation:
```
cashoutValue = (cov_received_from_us_for_full_stake * pco_stake_user_wants) / total_stake_of_the_cov_received_from_us
```

Simplified:
```
cashoutValue = (fullCashoutValue × partialCashoutStake) / totalStake
```

Where:
- `cov_received_from_us_for_full_stake` = Full cashout value from SSE response
- `pco_stake_user_wants` = Partial stake amount user wants to cash out
- `total_stake_of_the_cov_received_from_us` = Total bet stake

**Example:**
```
Full cashout value (from SSE): 17,263.00 XAF
Total stake: 17,263.00 XAF
Desired partial stake (30%): 5,178.90 XAF

cashoutValue = (17,263.00 × 5,178.90) / 17,263.00 = 5,178.90 XAF
```

### Response (Success)

#### Full Cashout Response
```json
{
  "success": true,
  "betId": "63fd0b52-f6ef-40cc-8836-9fd79af0367d",
  "requestId": "d2a22d6e-f360-402f-b168-abc35c04700d",
  "cashoutValue": 17263.00,
  "cashoutType": "USER_CASHED_OUT",
  "cashoutPayout": 17263.00,
  "pendingCashOut": false
}
```

#### Partial Cashout Response
```json
{
  "success": true,
  "betId": "63fd0b52-f6ef-40cc-8836-9fd79af0367d",
  "requestId": "e8c422e3-0da4-44c6-a812-d56a398c15b5",
  "cashoutValue": 5178.9,
  "cashoutType": "PARTIAL",
  "partialCashoutStake": 5178.9,
  "cashoutPayout": 5178.9,
  "pendingCashOut": false
}
```

### Response Fields
- **success** - Boolean indicating transaction success
- **requestId** - Unique transaction identifier
- **cashoutPayout** - Amount paid out to user
- **pendingCashOut** - false = immediate, true = requires approval
- **cashoutType** - "USER_CASHED_OUT" (full) or "PARTIAL"

---

## Error Responses

### Error 122: Invalid Request
```json
{
  "trackingId": "sUley9vGpPBt4JlgpKOft",
  "status": "CONFLICT",
  "errorCode": 122,
  "message": "Cash out request is invalid",
  "timestamp": "14-10-2025 16:11:59"
}
```
**Cause:** Field name typo (e.g., `partialcashoutStake` instead of `partialCashoutStake`)

### Error 139: Threshold Exceeded
```json
{
  "trackingId": "lmGXh9SHi0Okb6QSsS1in",
  "status": "CONFLICT",
  "errorCode": 139,
  "message": "Cashout value change is out of threshold",
  "timestamp": "14-10-2025 16:12:15"
}
```
**Cause:** Using full cashout value for partial cashout, or odds changed since value fetch
**Solution:** Refresh cashout value and recalculate

---

## Complete Flow Examples

### Full Cashout Flow
```
1. Login → Get sessionId, userId
2. Get Open Bets → Get betId, stake
3. Get Cashout Value (SSE) → Get cashoutValue
4. Execute Full Cashout → Use exact cashoutValue
5. Result: Full stake returned, bet closed
```

### Partial Cashout Flow (30%)
```
1. Login → Get sessionId, userId
2. Get Open Bets → Get betId, totalStake (e.g., 17,263.00)
3. Get Cashout Value (SSE) → Get fullCashoutValue (e.g., 17,263.00)
4. Calculate (MANDATORY - per API docs):
   partialStake = totalStake × 0.30 = 17,263.00 × 0.30 = 5,178.90
   cashoutValue = (fullCashoutValue × partialStake) / totalStake
   cashoutValue = (17,263.00 × 5,178.90) / 17,263.00 = 5,178.90
5. Execute Partial Cashout → Use calculated cashoutValue + partialStake
6. Result: 5,178.90 returned, 12,084.10 remains active
```

---

## Header Reference

| Endpoint | Headers Required |
|----------|-----------------|
| Login | `accept`, `content-type` |
| Open Bets | `accept`, `x-language`, `x-operator-id`, `x-session-id`, `x-user-id` |
| Cashout Value | `accept: text/event-stream`, `X-SessionId`, `X-OperatorId`, `userId` |
| Execute Cashout | `accept`, `content-type`, `X-SessionId`, `X-OperatorId`, `userId` |

**Note:** Cashout endpoints use `userId` while bets-api uses `x-user-id` (both accept same value).

---

## Key Concepts

### 1. Server-Sent Events (SSE)
The cashout-value endpoint streams data progressively. Always wait for the **code 100 message** before using the cashout value.

### 2. Partial Cashout Calculation (Mandatory)
**CRITICAL:** Per official API documentation, the `cashoutValue` field is **mandatory** and must be calculated as:
```
cashoutValue = (fullCashoutValue × partialStake) / totalStake
```

**Official formula:**
```
cashoutValue = (cov_received_from_us_for_full_stake * pco_stake_user_wants) / total_stake_of_the_cov_received_from_us
```

Never use the full cashout value for partial cashouts - always calculate the proportional value.

### 3. Break-Even Scenario
When `cashoutValue == stake`, the bet is at break-even (no profit/loss if cashed out now).

### 4. Session Expiration
Sessions expire after inactivity. If you get empty responses or auth errors, re-login.

### 5. Odds Changes
Cashout values change in real-time. Always fetch fresh values immediately before execution.

---

## Quick Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Empty response from open bets | Session expired | Re-login and get new sessionId |
| Error 122 | Field name typo | Check camelCase: `partialCashoutStake` |
| Error 139 | Wrong cashout value or stale value | Recalculate using formula or refresh SSE |
| Code 103 persists | Odds unavailable | Wait for code 100 or try different bet |
| Timeout on SSE | Network issue | Retry with --max-time 5-10 |

---

## Test Credentials

**Environment:** Stage
**Operator:** 4093 (Betsson Cameroon)
**User:** +237699198921
**Pass:** 1234

---

**Last Updated:** October 14, 2025
**API Version:** v1
**Status:** ✅ Verified Working
