## Date
23 September 2025

### Project / Branch
sportsbook-ios / rr/cms

### Goals for this session
- Implement image display in SportTopBannerSliderViewModel using ImageHighlightedContents<Event>
- Simplify overcomplicated banner architecture
- Ensure CMS images flow properly from API to UI components

### Achievements
- [x] Updated getCarouselEvents() across all providers to return ImageHighlightedContents<Event>
- [x] Fixed MatchBannerView to load images using Kingfisher (was just showing placeholder)
- [x] Completely simplified banner architecture - removed SportBannerData, SportBannerViewModel, SportBannerType
- [x] Created clean MatchBannerViewModel that directly converts ImageHighlightedContent<Event> to UI
- [x] Simplified MatchBannerViewModelProtocol - removed unused publishers and methods
- [x] Fixed build errors in InPlayEventsViewModel and NextUpEventsViewModel
- [x] Organized ViewModels into proper folder structure

### Issues / Bugs Hit
- [x] SportBannerAction enum no longer existed after refactor - replaced with simple String event ID
- [x] MatchBannerView tried to use publishers we removed from simplified protocol - removed reactive bindings
- [x] Unused variable warnings in for-loop iterations

### Key Decisions
- **Simplified banner flow**: `ImageHighlightedContent<Event>` → `MatchBannerViewModel` → `MatchBannerView`
- **Removed reactive updates from banners**: Static content doesn't need real-time publishers
- **Single navigation pattern**: All banners open match details with event ID only
- **Moved ViewModels to dedicated folders**: Better organization under `/ViewModels/Banners/`

### Experiments & Notes
- Tried keeping SportBannerData as intermediate model → Too complex, deleted it
- Initially kept SportBannerViewModel → Unnecessary wrapper, replaced with direct mapping
- MatchBannerView had placeholder TODO for image loading → Implemented with Kingfisher

### Useful Files / Links
- [MatchBannerViewModel](../../BetssonCameroonApp/App/ViewModels/Banners/MatchBannerViewModel.swift) - Clean production implementation
- [SportTopBannerSliderViewModel](../../BetssonCameroonApp/App/ViewModels/Banners/SportTopBannerSliderViewModel.swift) - Simplified slider logic
- [MatchBannerView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchBannerView/MatchBannerView.swift) - Now loads images properly
- [MatchBannerViewModelProtocol](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchBannerView/MatchBannerViewModelProtocol.swift) - Simplified protocol
- [ServiceProviderModelMapper+Events](../../BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+Events.swift) - Event to Match mapping

### Next Steps
1. Test image display in simulator with real CMS data
2. Verify navigation flow works correctly when tapping banners
3. Consider if other UI components can benefit from similar simplification
4. Update any remaining references to deleted SportBanner* classes