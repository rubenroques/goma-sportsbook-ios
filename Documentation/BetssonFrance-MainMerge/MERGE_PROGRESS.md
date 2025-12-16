# BetssonFrance → Main Branch Merge Progress

## Overview

**Goal**: Merge the `betsson-fr-releases` branch into `main` to consolidate both BetssonCameroonApp and BetssonFranceLegacy in a single workspace.

**Start Date**: 14 December 2025

---

## Completed Steps

### 1. Branch Structure Setup
- [x] Created backup branch: `backup-main-before-france-merge`
- [x] Used `git read-tree --prefix=BetssonFranceApp/` to import betsson-fr-releases content
- [x] Renamed `BetssonFranceApp/` → `BetssonFranceLegacy/`
- [x] Renamed Xcode project: `Sportsbook2.xcodeproj` → `BetssonFranceLegacy.xcodeproj`
- [x] Updated `Sportsbook.xcworkspace` to include BetssonFranceLegacy project

### 2. Package Path Fixes
- [x] Fixed package paths in `BetssonFranceLegacy.xcodeproj/project.pbxproj` to point to `../Frameworks/<PackageName>`

### 3. Package Version Conflicts Resolved
- [x] **Firebase SDK**: Upgraded BetssonCameroonApp from 10.0.0 to 12.0.0 (aligned with BetssonFranceLegacy)
- [x] **Optimove SDK**: Upgraded RegisterFlow from 5.0.0 to 6.3.0 (aligned with BetssonFranceLegacy)

### 4. Missing Model Files Added
- [x] `Models/WheelBoost/WheelEligibility.swift` - Contains WheelEligibility, WheelStatus, WheelConfiguration, WheelTier, WheelOptInData, WheelAwardedTier, GrantedWinBoosts, GrantedWinBoostInfo
- [x] `Models/Content/HomeWidgets/PromotionalBanner.swift` - PromotionalBanner, PromotionalBannersResponse, BannerSpecialAction
- [x] `Models/RecommendedBetBuilders.swift` - RecommendedBetBuilders, RecommendedBetBuilder, RecommendedBetBuilderSelection
- [x] `Models/Betting/Bonus/GrantedBonus.swift` - Updated with FreeBetBonus type
- [x] `Models/Betting/Bonus/AvailableBonus.swift` - Updated with AdditionalAward type
- [x] `Models/User/User.swift` - Added ExternalFreeBetBalance struct

### 5. Client.swift Merge
- [x] Manual 3-way merge of `ServicesProvider/Client.swift` completed (using kdiff3 or manual editing)

---

## Session 2 Progress (14 Dec 2025 continued)

### Fixed in This Session
- [x] `Score.gamePart` - Added `index: nil` parameter
- [x] `EventStatus.ended` - Added `"ended"` string parameter
- [x] `Market` - Added default `nil` for `marketTypeName` parameter
- [x] `SportType` - Added defaults `hasMatches: Bool = true, hasOutrights: Bool = true`
- [x] `SportRadarModelMapper+Events` - Added missing Event init parameters (homeTeamLogoUrl, awayTeamLogoUrl, boostedMarket, promoImageURL)
- [x] `Betting.swift` - Added `sportTypeName` computed property to BetSelection, added `detailedCode` to PlacedBetsResponse

---

## Remaining Work (72 errors, ~15 unique issues)

### Category 1: ServiceProviderError.notImplemented (35+ occurrences)
**File**: `SportRadarPrivilegedAccessManager.swift` lines 185, 1593-1755
**Issue**: `ServiceProviderError` has no member `notImplemented`
**Fix**: Add `.notImplemented` case to `ServiceProviderError` enum OR replace with existing error case

### Category 2: SportRadar Mapper Issues

#### SportRadarModelMapper+Events.swift
- Line 205: `[Banner]` vs `[EventBanner]` type mismatch
- Line 209: Extra arguments / missing `from` parameter in EventBanner init

#### SportRadarModelMapper+User.swift
- Line 148: Extra argument `externalFreeBetBalances` in UserWallet call
- Line 159: Type mismatch `Double?` vs `String?`

