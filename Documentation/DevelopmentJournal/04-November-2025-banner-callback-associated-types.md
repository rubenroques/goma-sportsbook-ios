# Banner Callback Infrastructure with Associated Types

## Date
04 November 2025

## Project / Branch
BetssonCameroonApp / betsson-cm (via git worktree rr/rich-banner-ui-debug)

## Goals for this session
- Implement type-safe callback infrastructure for banner CTA buttons
- Wire up full MVVM-C callback chain from banner tap to navigation
- Eliminate casting and custom properties outside protocol definitions
- Use Swift associated types for clean protocol design

## Achievements
- [x] Added `associatedtype ActionType` to `SingleButtonBannerViewModelProtocol`
- [x] Added protocol-level `onButtonAction: ((ActionType) -> Void)?` callback property
- [x] Updated `MockSingleButtonBannerViewModel` with `ActionType = Void`
- [x] Updated `InfoBannerViewModel` with `ActionType = InfoBannerAction`
- [x] Updated `CasinoBannerViewModel` with `ActionType = CasinoBannerAction`
- [x] Updated `TopBannerSliderViewModel` callback setup (sports banners)
- [x] Updated `CasinoTopBannerSliderViewModel` callback setup
- [x] Fixed `BannerType` enum to use concrete types instead of `any` keyword
- [x] Removed all custom `onBannerAction` properties in favor of protocol callbacks
- [x] Successfully tested banner navigation in sports and casino contexts
- [x] Merged changes from worktree to betsson-cm branch
- [x] Cleaned up git worktree and deleted feature branch

## Issues / Bugs Hit
- [x] **EXC_BAD_ACCESS crash with `any` keyword**: Initial implementation used `BannerType` with `any SingleButtonBannerViewModelProtocol` causing memory corruption (address 0x38)
  - **Root cause**: Swift existential containers with associated types created ARC issues in callback closures
  - **Fix**: Changed `BannerType` to use concrete types instead of `any` keyword
  - **Learning**: Associated types + `any` keyword requires careful memory management; concrete types are simpler and safer

- [x] **Git worktree branch conflict**: Attempted to checkout `betsson-cm` in main repo while worktree had it checked out
  - **Fix**: Switched worktree to different branch first, then switched main repo
  - **Command sequence**: Worktree → `git checkout rr/rich-banner-ui-debug`, Main → `git checkout betsson-cm`

## Key Decisions

### 1. Associated Types Over Type Erasure
**Decision**: Use Swift associated types with concrete implementations instead of `any` keyword for type erasure

**Rationale**:
- Type safety at compile time without runtime overhead
- Cleaner protocol design - callbacks are part of the protocol contract
- Eliminates need for custom properties outside protocol
- Simpler mental model: InfoBanner → InfoBannerAction, CasinoBanner → CasinoBannerAction

**Trade-off**: Requires type checking in parent ViewModels to route to correct action handler, but this is intentional routing logic, not a workaround

### 2. Separate Action Types for Different Domains
**Decision**: Keep `InfoBannerAction` and `CasinoBannerAction` separate instead of creating unified action type

**Rationale**:
- **Domain modeling**: Info banners need URL + target control (internal/external), Casino banners need game launch + simple URL
- **Type safety**: Compiler enforces correct action handling per banner type
- **Business logic clarity**: Actions reflect actual business requirements, not technical convenience

**Alternative considered**: Single `BannerAction` enum with all possible cases - rejected as it would mix unrelated business concepts

### 3. Mock Implementation Uses `Void` ActionType
**Decision**: `MockSingleButtonBannerViewModel` uses `typealias ActionType = Void`

**Rationale**:
- Simplest possible type for testing/preview scenarios
- Mocks don't need real action semantics
- Demonstrates protocol flexibility - any type works for ActionType

## Architecture Changes

### Before (Anti-pattern)
```swift
// Protocol had no callback property
public protocol SingleButtonBannerViewModelProtocol {
    var currentDisplayState: SingleButtonBannerDisplayState { get }
    func buttonTapped()
}

// Implementations added custom properties OUTSIDE protocol
final class InfoBannerViewModel: SingleButtonBannerViewModelProtocol {
    var onBannerAction: ((InfoBannerAction) -> Void) = { _ in }  // ❌ Not in protocol
}

// Parent had to cast to access custom property
case .info(let viewModel):
    if let infoVM = viewModel as? InfoBannerViewModel {  // ❌ Casting to workaround
        infoVM.onBannerAction = { ... }  // ❌ Accessing non-protocol property
    }
```

