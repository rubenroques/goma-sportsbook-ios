## Date
27 November 2025

### Project / Branch
sportsbook-ios / rr/bugfix/match_detail_blinks

### Goals for this session
- Hide volatility and minimum stake mini components from CasinoGamePrePlay screen

### Achievements
- [x] Commented out volatility label, capsule, and thunderbolt stack view UI components
- [x] Commented out minStake label and value UI components
- [x] Commented out detailsContainerView that housed these components
- [x] Updated constraints to connect buttonsStackView directly to gameDescriptionLabel
- [x] Commented out `updateVolatilityCapsule()` and `mapVolatilityToThunderboltCount()` methods
- [x] Commented out volatility/minStake data binding calls in `updateGameData()`

### Issues / Bugs Hit
- None

### Key Decisions
- Chose to comment out rather than delete code to allow easy restoration if needed
- Added clear comments (`// Hidden per product decision`) to explain why code is commented
- Modified constraints so buttons stack view now connects to description label instead of the hidden details container

### Experiments & Notes
- The volatility and minStake components were part of `CasinoGamePlayModeSelectorView` in GomaUI framework
- This is a reusable component, so changes affect all consumers (currently only BetssonCameroonApp)

### Useful Files / Links
- [CasinoGamePlayModeSelectorView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CasinoGamePlayModeSelectorView/CasinoGamePlayModeSelectorView.swift)
- [CasinoGamePrePlayViewController](../../BetssonCameroonApp/App/Screens/Casino/CasinoGamePrePlay/CasinoGamePrePlayViewController.swift)

### Next Steps
1. Build and verify changes compile correctly
2. Test in simulator to confirm UI displays correctly without the hidden components
