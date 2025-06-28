## Date
28 June 2025

### Project / Branch
sportsbook-ios / GomaUI MatchHeaderView Component Architecture

### Goals for this session
- Remove UIKit dependencies from MatchHeaderViewModelProtocol to achieve proper MVVM separation
- Enable external image customization for reusable GomaUI components
- Eliminate over-engineered MatchHeaderVisualState complexity
- Implement ImageResolver pattern for dependency injection

### Achievements
- [x] Created `MatchHeaderImageResolver` protocol for clean image resolution abstraction
- [x] Removed UIKit imports from all ViewModel protocols (proper MVVM separation achieved)
- [x] Implemented `AppMatchHeaderImageResolver` using existing app image loading logic
- [x] Updated `TallOddsMatchCardView` to accept and use `imageResolver` parameter
- [x] Removed entire `MatchHeaderVisualState` enum and related complexity (4 states → 1 standard state)
- [x] Cleaned up all visual state handling from MatchHeaderView, MockMatchHeaderViewModel, and production ViewModel
- [x] Fixed compilation errors in `TallOddsMatchCardViewModel` and `MockTallOddsMatchCardViewModel`
- [x] Updated documentation with new ImageResolver pattern examples
- [x] Maintained backward compatibility with `DefaultMatchHeaderImageResolver`

### Issues / Bugs Hit
- [x] Production `MatchHeaderViewModel` had hardcoded image loading logic mixed with ViewModel concerns
- [x] Multiple files still referenced removed `visualState` parameter causing compilation errors
- [x] `TallOddsMatchCardView` factory method was static, needed to become instance method to access imageResolver

### Key Decisions
- **ImageResolver ownership**: View owns the resolver (Option 1) - clean separation, testable, flexible
- **Backward compatibility**: Default parameter `DefaultMatchHeaderImageResolver()` maintains existing API
- **Visual state elimination**: Simplified from 4 complex states to always "standard" - removed over-engineering
- **Bundle dependencies**: Removed hardcoded `Bundle.module` references, now uses system icons or custom resolver

### Experiments & Notes
- Tried making `createMatchHeaderView()` static but needed instance access to `imageResolver` property
- Explored global singleton for ImageResolver but decided against it for testability
- Live indicator icon changed from custom bundle asset to `UIImage(systemName: "play.fill")`

### Useful Files / Links
- [MatchHeaderImageResolver Protocol](GomaUI/GomaUI/Sources/GomaUI/Components/MatchHeaderView/MatchHeaderViewModelProtocol.swift)
- [AppMatchHeaderImageResolver Implementation](Core/Services/ImageResolvers/AppMatchHeaderImageResolver.swift)
- [Updated MatchHeaderView](GomaUI/GomaUI/Sources/GomaUI/Components/MatchHeaderView/MatchHeaderView.swift)
- [Production MatchHeaderViewModel](Core/ViewModels/TallOddsMatchCard/MatchHeaderViewModel.swift)
- [TallOddsMatchCardView Integration](GomaUI/GomaUI/Sources/GomaUI/Components/TallOddsMatchCardView/TallOddsMatchCardView.swift)

### Architecture Impact
**Before**: ViewModel had UIKit dependencies, hardcoded image names, complex visual states
**After**: Clean MVVM separation, external image customization, simplified always-standard behavior

### Code Quality Improvements
- **Separation of Concerns**: ViewModels now pure, View handles UI concerns via ImageResolver
- **Dependency Injection**: ImageResolver can be easily mocked for testing
- **Reusability**: GomaUI components work across different apps with custom image loading
- **Simplicity**: Removed 200+ lines of visual state complexity that wasn't being used

### Next Steps
1. Test complete build and runtime behavior in simulator
2. Consider creating similar ImageResolver patterns for other GomaUI components
3. Update any integration tests that might reference removed visual states
4. Document pattern for other developers working on GomaUI components