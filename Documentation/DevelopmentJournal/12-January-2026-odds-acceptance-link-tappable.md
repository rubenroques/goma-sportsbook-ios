## Date
12 January 2026

### Project / Branch
sportsbook-ios / wip/manual-distribute-refactor (or dedicated branch for SPOR-7078)

### Goals for this session
- Implement SPOR-7078 (BC-204): Remove underline and link tap from betslip odds change info text
- Add `isLinkTappable` property to preserve future re-enablement option
- Create snapshot tests for OddsAcceptanceView component

### Achievements
- [x] Added `isLinkTappable: Bool` property to `OddsAcceptanceData` (default `false`)
- [x] Updated `OddsAcceptanceView` to conditionally apply underline and enable tap based on `isLinkTappable`
- [x] Updated `MockOddsAcceptanceViewModel` to support `isLinkTappable` parameter
- [x] Updated production `OddsAcceptanceViewModel` in BetssonCameroonApp to preserve `isLinkTappable` in update methods
- [x] Added 4th preview state showing tappable link for documentation
- [x] Created `OddsAcceptanceViewSnapshotViewController.swift` with two categories: Acceptance States and Link States
- [x] Created `OddsAcceptanceViewSnapshotTests.swift` with light/dark mode tests for both categories

### Issues / Bugs Hit
- None - implementation was straightforward

### Key Decisions
- **Used `isLinkTappable` property instead of removing link functionality entirely** - This preserves the ability to re-enable the link in the future without code changes, just by passing `true` to the property
- **Default value is `false`** - Production code uses default, so the link is disabled by default as required by SPOR-7078
- **Added snapshot tests with two categories** - Separates acceptance states (accepted/not accepted/disabled) from link states (tappable vs non-tappable) for clearer visual regression testing

### Experiments & Notes
- Traced the underline addition to commit `0a13c30df` by André Lascas on Jan 8, 2026
- The underline is applied via `NSAttributedString` with `.underlineStyle` attribute
- Tap gesture is controlled via `labelWithLinkLabel.isUserInteractionEnabled`

### Useful Files / Links
- [OddsAcceptanceViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Betting/OddsAcceptanceView/OddsAcceptanceViewModelProtocol.swift) - Data model with `isLinkTappable`
- [OddsAcceptanceView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Betting/OddsAcceptanceView/OddsAcceptanceView.swift) - View implementation
- [MockOddsAcceptanceViewModel.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Betting/OddsAcceptanceView/MockOddsAcceptanceViewModel.swift) - Mock for testing
- [OddsAcceptanceViewModel.swift](../../BetssonCameroonApp/App/Screens/Betslip/Cells/ViewModels/OddsAcceptanceViewModel.swift) - Production ViewModel
- [SPOR-7078](https://gomagaming.atlassian.net/browse/SPOR-7078) - Jira ticket

### Version Bump
- **Version**: 0.4.0 → 0.4.1
- **Build**: 4002 → 4101

### Next Steps
1. Build GomaUI and BetssonCameroonApp to verify compilation
2. Run snapshot tests and record reference images (set `SnapshotTestConfig.record = true`)
3. Commit reference images to git
4. Test in app: Open betslip, verify "Odds may change..." text has no underline and is not tappable
5. Create PR for SPOR-7078
