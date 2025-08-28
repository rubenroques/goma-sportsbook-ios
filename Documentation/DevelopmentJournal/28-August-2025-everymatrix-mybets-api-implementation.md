# EveryMatrix MyBets API Implementation

## Date
28 August 2025

### Project / Branch
sportsbook-ios / rr/mybets_profile_features

### Goals for this session
- Implement EveryMatrix MyBets API endpoints in ServicesProvider
- Follow established architectural patterns and naming conventions
- Integrate real API data with existing MyBets screen structure
- Test API endpoints with proper authentication flow

### Achievements
- [x] Analyzed web MyBets documentation and API structure from frontend team
- [x] Reviewed existing betting data models in ServicesProvider framework
- [x] Successfully tested EveryMatrix API endpoints with real authentication
- [x] Implemented complete EveryMatrix MyBets API endpoints with proper error handling
- [x] Fixed EveryMatrix namespace pattern compliance following `extension EveryMatrix` convention
- [x] Built and verified BetssonCameroonApp successfully compiles with new implementation

### Issues / Bugs Hit
- [x] ~~Initial API endpoint URL was outdated - fixed with correct `https://sports-api-stage.everymatrix.com/bets-api/v1/` URL~~
- [x] ~~ServiceProviderError.apiError case didn't exist - fixed by using ServiceProviderError.errorMessage(message:)~~
- [x] ~~SportType.football enum case incorrect - fixed by using SportType.defaultFootball struct~~
- [x] ~~EveryMatrix models didn't follow namespace pattern - fixed by creating EveryMatrix+MyBets.swift extension~~

### Key Decisions
- **API Architecture**: Used existing EveryMatrixOddsMatrixAPI enum to add MyBets endpoints instead of creating separate API structure
- **Date Handling**: Replaced hardcoded date strings with dynamic calculation using `Calendar.current.date(byAdding: .month, value: 6, to: Date())`
- **Model Organization**: Followed established `extension EveryMatrix` namespace pattern for all internal provider models
- **Error Handling**: Used existing ServiceProviderError cases for consistent error propagation
- **Data Mapping**: Created comprehensive mapping functions from EveryMatrix API responses to internal Bet models

### Experiments & Notes
- **API Testing**: Successfully authenticated using login endpoint to get valid session tokens for MyBets API calls
- **Namespace Pattern**: Discovered and implemented the established EveryMatrix model naming convention using enum as namespace
- **Build Verification**: Used proper simulator device ID (`229F70D9-99F6-411E-870A-23C4B153C01E`) instead of simulator name for xcodebuild

### Useful Files / Links
- [EveryMatrix MyBets Models](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Shared/EveryMatrix+MyBets.swift)
- [EveryMatrix API Endpoints](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/OddsMatrixAPI/EveryMatrixOddsMatrixAPI.swift)
- [EveryMatrix Betting Provider](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixBettingProvider.swift)
- [MyBets ViewController](../../BetssonCameroonApp/App/Screens/MyBets/MyBetsViewController.swift)
- [Web MyBets Documentation](provided by user - comprehensive API structure and data flow)

### API Endpoints Implemented
**Base URL**: `https://sports-api-stage.everymatrix.com/bets-api/v1`

- **GET** `/4093/open-bets` - Retrieve open/pending bets
- **GET** `/4093/settled-bets` - Retrieve settled bets with optional betStatus filtering (WON, LOST, CASHED_OUT)
- **GET** `/4093/cashout-amount` - Calculate current cashout value for a bet
- **POST** `/4093/cashout` - Execute full or partial cashout

**Authentication Headers**:
- `X-session-id`: User session token
- `X-operator-id`: Operator ID (4093)
- `X-user-id`: User ID
- `X-language`: Language preference

### Data Models Created
**EveryMatrix Namespace Models**:
- `EveryMatrix.Bet` - Complete bet information with selections, amounts, status
- `EveryMatrix.BetSelection` - Individual bet selection with match/market details
- `EveryMatrix.CashoutRequest` - Request payload for cashout execution
- `EveryMatrix.CashoutResponse` - Cashout amount calculation response
- `EveryMatrix.CashoutExecuteResponse` - Cashout execution result

### Next Steps
1. Update MyBetsViewModel to replace mock data with real ServicesProvider API calls
2. Implement bet list UI using appropriate GomaUI components (BetDetailRowView, BetTicketStatusView, etc.)
3. Add proper loading states and error handling in MyBets UI
4. Test complete MyBets functionality in simulator with real API data
5. Consider implementing real-time bet status updates via WebSocket connections

### Status
✅ **API Implementation Complete** - Ready for UI integration
📋 **Next Phase** - MyBetsViewModel integration and GomaUI component implementation