## Date
07 January 2026

### Project / Branch
GomaUI / al/ba-cashout-fixes

### Goals for this session
- Add snap-to-edge behavior for CashoutSliderView to improve UX when selecting min/max values
- Fix precision issue where large value ranges make it nearly impossible to hit exact limits

### Achievements
- [x] Added snap zone logic to CashoutSliderView (2.5% threshold at each edge)
- [x] Implemented `snappedValue(for:min:max:)` helper method for edge detection
- [x] Fixed button title sync issue - ensures ViewModel receives snapped value
- [x] No protocol or ViewModel changes required (view-side only implementation)

### Issues / Bugs Hit
- [x] Initial 5% threshold was too aggressive - reduced to 2.5%
- [x] Button showed un-snapped value (99.23) while slider visually snapped to max (100) - fixed by simplifying value passing logic

### Key Decisions
- **View-side snapping** chosen over ViewModel-side because:
  - Snap behavior is a UI concern (pixel precision)
  - ViewModel receives already-snapped values (cleaner contract)
  - No protocol changes required
  - Production ViewModels stay untouched
- **2.5% threshold** at each edge (not 5%) - for 0.01→100 range, values ≥97.5 snap to max

### Experiments & Notes
- Explored existing GomaUI patterns: CustomSliderView has `snapToNearestStep()` for discrete steps, TimeSliderView rounds to integers
- Considered tappable min/max labels as alternative UX - can be added later if needed

### Useful Files / Links
- [CashoutSliderView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Betting/CashoutSliderView/CashoutSliderView.swift)
- [CashoutSliderViewModelProtocol](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Betting/CashoutSliderView/CashoutSliderViewModelProtocol.swift)
- [CustomSliderView (reference)](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Forms/CustomSliderView/)

### Next Steps
1. Test snap behavior on device with various value ranges
2. Consider adding haptic feedback when snap occurs (optional enhancement)
3. Consider making snap threshold configurable via ViewModel if different screens need different thresholds
