import XCTest
import Combine
@testable import ServicesProvider

/// Integration tests for the Carousel Events endpoint
class CarouselEventTests: BaseIntegrationTest {
    
    /// Test that GomaPromotionsAPIClient.carouselEvents endpoint builds the correct URL with query parameters
    func testCarouselEventsEndpointBuildsCorrectURL() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )
        
        // When
        let request = apiClient.carouselEvents()
        
        // Then
        XCTAssertEqual(
            request.url?.absoluteString,
            "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.carouselEvents)"
        )
    }
    
    /// Test that GomaPromotionsAPIClient.carouselEvents endpoint uses the correct HTTP method (GET)
    func testCarouselEventsEndpointUsesCorrectHTTPMethod() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )
        
        // When
        let request = apiClient.carouselEvents()
        
        // Then
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    /// Test that the JSON response for carouselEvents decodes to [GomaModels.CarouselEvent]
    func testCarouselEventsResponseDecodesToInternalModel() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.carouselEvents
        )
        
        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let carouselEvents = try decoder.decode([GomaModels.CarouselEvent].self, from: jsonData)
        
        // Then
        XCTAssertNotNil(carouselEvents)
        XCTAssertFalse(carouselEvents.isEmpty, "Carousel Events array should not be empty")
        
        // Verify first carousel event has all required properties
        if let firstEvent = carouselEvents.first {
            XCTAssertNotNil(firstEvent.id)
            XCTAssertNotNil(firstEvent.title)
            XCTAssertNotNil(firstEvent.imageUrl)
            XCTAssertNotNil(firstEvent.status)
            XCTAssertNotNil(firstEvent.event)
            XCTAssertNotNil(firstEvent.platform)
        }
    }
    
    /// Test that GomaModelMapper.carouselEvent transforms GomaModels.CarouselEvent to CarouselEvent correctly
    func testSingleCarouselEventModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.carouselEvents
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let carouselEvents = try decoder.decode([GomaModels.CarouselEvent].self, from: jsonData)
        
        // Ensure we have at least one carousel event to test
        guard let internalModel = carouselEvents.first else {
            XCTFail("No carousel events found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.carouselEvent(fromInternalCarouselEvent: internalModel)
        
        // Then
        XCTAssertEqual(domainModel.id, String(internalModel.id))
        XCTAssertEqual(domainModel.title, internalModel.title)
        XCTAssertEqual(domainModel.imageUrl, internalModel.imageUrl)
        XCTAssertEqual(domainModel.actionUrl, internalModel.actionUrl)
        XCTAssertEqual(domainModel.status, internalModel.status)
        XCTAssertEqual(domainModel.platform, internalModel.platform)
        XCTAssertEqual(domainModel.startDate, internalModel.startDate)
        XCTAssertEqual(domainModel.endDate, internalModel.endDate)
        XCTAssertEqual(domainModel.userType, internalModel.userType)
    }
    
    /// Test that GomaModelMapper.carouselEvents transforms array of GomaModels.CarouselEvent to [CarouselEvent] correctly
    func testCarouselEventsArrayModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.carouselEvents
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModels = try decoder.decode([GomaModels.CarouselEvent].self, from: jsonData)
        
        // When
        let domainModels = GomaModelMapper.carouselEvents(fromInternalCarouselEvents: internalModels)
        
        // Then
        XCTAssertEqual(domainModels.count, internalModels.count, "Domain model count should match internal model count")
        
        // Check that each carousel event was transformed correctly
        for (index, internalModel) in internalModels.enumerated() {
            let domainModel = domainModels[index]
            
            XCTAssertEqual(domainModel.id, String(internalModel.id))
            XCTAssertEqual(domainModel.title, internalModel.title)
            XCTAssertEqual(domainModel.imageUrl, internalModel.imageUrl)
        }
    }
    
    /// Test nested SportEventData mapping to SportEventSummary
    func testNestedSportEventDataMapping() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.carouselEvents
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let carouselEvents = try decoder.decode([GomaModels.CarouselEvent].self, from: jsonData)
        
        // Ensure we have at least one carousel event with event data to test
        guard let internalModel = carouselEvents.first, let eventData = internalModel.event else {
            XCTFail("No carousel events with event data found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.carouselEvent(fromInternalCarouselEvent: internalModel)
        
        // Then
        XCTAssertNotNil(domainModel.event)
        XCTAssertEqual(domainModel.event?.id, String(eventData.id))
        XCTAssertEqual(domainModel.event?.sportId, String(eventData.sportId))
        XCTAssertEqual(domainModel.event?.competitionId, String(eventData.competitionId))
        XCTAssertEqual(domainModel.event?.dateTime, eventData.dateTime)
    }
    
    /// Test team data mapping for home and away teams
    func testTeamDataMapping() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.carouselEvents
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let carouselEvents = try decoder.decode([GomaModels.CarouselEvent].self, from: jsonData)
        
        // Ensure we have at least one carousel event with event data to test
        guard let internalModel = carouselEvents.first, 
              let eventData = internalModel.event,
              let homeTeam = eventData.homeTeam,
              let awayTeam = eventData.awayTeam else {
            XCTFail("No carousel events with complete team data found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.carouselEvent(fromInternalCarouselEvent: internalModel)
        
        // Then
        XCTAssertNotNil(domainModel.event?.homeTeam)
        XCTAssertNotNil(domainModel.event?.awayTeam)
        
        // Check home team mapping
        XCTAssertEqual(domainModel.event?.homeTeam.id, String(homeTeam.id))
        XCTAssertEqual(domainModel.event?.homeTeam.name, homeTeam.name)
        
        // Check away team mapping
        XCTAssertEqual(domainModel.event?.awayTeam.id, String(awayTeam.id))
        XCTAssertEqual(domainModel.event?.awayTeam.name, awayTeam.name)
    }
    
    /// Test logo URLs
    func testLogoUrls() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.carouselEvents
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let carouselEvents = try decoder.decode([GomaModels.CarouselEvent].self, from: jsonData)
        
        // Ensure we have at least one carousel event with event data to test
        guard let internalModel = carouselEvents.first, 
              let eventData = internalModel.event,
              let homeTeam = eventData.homeTeam,
              let awayTeam = eventData.awayTeam else {
            XCTFail("No carousel events with complete team data found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.carouselEvent(fromInternalCarouselEvent: internalModel)
        
        // Then
        // Check home team logo URL
        XCTAssertEqual(domainModel.event?.homeTeam.logoUrl, homeTeam.logoUrl)
        
        // Check away team logo URL
        XCTAssertEqual(domainModel.event?.awayTeam.logoUrl, awayTeam.logoUrl)
    }
    
    /// Test that GomaManagedContentProvider.getCarouselEvents() calls the correct API endpoint
    func testGetCarouselEventsCallsCorrectAPIEndpoint() throws {
        // Given
        let expectation = XCTestExpectation(description: "API call made")
        try registerMockCarouselEventsResponse()
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getCarouselEvents()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(MockURLProtocol.requestsForEndpoint(TestConfiguration.EndpointPaths.carouselEvents).count > 0)
    }
    
    /// Test that GomaManagedContentProvider.getCarouselEvents() handles successful responses
    func testGetCarouselEventsHandlesSuccessfulResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received carousel events")
        try registerMockCarouselEventsResponse()
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getCarouselEvents()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { carouselEvents in
                    // Then
                    XCTAssertNotNil(carouselEvents)
                    XCTAssertFalse(carouselEvents.isEmpty, "Carousel Events array should not be empty")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    /// Test that GomaManagedContentProvider.getCarouselEvents() handles error responses
    func testGetCarouselEventsHandlesErrorResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received error")
        
        // Register a mock error response
        let errorURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.carouselEvents)")!
        MockURLProtocol.registerMockResponse(
            for: errorURL,
            data: "Internal Server Error".data(using: .utf8)!,
            statusCode: 500
        )
        
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getCarouselEvents()
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
    
    /// Test that GomaManagedContentProvider.getCarouselEvents() handles empty array responses
    func testGetCarouselEventsHandlesEmptyArrayResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received empty array")
        
        // Register a mock empty array response
        let emptyURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.carouselEvents)")!
        MockURLProtocol.registerMockResponse(
            for: emptyURL,
            data: "[]".data(using: .utf8)!,
            statusCode: 200
        )
        
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getCarouselEvents()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Empty array should not cause failure")
                    }
                },
                receiveValue: { carouselEvents in
                    // Then
                    XCTAssertTrue(carouselEvents.isEmpty, "Carousel Events array should be empty")
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
        try registerMockCarouselEventsResponse()
        let contentProvider = createMockContentProvider()
        
        // Load the expected data for comparison
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.carouselEvents
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModels = try decoder.decode([GomaModels.CarouselEvent].self, from: jsonData)
        let expectedDomainModels = GomaModelMapper.carouselEvents(fromInternalCarouselEvents: internalModels)
        
        // When
        contentProvider.getCarouselEvents()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { carouselEvents in
                    // Then
                    XCTAssertEqual(carouselEvents.count, expectedDomainModels.count)
                    
                    // Compare each carousel event with its expected model
                    for (index, expectedEvent) in expectedDomainModels.enumerated() {
                        let actualEvent = carouselEvents[index]
                        
                        XCTAssertEqual(actualEvent.id, expectedEvent.id)
                        XCTAssertEqual(actualEvent.title, expectedEvent.title)
                        XCTAssertEqual(actualEvent.status, expectedEvent.status)
                        XCTAssertEqual(actualEvent.imageUrl, expectedEvent.imageUrl)
                        XCTAssertEqual(actualEvent.actionUrl, expectedEvent.actionUrl)
                        XCTAssertEqual(actualEvent.platform, expectedEvent.platform)
                        XCTAssertEqual(actualEvent.startDate, expectedEvent.startDate)
                        XCTAssertEqual(actualEvent.endDate, expectedEvent.endDate)
                        XCTAssertEqual(actualEvent.userType, expectedEvent.userType)
                        
                        // Compare event data if present
                        if let expectedEventData = expectedEvent.event, let actualEventData = actualEvent.event {
                            XCTAssertEqual(actualEventData.id, expectedEventData.id)
                            XCTAssertEqual(actualEventData.sportId, expectedEventData.sportId)
                            XCTAssertEqual(actualEventData.competitionId, expectedEventData.competitionId)
                            
                            // Compare teams
                            XCTAssertEqual(actualEventData.homeTeam.id, expectedEventData.homeTeam.id)
                            XCTAssertEqual(actualEventData.homeTeam.name, expectedEventData.homeTeam.name)
                            XCTAssertEqual(actualEventData.awayTeam.id, expectedEventData.awayTeam.id)
                            XCTAssertEqual(actualEventData.awayTeam.name, expectedEventData.awayTeam.name)
                            
                            // Compare team logo URLs
                            XCTAssertEqual(actualEventData.homeTeam.logoUrl, expectedEventData.homeTeam.logoUrl)
                            XCTAssertEqual(actualEventData.awayTeam.logoUrl, expectedEventData.awayTeam.logoUrl)
                            
                            // Compare date
                            XCTAssertEqual(actualEventData.dateTime, expectedEventData.dateTime)
                        } else {
                            XCTAssertEqual(actualEvent.event == nil, expectedEvent.event == nil)
                        }
                    }
                    
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Helper Methods
    
    /// Register a mock response for the carouselEvents endpoint
    private func registerMockCarouselEventsResponse() throws {
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.carouselEvents,
            filename: "response.json"
        )
        
        let url = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.carouselEvents)")!
        MockURLProtocol.registerMockResponse(
            for: url,
            data: jsonData,
            statusCode: 200
        )
    }
} 