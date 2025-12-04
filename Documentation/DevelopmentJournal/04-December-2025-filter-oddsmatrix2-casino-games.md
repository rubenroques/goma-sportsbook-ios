# Development Journal

## Date
04 December 2025

### Project / Branch
BetssonCameroonApp / rr/feature/lang-switcher

### Goals for this session
- Filter out casino games with vendor "OddsMatrix2" from casino listings
- Fix SPOR-6733 / BC-346: "Recently Played" showing Sports Betting as an available game

### Achievements
- [x] Identified that "OddsMatrix2" games are sportsbook entries appearing in casino API responses
- [x] Discovered the `subVendor` field contains "OddsMatrix2" for sportsbook games via API investigation
- [x] Added `isSportsbookGame()` helper in `EveryMatrixModelMapper+Casino.swift`
- [x] Updated `casinoGames()` mapper to filter out OddsMatrix2 games
- [x] Updated `casinoRecentlyPlayed()` mapper to filter out OddsMatrix2 games
- [x] Added changelog entry for SPOR-6733

### Issues / Bugs Hit
- None - straightforward implementation once the API response structure was understood

### Key Decisions
- **Filter at mapper level**: Implemented filtering in `EveryMatrixModelMapper+Casino.swift` rather than at provider or UI level - this is "as close to the parsing as possible" while still being in the EM→SP model transformation layer
- **Use `subVendor` field**: The API response shows `subVendor: "OddsMatrix2"` is the reliable identifier for sportsbook games (also present in `vendor.name` and `gameCode`)
- **Private constant**: Created `sportsbookVendorIdentifier = "OddsMatrix2"` for maintainability

### Experiments & Notes
- API investigation via curl to production (`betsson.nwacdn.com`) revealed the full structure:
  - `gameCode: "OddsMatrix2"`
  - `gameId: "OddsMatrix2"`
  - `subVendor: "OddsMatrix2"`
  - `vendor.name: "OddsMatrix2"`
  - Game name is "Sports Betting" and appears in "OTHERGAMES" category

### Useful Files / Links
- [EveryMatrixModelMapper+Casino.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/ModelMappers/EveryMatrixModelMapper+Casino.swift) - Main file modified
- [EveryMatrix+CasinoGame.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/REST/Casino/EveryMatrix+CasinoGame.swift) - EM internal model with `subVendor` field
- [GameTransactionType.swift](../../BetssonCameroonApp/App/Screens/TransactionHistory/GameTransactionType.swift) - Reference for how OddsMatrix2 is used in transaction filtering

### Next Steps
1. Test in simulator to verify sportsbook games no longer appear in casino sections
2. Verify recently played and regular casino listings both filter correctly
