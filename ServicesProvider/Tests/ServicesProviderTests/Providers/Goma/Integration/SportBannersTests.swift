import XCTest
import Combine
@testable import ServicesProvider

/// Integration tests for the Sport Banners endpoint
class SportBannersTests: BaseIntegrationTest {
    
    /// Test that GomaPromotionsAPIClient.sportBanners endpoint builds the correct URL with query parameters
    func testSportBannersEndpointBuildsCorrectURL() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )
        
        // When
        let request = apiClient.sportBanners()
        
        // Then
        XCTAssertEqual(
            request.url?.absoluteString,
            "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.sportBanners)"
        )
    }
    
    /// Test that GomaPromotionsAPIClient.sportBanners endpoint uses the correct HTTP method (GET)
    func testSportBannersEndpointUsesCorrectHTTPMethod() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )
        
        // When
        let request = apiClient.sportBanners()
        
        // Then
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    /// Test that the JSON response for sportBanners decodes to [GomaModels.SportBannerData]
    func testSportBannersResponseDecodesToInternalModel() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.sportBanners,
            filename: "response.json"
        )
        
        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let sportBanners = try decoder.decode([GomaModels.SportBannerData].self, from: jsonData)
        
        // Then
        XCTAssertNotNil(sportBanners)
        XCTAssertFalse(sportBanners.isEmpty, "Sport Banners array should not be empty")
        
        // Verify first sport banner has all required properties
        if let firstBanner = sportBanners.first {
            XCTAssertNotNil(firstBanner.id)
            XCTAssertNotNil(firstBanner.title)
            XCTAssertNotNil(firstBanner.imageUrl)
            XCTAssertNotNil(firstBanner.status)
            XCTAssertNotNil(firstBanner.event)
        }
    }
    
    /// Test that GomaModelMapper.sportBanner transforms GomaModels.SportBannerData to SportBanner correctly
    func testSingleSportBannerModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.sportBanners,
            filename: "response.json"
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let sportBanners = try decoder.decode([GomaModels.SportBannerData].self, from: jsonData)
        
        // Ensure we have at least one sport banner to test
        guard let internalModel = sportBanners.first else {
            XCTFail("No sport banners found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.sportBanner(from: internalModel)
        
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
    
    /// Test that GomaModelMapper.sportBanners transforms array of GomaModels.SportBannerData to [SportBanner] correctly
    func testSportBannersArrayModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.sportBanners,
            filename: "response.json"
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModels = try decoder.decode([GomaModels.SportBannerData].self, from: jsonData)
        
        // When
        let domainModels = GomaModelMapper.sportBanners(from: internalModels)
        
        // Then
        XCTAssertEqual(domainModels.count, internalModels.count, "Domain model count should match internal model count")
        
        // Check that each sport banner was transformed correctly
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
    
    /// Test nested SportEventData mapping to SportEventSummary
    func testNestedSportEventDataMapping() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.sportBanners,
            filename: "response.json"
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let sportBanners = try decoder.decode([GomaModels.SportBannerData].self, from: jsonData)
        
        // Ensure we have at least one sport banner with event data to test
        guard let internalModel = sportBanners.first, let eventData = internalModel.event else {
            XCTFail("No sport banners with event data found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.sportBanner(from: internalModel)
        
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
    }
    
    /// Test team data mapping for home and away teams
    func testTeamDataMapping() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.sportBanners,
            filename: "response.json"
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let sportBanners = try decoder.decode([GomaModels.SportBannerData].self, from: jsonData)
        
        // Ensure we have at least one sport banner with event data to test
        guard let internalModel = sportBanners.first, 
              let eventData = internalModel.event,
              let homeTeam = eventData.homeTeam,
              let awayTeam = eventData.awayTeam else {
            XCTFail("No sport banners with complete team data found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.sportBanner(from: internalModel)
        
        // Then
        XCTAssertNotNil(domainModel.event?.homeTeam)
        XCTAssertNotNil(domainModel.event?.awayTeam)
        
        // Check home team mapping
        XCTAssertEqual(domainModel.event?.homeTeam.id, homeTeam.id)
        XCTAssertEqual(domainModel.event?.homeTeam.name, homeTeam.name)
        
        // Check away team mapping
        XCTAssertEqual(domainModel.event?.awayTeam.id, awayTeam.id)
        XCTAssertEqual(domainModel.event?.awayTeam.name, awayTeam.name)
    }
    
    /// Test URL construction for imageUrl and team logo URLs
    func testURLConstructionForImageAndLogoUrls() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.sportBanners,
            filename: "response.json"
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let sportBanners = try decoder.decode([GomaModels.SportBannerData].self, from: jsonData)
        
        // Ensure we have at least one sport banner with event data to test
        guard let internalModel = sportBanners.first, 
              let eventData = internalModel.event,
              let homeTeam = eventData.homeTeam,
              let awayTeam = eventData.awayTeam else {
            XCTFail("No sport banners with complete team data found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.sportBanner(from: internalModel)
        
        // Then
        // Check banner image URL
        if let imageUrl = internalModel.imageUrl {
            XCTAssertEqual(domainModel.imageUrl?.absoluteString, imageUrl)
        } else {
            XCTAssertNil(domainModel.imageUrl)
        }
        
        // Check home team logo URL
        if let logoUrl = homeTeam.logoUrl {
            XCTAssertEqual(domainModel.event?.homeTeam.logoUrl?.absoluteString, logoUrl)
        } else {
            XCTAssertNil(domainModel.event?.homeTeam.logoUrl)
        }
        
        // Check away team logo URL
        if let logoUrl = awayTeam.logoUrl {
            XCTAssertEqual(domainModel.event?.awayTeam.logoUrl?.absoluteString, logoUrl)
        } else {
            XCTAssertNil(domainModel.event?.awayTeam.logoUrl)
        }
    }
    
    /// Test that GomaManagedContentProvider.getSportBanners() calls the correct API endpoint
    func testGetSportBannersCallsCorrectAPIEndpoint() throws {
        // Given
        let expectation = XCTestExpectation(description: "API call made")
        try registerMockSportBannersResponse()
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getSportBanners()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(MockURLProtocol.requestsForEndpoint(TestConfiguration.EndpointPaths.sportBanners).count > 0)
    }
    
    /// Test that GomaManagedContentProvider.getSportBanners() handles successful responses
    func testGetSportBannersHandlesSuccessfulResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received sport banners")
        try registerMockSportBannersResponse()
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getSportBanners()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { sportBanners in
                    // Then
                    XCTAssertNotNil(sportBanners)
                    XCTAssertFalse(sportBanners.isEmpty, "Sport Banners array should not be empty")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    /// Test that GomaManagedContentProvider.getSportBanners() handles error responses
    func testGetSportBannersHandlesErrorResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received error")
        
        // Register a mock error response
        let errorURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.sportBanners)")!
        MockURLProtocol.registerMockResponse(
            for: errorURL,
            statusCode: 500,
            data: "Internal Server Error".data(using: .utf8)!
        )
        
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getSportBanners()
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
    
    /// Test that GomaManagedContentProvider.getSportBanners() handles empty array responses
    func testGetSportBannersHandlesEmptyArrayResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received empty array")
        
        // Register a mock empty array response
        let emptyURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.sportBanners)")!
        MockURLProtocol.registerMockResponse(
            for: emptyURL,
            statusCode: 200,
            data: "[]".data(using: .utf8)!
        )
        
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getSportBanners()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Empty array should not cause failure")
                    }
                },
                receiveValue: { sportBanners in
                    // Then
                    XCTAssertTrue(sportBanners.isEmpty, "Sport Banners array should be empty")
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
        try registerMockSportBannersResponse()
        let contentProvider = createMockContentProvider()
        
        // Load the expected data for comparison
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.sportBanners,
            filename: "response.json"
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModels = try decoder.decode([GomaModels.SportBannerData].self, from: jsonData)
        let expectedDomainModels = GomaModelMapper.sportBanners(from: internalModels)
        
        // When
        contentProvider.getSportBanners()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { sportBanners in
                    // Then
                    XCTAssertEqual(sportBanners.count, expectedDomainModels.count)
                    
                    // Compare each sport banner with its expected model
                    for (index, expectedBanner) in expectedDomainModels.enumerated() {
                        let actualBanner = sportBanners[index]
                        
                        XCTAssertEqual(actualBanner.id, expectedBanner.id)
                        XCTAssertEqual(actualBanner.title, expectedBanner.title)
                        XCTAssertEqual(actualBanner.isActive, expectedBanner.isActive)
                        
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
                            
                            // Compare teams
                            XCTAssertEqual(actualEvent.homeTeam.id, expectedEvent.homeTeam.id)
                            XCTAssertEqual(actualEvent.homeTeam.name, expectedEvent.homeTeam.name)
                            XCTAssertEqual(actualEvent.awayTeam.id, expectedEvent.awayTeam.id)
                            XCTAssertEqual(actualEvent.awayTeam.name, expectedEvent.awayTeam.name)
                            
                            // Compare team logo URLs
                            if let expectedHomeLogoURL = expectedEvent.homeTeam.logoUrl {
                                XCTAssertEqual(actualEvent.homeTeam.logoUrl?.absoluteString, expectedHomeLogoURL.absoluteString)
                            } else {
                                XCTAssertNil(actualEvent.homeTeam.logoUrl)
                            }
                            
                            if let expectedAwayLogoURL = expectedEvent.awayTeam.logoUrl {
                                XCTAssertEqual(actualEvent.awayTeam.logoUrl?.absoluteString, expectedAwayLogoURL.absoluteString)
                            } else {
                                XCTAssertNil(actualEvent.awayTeam.logoUrl)
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