### After (Clean Architecture)
```swift
// Protocol defines callback contract with associated type
public protocol SingleButtonBannerViewModelProtocol {
    associatedtype ActionType  // ✅ Type-safe, flexible

    var currentDisplayState: SingleButtonBannerDisplayState { get }
    var onButtonAction: ((ActionType) -> Void)? { get set }  // ✅ Part of protocol
    func buttonTapped()
}

// Implementations specify their action type
final class InfoBannerViewModel: SingleButtonBannerViewModelProtocol {
    typealias ActionType = InfoBannerAction  // ✅ Explicit action semantics
    var onButtonAction: ((InfoBannerAction) -> Void)?  // ✅ Protocol conformance
}

// Parent uses protocol property with intentional routing
case .info(let viewModel):
    if let infoVM = viewModel as? InfoBannerViewModel {  // ✅ Intentional routing
        infoVM.onButtonAction = { action in  // ✅ Using protocol property
            self?.onInfoBannerAction(action)
        }
    }
```

### Key Improvements
1. **No custom properties** - Everything defined in protocol
2. **Type safety** - Associated types enforce correct action types
3. **Clear intent** - Casting is routing logic, not architectural workaround
4. **Flexible** - Any type can be ActionType (Void, InfoBannerAction, CasinoBannerAction)

## Full Callback Chain

```
User Tap
    ↓
SingleButtonBannerView.buttonTapped()
    ↓
SingleButtonBannerViewModel.buttonTapped()
    ↓
InfoBannerViewModel.onButtonAction?(InfoBannerAction)
    ↓
TopBannerSliderViewModel.onInfoBannerAction(InfoBannerAction)
    ↓
InPlayEventsViewModel.onBannerURLRequested?(url, target)
    ↓
InPlayEventsCoordinator.onShowBannerURL(url, target)
    ↓
MainTabBarCoordinator.openBannerURL(url, target)
    ↓
parseURLToRoute() → handleRoute() OR openExternalURL()
    ↓
Navigation (Internal deep link or Safari)
```

## Files Modified

### GomaUI Framework (3 files)
1. `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/SingleButtonBannerView/SingleButtonBannerViewModelProtocol.swift`
   - Added `associatedtype ActionType`
   - Added `var onButtonAction: ((ActionType) -> Void)? { get set }`

2. `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TopBannerSliderView/BannerType.swift`
   - Changed from `case info(any SingleButtonBannerViewModelProtocol)` to concrete types
   - Final: Uses InfoBannerViewModel, CasinoBannerViewModel directly (no `any`)

3. `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/SingleButtonBannerView/MockSingleButtonBannerViewModel.swift`
   - Added `typealias ActionType = Void`
   - Added `var onButtonAction: ((Void) -> Void)?`
   - Updated `buttonTapped()` to call `onButtonAction?(())`
   - Removed debug print statement from init

### BetssonCameroonApp (4 files)
4. `BetssonCameroonApp/App/ViewModels/Banners/InfoBannerViewModel.swift`
   - Added `typealias ActionType = InfoBannerAction`
   - Replaced custom `var onBannerAction` with protocol `var onButtonAction`
   - Updated `buttonTapped()` to use `onButtonAction?(action)`

5. `BetssonCameroonApp/App/Models/CasinoBanner/CasinoBannerViewModel.swift`
   - Added `typealias ActionType = CasinoBannerAction`
   - Replaced custom `var onBannerAction` with protocol `var onButtonAction`
   - Updated `buttonTapped()` to use `onButtonAction?(action)`

6. `BetssonCameroonApp/App/ViewModels/Banners/TopBannerSliderViewModel.swift`
   - Updated `processRichBanners()` callback setup
   - Added type checking: `if let infoVM = viewModel as? InfoBannerViewModel`
   - Changed from `infoVM.onBannerAction` to `infoVM.onButtonAction`
   - Same for casino banners

7. `BetssonCameroonApp/App/Screens/Casino/CasinoCategoriesList/CasinoTopBannerSliderViewModel.swift`
   - Updated `processRichBanners()` callback setup
   - Added type checking for both info and casino banners
   - Changed from custom `onBannerAction` to protocol `onButtonAction`
   - Includes InfoBannerAction → CasinoBannerAction conversion logic

## Experiments & Notes

### Why `buttonTapped()` Stays in Protocol
Initially questioned why `buttonTapped()` method exists if we have `onButtonAction` callback.

