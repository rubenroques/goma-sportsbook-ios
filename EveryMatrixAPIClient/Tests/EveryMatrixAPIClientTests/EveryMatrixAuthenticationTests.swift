import XCTest
import Combine
import Foundation
@testable import EveryMatrixAPIClient

class EveryMatrixAuthenticationTests: XCTestCase {

    var cancellables = Set<AnyCancellable>()
    var testSession: URLSession!

    override func setUp() {
        super.setUp()
        // Configure URLSession with MockURLProtocol
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        testSession = URLSession(configuration: configuration)
    }

    override func tearDown() {
        MockURLProtocol.reset()
        cancellables.removeAll()
        testSession = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    /// Creates a test client with the configured test session
    private func createTestClient() -> EveryMatrixPAMAPIClient {
        // Create an authenticator
        let authenticator = EveryMatrixAuthenticator()

        // Create a connector with the test session
        let connector = EveryMatrixConnector(authenticator: authenticator, session: testSession, decoder: JSONDecoder())

        // Create a client with the connector
        return EveryMatrixPAMAPIClient(
            configuration: EveryMatrixConfiguration(environment: .staging),
            connector: connector
        )
    }

    // MARK: - Test Methods

    func testLoginMatchesCurlRequest() {
        let client = createTestClient()

        // Setup mock response
        let responseJSON = """
        {
            "sessionID": "b8216a1d-ef92-40b2-9d3f-7a394150042e",
            "universalID": "player-123456",
            "hasToAcceptTC": false,
            "hasToSetPass": false
        }
        """
        let expectation = self.expectation(description: "Login request made")
        var capturedRequest: URLRequest?

        // Setup request handler to capture and verify the request
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            return (responseJSON.data(using: .utf8), nil, HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil))
        }

