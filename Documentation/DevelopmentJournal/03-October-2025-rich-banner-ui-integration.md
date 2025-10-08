# Rich Banner UI Integration - 3-Layer Architecture

## Date
03 October 2025

### Project / Branch
sportsbook-ios / rr/bettingOfferSubscription

### Goals for this session
- Connect new ServicesProvider `RichBanner` models to GomaUI components
- Update BannerType enum to support 3 distinct cases: info, casino, match
- Implement proper 3-layer architecture: ServicesProvider → App (Mappers/ViewModels) → GomaUI
- Fix protocol callback issues in MatchBannerViewModelProtocol
- Enable ViewModels to consume unified rich banners supporting mixed types

### Achievements
- [x] Updated GomaUI `BannerType` enum with 3 explicit cases: `.info`, `.casino`, `.match`
- [x] Created `InfoBannerData` app-level model with action support
- [x] Created `InfoBannerViewModel` implementing `SingleButtonBannerViewModelProtocol`
- [x] Created `ServiceProviderModelMapper+RichBanners` for 3-layer conversion
- [x] Added callback closures to `MatchBannerViewModelProtocol` for proper MVVM
- [x] Updated `MockMatchBannerViewModel` with protocol callback properties
- [x] Verified `TopBannerSliderViewModel` uses new rich banner API

### Issues / Bugs Hit
- [x] **Duplicate method error**: `singleButtonBannerData(fromCasinoBannerData:)` already existed in `ServiceProviderModelMapper+CasinoBanner.swift` - removed duplicate from new file
- [x] **Protocol callback missing**: `MatchBannerViewModelProtocol` didn't define callback closures, only concrete `MatchBannerViewModel` had them - added to protocol
- [x] **File path confusion**: Looked for `SportTopBannerSliderViewModel.swift` but actual file was `TopBannerSliderViewModel.swift`
- [x] **Naming conflict**: Same name for method and closure (`onOutcomeSelected`) - Swift allows this pattern, closure takes precedence when called with `?`

### Key Decisions
- **3-Layer Architecture**: Clear separation of concerns
  - **ServicesProvider**: Network layer with `RichBanner` enum (info/casinoGame/sportEvent)
  - **App Layer**: Mappers + ViewModels connecting ServicesProvider → GomaUI
  - **GomaUI**: Reusable UI components with protocol-driven interfaces

- **BannerType with 3 cases**: Even though `.info` and `.casino` both use `SingleButtonBannerView`, we keep them separate for semantic clarity and maintainability

- **Protocol-driven callbacks**: Added closure properties to `MatchBannerViewModelProtocol`:
  ```swift
  var onMatchTap: ((String) -> Void)? { get set }
  var onOutcomeSelected: ((String) -> Void)? { get set }
  var onOutcomeDeselected: ((String) -> Void)? { get set }
  ```
  This allows parent ViewModels to set callbacks without casting to concrete types

- **Naming convention**: Follow existing pattern `ServiceProviderModelMapper+{Domain}.swift` for mapper extensions

- **Reuse existing helpers**: Don't duplicate `singleButtonBannerData(fromCasinoBannerData:)` - reuse from `ServiceProviderModelMapper+CasinoBanner.swift`

### Experiments & Notes

