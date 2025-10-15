# Development Journal Entry

## Date
15 October 2025

### Project / Branch
sportsbook-ios / rr/register_fields_fix

### Goals for this session
- Move booking code endpoints from OddsMatrix API to Player API (correct base URL)
- Refactor booking code methods from BettingProvider to PrivilegedAccessManager
- Fix architectural misalignment where user-centric features were in betting provider

### Achievements
- [x] Added booking code endpoints to EveryMatrixPlayerAPI.swift
  - Added `createBookingCode` and `getFromBookingCode` enum cases
  - Configured endpoints: `/v2/sports/bets/book` and `/v2/sports/bets/book/{code}`
  - Set correct HTTP methods (POST/GET), body encoding, and headers
  - Set `requireSessionKey: false` (public endpoints)

- [x] Removed booking code endpoints from EveryMatrixOddsMatrixAPI.swift
  - Removed enum cases and all switch statements
  - Cleaned up query, headers, method, body, and auth header handling

- [x] Added booking methods to PrivilegedAccessManagerProvider protocol
  - Added `createBookingCode(bettingOfferIds:originalSelectionsLength:)`
  - Added `getBettingOfferIds(bookingCode:)`
  - Included comprehensive documentation

- [x] Implemented booking methods in EveryMatrixPrivilegedAccessManager.swift
  - Uses `EveryMatrixPlayerAPIConnector` (already available)
  - Proper error handling and logging
  - Maps responses correctly

- [x] Removed booking methods from EveryMatrixBettingProvider.swift
  - Removed both `createBookingCode` and `getBettingOfferIds` implementations
  - No longer needs Player API connector

- [x] Removed booking methods from BettingProvider protocol
  - Removed method signatures and documentation (lines 55-112)

- [x] Updated Client.swift routing
  - Changed from `bettingProvider.createBookingCode(...)` to `privilegedAccessManager.createBookingCode(...)`
  - Changed from `bettingProvider.getBettingOfferIds(...)` to `privilegedAccessManager.getBettingOfferIds(...)`
  - Updated error handling to use `ServiceProviderError.privilegedAccessManagerNotFound`

### Issues / Bugs Hit
- [ ] Session interrupted before completing stub removal in GomaProvider and SportRadarBettingProvider
- [ ] Build and testing not completed

### Key Decisions
- **Architectural realignment**: Booking codes are user-centric features (sharing/restoring betslips), not betting transactions
  - Moved from `BettingProvider` → `PrivilegedAccessManagerProvider`
  - This aligns with the existing separation of concerns:
    - **BettingProvider**: Real-time betting operations (place bet, cashout, bet history)
    - **PrivilegedAccessManager**: User-centric operations (profile, balance, transactions)

- **API correction**: Booking endpoints belong to Player API, not OddsMatrix API
  - **Old (wrong)**: `https://sports-api-stage.everymatrix.com/v2/sports/bets/book` ❌
  - **New (correct)**: `https://betsson-api.stage.norway.everymatrix.com/v2/sports/bets/book` ✅

- **No authentication required**: Booking code endpoints are public (requireSessionKey: false)
  - This allows sharing betslips without requiring login

### Experiments & Notes
- The migration touched 9 files across the ServicesProvider framework:
  1. EveryMatrixPlayerAPI.swift - Added endpoints
  2. EveryMatrixOddsMatrixAPI.swift - Removed endpoints
  3. PrivilegedAccessManager.swift (protocol) - Added methods
  4. EveryMatrixPrivilegedAccessManager.swift - Implemented methods
  5. EveryMatrixBettingProvider.swift - Removed methods
  6. BettingProvider.swift (protocol) - Removed methods
  7. Client.swift - Updated routing
  8. GomaProvider.swift - Needs stub removal (incomplete)
  9. SportRadarBettingProvider.swift - Needs stub removal (incomplete)

- The booking code models (BookingRequest, BookingCodeResponse, BookingSelection, BookingRetrievalResponse) remain unchanged in `BettingOfferBooking.swift`

### Useful Files / Links
- [EveryMatrixPlayerAPI.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/PlayerAPI/EveryMatrixPlayerAPI.swift:60-63) - New booking endpoints
- [EveryMatrixPrivilegedAccessManager.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Managers/EveryMatrixPrivilegedAccessManager.swift:621-654) - Implementation
- [PrivilegedAccessManager.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/PrivilegedAccessManager.swift:161-181) - Protocol definition
- [Client.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift:1466-1482) - Updated routing
- [BettingOfferBooking.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/BettingOfferBooking.swift) - Data models
- [BetslipCoordinator.swift](../../BetssonCameroonApp/App/Coordinators/Screens/BetslipCoordinator.swift:126-159) - Usage in BetssonCameroonApp

### Next Steps
1. ~~Remove stub implementations from GomaProvider.swift (lines 1564-1572)~~ - Interrupted
2. ~~Remove stub implementations from SportRadarBettingProvider.swift (lines 446-454)~~ - Interrupted
3. Build BetssonCameroonApp to verify no compilation errors
4. Test booking code creation and retrieval in simulator
5. Verify correct API endpoint is being called (Player API, not OddsMatrix API)
6. Consider adding unit tests for the new PrivilegedAccessManager booking methods

### Additional Context
This migration fixes a bug where booking code endpoints were using the wrong base URL, which would have caused API failures in production. The architectural realignment also improves code organization by placing user-centric features in the correct provider.
