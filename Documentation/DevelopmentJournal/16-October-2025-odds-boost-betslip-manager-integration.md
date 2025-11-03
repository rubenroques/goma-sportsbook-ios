# Odds Boost Stairs - BetslipManager Integration & Model Refactoring

## Date
16 October 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Integrate odds boost stairs API call into BetslipManager (single source of truth for betslip state)
- Create app-level models (not using ServicesProvider models directly)
- Create purpose-specific domain model for odds boost requests (avoid abusing BetTicketSelection)
- Add reactive triggers: ticket changes AND user login state changes
- Publish odds boost state via Combine for UI consumption

### Achievements
- [x] Created app models with pure data (no UI helpers in models)
  - `OddsBoostStairsState`: Current/next tier, ubsWalletId, currency, eligible events
  - `OddsBoostTier`: Min selections, percentage, cap amount
- [x] Created model mapper `ServiceProviderModelMapper+OddsBoost.swift`
  - Maps from `ServicesProvider.OddsBoostStairsResponse` → `OddsBoostStairsState`
- [x] Refactored to purpose-specific selection model in ServicesProvider
  - Created `OddsBoostStairsSelection` with only 2 fields (outcomeId, eventId)
  - Replaced abuse of `BetTicketSelection` (was 90% dummy data)
  - Updated protocol signature in `PrivilegedAccessManager`
  - Updated implementation in `EveryMatrixPrivilegedAccessManager`
- [x] Integrated into BetslipManager with proper encapsulation
  - Private `oddsBoostStairsSubject` for state management
  - Public `oddsBoostStairsPublisher: AnyPublisher` for consumers
  - `fetchOddsBoostStairs()` method with comprehensive logging
- [x] Added reactive triggers for all scenarios:
  - Tickets added/removed (betslip changes)
  - User login (catches "added tickets before login" scenario)
  - User logout (clears odds boost state)
  - Betslip cleared (clears odds boost state)

### Issues / Bugs Hit
- **Initial approach**: Used `BetTicketSelection` with 90% dummy data
  - **Solution**: Created dedicated `OddsBoostStairsSelection` model (2 fields only)
  - **Why**: Semantic clarity, type safety, prevents accidental misuse
- **Missing user login tracking**: Initial implementation only tracked ticket changes
  - **Scenario missed**: User adds tickets while logged out, then logs in
  - **Solution**: Added subscriber to `Env.userSessionStore.userProfileStatusPublisher`
  - **Trigger on**: `.logged` → fetch odds boost, `.anonymous` → clear state

### Key Decisions
- **Models should be pure data**: Removed UI helpers from app models (user's feedback)
  - ViewModels should contain display logic, not models
  - Models: `OddsBoostStairsState`, `OddsBoostTier` (data only)
- **BetslipManager owns the logic**: Not in ViewModel (user's guidance)
  - BetslipManager is single source of truth for betslip state
  - Needed in multiple UI locations ("always on" widgets)
  - Ensures consistent data across all consumers
- **Purpose-specific selection model**: Created `OddsBoostStairsSelection` (user's request)
  - Prevents semantic abuse of `BetTicketSelection` (designed for bet placement)
  - Type safety: Can't accidentally use for wrong purpose
  - Clean code: 2 fields vs 10+ with dummy values
- **Proper encapsulation**: Private subject, public AnyPublisher
  - External consumers can only observe, not mutate
  - Follows existing BetslipManager patterns
- **Track user login state**: Subscribe to `userProfileStatusPublisher`
  - Not `userWalletPublisher` (user's correction)
  - Handles edge case: tickets added before login

### Experiments & Notes
- **EveryMatrix API only needs 2 fields** for odds boost calculation:
  - `outcomeId` (betting offer ID)
  - `eventId` (match ID)
  - All other fields in `BetTicketSelection` were unnecessary
- **User login scenarios tested**:
  1. Logged in user adds tickets → fetches immediately ✅
  2. Anonymous user adds tickets, then logs in → fetches on login ✅
  3. User logs out → clears state ✅
- **Console logging strategy**:
  - `[ODDS_BOOST] 🎁` - Fetch initiated
  - `[ODDS_BOOST] ✅` - Success with tier data
  - `[ODDS_BOOST] 💰` - UBS Wallet ID (critical for bet placement)
  - `[ODDS_BOOST] 📊` - Progress message
  - `[ODDS_BOOST] 🏆` - Max tier reached
  - `[ODDS_BOOST] ⚠️` - Skipped (no tickets/currency)
  - `[ODDS_BOOST] ❌` - API failure
  - `[ODDS_BOOST] 🔐` - User logged in
  - `[ODDS_BOOST] 👋` - User logged out

### Useful Files / Links
- [App Models](../../BetssonCameroonApp/App/Models/Betting/OddsBoostStairs.swift) - Pure data models
- [Model Mapper](../../BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+OddsBoost.swift) - SP → App transformation
- [BetslipManager](../../BetssonCameroonApp/App/Services/BetslipManager.swift) - Integration with reactive triggers
- [SP Domain Model](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/OddsBoost/OddsBoostStairs.swift) - `OddsBoostStairsSelection`
- [SP Protocol](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/PrivilegedAccessManager.swift) - Updated signature
- [EM Implementation](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Managers/EveryMatrixPrivilegedAccessManager.swift) - Clean mapping
- [Previous Session](./16-October-2025-odds-boost-stairs-integration.md) - Initial SP integration

### Next Steps
1. **UI Integration**: Create ViewModels that consume `Env.betslipManager.oddsBoostStairsPublisher`
2. **Widget Development**: Build "always on" widget showing current boost percentage and progress
3. **UX Messaging**: Display "Add X more events to get Y% boost" using published state
4. **Bet Placement**: Store `ubsWalletId` from state and pass to `placeBet()` API
5. **Testing**: Test edge cases (no bonus available, max tier reached, currency not supported)
6. **Performance**: Monitor API call frequency, consider debouncing if needed

### Implementation Pattern Used
**App Architecture Pattern**:
- ServicesProvider domain models → App models (via ServiceProviderModelMapper)
- Manager owns business logic + state
- Publishes state via Combine (private subject, public AnyPublisher)
- ViewModels subscribe and transform for UI

**Reactive Triggers**:
- `bettingTicketsPublisher` changes → fetch odds boost
- `userProfileStatusPublisher` changes → fetch on login, clear on logout
- `clearAllBettingTickets()` → clear odds boost state

### Feature Context
**Business Goal**: Display progressive bonus tiers to motivate users to add more selections to betslip

**User Flow**:
1. User adds 2 selections → Shows "10% boost, add 1 more for 15%"
2. User adds 3rd selection → Shows "15% boost, add 1 more for 20%"
3. User adds 4th selection → Shows "20% boost - maximum reached!"
4. User places bet → Backend applies bonus using `ubsWalletId`

**Edge Cases Handled**:
- User not logged in → Skips fetch, shows nothing
- User logs in after adding tickets → Fetches immediately
- User logs out → Clears state
- No tickets → Clears state
- No bonus available from API → Publishes nil
- Max tier reached → `nextTier` is nil

**How UI Consumes**:
```swift
Env.betslipManager.oddsBoostStairsPublisher
    .combineLatest(Env.betslipManager.bettingTicketsPublisher)
    .sink { oddsBoost, tickets in
        // Update UI with current tier, next tier, progress
    }
```
