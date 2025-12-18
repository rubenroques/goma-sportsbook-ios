## Date
18 December 2025

### Project / Branch
sportsbook-ios / main (changes to be committed)

### Goals for this session
- Compare iOS cashout implementation with web team's working cURL commands (from Miguel Maia)
- Identify discrepancies between iOS and web implementations
- Fix any misalignments in the cashout execution endpoint

### Achievements
- [x] Tested web team's SSE endpoint (`/bets-api/v1/{operatorId}/cashout-value-updates`) - confirmed iOS implementation is correct
- [x] Tested web team's cashout execution endpoint (`/bets-api/v1/{operatorId}/cashout`) - identified critical differences
- [x] Fixed endpoint path: `/cashout/v1/cashout` → `/bets-api/v1/{operatorId}/cashout`
- [x] Fixed headers: Changed from `X-OperatorId`, `X-SessionId`, `userId` to lowercase `x-operator-id`, `x-session-id`, `x-user-id`
- [x] Fixed request body field name: `cashoutChangeAcceptanceType` → `cashoutChangeAcceptance`
- [x] Fixed default acceptance value: `"ACCEPT_ANY"` → `"WITHIN_THRESHOLD"` (ACCEPT_ANY was invalid)
- [x] Added missing body fields: `operatorId` and `language` now included in request

### Issues / Bugs Hit
- [x] Initial cURL tests returned HTTP 403 - session had expired, re-login fixed it
- [x] "Invalid cashout acceptance mode" error revealed `ACCEPT_ANY` is not a valid value for new API
- [x] "Cashout value change is out of threshold" errors during testing - expected behavior when odds change between SSE and execution

### Key Decisions
- **Alignment with web**: Matched iOS implementation exactly to web team's working cURL commands
- **Default acceptance**: Using `WITHIN_THRESHOLD` as default (matches web behavior)
- **Header consistency**: Using bets-api pattern (lowercase hyphenated) for all headers

### Experiments & Notes
- Web sends both `userid` and `x-user-id` headers; iOS only sends `x-user-id` - SSE worked without `userid`, so may be optional
- SSE returns aggregated updates for multiple bets in single stream (new API design vs old per-bet approach)
- Confirmed SSE endpoint was already correct in iOS from previous work

### Useful Files / Links
- [EveryMatrixOddsMatrixWebAPI.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixWebAPI/EveryMatrixOddsMatrixWebAPI.swift) - Endpoint path, headers, auth headers
- [EveryMatrix+NewCashoutRequest.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/REST/Cashout/EveryMatrix+NewCashoutRequest.swift) - Internal request body structure
- [CashoutRequest.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/Cashout/CashoutRequest.swift) - Public request model
- [EveryMatrixModelMapper+CashoutSSE.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/ModelMappers/EveryMatrixModelMapper+CashoutSSE.swift) - Request mapper
- [TicketBetInfoViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/TicketBetInfoViewModel.swift) - Usage site updated
- [Previous cashout handoff DJ](./16-December-2025-cashout-handoff-document.md)

### Next Steps
1. Build and verify all changes compile (BetssonCM UAT scheme)
2. Test end-to-end cashout execution with real bet on STG
3. Verify both full and partial cashout work correctly
4. Consider adding `userid` header if issues arise (web sends it, iOS doesn't currently)
