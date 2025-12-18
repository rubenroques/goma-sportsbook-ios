# Cashout Feature - Handoff Document for Next LLM Instance

## Current State Summary

**Branch**: `single_code`
**Build Status**: Compiles successfully (BetssonCM UAT scheme)

### What's DONE

#### Phase 1-3: Infrastructure (COMPLETE)
SSE endpoint updated from deprecated to new format:
- **OLD (broken)**: `GET /cashout/v1/cashout-value/{betId}` → Returns 503
- **NEW (working)**: `POST /bets-api/v1/{operatorId}/cashout-value-updates` with body `{"betIds": [...]}`

Files modified:
1. `Frameworks/ServicesProvider/.../Connectors/EveryMatrixSSEConnector.swift`
   - Added `method` and `body` parameters to `createEventSource()`
   - Config now uses `endpoint.method.value()` and `endpoint.body`

2. `Frameworks/ServicesProvider/.../APIs/OddsMatrixWebAPI/EveryMatrixOddsMatrixWebAPI.swift`
   - Changed enum: `getCashoutValueSSE(betId: String)` → `getCashoutValueSSE(betIds: [String])`
   - Updated endpoint path, headers (Content-Type, lowercase x-session-id/x-user-id), method (POST), and body encoding

3. `Frameworks/ServicesProvider/.../EveryMatrixBettingProvider.swift`
   - Updated `subscribeToCashoutValue` to use `getCashoutValueSSE(betIds: [betId])`

#### Phase 4.1: Static Cashout Data (COMPLETE)
File: `BetssonCameroonApp/App/Screens/MyBets/ViewModels/TicketBetInfoViewModel.swift`

```swift
private static func createTicketBetInfoData(from myBet: MyBet, overrideCashoutValue: Double? = nil) -> TicketBetInfoData {
    // Use override value (from SSE) if provided, otherwise use API value
    let cashoutAmount = overrideCashoutValue ?? myBet.partialCashoutReturn

    // Format cashout values only if bet can be cashed out
    let partialCashoutValue: String? = myBet.canCashOut ? cashoutAmount.map { formatCurrency($0, currency: myBet.currency) } : nil
    let cashoutTotalAmount: String? = myBet.canCashOut ? cashoutAmount.map { formatCurrency($0, currency: myBet.currency) } : nil
    // ... rest of TicketBetInfoData creation
}
```

#### Phase 4.2-4.3: ViewModel Caching (COMPLETE)
New file: `BetssonCameroonApp/App/Screens/MyBets/Cache/TicketBetInfoViewModelCache.swift`
- LRU cache with max 20 entries
- Thread-safe (concurrent DispatchQueue)
- Methods: `get(forBetId:)`, `set(_:forBetId:)`, `invalidate(forBetId:)`, `invalidateAll()`

Integrated in `MyBetsViewModel.swift`:
- Cache used in `createTicketViewModels(from:)`
- Cache invalidated on logout (security)

---

## What's REMAINING

### 4.4 Add SSE Subscription to TicketBetInfoViewModel

**File**: `BetssonCameroonApp/App/Screens/MyBets/ViewModels/TicketBetInfoViewModel.swift`

Add these properties and methods:

```swift
final class TicketBetInfoViewModel: TicketBetInfoViewModelProtocol {
    // ADD these properties:
    private var sseSubscription: AnyCancellable?
    private let cashoutValueSubject = CurrentValueSubject<Double?, Never>(nil)

    init(myBet: MyBet, servicesProvider: ServicesProvider.Client) {
        // ... existing init code ...

        // ADD: Subscribe to SSE if cashout available
        if myBet.canCashOut {
            subscribeToCashoutUpdates()
        }
    }

    // ADD deinit:
    deinit {
        sseSubscription?.cancel()
    }

    // ADD this method:
    private func subscribeToCashoutUpdates() {
        sseSubscription = servicesProvider.subscribeToCashoutValue(betId: myBet.identifier)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("Cashout SSE error for bet \(self?.myBet.identifier ?? ""): \(error)")
                    }
                },
                receiveValue: { [weak self] content in
                    switch content {
                    case .connected:
                        print("Cashout SSE connected for bet \(self?.myBet.identifier ?? "")")
                    case .contentUpdate(let cashoutValue):
                        self?.handleCashoutUpdate(cashoutValue)
                    case .disconnected:
                        print("Cashout SSE disconnected")
                    }
                }
            )
    }

    // ADD this method:
    private func handleCashoutUpdate(_ cashoutValue: CashoutValue) {
        cashoutValueSubject.send(cashoutValue.cashoutAmount)

        // Rebuild TicketBetInfoData with new cashout value
        let updatedData = Self.createTicketBetInfoData(
            from: myBet,
            overrideCashoutValue: cashoutValue.cashoutAmount
        )
        betInfoSubject.send(updatedData)
    }
}
```

