import XCTest
import Combine
@testable import ServicesProvider

/// Integration tests for the Alert Banner endpoint
class AlertBannerTests: BaseIntegrationTest {

    // Instance of our mock connector for testing
    private var mockConnector: MockGomaConnector!
    // Instance of our API client for testing
    private var apiClient: GomaAPIPromotionsClient!

    override func setUp() {
        super.setUp()
        mockConnector = MockGomaConnector(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )
        apiClient = GomaAPIPromotionsClient(connector: mockConnector)
    }

    /// Test that GomaAPIPromotionsClient.alertBanner endpoint builds the correct URL with query parameters
    func testAlertBannerEndpointBuildsCorrectURL() {
        // When
        let request = apiClient.requestFor(.alertBanner)

        // Then
        XCTAssertEqual(
            request?.url?.absoluteString,
            "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.alertBanner)"
        )
    }

    /// Test that GomaAPIPromotionsClient.alertBanner endpoint uses the correct HTTP method (GET)
    func testAlertBannerEndpointUsesCorrectHTTPMethod() {
        // When
        let request = apiClient.requestFor(.alertBanner)

        // Then
        XCTAssertEqual(request?.httpMethod, "GET")
    }

    /// Test that the JSON response for alertBanner decodes to GomaModels.AlertBanner
    func testAlertBannerResponseDecodesToInternalModel() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.alertBanner
        )

        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let alertBanner = try decoder.decode(GomaModels.AlertBanner.self, from: jsonData)

        // Then
        XCTAssertNotNil(alertBanner)
        XCTAssertNotNil(alertBanner.id)
        XCTAssertNotNil(alertBanner.title)
        XCTAssertNotNil(alertBanner.subtitle)
        XCTAssertNotNil(alertBanner.ctaText)
        XCTAssertNotNil(alertBanner.ctaUrl)
        XCTAssertNotNil(alertBanner.status)
    }

    /// Test that GomaModelMapper.alertBanner transforms GomaModels.AlertBanner to AlertBanner correctly
    func testAlertBannerModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.alertBanner
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModel = try decoder.decode(GomaModels.AlertBanner.self, from: jsonData)

        // When
        let domainModel = GomaModelMapper.alertBanner(fromInternalAlertBanner: internalModel)

        // Then
        XCTAssertEqual(domainModel.id, String(internalModel.id))
        XCTAssertEqual(domainModel.title, internalModel.title)
        XCTAssertEqual(domainModel.subtitle, internalModel.subtitle)
        XCTAssertEqual(domainModel.ctaText, internalModel.ctaText)
        XCTAssertEqual(domainModel.ctaUrl, internalModel.ctaUrl)
        XCTAssertEqual(domainModel.platform, internalModel.platform)
        XCTAssertEqual(domainModel.status, internalModel.status)
        XCTAssertEqual(domainModel.startDate, internalModel.startDate)
        XCTAssertEqual(domainModel.endDate, internalModel.endDate)
        XCTAssertEqual(domainModel.userType, internalModel.userType)
    }

    /// Test that GomaAPIPromotionsClient.alertBanner() makes the correct API call
    func testAlertBannerPublisherMakesCorrectAPICall() throws {
        // Given
        let expectation = XCTestExpectation(description: "API call made")
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.alertBanner
        )

        // Register the mock response with our mock connector
        let alertBannerURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.alertBanner)")!
        mockConnector.registerMockResponse(for: alertBannerURL, data: jsonData)

        // When
        apiClient.alertBanner<GomaModels.AlertBanner>()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { (alertBanner: GomaModels.AlertBanner) in
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockConnector.capturedEndpoints.contains { endpoint in
            if case .alertBanner = endpoint as? GomaAPIPromotionsSchema {
                return true
            }
            return false
        })
    }

    /// Test that GomaAPIPromotionsClient.alertBanner() handles successful responses
    func testAlertBannerPublisherHandlesSuccessfulResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received alert banner")
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.alertBanner
        )

        // Register the mock response with our mock connector
        let alertBannerURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.alertBanner)")!
        mockConnector.registerMockResponse(for: alertBannerURL, data: jsonData)

        // When
        apiClient.alertBanner<GomaModels.AlertBanner>()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { (alertBanner: GomaModels.AlertBanner) in
                    // Then
                    XCTAssertNotNil(alertBanner)
                    XCTAssertNotNil(alertBanner.id)
                    XCTAssertNotNil(alertBanner.title)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    /// Test that GomaAPIPromotionsClient.alertBanner() handles error responses
    func testAlertBannerPublisherHandlesErrorResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received error")

        // Register a mock error response
        let errorURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.alertBanner)")!
        mockConnector.registerMockResponse(
            for: errorURL,
            data: "Internal Server Error".data(using: .utf8)!,
            statusCode: 500
        )

        // When
        apiClient.alertBanner<GomaModels.AlertBanner>()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        // Then
                        XCTAssertNotNil(error)
                        expectation.fulfill()
                    }
                },
                receiveValue: { (alertBanner: GomaModels.AlertBanner) in
                    XCTFail("Should not receive a value")
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    /// Test that GomaAPIPromotionsClient.alertBanner() handles empty/null responses
    func testAlertBannerPublisherHandlesEmptyResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received empty response")

        // Register a mock empty response
        let emptyURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.alertBanner)")!
        mockConnector.registerMockResponse(
            for: emptyURL,
            data: "{}".data(using: .utf8)!,
            statusCode: 200
        )

        // When
        apiClient.alertBanner<GomaModels.AlertBanner>()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        expectation.fulfill()
                    }
                },
                receiveValue: { (alertBanner: GomaModels.AlertBanner) in
                    // Then
                    // If we get a value, it should have default values
                    XCTAssertEqual(alertBanner.id, "")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    /// Test the end-to-end flow with mocked API response to final domain model
    func testEndToEndFlowWithMockedAPIResponse() throws {
        // Given
        let expectation = XCTestExpectation(description: "End-to-end flow completed")

        // Load the expected data for comparison
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.alertBanner
        )

        // Register the mock response
        let alertBannerURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.alertBanner)")!
        mockConnector.registerMockResponse(for: alertBannerURL, data: jsonData)

        // Get the expected data for comparison
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModel = try decoder.decode(GomaModels.AlertBanner.self, from: jsonData)
        let expectedDomainModel = GomaModelMapper.alertBanner(fromInternalAlertBanner: internalModel)

        // We'll also need to test with the content provider so keep that test
        try registerMockAlertBannerResponse()
        let contentProvider = createMockContentProvider()

        // When
        contentProvider.getAlertBanner()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { (alertBanner: GomaModels.AlertBanner) in

                    guard let alertBanner = alertBanner else {
                        XCTFail("Should not be nil")
                        return
                    }

                    // Then
                    XCTAssertEqual(alertBanner.id, expectedDomainModel.id)
                    XCTAssertEqual(alertBanner.title, expectedDomainModel.title)
                    XCTAssertEqual(alertBanner.subtitle, expectedDomainModel.subtitle)
                    XCTAssertEqual(alertBanner.ctaText, expectedDomainModel.ctaText)
                    XCTAssertEqual(alertBanner.ctaUrl, expectedDomainModel.ctaUrl)
                    XCTAssertEqual(alertBanner.status, expectedDomainModel.status)
                    XCTAssertEqual(alertBanner.platform, expectedDomainModel.platform)
                    XCTAssertEqual(alertBanner.startDate, expectedDomainModel.startDate)
                    XCTAssertEqual(alertBanner.endDate, expectedDomainModel.endDate)
                    XCTAssertEqual(alertBanner.userType, expectedDomainModel.userType)

                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
}
