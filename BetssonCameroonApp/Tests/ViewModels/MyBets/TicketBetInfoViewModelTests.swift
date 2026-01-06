//
//  TicketBetInfoViewModelTests.swift
//  BetssonCameroonAppTests
//
//  Exemplary unit tests demonstrating pointfree-style struct-based dependencies.
//  These tests serve as reference patterns for the team.
//
//  For full documentation, see: Tests/Documentation/UNIT_TESTING_101.md
//

import XCTest
import Combine
import ServicesProvider
@testable import BetssonCameroonApp

final class TicketBetInfoViewModelTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Example 1: Tracking Method Calls
    //
    // Pattern: Use a local array to capture method calls and verify them after.
    // This is useful when you need to verify that a method was called with specific arguments.

    func test_activeBet_subscribesToSSE() {
        // Given - track if subscribe was called with correct betId
        var subscribedBetIds: [String] = []

        let service = CashoutService(
            subscribeToCashoutValue: { betId in
                subscribedBetIds.append(betId)  // Capture the call
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            },
            executeCashout: { _ in Empty().eraseToAnyPublisher() }
        )
        let bet = MyBet.activeBetWithCashout(identifier: "bet-123")

        // When
        _ = TicketBetInfoViewModel(myBet: bet, cashoutService: service)

        // Then
        XCTAssertEqual(subscribedBetIds, ["bet-123"], "Should subscribe to SSE for active bet")
    }

    // MARK: - Example 2: Simulating SSE Stream with PassthroughSubject
    //
    // Pattern: Create a PassthroughSubject that you control, pass it to the service,
    // then send values through it to simulate real-time updates.

    func test_sseUpdate_updatesCashoutSliderVisibility() {
        // Given - Create a subject we can push values through
        let sseSubject = PassthroughSubject<SubscribableContent<CashoutValue>, ServiceProviderError>()

        let service = CashoutService(
            subscribeToCashoutValue: { _ in sseSubject.eraseToAnyPublisher() },
            executeCashout: { _ in Empty().eraseToAnyPublisher() }
        )
        let viewModel = TicketBetInfoViewModel(
            myBet: .activeBetWithCashout(),
            cashoutService: service
        )

        let expectation = expectation(description: "Components changed")
        viewModel.cashoutComponentsDidChangePublisher
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        // When - Simulate SSE pushing a value with partial cashout enabled
        let cashoutValue = CashoutValue.fixture(partialCashOutEnabled: true)
        sseSubject.send(.contentUpdate(content: cashoutValue))

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(viewModel.cashoutSliderViewModel, "Slider should be created")
    }

    // MARK: - Example 3: Testing Success Callbacks
    //
    // Pattern: Configure executeCashout to return a successful response using Just(),
    // then verify the completion callback is called with correct values.

    func test_fullCashoutSuccess_callsCompletionCallback() {
        // Given
        let sseSubject = PassthroughSubject<SubscribableContent<CashoutValue>, ServiceProviderError>()
        var executedRequests: [CashoutRequest] = []

        let service = CashoutService(
            subscribeToCashoutValue: { _ in sseSubject.eraseToAnyPublisher() },
            executeCashout: { request in
                executedRequests.append(request)  // Capture request for verification
                return Just(CashoutResponse.fullCashoutSuccess)
                    .setFailureType(to: ServiceProviderError.self)
                    .eraseToAnyPublisher()
            }
        )
        let viewModel = TicketBetInfoViewModel(
            myBet: .activeBetWithCashout(identifier: "bet-test"),
            cashoutService: service
        )

        // Setup: Send SSE value to enable cashout
        sseSubject.send(.contentUpdate(content: .fixture(stake: 10.0, partialCashOutEnabled: true)))

        let expectation = expectation(description: "Completion called")
        var completedBetId: String?
        var wasFullCashout: Bool?

        viewModel.onCashoutCompleted = { betId, isFullCashout, _ in
            completedBetId = betId
            wasFullCashout = isFullCashout
            expectation.fulfill()
        }

        // Auto-confirm the cashout dialog
        viewModel.onConfirmCashout = { _, _, _, _, _, confirm in
            confirm()
        }

        // When
        viewModel.handleCashoutTap()

        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(completedBetId, "bet-test")
        XCTAssertEqual(wasFullCashout, true)
        XCTAssertEqual(executedRequests.count, 1)
        XCTAssertEqual(executedRequests.first?.betId, "bet-test")
    }

    // MARK: - Example 4: Testing Error & Retry Flow
    //
    // Pattern: Use a mutable flag to change behavior between calls.
    // First call fails, retry succeeds. This tests the full error-retry cycle.

    func test_retryCashout_reexecutesLastRequest() {
        // Given
        let sseSubject = PassthroughSubject<SubscribableContent<CashoutValue>, ServiceProviderError>()
        var executionCount = 0
        var shouldFail = true  // Mutable flag to change behavior

        let service = CashoutService(
            subscribeToCashoutValue: { _ in sseSubject.eraseToAnyPublisher() },
            executeCashout: { _ in
                executionCount += 1
                if shouldFail {
                    shouldFail = false  // Next call will succeed
                    return Fail(error: ServiceProviderError.unknown).eraseToAnyPublisher()
                } else {
                    return Just(CashoutResponse.fullCashoutSuccess)
                        .setFailureType(to: ServiceProviderError.self)
                        .eraseToAnyPublisher()
                }
            }
        )
        let viewModel = TicketBetInfoViewModel(
            myBet: .activeBetWithCashout(),
            cashoutService: service
        )

        // Setup
        sseSubject.send(.contentUpdate(content: .fixture(partialCashOutEnabled: true)))

        let expectation = expectation(description: "Retry completed")

        viewModel.onCashoutError = { _, retry, _ in
            retry()  // Trigger retry on error
        }

        viewModel.onCashoutCompleted = { _, _, _ in
            expectation.fulfill()
        }

        viewModel.onConfirmCashout = { _, _, _, _, _, confirm in
            confirm()
        }

        // When
        viewModel.handleCashoutTap()

        // Then
        wait(for: [expectation], timeout: 3.0)
        XCTAssertEqual(executionCount, 2, "Should execute twice (initial + retry)")
    }

    // MARK: - Example 5: Using .noop for Minimal Setup
    //
    // Pattern: When you only need to test initial state or don't need
    // the service to do anything, use .noop for minimal boilerplate.

    func test_initialState_isIdle() {
        // Given - .noop provides a service that does nothing (Empty publishers)
        let viewModel = TicketBetInfoViewModel(
            myBet: .activeBetWithCashout(),
            cashoutService: .noop
        )

        // Then
        XCTAssertFalse(viewModel.isCashoutLoading, "Initial state should be idle")
    }
}
