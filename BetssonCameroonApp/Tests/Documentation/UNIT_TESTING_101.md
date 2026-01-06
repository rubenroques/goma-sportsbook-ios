# Unit Testing 101: Protocol Witness Pattern

This guide explains our approach to unit testing ViewModels using the **Protocol Witness** pattern (popularized by pointfree.co). This pattern enables true unit testing by replacing protocol-based mocking with struct-based dependency injection.

## Table of Contents

1. [The Problem](#the-problem)
2. [The Solution: Protocol Witness](#the-solution-protocol-witness)
3. [Creating a Service Struct](#creating-a-service-struct)
4. [Using Fixtures](#using-fixtures)
5. [Common Testing Patterns](#common-testing-patterns)
6. [Quick Reference](#quick-reference)

---

## The Problem

Traditional dependency injection uses protocols + mock classes:

```swift
// ❌ Traditional approach - requires a new class per test scenario
protocol CashoutServiceProtocol {
    func subscribeToCashoutValue(betId: String) -> AnyPublisher<...>
    func executeCashout(request: CashoutRequest) -> AnyPublisher<...>
}

class MockCashoutService: CashoutServiceProtocol {
    var stubbedSubscribeResult: AnyPublisher<...>?
    var stubbedExecuteResult: AnyPublisher<...>?

    func subscribeToCashoutValue(betId: String) -> AnyPublisher<...> {
        return stubbedSubscribeResult ?? Empty().eraseToAnyPublisher()
    }
    // ... more boilerplate
}
```

Problems with this approach:
- **Boilerplate**: Every new mock requires a new class
- **Limited flexibility**: Hard to change behavior mid-test
- **Coupling**: Mock behavior is defined in the class, not the test

---

## The Solution: Protocol Witness

Instead of protocols, we use **structs with closure properties**:

```swift
// ✅ Protocol Witness pattern - configure behavior inline
struct CashoutService {
    var subscribeToCashoutValue: (String) -> AnyPublisher<SubscribableContent<CashoutValue>, ServiceProviderError>
    var executeCashout: (CashoutRequest) -> AnyPublisher<CashoutResponse, ServiceProviderError>
}
```

Each function in the struct is a "morphism" - a transformation from input to output. In tests, you provide these transformations directly as closures.

### Benefits

1. **No mock classes**: Configure any behavior inline in the test
2. **Mathematically composable**: Each function is independent
3. **Explicit dependencies**: The struct declares exactly what the ViewModel needs
4. **Per-test configuration**: Different behavior for each test without new classes

---

## Creating a Service Struct

### Step 1: Define the Struct

Create a struct with closure properties matching what the ViewModel needs:

```swift
// File: App/Services/Cashout/CashoutService.swift

import Combine
import ServicesProvider

struct CashoutService {
    // Each property is a closure representing one capability
    var subscribeToCashoutValue: (String) -> AnyPublisher<SubscribableContent<CashoutValue>, ServiceProviderError>
    var executeCashout: (CashoutRequest) -> AnyPublisher<CashoutResponse, ServiceProviderError>
}
```

### Step 2: Add Factory Methods

```swift
extension CashoutService {

    /// Production: wraps the real ServicesProvider.Client
    static func live(client: ServicesProvider.Client) -> Self {
        .init(
            subscribeToCashoutValue: client.subscribeToCashoutValue,
            executeCashout: client.executeCashout
        )
    }

    /// Test: operations never complete (for testing loading states)
    static var noop: Self {
        .init(
            subscribeToCashoutValue: { _ in Empty(completeImmediately: false).eraseToAnyPublisher() },
            executeCashout: { _ in Empty(completeImmediately: false).eraseToAnyPublisher() }
        )
    }

    /// Test: all operations fail immediately
    static func failing(error: ServiceProviderError = .unknown) -> Self {
        .init(
            subscribeToCashoutValue: { _ in Fail(error: error).eraseToAnyPublisher() },
            executeCashout: { _ in Fail(error: error).eraseToAnyPublisher() }
        )
    }
}
```

### Step 3: Update the ViewModel

```swift
class TicketBetInfoViewModel {
    private let cashoutService: CashoutService  // ✅ Use struct, not protocol

    init(myBet: MyBet, cashoutService: CashoutService) {
        self.cashoutService = cashoutService
        // ...
    }

    // Backward-compatible factory for production code
    static func create(from myBet: MyBet, servicesProvider: ServicesProvider.Client) -> TicketBetInfoViewModel {
        return TicketBetInfoViewModel(myBet: myBet, cashoutService: .live(client: servicesProvider))
    }
}
```

---

## Using Fixtures

Fixtures are static factory methods on model types that create test data with sensible defaults.

### Why Fixtures?

```swift
// ❌ Without fixtures - verbose, hard to read
let bet = MyBet(
    identifier: "test",
    type: "single",
    state: .opened,
    result: .open,
    globalState: .opened,
    stake: 10.0,
    totalOdd: 2.5,
    // ... 15 more properties
)

// ✅ With fixtures - concise, only specify what matters
let bet = MyBet.activeBetWithCashout(identifier: "test")
```

### Creating Fixtures

```swift
// File: Tests/Fixtures/MyBetTestFixtures.swift

extension MyBet {
    /// Active bet eligible for cashout
    static func activeBetWithCashout(
        identifier: String = "bet-123",
        stake: Double = 10.0,
        cashoutValue: Double = 50.0
    ) -> MyBet {
        MyBet(
            identifier: identifier,
            type: "single",
            state: .opened,
            result: .open,
            // ... sensible defaults for all properties
            partialCashoutReturn: cashoutValue,
            partialCashoutStake: stake
        )
    }

    /// Settled bet (won) - not eligible for cashout
    static var settledWon: MyBet {
        MyBet(
            identifier: "bet-settled",
            state: .won,
            result: .won,
            // ...
        )
    }
}
```

### Available Fixtures

| Type | Fixture | Description |
|------|---------|-------------|
| `MyBet` | `.activeBetWithCashout(...)` | Open bet eligible for cashout |
| `MyBet` | `.activeBetNoCashout()` | Open bet, no cashout value yet |
| `MyBet` | `.settledWon` | Settled winning bet |
| `MyBet` | `.settledLost` | Settled losing bet |
| `MyBet` | `.cashedOut` | Fully cashed out bet |
| `CashoutValue` | `.fixture(...)` | SSE update with configurable fields |
| `CashoutValue` | `.loading` | Loading state (code 103) |
| `CashoutValue` | `.fullCashoutOnly` | Partial disabled |
| `CashoutResponse` | `.fullCashoutSuccess` | Successful full cashout |
| `CashoutResponse` | `.partialCashoutSuccess(...)` | Successful partial cashout |
| `CashoutResponse` | `.failed` | Failed cashout |

---

## Common Testing Patterns

### Pattern 1: Tracking Method Calls

Use local arrays to capture calls and verify them:

```swift
func test_subscribesToSSE() {
    var capturedBetIds: [String] = []

    let service = CashoutService(
        subscribeToCashoutValue: { betId in
            capturedBetIds.append(betId)  // Capture!
            return Empty().eraseToAnyPublisher()
        },
        executeCashout: { _ in Empty().eraseToAnyPublisher() }
    )

    _ = TicketBetInfoViewModel(myBet: .activeBetWithCashout(identifier: "bet-123"), cashoutService: service)

    XCTAssertEqual(capturedBetIds, ["bet-123"])
}
```

### Pattern 2: Simulating Streams with PassthroughSubject

Control real-time updates in tests:

```swift
func test_sseUpdatesUI() {
    let sseSubject = PassthroughSubject<SubscribableContent<CashoutValue>, ServiceProviderError>()

    let service = CashoutService(
        subscribeToCashoutValue: { _ in sseSubject.eraseToAnyPublisher() },
        executeCashout: { _ in Empty().eraseToAnyPublisher() }
    )
    let viewModel = TicketBetInfoViewModel(myBet: .activeBetWithCashout(), cashoutService: service)

    // Simulate SSE pushing a value
    sseSubject.send(.contentUpdate(content: .fixture(partialCashOutEnabled: true)))

    XCTAssertNotNil(viewModel.cashoutSliderViewModel)
}
```

### Pattern 3: Returning Success with Just()

```swift
func test_successCallsCompletion() {
    let service = CashoutService(
        subscribeToCashoutValue: { _ in Empty().eraseToAnyPublisher() },
        executeCashout: { _ in
            Just(CashoutResponse.fullCashoutSuccess)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }
    )
    // ...
}
```

### Pattern 4: Returning Errors with Fail()

```swift
func test_errorCallsErrorCallback() {
    let service = CashoutService(
        subscribeToCashoutValue: { _ in Empty().eraseToAnyPublisher() },
        executeCashout: { _ in
            Fail(error: ServiceProviderError.unknown)
                .eraseToAnyPublisher()
        }
    )
    // ...
}
```

### Pattern 5: Changing Behavior Between Calls

```swift
func test_retryAfterFailure() {
    var shouldFail = true

    let service = CashoutService(
        subscribeToCashoutValue: { _ in Empty().eraseToAnyPublisher() },
        executeCashout: { _ in
            if shouldFail {
                shouldFail = false  // Next call succeeds
                return Fail(error: .unknown).eraseToAnyPublisher()
            }
            return Just(.fullCashoutSuccess)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }
    )
    // ...
}
```

### Pattern 6: Minimal Setup with .noop

```swift
func test_initialState() {
    // When you just need a ViewModel instance without service behavior
    let viewModel = TicketBetInfoViewModel(
        myBet: .activeBetWithCashout(),
        cashoutService: .noop
    )

    XCTAssertFalse(viewModel.isCashoutLoading)
}
```

---

## Quick Reference

### Combine Publishers for Tests

| Publisher | Use Case |
|-----------|----------|
| `Empty()` | Service does nothing (default for unused closures) |
| `Empty(completeImmediately: false)` | Never completes (test loading states) |
| `Just(value).setFailureType(to:).eraseToAnyPublisher()` | Return success immediately |
| `Fail(error:).eraseToAnyPublisher()` | Return error immediately |
| `PassthroughSubject` | Control when/what values are sent |

### Service Factory Methods

| Method | Use Case |
|--------|----------|
| `.live(client:)` | Production - wraps real ServicesProvider |
| `.noop` | Test - operations never complete |
| `.failing()` | Test - all operations fail |
| Inline closures | Test - full control over behavior |

### Test Structure

```swift
func test_someBehavior() {
    // Given - Setup
    let service = CashoutService(
        subscribeToCashoutValue: { _ in /* ... */ },
        executeCashout: { _ in /* ... */ }
    )
    let viewModel = TicketBetInfoViewModel(myBet: .activeBetWithCashout(), cashoutService: service)

    // When - Action
    viewModel.handleCashoutTap()

    // Then - Assertion
    XCTAssertEqual(/* ... */)
}
```

---

## Further Reading

- [pointfree.co - Protocol Witnesses](https://www.pointfree.co/collections/protocol-witnesses)
- [Brandon Williams - Protocol-Oriented Programming is Not a Silver Bullet](https://www.youtube.com/watch?v=VFLdIGY8kV8)
- Example tests: `Tests/ViewModels/MyBets/TicketBetInfoViewModelTests.swift`
