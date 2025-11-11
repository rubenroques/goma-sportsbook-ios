# RichBanner Pointer System Implementation for EveryMatrix

## Date
04 November 2025

## Project / Branch
sportsbook-ios / rr/rich-banner-ui-debug (worktree)

## Goals for this session
- Fix non-displaying match banners in EveryMatrix provider
- Complete migration from legacy `getCarouselEvents()` to new `getSportRichBanners()` API
- Implement proper pointer-based architecture for RichBanners in EveryMatrix

## Achievements
- [x] Identified root cause: EveryMatrix provider returned `Fail(notSupportedForProvider)` for RichBanner methods
- [x] Discovered architectural mismatch: Missing pointer layer between internal and enriched models
- [x] Created public `RichBannerPointers` types (InfoBannerPointer, CasinoGameBannerPointer, SportEventBannerPointer)
- [x] Added `getCasinoRichBannerPointers()` and `getSportRichBannerPointers()` to ManagedContentProvider protocol
- [x] Implemented `richBannerPointers()` mapper in GomaModelMapper
- [x] Implemented pointer methods in GomaHomeContentProvider (simple mapping, no enrichment)
- [x] Implemented both pointer and enriched methods in EveryMatrixManagedContentProvider
- [x] Verified data flow with breakpoints - banners now loading successfully

## Issues / Bugs Hit
- [x] Initial confusion about internal methods approach (reverted wrong implementation)
- [x] Misunderstood that `GomaModels.RichBanners` should be treated as pointers, not enriched data
- [ ] Info banner CTA buttons not functional (no callback wiring) - **Deferred to next session**

## Key Decisions

### Architecture Pattern: Pointer + Enriched Types
**Decision**: Follow the same pattern as CarouselEvents (pointer + enriched types)

**Rationale**:
- `GomaModels.RichBanners` contains only IDs and metadata (acts as pointers)
- Need public `RichBannerPointers` type to expose from providers
- EveryMatrix proxies pointers from Goma, enriches with own event/casino data
- Maintains clean 3-layer architecture: Internal Models → Public Pointers → Enriched Models

### Provider Responsibilities
**GomaHomeContentProvider**:
- Pointer methods: Map internal → public pointers (no enrichment)
- Enriched methods: Enrich with Goma's own event/casino providers

**EveryMatrixManagedContentProvider**:
- Pointer methods: Simple proxy to Goma (just delegate)
- Enriched methods: Get pointers from Goma → Enrich with EveryMatrix providers

### Order Preservation Strategy
**Decision**: Use dictionary-based lookup after parallel fetch, iterate original pointer array

**Implementation**:
```swift
// 1. Fetch in parallel (order not guaranteed)
Publishers.MergeMany(publishers).collect()

// 2. Create lookup dictionary
var eventDict: [String: Event] = [:]
validEvents.forEach { event in eventDict[event.id] = event }

// 3. Iterate pointers in order, lookup enrichment data
let richBanners: RichBanners = pointers.compactMap { pointer in
    guard let event = eventDict[pointer.sportEventId] else { return nil }
    // Map pointer + event → RichBanner
}
```

**Rationale**: Same pattern as existing `getCarouselEvents()` - proven to work correctly

## Experiments & Notes

### Why Not Use Internal Methods?
Initial approach was to add `sportRichBannersInternal()` methods to GomaHomeContentProvider. This was wrong because:
- Violates encapsulation (exposing internal API client)
- Doesn't follow established CarouselEvent pattern
- Protocol should define both pointer and enriched methods

### Why RichBannerPointers Are Needed
`GomaModels.RichBanners` are internal-only and contain:
- `.info(InfoBannerData)` - Complete data (id, title, imageUrl, etc.)
- `.casinoGame(CasinoGameBannerData)` - Just ID + metadata (casinoGameId, no CasinoGame object)
- `.sportEvent(SportEventBannerData)` - Just ID + metadata (sportEventId, no Event object)

