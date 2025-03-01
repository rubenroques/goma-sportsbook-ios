import XCTest
import Combine
@testable import ServicesProvider

/// Integration tests for the Pro Choices endpoint
class ProChoicesTests: BaseIntegrationTest {

    /// Test that GomaPromotionsAPIClient.proChoices endpoint builds the correct URL with query parameters
    func testProChoicesEndpointBuildsCorrectURL() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )

        // When
        let request = apiClient.proChoices()

        // Then
        XCTAssertEqual(
            request.url?.absoluteString,
            "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.proChoices)"
        )
    }

    /// Test that GomaPromotionsAPIClient.proChoices endpoint uses the correct HTTP method (GET)
    func testProChoicesEndpointUsesCorrectHTTPMethod() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )

        // When
        let request = apiClient.proChoices()

        // Then
        XCTAssertEqual(request.httpMethod, "GET")
    }

    /// Test that the JSON response for proChoices decodes to [GomaModels.ProChoiceData]
    func testProChoicesResponseDecodesToInternalModel() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.proChoices
        )

        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let proChoices = try decoder.decode([GomaModels.ProChoiceData].self, from: jsonData)

        // Then
        XCTAssertNotNil(proChoices)
        XCTAssertFalse(proChoices.isEmpty, "Pro Choices array should not be empty")

        // Verify first pro choice has all required properties
        if let firstChoice = proChoices.first {
            XCTAssertNotNil(firstChoice.id)
            XCTAssertNotNil(firstChoice.tipster)
            XCTAssertNotNil(firstChoice.event)
            XCTAssertNotNil(firstChoice.selection)
            XCTAssertNotNil(firstChoice.status)
        }
    }

    /// Test that GomaModelMapper.proChoice transforms GomaModels.ProChoiceData to ProChoice correctly
    func testSingleProChoiceModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.proChoices
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let proChoices = try decoder.decode([GomaModels.ProChoiceData].self, from: jsonData)

        // Ensure we have at least one pro choice to test
        guard let internalModel = proChoices.first else {
            XCTFail("No pro choices found in test data")
            return
        }

        // When
        let domainModel = GomaModelMapper.proChoice(fromInternalProChoice: internalModel)

        // Then
        XCTAssertEqual(domainModel.id, internalModel.id)

        // Check isActive transformation
        if internalModel.status == "published" {
            XCTAssertTrue(domainModel.isActive)
        } else {
            XCTAssertFalse(domainModel.isActive)
        }

        // Check reasoning field
        XCTAssertEqual(domainModel.reasoning, internalModel.reasoning)
    }

    /// Test that GomaModelMapper.proChoices transforms array of GomaModels.ProChoiceData to [ProChoice] correctly
    func testProChoicesArrayModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.proChoices
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModels = try decoder.decode([GomaModels.ProChoiceData].self, from: jsonData)

        // When
        let domainModels = GomaModelMapper.proChoices(fromInternalProChoices: internalModels)

        // Then
        XCTAssertEqual(domainModels.count, internalModels.count, "Domain model count should match internal model count")

        // Check that each pro choice was transformed correctly
        for (index, internalModel) in internalModels.enumerated() {
            let domainModel = domainModels[index]

            XCTAssertEqual(domainModel.id, internalModel.id)
            XCTAssertEqual(domainModel.reasoning, internalModel.reasoning)

            // Check isActive transformation
            if internalModel.status == "published" {
                XCTAssertTrue(domainModel.isActive)
            } else {
                XCTAssertFalse(domainModel.isActive)
            }
        }
    }

    /// Test tipster data mapping (id, name, winRate, avatar)
    func testTipsterDataMapping() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.proChoices
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let proChoices = try decoder.decode([GomaModels.ProChoiceData].self, from: jsonData)

        // Ensure we have at least one pro choice with tipster data to test
        guard let internalModel = proChoices.first, let tipsterData = internalModel.tipster else {
            XCTFail("No pro choices with tipster data found in test data")
            return
        }

        // When
        let domainModel = GomaModelMapper.proChoice(fromInternalProChoice: internalModel)

        // Then
        XCTAssertNotNil(domainModel.tipster)
        XCTAssertEqual(domainModel.tipster.id, tipsterData.id)
        XCTAssertEqual(domainModel.tipster.name, tipsterData.name)
        XCTAssertEqual(domainModel.tipster.winRate, tipsterData.winRate)

        // Check avatar URL transformation
        if let avatarUrl = tipsterData.avatarUrl {
            XCTAssertEqual(domainModel.tipster.avatarUrl?.absoluteString, avatarUrl)
        } else {
            XCTAssertNil(domainModel.tipster.avatarUrl)
        }
    }

    /// Test event summary mapping (id, homeTeam, awayTeam, dateTime)
    func testEventSummaryMapping() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.proChoices
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let proChoices = try decoder.decode([GomaModels.ProChoiceData].self, from: jsonData)

        // Ensure we have at least one pro choice with event data to test
        guard let internalModel = proChoices.first, let eventData = internalModel.event else {
            XCTFail("No pro choices with event data found in test data")
            return
        }

        // When
        let domainModel = GomaModelMapper.proChoice(fromInternalProChoice: internalModel)

        // Then
        XCTAssertNotNil(domainModel.event)
        XCTAssertEqual(domainModel.event.id, eventData.id)

        // Check teams data
        if let homeTeam = eventData.homeTeam, let awayTeam = eventData.awayTeam {
            XCTAssertEqual(domainModel.event.homeTeam.id, homeTeam.id)
            XCTAssertEqual(domainModel.event.homeTeam.name, homeTeam.name)
            XCTAssertEqual(domainModel.event.awayTeam.id, awayTeam.id)
            XCTAssertEqual(domainModel.event.awayTeam.name, awayTeam.name)
        }

        // Check date transformation
        if let dateTimeString = eventData.dateTime {
            let dateFormatter = ISO8601DateFormatter()
            let expectedDate = dateFormatter.date(from: dateTimeString)
            XCTAssertEqual(domainModel.event.dateTime, expectedDate)
        } else {
            XCTAssertNil(domainModel.event.dateTime)
        }
    }

    /// Test selection mapping (marketName, outcomeName, odds)
    func testSelectionMapping() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.proChoices
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let proChoices = try decoder.decode([GomaModels.ProChoiceData].self, from: jsonData)

        // Ensure we have at least one pro choice with selection data to test
        guard let internalModel = proChoices.first, let selectionData = internalModel.selection else {
            XCTFail("No pro choices with selection data found in test data")
            return
        }

        // When
        let domainModel = GomaModelMapper.proChoice(fromInternalProChoice: internalModel)

        // Then
        XCTAssertNotNil(domainModel.selection)
        XCTAssertEqual(domainModel.selection.marketName, selectionData.marketName)
        XCTAssertEqual(domainModel.selection.outcomeName, selectionData.outcomeName)
        XCTAssertEqual(domainModel.selection.odds, selectionData.odds)
    }

    /// Test reasoning field is correctly mapped
    func testReasoningFieldIsCorrectlyMapped() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.proChoices
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let proChoices = try decoder.decode([GomaModels.ProChoiceData].self, from: jsonData)

        // Ensure we have at least one pro choice to test
        guard let internalModel = proChoices.first else {
            XCTFail("No pro choices found in test data")
            return
        }

        // When
        let domainModel = GomaModelMapper.proChoice(fromInternalProChoice: internalModel)

        // Then
        XCTAssertEqual(domainModel.reasoning, internalModel.reasoning)
    }

    /// Test URL construction for tipster avatar
    func testURLConstructionForTipsterAvatar() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.proChoices
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let proChoices = try decoder.decode([GomaModels.ProChoiceData].self, from: jsonData)

        // Ensure we have at least one pro choice with tipster data to test
        guard let internalModel = proChoices.first, let tipsterData = internalModel.tipster else {
            XCTFail("No pro choices with tipster data found in test data")
            return
        }

        // When
        let domainModel = GomaModelMapper.proChoice(fromInternalProChoice: internalModel)

        // Then
        if let avatarUrl = tipsterData.avatarUrl {
            XCTAssertEqual(domainModel.tipster.avatarUrl?.absoluteString, avatarUrl)
        } else {
            XCTAssertNil(domainModel.tipster.avatarUrl)
        }
    }

    /// Test that GomaManagedContentProvider.getProChoices() calls the correct API endpoint
    func testGetProChoicesCallsCorrectAPIEndpoint() throws {
        // Given
        let expectation = XCTestExpectation(description: "API call made")
        try registerMockProChoicesResponse()
        let contentProvider = createMockContentProvider()

        // When
        contentProvider.getProChoices()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(MockURLProtocol.requestsForEndpoint(TestConfiguration.EndpointPaths.proChoices).count > 0)
    }

    /// Test that GomaManagedContentProvider.getProChoices() handles successful responses
    func testGetProChoicesHandlesSuccessfulResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received pro choices")
        try registerMockProChoicesResponse()
        let contentProvider = createMockContentProvider()

        // When
        contentProvider.getProChoices()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { proChoices in
                    // Then
                    XCTAssertNotNil(proChoices)
                    XCTAssertFalse(proChoices.isEmpty, "Pro Choices array should not be empty")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    /// Test that GomaManagedContentProvider.getProChoices() handles error responses
    func testGetProChoicesHandlesErrorResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received error")

        // Register a mock error response
        let errorURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.proChoices)")!
        MockURLProtocol.registerMockResponse(
            for: errorURL,
            data: "Internal Server Error".data(using: .utf8)!,
            statusCode: 500
        )

        let contentProvider = createMockContentProvider()

        // When
        contentProvider.getProChoices()
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

    /// Test that GomaManagedContentProvider.getProChoices() handles empty array responses
    func testGetProChoicesHandlesEmptyArrayResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received empty array")

        // Register a mock empty array response
        let emptyURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.proChoices)")!
        MockURLProtocol.registerMockResponse(
            for: emptyURL,
            data: "[]".data(using: .utf8)!,
            statusCode: 200
        )

        let contentProvider = createMockContentProvider()

        // When
        contentProvider.getProChoices()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Empty array should not cause failure")
                    }
                },
                receiveValue: { proChoices in
                    // Then
                    XCTAssertTrue(proChoices.isEmpty, "Pro Choices array should be empty")
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
        try registerMockProChoicesResponse()
        let contentProvider = createMockContentProvider()

        // Load the expected data for comparison
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.proChoices
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModels = try decoder.decode([GomaModels.ProChoiceData].self, from: jsonData)
        let expectedDomainModels = GomaModelMapper.proChoices(fromInternalProChoices: internalModels)

        // When
        contentProvider.getProChoices()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { proChoices in
                    // Then
                    XCTAssertEqual(proChoices.count, expectedDomainModels.count)

                    // Compare each pro choice with its expected model
                    for (index, expectedChoice) in expectedDomainModels.enumerated() {
                        let actualChoice = proChoices[index]

                        XCTAssertEqual(actualChoice.id, expectedChoice.id)
                        XCTAssertEqual(actualChoice.isActive, expectedChoice.isActive)
                        XCTAssertEqual(actualChoice.reasoning, expectedChoice.reasoning)

                        // Compare tipster data
                        XCTAssertEqual(actualChoice.tipster.id, expectedChoice.tipster.id)
                        XCTAssertEqual(actualChoice.tipster.name, expectedChoice.tipster.name)
                        XCTAssertEqual(actualChoice.tipster.winRate, expectedChoice.tipster.winRate)

                        if let expectedAvatarURL = expectedChoice.tipster.avatarUrl {
                            XCTAssertEqual(actualChoice.tipster.avatarUrl?.absoluteString, expectedAvatarURL.absoluteString)
                        } else {
                            XCTAssertNil(actualChoice.tipster.avatarUrl)
                        }

                        // Compare event data
                        XCTAssertEqual(actualChoice.event.id, expectedChoice.event.id)
                        XCTAssertEqual(actualChoice.event.homeTeam.id, expectedChoice.event.homeTeam.id)
                        XCTAssertEqual(actualChoice.event.homeTeam.name, expectedChoice.event.homeTeam.name)
                        XCTAssertEqual(actualChoice.event.awayTeam.id, expectedChoice.event.awayTeam.id)
                        XCTAssertEqual(actualChoice.event.awayTeam.name, expectedChoice.event.awayTeam.name)

                        if let expectedDate = expectedChoice.event.dateTime {
                            XCTAssertEqual(actualChoice.event.dateTime, expectedDate)
                        } else {
                            XCTAssertNil(actualChoice.event.dateTime)
                        }

                        // Compare selection data
                        XCTAssertEqual(actualChoice.selection.marketName, expectedChoice.selection.marketName)
                        XCTAssertEqual(actualChoice.selection.outcomeName, expectedChoice.selection.outcomeName)
                        XCTAssertEqual(actualChoice.selection.odds, expectedChoice.selection.odds)
                    }

                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
}