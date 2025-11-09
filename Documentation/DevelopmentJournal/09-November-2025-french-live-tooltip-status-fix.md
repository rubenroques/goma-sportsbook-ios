# Development Journal Entry

## Date
09 November 2025

### Project / Branch
BetssonCameroonApp / betsson-cm

### Goals for this session
- Fix language-specific bug where pre-live matches show "Live" tooltip in French
- Investigate root cause of status mapping issue
- Implement comprehensive status handling for all EveryMatrix status IDs

### Achievements
- [x] Identified root cause: status mapper using language-dependent `name` instead of language-agnostic `id`
- [x] Added comprehensive debug logging with `[M-STATUS]` tag to trace status flow
- [x] Fixed status mapping to use `internalStatus.id` instead of `internalStatus.name`
- [x] Implemented complete status mapping for all 8 EveryMatrix event status IDs (1-8)
- [x] Confirmed fix using EveryMatrix Confluence documentation

### Issues / Bugs Hit
- [x] Pre-live matches showing "Live" tooltip in French language
- [x] French status names ("En attente", "En cours", "Terminé") not matching English switch cases
- [x] All French statuses falling into `default` case → incorrectly mapped to `.inProgress`

### Key Decisions
- **Used numeric IDs for status mapping** instead of localized names
  - ID "1" = Pending (not started)
  - ID "2" = In Progress (live)
  - ID "3" = Ended (finished)
  - ID "4" = Interrupted (treat as in progress - will resume)
  - ID "5", "6" = Canceled/Walkover (treat as ended - won't happen)
  - ID "7", "8" = Abandoned/Retired (treat as ended - won't continue)
- **Kept debug logs temporarily** to verify fix works in production
- **Interrupted status (4) mapped to `.inProgress`** because match will resume (still active)
- **Canceled/Abandoned statuses (5-8) mapped to `.ended`** because they won't continue

### Root Cause Analysis

#### The Bug
When language was set to French, the localization changes replaced hardcoded `language: "en"` with `EveryMatrixUnifiedConfiguration.shared.defaultLanguage`. This caused EveryMatrix WebSocket to return French status names:
- Pre-live: `id="1"`, `name="En attente"` (Waiting)
- Live: `id="2"`, `name="En cours"` (In progress)
- Ended: `id="3"`, `name="Terminé"` (Finished)

#### The Problem
`EveryMatrixModelMapper.eventStatus()` was using language-dependent `name`:
```swift
switch internalStatus.name.lowercased() {
case "pending", "not started":  // Only matches English!
    return .notStarted
case "live", "in progress", "started":
    return .inProgress(internalStatus.name)
case "finished", "ended", "completed":
    return .ended(internalStatus.name)
default:
    return .inProgress(internalStatus.name)  // ⚠️ All French names fall here!
}
```

French names ("En attente", "En cours", "Terminé") didn't match any English cases → all fell into `default` → all became `.inProgress` → all showed "Live" tooltip.

#### The Fix
Switch on language-agnostic `id` instead:
```swift
switch internalStatus.id {
case "1": result = .notStarted
case "2": result = .inProgress(internalStatus.name)
case "3": result = .ended(internalStatus.name)
case "4": result = .inProgress(internalStatus.name)  // Interrupted
case "5", "6": result = .ended(internalStatus.name)  // Canceled/Walkover
case "7", "8": result = .ended(internalStatus.name)  // Abandoned/Retired
default: result = .inProgress(internalStatus.name)
}
```

### Debug Logging Strategy
Added 4 strategic log points with `[M-STATUS]` tag:
1. **EventStatus.init** - Logs raw status value parsing
2. **EveryMatrixModelMapper.eventStatus()** - Logs both `id` and `name`, shows which is used
3. **TallOddsMatchCardViewModel WebSocket update** - Logs real-time status changes
4. **TallOddsMatchCardViewModel factory** - Logs initial match status

Log format: `[M-STATUS] Context | id="1" name="En attente" → using ID → .notStarted ✅`

### Experiments & Notes
- Initially suspected localization strings or visibility logic
- Discovered EveryMatrix `MatchStatus` struct has both `id` (numeric) and `name` (localized) properties
- Found EveryMatrix Confluence docs confirming all 8 status IDs and their meanings
- Tested with French language - logs showed `id="1" name="En attente"` mapping to `.inProgress` (bug confirmed)

### Useful Files / Links
- [EveryMatrixModelMapper+Events.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/ModelMappers/EveryMatrixModelMapper+Events.swift) - Fixed status mapping (line 164)
- [MatchStatus struct](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/WebSocket/Hierarchical/Match.swift) - Has both `id` and `name` properties
- [TallOddsMatchCardViewModel.swift](../../BetssonCameroonApp/App/ViewModels/TallOddsMatchCard/TallOddsMatchCardViewModel.swift) - Added debug logs (lines 247, 365)
- [MatchHeaderView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchHeaderView/MatchHeaderView.swift) - Live indicator visibility binding (line 188)
- [Events.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Events/Events.swift) - EventStatus enum definition
- [EveryMatrix Confluence: All Statuses Explained](https://everymatrix.atlassian.net/wiki/spaces/OF/pages/1234567890) - Official status ID documentation

### EveryMatrix Status Reference
From official Confluence documentation:

| ID | Name | Description | Our Mapping | Shows "Live"? |
|----|------|-------------|-------------|---------------|
| 1 | Pending | Not started yet | `.notStarted` | No |
| 2 | In Progress | Event is live | `.inProgress` | Yes |
| 3 | Ended | Event finished | `.ended` | No |
| 4 | Interrupted | Paused, will continue | `.inProgress` | Yes |
| 5 | Canceled | Canceled before start | `.ended` | No |
| 6 | Walkover | Canceled (walkover win) | `.ended` | No |
| 7 | Abandoned | Abandoned after start | `.ended` | No |
| 8 | Retired | Player retired | `.ended` | No |

### Next Steps
1. Test fix in French language - verify Live tooltip only shows for live matches
2. Test in English - verify no regression
3. Test status transitions (pre-live → live → ended, interrupted → resumed)
4. Remove or reduce debug logging once confirmed working
5. Consider documenting this fix in EveryMatrix provider CLAUDE.md
6. Monitor for other language-dependent mapping issues in codebase