Public API needs equivalent pointer types that providers can expose without depending on internal Goma models.

### Graceful Degradation
When enrichment fails (event/game not found), the banner is filtered out via `compactMap` returning `nil`. Info banners always succeed since they need no enrichment.

## Useful Files / Links

### Models (Public ServicesProvider)
- [RichBanner.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Content/Promotions/RichBanner.swift) - Added RichBannerPointer types (lines 4-109)
- [ManagedContentProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/ManagedContentProvider.swift) - Added pointer methods (lines 39-47)

### Mappers
- [GomaModelMapper+Promotions.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/Mappers/GomaModelMapper+Promotions.swift) - Added richBannerPointers() mapper (lines 359-404)

### Providers
- [GomaHomeContentProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Goma/Subsets/ManagedHomeContent/GomaHomeContentProvider.swift) - Implemented pointer methods (lines 123-133)
- [EveryMatrixManagedContentProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixManagedContentProvider.swift) - Full implementation (lines 194-311)

### App Layer
- [TopBannerSliderViewModel.swift](../../BetssonCameroonApp/App/ViewModels/Banners/TopBannerSliderViewModel.swift) - Calls getSportRichBanners() (line 88)
- [HANDOFF_DOCUMENT.md](../../HANDOFF_DOCUMENT.md) - Original implementation documentation

### Reference Documentation
- [Banners_Web_Implementation.md](/Users/rroques/Desktop/GOMA/CoreMasterAggregator/Documentation/Banners_Web_Implementation.md) - Web/Vue.js implementation
- [Banners_Android_Implementation.md](/Users/rroques/Desktop/GOMA/CoreMasterAggregator/Documentation/Banners_Android_Implementation.md) - Android/Kotlin implementation

## Code Statistics
- **Files Modified**: 5
- **Files Created**: 0 (only added types to existing RichBanner.swift)
- **Lines Added**: ~350
- **Lines Removed**: ~10

## Next Steps

### Immediate (Next Session)
1. **Wire info banner CTA callbacks** - Info banners display but buttons don't work
   - Add `onInfoBannerAction` callback to TopBannerSliderViewModel
   - Set callback in mapper or after mapping (like match banners)
   - Handle navigation in InPlayEvents/NextUpEvents coordinators
   - **Prompt created for next LLM instance** ✅

2. **Remove debug logging** - Clean up `[BANNER-DEBUG]` print statements from:
   - TopBannerSliderViewModel.swift
   - ServiceProviderModelMapper+RichBanners.swift

3. **Test all banner types**:
   - Info banners (with and without CTA)
   - Casino game banners
   - Match/sport event banners
   - Mixed carousel

### Follow-up Tasks
4. **Update SportRadar provider** - Currently returns `Fail(notSupportedForProvider)` for RichBanner methods
5. **Deprecate legacy methods** - Once RichBanner fully working:
   - Mark `getCarouselEvents()` as deprecated
   - Mark `getCasinoCarouselGames()` as deprecated
   - Add migration guide for BetssonFranceApp

6. **Documentation**:
   - Update CLAUDE.md with RichBanner pointer pattern
   - Document pointer vs enriched API usage
   - Add to API_DEVELOPMENT_GUIDE.md

## Session Reflection

**What went well**:
- Systematic investigation revealed the architectural gap (missing pointer layer)
- User caught my misunderstanding early (about internal methods approach)
- Clear pattern emerged by studying CarouselEvents implementation
- Implementation works on first try (verified with breakpoints)

**What could improve**:
- Should have read CarouselEvent implementation first before proposing solution
- Initial plan was overcomplicated (internal methods weren't needed)
- Could have been more critical of the "RichBanners already enriched" assumption

**Learning**:
- Always check existing patterns before designing new ones
- "Pointers" in this codebase means "IDs + metadata, no enriched objects"
- Protocol methods should expose both pointer and enriched variants
- User's architectural instinct was correct - trust domain expertise
