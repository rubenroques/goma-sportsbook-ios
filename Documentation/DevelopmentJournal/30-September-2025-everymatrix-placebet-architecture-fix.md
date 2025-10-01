# Development Journal Entry

## Date
30 September 2025

### Project / Branch
sportsbook-ios / rr/virtuals

### Goals for this session
- Understand EveryMatrix placeBet endpoint implementation
- Fix architectural violation: public models in API layer
- Implement proper 3-layer ServicesProvider architecture for place bet

### Achievements
- [x] Identified architectural violation: `PlaceBetRequest` and `BetSelectionInfo` were public models defined in API layer file
- [x] Created `EveryMatrix+PlaceBet.swift` following established pattern (like `EveryMatrix+MyBets.swift`)
- [x] Moved models to internal `EveryMatrix` namespace
- [x] Updated `EveryMatrixOddsMatrixAPI.swift` to use `EveryMatrix.PlaceBetRequest`
- [x] Updated `EveryMatrixBettingProvider.swift` to use new internal types
- [x] Simplified `PlaceBetRequest` model to match actual API structure (removed unnecessary fields)
- [x] Added comprehensive logging: request body, headers, response body, 409 error handling
- [x] Successfully tested bet placement with simplified model

### Issues / Bugs Hit
- [x] Initial 409 Conflict error on second bet placement (likely duplicate bet, not model issue)
- [x] Missing comprehensive logging made debugging difficult
- [x] Error model had wrong field reference (`apiError.message` → `apiError.error`)

### Key Decisions
- **Adopted established EveryMatrix pattern**: Created `EveryMatrix+PlaceBet.swift` in `Models/Shared/` directory to match existing `EveryMatrix+MyBets.swift`, `EveryMatrix+Cashier.swift` structure
- **Simplified request model**: Removed fields sent via headers (`ucsOperatorId`, `userId`, `username`) and unnecessary fields (`currency`, `oddsValidationType`, `ubsWalletId`, `freeBet`)
- **Changed `amount` field**: From `Double` to `String` matching API expectation, renamed to `stakeAmount`
- **Enhanced logging**: Added request/response body logging in `EveryMatrixBaseConnector` for better debugging
- **409 handling**: Added specific case for 409 Conflict errors with proper error message extraction

### Experiments & Notes
- Compared iOS request structure with working web app cURL request
- Web app still uses old full structure, but simplified structure works for iOS
- EveryMatrix API appears flexible - accepts both simplified and full payload structures
- Terminal type changed to "SSBT" (user modified from "MOBILE")

### Architecture Pattern Applied
**3-Layer ServicesProvider Architecture:**
1. **Domain Models** (`BetTicket`, `PlacedBetsResponse`) - shared across providers
2. **Provider Layer** (`EveryMatrixBettingProvider`) - business logic, converts domain → internal
3. **Internal Models** (`EveryMatrix.PlaceBetRequest`) - provider-specific API structures

**Data Flow:**
```
BetTicket (domain)
  → convertBetTicketsToPlaceBetRequest()
  → EveryMatrix.PlaceBetRequest (internal)
  → EveryMatrixOddsMatrixAPI.placeBet(betData:)
  → HTTP POST
  → EveryMatrix.PlaceBetResponse (internal)
  → convertResponseToPlacedBetsResponse()
  → PlacedBetsResponse (domain)
```

### Useful Files / Links
- [EveryMatrix+PlaceBet.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Shared/EveryMatrix+PlaceBet.swift) - New internal models
- [EveryMatrixOddsMatrixAPI.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/OddsMatrixAPI/EveryMatrixOddsMatrixAPI.swift) - API endpoint definition
- [EveryMatrixBettingProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixBettingProvider.swift) - Provider implementation
- [EveryMatrixBaseConnector.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixBaseConnector.swift) - Enhanced with logging
- [API Development Guide](../API_DEVELOPMENT_GUIDE.md) - 3-layer architecture documentation

### Code Changes Summary
**Created:**
- `EveryMatrix+PlaceBet.swift` - Internal models for place bet request/response

**Modified:**
- `EveryMatrixOddsMatrixAPI.swift` - Removed public models, use `EveryMatrix.PlaceBetRequest`
- `EveryMatrixBettingProvider.swift` - Updated type references, removed duplicate response model
- `EveryMatrixBaseConnector.swift` - Added request/response logging, 409 error handling

**Model Structure (Simplified):**
```swift
EveryMatrix.PlaceBetRequest {
    type: String              // "SINGLE" or "MULTIPLE"
    systemBetType: String?    // null for now
    eachWay: Bool             // false
    selections: [BetSelectionInfo]
    stakeAmount: Double
    terminalType: String      // "SSBT"
    lang: String              // "en"
}
```

### Next Steps
1. Monitor bet placement with new logging to catch any edge cases
2. Consider making `terminalType` configurable (currently hardcoded "SSBT")
3. Consider making `lang` dynamic based on user locale
4. Verify all EveryMatrix endpoints follow proper 3-layer architecture
5. Document the simplified vs full payload difference with EveryMatrix team