        client.login(username: "jobit11000", password: "P@ssw0rd123!")
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success but got error: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)

        // Verify the request matches the curl example
        guard let request = capturedRequest else {
            XCTFail("No request was captured")
            return
        }

        let urlString = request.url?.absoluteString ?? ""
        XCTAssertTrue(urlString.hasPrefix("https://betsson-api.stage.norway.everymatrix.com/v1/player/login/player"))
        XCTAssertEqual(request.httpMethod, "POST")

        // Verify request body
        guard let httpBody = request.httpBody,
              let requestBody = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: Any] else {
            XCTFail("Invalid request body")
            return
        }
        XCTAssertEqual(requestBody["username"] as? String, "jobit11000")
        XCTAssertEqual(requestBody["password"] as? String, "P@ssw0rd123!")
    }

    func testRegisterMatchesCurlRequest() {
        let client = createTestClient()

        // Create a registration request that matches the curl example
        let birthDate = BirthDate(day: 15, month: 6, year: 1987)
        let mobile = MobilePhone(prefix: "+351", number: "912345678")
        let userConsents = UserConsents(
            termsAndConditions: true,
            emailMarketing: true,
            sms: true,
            thirdParty: false
        )

        let request = RegistrationRequest(
            username: "mesapad203",
            firstname: "John",
            lastname: "Doe",
            motherMaidenName: "Smith",
            address1: "123 Main Street",
            birth: birthDate,
            city: "Lisbon",
            country: "PT",
            currency: "EUR",
            email: "mesapad203@buides.com",
            postalCode: "1000-001",
            password: "P@ssw0rd123!",
            title: "Mr.",
            securityAnswer: "Blue",
            securityQuestion: "What is your favorite color?",
            mobile: mobile,
            address2: "Apartment 4B",
            userConsents: userConsents,
            nationality: "Portuguese",
            personalId: "12345678Z",
            birthPlace: "Porto",
            affiliateMarker: "AFF2025",
            alias: "jd87",
            language: "pt",
            gender: "male",
            iban: "PT50000201231234567890154"
        )

        // Setup mock response
        let responseJSON = """
            {
            "username": "mesapad203",
            "firstname": "John",
            "lastname": "Doe",
            "address1": "123 Main Street",
            "birth": {
                "day": 15,
                "month": 6,
                "year": 1987
            },
            "city": "Lisbon",
            "country": "PT",
            "currency": "EUR",
            "email": "mesapad203@buides.com",
            "mobile": {
                "prefix": "+351",
                "number": "912345678"
            },
            "address2": "Apartment 4B",
            "personalId": "12345678Z",
            "alias": "jd87",
            "id": "b8216a1d-ef92-40b2-9d3f-7a394150042e"
            }
        """

        let expectation = self.expectation(description: "Register request made")
        var capturedRequest: URLRequest?

        // Setup request handler to capture and verify the request
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(
                url: URL(string: "https://betsson-api.stage.norway.everymatrix.com/v1/player/register")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )
            return (responseJSON.data(using: .utf8), nil, response)
        }

        client.register(request: request)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success but got error: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)

        // Verify the request matches the curl example
        guard let request = capturedRequest else {
            XCTFail("No request was captured")
            return
        }

        let urlString = request.url?.absoluteString ?? ""
        XCTAssertTrue(urlString.hasPrefix("https://betsson-api.stage.norway.everymatrix.com/v1/player/register"))
        XCTAssertEqual(request.httpMethod, "PUT")
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")

        // Verify request body with better error handling
        guard let httpBody = request.httpBody else {
            XCTFail("Request body is nil")
            return
        }

        guard let requestBody = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: Any] else {
            if let bodyString = String(data: httpBody, encoding: .utf8) {
                XCTFail("Invalid JSON in request body: \(bodyString)")
            } else {
                XCTFail("Invalid request body and couldn't convert to string")
            }
            return
        }

        XCTAssertEqual(requestBody["username"] as? String, "mesapad203")
        XCTAssertEqual(requestBody["firstname"] as? String, "John")
        XCTAssertEqual(requestBody["lastname"] as? String, "Doe")
        XCTAssertEqual(requestBody["email"] as? String, "mesapad203@buides.com")

        // Check nested objects
        let birth = requestBody["birth"] as? [String: Any]
        XCTAssertNotNil(birth)
        XCTAssertEqual(birth?["day"] as? Int, 15)
        XCTAssertEqual(birth?["month"] as? Int, 6)
        XCTAssertEqual(birth?["year"] as? Int, 1987)

        let userConsentsData = requestBody["userConsents"] as? [String: Any]
        XCTAssertNotNil(userConsentsData)
        XCTAssertEqual(userConsentsData?["termsandconditions"] as? Bool, true)
        XCTAssertEqual(userConsentsData?["emailmarketing"] as? Bool, true)
        XCTAssertEqual(userConsentsData?["sms"] as? Bool, true)
        XCTAssertEqual(userConsentsData?["3rdparty"] as? Bool, false)
    }

    func testLogoutMatchesCurlRequest() {
        let client = createTestClient()
        let sessionId = "b8216a1d-ef92-40b2-9d3f-7a394150042e"
        let expectation = self.expectation(description: "Logout request made")
        var capturedRequest: URLRequest?

        // Setup request handler to capture and verify the request
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            return ("{}".data(using: .utf8), nil, HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil))
        }

        client.logout(sessionId: sessionId)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)

        // Verify the request matches the curl example
        guard let request = capturedRequest else {
            XCTFail("No request was captured")
            return
        }

        let urlString = request.url?.absoluteString ?? ""
        XCTAssertTrue(urlString.hasPrefix("https://betsson-api.stage.norway.everymatrix.com/v1/player/session/player"))
        XCTAssertEqual(request.httpMethod, "DELETE")
        XCTAssertEqual(request.allHTTPHeaderFields?["X-SessionId"], sessionId)
    }

    func testErrorHandling() {
        let client = createTestClient()

        // Setup mock error response for login
        MockURLProtocol.responseError = URLError(.badServerResponse)

        // Test login error handling
        let loginExpectation = self.expectation(description: "Login error handled")
        var loginError: Error?

        client.login(username: "baduser", password: "badpass")
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        loginError = error
                        loginExpectation.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)
        XCTAssertNotNil(loginError)

        // Reset mock for registration test
        MockURLProtocol.reset()
        MockURLProtocol.responseError = URLError(.badServerResponse)

        // Test registration error handling
        let registerExpectation = self.expectation(description: "Registration error handled")
        var registerError: Error?

        // Create a minimal registration request
        let birthDate = BirthDate(day: 1, month: 1, year: 2000)
        let mobile = MobilePhone(prefix: "+1", number: "5555555555")
        let userConsents = UserConsents(
            termsAndConditions: true,
            emailMarketing: false,
            sms: false,
            thirdParty: false
        )

        let request = RegistrationRequest(
            username: "testuser",
            firstname: "Test",
            lastname: "User",
            motherMaidenName: "Mother",
            address1: "123 Test St",
            birth: birthDate,
            city: "Test City",
            country: "US",
            currency: "USD",
            email: "test@test.com",
            postalCode: "12345",
            password: "password123",
            title: "Mr",
            securityAnswer: "Answer",
            securityQuestion: "Question",
            mobile: mobile,
            userConsents: userConsents
        )

        client.register(request: request)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        registerError = error
                        registerExpectation.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)
        XCTAssertNotNil(registerError)
    }
}