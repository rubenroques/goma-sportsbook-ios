import XCTest
import Combine
@testable import ServicesProvider

// MARK: - URLProtocolMock
/// A mock URLProtocol implementation that allows us to intercept network requests and provide mock responses
/// This enables us to test network-dependent code without making actual network calls
///
/// Key Features:
/// - Stores mock responses for specific requests
/// - Tracks all received requests for verification
/// - Can simulate success responses, errors, and different HTTP status codes
/// - Identifies requests uniquely based on both URL and body content
class URLProtocolMock: URLProtocol {
    /// Dictionary that stores mock responses for requests
    /// - Key: A unique identifier generated from the request's URL and body
    /// - Value: A tuple containing:
    ///   - error: Optional error to simulate network/server errors
    ///   - data: Optional response data
    ///   - response: Optional HTTP response with status code and headers
    static var mockResponses = [String: (error: Error?, data: Data?, response: HTTPURLResponse?)]()

    /// Keeps track of all requests received by the mock
    /// Useful for verifying that expected requests were made
    static var requestsReceived: [URLRequest] = []

    /// Dictionary to store request bodies since they might not be available in startLoading
    private static var requestBodies = [URL?: Data]()

    /// Creates a unique identifier for a request by combining its URL and body
    /// This allows us to differentiate between requests that have the same URL but different bodies
    /// - Parameter request: The URLRequest to create an identifier for
    /// - Returns: A string that uniquely identifies the request
    static func requestIdentifier(for request: URLRequest) -> String {
        let url = request.url?.absoluteString ?? ""

        // Try to get body from the request or from our stored bodies
        let bodyData = request.httpBody ?? requestBodies[request.url]
        if let bodyData = bodyData,
           let bodyString = String(data: bodyData, encoding: .utf8) {
            return "\(url)_\(bodyString)"
        }
        return url
    }

    /// Required override that tells URLSession whether this protocol can handle a given request
    /// We return true to handle all requests in our tests
    override class func canInit(with request: URLRequest) -> Bool {
        // Store the body when we first see the request
        if let body = request.httpBody {
            requestBodies[request.url] = body
        }
        return true
    }

    /// Required override that allows URLSession to create a canonical version of the request
    /// We simply return the original request as we don't need to modify it
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        // Store the body when we see the canonical request
        if let body = request.httpBody {
            requestBodies[request.url] = body
        }
        return request
    }

    /// The main method where we intercept requests and return mock responses
    /// This is called by URLSession when a request is made
    override func startLoading() {
        // Store the request for later verification
        URLProtocolMock.requestsReceived.append(request)

        // Get the unique identifier for this request using stored body if needed
        let identifier = URLProtocolMock.requestIdentifier(for: request)

        print("[SERVICEPROVIDER][MOCK] Received request with identifier: \(identifier)")
        print("[SERVICEPROVIDER][MOCK] URL: \(request.url?.absoluteString ?? "nil")")

        // Try to get body from request or stored bodies
        let bodyData = request.httpBody ?? URLProtocolMock.requestBodies[request.url]
        if let bodyData = bodyData,
           let bodyString = String(data: bodyData, encoding: .utf8) {
            print("[SERVICEPROVIDER][MOCK] Body: \(bodyString)")
        } else {
            print("[SERVICEPROVIDER][MOCK] ⚠️ No body found for request")
        }

        // If we have a mock response for this request, return it
        if let (error, data, response) = URLProtocolMock.mockResponses[identifier] {
            print("[SERVICEPROVIDER][MOCK] Found mock response for request")

            // Send the mock HTTP response if provided
            if let responseStrong = response {
                print("[SERVICEPROVIDER][MOCK] Sending response with status code: \(responseStrong.statusCode)")
                self.client?.urlProtocol(self, didReceive: responseStrong, cacheStoragePolicy: .notAllowed)
            }

            // Send the mock response data if provided
            if let dataStrong = data {
                print("[SERVICEPROVIDER][MOCK] Sending response data: \(String(data: dataStrong, encoding: .utf8) ?? "nil")")
                self.client?.urlProtocol(self, didLoad: dataStrong)
            }

            // Send the mock error if provided
            if let errorStrong = error {
                print("[SERVICEPROVIDER][MOCK] Sending error: \(errorStrong)")
                self.client?.urlProtocol(self, didFailWithError: errorStrong)
            }
        } else {
            print("[SERVICEPROVIDER][MOCK] ⚠️ No mock response found for request")
            print("[SERVICEPROVIDER][MOCK] Available mock identifiers:")
            for (key, _) in URLProtocolMock.mockResponses {
                print("[SERVICEPROVIDER][MOCK] - \(key)")
            }
        }

        // Signal that we're done loading
        self.client?.urlProtocolDidFinishLoading(self)
    }

    /// Required override for cleanup
    /// Not used in our implementation
    override func stopLoading() {}

    /// Resets all static state between tests
    /// Important to prevent test cross-contamination
    static func reset() {
        mockResponses.removeAll()
        requestsReceived.removeAll()
        requestBodies.removeAll()
    }

    /// Verifies that a specific request was received
    /// - Parameter request: The request to verify
    /// - Returns: True if the request was received, false otherwise
    static func verifyRequest(_ request: URLRequest) -> Bool {
        let identifier = requestIdentifier(for: request)
        return requestsReceived.contains { requestIdentifier(for: $0) == identifier }
    }
}

