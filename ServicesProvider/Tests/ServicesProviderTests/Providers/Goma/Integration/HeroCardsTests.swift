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

    /// Test that the JSON response for heroCards decodes to [GomaModels.HeroCard]
    func testHeroCardsResponseDecodesToInternalModel() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.heroCards
        )

        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let heroCards = try decoder.decode([GomaModels.HeroCard].self, from: jsonData)

        // Then
        XCTAssertNotNil(heroCards)
        XCTAssertFalse(heroCards.isEmpty, "Hero Cards array should not be empty")

        // Verify first hero card has all required properties
        if let firstCard = heroCards.first {
            XCTAssertNotNil(firstCard.id)
            XCTAssertNotNil(firstCard.imageUrl)
        }
    }

    /// Test that GomaModelMapper.heroCard transforms GomaModels.HeroCard to HeroCard correctly
    func testSingleHeroCardModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.heroCards
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let heroCards = try decoder.decode([GomaModels.HeroCard].self, from: jsonData)

        // Ensure we have at least one hero card to test
        guard let internalModel = heroCards.first else {
            XCTFail("No hero cards found in test data")
            return
        }

        // When
        let domainModel = GomaModelMapper.heroCard(fromInternalHeroCard: internalModel)

        // Then
        XCTAssertEqual(domainModel.id, String(internalModel.id))
        XCTAssertEqual(domainModel.eventId, internalModel.eventId)
        XCTAssertEqual(domainModel.eventMarketIds, internalModel.eventMarketIds)
        XCTAssertEqual(domainModel.imageUrl, internalModel.imageUrl)
    }

    /// Test that GomaModelMapper.heroCards transforms array of GomaModels.HeroCard to [HeroCard] correctly
    func testHeroCardsArrayModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.heroCards
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModels = try decoder.decode([GomaModels.HeroCard].self, from: jsonData)

        // When
        let domainModels = GomaModelMapper.heroCards(fromInternalHeroCards: internalModels)

        // Then
        XCTAssertEqual(domainModels.count, internalModels.count, "Domain model count should match internal model count")

        // Check that each hero card was transformed correctly
        for (index, internalModel) in internalModels.enumerated() {
            let domainModel = domainModels[index]

            XCTAssertEqual(domainModel.id, String(internalModel.id))
            XCTAssertEqual(domainModel.eventId, internalModel.eventId)
            XCTAssertEqual(domainModel.eventMarketIds, internalModel.eventMarketIds)
            XCTAssertEqual(domainModel.imageUrl, internalModel.imageUrl)
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
            data: "Internal Server Error".data(using: .utf8)!,
            statusCode: 500
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
            data: "[]".data(using: .utf8)!,
            statusCode: 200
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
        let internalModels = try decoder.decode([GomaModels.HeroCard].self, from: jsonData)
        let expectedDomainModels = GomaModelMapper.heroCards(fromInternalHeroCards: internalModels)

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
                        XCTAssertEqual(actualCard.eventId, expectedCard.eventId)
                        XCTAssertEqual(actualCard.eventMarketIds, expectedCard.eventMarketIds)
                        XCTAssertEqual(actualCard.imageUrl, expectedCard.imageUrl)
                    }

                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
}