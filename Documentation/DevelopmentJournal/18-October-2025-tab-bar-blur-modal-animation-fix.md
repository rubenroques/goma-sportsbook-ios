# Tab Bar Blur Layer Modal Animation Fix

## Date
18 October 2025

### Project / Branch
BetssonCameroonApp / rr/oddsboost_ui

### Goals for this session
- Fix weird blur layer animation during modal presentation/dismissal on tab bar
- Investigate why translucent glass effect was appearing from top-left corner with tiny size
- Restore proper native-like iOS tab bar blur behavior

### Achievements
- [x] Identified root cause: blur view being removed/recreated on `traitCollectionDidChange()`
- [x] Converted `combinedTabBarBlurView` from optional to lazy property with factory method
- [x] Moved blur view creation to `setupSubviews()` - created once, never removed
- [x] Moved blur constraints to `initConstraints()` - set once during initial layout
- [x] Deleted problematic `setupCombinedTabBarBlur()` method entirely
- [x] Fixed `mainContainerView` constraint to extend behind tab bar (changed from `tabBarView.topAnchor` to `view.bottomAnchor`)
- [x] Made `containerView` transparent to allow blur effect to work properly

### Issues / Bugs Hit
- [x] Initial fix didn't restore blur effect - blur was trying to blur a solid background color
- [x] After fixing background, content wasn't extending behind tab bar (wrong constraint)
- [ ] **REMAINING:** Table view content inset hardcoded at 54pt instead of dynamic calculation (56pt tab bar + safe area)

### Key Decisions
- **Treat blur view like any other view** - lazy property, created once, never removed/recreated
- Changed `mainContainerView.bottomAnchor` from `tabBarView.topAnchor` to `view.bottomAnchor` to allow content to extend underneath tab bar for blur effect
- Made `containerView` transparent (`.clear`) so blur effect can work - only `mainContainerView` needs background color
- Deleted entire `setupCombinedTabBarBlur()` method to prevent future recreation during theme changes

### Experiments & Notes
- Initially tried fixing with `isAnimating` flag and `layoutSubviews()` override - wrong approach, reverted
- Discovered the issue wasn't transform conflicts but **view lifecycle** - blur being removed/added repeatedly
- Key insight: User noticed "only the blur layer moves, not the tab bar itself" - led to correct diagnosis
- Modal presentation/dismissal triggers `traitCollectionDidChange()` → `setupWithTheme()` → blur recreation
- Blur requires transparent container + content extending behind it to work properly

### Useful Files / Links
- [MainTabBarViewController.swift](../../BetssonCameroonApp/App/Screens/MainTabBar/MainTabBarViewController.swift)
  - Lines 25: Property declaration (now lazy)
  - Lines 764-769: Factory method `createCombinedTabBarBlurView()`
  - Lines 827: View hierarchy setup in `setupSubviews()`
  - Lines 948-952: Constraints in `initConstraints()`
  - Line 254: Transparent container background in `setupWithTheme()`
  - Line 861: Fixed mainContainer constraint to extend behind tab bar
- [MarketGroupCardsViewController.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/MarketGroupCardsViewController.swift)
  - Line 195: Content inset (needs dynamic calculation fix)
- [AdaptiveTabBarView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/AdaptiveTabBarView/AdaptiveTabBarView.swift)
  - Custom tab bar component (no changes needed - issue was in parent view controller)

### Architecture Pattern Applied
**Standard UIKit view lifecycle pattern:**
```swift
// Property: Lazy initialization
private lazy var combinedTabBarBlurView: UIVisualEffectView = Self.createCombinedTabBarBlurView()

// Factory method: Create view once
private static func createCombinedTabBarBlurView() -> UIVisualEffectView {
    let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
    let view = UIVisualEffectView(effect: blurEffect)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
}

// Add to hierarchy: Once in setupSubviews()
containerView.insertSubview(combinedTabBarBlurView, belowSubview: tabBarView)

// Constraints: Once in initConstraints()
NSLayoutConstraint.activate([...])
```

### Next Steps
1. **Fix table view content inset** - calculate dynamically in `MarketGroupCardsViewController`:
   - Move from hardcoded `54pt` to dynamic: `56pt (tab bar) + view.safeAreaInsets.bottom`
   - Implement in `viewDidLayoutSubviews()` or `viewSafeAreaInsetsDidChange()` for correct timing
2. Test on devices with different safe areas (iPhone with home button vs notch/island)
3. Verify modal animations work correctly across all screens (betslip, profile, etc.)
4. Consider if other view controllers with table/collection views need similar content inset fixes
