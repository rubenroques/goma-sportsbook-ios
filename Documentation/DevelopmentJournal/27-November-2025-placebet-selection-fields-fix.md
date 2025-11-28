## Date
27 November 2025

### Project / Branch
BetssonCameroonApp / rr/casino-redesign

### Goals for this session
- Investigate EM WebAPI team request to add `marketId`, `bettingTypeId`, `outcomeId` fields to Place Bet selections
- Align `BetSelectionInfo` struct with EM WebAPI v2.0 specification

### Achievements
- [x] Discovered fields already existed but with wrong types and naming
- [x] Fixed `BetSelectionInfo` struct to match EM WebAPI v2.0 spec:
  - `bettingOfferId`: `String` → `Int`
  - `outcomeId`: `String` → `Int?`
  - `bettingTypeId`: `String` → `Int?`
  - `marketId`: `String` → `marketIDs: [Int]` (renamed + array)
  - Added mandatory `banker: Bool` field (was missing)
  - Removed `eventId` (not in EM spec)
- [x] Updated conversion logic in `EveryMatrixBettingProvider.convertBetTicketsToPlaceBetRequest()`

### Issues / Bugs Hit
- None - straightforward implementation once spec was clarified

### Key Decisions
- **Remove `eventId`**: Field was not in EM v2.0 spec, removed entirely
- **`banker: false`**: Always send `false` for standard single/multiple bets
- **`marketIDs` as array**: Send single-element array `[marketId]` for normal markets (spec indicates multiple IDs only for No Goal markets)
- **Optional fields**: `outcomeId` and `bettingTypeId` use `encodeIfPresent` to omit when nil

### Experiments & Notes
- Initial investigation showed fields existed but EM spec comparison revealed:
  - Type mismatches (String vs number)
  - Field naming issue (`marketId` vs `marketIDs`)
  - Missing mandatory field (`banker`)
  - Extra field not in spec (`eventId`)

### Useful Files / Links
- [EveryMatrix+PlaceBet.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/REST/Betting/EveryMatrix+PlaceBet.swift)
- [EveryMatrixBettingProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixBettingProvider.swift)
- EM WebAPI v2.0 Documentation (PDF from PM)

### Next Steps
1. Test place bet flow end-to-end in staging environment
2. Verify JSON payload matches EM expected format
3. Confirm with EM WebAPI team that implementation is correct
