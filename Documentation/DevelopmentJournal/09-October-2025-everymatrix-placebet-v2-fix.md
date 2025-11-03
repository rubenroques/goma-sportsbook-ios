# Development Journal Entry

## Date
09 October 2025

### Project / Branch
sportsbook-ios / rr/rebet

### Goals for this session
- Investigate why EveryMatrix place bet stopped working after recent changes
- Understand what fields were removed in the September 30 refactoring
- Restore complete V2 API structure matching working production cURL

### Achievements
- [x] Identified root cause: Recent refactoring removed critical fields and used wrong data type
- [x] Analyzed commit 1a8764de1 from Oct 1 that "Fixed banner updates. Fix place bet request+response"
- [x] Compared current model against working production cURL V2 endpoint
- [x] Restored all 11 V2 fields to `PlaceBetRequest` model
- [x] Fixed critical bug: `amount` field was `Double`, API requires `String`
- [x] Commented out V3 fields (`systemBetType`, `eachWay`, `lang`) for future reference
- [x] Updated `convertBetTicketsToPlaceBetRequest()` to format amount as String with 2 decimal places

### Issues / Bugs Hit
- [x] **Critical Data Type Mismatch**: `amount: Double` → API expects `"250.00"` as String
- [x] **Missing Fields**: Original model had 14 fields, simplified version only had 7 active fields
- [x] **V2 vs V3 Confusion**: Code mixed V2 endpoint path with V3-style field names
- [x] **Field Removal**: `ucsOperatorId`, `userId`, `username`, `currency`, `oddsValidationType` were removed

### Key Decisions
- **Restored complete V2 structure**: Added back all fields from original implementation
- **Fixed amount type**: Changed from `Double` to `String` matching API expectation: `String(format: "%.2f", totalAmount)`
- **Commented V3 fields**: Kept `systemBetType`, `eachWay`, `lang` as comments instead of deleting for documentation
- **Kept terminalType as "SSBT"**: User preference over old "MOBILE" value
- **Maintained architectural improvements**: Kept internal `EveryMatrix` namespace from refactoring

### Experiments & Notes

#### Investigation Process
1. Read `EveryMatrixBettingProvider.swift` to understand current implementation
2. Examined `EveryMatrix+PlaceBet.swift` for model structure
3. Checked commit history for recent changes: `git log --oneline --since="2 weeks ago"`
4. Found commit 1a8764de1 from Oct 1: "Fixed banner updates. Fix place bet request+response"
5. Compared old vs new model structures using `git show`
6. Read development journal entry from Sept 30 explaining the refactoring rationale

#### Old Model (Before Oct 1 Refactoring)
```swift
PlaceBetRequest {
    ucsOperatorId: Int           // 4093
    userId: String               // From parameter
    username: String             // From parameter
    currency: String             // Default "EUR"
    type: String                 // "SINGLE" or "MULTIPLE"
    selections: [BetSelectionInfo]
    amount: Double               // ❌ Wrong type!
    oddsValidationType: String   // Default "ACCEPT_ANY"
    terminalType: String         // "MOBILE"
    ubsWalletId: String?         // nil
    freeBet: String?             // nil
}
```

#### Simplified Model (Oct 1 - Today)
```swift
PlaceBetRequest {
    type: String
    systemBetType: String?       // V3 field
    eachWay: Bool                // V3 field
    selections: [BetSelectionInfo]
    stakeAmount: Double          // ❌ Wrong field name AND type!
    terminalType: String         // "SSBT"
    lang: String                 // V3 field
}
```

#### Working Production cURL (V2 Endpoint)
```bash
curl 'https://sports-api-stage.everymatrix.com/place-bet/4093/v2/bets' \
  -H 'x-sessionid: 607a318c-3227-4735-aacb-fc46080dab6b' \
  --data-raw '{
    "ucsOperatorId": 4093,
    "userId": "7054250",
    "username": "+237699198921",
    "currency": "XAF",
    "type": "SINGLE",
    "selections": [{
      "bettingOfferId": "282311337880705280",
      "priceValue": 1.6060606
    }],
    "amount": "250.00",          // ← STRING, not number!
    "oddsValidationType": "ACCEPT_ANY",
    "terminalType": "DESKTOP",
    "ubsWalletId": null,
    "freeBet": null
  }'
```

#### Final Model (This Session)
```swift
PlaceBetRequest {
    ucsOperatorId: Int           // From config.domainId
    userId: String               // From parameter
    username: String             // From parameter
    currency: String             // Default "EUR"
    type: String                 // "SINGLE" or "MULTIPLE"
    // systemBetType: String?    // V3 field - commented out
    // eachWay: Bool              // V3 field - commented out
    selections: [BetSelectionInfo]
    amount: String               // ✅ Fixed to String!
    oddsValidationType: String   // Default "ACCEPT_ANY"
    terminalType: String         // "SSBT"
    // lang: String               // V3 field - commented out
    ubsWalletId: String?         // nil
    freeBet: String?             // nil
}
```

