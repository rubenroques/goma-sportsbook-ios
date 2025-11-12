## Date
12 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Debug and fix Auto Layout crash in CasinoGamePrePlayViewController
- Resolve NSLayoutConstraint "no common ancestor" exception

### Achievements
- [x] Identified root cause: `favoritesButton` constraints activated without adding view to hierarchy
- [x] Fixed crash by keeping button in view hierarchy but setting `isHidden = true`
- [x] Maintained feature readiness for future activation

### Issues / Bugs Hit
- [x] **NSGenericException crash**: "Unable to activate constraint with anchors UIButton.trailing and SimpleNavigationBarView.trailing because they have no common ancestor"
  - **Location**: `CasinoGamePrePlayViewController.swift:158` (setupConstraints)
  - **Root Cause**: Line 141 had `view.addSubview(favoritesButton)` commented out, but lines 177-180 were still activating constraints for the button
  - **Impact**: App terminating at launch when navigating to Casino game pre-play screen

### Key Decisions
- **Chose to hide rather than remove**: Instead of commenting out constraints, added `button.isHidden = true` to the button initialization
  - **Rationale**: Keeps Auto Layout structure intact and feature ready for activation
  - **Benefit**: No need to refactor constraints when enabling the favorites feature later
  - **Trade-off**: Minimal overhead of hidden view in hierarchy vs. cleaner removal

### Technical Details
**The Problem:**
```swift
// Line 141: Button NOT added to view hierarchy (commented out)
private func setupNavigationView() {
    view.addSubview(navigationBarView)
    // view.addSubview(favoritesButton)  // ❌ Commented out
}

// Lines 177-180: But constraints still being activated
favoritesButton.trailingAnchor.constraint(equalTo: navigationBarView.trailingAnchor, constant: -16),
favoritesButton.centerYAnchor.constraint(equalTo: navigationBarView.centerYAnchor),
// ... ❌ Crashes: views have no common ancestor
```

**The Solution:**
```swift
// Line 52: Added isHidden = true to button initialization
private let favoritesButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(systemName: "heart"), for: .normal)
    button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
    button.tintColor = .white
    button.isHidden = true  // ✅ Hidden but in hierarchy
    return button
}()

// Line 141: Uncommented to add button to hierarchy
private func setupNavigationView() {
    view.addSubview(navigationBarView)
    view.addSubview(favoritesButton)  // ✅ Now in hierarchy
}
```

### Auto Layout Crash Pattern Recognition
**Key Learning**: This crash pattern occurs when:
1. View constraints are defined and activated
2. But view is never added to superview via `addSubview()`
3. Auto Layout cannot establish "common ancestor" relationship

**Prevention Checklist**:
- Always ensure `view.addSubview()` is called before activating constraints
- Use `isHidden` instead of commenting out `addSubview()` if temporarily disabling UI
- Consider extracting constraint activation to lazy property or method called after setup

### Useful Files / Links
- [CasinoGamePrePlayViewController.swift](../../BetssonCameroonApp/App/Screens/Casino/CasinoGamePrePlay/CasinoGamePrePlayViewController.swift) (lines 46-54, 141, 177-180)
- [Apple Auto Layout Guide - Common Ancestor](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/)

### Next Steps
1. Test favorites button functionality when `isHidden` is set to false
2. Implement actual favorites toggle backend integration
3. Consider adding favorites feature to casino game cards as well
