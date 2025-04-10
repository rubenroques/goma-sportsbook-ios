import XCTest
import Combine
@testable import EveryMatrixAPIClient

class EveryMatrixAuthenticatorTests: XCTestCase {

    var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testInitialState() {
        let authenticator = EveryMatrixAuthenticator()

        // Verify initial state
        XCTAssertNil(authenticator.getToken())

        // Verify initial authentication state is .initial
        let expectation = self.expectation(description: "Initial state is .initial")
        authenticator.statePublisher
            .sink { state in
                XCTAssertEqual(state, .initial)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)
    }

    func testUpdateToken() {
        let authenticator = EveryMatrixAuthenticator()

        // Create a session token
        let token = SessionToken(sessionID: "test-session-id", universalID: "test-universal-id")

        // Update the token
        authenticator.updateToken(token)

        // Verify the token is updated
        XCTAssertEqual(authenticator.getToken(), "test-session-id")

        // Verify the authentication state changes to .authenticated
        let expectation = self.expectation(description: "State changes to authenticated")
        authenticator.statePublisher
            .sink { state in
                XCTAssertEqual(state, .authenticated(token))
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)
    }

    func testClearToken() {
        let authenticator = EveryMatrixAuthenticator()

        // Set up an initial token
        let token = SessionToken(sessionID: "test-session-id", universalID: "test-universal-id")
        authenticator.updateToken(token)

        // Verify the token is set
        XCTAssertEqual(authenticator.getToken(), "test-session-id")

        // Verify the token is valid
        XCTAssertTrue(authenticator.hasValidToken())

        // Verify we're in authenticated state
        let authenticatedExpectation = self.expectation(description: "State is authenticated")
        authenticator.statePublisher
            .first()
            .sink { state in
                if case .authenticated = state {
                    authenticatedExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)

        // Clear the token
        authenticator.updateToken(nil)

        // Verify the token is cleared
        XCTAssertNil(authenticator.getToken())
        XCTAssertFalse(authenticator.hasValidToken())

        // Verify we're in unauthenticated state
        let unauthenticatedExpectation = self.expectation(description: "State is unauthenticated")
        authenticator.statePublisher
            .first()
            .sink { state in
                if case .unauthenticated = state {
                    unauthenticatedExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)
    }

    func testTokenValidation() {
        let authenticator = EveryMatrixAuthenticator()

        // Test with no token
        XCTAssertFalse(authenticator.hasValidToken())

        // Set a token
        let token = SessionToken(sessionID: "test-session-id", universalID: "test-universal-id")
        authenticator.updateToken(token)

        // Verify the token is valid
        XCTAssertTrue(authenticator.hasValidToken())
    }

    func testAuthenticationFlow() {
        let authenticator = EveryMatrixAuthenticator()

        // Create expectations for each state transition
        let initialExpectation = self.expectation(description: "Initial state")
        let authenticatingExpectation = self.expectation(description: "Authenticating state")
        let authenticatedExpectation = self.expectation(description: "Authenticated state")
        let unauthenticatedExpectation = self.expectation(description: "Unauthenticated state")

        // Track state transitions
        var observedStates = Set<AuthenticationState>()

        authenticator.statePublisher
            .sink { state in
                // Only fulfill each expectation once
                if !observedStates.contains(state) {
                    observedStates.insert(state)

                    switch state {
                    case .initial:
                        initialExpectation.fulfill()
                    case .authenticating:
                        authenticatingExpectation.fulfill()
                    case .authenticated:
                        authenticatedExpectation.fulfill()
                    case .unauthenticated:
                        unauthenticatedExpectation.fulfill()
                    }
                }
            }
            .store(in: &cancellables)

        // Simulate authentication flow

        // We need to trigger authenticating state through publisherWithValidToken
        // as setAuthenticating no longer exists
        _ = authenticator.publisherWithValidToken(forceRefresh: true)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)

        let token = SessionToken(sessionID: "test-session-id", universalID: "test-universal-id")
        authenticator.updateToken(token) // Move to authenticated

        authenticator.updateToken(nil) // Move to unauthenticated

        // Wait for all state transitions
        waitForExpectations(timeout: 1)
    }
}
