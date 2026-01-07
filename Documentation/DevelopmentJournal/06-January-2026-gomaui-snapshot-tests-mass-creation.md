## Date
06 January 2026

### Project / Branch
sportsbook-ios / rw/snapshot_tests

### Goals for this session
- Create snapshot tests for ALL GomaUI components following the spec at `Frameworks/GomaUI/Documentation/RALPH_SNAPSHOT_TESTS.md`
- Follow the **two-file pattern**: SnapshotViewController (in Sources, same folder as component) + SnapshotTests (in Tests)
- Process 3 components per batch with mandatory build verification and test execution
- Ensure Light/Dark mode coverage for each component
- Update COMPONENT_MAP.json with `has_snapshot_tests: true` after each batch

### Spec Followed
All work followed the workflow defined in:
```
Frameworks/GomaUI/Documentation/RALPH_SNAPSHOT_TESTS.md
```

Key patterns from spec:
- **Scheme**: `GomaUI` (NOT GomaUICatalog)
- **Simulator ID**: `4C2C3F29-3F1E-4BEC-A397-C5A54256ADC7`
- **Category-based enum** for organizing snapshot variants
- **Light + Dark** test methods per category
- **`SnapshotTestConfig.record = true`** for recording mode

### Achievements
- [x] Created snapshot tests for **83 GomaUI components** (all committed)
- [x] Created **86 SnapshotViewController files** (3 pending commit for batch 26)
- [x] Created **86 SnapshotTests files** (3 pending commit for batch 26)
- [x] Reorganized ~130 components into feature-based category folders
- [x] Fixed BorderedTextFieldView synchronous state access for snapshot tests
- [x] Updated COMPONENT_MAP.json with `has_snapshot_tests: true` for all 83 committed components

#### Components Covered (by batch/commit):

**Batch 1**: ActionButtonBlockView, ActionRowView, AdaptiveTabBarView
**Batch 2**: AmountPillView, AmountPillsView, BetDetailResultSummaryView
**Batch 3**: BetDetailValuesSummaryView, BetInfoSubmissionView, BetTicketStatusView
**Batch 4**: BetslipFloatingView, BetslipHeaderView, BetslipOddsBoostHeaderView
**Batch 5**: BetslipTicketView, BetslipTypeSelectorView, BonusCardView
**Batch 6**: BetslipTypeTabItemView, BonusInfoCardView, BorderedTextFieldView
**Batch 7**: BulletItemBlockView, ButtonIconView, CashoutSliderView
**Batch 8**: CashoutSubmissionInfoView, CasinoCategoryBarView, CasinoCategorySectionView
**Batch 9**: CasinoGameCardView, CodeClipboardView, CopyableCodeView
**Batch 10**: CustomSliderView, DepositBonusInfoView, DescriptionBlockView
**Batch 11**: EmptyStateActionView, ExpandableSectionView, ExtendedListFooterView
**Batch 12**: CasinoGameImageView, CasinoGameImagePairView, CasinoGameImageGridSectionView
**Batch 13**: CasinoGamePlayModeSelectorView, CasinoGameSearchedView, CodeInputView
**Batch 14**: CompactMatchHeaderView, CompactOutcomesLineView, CountryLeaguesFilterView
**Batch 15**: CustomExpandableSectionView, CustomNavigationView, HighlightedTextView
**Batch 16**: HeaderTextView, InfoRowView, NavigationActionView
**Batch 17**: PinDigitEntryView, ProgressInfoCheckView, QuickLinksTabBar
**Batch 18**: SeeMoreButtonView, StatusInfoView, StatusNotificationView
**Batch 19**: GradientHeaderView, TextSectionView, ToasterView
**Batch 20**: ThemeSwitcherView, TimeSliderView, TopBannerSliderView
**Batch 21**: StepInstructionView, SingleButtonBannerView, TransactionItemView
**Batch 22**: TermsAcceptanceView, PromotionalHeaderView, ResendCodeView
**Batch 23**: TransactionVerificationView, ScoreView, SearchView
**Batch 24**: MatchHeaderCompactView, MatchHeaderView, MatchParticipantsInfoView
**Batch 25**: MarketOutcomesLineView, MarketOutcomesMultiLineView, MarketInfoLineView

**Pending Commit (Batch 26)**: WalletWidgetView, UserLimitCardView, WalletStatusView

### Issues / Bugs Hit
- [x] COMPONENT_MAP.json edit failed for MatchHeaderCompactView due to different JSON structure (children array vs empty)
- [x] Exit code 137 on test runs - process interrupted by user, not actual failures
- [ ] Some snapshot images pending commit (CasinoGame*, Code*, Custom*, etc.)

### Key Decisions
- Used Ralph loop automation for systematic batch processing (3 components per iteration)
- Each component gets both Light and Dark mode snapshots
- SnapshotViewController pattern: category enum + createLabeledVariant helper
- MockViewModel factory methods used extensively for test data
- record mode enabled (`SnapshotTestConfig.record = true`) - "failures" expected during recording

### Experiments & Notes
- Ralph loop proved highly effective for repetitive test creation tasks
- Pattern consistency maintained across all 86 components
- Two-file pattern (SnapshotViewController in Sources, Tests in Tests) works well for organization

### Useful Files / Links
- [Snapshot Test Guide](../../Frameworks/GomaUI/Documentation/RALPH_SNAPSHOT_TESTS.md)
- [COMPONENT_MAP.json](../../Frameworks/GomaUI/Documentation/COMPONENT_MAP.json)
- [SnapshotTestConfig](../../Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/SnapshotTestConfig.swift)

### Next Steps
1. Run tests for WalletWidgetView, UserLimitCardView, WalletStatusView to record snapshots
2. Commit batch 26 with recorded images
3. Stage and commit all pending snapshot images from earlier batches
4. Consider running full test suite to verify all snapshots
5. Set `SnapshotTestConfig.record = false` for CI verification mode
