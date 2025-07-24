import XCTest
@testable import EveryMatrixProviderClient

class LoginCredentialsTests: XCTestCase {

    func testLoginCredentialsEncoding() {
        // Create credentials
        let credentials = LoginCredentials(username: "jobit11000", password: "P@ssw0rd123!")

        // Encode to JSON
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(credentials)

            // Convert to JSON object and verify fields
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                XCTAssertEqual(json["username"] as? String, "jobit11000")
                XCTAssertEqual(json["password"] as? String, "P@ssw0rd123!")
            } else {
                XCTFail("Failed to convert encoded data to JSON object")
            }
        } catch {
            XCTFail("Failed to encode LoginCredentials: \(error)")
        }
    }

    func testLoginCredentialsDecoding() {
        // Create JSON data
        let json = """
        {
            "username": "jobit11000",
            "password": "P@ssw0rd123!"
        }
        """

        let data = json.data(using: .utf8)!

        // Decode the data
        let decoder = JSONDecoder()
        do {
            let credentials = try decoder.decode(LoginCredentials.self, from: data)

            // Verify the fields
            XCTAssertEqual(credentials.username, "jobit11000")
            XCTAssertEqual(credentials.password, "P@ssw0rd123!")
        } catch {
            XCTFail("Failed to decode LoginCredentials: \(error)")
        }
    }

    func testEquality() {
        // Create two credentials with the same values
        let credentials1 = LoginCredentials(username: "user1", password: "pass1")
        let credentials2 = LoginCredentials(username: "user1", password: "pass1")

        // Create different credentials
        let credentials3 = LoginCredentials(username: "user2", password: "pass2")

        // Test equality
        XCTAssertEqual(credentials1, credentials2)
        XCTAssertNotEqual(credentials1, credentials3)
    }

    func testMatchesCurlExample() {
        // Create credentials matching the curl example
        let credentials = LoginCredentials(username: "jobit11000", password: "P@ssw0rd123!")

        // Encode to JSON
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(credentials)

            // Expected JSON from the curl example
            let expectedJson = """
            {
              "username": "jobit11000",
              "password": "P@ssw0rd123!"
            }
            """

            // Convert both to dictionaries for comparison (ignoring whitespace differences)
            let actualDict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let expectedDict = try JSONSerialization.jsonObject(with: expectedJson.data(using: .utf8)!) as? [String: Any]

            // Compare the dictionaries
            XCTAssertEqual(actualDict?["username"] as? String, expectedDict?["username"] as? String)
            XCTAssertEqual(actualDict?["password"] as? String, expectedDict?["password"] as? String)
        } catch {
            XCTFail("Failed to encode or compare LoginCredentials: \(error)")
        }
    }
}