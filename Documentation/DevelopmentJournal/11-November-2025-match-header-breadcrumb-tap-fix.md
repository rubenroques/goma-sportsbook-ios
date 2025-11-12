## Date
11 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Fix match header breadcrumb format from "Sport / Competition / League" to "Sport / Country / League"
- Make Country and League tappable with underlines
- Wire up callbacks to pass country ID and league ID to parent screen

### Achievements
- [x] Updated MatchHeaderCompactData struct to include `country` and `countryId` fields
- [x] Added `onCountryTapped` and `onLeagueTapped` callbacks to MatchHeaderCompactViewModelProtocol
- [x] Implemented production ViewModel with country extraction from `match.venue`
- [x] Updated all mock ViewModels with new protocol requirements
- [x] Changed breadcrumb format in MatchHeaderCompactView from "Sport / Competition / League" to "Sport / Country / League"
- [x] Implemented tap detection using NSLayoutManager for precise character-level tap detection
- [x] Wired up callbacks in MatchDetailsTextualViewModel
- [x] **Fixed critical bug**: LocationDTO not in EntityStore - added fallback to use embedded venue data from MatchDTO

### Issues / Bugs Hit
- [x] **Bad code pattern detected**: Initial tap handler created new Combine subscription on every tap - Fixed by caching data in `updateUI`
- [x] **Data loss in mapping chain**: `match.venue` was nil because LocationDTO not stored in EntityStore
  - Root cause: EveryMatrix WebSocket doesn't send LocationDTO separately
  - MatchDTO contains embedded venue data (`venueId`, `venueName`, `shortVenueName`)
  - MatchBuilder tried to lookup LocationDTO in EntityStore and failed
  - Solution: Added fallback logic to create Location directly from MatchDTO fields

### Key Decisions
- **Breadcrumb implementation**: Chose attributed string with NSLayoutManager tap detection over UIStackView
  - Reason: UIStackView doesn't wrap to multiple lines (would truncate instead)
  - Maintains proper text wrapping with `numberOfLines = 0`
- **Data caching approach**: Cache `MatchHeaderCompactData` during `updateUI` instead of subscribing to publisher on tap
  - Avoids reactive overhead on every user interaction
  - Data stays synchronized with UI updates
  - Pragmatic solution balancing code smell vs. maintainability
- **Fallback pattern in MatchBuilder**: Prefer EntityStore lookup, fallback to embedded DTO data
  - Makes MatchBuilder resilient to WebSocket data variations
  - Follows EveryMatrix architecture where some entities are embedded vs. normalized

### Experiments & Notes
- Initial attempt used `.first()` publisher subscription in tap handler - quickly identified as anti-pattern
- Debugged full data flow from WebSocket → EntityStore → MatchBuilder → ViewModel → View using `[BreadcrumbDebug]` prefix
- Traced through 4-layer transformation: DTO → Builder → Hierarchical Internal → Mapper → Domain Model
- Discovered MatchDTO has venue data but MatchBuilder couldn't access it due to missing LocationDTO in store

### Useful Files / Links
- [MatchHeaderCompactView](../../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchHeaderCompactView/MatchHeaderCompactView.swift) - UIKit view with tap detection
- [MatchHeaderCompactViewModelProtocol](../../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchHeaderCompactView/MatchHeaderCompactViewModelProtocol.swift) - Protocol with callbacks
- [MatchHeaderCompactViewModel](../../../BetssonCameroonApp/App/ViewModels/MatchHeaderCompact/MatchHeaderCompactViewModel.swift) - Production implementation
- [MatchBuilder](../../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/Builders/MatchBuilder.swift) - **Critical fix applied here**
- [ServiceProviderModelMapper+Events](../../../BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+Events.swift) - Maps ServicesProvider.Event to Match
- [MatchDetailsTextualViewModel](../../../BetssonCameroonApp/App/Screens/MatchDetailsTextual/MatchDetailsTextualViewModel.swift) - Parent screen wiring

### Next Steps
1. Test breadcrumb tap functionality in simulator with real match data
2. Verify country ID and league ID are passed correctly to callbacks
3. Implement actual navigation logic in MatchDetailsTextualViewModel (currently TODOs)
4. Remove TODO comments once navigation is implemented
5. Consider extracting tap detection logic to reusable helper if pattern repeats elsewhere