### Category 3: SportRadarEventsProvider.swift
- Line 992, 2354, 2403: Missing argument for parameter `loaded` in call
- Line 1575: Optional unwrapping needed for `markets` access
- Line 1843: Missing Event init parameters (homeTeamLogoUrl, etc.)

### Category 4: Protocol Conformance
- `SportRadarBettingProvider` does not conform to `BettingProvider`
- `SportRadarEventsProvider` does not conform to `EventsProvider`
- (These will resolve once other errors are fixed)

### Category 5: Missing Members
- `SportRadarManagedContentProvider.swift:418` - `customRequest` method not found on `SportRadarEventsProvider`

---

## Previously Documented Remaining Work (for reference)

#### Event Model (`Models/Events/Core/Event.swift`)
Missing initializer parameters:
- `homeTeamLogoUrl: String?`
- `awayTeamLogoUrl: String?`
- `boostedMarket: Market?`
- `promoImageURL: String?`

#### SportType Model (`Models/Events/Sports/SportType.swift`)
Missing initializer parameters:
- `hasMatches: Bool`
- `hasOutrights: Bool`

#### Bet Model (`Models/Betting/Betting.swift`)
Missing initializer parameter:
- `currency: String`

#### BetSelection Model (`Models/Betting/Betting.swift`)
Parameter type mismatch:
- Current: `sportType: SportType`
- Expected by SportRadar: `sportTypeName: String`

#### PlacedBetsResponse Model
Different initializer signature:
- Current: `identifier:bets:detailedBets:requiredConfirmation:totalStake:`
- Expected: `identifier:detailedCode:bets:totalStake:`

#### Score Model (`Models/Events/Core/Event.swift` or similar)
Missing parameter in `Score.gamePart`:
- `index: Int`

#### EventStatus Enum
Type issue - returning function instead of value

#### Market Model
Missing parameter:
- `marketTypeName: String?`

#### Banner vs EventBanner
Type mismatch - needs investigation

### Medium Priority - Protocol Conformance

#### SportRadarPrivilegedAccessManager
- Cannot find type `PrivilegedAccessManager` in scope
- May need protocol import or definition

#### SportRadarBettingProvider
- Does not conform to `BettingProvider` protocol (due to missing model types)

#### SportRadarEventsProvider
- Does not conform to `EventsProvider` protocol (due to missing model types)
- Missing `customRequest` method

### Low Priority - EveryMatrix Mapper Updates

#### EveryMatrixModelMapper+Bonus.swift
- Extra arguments in calls - needs signature alignment with new Bonus models

---

## Proposed Solutions

### Option A: Full ServicesProvider Replacement (Recommended for Quick Fix)
1. Replace entire `Frameworks/ServicesProvider/` with betsson-fr-releases version
2. Re-apply Client.swift manual merge
3. Test both BetssonCameroonApp and BetssonFranceLegacy builds

**Pros**: Complete and consistent
**Cons**: May break BetssonCameroonApp if models diverged significantly

### Option B: Model-by-Model Alignment
1. Update each domain model to include all properties from both branches
2. Make new properties optional with defaults where appropriate
3. Update mappers as needed

**Pros**: Preserves both codebases' requirements
**Cons**: Time-consuming, error-prone

### Option C: Disable SportRadar Provider Temporarily
1. Exclude SportRadar provider files from build
2. Focus on EveryMatrix-only for initial merge
3. Re-enable and fix SportRadar later

**Pros**: Quick path to working build
**Cons**: SportRadar schemes won't work

---

## File Locations Reference

| Component | Location |
|-----------|----------|
| Workspace | `Sportsbook.xcworkspace` |
| BetssonCameroonApp | `BetssonCameroonApp/BetssonCameroonApp.xcodeproj` |
| BetssonFranceLegacy | `BetssonFranceLegacy/BetssonFranceLegacy.xcodeproj` |
| ServicesProvider | `Frameworks/ServicesProvider/` |
| RegisterFlow | `Frameworks/RegisterFlow/` |
| GomaUI | `Frameworks/GomaUI/` |
| betsson-fr worktree | `/Users/rroques/Desktop/GOMA/iOS/betssonfrance-git-worktree` |
| Backup branch | `backup-main-before-france-merge` |

