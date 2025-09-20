# Cashout API Debug

**Issue**: Cashout execution fails with "Current odds not found" despite successful value retrieval
**Environment**: Stage
**Operator**: 4093 (Betsson Cameroon)
**Test User**: +237666999005 / 4050

---

## Step 1: Login

**cURL:**
```bash
curl 'https://betsson-api.stage.norway.everymatrix.com/v1/player/legislation/login' \
  -H 'accept: application/json' \
  -H 'content-type: application/json' \
  --data-raw '{"username":"+237666999005","password":"4050"}'
```

**Response:**
```json
{
  "sessionId": "e24750f9-34d0-49ad-9b4c-87195dda7bdf",
  "id": "7cef0596-3f5c-4d7e-893b-8dba4a1c7637",
  "userId": 7005274,
  "sessionBlockers": ["has-to-set-consents"],
  "hasToAcceptTC": true,
  "hasToSetPass": false
}
```

**Extract for next step:**
- `sessionId`: `e24750f9-34d0-49ad-9b4c-87195dda7bdf`
- `userId`: `7005274`

---

## Step 2: Get Open Bets

**cURL:**
```bash
curl 'https://sports-api-stage.everymatrix.com/bets-api/v1/4093/open-bets?limit=20&placedBefore=2025-09-19T16:00:00' \
  -H 'accept: application/json' \
  -H 'x-language: en' \
  -H 'x-operator-id: 4093' \
  -H 'x-session-id: e24750f9-34d0-49ad-9b4c-87195dda7bdf' \
  -H 'x-user-id: 7005274'
```

**Response (Arsenal bet excerpt):**
```json
[{
  "id": "8ac1b7dd-952f-401a-bf0f-02ac8a8b71ab",
  "selections": [{
    "eventName": "Arsenal - Man City",
    "priceValue": 1.9090909,
    "isLive": false,
    "betName": "Arsenal"
  }],
  "type": "SINGLE",
  "amount": 1600.00,
  "currency": "XAF",
  "maxWinning": 3054.54,
  "status": "OPEN"
}]
```

**Extract for next step:**
- `betId`: `8ac1b7dd-952f-401a-bf0f-02ac8a8b71ab`

---

## Step 3: Get Cashout Value (SSE)

**cURL:**
```bash
curl 'https://sports-api-stage.everymatrix.com/cashout/v1/cashout-value/8ac1b7dd-952f-401a-bf0f-02ac8a8b71ab' \
  -H 'accept: text/event-stream' \
  -H 'X-SessionId: e24750f9-34d0-49ad-9b4c-87195dda7bdf' \
  -H 'X-OperatorId: 4093' \
  -H 'userId: 7005274' \
  --max-time 4
```

**Response (Server-Sent Events):**
```
id:3eFQ0yDr8fGoSghNSjJcJa
event:message
data:{"messageType":"AUTOCASHOUT_RULE","betId":"8ac1b7dd-952f-401a-bf0f-02ac8a8b71ab","betHasAutoCashout":false}

id:7Ey28ZCbsgSoxuE3aImj9t
event:message
data:{
  "messageType": "CASHOUT_VALUE",
  "betId": "8ac1b7dd-952f-401a-bf0f-02ac8a8b71ab",
  "screenId": "0a25302f-1824-472f-9e6b-8364723f67be",
  "cashoutValue": 1600.00,
  "currentPossibleWinning": 3054.54,
  "stake": 1600.00,
  "autoCashOutEnabled": true,
  "partialCashOutEnabled": true,
  "details": {
    "code": 100,
    "message": "Success"
  },
  "cashoutValueSettings": {
    "autoCashOutEnabled": true,
    "partialCashOutEnabled": true,
    "covValidationAcceptHigher": false,
    "covValidationAcceptLower": false
  }
}
```

**Extract for next step:**
- `cashoutValue`: `1600.00`
- `code`: `100` (Success)
- `partialCashOutEnabled`: `true`

---

## Step 4: Execute FULL Cashout

**cURL:**
```bash
curl 'https://sports-api-stage.everymatrix.com/cashout/v1/cashout' \
  -X POST \
  -H 'accept: application/json' \
  -H 'content-type: application/json' \
  -H 'X-SessionId: e24750f9-34d0-49ad-9b4c-87195dda7bdf' \
  -H 'X-OperatorId: 4093' \
  -H 'userId: 7005274' \
  --data-raw '{
    "betId": "8ac1b7dd-952f-401a-bf0f-02ac8a8b71ab",
    "cashoutValue": 1600.00,
    "cashoutType": "FULL",
    "CashoutChangeAcceptanceType": "ACCEPT_ANY"
  }'
```

**Response:**
```json
{
  "trackingId": "93fDDPBtmKEqInk2mHCtk",
  "status": "NOT_FOUND",
  "message": "Current odds not found",
  "timestamp": "19-09-2025 14:38:59"
}
```

---

## Data Pipeline Flow

1. **Login** → Extract `sessionId` and `userId`
2. **Get Open Bets** → Extract `betId` from desired bet
3. **Get Cashout Value** → Extract `cashoutValue` from SSE stream
4. **Execute Cashout** → Use extracted values in cashout request

**Key Headers Pipeline:**
- `X-SessionId`: From login response `sessionId`
- `X-OperatorId`: Always `4093`
- `userId`: From login response `userId`

**Key Values Pipeline:**
- `betId`: From open bets response
- `cashoutValue`: From SSE cashout-value response
- `partialCashoutStake`: User-defined amount
- Partial formula: `(cashoutValue * partialStake) / totalStake`

---

❌ **Failing**: Cashout execution with error code 103 "Current odds not found"