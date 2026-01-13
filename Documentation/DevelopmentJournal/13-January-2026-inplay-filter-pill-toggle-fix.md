## Date
13 January 2026

### Project / Branch
BetssonCameroonApp / rr/gomaui_snapshot_test

### Goals for this session
- Investigate and fix filter button toggle behavior bug in NextUpEvents/InPlayEvents screen
- Understand PillItemView architecture and isReadOnly pattern

### Achievements
- [x] Identified root cause: InPlayEventsViewController using `MockPillItemViewModel` without `isReadOnly: true`
- [x] Fixed by replacing `MockPillItemViewModel` with `FilterPillViewModel` (consistent with NextUpEvents)
- [x] Created Jira ticket SPOR-7135 with proper labels (BA, iOS), assigned, set to In Progress
- [x] Added changelog entry to v0.4.2 release notes

### Issues / Bugs Hit
- Initial confusion about which screen had the bug (NextUpEvents vs InPlayEvents)
- Atlassian MCP auth issues required re-authentication mid-session

### Key Decisions
- **Use `FilterPillViewModel`** instead of adding `isReadOnly: true` to MockPillItemViewModel
  - Rationale: Using Mock in production code is a code smell; FilterPillViewModel is purpose-built for this use case
- Noted architectural improvement opportunity: PillItemView could defensively check `isReadOnly` at view layer

### Experiments & Notes
- Traced the bug through multiple layers:
  1. `PillItemView.pillTapped()` calls `viewModel.selectPill()`
  2. `MockPillItemViewModel.selectPill()` checks `isReadOnly` - but defaults to `false`
  3. When `isReadOnly: false`, it toggles: `isSelectedSubject.send(!isSelectedSubject.value)`
- `FilterPillViewModel` was correctly designed from the start with:
  - `isReadOnly: true`
  - `selectPill()` as no-op
  - `isSelected: false` always

### Useful Files / Links
- [InPlayEventsViewController.swift](../../BetssonCameroonApp/App/Screens/InPlayEvents/InPlayEventsViewController.swift) - Bug location (line 173-181)
- [FilterPillViewModel.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/FilterPillViewModel.swift) - Correct implementation
- [PillItemView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Filters/PillItemView/PillItemView.swift) - Component implementation
- [MockPillItemViewModel.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Filters/PillItemView/MockPillItemViewModel.swift) - Mock with isReadOnly param
- [PillItemView README](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Filters/PillItemView/README.md) - Component documentation
- [SPOR-7135](https://gomagaming.atlassian.net/browse/SPOR-7135) - Jira ticket

### Next Steps
1. Build and verify fix compiles correctly
2. Test on device: tap filter button in Live screen, confirm no toggle
3. Consider adding defensive `isReadOnly` check in `PillItemView.pillTapped()` to prevent similar bugs
