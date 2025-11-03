# Testing Guide

This guide documents testing strategies and patterns for the sportsbook iOS application.

## Current State

- ✅ **Protocol-driven architecture**: All components use protocol interfaces for easy mocking
- ✅ **Mock implementations**: GomaUI components have comprehensive mocks
- ✅ **Test infrastructure**: Test targets configured for unit and UI tests
- ⏳ **Test coverage**: Limited, needs expansion
- ⏳ **Screenshot tests**: Infrastructure prepared but not yet implemented

## Mock Patterns

### Pattern 1: Static Factory Mock (GomaUI Standard)

**Use Case**: UI components with predefined state variations for previews and demos

**Example**:
```swift
final public class MockButtonViewModel: ButtonViewModelProtocol {
    private let buttonDataSubject: CurrentValueSubject<ButtonData, Never>

    public var buttonDataPublisher: AnyPublisher<ButtonData, Never> {
        buttonDataSubject.eraseToAnyPublisher()
    }

    public init(buttonData: ButtonData) {
        self.buttonDataSubject = CurrentValueSubject(buttonData)
    }

    public func setEnabled(_ isEnabled: Bool) {
        // Update state implementation
    }
}

// MARK: - Static Factory Methods
extension MockButtonViewModel {
    public static var solidBackgroundMock: MockButtonViewModel {
        MockButtonViewModel(buttonData: ButtonData(
            id: "confirm_payment",
            title: "Confirm Payment",
            style: .solidBackground,
            isEnabled: true
        ))
    }

    public static var disabledMock: MockButtonViewModel {
        MockButtonViewModel(buttonData: ButtonData(
            id: "disabled_button",
            title: "Submit",
            style: .solidBackground,
            isEnabled: false
        ))
    }
}
```

**When to Use**: GomaUI components, SwiftUI previews, demo app

---

### Pattern 2: Closure-Based Strategy Pattern (Recommended for Services)

**Technical Name**: "Closure-Based Strategy Pattern" or "Configurable Mock with Closure Injection"

**Use Case**: Service layer where behavior varies significantly per test case

**Key Benefits**:
1. **Flexibility**: Configure different behaviors per test without creating new mock classes
2. **Type Safety**: Closures enforce correct return types at compile-time
3. **No Inheritance Overhead**: Single mock class handles all scenarios
4. **Testability**: Easy to simulate success, failure, loading states, edge cases
5. **Readability**: Test setup clearly shows what the mock will return

**Example**:
```swift
// Protocol
public protocol BettingServiceProtocol {
    func placeBet(selections: [Selection], stake: Decimal) -> AnyPublisher<BetReceipt, BettingError>
    func fetchBetHistory(limit: Int) -> AnyPublisher<[BetTicket], BettingError>
}

// Mock with closure injection
public final class MockBettingService: BettingServiceProtocol {

    // MARK: - Closure Properties
    public var placeBetClosure: (([Selection], Decimal) -> AnyPublisher<BetReceipt, BettingError>)?
    public var fetchBetHistoryClosure: ((Int) -> AnyPublisher<[BetTicket], BettingError>)?

    // MARK: - Call Tracking
    public private(set) var placeBetCallCount = 0
    public private(set) var fetchBetHistoryCallCount = 0

    // MARK: - Initialization
    public init(
        placeBet: (([Selection], Decimal) -> AnyPublisher<BetReceipt, BettingError>)? = nil,
        fetchBetHistory: ((Int) -> AnyPublisher<[BetTicket], BettingError>)? = nil
    ) {
        self.placeBetClosure = placeBet
        self.fetchBetHistoryClosure = fetchBetHistory
    }

    // MARK: - Protocol Conformance
    public func placeBet(selections: [Selection], stake: Decimal) -> AnyPublisher<BetReceipt, BettingError> {
        placeBetCallCount += 1

        guard let closure = placeBetClosure else {
            return Fail(error: .notImplemented).eraseToAnyPublisher()
        }

        return closure(selections, stake)
    }

    public func fetchBetHistory(limit: Int) -> AnyPublisher<[BetTicket], BettingError> {
        fetchBetHistoryCallCount += 1

        guard let closure = fetchBetHistoryClosure else {
            return Just([]).setFailureType(to: BettingError.self).eraseToAnyPublisher()
        }

        return closure(limit)
    }
}

// MARK: - Optional Convenience Factories
public extension MockBettingService {
    static var alwaysSucceeds: MockBettingService {
        MockBettingService(
            placeBet: { _, _ in
                Just(BetReceipt.mock)
                    .setFailureType(to: BettingError.self)
                    .eraseToAnyPublisher()
            },
            fetchBetHistory: { limit in
                Just(Array(repeating: BetTicket.mock, count: limit))
                    .setFailureType(to: BettingError.self)
                    .eraseToAnyPublisher()
            }
        )
    }
}
```

