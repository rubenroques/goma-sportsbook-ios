# Development Journal Entry

## Date
15 October 2025

### Project / Branch
sportsbook-ios / rr/register_fields_fix

### Goals for this session
- Add betting offer booking feature to BettingProvider API
- Support EveryMatrix endpoints for storing/retrieving betting offer selections via booking codes
- Maintain ServicesProvider facade pattern architecture across all providers

### Achievements
- [x] Created public models in `BettingOfferBooking.swift` (BookingSelection, BookingRequest, BookingCodeResponse, BookingRetrievalResponse)
- [x] Added two protocol methods to BettingProvider with comprehensive documentation
- [x] Implemented two EveryMatrix API endpoints (POST `/v2/sports/bets/book`, GET `/v2/sports/bets/book/{code}`)
- [x] Fully implemented methods in EveryMatrixBettingProvider with logging
- [x] Added stub implementations to GomaProvider (returns notSupportedForProvider)
- [x] Added stub implementations to SportRadarBettingProvider (returns notSupportedForProvider)
- [x] Tested both EveryMatrix endpoints with cURL before implementation

### Issues / Bugs Hit
- [x] Initial naming issue: used `.getBookingCode` instead of `.getFromBookingCode` - corrected across all 8 occurrences

### Key Decisions
- **EveryMatrix-only feature**: Goma and SportRadar providers return `notSupportedForProvider` error
- **Simplified model structure**: Created new lightweight `BookingSelection` struct instead of reusing complex `OutcomeBettingOfferReference`
- **No session requirement**: Booking endpoints don't require authentication (`requireSessionKey: false`)
- **Direct ID mapping**: Methods work with betting offer IDs (strings) rather than full selection objects for cleaner API surface

### Experiments & Notes
- Successfully tested EveryMatrix endpoints in staging:
  - POST returned booking code: `7YRLO2UQ`
  - GET successfully retrieved selections from booking code
- Booking feature enables betslip sharing, QR codes, and cross-device transfer use cases
- Models are Codable and Equatable for easy testing and JSON serialization

### Useful Files / Links
- [BettingOfferBooking.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/BettingOfferBooking.swift) - Public domain models
- [BettingProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/BettingProvider.swift) - Protocol interface with new methods
- [EveryMatrixOddsMatrixAPI.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/OddsMatrixAPI/EveryMatrixOddsMatrixAPI.swift) - API endpoint definitions
- [EveryMatrixBettingProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixBettingProvider.swift) - Full implementation (lines 331-367)
- [GomaProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Goma/GomaProvider.swift) - Stub implementation
- [SportRadarBettingProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/SportRadarBettingProvider.swift) - Stub implementation (extension lines 424-454)
- [API Development Guide](../API_DEVELOPMENT_GUIDE.md) - 3-layer architecture reference

### Architecture Notes
This implementation follows the established ServicesProvider facade pattern:

1. **Protocol Layer**: BettingProvider protocol defines interface
2. **Public Models**: Provider-agnostic domain models (BookingCodeResponse, etc.)
3. **Provider Implementation**:
   - EveryMatrix: Full implementation with OddsMatrixAPI endpoints
   - Goma/SportRadar: Return notSupportedForProvider error

**Combine Pattern**: Used throughout for reactive async operations with AnyPublisher

**Endpoint Configuration**: EveryMatrixOddsMatrixAPI enum handles all endpoint specifics (URL, headers, body encoding, session requirements)

### Next Steps
1. Consider adding unit tests for booking code creation/retrieval
2. Update client app UI to expose booking code sharing functionality
3. Document booking code use cases in client app user guides (QR codes, betslip sharing)
4. Monitor EveryMatrix booking endpoint usage in production logs