**Note**: The `overrideCashoutValue` parameter already exists in `createTicketBetInfoData` - we added it in Phase 4.1.

### 4.5 Wire Slider Calculations

**Business Logic from Web/Android**:

```swift
// Formula for partial cashout value:
let partialCashoutValue = (fullCashoutValue * sliderAmount) / totalRemainingStake

// Slider bounds:
let minValue: Float = 0.1  // Minimum 0.1 currency units
let maxValue: Float = bet.betRemainingStake ?? bet.stake

// Initial position (80% of max):
let initialPosition = maxValue * 0.8

// Full vs Partial determination:
let isFullCashout = sliderAmount >= (remainingStake - 0.01)
```

**GomaUI Component**: `CashoutSliderView` already exists in GomaUI. Currently `TicketBetInfoView` creates Mock ViewModels internally (lines 485-530). Need to:
1. Pass real `CashoutSliderViewModelProtocol` from TicketBetInfoViewModel
2. Wire slider value changes to recalculate partial cashout amount
3. Update displayed cashout value as slider moves

### 4.6 Add Cashout State Machine

```swift
enum CashoutState {
    case slider       // Default - user can interact
    case loading      // API call in progress
    case success      // Full cashout succeeded → Remove bet from list
    case partialSuccess // Partial cashout succeeded → Reload bet data
    case failed(Error)  // Show error with Retry button
}
```

**State Transitions**:
- `slider` → (user taps cashout) → `loading`
- `loading` → (API success, full) → `success` → remove bet from list
- `loading` → (API success, partial) → `partialSuccess` → reload bets
- `loading` → (API failure) → `failed` → show retry

**Cashout Execution API** (already exists in ServicesProvider):
```swift
servicesProvider.executeCashout(request: CashoutRequest) -> AnyPublisher<CashoutResponse, ServiceProviderError>
```

Where `CashoutRequest` contains:
- `betId: String`
- `cashoutValue: Double`
- `cashoutType: String` ("FULL" or "PARTIAL")
- `partialCashoutStake: Double?` (only for partial)

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `EveryMatrixSSEConnector.swift` | SSE connection with POST/body support |
| `EveryMatrixOddsMatrixWebAPI.swift` | Endpoint definitions |
| `EveryMatrixBettingProvider.swift` | `subscribeToCashoutValue` method |
| `TicketBetInfoViewModel.swift` | Per-bet ViewModel (add SSE subscription here) |
| `TicketBetInfoViewModelCache.swift` | LRU cache (already implemented) |
| `MyBetsViewModel.swift` | Uses cache, handles cashout tap |
| `TicketBetInfoView.swift` (GomaUI) | UI component showing cashout slider |
| `CashoutSliderView.swift` (GomaUI) | Slider component |
| `CashoutAmountView.swift` (GomaUI) | Amount display component |

---

## SSE Message Format

The SSE endpoint returns messages like:
```json
{
  "messageType": "CASHOUT_VALUE",
  "betId": "abc-123",
  "cashoutValue": 45.50,
  "partialCashOutEnabled": true,
  "details": {
    "code": 100,
    "message": "Success"
  }
}
```

**Filtering Rules**:
- Only process `messageType == "CASHOUT_VALUE"`
- Only process `details.code == 100` (success)
- Ignore `code == 103` (temporary "odds not found" state)

This filtering is already implemented in `EveryMatrixBettingProvider.subscribeToCashoutValue`.

---

## MyBet Model (Relevant Properties)

```swift
struct MyBet {
    let identifier: String
    let partialCashoutReturn: Double?  // Full cashout amount from API
    let partialCashoutStake: Double?   // Remaining stake
    let stake: Double
    let currency: String

    var canCashOut: Bool {
        return state == .opened && partialCashoutReturn != nil && partialCashoutReturn! > 0
    }
}
```

---

## Plan File Location

Full implementation plan with code snippets:
`~/.claude/plans/foamy-wondering-lamport.md`

---

## Build Command

```bash
cd /Users/rroques/Desktop/GOMA/iOS/sportsbook-ios
xcodebuild -workspace Sportsbook.xcworkspace -scheme "BetssonCM UAT" -destination 'platform=iOS Simulator,id=4C2C3F29-3F1E-4BEC-A397-C5A54256ADC7' build 2>&1 | xcbeautify --quieter
```

---

## Test Credentials

For testing with real bet:
- Phone: `+237650888006`
- Password: `4050`
- Environment: PROD

---

## Cache Invalidation Rules (Already Implemented)

| Event | Action |
|-------|--------|
| Full cashout success | `viewModelCache.invalidate(forBetId:)` |
| Logout | `viewModelCache.invalidateAll()` |
| Tab switch | Keep cache |
| Pull-to-refresh | Keep cache, update data |
