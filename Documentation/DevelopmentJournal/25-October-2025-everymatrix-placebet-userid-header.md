## Date
25 October 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Add new `userid` header to EveryMatrix place bet API endpoint

### Achievements
- [x] Added `userid` header support to place bet endpoint in EveryMatrixOddsMatrixWebAPI.swift:153

### Issues / Bugs Hit
- None encountered

### Key Decisions
- **Header name**: Confirmed with user to use `"userid"` (lowercase, no prefix) matching the pattern used in the new cashout API (executeCashoutV2 and getCashoutValueSSE)
- **Implementation approach**: Leveraged existing `authHeaderKey(for:)` infrastructure - no changes needed to connector logic
- **Minimal change**: Only modified the return value for `.userId` case in `.placeBet` endpoint from `nil` to `"userid"`

### Experiments & Notes
- Investigation revealed the architecture already handles userId headers through `AuthHeaderType` enum and `EveryMatrixRESTConnector`
- The connector automatically adds authentication headers (lines 169-187 in EveryMatrixRESTConnector.swift)
- User ID value comes from `EveryMatrixSessionResponse.userId` which is already tracked from login
- Different EveryMatrix APIs use different header naming conventions:
  - Place bet: `x-sessionid` + `userid`
  - MyBets APIs: `x-session-id` + `x-user-id`
  - Cashout APIs: `X-SessionId` + `userid`

### Useful Files / Links
- [EveryMatrixOddsMatrixWebAPI.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixWebAPI/EveryMatrixOddsMatrixWebAPI.swift) - Endpoint definitions
- [EveryMatrixRESTConnector.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Connectors/EveryMatrixRESTConnector.swift) - Authentication header handling
- [Endpoint.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Network/Endpoint.swift) - AuthHeaderType protocol
- [EveryMatrix Provider CLAUDE.md](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CLAUDE.md) - Provider architecture documentation

### Next Steps
1. Test place bet functionality with the new userid header in staging/development environment
2. Verify the header is correctly included in API requests via logging or network inspection
3. Monitor for any API errors related to missing or incorrect userid header format
