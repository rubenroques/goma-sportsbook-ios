## Date
18 December 2025

### Project / Branch
sportsbook-ios / rr/cashout_fixes

### Goals for this session
- Fix MyBets API decoding errors causing settled bets to fail loading
- Properly handle type mismatches in EveryMatrix REST models

### Achievements
- [x] Fixed `earlySettlement` type mismatch (`String?` → `Bool?`)
- [x] Fixed `partialCashOuts` type mismatch (`[String]?` → `[FailableDecodable<PartialCashOut>]?`)
- [x] Added `EveryMatrix.PartialCashOut` internal REST model with correct API fields
- [x] Added public `PartialCashOut` domain model to ServicesProvider
- [x] Added `partialCashOuts: [PartialCashOut]?` property to public `Bet` struct
- [x] Created mapper function `partialCashOut(fromEveryMatrixPartialCashOut:)`
- [x] Wrapped `selections` array with `FailableDecodable` for resilience
- [x] Updated mapper to unwrap `.content` from FailableDecodable wrappers

### Issues / Bugs Hit
- [x] `earlySettlement` field returning `Bool` but model expected `String` - caused decode failure
- [x] `partialCashOuts` field returning array of objects but model expected `[String]` - caused decode failure on CASHED_OUT bets

### Key Decisions
- Used `FailableDecodable` wrapper for arrays to prevent single malformed item from failing entire bet decode
- Followed proper 2-layer REST architecture: Internal Model → Mapper → Domain Model
- Used actual API response to determine `PartialCashOut` structure (via cURL testing)

### Experiments & Notes
- Tested API directly with cURL to discover actual `partialCashOuts` structure:
  ```json
  {
    "requestId": "49071f53-ba81-4f69-8ce3-e46649409387",
    "usedStake": 0.75,
    "cashOutAmount": 0.75,
    "status": "SUCCESSFUL",
    "extraInfo": "{...}",
    "cashOutDate": "2025-12-15T17:18:13Z"
  }
  ```
- `extraInfo` is a JSON string (not nested object) - kept as `String?` in internal model, excluded from public model

### Useful Files / Links
- [EveryMatrix+MyBets.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/REST/EveryMatrix+MyBets.swift) - Internal REST models
- [Betting.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/Betting.swift) - Public domain models
- [EveryMatrixModelMapper+MyBets.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/ModelMappers/EveryMatrixModelMapper+MyBets.swift) - Model mapper
- [FailableDecodable.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Helpers/FailableDecodable.swift) - Failable decode wrapper

### Next Steps
1. Build and verify MyBets loads correctly for all tabs (Open, Won, Lost, Cashed Out)
2. Test with users that have partial cashout history
3. Consider adding more fields from API if needed in future (e.g., `hasVirtualSportSelection`)