**Usage in Tests**:
```swift
final class BetslipViewModelTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    // Test success scenario
    func testPlaceBet_Success_UpdatesState() {
        // Arrange - Configure mock inline for this specific test
        let mockService = MockBettingService(
            placeBet: { selections, stake in
                Just(BetReceipt(betId: "bet-456", timestamp: Date()))
                    .delay(for: 0.1, scheduler: DispatchQueue.main)
                    .setFailureType(to: BettingError.self)
                    .eraseToAnyPublisher()
            }
        )

        let viewModel = BetslipViewModel(bettingService: mockService)
        var receivedStates: [BetslipState] = []

        viewModel.statePublisher
            .sink { receivedStates.append($0) }
            .store(in: &cancellables)

        // Act
        viewModel.placeBet(selections: [.mock], stake: 10.0)

        // Wait for async operation
        let expectation = expectation(description: "Bet placed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Assert
        XCTAssertEqual(receivedStates.count, 3)
        XCTAssertEqual(receivedStates[0], .idle)
        XCTAssertEqual(receivedStates[1], .loading)
        XCTAssertEqual(receivedStates[2], .success(betId: "bet-456"))
        XCTAssertEqual(mockService.placeBetCallCount, 1)
    }

    // Test failure scenario - different behavior, same mock class
    func testPlaceBet_InsufficientFunds_ShowsError() {
        // Arrange - Configure different behavior for this test
        let mockService = MockBettingService(
            placeBet: { _, _ in
                Fail(error: .insufficientFunds(available: 5.0, required: 10.0))
                    .eraseToAnyPublisher()
            }
        )

        let viewModel = BetslipViewModel(bettingService: mockService)
        var receivedError: BettingError?

        viewModel.errorPublisher
            .sink { receivedError = $0 }
            .store(in: &cancellables)

        // Act
        viewModel.placeBet(selections: [.mock], stake: 10.0)

        // Assert
        XCTAssertEqual(receivedError, .insufficientFunds(available: 5.0, required: 10.0))
    }

    // Test edge case - yet another behavior
    func testFetchHistory_EmptyResult_ShowsEmptyState() {
        // Arrange
        let mockService = MockBettingService(
            fetchBetHistory: { _ in
                Just([]).setFailureType(to: BettingError.self).eraseToAnyPublisher()
            }
        )

        let viewModel = BetHistoryViewModel(bettingService: mockService)

        // Act
        viewModel.loadHistory()

        // Assert
        XCTAssertEqual(viewModel.currentState, .empty)
    }
}
```

**Comparison with Old Approach**:
```swift
// ❌ OLD: Multiple mock classes for different scenarios
class MockBettingServiceSuccess: BettingServiceProtocol { ... }
class MockBettingServiceFailure: BettingServiceProtocol { ... }
class MockBettingServiceEmpty: BettingServiceProtocol { ... }
class MockBettingServiceInsufficientFunds: BettingServiceProtocol { ... }
// Result: 4+ mock classes for one protocol!

// ✅ NEW: One mock, configured inline per test
let mock = MockBettingService(
    placeBet: { selections, stake in
        // Configure behavior for this specific test
    }
)
// Result: 1 mock class, infinite scenarios
```

**When to Use**: Services, Providers, Repositories, any backend layer

---

## Unit Testing Guidelines

### Test Structure (Arrange-Act-Assert)

```swift
func testMethodName_Scenario_ExpectedBehavior() {
    // Arrange: Set up test data and mocks
    let mockService = MockBettingService.alwaysSucceeds
    let viewModel = BetslipViewModel(bettingService: mockService)

    // Act: Execute the code under test
    viewModel.placeBet(selections: [.mock], stake: 10.0)

    // Assert: Verify expected outcome
    XCTAssertEqual(viewModel.currentState, .loading)
}
```

### What to Test

**ViewModels**:
- ✅ State transitions and business logic
- ✅ Data transformations (model → UI model)
- ✅ Publisher emissions and Combine chains
- ✅ Error handling and edge cases
- ❌ UIKit view layout (use screenshot tests)

**Services/Providers**:
- ✅ API request construction
- ✅ Response parsing and model mapping
- ✅ Error handling (network, parsing, business errors)
- ❌ Actual network calls (use URL protocol mocking)

**Models**:
- ✅ Codable conformance (encoding/decoding)
- ✅ Custom initializers and computed properties
- ✅ Validation logic

### Testing Async Publishers

```swift
func testPublisher_EmitsExpectedValues() {
    var receivedValues: [String] = []
    let expectation = expectation(description: "Publisher emits")

    viewModel.titlePublisher
        .sink { title in
            receivedValues.append(title)
            expectation.fulfill()
        }
        .store(in: &cancellables)

    viewModel.updateTitle("New Title")

    wait(for: [expectation], timeout: 1.0)

    XCTAssertEqual(receivedValues.last, "New Title")
}
```

## UI Testing (Future)

### Planned Approach: Screenshot Testing

**Status**: Infrastructure prepared but not yet implemented

**Recommended Tool**: [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing)

**Future Example**:
```swift
import SnapshotTesting

class ButtonViewSnapshotTests: XCTestCase {
    func testButtonView_AllStates_MatchReferences() {
        let button = ButtonView(viewModel: MockButtonViewModel.solidBackgroundMock)
        button.frame = CGRect(x: 0, y: 0, width: 300, height: 50)

        assertSnapshot(matching: button, as: .image)
    }
}
```

## Best Practices

1. **Use protocols for all dependencies** - Makes testing easy
2. **Keep tests focused** - One behavior per test
3. **Test edge cases** - Empty states, errors, boundaries
4. **Use descriptive test names** - `testPlaceBet_InsufficientFunds_ShowsError`
5. **Avoid testing implementation details** - Test behavior, not internal methods
6. **Keep tests fast** - No real network calls, minimal delays

## Mock Pattern Selection Guide

| Use Case | Pattern | When to Use |
|----------|---------|-------------|
| GomaUI Components | Static Factory Mock | Component demos, previews, predefined states |
| Service Layer | Closure-Based Strategy | Per-test behavior, complex scenarios, errors |
| API Integration | URL Protocol Mocking | Integration tests with endpoints |

## Related Documentation

- [MVVM.md](MVVM.md) - MVVM architecture patterns
- [API_DEVELOPMENT_GUIDE.md](API_DEVELOPMENT_GUIDE.md) - API integration
- [UI_COMPONENT_GUIDE.md](UI_COMPONENT_GUIDE.md) - Creating UI components
