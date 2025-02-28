import XCTest
import Combine
@testable import ServicesProvider

/// Integration tests for the News endpoint
class NewsTests: BaseIntegrationTest {
    
    /// Test that GomaPromotionsAPIClient.news endpoint builds the correct URL with query parameters
    func testNewsEndpointBuildsCorrectURL() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )
        
        // When
        let request = apiClient.news(pageIndex: 0, pageSize: 10)
        
        // Then
        XCTAssertEqual(
            request.url?.absoluteString,
            "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.news)?pageIndex=0&pageSize=10"
        )
    }
    
    /// Test that GomaPromotionsAPIClient.news endpoint uses the correct HTTP method (GET)
    func testNewsEndpointUsesCorrectHTTPMethod() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )
        
        // When
        let request = apiClient.news(pageIndex: 0, pageSize: 10)
        
        // Then
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    /// Verify pagination parameters (pageIndex, pageSize) are correctly added to URL
    func testPaginationParametersAreCorrectlyAddedToURL() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )
        
        // Test different pagination values
        let testCases = [
            (pageIndex: 0, pageSize: 10),
            (pageIndex: 1, pageSize: 20),
            (pageIndex: 2, pageSize: 5)
        ]
        
        for (pageIndex, pageSize) in testCases {
            // When
            let request = apiClient.news(pageIndex: pageIndex, pageSize: pageSize)
            
            // Then
            XCTAssertEqual(
                request.url?.absoluteString,
                "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.news)?pageIndex=\(pageIndex)&pageSize=\(pageSize)"
            )
        }
    }
    
    /// Test that the JSON response for news decodes to [GomaModels.NewsItemData]
    func testNewsResponseDecodesToInternalModel() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.news
        )
        
        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let news = try decoder.decode([GomaModels.NewsItemData].self, from: jsonData)
        
        // Then
        XCTAssertNotNil(news)
        XCTAssertFalse(news.isEmpty, "News array should not be empty")
        
        // Verify first news item has all required properties
        if let firstItem = news.first {
            XCTAssertNotNil(firstItem.id)
            XCTAssertNotNil(firstItem.title)
            XCTAssertNotNil(firstItem.imageUrl)
            XCTAssertNotNil(firstItem.status)
            XCTAssertNotNil(firstItem.content)
        }
    }
    
    /// Test that GomaModelMapper.newsItem transforms GomaModels.NewsItemData to NewsItem correctly
    func testSingleNewsItemModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.news
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let news = try decoder.decode([GomaModels.NewsItemData].self, from: jsonData)
        
        // Ensure we have at least one news item to test
        guard let internalModel = news.first else {
            XCTFail("No news items found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.newsItem(from: internalModel)
        
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
    
    /// Test that GomaModelMapper.newsItems transforms array of GomaModels.NewsItemData to [NewsItem] correctly
    func testNewsItemsArrayModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.news
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModels = try decoder.decode([GomaModels.NewsItemData].self, from: jsonData)
        
        // When
        let domainModels = GomaModelMapper.newsItems(from: internalModels)
        
        // Then
        XCTAssertEqual(domainModels.count, internalModels.count, "Domain model count should match internal model count")
        
        // Check that each news item was transformed correctly
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
    
    /// Test author and tags fields are correctly mapped
    func testAuthorAndTagsFieldsAreCorrectlyMapped() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.news
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let news = try decoder.decode([GomaModels.NewsItemData].self, from: jsonData)
        
        // Ensure we have at least one news item to test
        guard let internalModel = news.first else {
            XCTFail("No news items found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.newsItem(from: internalModel)
        
        // Then
        XCTAssertEqual(domainModel.author, internalModel.author)
        XCTAssertEqual(domainModel.tags, internalModel.tags)
    }
    
    /// Test content field is correctly mapped
    func testContentFieldIsCorrectlyMapped() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.news
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let news = try decoder.decode([GomaModels.NewsItemData].self, from: jsonData)
        
        // Ensure we have at least one news item to test
        guard let internalModel = news.first else {
            XCTFail("No news items found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.newsItem(from: internalModel)
        
        // Then
        XCTAssertEqual(domainModel.content, internalModel.content)
    }
    
    /// Test URL construction for imageUrl field
    func testURLConstructionForImageUrl() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.news
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let news = try decoder.decode([GomaModels.NewsItemData].self, from: jsonData)
        
        // Ensure we have at least one news item to test
        guard let internalModel = news.first else {
            XCTFail("No news items found in test data")
            return
        }
        
        // When
        let domainModel = GomaModelMapper.newsItem(from: internalModel)
        
        // Then
        if let imageUrl = internalModel.imageUrl {
            XCTAssertEqual(domainModel.imageUrl?.absoluteString, imageUrl)
        } else {
            XCTAssertNil(domainModel.imageUrl)
        }
    }
    
    /// Test that GomaManagedContentProvider.getNews() calls the correct API endpoint
    func testGetNewsCallsCorrectAPIEndpoint() throws {
        // Given
        let expectation = XCTestExpectation(description: "API call made")
        try registerMockNewsResponse()
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getNews(pageIndex: 0, pageSize: 10)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(MockURLProtocol.requestsForEndpoint("\(TestConfiguration.EndpointPaths.news)?pageIndex=0&pageSize=10").count > 0)
    }
    
    /// Test that GomaManagedContentProvider.getNews() handles successful responses
    func testGetNewsHandlesSuccessfulResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received news")
        try registerMockNewsResponse()
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getNews(pageIndex: 0, pageSize: 10)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { news in
                    // Then
                    XCTAssertNotNil(news)
                    XCTAssertFalse(news.isEmpty, "News array should not be empty")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    /// Test that GomaManagedContentProvider.getNews() handles error responses
    func testGetNewsHandlesErrorResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received error")
        
        // Register a mock error response
        let errorURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.news)?pageIndex=0&pageSize=10")!
        MockURLProtocol.registerMockResponse(
            for: errorURL,
            statusCode: 500,
            data: "Internal Server Error".data(using: .utf8)!
        )
        
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getNews(pageIndex: 0, pageSize: 10)
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
    
    /// Test that GomaManagedContentProvider.getNews() handles empty array responses
    func testGetNewsHandlesEmptyArrayResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received empty array")
        
        // Register a mock empty array response
        let emptyURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.news)?pageIndex=0&pageSize=10")!
        MockURLProtocol.registerMockResponse(
            for: emptyURL,
            statusCode: 200,
            data: "[]".data(using: .utf8)!
        )
        
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getNews(pageIndex: 0, pageSize: 10)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Empty array should not cause failure")
                    }
                },
                receiveValue: { news in
                    // Then
                    XCTAssertTrue(news.isEmpty, "News array should be empty")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    /// Test pagination works correctly with different page indexes and sizes
    func testPaginationWorksCorrectlyWithDifferentPageIndexesAndSizes() throws {
        // Given
        let testCases = [
            (pageIndex: 0, pageSize: 10),
            (pageIndex: 1, pageSize: 20),
            (pageIndex: 2, pageSize: 5)
        ]
        
        for (pageIndex, pageSize) in testCases {
            let expectation = XCTestExpectation(description: "Pagination test for page \(pageIndex), size \(pageSize)")
            
            // Register a mock response for this pagination
            let url = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.news)?pageIndex=\(pageIndex)&pageSize=\(pageSize)")!
            
            // Create a mock response with the page index and size in the first item's title
            // to verify the correct endpoint was called
            let mockResponse = """
            [
                {
                    "id": "test-\(pageIndex)-\(pageSize)",
                    "title": "News Item Page \(pageIndex) Size \(pageSize)",
                    "image_url": "https://example.com/image.jpg",
                    "status": "published",
                    "content": "Test content",
                    "author": "Test Author",
                    "tags": ["test", "pagination"]
                }
            ]
            """.data(using: .utf8)!
            
            MockURLProtocol.registerMockResponse(
                for: url,
                statusCode: 200,
                data: mockResponse
            )
            
            let contentProvider = createMockContentProvider()
            
            // When
            contentProvider.getNews(pageIndex: pageIndex, pageSize: pageSize)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure = completion {
                            XCTFail("Should not fail")
                        }
                    },
                    receiveValue: { news in
                        // Then
                        XCTAssertFalse(news.isEmpty, "News array should not be empty")
                        if let firstItem = news.first {
                            XCTAssertEqual(firstItem.id, "test-\(pageIndex)-\(pageSize)")
                            XCTAssertEqual(firstItem.title, "News Item Page \(pageIndex) Size \(pageSize)")
                        }
                        expectation.fulfill()
                    }
                )
                .store(in: &cancellables)
            
            wait(for: [expectation], timeout: 1.0)
        }
    }
    
    /// Test the end-to-end flow with mocked API response to final domain model
    func testEndToEndFlowWithMockedAPIResponse() throws {
        // Given
        let expectation = XCTestExpectation(description: "End-to-end flow completed")
        try registerMockNewsResponse()
        let contentProvider = createMockContentProvider()
        
        // Load the expected data for comparison
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.news
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModels = try decoder.decode([GomaModels.NewsItemData].self, from: jsonData)
        let expectedDomainModels = GomaModelMapper.newsItems(from: internalModels)
        
        // When
        contentProvider.getNews(pageIndex: 0, pageSize: 10)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { news in
                    // Then
                    XCTAssertEqual(news.count, expectedDomainModels.count)
                    
                    // Compare each news item with its expected model
                    for (index, expectedItem) in expectedDomainModels.enumerated() {
                        let actualItem = news[index]
                        
                        XCTAssertEqual(actualItem.id, expectedItem.id)
                        XCTAssertEqual(actualItem.title, expectedItem.title)
                        XCTAssertEqual(actualItem.isActive, expectedItem.isActive)
                        XCTAssertEqual(actualItem.content, expectedItem.content)
                        XCTAssertEqual(actualItem.author, expectedItem.author)
                        XCTAssertEqual(actualItem.tags, expectedItem.tags)
                        
                        // Compare URLs
                        if let expectedImageURL = expectedItem.imageUrl {
                            XCTAssertEqual(actualItem.imageUrl?.absoluteString, expectedImageURL.absoluteString)
                        } else {
                            XCTAssertNil(actualItem.imageUrl)
                        }
                    }
                    
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Helper Methods
    
    /// Register a mock response for the news endpoint with the specified pagination parameters
    private func registerMockNewsResponse(pageIndex: Int = 0, pageSize: Int = 10) throws {
        let jsonData = try JSONLoader.loadJSON(
            fileName: "response.json",
            subdirectory: TestConfiguration.MockResponseDirectories.news
        )
        
        let url = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.news)?pageIndex=\(pageIndex)&pageSize=\(pageSize)")!
        MockURLProtocol.registerMockResponse(
            for: url,
            statusCode: 200,
            data: jsonData
        )
    }
} 