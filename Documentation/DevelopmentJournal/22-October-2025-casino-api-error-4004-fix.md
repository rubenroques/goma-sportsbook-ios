# Casino API Error 4004 (InvalidXSessionId) Fix

## Date
22 October 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Investigate and fix Casino API returning error 4004 (InvalidXSessionId) causing app crashes
- Understand why automatic token refresh wasn't triggering
- Implement proper error handling for Casino API's unique HTTP 200 + error body pattern

### Achievements
- [x] Identified root cause: Casino API returns HTTP 200 with error details in body (not 401/403 status codes)
- [x] Created lightweight error detection model `EveryMatrix.CasinoAPIErrorCheck`
- [x] Implemented pre-parse error detection in `EveryMatrixCasinoConnector.request<T>()`
- [x] Added automatic token refresh for error code 4004 at connector layer
- [x] Fixed compilation errors from making DTO fields optional
- [x] Cleaned up provider methods back to simple `.map` transformations
- [x] Solution now handles all Casino API errors (4004 and others) centrally

### Issues / Bugs Hit
- [x] Initial approach tried to handle errors at provider level - wrong architectural layer
- [x] BaseConnector's `.tryCatch` only catches HTTP-level errors, not post-decode errors
- [x] Making `items` optional in DTOs broke mapper and provider code (fixed with `?? []`)

### Key Decisions
- **Connector-level error detection**: Added pre-parse logic in `EveryMatrixCasinoConnector` before full decoding
  - Casino API is unique: returns HTTP 200 with `{"success": false, "errorCode": 4004}` instead of 401/403
  - Other EveryMatrix APIs (Player, OddsMatrix, Recsys) return proper HTTP status codes
- **Keep DTO error fields**: Made `items` optional and added `success`, `errorCode`, `errorMessage` fields
  - Defensive programming: provides safety net if pre-parse fails
  - Allows graceful degradation
- **Centralized solution**: One place handles all Casino endpoints automatically
  - No changes needed in provider methods
  - Future Casino endpoints get error handling for free

### Architecture Flow

```
User Action → Provider Method
    ↓
Connector.request<T>() makes HTTP request
    ↓
Returns HTTP 200 with raw Data
    ↓
✨ PRE-PARSE CHECK ✨ (NEW!)
Try decode: EveryMatrix.CasinoAPIErrorCheck
    ↓
If success == false && errorCode == 4004:
    throw ServiceProviderError.unauthorized
    ↓
.tryCatch catches .unauthorized
    ↓
Force token refresh via sessionCoordinator
    ↓
Retry entire request with new token
    ↓
Success → Full decode T.self → Return to provider
```

### Experiments & Notes
- **Approach 1 (rejected)**: Detect error in BaseConnector raw data - too complex, double JSON parsing
- **Approach 2 (chosen)**: Lightweight pre-parse in CasinoConnector before full decode
  - Clean separation: connector handles errors, provider handles data transformation
  - Reuses existing `.tryCatch` retry mechanism
  - Casino-specific logic isolated to CasinoConnector

### Useful Files / Links
- [EveryMatrixCasinoConnector](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CasinoAPI/EveryMatrixCasinoConnector.swift) - Pre-parse logic added at line 124-139
- [EveryMatrix+CasinoAPIErrorCheck](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Shared/EveryMatrix+CasinoAPIErrorCheck.swift) - New error detection model
- [CasinoGameDTO](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/DataTransferObjects/Casino/CasinoGameDTO.swift) - Updated DTOs with optional items
- [EveryMatrixCasinoProvider](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixCasinoProvider.swift) - Simplified provider methods
- [EveryMatrixModelMapper+Casino](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Mappers/EveryMatrixModelMapper+Casino.swift) - Fixed mapper for optional items

### Files Modified
1. **New File**: `EveryMatrix+CasinoAPIErrorCheck.swift` - Lightweight error detection struct
2. **EveryMatrixCasinoConnector.swift** - Added pre-parse logic (lines 124-139)
3. **CasinoGameDTO.swift** - Made `items` optional, added error fields to `CasinoGamesResponseDTO`
4. **CasinoCategoryDTO.swift** - Made group fields optional, added error fields to `CasinoGroupResponseDTO`
5. **EveryMatrixModelMapper+Casino.swift** - Handle optional items with `?? []`
6. **EveryMatrixCasinoProvider.swift** - Reverted to simple `.map`, removed error checking
7. **EveryMatrixPrivilegedAccessManager.swift** - Handle optional items in recently played

### Next Steps
1. Test the fix with real session expiration scenarios
2. Monitor logs for successful token refresh on 4004 errors
3. Consider adding similar pre-parse for other potential Casino API error codes
4. Document the Casino API's unique error handling pattern in CLAUDE.md