---

## Git Status Summary

As of last check:
- ~1,651 files deleted (old BetssonFranceApp)
- ~336 files added (new BetssonFranceLegacy)
- Several files modified (workspace config, package versions)
- `Frameworks/ServicesProvider/` is partially untracked (needs `git add`)

---

---

## Session 5 Progress (15 Dec 2025)

### Major Progress: Protocol Conformance Fixed

#### SportRadarBettingProvider
- [x] Fixed 3 method signature mismatches (`placeBets`, `confirmBoostedBet`, `placeBetBuilderBet`)
- [x] Added 9 stub methods returning `.notSupportedForProvider`

#### SportRadarEventsProvider
- [x] Fixed 2 method signature mismatches (`getMarketGroups`, `getHighlightedLiveEvents`)
- [x] Added 35+ stub methods returning `.notSupportedForProvider`

#### Wheel/WinBoost Methods (BetssonFrance-specific)
- [x] Added protocol methods to `PrivilegedAccessManagerProvider`
- [x] Added public methods to `Client.swift`
- [x] Added stubs to `EveryMatrixPAMProvider` and `GomaProvider`
- [x] `SportRadarPrivilegedAccessManager` already had implementations

### Remaining Issues

1. **Events Type Issue**: `Events(events: validEvents)` should just be `validEvents` (Events is a typealias for `[Event]`)
2. **Missing SDKs**: TwintSDK, IdensicMobileSDK, AdjustSdk still blocking BetssonFranceLegacy

### Current Build Status

| Target | Status |
|--------|--------|
| ServicesProvider | Nearly compiles (1 type issue) |
| RegisterFlow | Blocked by ServicesProvider |
| BetssonFranceLegacy | Blocked by ServicesProvider + missing SDKs |
| BetssonCameroonApp | Should still work (needs verification) |

---

## Session 6 Progress (15 Dec 2025) - BUILD SUCCESS!

### Major Milestone: "Betsson PROD" Scheme Builds Successfully

#### Method Signature Fixes (Client.swift Overloads)
- [x] Added `getEventSummary(eventId:)` overload (without marketLimit)
- [x] Added `getMarketGroups(forPreLiveEvent:)` overload
- [x] Added `getMarketGroups(forLiveEvent:)` overload
- [x] Added `getMarketGroups(forEvent:)` single-param overload
- [x] Added `placeBetBuilderBet(betTicket:calculatedOdd:useFreebetBalance:)` overload
- [x] Added `confirmBoostedBet(identifier:detailedCode:)` overload
- [x] Added `contactSupport(userIdentifier:firstName:...)` convenience overload

#### Model & Call Site Fixes
- [x] Fixed `BetGroupingType.system` calls - added `numberOfBets` parameter
- [x] Fixed `Score.gamePart` - added `index` parameter to local enum and mapper
- [x] Fixed `MatchDetailsViewModel` flatMap return type
- [x] Migrated `simpleSignUp(form:)` → `signUp(with: .simple(form))`
- [x] Renamed `getEventsForEventGroup` → `getEventGroup` calls

#### Client.swift Bug Fix
- [x] Added missing `getHomeSliders()` method
- [x] Fixed `getCashbackSuccessBanner()` to call correct provider method

### Final Build Status

| Scheme | Status |
|--------|--------|
| **Betsson PROD** | **BUILD SUCCEEDED** |
| ServicesProvider | Compiles |
| RegisterFlow | Compiles |

---

## Remaining Tasks

- [ ] Verify BetssonCameroonApp still builds (regression check)
- [ ] Test other BetssonFranceLegacy schemes (Betsson UAT, Demo, etc.)
- [ ] Stage all changes with `git add -A`
- [ ] Create commit for merge
