import XCTest
import Combine
@testable import ServicesProvider

/// Integration tests for the Banners endpoint
class BannersTests: BaseIntegrationTest {
    
    /// Test that GomaPromotionsAPIClient.banners endpoint builds the correct URL with query parameters
    func testBannersEndpointBuildsCorrectURL() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )
        
        // When
        let request = apiClient.banners()
        
        // Then
        XCTAssertEqual(
            request.url?.absoluteString,
            "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.banners)"
        )
    }
    
    /// Test that GomaPromotionsAPIClient.banners endpoint uses the correct HTTP method (GET)
    func testBannersEndpointUsesCorrectHTTPMethod() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )
        
        // When
        let request = apiClient.banners()
        
        // Then
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    /// Test that the JSON response for banners decodes to [GomaModels.Banner]
    func testBannersResponseDecodesToInternalModel() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.banners
        )
        
        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let banners = try decoder.decode([GomaModels.Banner].self, from: jsonData)
        
        // Then
        XCTAssertNotNil(banners)
        XCTAssertFalse(banners.isEmpty, "Banners array should not be empty")
        
        // Verify first banner has all required properties
        if let firstBanner = banners.first {
            XCTAssertNotNil(firstBanner.id)
            XCTAssertNotNil(firstBanner.title)
            XCTAssertNotNil(firstBanner.imageUrl)
            XCTAssertNotNil(firstBanner.status)
        }
    }
    
    /// Test that GomaModelMapper.banner transforms single GomaModels.Banner to Banner correctly
    func testSingleBannerModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.banners
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let banners = try decoder.decode([GomaModels.Banner].self, from: jsonData)
        
        // Ensure we have at least one banner to test
        guard let internalModel = banners.first else {
            XCTFail("No banners found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.banner(fromInternalBanner: internalModel)
        
        // Then
        XCTAssertEqual(domainModel.id, internalModel.id)
        XCTAssertEqual(domainModel.title, internalModel.title)
        XCTAssertEqual(domainModel.subtitle, internalModel.subtitle)
        XCTAssertEqual(domainModel.ctaText, internalModel.ctaText)
        XCTAssertEqual(domainModel.ctaUrl, internalModel.ctaUrl)
        XCTAssertEqual(domainModel.platform, internalModel.platform)
        XCTAssertEqual(domainModel.status, internalModel.status)
        XCTAssertEqual(domainModel.startDate, internalModel.startDate)
        XCTAssertEqual(domainModel.endDate, internalModel.endDate)
        XCTAssertEqual(domainModel.userType, internalModel.userType)
        XCTAssertEqual(domainModel.imageUrl, internalModel.imageUrl)
    }
    
    /// Test that GomaModelMapper.banners transforms array of GomaModels.Banner to [Banner] correctly
    func testBannersArrayModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.banners
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModels = try decoder.decode([GomaModels.Banner].self, from: jsonData)
        
        // When
        let domainModels = GomaModelMapper.banners(fromInternalBanners: internalModels)
        
        // Then
        XCTAssertEqual(domainModels.count, internalModels.count, "Domain model count should match internal model count")
        
        // Check that each banner was transformed correctly
        for (index, internalModel) in internalModels.enumerated() {
            let domainModel = domainModels[index]
            
            XCTAssertEqual(domainModel.id, internalModel.id)
            XCTAssertEqual(domainModel.title, internalModel.title)
            XCTAssertEqual(domainModel.subtitle, internalModel.subtitle)
            XCTAssertEqual(domainModel.ctaText, internalModel.ctaText)
            XCTAssertEqual(domainModel.ctaUrl, internalModel.ctaUrl)
            XCTAssertEqual(domainModel.platform, internalModel.platform)
            XCTAssertEqual(domainModel.status, internalModel.status)
            XCTAssertEqual(domainModel.startDate, internalModel.startDate)
            XCTAssertEqual(domainModel.endDate, internalModel.endDate)
            XCTAssertEqual(domainModel.userType, internalModel.userType)
            XCTAssertEqual(domainModel.imageUrl, internalModel.imageUrl)
        }
    }
    
    /// Test that GomaManagedContentProvider.getBanners() calls the correct API endpoint
    func testGetBannersCallsCorrectAPIEndpoint() throws {
        // Given
        let expectation = XCTestExpectation(description: "API call made")
        try registerMockBannersResponse()
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getBanners()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(MockURLProtocol.requestsForEndpoint(TestConfiguration.EndpointPaths.banners).count > 0)
    }
    
    /// Test that GomaManagedContentProvider.getBanners() handles successful responses
    func testGetBannersHandlesSuccessfulResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received banners")
        try registerMockBannersResponse()
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getBanners()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { banners in
                    // Then
                    XCTAssertNotNil(banners)
                    XCTAssertFalse(banners.isEmpty, "Banners array should not be empty")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    /// Test that GomaManagedContentProvider.getBanners() handles error responses
    func testGetBannersHandlesErrorResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received error")
        
        // Register a mock error response
        let errorURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.banners)")!
        MockURLProtocol.registerMockResponse(
            for: errorURL,
            data: "Internal Server Error".data(using: .utf8)!,
            statusCode: 500
        )
        
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getBanners()
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
    
    /// Test that GomaManagedContentProvider.getBanners() handles empty array responses
    func testGetBannersHandlesEmptyArrayResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received empty array")
        
        // Register a mock empty array response
        let emptyURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.banners)")!
        MockURLProtocol.registerMockResponse(
            for: emptyURL,
            data: "[]".data(using: .utf8)!,
            statusCode: 200
        )
        
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getBanners()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Empty array should not cause failure")
                    }
                },
                receiveValue: { banners in
                    // Then
                    XCTAssertTrue(banners.isEmpty, "Banners array should be empty")
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
        try registerMockBannersResponse()
        let contentProvider = createMockContentProvider()
        
        // Load the expected data for comparison
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.banners
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModels = try decoder.decode([GomaModels.Banner].self, from: jsonData)
        let expectedDomainModels = GomaModelMapper.banners(fromInternalBanners: internalModels)
        
        // When
        contentProvider.getBanners()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { banners in
                    // Then
                    XCTAssertEqual(banners.count, expectedDomainModels.count)
                    
                    // Compare each banner with its expected model
                    for (index, expectedBanner) in expectedDomainModels.enumerated() {
                        let actualBanner = banners[index]
                        
                        XCTAssertEqual(actualBanner.id, expectedBanner.id)
                        XCTAssertEqual(actualBanner.title, expectedBanner.title)
                        XCTAssertEqual(actualBanner.subtitle, expectedBanner.subtitle)
                        XCTAssertEqual(actualBanner.ctaText, expectedBanner.ctaText)
                        XCTAssertEqual(actualBanner.ctaUrl, expectedBanner.ctaUrl)
                        XCTAssertEqual(actualBanner.platform, expectedBanner.platform)
                        XCTAssertEqual(actualBanner.status, expectedBanner.status)
                        XCTAssertEqual(actualBanner.startDate, expectedBanner.startDate)
                        XCTAssertEqual(actualBanner.endDate, expectedBanner.endDate)
                        XCTAssertEqual(actualBanner.userType, expectedBanner.userType)
                        XCTAssertEqual(actualBanner.imageUrl, expectedBanner.imageUrl)
                    }
                    
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
} 