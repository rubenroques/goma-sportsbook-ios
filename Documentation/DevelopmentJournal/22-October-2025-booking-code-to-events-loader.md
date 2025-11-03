# Development Journal Entry

## Date
22 October 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Understand existing booking code infrastructure (create + retrieve)
- Add method to convert booking codes to full Event objects for betslip population
- Implement in EventsProvider protocol (proper architecture layer)

### Achievements
- [x] Analyzed existing booking code system (create + retrieve APIs already implemented)
- [x] Identified the missing gap: booking code → Events conversion
- [x] Added `loadEventsFromBookingCode` to EventsProvider protocol (line 139)
- [x] Implemented full logic in EveryMatrixProvider using flatMap + parallel fetch pattern (line 822)
- [x] Added stub implementations for GomaProvider and SportRadarEventsProvider
- [x] Exposed public API in Client.swift (line 918)
- [x] Leveraged both existing APIs: `getBettingOfferIds` + `getEventWithSingleOutcome`

### Issues / Bugs Hit
- None - smooth implementation following established patterns

### Key Decisions
- **Placed in EventsProvider instead of Client**:
  - Events data retrieval is EventsProvider's responsibility
  - Different providers can implement differently (batch APIs vs parallel fetch)
  - Follows existing ServicesProvider architecture pattern
  - Client remains thin coordinator layer

- **Parallel fetch strategy**:
  - Uses `Publishers.MergeMany` to fetch all Events concurrently
  - Faster than sequential fetching for multiple betting offers
  - Collects results into array with `.collect()`

- **Two-step approach**:
  1. `getBettingOfferIds(bookingCode:)` → `["id1", "id2", "id3"]`
  2. `getEventWithSingleOutcome(id)` for each ID (parallel)
  - Could be optimized with batch API in future, but parallel works well

### Experiments & Notes
- **Data Flow**:
  ```
  Booking Code "7YRLO2UQ"
      ↓
  PrivilegedAccessManager.getBettingOfferIds()
      ↓
  ["283682027195084800", "283682211352619520"]
      ↓
  EventsProvider.getEventWithSingleOutcome() x2 (parallel)
      ↓
  [Event, Event]
      ↓
  Add to betslip
  ```

- **Publishers.MergeMany Pattern**:
  ```swift
  let eventPublishers = bettingOfferIds.map { id in
      self.getEventWithSingleOutcome(bettingOfferId: id)
  }
  return Publishers.MergeMany(eventPublishers).collect()
  ```
  Executes all publishers concurrently and collects results

### Useful Files / Links
- [EventsProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/EventsProvider.swift) - Line 139 (protocol method)
- [EveryMatrixProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixProvider.swift) - Line 822 (full implementation)
- [Client.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift) - Line 918 (public API)
- [GomaProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Goma/GomaProvider.swift) - Line 1346 (stub)
- [SportRadarEventsProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/SportRadarEventsProvider.swift) - Line 1339 (stub)
- [BettingOfferBooking.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/BettingOfferBooking.swift) - Booking code models
- [15-October-2025-booking-code-integration.md](15-October-2025-booking-code-integration.md) - Original booking code creation implementation

### Architecture Notes

**Booking Code Complete Flow**:

**Create Flow** (when user shares):
```
Place bet → Get betting offer IDs
    ↓
createBookingCode(bettingOfferIds: [String])
    ↓
POST /v2/sports/bets/book
    ↓
BookingCodeResponse { code: "7YRLO2UQ" }
```

**Retrieve Flow** (when user receives):
```
Booking code "7YRLO2UQ"
    ↓
loadEventsFromBookingCode(bookingCode: String)  ← NEW METHOD
    ↓
Step 1: getBettingOfferIds(bookingCode)
    → GET /v2/sports/bets/book/{code}
    → ["283682027195084800", "283682211352619520"]
    ↓
Step 2: getEventWithSingleOutcome(id) for each ID (parallel)
    → RPC /sports#initialDump (multiple calls)
    → [Event, Event]
    ↓
Add to betslip
```

**Why Two Steps Instead of One API Call?**
- Backend returns only betting offer IDs (lightweight)
- Events data comes from sports data system (separate concern)
- Allows frontend to decide what to do with IDs (display, validate, fetch)
- Current odds fetched at retrieval time (not stale shared odds)

**Provider Architecture**:
- ✅ EventsProvider: Responsible for events data (correct layer)
- ✅ PrivilegedAccessManager: Responsible for booking code storage/retrieval
- ✅ Client: Thin wrapper exposing provider methods
- ❌ NOT in Client directly: Would violate separation of concerns

### Code Snippet

**Usage Example**:
```swift
// ViewModel handling booking code deep link
func handleBookingCode(_ code: String) {
    servicesProvider.loadEventsFromBookingCode(bookingCode: code)
        .receive(on: DispatchQueue.main)
        .sink { completion in
            if case .failure(let error) = completion {
                self.showError("Failed to load booking code: \(error.localizedDescription)")
            }
        } receiveValue: { events in
            // Add all events to betslip
            for event in events {
                self.betslipManager.addSelection(from: event)
            }
            self.showSuccess("Loaded \(events.count) selections")
        }
        .store(in: &cancellables)
}
```

### Next Steps
1. Integrate into URLSchemaManager to handle booking code deep links
2. Add method to BetslipCoordinator for loading booking code into betslip
3. Test end-to-end: Create code on device A → Open on device B → Verify betslip populated
4. Consider adding progress indicator for loading multiple events (future enhancement)
5. Add analytics tracking for booking code usage (shared vs received)
6. Consider batch fetch optimization if performance becomes concern (unlikely with <10 selections)

### Session Context

This session builds on the morning's work where we added `getEventWithSingleOutcome(bettingOfferId:)` RPC method. That new method is now the building block for this booking code loader, demonstrating good incremental API design - small focused methods that compose into powerful features.
