import XCTest
import Combine
@testable import ServicesProvider

/// Integration tests for the Boosted Odds Banners endpoint
class BoostedOddsBannersTests: BaseIntegrationTest {
    
    /// Test that GomaPromotionsAPIClient.boostedOddsBanners endpoint builds the correct URL with query parameters
    func testBoostedOddsBannersEndpointBuildsCorrectURL() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )
        
        // When
        let request = apiClient.boostedOddsBanners()
        
        // Then
        XCTAssertEqual(
            request.url?.absoluteString,
            "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.boostedOddsBanners)"
        )
    }
    
    /// Test that GomaPromotionsAPIClient.boostedOddsBanners endpoint uses the correct HTTP method (GET)
    func testBoostedOddsBannersEndpointUsesCorrectHTTPMethod() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )
        
        // When
        let request = apiClient.boostedOddsBanners()
        
        // Then
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    /// Test that the JSON response for boostedOddsBanners decodes to [GomaModels.BoostedOddsBannerData]
    func testBoostedOddsBannersResponseDecodesToInternalModel() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.boostedOddsBanners
        )
        
        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let boostedOddsBanners = try decoder.decode([GomaModels.BoostedOddsBannerData].self, from: jsonData)
        
        // Then
        XCTAssertNotNil(boostedOddsBanners)
        XCTAssertFalse(boostedOddsBanners.isEmpty, "Boosted Odds Banners array should not be empty")
        
        // Verify first boosted odds banner has all required properties
        if let firstBanner = boostedOddsBanners.first {
            XCTAssertNotNil(firstBanner.id)
            XCTAssertNotNil(firstBanner.title)
            XCTAssertNotNil(firstBanner.imageUrl)
            XCTAssertNotNil(firstBanner.status)
            XCTAssertNotNil(firstBanner.originalOdd)
            XCTAssertNotNil(firstBanner.boostedOdd)
            XCTAssertNotNil(firstBanner.event)
        }
    }
    
    /// Test that GomaModelMapper.boostedOddsBanner transforms GomaModels.BoostedOddsBannerData to BoostedOddsBanner correctly
    func testSingleBoostedOddsBannerModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.boostedOddsBanners
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let boostedOddsBanners = try decoder.decode([GomaModels.BoostedOddsBannerData].self, from: jsonData)
        
        // Ensure we have at least one boosted odds banner to test
        guard let internalModel = boostedOddsBanners.first else {
            XCTFail("No boosted odds banners found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.boostedOddsBanner(fromInternalBoostedOddsBanner: internalModel)
        
        // Then
        XCTAssertEqual(domainModel.id, internalModel.id)
        XCTAssertEqual(domainModel.title, internalModel.title)
        
        // Check URL transformation
        if let imageUrl = internalModel.imageUrl {
            XCTAssertEqual(domainModel.imageUrl?.absoluteString, imageUrl)
        } else {
            XCTAssertNil(domainModel.imageUrl)
        }
        
        // Check action URL transformation
        if let actionUrl = internalModel.actionUrl {
            XCTAssertEqual(domainModel.actionUrl?.absoluteString, actionUrl)
        } else {
            XCTAssertNil(domainModel.actionUrl)
        }
        
        // Check isActive transformation
        if internalModel.status == "published" {
            XCTAssertTrue(domainModel.isActive)
        } else {
            XCTAssertFalse(domainModel.isActive)
        }
    }
    
    /// Test that GomaModelMapper.boostedOddsBanners transforms array of GomaModels.BoostedOddsBannerData to [BoostedOddsBanner] correctly
    func testBoostedOddsBannersArrayModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.boostedOddsBanners
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModels = try decoder.decode([GomaModels.BoostedOddsBannerData].self, from: jsonData)
        
        // When
        let domainModels = GomaModelMapper.boostedOddsBanners(fromInternalBoostedOddsBanners: internalModels)
        
        // Then
        XCTAssertEqual(domainModels.count, internalModels.count, "Domain model count should match internal model count")
        
        // Check that each boosted odds banner was transformed correctly
        for (index, internalModel) in internalModels.enumerated() {
            let domainModel = domainModels[index]
            
            XCTAssertEqual(domainModel.id, internalModel.id)
            XCTAssertEqual(domainModel.title, internalModel.title)
            
            // Check URL transformation
            if let imageUrl = internalModel.imageUrl {
                XCTAssertEqual(domainModel.imageUrl?.absoluteString, imageUrl)
            } else {
                XCTAssertNil(domainModel.imageUrl)
            }
        }
    }
    
    /// Test originalOdd and boostedOdd values are correctly mapped
    func testOddsValuesAreCorrectlyMapped() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.boostedOddsBanners
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let boostedOddsBanners = try decoder.decode([GomaModels.BoostedOddsBannerData].self, from: jsonData)
        
        // Ensure we have at least one boosted odds banner to test
        guard let internalModel = boostedOddsBanners.first else {
            XCTFail("No boosted odds banners found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.boostedOddsBanner(fromInternalBoostedOddsBanner: internalModel)
        
        // Then
        XCTAssertEqual(domainModel.originalOdd, internalModel.originalOdd)
        XCTAssertEqual(domainModel.boostedOdd, internalModel.boostedOdd)
    }
    
    /// Test nested SportEventData mapping to SportEventSummary
    func testNestedSportEventDataMapping() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.boostedOddsBanners
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let boostedOddsBanners = try decoder.decode([GomaModels.BoostedOddsBannerData].self, from: jsonData)
        
        // Ensure we have at least one boosted odds banner with event data to test
        guard let internalModel = boostedOddsBanners.first, let eventData = internalModel.event else {
            XCTFail("No boosted odds banners with event data found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.boostedOddsBanner(fromInternalBoostedOddsBanner: internalModel)
        
        // Then
        XCTAssertNotNil(domainModel.event)
        XCTAssertEqual(domainModel.event?.id, eventData.id)
        XCTAssertEqual(domainModel.event?.sportId, eventData.sportId)
        XCTAssertEqual(domainModel.event?.competitionId, eventData.competitionId)
        
        // Check date transformation
        if let dateTimeString = eventData.dateTime {
            let dateFormatter = ISO8601DateFormatter()
            let expectedDate = dateFormatter.date(from: dateTimeString)
            XCTAssertEqual(domainModel.event?.dateTime, expectedDate)
        } else {
            XCTAssertNil(domainModel.event?.dateTime)
        }
        
        // Check team data if present
        if let homeTeam = eventData.homeTeam, let awayTeam = eventData.awayTeam {
            XCTAssertEqual(domainModel.event?.homeTeam.id, homeTeam.id)
            XCTAssertEqual(domainModel.event?.homeTeam.name, homeTeam.name)
            XCTAssertEqual(domainModel.event?.awayTeam.id, awayTeam.id)
            XCTAssertEqual(domainModel.event?.awayTeam.name, awayTeam.name)
        }
    }
    
    /// Test URL construction for imageUrl field
    func testURLConstructionForImageUrl() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.boostedOddsBanners
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let boostedOddsBanners = try decoder.decode([GomaModels.BoostedOddsBannerData].self, from: jsonData)
        
        // Ensure we have at least one boosted odds banner to test
        guard let internalModel = boostedOddsBanners.first else {
            XCTFail("No boosted odds banners found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.boostedOddsBanner(fromInternalBoostedOddsBanner: internalModel)
        
        // Then
        if let imageUrl = internalModel.imageUrl {
            XCTAssertEqual(domainModel.imageUrl?.absoluteString, imageUrl)
        } else {
            XCTAssertNil(domainModel.imageUrl)
        }
    }
    
    /// Test that GomaManagedContentProvider.getBoostedOddsBanners() calls the correct API endpoint
    func testGetBoostedOddsBannersCallsCorrectAPIEndpoint() throws {
        // Given
        let expectation = XCTestExpectation(description: "API call made")
        try registerMockBoostedOddsBannersResponse()
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getBoostedOddsBanners()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(MockURLProtocol.requestsForEndpoint(TestConfiguration.EndpointPaths.boostedOddsBanners).count > 0)
    }
    
    /// Test that GomaManagedContentProvider.getBoostedOddsBanners() handles successful responses
    func testGetBoostedOddsBannersHandlesSuccessfulResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received boosted odds banners")
        try registerMockBoostedOddsBannersResponse()
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getBoostedOddsBanners()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { boostedOddsBanners in
                    // Then
                    XCTAssertNotNil(boostedOddsBanners)
                    XCTAssertFalse(boostedOddsBanners.isEmpty, "Boosted Odds Banners array should not be empty")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    /// Test that GomaManagedContentProvider.getBoostedOddsBanners() handles error responses
    func testGetBoostedOddsBannersHandlesErrorResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received error")
        
        // Register a mock error response
        let errorURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.boostedOddsBanners)")!
        MockURLProtocol.registerMockResponse(
            for: errorURL,
            data: "Internal Server Error".data(using: .utf8)!,
            statusCode: 500
        )
        
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getBoostedOddsBanners()
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
    
    /// Test that GomaManagedContentProvider.getBoostedOddsBanners() handles empty array responses
    func testGetBoostedOddsBannersHandlesEmptyArrayResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received empty array")
        
        // Register a mock empty array response
        let emptyURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.boostedOddsBanners)")!
        MockURLProtocol.registerMockResponse(
            for: emptyURL,
            data: "[]".data(using: .utf8)!,
            statusCode: 200
        )
        
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getBoostedOddsBanners()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Empty array should not cause failure")
                    }
                },
                receiveValue: { boostedOddsBanners in
                    // Then
                    XCTAssertTrue(boostedOddsBanners.isEmpty, "Boosted Odds Banners array should be empty")
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
        try registerMockBoostedOddsBannersResponse()
        let contentProvider = createMockContentProvider()
        
        // Load the expected data for comparison
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.boostedOddsBanners
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModels = try decoder.decode([GomaModels.BoostedOddsBannerData].self, from: jsonData)
        let expectedDomainModels = GomaModelMapper.boostedOddsBanners(fromInternalBoostedOddsBanners: internalModels)
        
        // When
        contentProvider.getBoostedOddsBanners()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { boostedOddsBanners in
                    // Then
                    XCTAssertEqual(boostedOddsBanners.count, expectedDomainModels.count)
                    
                    // Compare each boosted odds banner with its expected model
                    for (index, expectedBanner) in expectedDomainModels.enumerated() {
                        let actualBanner = boostedOddsBanners[index]
                        
                        XCTAssertEqual(actualBanner.id, expectedBanner.id)
                        XCTAssertEqual(actualBanner.title, expectedBanner.title)
                        XCTAssertEqual(actualBanner.isActive, expectedBanner.isActive)
                        XCTAssertEqual(actualBanner.originalOdd, expectedBanner.originalOdd)
                        XCTAssertEqual(actualBanner.boostedOdd, expectedBanner.boostedOdd)
                        
                        // Compare URLs
                        if let expectedImageURL = expectedBanner.imageUrl {
                            XCTAssertEqual(actualBanner.imageUrl?.absoluteString, expectedImageURL.absoluteString)
                        } else {
                            XCTAssertNil(actualBanner.imageUrl)
                        }
                        
                        if let expectedActionURL = expectedBanner.actionUrl {
                            XCTAssertEqual(actualBanner.actionUrl?.absoluteString, expectedActionURL.absoluteString)
                        } else {
                            XCTAssertNil(actualBanner.actionUrl)
                        }
                        
                        // Compare event data if present
                        if let expectedEvent = expectedBanner.event, let actualEvent = actualBanner.event {
                            XCTAssertEqual(actualEvent.id, expectedEvent.id)
                            XCTAssertEqual(actualEvent.sportId, expectedEvent.sportId)
                            XCTAssertEqual(actualEvent.competitionId, expectedEvent.competitionId)
                            
                            // Compare teams if present
                            if expectedEvent.homeTeam != nil && expectedEvent.awayTeam != nil {
                                XCTAssertEqual(actualEvent.homeTeam.id, expectedEvent.homeTeam.id)
                                XCTAssertEqual(actualEvent.homeTeam.name, expectedEvent.homeTeam.name)
                                XCTAssertEqual(actualEvent.awayTeam.id, expectedEvent.awayTeam.id)
                                XCTAssertEqual(actualEvent.awayTeam.name, expectedEvent.awayTeam.name)
                            }
                            
                            // Compare date
                            if let expectedDate = expectedEvent.dateTime {
                                XCTAssertEqual(actualEvent.dateTime, expectedDate)
                            } else {
                                XCTAssertNil(actualEvent.dateTime)
                            }
                        } else {
                            XCTAssertEqual(actualBanner.event == nil, expectedBanner.event == nil)
                        }
                    }
                    
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
} 
