import XCTest
@testable import EveryMatrixProviderClient

class LoginResponseTests: XCTestCase {

    func testLoginResponseDecoding() {
        // JSON response from the API, matching the example format
        let json = """
        {
            "sessionID": "b21ecca4-2581-40ac-bf4a-334aaaf05c8c",
            "universalID": "6812585",
            "hasToAcceptTC": false,
            "hasToSetPass": false
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()

        do {
            let response = try decoder.decode(LoginResponse.self, from: data)

            // Verify all fields are decoded correctly
            XCTAssertEqual(response.sessionID, "b21ecca4-2581-40ac-bf4a-334aaaf05c8c")
            XCTAssertEqual(response.universalID, "6812585")
            XCTAssertFalse(response.hasToAcceptTC)
            XCTAssertFalse(response.hasToSetPass)

            // Verify the sessionToken is created correctly
            let token = response.sessionToken
            XCTAssertEqual(token.sessionID, "b21ecca4-2581-40ac-bf4a-334aaaf05c8c")
            XCTAssertEqual(token.universalID, "6812585")
        } catch {
            XCTFail("Failed to decode LoginResponse: \(error)")
        }
    }

    func testLoginResponseEncoding() {
        // Create a LoginResponse instance
        let response = LoginResponse(
            sessionID: "b21ecca4-2581-40ac-bf4a-334aaaf05c8c",
            universalID: "6812585",
            hasToAcceptTC: true,
            hasToSetPass: false
        )

        // Encode the response
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(response)

            // Decode the data back to verify
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(LoginResponse.self, from: data)

            // Verify the decoded response matches the original
            XCTAssertEqual(decodedResponse.sessionID, response.sessionID)
            XCTAssertEqual(decodedResponse.universalID, response.universalID)
            XCTAssertEqual(decodedResponse.hasToAcceptTC, response.hasToAcceptTC)
            XCTAssertEqual(decodedResponse.hasToSetPass, response.hasToSetPass)
        } catch {
            XCTFail("Failed to encode or decode LoginResponse: \(error)")
        }
    }

    func testEquality() {
        // Create two identical responses
        let response1 = LoginResponse(
            sessionID: "test-id",
            universalID: "user-123",
            hasToAcceptTC: false,
            hasToSetPass: true
        )

        let response2 = LoginResponse(
            sessionID: "test-id",
            universalID: "user-123",
            hasToAcceptTC: false,
            hasToSetPass: true
        )

        // Create a different response
        let response3 = LoginResponse(
            sessionID: "different-id",
            universalID: "user-456",
            hasToAcceptTC: true,
            hasToSetPass: false
        )

        // Test equality
        XCTAssertEqual(response1, response2)
        XCTAssertNotEqual(response1, response3)
    }
}
