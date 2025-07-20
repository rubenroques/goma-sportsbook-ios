## Date
19 July 2025

### Project / Branch
sportsbook-ios / ServicesProvider EveryMatrix improvements - Session 2

### Goals for this session
- Fix outcome ordering inversion in MarketOutcomesLineViewModel
- Investigate and fix market ordering conflicts in EveryMatrix mapper
- Add paramFloat1 support for outcome sorting (race_to_x patterns)
- Remove double-sorting issues causing data inversions

### Achievements
- [x] **Fixed Outcome Ordering Inversion**: Identified and resolved double-sorting in MarketOutcomesLineViewModel
  - [x] Root cause: String-based sorting in view model conflicted with numerical EveryMatrix mapper sorting
  - [x] Solution: Removed redundant sorting logic, use outcomes as-is from correctly sorted EveryMatrix data
- [x] **Fixed Market Ordering Conflicts**: Removed string-based market ID sorting in EveryMatrix mapper  
  - [x] Identified line 50 in EveryMatrixModelMapper+Events.swift overriding MatchBuilder numerical sorting
  - [x] Removed `markets = markets.sorted { $0.id < $1.id }` to preserve MatchBuilder parameter-based ordering
- [x] **Added paramFloat1 Support**: Complete implementation for parameter-based outcome sorting
  - [x] Added `paramFloat1: Double?` to main ServicesProvider.Outcome model (Events.swift)
  - [x] Updated all Codable/Equatable/Hashable conformances
  - [x] Added `paramFloat1: Double?` to EveryMatrix composed Outcome model
  - [x] Updated OutcomeBuilder to map paramFloat1 from DTO to composed model
  - [x] Enhanced EveryMatrixModelMapper.outcome() to pass paramFloat1 to external model
- [x] **Enhanced Sorting Algorithm**: Smart paramFloat1-based sorting for "race_to_x" patterns
  - [x] Updated `sortValue(forOutcomeHeaderKey:paramFloat1:)` method signature
  - [x] Added paramFloat1 fallback logic in default case: `1000 + Int(paramValue * 10)`
  - [x] Updated all call sites to pass paramFloat1 values (mapper and MarketBuilder)

### Issues / Bugs Hit
- [x] ~~Initially missed that ServicesProvider.Outcome model lacked paramFloat1 support~~
- [x] ~~Found that MarketBuilder wasn't updated to use new paramFloat1 parameter in sorting calls~~

### Key Decisions
- **Remove vs Fix**: Decided to remove conflicting sorting rather than add complex logic
- **paramFloat1 Base Value**: Used 1000 as base for paramFloat sorting to ensure it sorts after standard patterns
- **Multiplication Factor**: Used x10 for paramFloat values to handle decimal precision (1.5 -> 1015)
- **Graceful Degradation**: Enhanced methods maintain backward compatibility when paramFloat1 is nil

### Experiments & Notes
- Double-sorting pattern found in both outcome and market ordering chains
- View model sorting with string comparison conflicted with mapper's numerical sorting
- paramFloat1 enables proper sorting for dynamic betting patterns like "Race to X Goals"
- MarketBuilder automatically updated by linter to use new paramFloat1 parameter correctly

### Useful Files / Links
- [EveryMatrixModelMapper+Events](../../../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Mappers/EveryMatrixModelMapper+Events.swift) - Core sorting logic
- [Events.swift](../../../ServicesProvider/Sources/ServicesProvider/Models/Events/Events.swift) - Main Outcome model
- [MarketOutcomesLineViewModel](../../../Core/ViewModels/TallOddsMatchCard/MarketOutcomesLineViewModel.swift) - Fixed double-sorting issue
- [EveryMatrix Outcome](../../../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Composed/Outcome.swift) - Added paramFloat1
- [OutcomeBuilder](../../../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Builders/OutcomeBuilder.swift) - paramFloat1 mapping
- [MarketBuilder](../../../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Builders/MarketBuilder.swift) - Updated sorting calls

### Next Steps
1. Test outcome ordering with real "race_to_x" market data
2. Verify market ordering preserves MatchBuilder's numerical parameter sorting
3. Test edge cases where paramFloat1 is nil or zero
4. Consider adding paramFloat2/paramFloat3 support for outcomes if needed
5. Monitor for any regression in standard outcome ordering patterns