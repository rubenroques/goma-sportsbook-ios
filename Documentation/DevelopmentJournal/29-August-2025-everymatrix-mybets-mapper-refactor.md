## Date
29 August 2025

### Project / Branch
sportsbook-ios / rr/mybets_profile_features

### Goals for this session
- Fix EveryMatrix MyBets API integration showing empty selections
- Refactor mapping to follow established ModelMapper pattern
- Update models to match actual API response structure
- Fix SportType mapping to use proper IDs for icons

### Achievements
- [x] Identified field name mismatch between EveryMatrix API response and models
- [x] Created EveryMatrixModelMapper+MyBets.swift following existing pattern
- [x] Removed backward compatibility computed properties from models
- [x] Updated EveryMatrix.Bet and EveryMatrix.BetSelection models to match actual API fields
- [x] Fixed SportType mapping to use sportId for proper icon display
- [x] Verified status mapping matches actual API values (WON, LOST, OPEN)
- [x] Successfully displaying bet selections in MyBets screen with TicketBetInfoView

### Issues / Bugs Hit
- [x] TicketSelectionView items not appearing - EveryMatrix API field names didn't match model
- [x] SportType icons broken - was creating SportType with only name, needed ID
- [x] Status mapping incorrect - "IN_PROGRESS" doesn't exist in API

### Key Decisions
- Followed established EveryMatrixModelMapper pattern instead of custom mapping functions
- Added SportType(id:name:) helper initializer for proper icon mapping
- Removed all backward compatibility computed properties - clean API field mapping
- Used cURL to verify actual API response structure before updating models

### Experiments & Notes
- cURL requests revealed completely different field names:
  - API: `homeParticipantName`, `eventName`, `priceValue`, `betName`
  - Model expected: `homeTeam`, `matchName`, `odds`, `selection`
- EveryMatrix uses numeric sport IDs that map to SportTypeInfo enum
- Status values from API: "WON", "LOST", "OPEN" (not "IN_PROGRESS")

### Useful Files / Links
- [EveryMatrixModelMapper+MyBets]( Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Mappers/EveryMatrixModelMapper+MyBets.swift )
- [EveryMatrix MyBets Models]( Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Shared/EveryMatrix+MyBets.swift )
- [SportType Model]( Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Events/SportType.swift )
- [TicketBetInfoView]( Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TicketBetInfoView/TicketBetInfoView.swift )
- [MyBetsViewController]( BetssonCameroonApp/App/Screens/MyBets/MyBetsViewController.swift )

### Next Steps
1. Test with more bet types (multiple selections, system bets)
2. Verify cash out functionality mapping
3. Add proper error handling for missing/null fields
4. Consider adding unit tests for the mapper functions