#### Architecture Diagram
```
┌─────────────────────────────────────────────────────────────┐
│              SERVICES PROVIDER LAYER                        │
│         (Network / Backend Abstraction)                     │
└─────────────────────────────────────────────────────────────┘
                         │
                         │ API Response
                         ▼
        ┌────────────────────────────────────────┐
        │   GomaModels.RichBanner (Internal)     │
        │   • .info(InfoBannerData)              │
        │   • .casinoGame(CasinoGameBannerData)  │
        │   • .sportEvent(SportEventBannerData)  │
        └────────────────────────────────────────┘
                         │
                         │ Mapper + Enrichment
                         │ (Parallel fetch games/events)
                         ▼
        ┌────────────────────────────────────────┐
        │   RichBanner (Public Model)            │
        │   • .info(InfoBanner)                  │
        │   • .casinoGame(CasinoGameBanner)      │
        │   •   └─ CasinoGame + metadata         │
        │   • .sportEvent(SportEventBanner)      │
        │   •   └─ ImageHighlightedContent       │
        └────────────────────────────────────────┘
                         │
                         │ ServiceProviderModelMapper
                         │      +RichBanners
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   APP LAYER                                 │
│         (Integration / Glue Layer)                          │
└─────────────────────────────────────────────────────────────┘
                         │
        ┌────────────────────────────────────────┐
        │   App Models + ViewModels              │
        │   • InfoBannerData → InfoBannerViewModel│
        │   • CasinoBannerData → CasinoBannerViewModel│
        │   • Match → MatchBannerViewModel       │
        └────────────────────────────────────────┘
                         │
                         ▼
        ┌────────────────────────────────────────┐
        │   BannerType (GomaUI Model)            │
        │   • .info(SingleButtonBannerViewModelProtocol)│
        │   • .casino(SingleButtonBannerViewModelProtocol)│
        │   • .match(MatchBannerViewModelProtocol)│
        └────────────────────────────────────────┘
                         │
                         │ UI Rendering
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                     GOMAUI LAYER                            │
│              (Reusable UI Components)                       │
└─────────────────────────────────────────────────────────────┘
        ┌────────────────────────────────────────┐
        │   TopBannerSliderView                  │
        │   Renders:                             │
        │   • .info/.casino → SingleButtonBannerView│
        │   • .match → MatchBannerView           │
        └────────────────────────────────────────┘
```

#### Protocol Callback Pattern
Important learning: When adding callback closures to a protocol that's already in use:
1. **Add to protocol first**: Define `var onCallback: ((String) -> Void)? { get set }`
2. **Update all conformances**: Add the property to `MockViewModel` and concrete `ViewModel`
3. **Call the closure**: Inside method implementations, trigger the callback: `onCallback?(value)`
4. **No casting needed**: Parent ViewModels can now set callbacks directly via protocol

Example:
```swift
// Protocol (GomaUI)
protocol MatchBannerViewModelProtocol {
    var onMatchTap: ((String) -> Void)? { get set }
    func userDidTapBanner()
}

// Mock (GomaUI)
class MockMatchBannerViewModel: MatchBannerViewModelProtocol {
    var onMatchTap: ((String) -> Void)?

    func userDidTapBanner() {
        onMatchTap?(matchData.id)  // Trigger callback
    }
}

// Parent ViewModel (App)
let matchViewModel: MatchBannerViewModelProtocol = ...
matchViewModel.onMatchTap = { [weak self] eventId in
    self?.navigateToMatch(eventId)
}
```

### Useful Files / Links

#### Created Files
- [InfoBannerData.swift](../../BetssonCameroonApp/App/Models/InfoBanner/InfoBannerData.swift) - App-level info banner model with actions
- [InfoBannerViewModel.swift](../../BetssonCameroonApp/App/ViewModels/Banners/InfoBannerViewModel.swift) - Production ViewModel for info banners
- [ServiceProviderModelMapper+RichBanners.swift](../../BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+RichBanners.swift) - Mapper converting RichBanners → BannerType

#### Modified Files
- [BannerType.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TopBannerSliderView/BannerType.swift) - Updated enum: `.singleButton` → `.info` + `.casino`
- [MatchBannerViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchBannerView/MatchBannerViewModelProtocol.swift) - Added callback closures
- [MockMatchBannerViewModel.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchBannerView/MockMatchBannerViewModel.swift) - Implemented protocol callbacks
- [TopBannerSliderViewModel.swift](../../BetssonCameroonApp/App/ViewModels/Banners/TopBannerSliderViewModel.swift) - Uses `getSportRichBanners()` with mapper

