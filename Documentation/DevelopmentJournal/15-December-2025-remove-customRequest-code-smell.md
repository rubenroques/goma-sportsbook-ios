## Date
15 December 2025

### Project / Branch
sportsbook-ios / main

### Goals for this session
- Investigate and fix `customRequest` code smell in `SportRadarManagedContentProvider`
- Remove leaky abstraction bypassing `EventsProvider` protocol

### Achievements
- [x] Identified root cause: domain `SportCompetitionInfo` was missing `parentId` field
- [x] Added `parentId: String?` to domain model `SportCompetitionInfo`
- [x] Updated `SportRadarModelMapper.sportCompetitionInfo()` to map `parentId`
- [x] Updated `GomaProvider.getCompetitionMarketGroups()` to pass `nil` for `parentId`
- [x] Refactored `SportRadarManagedContentProvider.getTopCompetitions()` to use protocol method
- [x] Removed `customRequest<T>()` escape hatch from `SportRadarEventsProvider`
- [x] Verified build succeeds for "Betsson PROD" scheme

### Issues / Bugs Hit
- [ ] "BetssonCM Prod" has pre-existing linker error: `framework 'PhraseSDK' not found` (unrelated to this work)

### Key Decisions
- **Added `parentId` to domain model** rather than keeping internal model leakage - this is the proper 3-layer architecture fix
- **Kept `getTopCompetitionCountry()` on concrete type** - it's SportRadar-specific and only used internally by `SportRadarManagedContentProvider`, so protocol exposure isn't needed
- **Used `Optional($0)` mapping** in catch block to maintain error swallowing behavior (competitions that fail to load are simply excluded)

### Experiments & Notes
The code smell pattern was:
```swift
// BEFORE - bypassed protocol, leaked internal models
let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.SportCompetitionInfo>, ServiceProviderError> =
    self.eventsProvider.customRequest(endpoint: endpoint)

// AFTER - uses protocol method, works with domain models
return self.eventsProvider.getCompetitionMarketGroups(competitionId: competitionId)
    .map { Optional($0) }
```

The root cause was that the mapper was **dropping** `parentId` during internal-to-domain conversion because the domain model didn't have that field.

### Useful Files / Links
- [SportCompetitionInfo (domain)](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Events/Sports/SportCompetitionInfo.swift)
- [SportRadarModelMapper+Sports](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Mapper/SportRadarModelMapper+Sports.swift)
- [SportRadarManagedContentProvider](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/SportRadarManagedContentProvider.swift)
- [SportRadarEventsProvider](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/SportRadarEventsProvider.swift)
- [GomaProvider](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Goma/GomaProvider.swift)

### Next Steps
1. Test `getTopCompetitions()` functionality on SportRadar target to verify runtime behavior
2. Consider if `getTopCompetitionCountry()` should eventually move to protocol (low priority)
3. Fix PhraseSDK linker issue in BetssonCM targets (separate issue)