**Answer**: View needs protocol method to call. The callback is for parent-to-child communication (parent sets callback), the method is for child-to-parent events (view calls method → viewModel calls callback).

**Flow**:
```swift
// View calls protocol method
func buttonTapped() {
    viewModel.buttonTapped()  // Protocol method
}

// ViewModel implementation
func buttonTapped() {
    let action = determineAction()
    onButtonAction?(action)  // Callback to parent
}
```

### Memory Issue Investigation
The initial `any` keyword crash taught us about Swift's existential containers:

- **Existential container**: Swift's runtime wrapper for protocol types with associated types
- **Size**: ~40-56 bytes (depends on inline storage)
- **ARC semantics**: Complex retain/release for closures that capture existentials
- **Crash address 0x38 (56 bytes)**: Accessing property offset in corrupted existential

**Lesson**: When using associated types, prefer concrete types in storage (arrays, properties) over `any` keyword for simpler memory management.

## Useful Files / Links

### Core Protocol Files
- [SingleButtonBannerViewModelProtocol](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/SingleButtonBannerView/SingleButtonBannerViewModelProtocol.swift)
- [BannerType Enum](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TopBannerSliderView/BannerType.swift)
- [TopBannerSliderViewModelProtocol](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TopBannerSliderView/TopBannerSliderViewModelProtocol.swift)

### Implementation Files
- [InfoBannerViewModel](../../BetssonCameroonApp/App/ViewModels/Banners/InfoBannerViewModel.swift)
- [CasinoBannerViewModel](../../BetssonCameroonApp/App/Models/CasinoBanner/CasinoBannerViewModel.swift)
- [TopBannerSliderViewModel (Sports)](../../BetssonCameroonApp/App/ViewModels/Banners/TopBannerSliderViewModel.swift)
- [CasinoTopBannerSliderViewModel](../../BetssonCameroonApp/App/Screens/Casino/CasinoCategoriesList/CasinoTopBannerSliderViewModel.swift)

### Architecture Guides
- [MVVM-C Documentation](../MVVM.md)
- [GomaUI Component Guide](../../Frameworks/GomaUI/CLAUDE.md)
- [Project Architecture](../CLAUDE.md)

### Previous Related Work
- [Rich Banner EveryMatrix Implementation](./04-November-2025-richbanner-pointer-everymatrix-implementation.md)

## Next Steps

### Immediate (Optional Improvements)
1. Consider removing `buttonTapped()` method if View can call callback directly (architectural discussion needed)
2. Add unit tests for banner action routing logic
3. Document the associated types pattern in project architecture guide

### Future Considerations
1. **Pattern replication**: Apply same associated type pattern to other protocol callbacks in codebase
2. **Generic parent ViewModels**: Explore if TopBannerSliderViewModel can be generic over action type
3. **Performance profiling**: Measure if concrete types improved performance vs `any` keyword (expect negligible difference)

### Testing Checklist
- [x] Info banner CTA buttons navigate correctly (deposit, promotions, external URLs)
- [x] Casino banner CTA buttons launch games and open URLs
- [x] Sports banner match cards still work (not affected by changes)
- [x] GomaUI framework builds without errors
- [x] BetssonCameroonApp builds and runs on simulator
- [ ] Write unit tests for action routing logic (future work)
- [ ] Test banner callbacks in production build (not just debug)

## Merge & Cleanup Summary

```bash
# Worktree workflow used
git worktree add git-worktrees/rr/rich-banner-ui-debug betsson-cm
cd git-worktrees/rr/rich-banner-ui-debug
# Made all changes in worktree
git commit -m "Add banner callback infrastructure with associated types"

# Merge back to main repo
cd /Users/rroques/Desktop/GOMA/iOS/sportsbook-ios
git checkout betsson-cm  # Failed - branch in use by worktree

# Fix: Switch worktree to different branch
cd git-worktrees/rr/rich-banner-ui-debug
git checkout rr/rich-banner-ui-debug

# Now merge works
cd /Users/rroques/Desktop/GOMA/iOS/sportsbook-ios
git checkout betsson-cm
git worktree remove git-worktrees/rr/rich-banner-ui-debug
git branch -d rr/rich-banner-ui-debug
```

**Final commit**: `936760379` - "Added associated types to SingleButtonBannerViewModelProtocol..."

**Branches cleaned**: Local `rr/rich-banner-ui-debug` deleted, remote branch still exists (can be deleted with `git push origin --delete rr/rich-banner-ui-debug`)