final class SportsMergerTests: XCTestCase {

    // MARK: - Properties
    private var cancellables: Set<AnyCancellable>!
    private var mockedSession: URLSession!

    override func setUp() {
        super.setUp()
        cancellables = []

        // Configure mocked session
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        mockedSession = URLSession(configuration: configuration)
    }

    override func tearDown() {
        URLProtocolMock.reset()
        cancellables = nil
        mockedSession = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    /// Sets up a mock response for a single SportRadarRestAPIClient endpoint
    /// This is the lowest level helper that actually configures the mock response
    ///
    /// Usage example:
    /// ```
    /// setupMockResponse(
    ///     for: .subscribe(sessionToken: "token", contentIdentifier: .allSports),
    ///     statusCode: 404,
    ///     error: ServiceProviderError.onSubscribe
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - endpoint: The SportRadarRestAPIClient endpoint to mock
    ///   - statusCode: HTTP status code for the response (default: 200)
    ///   - responseData: Optional JSON data to return (default: {"version": "1.0"})
    ///   - error: Optional error to return (default: nil)
    private func setupMockResponse(
        for endpoint: SportRadarRestAPIClient,
        statusCode: Int = 200,
        responseData: Data? = """
        {
            "version": "1.0"
        }
        """.data(using: .utf8),
        error: Error? = nil
    ) {
        guard let request = endpoint.request(),
              let url = request.url else {
            XCTFail("Failed to create request for endpoint")
            return
        }

        let identifier = URLProtocolMock.requestIdentifier(for: request)
        print("[SERVICEPROVIDER][TEST] Setting up mock response for identifier: \(identifier)")
        print("[SERVICEPROVIDER][TEST] URL: \(url.absoluteString)")
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("[SERVICEPROVIDER][TEST] Body: \(bodyString)")
        }

        URLProtocolMock.mockResponses[identifier] = (
            error: error,
            data: responseData,
            response: HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )
        )
    }

    /// Sets up mock responses for multiple endpoints with the same configuration
    /// Useful when testing system-wide states like server outages or authentication failures
    ///
    /// Usage example:
    /// ```
    /// setupMockResponses(
    ///     for: [.subscribe(...), .unsubscribe(...)],
    ///     statusCode: 500,
    ///     error: ServiceProviderError.serverError
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - endpoints: Array of endpoints to mock
    ///   - statusCode: HTTP status code for all responses (default: 200)
    ///   - responseData: Optional JSON data to return for all endpoints (default: {"version": "1.0"})
    ///   - error: Optional error to return for all endpoints (default: nil)
    private func setupMockResponses(
        for endpoints: [SportRadarRestAPIClient],
        statusCode: Int = 200,
        responseData: Data? = """
        {
            "version": "1.0"
        }
        """.data(using: .utf8),
        error: Error? = nil
    ) {
        endpoints.forEach { endpoint in
            setupMockResponse(
                for: endpoint,
                statusCode: statusCode,
                responseData: responseData,
                error: error
            )
        }
    }

    /// Convenience method specifically for setting up subscription mock responses
    /// This is a higher-level helper that uses setupMockResponses internally
    ///
    /// Usage example:
    /// ```
    /// setupMockResponses(forSessionToken: "test_token")
    /// ```
    ///
    /// - Parameter sessionToken: The session token to use for the subscription requests
    private func setupMockResponses(forSessionToken sessionToken: String) {
        // Create subscription endpoints for both all sports and live sports
        let endpoints: [SportRadarRestAPIClient] = [
            .subscribe(sessionToken: sessionToken, contentIdentifier: ContentIdentifier.allSports),
            .subscribe(sessionToken: sessionToken, contentIdentifier: ContentIdentifier.liveSports)
        ]

        // Setup mock responses for all endpoints with default success values
        setupMockResponses(for: endpoints)
    }

    // MARK: - Initial Connection Tests

    /// Test verifies that SportsMerger successfully handles the initial subscription process
    ///
    /// Flow:
    /// 1. Setup:
    ///    - Creates MockURLSession to simulate network responses
    ///    - Prepares mock responses for both all sports and live sports subscriptions
    ///    - Each response contains a version number which validates the subscription
    ///
    /// 2. Subscription Process:
    ///    - SportsMerger initiates two parallel subscriptions:
    ///      a) All sports subscription (required)
    ///      b) Live sports subscription (optional)
    ///    - Both REST calls must return success (200) with valid version
    ///
    /// 3. State Management:
    ///    - SportsMerger transitions from .disconnected -> .connecting -> .connected
    ///    - Creates Subscription objects for successful responses
    ///    - Sends .connected state through sportsPublisher
    ///
    /// 4. Verification:
    ///    - Confirms we receive exactly one state update
    ///    - Verifies it's a .connected state with proper subscription
    ///    - Checks subscription has correct contentIdentifier and sessionToken
    ///    - Verifies the correct REST requests were made
    ///
    /// Note: This test only verifies the REST subscription part.
    /// Socket connection and updates are handled separately.
    func test_subscribeSportTypes_WhenSuccessful_ShouldReceiveConnectedState() {
        // Given
        let sessionToken = TestConstants.mockSessionToken
        let expectation = expectation(description: "Should receive connected state")
        var receivedStates: [SubscribableContent<[SportType]>] = []

        // Setup mock responses
        setupMockResponses(forSessionToken: sessionToken)

        // Create SportsMerger instance with mocked session
        let sportsMerger = SportsMerger(sessionToken: sessionToken, urlSession: mockedSession)

        // When
        sportsMerger.sportsPublisher
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Unexpected error: \(error)")
                    }
                },
                receiveValue: { state in
                    print("[SERVICEPROVIDER][TEST] Received state: \(state)")
                    receivedStates.append(state)
                    if case .connected = state {
                        expectation.fulfill()
                    }
                }
            )
            .store(in: &cancellables)

        // Then
        waitForExpectations(timeout: TestConstants.defaultTimeout)

        // Verify we received the correct number of states
        XCTAssertEqual(receivedStates.count, 1, "Should receive exactly one state update")

        // Verify the received state is .connected with correct subscription
        if case .connected(let subscription) = receivedStates.first {
            XCTAssertEqual(subscription.sessionToken, sessionToken, "Session token should match")
            XCTAssertEqual(subscription.contentIdentifier, ContentIdentifier.allSports, "Content identifier should be for all sports")

            // Verify that both subscription requests were made
            let allSportsEndpoint = SportRadarRestAPIClient.subscribe(
                sessionToken: sessionToken,
                contentIdentifier: ContentIdentifier.allSports
            )
            let liveSportsEndpoint = SportRadarRestAPIClient.subscribe(
                sessionToken: sessionToken,
                contentIdentifier: ContentIdentifier.liveSports
            )

            guard let allSportsRequest = allSportsEndpoint.request(),
                  let liveSportsRequest = liveSportsEndpoint.request() else {
                XCTFail("Failed to create verification requests")
                return
            }

            XCTAssertTrue(
                URLProtocolMock.verifyRequest(allSportsRequest),
                "All sports subscription request should have been made"
            )
            XCTAssertTrue(
                URLProtocolMock.verifyRequest(liveSportsRequest),
                "Live sports subscription request should have been made"
            )

            // Print received requests for debugging
            print("[SERVICEPROVIDER][TEST] Received requests:")
            for request in URLProtocolMock.requestsReceived {
                print("[SERVICEPROVIDER][TEST] - URL: \(request.url?.absoluteString ?? "nil")")
                if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
                    print("[SERVICEPROVIDER][TEST] - Body: \(bodyString)")
                }
            }
        } else {
            XCTFail("First state should be .connected")
        }
    }
}
