## Date
24 November 2025

### Project / Branch
sportsbook-ios / rr/match_details_score

### Goals for this session
- Fix basketball quarters displaying in wrong order (Q3, Q1, Q2 instead of Q1, Q2, Q3)
- Root cause the ordering issue and implement proper solution
- Ensure fix works across all projects and providers

### Achievements
- [x] Identified root cause: All quarters had same `sortValue = 100`, causing unpredictable dictionary iteration order
- [x] Implemented architectural solution: Added `index` parameter to `Score.gamePart` enum case
- [x] Updated ServicesProvider core Score model (shared by all providers)
- [x] Updated BetssonCameroonApp Score model
- [x] Updated BetssonFranceApp Score model
- [x] Updated EveryMatrix EventLiveDataBuilder to pass quarter/period/inning indices
- [x] Updated Goma provider to pass nil index for tennis game parts
- [x] Updated SportRadar provider Score model and mapper
- [x] Updated all ServiceProviderModelMapper files in both projects
- [x] Updated all pattern matching usages in ViewModels and Views
- [x] Updated preview/mock data files

### Issues / Bugs Hit
- Initial symptoms: Basketball quarters rendered as Q3, Q1, Q2, Q4 instead of Q1, Q2, Q3, Q4
- Log evidence: `[LIVE_SCORE] 🔄 Transforming 4 detailed scores` showed incorrect order
- Dictionary iteration order is non-deterministic when all items have same sort value

### Key Decisions
- **Chose Option 2**: Add index to gamePart enum case (matching `.set(index:)` pattern)
- **Why**: Architecturally consistent, type-safe, future-proof for all period-based sports
- **Rejected Option 1**: String parsing of dictionary keys (fragile, not type-safe)
- **Rejected Option 3**: Custom sorting logic with string parsing (less clean)
- Made index optional (`Int?`) to support sports without natural ordering (tennis game points)
- Used `index ?? 100` as fallback sortValue for backwards compatibility

### Experiments & Notes
- Quarter index is extracted at EventLiveDataBuilder from EventInfo eventPartName
- Pattern: "1st Quarter" → extracts 1 → stored as `.gamePart(index: 1, home: 24, away: 20)`
- Sets already used indexed enum: `.set(index: Int, home: Int?, away: Int?)` - quarters now follow same pattern
- Hockey periods and baseball innings also benefit from this fix automatically

### Useful Files / Links
- [Score.swift (ServicesProvider)](Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Events/Core/Score.swift) - Core model shared by all providers
- [Score.swift (BetssonCameroonApp)](BetssonCameroonApp/App/Models/Events/Score.swift) - App-specific model
- [Score.swift (BetssonFranceApp)](BetssonFranceApp/Core/Models/App/Scores.swift) - Legacy app model
- [EventLiveDataBuilder.swift](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/EventLiveDataBuilder.swift:251-270) - Where indices are assigned
- [ScoreViewModel.swift](BetssonCameroonApp/App/ViewModels/TallOddsMatchCard/ScoreViewModel.swift:169-227) - Where sorting happens
- [SportRadarModels+Scores.swift](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/SportRadarModels+Scores.swift) - SportRadar provider Score
- [ServiceProviderModelMapper+Scores.swift](BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+Scores.swift) - Provider-to-App mapping

### Architecture Notes

#### 4-Layer Score Transformation (EveryMatrix Provider)
```
WebSocket EventInfo (flat, normalized)
    ↓
EventLiveDataBuilder.processSimpleScore()
    ↓
Match.detailedScores: [String: ServicesProvider.Score]
    ↓
ServiceProviderModelMapper.score()
    ↓
App Score model → ScoreViewModel → UI
```

#### Key Implementation Details
- **Quarters**: "Q1", "Q2", "Q3", "Q4" with indices 1, 2, 3, 4
- **Periods**: "P1", "P2", "P3" with indices 1, 2, 3 (hockey, floorball)
- **Innings**: Keep full name but store index (baseball, cricket)
- **Sets**: Already used `.set(index:)` - no changes needed
- **Tennis Games**: Use nil index (no natural ordering for 0/15/30/40/Advantage)

#### Files Modified (13 files)
1. **Core Models (3)**:
   - ServicesProvider/Score.swift
   - BetssonCameroonApp/Score.swift
   - BetssonFranceApp/Scores.swift

2. **Provider Layer (4)**:
   - EventLiveDataBuilder.swift (EveryMatrix - quarters, periods, innings, tennis game)
   - GomaModels+Events.swift (Goma - tennis game)
   - SportRadarModels+Scores.swift (SportRadar model)
   - SportRadarModelMapper+Events.swift (SportRadar mapper)

3. **App Layer (6)**:
   - ServiceProviderModelMapper+Scores.swift (BetssonCameroonApp)
   - ServiceProviderModelMapper+Scores.swift (BetssonFranceApp)
   - ScoreViewModel.swift (pattern matching)
   - ScoreView.swift (pattern matching)
   - PreviewModelsHelper.swift (BetssonCameroonApp - mock data)
   - PreviewModelsHelper.swift (BetssonFranceApp - mock data)
   - VerticalMatchInfoView.swift (preview code)

### Next Steps
1. Build and test with live basketball match to verify quarters display Q1, Q2, Q3, Q4 in correct order
2. Test with hockey match to verify periods display P1, P2, P3 correctly
3. Verify tennis matches still work correctly with nil index
4. Consider adding debug logging to show sortValue during transformation
5. Monitor live score logs for `[LIVE_SCORE] 🔄 Transforming` messages to confirm ordering

### Testing Strategy
- Look for basketball matches with multiple completed quarters
- Expected log output should show:
  ```
  [LIVE_SCORE]    - GamePart 'Q1': 24 - 20
  [LIVE_SCORE]    - GamePart 'Q2': 19 - 24
  [LIVE_SCORE]    - GamePart 'Q3': 21 - 13
  [LIVE_SCORE]    - GamePart 'Q4': 3 - 0
  ```
- UI should render quarters in order with correct scores
