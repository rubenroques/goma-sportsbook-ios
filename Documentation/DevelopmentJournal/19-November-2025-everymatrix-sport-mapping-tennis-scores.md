## Date
19 November 2025

### Project / Branch
sportsbook-ios / rr/match_details_score

### Goals for this session
- Fix EveryMatrix sport ID mapping issue (all sports showing Sport.id='0')
- Fix tennis score layout to display correct column order: [Serve] [GamePart] | [Set1] [Set2] [Set3]

### Achievements
- [x] Fixed EveryMatrix sport ID mapping in MatchBuilder with inline data fallback
- [x] Fixed tennis score layout - game parts now render FIRST before sets for Type C sports
- [x] Improved fallback in EveryMatrixModelMapper with proper default sport IDs
- [x] Analyzed ScoreView component architecture and preview patterns
- [x] Used cWAMP tool to inspect real EveryMatrix match JSON structure

### Issues / Bugs Hit
- [x] EveryMatrix SportDTO not in EntityStore → sport was nil → fallback created SportType with all nil IDs → App Sport.id defaulted to '0'
- [x] Tennis scores showing sets before game parts due to sortValue-only ordering
- [x] All tennis matches displayed as "Sport.id='0', Sport.name='FBL'" regardless of actual sport

### Key Decisions
- **MatchBuilder inline fallback pattern**: Copied the exact pattern used for venue (lines 24-38) to create Sport from inline MatchDTO data when SportDTO isn't in EntityStore
- **Type C sport detection**: Maintained existing sportId list ["3", "20", "64", "63", "14"] for tennis/volleyball/etc.
- **Layout separation for Type C**: Separate game parts from sets, process game parts first with `showsTrailingSeparator: true` and serving indicator
- **Non-Type C preservation**: Keep original ordering logic for other sports (basketball, football, etc.) to avoid regression

### Experiments & Notes
- Investigated 4-layer EveryMatrix WebSocket transformation: DTO → Builder → Hierarchical Internal → Mapper → Domain
- MatchDTO contains inline sport data: `sportId`, `sportName`, `shortSportName` (verified via cWAMP)
- EveryMatrix sends normalized data - entities reference each other by ID, requiring EntityStore lookups
- ScoreView uses `ServingIndicatorView` (separate column) + vertical separator + score cells
- Tennis preview shows correct layout: [●] [40/15] | [6/4] [4/6] [3/2]

### Useful Files / Links
- [MatchBuilder.swift](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/Builders/MatchBuilder.swift) - Lines 21-42: Inline sport fallback
- [EveryMatrixModelMapper+Events.swift](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/ModelMappers/EveryMatrixModelMapper+Events.swift) - Lines 32-54: Sport mapping with improved fallback
- [TallOddsMatchCardViewModel.swift](BetssonCameroonApp/App/ViewModels/TallOddsMatchCard/TallOddsMatchCardViewModel.swift) - Lines 361-508: Score transformation with Type C layout
- [ScoreView.swift](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ScoreView/ScoreView.swift) - Lines 160-183: Serving indicator and separator rendering
- [ScoreViewModelProtocol.swift](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ScoreView/ScoreViewModelProtocol.swift) - Lines 7-48: ScoreDisplayData structure
- [MatchDTO.swift](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/WebSocket/DTOs/MatchDTO.swift) - Lines 15, 27-28: Inline sport fields
- [cWAMP Tool](Tools/wamp-client/) - Used to fetch real EveryMatrix match JSON

### Architecture Insights
**EveryMatrix Data Flow (WebSocket)**:
1. **MatchDTO** (Flat normalized) - Has inline `sportId`, `sportName`, `shortSportName` + references Sport by ID
2. **MatchBuilder** - Attempts EntityStore lookup for SportDTO, now falls back to inline data if missing
3. **Match** (Hierarchical) - Contains complete Sport object with all properties
4. **EveryMatrixModelMapper** - Transforms internal Match to ServicesProvider Event with SportType
5. **ServiceProviderModelMapper** - Maps SportType to App Sport model

**Problem**: SportDTO wasn't always in EntityStore → nil Sport → fallback created incomplete SportType → App got Sport.id='0'

**Solution**: Create Sport from inline MatchDTO data (mirroring venue pattern) when EntityStore lookup fails

### Next Steps
1. Test with live EveryMatrix data to verify sport IDs are now correct (Football=1, Tennis=3, etc.)
2. Verify tennis matches show proper score layout with serving indicator in live matches
3. Monitor logs for `[SPORT_DEBUG]` and `[LIVE_SCORE]` entries to confirm sport ID flow
4. Check if other sports (volleyball, badminton) also display correct layouts with new Type C logic
5. Consider removing debug print statements once verified in production
6. Validate that non-tennis sports (basketball, football) still show correct score layouts
