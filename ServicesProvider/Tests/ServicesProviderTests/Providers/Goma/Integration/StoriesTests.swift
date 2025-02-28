import XCTest
import Combine
@testable import ServicesProvider

/// Integration tests for the Stories endpoint
class StoriesTests: BaseIntegrationTest {
    
    /// Test that GomaPromotionsAPIClient.stories endpoint builds the correct URL with query parameters
    func testStoriesEndpointBuildsCorrectURL() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )
        
        // When
        let request = apiClient.stories()
        
        // Then
        XCTAssertEqual(
            request.url?.absoluteString,
            "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.stories)"
        )
    }
    
    /// Test that GomaPromotionsAPIClient.stories endpoint uses the correct HTTP method (GET)
    func testStoriesEndpointUsesCorrectHTTPMethod() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )
        
        // When
        let request = apiClient.stories()
        
        // Then
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    /// Test that the JSON response for stories decodes to [GomaModels.StoryData]
    func testStoriesResponseDecodesToInternalModel() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.stories,
            filename: "response.json"
        )
        
        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let stories = try decoder.decode([GomaModels.StoryData].self, from: jsonData)
        
        // Then
        XCTAssertNotNil(stories)
        XCTAssertFalse(stories.isEmpty, "Stories array should not be empty")
        
        // Verify first story has all required properties
        if let firstStory = stories.first {
            XCTAssertNotNil(firstStory.id)
            XCTAssertNotNil(firstStory.title)
            XCTAssertNotNil(firstStory.imageUrl)
            XCTAssertNotNil(firstStory.status)
            XCTAssertNotNil(firstStory.content)
        }
    }
    
    /// Test that GomaModelMapper.story transforms GomaModels.StoryData to Story correctly
    func testSingleStoryModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.stories,
            filename: "response.json"
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let stories = try decoder.decode([GomaModels.StoryData].self, from: jsonData)
        
        // Ensure we have at least one story to test
        guard let internalModel = stories.first else {
            XCTFail("No stories found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.story(from: internalModel)
        
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
    
    /// Test that GomaModelMapper.stories transforms array of GomaModels.StoryData to [Story] correctly
    func testStoriesArrayModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.stories,
            filename: "response.json"
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModels = try decoder.decode([GomaModels.StoryData].self, from: jsonData)
        
        // When
        let domainModels = GomaModelMapper.stories(from: internalModels)
        
        // Then
        XCTAssertEqual(domainModels.count, internalModels.count, "Domain model count should match internal model count")
        
        // Check that each story was transformed correctly
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
    
    /// Test content field is correctly mapped
    func testContentFieldIsCorrectlyMapped() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.stories,
            filename: "response.json"
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let stories = try decoder.decode([GomaModels.StoryData].self, from: jsonData)
        
        // Ensure we have at least one story to test
        guard let internalModel = stories.first else {
            XCTFail("No stories found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.story(from: internalModel)
        
        // Then
        XCTAssertEqual(domainModel.content, internalModel.content)
    }
    
    /// Test duration field is correctly mapped
    func testDurationFieldIsCorrectlyMapped() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.stories,
            filename: "response.json"
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let stories = try decoder.decode([GomaModels.StoryData].self, from: jsonData)
        
        // Ensure we have at least one story to test
        guard let internalModel = stories.first else {
            XCTFail("No stories found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.story(from: internalModel)
        
        // Then
        XCTAssertEqual(domainModel.duration, internalModel.duration)
    }
    
    /// Test URL construction for imageUrl field
    func testURLConstructionForImageUrl() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.stories,
            filename: "response.json"
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let stories = try decoder.decode([GomaModels.StoryData].self, from: jsonData)
        
        // Ensure we have at least one story to test
        guard let internalModel = stories.first else {
            XCTFail("No stories found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.story(from: internalModel)
        
        // Then
        if let imageUrl = internalModel.imageUrl {
            XCTAssertEqual(domainModel.imageUrl?.absoluteString, imageUrl)
        } else {
            XCTAssertNil(domainModel.imageUrl)
        }
    }
    
    /// Test that GomaManagedContentProvider.getStories() calls the correct API endpoint
    func testGetStoriesCallsCorrectAPIEndpoint() throws {
        // Given
        let expectation = XCTestExpectation(description: "API call made")
        try registerMockStoriesResponse()
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getStories()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(MockURLProtocol.requestsForEndpoint(TestConfiguration.EndpointPaths.stories).count > 0)
    }
    
    /// Test that GomaManagedContentProvider.getStories() handles successful responses
    func testGetStoriesHandlesSuccessfulResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received stories")
        try registerMockStoriesResponse()
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getStories()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { stories in
                    // Then
                    XCTAssertNotNil(stories)
                    XCTAssertFalse(stories.isEmpty, "Stories array should not be empty")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    /// Test that GomaManagedContentProvider.getStories() handles error responses
    func testGetStoriesHandlesErrorResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received error")
        
        // Register a mock error response
        let errorURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.stories)")!
        MockURLProtocol.registerMockResponse(
            for: errorURL,
            statusCode: 500,
            data: "Internal Server Error".data(using: .utf8)!
        )
        
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getStories()
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
    
    /// Test that GomaManagedContentProvider.getStories() handles empty array responses
    func testGetStoriesHandlesEmptyArrayResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received empty array")
        
        // Register a mock empty array response
        let emptyURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.stories)")!
        MockURLProtocol.registerMockResponse(
            for: emptyURL,
            statusCode: 200,
            data: "[]".data(using: .utf8)!
        )
        
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getStories()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Empty array should not cause failure")
                    }
                },
                receiveValue: { stories in
                    // Then
                    XCTAssertTrue(stories.isEmpty, "Stories array should be empty")
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
        try registerMockStoriesResponse()
        let contentProvider = createMockContentProvider()
        
        // Load the expected data for comparison
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.stories,
            filename: "response.json"
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModels = try decoder.decode([GomaModels.StoryData].self, from: jsonData)
        let expectedDomainModels = GomaModelMapper.stories(from: internalModels)
        
        // When
        contentProvider.getStories()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { stories in
                    // Then
                    XCTAssertEqual(stories.count, expectedDomainModels.count)
                    
                    // Compare each story with its expected model
                    for (index, expectedStory) in expectedDomainModels.enumerated() {
                        let actualStory = stories[index]
                        
                        XCTAssertEqual(actualStory.id, expectedStory.id)
                        XCTAssertEqual(actualStory.title, expectedStory.title)
                        XCTAssertEqual(actualStory.isActive, expectedStory.isActive)
                        XCTAssertEqual(actualStory.content, expectedStory.content)
                        XCTAssertEqual(actualStory.duration, expectedStory.duration)
                        
                        // Compare URLs
                        if let expectedImageURL = expectedStory.imageUrl {
                            XCTAssertEqual(actualStory.imageUrl?.absoluteString, expectedImageURL.absoluteString)
                        } else {
                            XCTAssertNil(actualStory.imageUrl)
                        }
                    }
                    
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
} 