## Date
28 August 2025

### Project / Branch
sportsbook-ios / rr/mybets_profile_features

### Goals for this session
- Fix 403 Forbidden error in MyBets API requests
- Compare headers between working web client and failing iOS app
- Implement missing authentication headers

### Achievements
- [x] Identified root cause: Missing `X-User-Id` header in app requests
- [x] Analyzed header differences between app and web client
- [x] Discovered header key inconsistency across different EveryMatrix endpoints
- [x] Implemented flexible enum-based solution for endpoint-specific auth headers
- [x] Added `AuthHeaderType` enum to Endpoint protocol
- [x] Updated EveryMatrixOddsMatrixAPI to specify correct header keys per endpoint
- [x] Modified EveryMatrixOddsMatrixAPIConnector to dynamically build auth headers

### Issues / Bugs Hit
- [x] 403 Forbidden on MyBets API calls - app missing `x-user-id` header
- [x] Header key inconsistency: PlaceBet uses `x-sessionid`, MyBets uses `x-session-id`
- [x] App was only sending session token, not user ID for authenticated requests

### Key Decisions
- **Enum-based header solution**: Created `AuthHeaderType` enum (.sessionId, .userId) instead of hardcoded headers
- **Endpoint-specific keys**: Each endpoint can specify its exact header key format via `authHeaderKey(for:)` method
- **Dynamic header building**: Connector builds auth headers based on what each endpoint actually needs

### Experiments & Notes
- Web client working headers: `x-language`, `x-operator-id`, `x-session-id`, `x-user-id`
- App was missing `x-user-id` completely
- PlaceBet API uses `x-sessionid` (no hyphen), MyBets APIs use `x-session-id` (with hyphen)
- User ID already stored in session coordinator during login, just needed to pass it to connector

### Useful Files / Links
- [EveryMatrixOddsMatrixAPIConnector](../../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/OddsMatrixAPI/EveryMatrixOddsMatrixAPIConnector.swift) - Auth header logic
- [EveryMatrixOddsMatrixAPI](../../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/OddsMatrixAPI/EveryMatrixOddsMatrixAPI.swift) - Endpoint header specifications
- [Endpoint Protocol](../../../Frameworks/ServicesProvider/Sources/ServicesProvider/Network/Endpoint.swift) - New AuthHeaderType enum
- [EveryMatrixBettingProvider](../../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixBettingProvider.swift) - User ID subscription
- [MyBetsViewModel](../../../BetssonCameroonApp/App/Screens/MyBets/MyBetsViewModel.swift) - Consumer of fixed API

### Next Steps
1. Test the fix by running the app and verifying MyBets loads successfully
2. Verify both PlaceBet and MyBets APIs work with their respective header formats
3. Remove debug logging once confirmed working in production