import XCTest
@testable import EveryMatrixProviderClient

class EveryMatrixAuthenticationErrorTests: XCTestCase {

    func testErrorDescriptions() {
        // Test that each error has an appropriate description
        XCTAssertEqual(EveryMatrixAuthenticationError.loginRequired.localizedDescription, "Authentication required. Please log in.")
        XCTAssertEqual(EveryMatrixAuthenticationError.invalidCredentials.localizedDescription, "Invalid username or password.")
        XCTAssertEqual(EveryMatrixAuthenticationError.invalidToken.localizedDescription, "Authentication session has expired. Please log in again.")
        XCTAssertEqual(EveryMatrixAuthenticationError.accountLocked.localizedDescription, "Account is locked or suspended. Please contact customer support.")

        let customRegistrationMessage = "Username already exists"
        XCTAssertEqual(EveryMatrixAuthenticationError.invalidRegistrationData(customRegistrationMessage).localizedDescription, "Registration failed: Username already exists")

        let networkErrorMessage = "Connection timeout"
        XCTAssertEqual(EveryMatrixAuthenticationError.networkError(networkErrorMessage).localizedDescription, "Network error: Connection timeout")

        let invalidRequestMessage = "Missing required fields"
        XCTAssertEqual(EveryMatrixAuthenticationError.invalidRequest(invalidRequestMessage).localizedDescription, "Invalid request: Missing required fields")

        let decodingError = "JSON decoding failed"
        XCTAssertEqual(EveryMatrixAuthenticationError.invalidResponseDecoded(decodingError).localizedDescription, "Failed to parse server response: JSON decoding failed")

        let unknownErrorMessage = "Unexpected server response"
        XCTAssertEqual(EveryMatrixAuthenticationError.unknown(unknownErrorMessage).localizedDescription, "Authentication error: Unexpected server response")
    }

    func testErrorEquality() {
        // Test that errors of the same type are equal
        XCTAssertEqual(EveryMatrixAuthenticationError.loginRequired, EveryMatrixAuthenticationError.loginRequired)
        XCTAssertEqual(EveryMatrixAuthenticationError.invalidCredentials, EveryMatrixAuthenticationError.invalidCredentials)
        XCTAssertEqual(EveryMatrixAuthenticationError.invalidToken, EveryMatrixAuthenticationError.invalidToken)
        XCTAssertEqual(EveryMatrixAuthenticationError.accountLocked, EveryMatrixAuthenticationError.accountLocked)

        // Test that errors with associated values compare correctly
        XCTAssertEqual(
            EveryMatrixAuthenticationError.invalidRegistrationData("Username already exists"),
            EveryMatrixAuthenticationError.invalidRegistrationData("Username already exists")
        )
        XCTAssertNotEqual(
            EveryMatrixAuthenticationError.invalidRegistrationData("Username already exists"),
            EveryMatrixAuthenticationError.invalidRegistrationData("Email already exists")
        )

        XCTAssertEqual(
            EveryMatrixAuthenticationError.networkError("Connection timeout"),
            EveryMatrixAuthenticationError.networkError("Connection timeout")
        )
        XCTAssertNotEqual(
            EveryMatrixAuthenticationError.networkError("Connection timeout"),
            EveryMatrixAuthenticationError.networkError("Server error")
        )

        // Test the new error cases
        XCTAssertEqual(
            EveryMatrixAuthenticationError.invalidRequest("Missing field"),
            EveryMatrixAuthenticationError.invalidRequest("Missing field")
        )
        XCTAssertNotEqual(
            EveryMatrixAuthenticationError.invalidRequest("Missing field"),
            EveryMatrixAuthenticationError.invalidRequest("Invalid format")
        )

        let error1 = "Error message"
        let error2 = "Error message"
        let error3 = "Different error"

        XCTAssertEqual(
            EveryMatrixAuthenticationError.invalidResponseDecoded(error1),
            EveryMatrixAuthenticationError.invalidResponseDecoded(error2)
        )
        XCTAssertNotEqual(
            EveryMatrixAuthenticationError.invalidResponseDecoded(error1),
            EveryMatrixAuthenticationError.invalidResponseDecoded(error3)
        )

        // Test that different error types are not equal
        XCTAssertNotEqual(EveryMatrixAuthenticationError.loginRequired, EveryMatrixAuthenticationError.invalidCredentials)
        XCTAssertNotEqual(EveryMatrixAuthenticationError.invalidToken, EveryMatrixAuthenticationError.networkError("Any message"))
        XCTAssertNotEqual(EveryMatrixAuthenticationError.invalidRequest("Message"), EveryMatrixAuthenticationError.invalidResponseDecoded(error1))
    }

    func testErrorHandling() {
        // Test handling different error types
        func handleError(_ error: EveryMatrixAuthenticationError) -> String {
            switch error {
            case .loginRequired:
                return "Please log in first"
            case .invalidCredentials:
                return "Wrong username or password"
            case .invalidToken:
                return "Your session has expired"
            case .accountLocked:
                return "Your account has been locked"
            case .invalidRegistrationData(let message):
                return "Registration problem: \(message)"
            case .networkError(let message):
                return "Network issue: \(message)"
            case .invalidRequest(let message):
                return "Request issue: \(message)"
            case .invalidResponseDecoded(let error):
                return "Response parsing issue: \(error)"
            case .unknown(let message):
                return "Something went wrong: \(message)"
            }
        }

        XCTAssertEqual(handleError(.loginRequired), "Please log in first")
        XCTAssertEqual(handleError(.invalidCredentials), "Wrong username or password")
        XCTAssertEqual(handleError(.invalidToken), "Your session has expired")
        XCTAssertEqual(handleError(.accountLocked), "Your account has been locked")
        XCTAssertEqual(handleError(.invalidRegistrationData("Username already exists")), "Registration problem: Username already exists")
        XCTAssertEqual(handleError(.networkError("Connection timeout")), "Network issue: Connection timeout")
        XCTAssertEqual(handleError(.invalidRequest("Missing required field")), "Request issue: Missing required field")

        let decodingError = "JSON parse error"
        XCTAssertEqual(handleError(.invalidResponseDecoded(decodingError)), "Response parsing issue: JSON parse error")

        XCTAssertEqual(handleError(.unknown("Unexpected error")), "Something went wrong: Unexpected error")
    }
}
