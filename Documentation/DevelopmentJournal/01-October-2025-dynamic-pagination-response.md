## Date
01 October 2025

### Project / Branch
sportsbook-ios / rr/bettingOfferSubscription

### Goals for this session
- Make pagination Load More button dynamic based on actual server response
- Change `loadNextPage()` to wait for WAMP data before returning boolean
- Eliminate hardcoded `Just(true)` responses that don't reflect actual data availability
- Ensure Load More button hides automatically when reaching end of data

### Achievements
- [x] Added `paginationResponseSubject: PassthroughSubject<Bool, ServiceProviderError>?` to both paginators
- [x] Refactored `loadNextPage()` to create PassthroughSubject and return it (instead of `Just(true)`)
- [x] Updated `handleSubscriptionContent()` to emit pagination response when data arrives
- [x] Added error handling: WAMP errors now propagate through pagination subject
- [x] Implemented duplicate request cancellation: prevents race conditions
- [x] Applied identical changes to both PreLiveMatchesPaginator and LiveMatchesPaginator
- [x] Verified ViewModels already handle boolean response correctly (no changes needed)

### Issues / Bugs Hit
- **User clarification needed**: Example "receives 10 events (requested 20)" seemed like typo
  - **Clarification**: Actually correct! When server has only 10 total events:
    - Request eventLimit=10 → receive 10 (might have more)
    - Request eventLimit=20 → receive 10 (end of data: 10 < 20)
  - Detection logic: `matchCount < currentEventLimit` catches this case

### Key Decisions
- **Wait for actual data before responding**: Changed from synchronous `Just(true)` to asynchronous `PassthroughSubject`
  - **Before**: `loadNextPage()` returns immediately → ViewModel doesn't know if there's actually more data
  - **After**: `loadNextPage()` returns Publisher that emits when data arrives → accurate boolean based on server response
- **Single source of truth**: Paginator's `hasMoreEvents` state (set by `matchCount < currentEventLimit`) is now the definitive answer
  - ViewModel receives this exact state through the Publisher
  - No need for ViewModel to poll `canLoadMore()` later
- **Error propagation**: If WAMP subscription fails, error flows through pagination subject to ViewModel
  - ViewModel's `sink receiveCompletion` handles failures
  - Sets `isLoadingMore = false` to reset UI state
- **Cancel previous requests**: If `loadNextPage()` called while already waiting, cancel previous subject
  - Prevents multiple pending pagination requests
  - Latest request always wins

### Architecture Notes

#### New Pagination Flow
```
User taps Load More
  ↓
ViewController.onLoadMoreTapped
  ↓
ViewModel.loadNextPage()
  ↓ isLoadingMore = true
  ↓
Paginator.loadNextPage()
  ↓ creates PassthroughSubject<Bool, ServiceProviderError>
  ↓ stores it in paginationResponseSubject
  ↓ starts WAMP subscription with new eventLimit
  ↓ returns subject.eraseToAnyPublisher()
  ↓
ViewModel waits on Publisher...
  ↓
[WAMP data arrives]
  ↓
Paginator.handleSubscriptionContent(.initialContent)
  ↓ parses data
  ↓ checks: matchCount < currentEventLimit?
  ↓   YES → hasMoreEvents = false
  ↓   NO  → hasMoreEvents = true
  ↓ emits paginationSubject.send(hasMoreEvents)
  ↓ emits paginationSubject.send(completion: .finished)
  ↓
ViewModel receives boolean in sink receiveValue
  ↓ if true: keeps waiting for processMatches()
  ↓ if false: sets hasMoreEvents = false → button hides
  ↓
UI updates automatically via @Published property
```

#### PassthroughSubject Pattern
**Problem**: Need to return response that depends on async WAMP data

**Solution**: Two-phase Publisher pattern
1. **Phase 1**: Create PassthroughSubject, return it immediately as AnyPublisher
2. **Phase 2**: When data arrives, emit through subject and complete

**Benefits**:
- Caller receives Publisher immediately (no blocking)
- Publisher emits when actual data arrives (accurate response)
- Supports error handling through completion
- Supports cancellation (cancel subject if new request comes)

**Example**:
```swift
// In loadNextPage()
let responseSubject = PassthroughSubject<Bool, ServiceProviderError>()
paginationResponseSubject = responseSubject
startInternalSubscription()
return responseSubject.eraseToAnyPublisher()

// Later, in handleSubscriptionContent()
if let subject = paginationResponseSubject {
    subject.send(hasMoreEvents)  // Emit value
    subject.send(completion: .finished)  // Complete
    paginationResponseSubject = nil
}
```

### Experiments & Notes
- **End-of-data detection unchanged**: Still using `matchCount < currentEventLimit` logic
  - Example: Request 20, receive 10 → 10 < 20 → `hasMoreEvents = false`
  - This detection now directly feeds the pagination response
- **ViewModel already compatible**: NextUpEventsViewModel and InPlayEventsViewModel already had correct logic:
  ```swift
  receiveValue: { [weak self] success in
      if success {
          print("✅ Pagination started - waiting for data")
      } else {
          self?.hasMoreEvents = false  // Hide button
      }
  }
  ```
  - No changes needed in ViewModels!
- **Error handling chain**: WAMP error → pagination subject error → ViewModel sink completion → reset loading state
- **Race condition prevention**: Cancel previous `paginationResponseSubject` before creating new one

### Useful Files / Links
- [PreLiveMatchesPaginator.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/SubscriptionManagers/PreLiveMatchesPaginator.swift) - Lines 61 (subject property), 178-231 (loadNextPage), 373-378 (emit response), 129-133 (error handling)
- [LiveMatchesPaginator.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/SubscriptionManagers/LiveMatchesPaginator.swift) - Lines 53 (subject property), 174-227 (loadNextPage), 374-379 (emit response), 123-127 (error handling)
- [NextUpEventsViewModel.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/NextUpEventsViewModel.swift) - Lines 264-273 (already handles boolean correctly)
- [InPlayEventsViewModel.swift](../../BetssonCameroonApp/App/Screens/InPlayEvents/InPlayEventsViewModel.swift) - Lines 290-299 (already handles boolean correctly)

### Previous Session Reference
- [01-October-2025-live-events-pagination-implementation.md](./01-October-2025-live-events-pagination-implementation.md) - Initial pagination implementation (hardcoded `Just(true)`)

### Next Steps
1. **Test in simulator**: Verify Load More button hides after reaching last page
2. **Test error cases**: Simulate WAMP connection failure during pagination
3. **Test race conditions**: Rapidly tap Load More button multiple times
4. **Edge case testing**:
   - Server has exactly 10/20/30 events (matchCount == currentEventLimit)
   - Server has 0 events on initial load
   - Server has fewer events than initial limit (e.g., 5 events with limit=10)
5. **Performance testing**: Check if PassthroughSubject introduces any memory leaks
6. **Consider adding timeout**: If WAMP response takes too long, should we timeout the pagination subject?
7. **Analytics**: Track how many users reach the end of pagination vs stop mid-scroll
8. **UI polish**: Add subtle animation when Load More button disappears
