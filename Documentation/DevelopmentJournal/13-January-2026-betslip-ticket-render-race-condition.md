## Date
13 January 2026

### Project / Branch
BetssonCameroonApp / rr/gomaui_snapshot_test

### Goals for this session
- Investigate betslip ticket rendering issue (empty cells with only odds showing)
- Identify root cause of intermittent rendering bug
- Apply fix to resolve the race condition

### Achievements
- [x] Identified race condition in `BetslipTicketView` async rendering
- [x] Added comprehensive debug logging with `BETSLIP_RACE` filter tag
- [x] Confirmed hypothesis through log analysis (failing vs working cases)
- [x] Applied synchronous render fix to `BetslipTicketView.swift`

### Issues / Bugs Hit
- [x] **Race Condition**: `BetslipTicketView` relied entirely on async Combine publishers for rendering
- [x] **Root Cause**: `.receive(on: DispatchQueue.main)` always schedules for next run loop, even when already on main thread
- [x] **Symptom**: Fresh cells displayed before `render()` fired, showing empty labels

### Key Decisions
- Used **synchronous initial render** pattern: call `render(data: viewModel.currentData)` immediately in `didSet` and `init`
- Added `.dropFirst()` to publishers to avoid double-rendering on initial assignment
- Kept debug logs in place for verification (can be removed after confirmation)

### Experiments & Notes

**Log Analysis - Failing Case:**
```
17:10:01.330 ticketsStatePublisher triggered reloadData()
17:10:01.330 updateUI() triggering reloadData()
17:10:01.331 ticketsStatePublisher triggered reloadData()  ← 3 reloads in 1ms
17:10:01.335 cellForRowAt START                            ← 4ms gap
17:10:01.340 dequeued cell: 0x10798c400                    ← FRESH cell (no prepareForReuse)
```

**Log Analysis - Working Case:**
```
17:11:10.650 ticketsStatePublisher triggered reloadData()
17:11:10.652 cellForRowAt START                            ← Only 2ms gap
17:11:10.657 updateUI() triggering reloadData()            ← Second pass gives render() time
17:11:10.665 prepareForReuse() START                       ← Cell reused, already rendered
```

**Key Insight**: In failing case, fresh cell had no prior render. Async publisher subscription meant `render()` fired AFTER cell was displayed.

### Useful Files / Links
- [SPOR-7132](https://gomagaming.atlassian.net/browse/SPOR-7132) - Jira ticket (BC-475)
- [BetslipTicketView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Betting/BetslipTicketView/BetslipTicketView.swift) - Main fix location
- [BetslipTicketTableViewCell.swift](../../BetssonCameroonApp/App/Screens/Betslip/Cells/BetslipTicketTableViewCell.swift) - Debug logs added
- [SportsBetslipViewController.swift](../../BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/SportsBetslipViewController.swift) - Debug logs added
- [GomaUI CLAUDE.md - Synchronous State Access](../../Frameworks/GomaUI/CLAUDE.md) - Documents the pattern

### Code Changes Summary

**BetslipTicketView.swift:**
```swift
// 1. In init - render synchronously (didSet doesn't fire during init)
render(data: viewModel.currentData)

// 2. In viewModel didSet - render synchronously before async bindings
render(data: viewModel.currentData)

// 3. In setupBindings() - skip first emission (already rendered sync)
viewModel.dataPublisher
    .dropFirst()
    .receive(on: DispatchQueue.main)
    ...
```

### Next Steps
1. Remove debug logs after confirming fix works consistently
2. Consider applying same pattern to other GomaUI components with similar async-only rendering
3. Document this pattern in GomaUI CLAUDE.md if not already covered
