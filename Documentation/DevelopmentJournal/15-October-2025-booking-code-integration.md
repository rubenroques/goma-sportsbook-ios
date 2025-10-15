## Date
15 October 2025

### Project / Branch
sportsbook-ios / rr/bettingOfferSubscription

### Goals for this session
- Integrate betting offer booking API with bet success screen
- Generate shareable booking codes from placed bets
- Add comprehensive debug logging for bet placement flow
- Pass betting tickets data through success screen

### Achievements
- [x] Enhanced BetPlacedState enum to include betId, betslipId, and bettingTickets array
- [x] Added comprehensive [BET_PLACEMENT] debug logging throughout entire bet placement flow
- [x] Updated BetSuccessViewModelProtocol with bookingCode publisher and property
- [x] Implemented automatic booking code creation in BetSuccessViewModel
- [x] Integrated ServicesProvider.createBookingCode() API call
- [x] Updated share functionality to use booking code with triple fallback (bookingCode → betId → betslipId)
- [x] Changed share closure to parameterless design (coordinator resolves code)

### Issues / Bugs Hit
- [x] Initial implementation used `environment: Environment` parameter - refined to `servicesProvider: ServicesProvider.Client` for cleaner dependency injection
- [x] betId coming back empty from API - added logging to debug and implemented fallback strategy

### Key Decisions
- **Triple fallback strategy for sharing**: bookingCode (primary) → betId → betslipId
  - Ensures users can always share even if booking code API fails
  - Graceful degradation for unsupported providers
  - Comprehensive logging at each fallback level

- **Automatic booking code creation**: ViewModel creates booking code on init, not on share button tap
  - Reactive approach - code ready when user wants to share
  - Non-blocking - doesn't delay success screen presentation
  - Uses Combine publisher for state updates

- **Debug logging strategy**: All logs prefixed with `[BET_PLACEMENT]`
  - Easy filtering: `grep "[BET_PLACEMENT]"` in console
  - Traces entire flow from placement → response → booking code → sharing
  - Logs betting offer IDs, ticket details, and all available ID fields

- **ServicesProvider dependency**: Pass `ServicesProvider.Client` instead of full `Environment`
  - Cleaner dependency injection
  - Only requires what's needed (betting provider access)
  - Easier testing and mocking

- **Parameterless share closure**: Changed from `((String) -> Void)?` to `(() -> Void)?`
  - Coordinator resolves the code to share (bookingCode, betId, or betslipId)
  - ViewController doesn't need to know which ID to use
  - Single source of truth for fallback logic

### Experiments & Notes
- BettingTicket model contains `bettingId` field which maps to betting offer ID
- ServicesProvider booking code API returns `BookingCodeResponse` with `code` and optional `message`
- Booking codes are 8-character alphanumeric strings (e.g., "7YRLO2UQ")
- API calls use Combine publishers with `.receive(on: DispatchQueue.main)` for UI thread safety

### Useful Files / Links
**Models:**
- [BetPlacedDetails](../../BetssonCameroonApp/App/Models/Betting/BetPlacedDetails.swift) - Bet placement response model
- [BettingTicket](../../BetssonCameroonApp/App/Models/Betting/BettingTicket.swift) - Ticket model with bettingId
- [BettingOfferBooking](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/BettingOfferBooking.swift) - Booking code models

**ViewModels:**
- [BetSuccessViewModel](../../BetssonCameroonApp/App/Screens/Betslip/BetSuccessScreen/BetSuccessViewModel.swift) - Success screen with booking code creation
- [BetSuccessViewModelProtocol](../../BetssonCameroonApp/App/Screens/Betslip/BetSuccessScreen/BetSuccessViewModelProtocol.swift) - Protocol with bookingCode publisher
- [SportsBetslipViewModel](../../BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/SportsBetslipViewModel.swift) - Bet placement with debug logging

**Coordinators:**
- [BetslipCoordinator](../../BetssonCameroonApp/App/Coordinators/Screens/BetslipCoordinator.swift) - Handles success screen and sharing

**API Documentation:**
- [Booking Code API Journal](15-October-2025-betting-offer-booking-api.md) - Original API implementation

### Debug Logging Flow

Complete logging trail for successful bet placement and sharing:

```
[BET_PLACEMENT] 📋 Placing bet with 2 tickets
[BET_PLACEMENT]   [1] Manchester vs Liverpool - Home Win @ 2.50
[BET_PLACEMENT]   [2] Real Madrid vs Barcelona - Over 2.5 @ 1.80
[BET_PLACEMENT] ✅ Placement request completed
[BET_PLACEMENT] 🎉 Received response with 1 items
[BET_PLACEMENT]   Response[0]:
[BET_PLACEMENT]     betId: nil
[BET_PLACEMENT]     betslipId: ABC123XYZ
[BET_PLACEMENT]     betSucceed: true
[BET_PLACEMENT]     selections count: 2
[BET_PLACEMENT] 🏷️ Extracted IDs - betId: nil, betslipId: ABC123XYZ
[BET_PLACEMENT] 🎯 Coordinator received success - betId: nil, betslipId: ABC123XYZ, tickets: 2
[BET_PLACEMENT] 🎬 Showing success screen - betId: nil, betslipId: ABC123XYZ, tickets: 2
[BET_PLACEMENT] 📱 Success ViewModel created - betId: nil, betslipId: ABC123XYZ, tickets: 2
[BET_PLACEMENT]   [1] Manchester vs Liverpool - Home Win
[BET_PLACEMENT]   [2] Real Madrid vs Barcelona - Over 2.5
[BET_PLACEMENT] 📋 Creating booking code for 2 offers:
[BET_PLACEMENT]   [1] 283682027195084800
[BET_PLACEMENT]   [2] 283682211352619520
[BET_PLACEMENT] ✅ Booking code request completed
[BET_PLACEMENT] 🎉 Booking code created: 7YRLO2UQ
[BET_PLACEMENT] 📤 Sharing betslip - code: 7YRLO2UQ
```

### Architecture Notes

**Data Flow:**
1. User places bet → SportsBetslipViewModel
2. Extract betId, betslipId, tickets → BetPlacedState.success(...)
3. Pass to BetslipCoordinator
4. Create BetSuccessViewModel with ServicesProvider
5. ViewModel calls createBookingCode() on init
6. Booking code stored in reactive subject
7. User taps share → Coordinator resolves code (bookingCode ?? betId ?? betslipId)
8. Present UIActivityViewController with code

**Reactive Pattern:**
- ViewModel creates booking code asynchronously
- Publishes result via `bookingCodePublisher: AnyPublisher<String?, Never>`
- Coordinator accesses via computed property `bookingCode: String?`
- Future enhancement: ViewController could observe publisher to show loading state

### Next Steps
1. Test bet placement end-to-end with real backend to verify betId/betslipId values
2. Monitor `[BET_PLACEMENT]` logs to identify why betId is empty
3. Consider adding loading indicator while booking code is being created
4. Implement "Open Betslip Details" navigation (currently placeholder)
5. Add analytics tracking for booking code creation success/failure
6. Consider adding booking code to success screen UI (not just in share)
7. Test share functionality with QR code generation libraries
