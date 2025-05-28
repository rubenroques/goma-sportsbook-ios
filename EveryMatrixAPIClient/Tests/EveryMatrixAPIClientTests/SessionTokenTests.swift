import XCTest
@testable import EveryMatrixAPIClient

class SessionTokenTests: XCTestCase {
    
    func testSessionTokenInitialization() {
        // Test initialization with valid parameters
        let sessionId = "b8216a1d-ef92-40b2-9d3f-7a394150042e"
        let universalId = "player-123456"
        
        let token = SessionToken(sessionID: sessionId, universalID: universalId)
        
        XCTAssertEqual(token.sessionID, sessionId)
        XCTAssertEqual(token.universalID, universalId)
    }
    
    func testSessionTokenCodable() {
        // Test SessionToken encoding and decoding
        let sessionId = "b8216a1d-ef92-40b2-9d3f-7a394150042e"
        let universalId = "player-123456"
        
        let originalToken = SessionToken(sessionID: sessionId, universalID: universalId)
        
        // Encode the token
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(originalToken)
            
            // Decode the data back to a token
            let decoder = JSONDecoder()
            let decodedToken = try decoder.decode(SessionToken.self, from: data)
            
            // Verify that the decoded token matches the original
            XCTAssertEqual(decodedToken.sessionID, originalToken.sessionID)
            XCTAssertEqual(decodedToken.universalID, originalToken.universalID)
        } catch {
            XCTFail("Failed to encode or decode SessionToken: \(error)")
        }
    }
    
    func testSessionTokenFromJSON() {
        // Test creating a token from JSON data (as would be received from the API)
        let json = """
        {
            "sessionID": "b8216a1d-ef92-40b2-9d3f-7a394150042e",
            "universalID": "player-123456",
            "hasToAcceptTC": false,
            "hasToSetPass": false
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let token = try decoder.decode(SessionToken.self, from: data)
            
            XCTAssertEqual(token.sessionID, "b8216a1d-ef92-40b2-9d3f-7a394150042e")
            XCTAssertEqual(token.universalID, "player-123456")
            XCTAssertFalse(token.hasToAcceptTC)
            XCTAssertFalse(token.hasToSetPass)
        } catch {
            XCTFail("Failed to decode SessionToken from JSON: \(error)")
        }
    }
    
    func testSessionTokenHasToFromJSON() {
        // Test creating a token from JSON data (as would be received from the API)
        let json = """
        {
            "sessionID": "b8216a1d-ef92-40b2-9d3f-7a394150042e",
            "universalID": "player-123456",
            "hasToAcceptTC": true,
            "hasToSetPass": true
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let token = try decoder.decode(SessionToken.self, from: data)
            
            XCTAssertEqual(token.sessionID, "b8216a1d-ef92-40b2-9d3f-7a394150042e")
            XCTAssertEqual(token.universalID, "player-123456")
            XCTAssertTrue(token.hasToAcceptTC)
            XCTAssertTrue(token.hasToSetPass)
        } catch {
            XCTFail("Failed to decode SessionToken from JSON: \(error)")
        }
    }
    
    func testSessionTokenPartialFromJSON() {
        // Test creating a token from JSON data (as would be received from the API)
        let json = """
        {
            "sessionID": "b8216a1d-ef92-40b2-9d3f-7a394150042e",
            "universalID": "123456"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let token = try decoder.decode(SessionToken.self, from: data)
            
            XCTAssertEqual(token.sessionID, "b8216a1d-ef92-40b2-9d3f-7a394150042e")
            XCTAssertEqual(token.universalID, "123456")
            XCTAssertFalse(token.hasToAcceptTC)
            XCTAssertFalse(token.hasToSetPass)
        } catch {
            XCTFail("Failed to decode SessionToken from JSON: \(error)")
        }
    }
    
    func testSessionTokenEquality() {
        // Test that two tokens with the same values are considered equal
        let token1 = SessionToken(sessionID: "abc123", universalID: "player-123")
        let token2 = SessionToken(sessionID: "abc123", universalID: "player-123")
        let token3 = SessionToken(sessionID: "def456", universalID: "player-456")
        
        XCTAssertEqual(token1, token2)
        XCTAssertNotEqual(token1, token3)
    }
} 
