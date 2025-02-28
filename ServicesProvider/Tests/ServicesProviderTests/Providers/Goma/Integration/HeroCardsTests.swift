import XCTest
import Combine
@testable import ServicesProvider

/// Integration tests for the Hero Cards endpoint
class HeroCardsTests: BaseIntegrationTest {
    
    /// Test that GomaPromotionsAPIClient.heroCards endpoint builds the correct URL with query parameters
    func testHeroCardsEndpointBuildsCorrectURL() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )
        
        // When
        let request = apiClient.heroCards()
        
        // Then
        XCTAssertEqual(
            request.url?.absoluteString,
            "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.heroCards)"
        )
    }
    
    /// Test that GomaPromotionsAPIClient.heroCards endpoint uses the correct HTTP method (GET)
    func testHeroCardsEndpointUsesCorrectHTTPMethod() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )
        
        // When
        let request = apiClient.heroCards()
        
        // Then
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    /// Test that the JSON response for heroCards decodes to [GomaModels.HeroCardData]
    func testHeroCardsResponseDecodesToInternalModel() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.heroCards
        )
        
        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let heroCards = try decoder.decode([GomaModels.HeroCardData].self, from: jsonData)
        
        // Then
        XCTAssertNotNil(heroCards)
        XCTAssertFalse(heroCards.isEmpty, "Hero Cards array should not be empty")
        
        // Verify first hero card has all required properties
        if let firstCard = heroCards.first {
            XCTAssertNotNil(firstCard.id)
            XCTAssertNotNil(firstCard.title)
            XCTAssertNotNil(firstCard.imageUrl)
            XCTAssertNotNil(firstCard.status)
            XCTAssertNotNil(firstCard.actionType)
        }
    }
    
    /// Test that GomaModelMapper.heroCard transforms GomaModels.HeroCardData to HeroCard correctly
    func testSingleHeroCardModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.heroCards
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let heroCards = try decoder.decode([GomaModels.HeroCardData].self, from: jsonData)
        
        // Ensure we have at least one hero card to test
        guard let internalModel = heroCards.first else {
            XCTFail("No hero cards found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.heroCard(from: internalModel)
        
        // Then
        XCTAssertEqual(domainModel.id, internalModel.id)
        XCTAssertEqual(domainModel.title, internalModel.title)
        
        // Check URL transformation
        if let imageUrl = internalModel.imageUrl {
            XCTAssertEqual(domainModel.imageUrl?.absoluteString, imageUrl)
        } else {
            XCTAssertNil(domainModel.imageUrl)
        }
        
        // Check isActive transformation
        if internalModel.status == "published" {
            XCTAssertTrue(domainModel.isActive)
        } else {
            XCTAssertFalse(domainModel.isActive)
        }
    }
    
    /// Test that GomaModelMapper.heroCards transforms array of GomaModels.HeroCardData to [HeroCard] correctly
    func testHeroCardsArrayModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.heroCards
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModels = try decoder.decode([GomaModels.HeroCardData].self, from: jsonData)
        
        // When
        let domainModels = GomaModelMapper.heroCards(from: internalModels)
        
        // Then
        XCTAssertEqual(domainModels.count, internalModels.count, "Domain model count should match internal model count")
        
        // Check that each hero card was transformed correctly
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
    
    /// Test actionType and actionTarget fields are correctly mapped
    func testActionTypeAndTargetAreCorrectlyMapped() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.heroCards
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let heroCards = try decoder.decode([GomaModels.HeroCardData].self, from: jsonData)
        
        // Ensure we have at least one hero card to test
        guard let internalModel = heroCards.first else {
            XCTFail("No hero cards found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.heroCard(from: internalModel)
        
        // Then
        XCTAssertEqual(domainModel.actionType, internalModel.actionType)
        XCTAssertEqual(domainModel.actionTarget, internalModel.actionTarget)
    }
    
    /// Test eventId and eventData fields are correctly mapped
    func testEventDataIsCorrectlyMapped() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.heroCards
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let heroCards = try decoder.decode([GomaModels.HeroCardData].self, from: jsonData)
        
        // Find a hero card with event data to test
        guard let cardWithEvent = heroCards.first(where: { $0.event != nil }) else {
            // If no card has event data, skip this test
            print("No hero cards with event data found in test data, skipping test")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.heroCard(from: cardWithEvent)
        
        // Then
        XCTAssertNotNil(domainModel.event)
        XCTAssertEqual(domainModel.event?.id, cardWithEvent.event?.id)
        
        // Check event details if present
        if let eventData = cardWithEvent.event {
            XCTAssertEqual(domainModel.event?.sportId, eventData.sportId)
            XCTAssertEqual(domainModel.event?.competitionId, eventData.competitionId)
            
            // Check teams if present
            if let homeTeam = eventData.homeTeam, let awayTeam = eventData.awayTeam {
                XCTAssertEqual(domainModel.event?.homeTeam.id, homeTeam.id)
                XCTAssertEqual(domainModel.event?.homeTeam.name, homeTeam.name)
                XCTAssertEqual(domainModel.event?.awayTeam.id, awayTeam.id)
                XCTAssertEqual(domainModel.event?.awayTeam.name, awayTeam.name)
            }
        }
    }
    
    /// Test URL construction for imageUrl field
    func testURLConstructionForImageUrl() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.heroCards
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let heroCards = try decoder.decode([GomaModels.HeroCardData].self, from: jsonData)
        
        // Ensure we have at least one hero card to test
        guard let internalModel = heroCards.first else {
            XCTFail("No hero cards found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.heroCard(from: internalModel)
        
        // Then
        if let imageUrl = internalModel.imageUrl {
            XCTAssertEqual(domainModel.imageUrl?.absoluteString, imageUrl)
        } else {
            XCTAssertNil(domainModel.imageUrl)
        }
    }
    
    /// Test that GomaManagedContentProvider.getHeroCards() calls the correct API endpoint
    func testGetHeroCardsCallsCorrectAPIEndpoint() throws {
        // Given
        let expectation = XCTestExpectation(description: "API call made")
        try registerMockHeroCardsResponse()
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getHeroCards()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(MockURLProtocol.requestsForEndpoint(TestConfiguration.EndpointPaths.heroCards).count > 0)
    }
    
    /// Test that GomaManagedContentProvider.getHeroCards() handles successful responses
    func testGetHeroCardsHandlesSuccessfulResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received hero cards")
        try registerMockHeroCardsResponse()
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getHeroCards()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { heroCards in
                    // Then
                    XCTAssertNotNil(heroCards)
                    XCTAssertFalse(heroCards.isEmpty, "Hero Cards array should not be empty")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    /// Test that GomaManagedContentProvider.getHeroCards() handles error responses
    func testGetHeroCardsHandlesErrorResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received error")
        
        // Register a mock error response
        let errorURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.heroCards)")!
        MockURLProtocol.registerMockResponse(
            for: errorURL,
            statusCode: 500,
            data: "Internal Server Error".data(using: .utf8)!
        )
        
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getHeroCards()
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
    
    /// Test that GomaManagedContentProvider.getHeroCards() handles empty array responses
    func testGetHeroCardsHandlesEmptyArrayResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received empty array")
        
        // Register a mock empty array response
        let emptyURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.heroCards)")!
        MockURLProtocol.registerMockResponse(
            for: emptyURL,
            statusCode: 200,
            data: "[]".data(using: .utf8)!
        )
        
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getHeroCards()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Empty array should not cause failure")
                    }
                },
                receiveValue: { heroCards in
                    // Then
                    XCTAssertTrue(heroCards.isEmpty, "Hero Cards array should be empty")
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
        try registerMockHeroCardsResponse()
        let contentProvider = createMockContentProvider()
        
        // Load the expected data for comparison
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.heroCards
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModels = try decoder.decode([GomaModels.HeroCardData].self, from: jsonData)
        let expectedDomainModels = GomaModelMapper.heroCards(from: internalModels)
        
        // When
        contentProvider.getHeroCards()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { heroCards in
                    // Then
                    XCTAssertEqual(heroCards.count, expectedDomainModels.count)
                    
                    // Compare each hero card with its expected model
                    for (index, expectedCard) in expectedDomainModels.enumerated() {
                        let actualCard = heroCards[index]
                        
                        XCTAssertEqual(actualCard.id, expectedCard.id)
                        XCTAssertEqual(actualCard.title, expectedCard.title)
                        XCTAssertEqual(actualCard.isActive, expectedCard.isActive)
                        XCTAssertEqual(actualCard.actionType, expectedCard.actionType)
                        XCTAssertEqual(actualCard.actionTarget, expectedCard.actionTarget)
                        
                        // Compare URLs
                        if let expectedImageURL = expectedCard.imageUrl {
                            XCTAssertEqual(actualCard.imageUrl?.absoluteString, expectedImageURL.absoluteString)
                        } else {
                            XCTAssertNil(actualCard.imageUrl)
                        }
                        
                        // Compare event data if present
                        if let expectedEvent = expectedCard.event, let actualEvent = actualCard.event {
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
                            XCTAssertEqual(actualCard.event == nil, expectedCard.event == nil)
                        }
                    }
                    
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
} 