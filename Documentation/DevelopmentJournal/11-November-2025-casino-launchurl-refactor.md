## Date
11 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Investigate casino game launch URL handling
- Fix URL construction to use API-provided launchUrl
- Replace unsafe string concatenation with URLComponents

### Achievements
- [x] Identified that iOS was ignoring `launchUrl` from API and rebuilding URLs from scratch
- [x] Refactored `EveryMatrixCasinoProvider.buildGameLaunchUrl()` to use API-provided URL
- [x] Replaced manual string concatenation with URLComponents for proper URL encoding
- [x] Preserved backward compatibility (same method signature, no breaking changes)

### Issues / Bugs Hit
- **Issue**: iOS was rebuilding casino game URLs instead of using the `launchUrl` field from API
  - **Root Cause**: Method was using `gameLaunchBaseURL + operatorId + game.slug` pattern
  - **Impact**: API-side URL changes were not respected, special characters weren't encoded
- **Fix Applied**: Now starts with `game.launchUrl` and merges query parameters using URLComponents

### Key Decisions
- **Use URLComponents instead of string concatenation**: Proper RFC 3986 URL encoding for special characters
- **Preserve existing query parameters**: Merge instead of replace (supports API-provided params)
- **Maintain logging**: Kept debug print statements for troubleshooting game launches
- **No breaking changes**: Method signature unchanged, callers work without modification

### Code Changes

**File**: `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixCasinoProvider.swift:192-254`

**Before**:
```swift
// Rebuilt URL from scratch, ignoring game.launchUrl
var urlString = "\(gameLaunchBaseURL)/Loader/Start/\(operatorId)/\(game.slug)"
var queryParams: [String] = []
queryParams.append("language=\(finalLanguage)")
// Manual string concatenation - no URL encoding
urlString += "?" + queryParams.joined(separator: "&")
```

**After**:
```swift
// Start with API-provided launchUrl
guard var urlComponents = URLComponents(string: game.launchUrl) else {
    return nil
}

// Build query items with proper encoding
var queryItems: [URLQueryItem] = []
queryItems.append(URLQueryItem(name: "language", value: finalLanguage))

// Merge with existing params from API
var allQueryItems = urlComponents.queryItems ?? []
allQueryItems.append(contentsOf: queryItems)
urlComponents.queryItems = allQueryItems

return urlComponents.url?.absoluteString
```

### Technical Details

**Query Parameters by Mode**:
- `funGuest`: `language` only
- `funLoggedIn`: `language`, `funMode=True`, `_sid={sessionId}`
- `realMoney`: `language`, `_sid={sessionId}`

**URLComponents Benefits**:
- Automatic percent-encoding of special characters (spaces → %20, & → %26, etc.)
- Preserves existing query parameters from API
- RFC 3986 compliant URL construction
- More maintainable than string manipulation

**Edge Cases Handled**:
- Invalid `launchUrl` from API → returns nil with error log
- Missing session token in authenticated modes → returns nil with error log
- Pre-existing query parameters → preserved and merged

### Useful Files / Links
- [EveryMatrixCasinoProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixCasinoProvider.swift)
- [CasinoGame.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Casino/CasinoGame.swift) - Domain model with launchUrl field
- [CasinoGamePlayViewModel.swift](../../BetssonCameroonApp/App/Screens/Casino/CasinoGamePlay/CasinoGamePlayViewModel.swift) - Caller of buildGameLaunchUrl
- [EveryMatrix Provider CLAUDE.md](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CLAUDE.md) - Architecture documentation

### Next Steps
1. Manual testing in BetssonCameroonApp casino flow (guest mode, fun mode, real money)
2. Verify URL encoding works with games that have special characters
3. Monitor logs to confirm proper URL construction in all three modes
4. Consider adding unit tests for buildGameLaunchUrl edge cases (future enhancement)