### Architectural Context

**Why the Refactoring Happened (Sept 30):**
According to [30-September-2025-everymatrix-placebet-architecture-fix.md](./30-September-2025-everymatrix-placebet-architecture-fix.md):
- Fixed architectural violation: models were public in API layer
- Created `EveryMatrix+PlaceBet.swift` following established pattern
- Simplified request model thinking fields were sent via headers
- Successfully tested with simplified structure

**Why It Broke:**
The Sept 30 refactoring removed too many fields and introduced type errors:
1. Removed `userId`, `username` from body (assumption they'd be in headers - incorrect)
2. Removed `currency`, `oddsValidationType` entirely
3. Changed `amount` field name to `stakeAmount`
4. Used `Double` instead of `String` for amount
5. Added V3 fields that aren't in V2 API

**What We Fixed:**
- Kept architectural improvements (internal `EveryMatrix` namespace)
- Restored complete V2 field structure
- Fixed critical `amount` type: `Double` → `String`
- Commented out V3 fields instead of deleting for future reference

### Useful Files / Links
- [EveryMatrix+PlaceBet.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Shared/EveryMatrix+PlaceBet.swift) - Request/response models
- [EveryMatrixBettingProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixBettingProvider.swift) - Provider implementation
- [EveryMatrixOddsMatrixAPI.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/OddsMatrixAPI/EveryMatrixOddsMatrixAPI.swift) - API endpoint definition
- [EveryMatrixBaseConnector.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixBaseConnector.swift) - HTTP connector with logging
- [Previous Journal Entry](./30-September-2025-everymatrix-placebet-architecture-fix.md) - Original refactoring context
- [API Development Guide](../API_DEVELOPMENT_GUIDE.md) - 3-layer architecture documentation

### Code Changes Summary

**Modified Files:**

1. **`EveryMatrix+PlaceBet.swift`**
   - Restored 11 V2 fields: `ucsOperatorId`, `userId`, `username`, `currency`, `type`, `selections`, `amount`, `oddsValidationType`, `terminalType`, `ubsWalletId`, `freeBet`
   - Changed `amount: Double` → `amount: String` (critical fix)
   - Commented out V3 fields: `systemBetType`, `eachWay`, `lang`
   - Updated initializer to match new structure

2. **`EveryMatrixBettingProvider.swift`**
   - Updated `convertBetTicketsToPlaceBetRequest()` method
   - Added back: `ucsOperatorId` from `EveryMatrixUnifiedConfiguration.shared.domainId`
   - Added back: `userId`, `username`, `currency`, `oddsValidationType` with proper defaults
   - Fixed amount formatting: `String(format: "%.2f", totalAmount)`
   - Removed: `systemBetType`, `eachWay`, `lang` from initialization

**Field Comparison Table:**

| Field | Old (Pre-Sept 30) | Simplified (Sept 30) | Working cURL | Final (This Session) |
|-------|-------------------|----------------------|--------------|----------------------|
| ucsOperatorId | ✅ Int | ❌ Missing | ✅ Int | ✅ Int |
| userId | ✅ String | ❌ Missing | ✅ String | ✅ String |
| username | ✅ String | ❌ Missing | ✅ String | ✅ String |
| currency | ✅ String | ❌ Missing | ✅ String | ✅ String |
| type | ✅ String | ✅ String | ✅ String | ✅ String |
| systemBetType | ❌ | ✅ String? | ❌ | 💬 Commented |
| eachWay | ❌ | ✅ Bool | ❌ | 💬 Commented |
| selections | ✅ Array | ✅ Array | ✅ Array | ✅ Array |
| amount | ⚠️ Double | ⚠️ Double | ✅ String | ✅ String |
| oddsValidationType | ✅ String | ❌ Missing | ✅ String | ✅ String |
| terminalType | ✅ String | ✅ String | ✅ String | ✅ String |
| lang | ❌ | ✅ String | ❌ | 💬 Commented |
| ubsWalletId | ✅ String? | ❌ Missing | ✅ null | ✅ String? |
| freeBet | ✅ String? | ❌ Missing | ✅ null | ✅ String? |

Legend: ✅ Correct | ❌ Missing | ⚠️ Wrong Type | 💬 Commented

### Next Steps
1. Test place bet functionality with restored V2 structure
2. Monitor logs from `EveryMatrixBaseConnector` cURL output (lines 208-210)
3. Verify amount formatting: ensure `String(format: "%.2f", totalAmount)` produces correct format
4. Document V3 endpoint differences when they become available
5. Consider making `terminalType` configurable via configuration file
6. Verify currency handling for different markets (EUR, XAF, etc.)
