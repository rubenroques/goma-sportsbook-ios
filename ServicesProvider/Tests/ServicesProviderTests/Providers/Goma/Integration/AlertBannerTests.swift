import XCTest
import Combine
@testable import ServicesProvider

/// Integration tests for the Alert Banner endpoint
class AlertBannerTests: BaseIntegrationTest {
    
    /// Test that GomaPromotionsAPIClient.alertBanner endpoint builds the correct URL with query parameters
    func testAlertBannerEndpointBuildsCorrectURL() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )
        
        // When
        let request = apiClient.alertBanner()
        
        // Then
        XCTAssertEqual(
            request.url?.absoluteString,
            "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.alertBanner)"
        )
    }
    
    /// Test that GomaPromotionsAPIClient.alertBanner endpoint uses the correct HTTP method (GET)
    func testAlertBannerEndpointUsesCorrectHTTPMethod() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )
        
        // When
        let request = apiClient.alertBanner()
        
        // Then
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    /// Test that the JSON response for alertBanner decodes to GomaModels.AlertBannerData
    func testAlertBannerResponseDecodesToInternalModel() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.alertBanner,
            filename: "response.json"
        )
        
        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let alertBanner = try decoder.decode(GomaModels.AlertBannerData.self, from: jsonData)
        
        // Then
        XCTAssertNotNil(alertBanner)
        XCTAssertNotNil(alertBanner.id)
        XCTAssertNotNil(alertBanner.title)
        XCTAssertNotNil(alertBanner.subtitle)
        XCTAssertNotNil(alertBanner.ctaText)
        XCTAssertNotNil(alertBanner.ctaUrl)
        XCTAssertNotNil(alertBanner.status)
    }
    
    /// Test that GomaModelMapper.alertBanner transforms GomaModels.AlertBannerData to AlertBanner correctly
    func testAlertBannerModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.alertBanner,
            filename: "response.json"
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModel = try decoder.decode(GomaModels.AlertBannerData.self, from: jsonData)
        
        // When
        let domainModel = GomaModelMapper.alertBanner(from: internalModel)
        
        // Then
        XCTAssertEqual(domainModel.id, internalModel.id)
        XCTAssertEqual(domainModel.title, internalModel.title)
        XCTAssertEqual(domainModel.subtitle, internalModel.subtitle)
        XCTAssertEqual(domainModel.ctaText, internalModel.ctaText)
        
        // Check URL transformation
        if let ctaUrl = internalModel.ctaUrl {
            XCTAssertEqual(domainModel.ctaUrl?.absoluteString, ctaUrl)
        } else {
            XCTAssertNil(domainModel.ctaUrl)
        }
    }
    
    /// Test that transformation correctly sets isActive based on status field
    func testIsActiveIsCorrectlyMappedFromStatus() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.alertBanner,
            filename: "response.json"
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModel = try decoder.decode(GomaModels.AlertBannerData.self, from: jsonData)
        
        // When
        let domainModel = GomaModelMapper.alertBanner(from: internalModel)
        
        // Then
        if internalModel.status == "published" {
            XCTAssertTrue(domainModel.isActive)
        } else {
            XCTAssertFalse(domainModel.isActive)
        }
    }
    
    /// Test URL construction for imageUrl field
    func testURLConstructionForImageUrl() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.alertBanner,
            filename: "response.json"
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModel = try decoder.decode(GomaModels.AlertBannerData.self, from: jsonData)
        
        // When
        let domainModel = GomaModelMapper.alertBanner(from: internalModel)
        
        // Then
        if let ctaUrl = internalModel.ctaUrl {
            XCTAssertEqual(domainModel.ctaUrl?.absoluteString, ctaUrl)
        } else {
            XCTAssertNil(domainModel.ctaUrl)
        }
    }
    
    /// Test that GomaManagedContentProvider.getAlertBanner() calls the correct API endpoint
    func testGetAlertBannerCallsCorrectAPIEndpoint() throws {
        // Given
        let expectation = XCTestExpectation(description: "API call made")
        try registerMockAlertBannerResponse()
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getAlertBanner()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(MockURLProtocol.requestsForEndpoint(TestConfiguration.EndpointPaths.alertBanner).count > 0)
    }
    
    /// Test that GomaManagedContentProvider.getAlertBanner() handles successful responses
    func testGetAlertBannerHandlesSuccessfulResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received alert banner")
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
                receiveValue: { alertBanner in
                    // Then
                    XCTAssertNotNil(alertBanner)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    /// Test that GomaManagedContentProvider.getAlertBanner() handles error responses
    func testGetAlertBannerHandlesErrorResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received error")
        
        // Register a mock error response
        let errorURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.alertBanner)")!
        MockURLProtocol.registerMockResponse(
            for: errorURL,
            statusCode: 500,
            data: "Internal Server Error".data(using: .utf8)!
        )
        
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getAlertBanner()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        // Then
                        XCTAssertNotNil(error)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail("Should not receive a value")
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    /// Test that GomaManagedContentProvider.getAlertBanner() handles empty/null responses
    func testGetAlertBannerHandlesEmptyResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received empty response")
        
        // Register a mock empty response
        let emptyURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.alertBanner)")!
        MockURLProtocol.registerMockResponse(
            for: emptyURL,
            statusCode: 200,
            data: "{}".data(using: .utf8)!
        )
        
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getAlertBanner()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        expectation.fulfill()
                    }
                },
                receiveValue: { alertBanner in
                    // Then
                    // If we get a value, it should be a default/empty alert banner
                    XCTAssertEqual(alertBanner.id, 0)
                    XCTAssertEqual(alertBanner.title, "")
                    XCTAssertEqual(alertBanner.subtitle, "")
                    XCTAssertNil(alertBanner.ctaUrl)
                    XCTAssertEqual(alertBanner.ctaText, "")
                    XCTAssertFalse(alertBanner.isActive)
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
        try registerMockAlertBannerResponse()
        let contentProvider = createMockContentProvider()
        
        // Load the expected data for comparison
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.alertBanner,
            filename: "response.json"
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModel = try decoder.decode(GomaModels.AlertBannerData.self, from: jsonData)
        let expectedDomainModel = GomaModelMapper.alertBanner(from: internalModel)
        
        // When
        contentProvider.getAlertBanner()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { alertBanner in
                    // Then
                    XCTAssertEqual(alertBanner.id, expectedDomainModel.id)
                    XCTAssertEqual(alertBanner.title, expectedDomainModel.title)
                    XCTAssertEqual(alertBanner.subtitle, expectedDomainModel.subtitle)
                    XCTAssertEqual(alertBanner.ctaText, expectedDomainModel.ctaText)
                    
                    // Compare URLs
                    if let expectedURL = expectedDomainModel.ctaUrl {
                        XCTAssertEqual(alertBanner.ctaUrl?.absoluteString, expectedURL.absoluteString)
                    } else {
                        XCTAssertNil(alertBanner.ctaUrl)
                    }
                    
                    XCTAssertEqual(alertBanner.isActive, expectedDomainModel.isActive)
                    
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
} 