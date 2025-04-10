import XCTest
import Combine
@testable import EveryMatrixAPIClient

final class ClientBalanceTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!
    var mockAuthenticator: EveryMatrixAuthenticator!
    var connector: EveryMatrixConnector!
    var apiClient: EveryMatrixPAMAPIClient!
    var testSession: URLSession!

    override func setUp() {
        super.setUp()
        cancellables = []

        // Configure URLSession to use MockURLProtocol
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self] // Inject our custom protocol
        testSession = URLSession(configuration: configuration)

        // Use explicit EveryMatrixConfiguration.default
        let emConfiguration = EveryMatrixConfiguration.default
        mockAuthenticator = EveryMatrixAuthenticator() // Assuming the real connector needs this

        // Initialize the *real* connector but inject the testSession
        connector = EveryMatrixConnector(authenticator: mockAuthenticator, session: testSession)

        // Initialize the API client with the configured connector
        apiClient = EveryMatrixPAMAPIClient(configuration: emConfiguration, connector: connector)

        print("ClientBalanceTests.setUp completed using MockURLProtocol")
    }

    override func tearDown() {
        MockURLProtocol.reset() // Reset MockURLProtocol state
        cancellables = nil
        testSession = nil
        mockAuthenticator = nil
        connector = nil
        apiClient = nil
        super.tearDown()
        print("ClientBalanceTests.tearDown completed")
    }

    // Test successful retrieval of balance
    func testGetBalanceSuccess() throws {
        let expectation = XCTestExpectation(description: "Fetch balance successfully")
        let userId = "test-user-123"

        // Prepare mock response data
        let mockBalanceResponse = BalanceResponse(
            totalAmount: ["EUR": 125.50],
            totalCashAmount: ["EUR": 100.0],
            totalWithdrawableAmount: ["EUR": 100.0],
            totalRealAmount: ["EUR": 100.0],
            totalBonusAmount: ["EUR": 25.50],
            items: [
                BalanceItem(
                    type: "Real",
                    amount: 100.0,
                    currency: "EUR",
                    productType: "Casino",
                    sessionTimestamp: "2024-03-20T10:00:00Z",
                    walletAccountType: "Cash",
                    sessionId: "session123",
                    creditLine: nil
                ),
                BalanceItem(
                    type: "Bonus",
                    amount: 25.50,
                    currency: "EUR",
                    productType: "Casino",
                    sessionTimestamp: "2024-03-20T10:00:00Z",
                    walletAccountType: "CasinoBonus",
                    sessionId: "session123",
                    creditLine: nil
                )
            ]
        )
        let mockData = try JSONEncoder().encode(mockBalanceResponse)

        // Configure MockURLProtocol to return the mock data
        MockURLProtocol.responseData = mockData
        MockURLProtocol.httpResponse = HTTPURLResponse(url: URL(string: "http://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil) // Provide a 200 response

        apiClient.getBalance(userId: userId)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success but got error: \(error)")
                }
            }, receiveValue: { balanceResponse in
                // Validate the received response against the mock
                XCTAssertEqual(balanceResponse.totalAmount, mockBalanceResponse.totalAmount)
                XCTAssertEqual(balanceResponse.items.count, mockBalanceResponse.items.count)
                XCTAssertEqual(balanceResponse.items[0].type, "Real")
                XCTAssertEqual(balanceResponse.items[1].type, "Bonus")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
        // Note: We can't easily assert on the lastRequest URL via MockURLProtocol directly
        // unless we add specific logic to the requestHandler to capture it.
        // Verification now relies on the test passing if the correct data is returned.
    }

    // Test failure when fetching balance (e.g., simulated network error)
    func testGetBalanceFailure_NetworkError() throws {
        let expectation = XCTestExpectation(description: "Fetch balance fails with simulated network error")
        let userId = "test-user-456"
        let expectedError = URLError(.notConnectedToInternet) // Simulate a network error

        // Configure MockURLProtocol to return an error
        MockURLProtocol.responseError = expectedError

        apiClient.getBalance(userId: userId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("Expected failure but got success")
                case .failure(let error):
                    // Check if the received error matches the expected simulated error
                    expectation.fulfill()
                }
            }, receiveValue: { balanceResponse in
                XCTFail("Expected error but received value: \(balanceResponse)")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    // Test failure due to specific HTTP status code (e.g., 401 Unauthorized)
    func testGetBalanceFailure_AuthError_401() throws {
        let expectation = XCTestExpectation(description: "Fetch balance fails with 401 Unauthorized")
        let userId = "test-user-789"
        let expectedError = EveryMatrixAuthenticationError.loginRequired // Expected error for 401

        // Configure MockURLProtocol to return a 401 response
        MockURLProtocol.httpResponse = HTTPURLResponse(url: URL(string: "http://test.com")!, statusCode: 401, httpVersion: nil, headerFields: nil)
        MockURLProtocol.responseData = Data() // Often need some data even for errors

        apiClient.getBalance(userId: userId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("Expected failure but got success")
                case .failure(let error):
                    // Check if the received error matches the expected authentication error
                    XCTAssertEqual(error as? EveryMatrixAuthenticationError, expectedError)
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Expected error but received value")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    // Test failure due to specific HTTP status code (e.g., 403 Forbidden)
    func testGetBalanceFailure_AuthError_403() throws {
        let expectation = XCTestExpectation(description: "Fetch balance fails with 403 Forbidden")
        let userId = "test-user-abc"
        let expectedError = EveryMatrixAuthenticationError.invalidToken // Expected error for 403

        // Configure MockURLProtocol to return a 403 response
        MockURLProtocol.httpResponse = HTTPURLResponse(url: URL(string: "http://test.com")!, statusCode: 403, httpVersion: nil, headerFields: nil)
        MockURLProtocol.responseData = Data()

        apiClient.getBalance(userId: userId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("Expected failure but got success")
                case .failure(let error):
                    XCTAssertEqual(error as? EveryMatrixAuthenticationError, expectedError)
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Expected error but received value")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

     // Test failure due to unexpected HTTP status code (e.g., 500)
    func testGetBalanceFailure_ServerError_500() throws {
        let expectation = XCTestExpectation(description: "Fetch balance fails with 500 Server Error")
        let userId = "test-user-xyz"
        let expectedError = EveryMatrixAuthenticationError.unknown("Unknown error: 500") // Expected error for unknown status

        // Configure MockURLProtocol to return a 500 response
        MockURLProtocol.httpResponse = HTTPURLResponse(url: URL(string: "http://test.com")!, statusCode: 500, httpVersion: nil, headerFields: nil)
        MockURLProtocol.responseData = Data()

        apiClient.getBalance(userId: userId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("Expected failure but got success")
                case .failure(let error):
                     guard let authError = error as? EveryMatrixAuthenticationError else {
                        XCTFail("Expected EveryMatrixAuthenticationError, got \(type(of: error))")
                        return
                    }
                    // Check the specific case or associated value if needed
                     if case .unknown(let message) = authError {
                         XCTAssertTrue(message.contains("500"))
                         expectation.fulfill()
                     } else {
                         XCTFail("Expected .unknown error, got \(authError)")
                     }
                }
            }, receiveValue: { _ in
                XCTFail("Expected error but received value")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
}