#### Related Files
- [ServiceProviderModelMapper+CasinoBanner.swift](../../BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+CasinoBanner.swift) - Contains reusable `singleButtonBannerData(fromCasinoBannerData:)`
- [CasinoBannerData.swift](../../BetssonCameroonApp/App/Models/CasinoBanner/CasinoBannerData.swift) - App model for casino banners
- [CasinoBannerViewModel.swift](../../BetssonCameroonApp/App/Models/CasinoBanner/CasinoBannerViewModel.swift) - Production ViewModel for casino banners
- [MatchBannerViewModel.swift](../../BetssonCameroonApp/App/ViewModels/Banners/MatchBannerViewModel.swift) - Production ViewModel for match banners

### Data Flow Example

```swift
// 1. ViewModel fetches rich banners from ServicesProvider
servicesProvider.getSportRichBanners()
    .sink { richBanners in
        // richBanners: [RichBanner] = [.info(...), .sportEvent(...), .info(...)]

        // 2. Mapper converts to BannerType array
        let bannerTypes = ServiceProviderModelMapper.bannerTypes(
            fromRichBanners: richBanners
        )
        // bannerTypes: [BannerType] = [
        //   .info(InfoBannerViewModel),
        //   .match(MatchBannerViewModel),
        //   .info(InfoBannerViewModel)
        // ]

        // 3. Set up callbacks for match banners
        bannerTypes.forEach { bannerType in
            if case .match(let matchViewModel) = bannerType {
                matchViewModel.onMatchTap = { eventId in
                    // Navigate to match details
                }
            }
        }

        // 4. Pass to TopBannerSliderView
        updateSliderDataWithBanners(bannerTypes)
    }

// 5. TopBannerSliderView renders based on BannerType
switch bannerType {
case .info, .casino:
    // Render SingleButtonBannerView
case .match:
    // Render MatchBannerView
}
```

### Next Steps
1. **Build and test**: Verify BetssonCameroonApp builds successfully
2. **Test with real API**: Confirm all 3 banner types render correctly
3. **Update other banner consumers**: If there are other ViewModels using old banner APIs, migrate them
4. **Consider casino rich banners**: Create similar ViewModel for `getCasinoRichBanners()` if needed
5. **Clean up old code**: Remove deprecated methods once migration is complete
6. **Add info banner action handling**: Implement URL opening for info banner CTA

### Testing Notes
- Protocol changes verified: All conformances updated (Mock + Production)
- Mapper reuses existing helpers to avoid duplication
- TopBannerSliderViewModel already migrated to new API
- Build not yet run - awaiting user confirmation

### Migration Notes for Other Developers

**Breaking Changes:**
- `BannerType.singleButton` → split into `.info` and `.casino`
- `MatchBannerViewModelProtocol` now requires callback properties:
  - `var onMatchTap: ((String) -> Void)? { get set }`
  - `var onOutcomeSelected: ((String) -> Void)? { get set }`
  - `var onOutcomeDeselected: ((String) -> Void)? { get set }`

**New Pattern:**
```swift
// OLD: Cast to concrete type
if case .match(let matchViewModel) = bannerType,
   let concreteVM = matchViewModel as? MatchBannerViewModel {
    concreteVM.onMatchTap = { ... }
}

// NEW: Use protocol directly
if case .match(let matchViewModel) = bannerType {
    matchViewModel.onMatchTap = { ... }  // ✅ No cast needed!
}
```

**New Capabilities:**
- Mixed banner types in single slider (info + casino + sport events)
- Proper semantic separation of banner types
- Protocol-driven callback pattern for better MVVM
- Full enrichment with game/event data

### Architecture Learnings

1. **3-Layer Separation is Critical**:
   - ServicesProvider knows nothing about UI
   - GomaUI is reusable across apps, no business logic
   - App layer is the glue connecting the two

2. **Protocol Callbacks > Property Callbacks**:
   - Define callbacks in protocols, not just concrete classes
   - Enables MVVM without type casting
   - More testable with mocks

3. **Semantic Naming Matters**:
   - `onMatchTap` better than `onBannerTap` for match-specific protocol
   - `.info` and `.casino` more clear than generic `.singleButton`

4. **Reuse Over Duplication**:
   - Don't duplicate mapper methods
   - Check existing extensions before creating new ones
