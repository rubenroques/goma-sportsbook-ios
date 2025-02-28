import XCTest
import Combine
@testable import ServicesProvider

/// Integration tests for the Home Template endpoint
class HomeTemplateTests: BaseIntegrationTest {
    
    /// Test that GomaPromotionsAPIClient.homeTemplate builds the correct URL with query parameters
    func testHomeTemplateEndpointBuildsCorrectURL() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )
        
        // When
        let request = apiClient.homeTemplate()
        
        // Then
        XCTAssertEqual(
            request.url?.absoluteString,
            "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.homeTemplate)?platform=ios"
        )
    }
    
    /// Test that GomaPromotionsAPIClient.homeTemplate uses the correct HTTP method (GET)
    func testHomeTemplateEndpointUsesCorrectHTTPMethod() {
        // Given
        let apiClient = GomaPromotionsAPIClient(
            baseURL: URL(string: TestConfiguration.API.baseURL)!,
            apiKey: TestConfiguration.API.apiKey,
            session: mockURLSession
        )
        
        // When
        let request = apiClient.homeTemplate()
        
        // Then
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    /// Test that the JSON response for homeTemplate decodes to GomaModels.HomeTemplate
    func testHomeTemplateResponseDecodesToInternalModel() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.homeTemplate,
            filename: "response.json"
        )
        
        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let homeTemplate = try decoder.decode(GomaModels.HomeTemplate.self, from: jsonData)
        
        // Then
        XCTAssertNotNil(homeTemplate)
        XCTAssertNotNil(homeTemplate.id)
        XCTAssertNotNil(homeTemplate.name)
        XCTAssertNotNil(homeTemplate.widgets)
        XCTAssertFalse(homeTemplate.widgets.isEmpty)
    }
    
    /// Test that GomaModelMapper.homeTemplate transforms GomaModels.HomeTemplate to HomeTemplate correctly
    func testHomeTemplateModelMapperTransformsCorrectly() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.homeTemplate,
            filename: "response.json"
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModel = try decoder.decode(GomaModels.HomeTemplate.self, from: jsonData)
        
        // When
        let domainModel = GomaModelMapper.homeTemplate(from: internalModel)
        
        // Then
        XCTAssertEqual(domainModel.id, internalModel.id)
        XCTAssertEqual(domainModel.name, internalModel.name)
        XCTAssertEqual(domainModel.widgets.count, internalModel.widgets.count)
    }
    
    /// Test that widget types are correctly mapped in the transformation
    func testWidgetTypesAreCorrectlyMapped() throws {
        // Given
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.homeTemplate,
            filename: "response.json"
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModel = try decoder.decode(GomaModels.HomeTemplate.self, from: jsonData)
        
        // When
        let domainModel = GomaModelMapper.homeTemplate(from: internalModel)
        
        // Then
        for (index, widget) in internalModel.widgets.enumerated() {
            let mappedWidget = domainModel.widgets[index]
            XCTAssertEqual(mappedWidget.id, widget.id)
            XCTAssertEqual(mappedWidget.name, widget.name)
            XCTAssertEqual(mappedWidget.description, widget.description)
            
            // Check that the widget type is correctly mapped based on the name
            switch widget.name {
            case "alertBanners":
                XCTAssertEqual(mappedWidget.type, .alertBanners)
            case "banners":
                XCTAssertEqual(mappedWidget.type, .banners)
            case "sportBanners":
                XCTAssertEqual(mappedWidget.type, .sportBanners)
            case "boostedOddsBanners":
                XCTAssertEqual(mappedWidget.type, .boostedOddsBanners)
            case "heroCards":
                XCTAssertEqual(mappedWidget.type, .heroCards)
            case "stories":
                XCTAssertEqual(mappedWidget.type, .stories)
            case "news":
                XCTAssertEqual(mappedWidget.type, .news)
            case "proChoices":
                XCTAssertEqual(mappedWidget.type, .proChoices)
            default:
                XCTAssertEqual(mappedWidget.type, .unknown)
            }
        }
    }
    
    /// Test that GomaManagedContentProvider.getHomeTemplate() calls the correct API endpoint
    func testGetHomeTemplateCallsCorrectAPIEndpoint() throws {
        // Given
        let expectation = XCTestExpectation(description: "API call made")
        try registerMockHomeTemplateResponse()
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getHomeTemplate()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(MockURLProtocol.requestsForEndpoint(TestConfiguration.EndpointPaths.homeTemplate).count > 0)
    }
    
    /// Test that GomaManagedContentProvider.getHomeTemplate() handles successful responses
    func testGetHomeTemplateHandlesSuccessfulResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received home template")
        try registerMockHomeTemplateResponse()
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getHomeTemplate()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { homeTemplate in
                    // Then
                    XCTAssertNotNil(homeTemplate)
                    XCTAssertFalse(homeTemplate.widgets.isEmpty)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    /// Test that GomaManagedContentProvider.getHomeTemplate() handles error responses
    func testGetHomeTemplateHandlesErrorResponses() throws {
        // Given
        let expectation = XCTestExpectation(description: "Received error")
        
        // Register a mock error response
        let errorURL = URL(string: "\(TestConfiguration.API.baseURL)\(TestConfiguration.EndpointPaths.homeTemplate)?platform=ios")!
        MockURLProtocol.registerMockResponse(
            for: errorURL,
            statusCode: 500,
            data: "Internal Server Error".data(using: .utf8)!
        )
        
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getHomeTemplate()
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
    
    /// Test that GomaManagedContentProvider.getHomeTemplate() applies authentication correctly
    func testGetHomeTemplateAppliesAuthenticationCorrectly() throws {
        // Given
        let expectation = XCTestExpectation(description: "API call made with authentication")
        try registerMockHomeTemplateResponse()
        let contentProvider = createMockContentProvider()
        
        // When
        contentProvider.getHomeTemplate()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        let requests = MockURLProtocol.requestsForEndpoint(TestConfiguration.EndpointPaths.homeTemplate)
        XCTAssertTrue(requests.count > 0)
        
        let request = requests.first!
        XCTAssertNotNil(request.allHTTPHeaderFields?["Authorization"])
        XCTAssertEqual(
            request.allHTTPHeaderFields?["Authorization"],
            "Bearer \(TestConfiguration.authToken)"
        )
    }
    
    /// Test the end-to-end flow with mocked API response to final domain model
    func testEndToEndFlowWithMockedAPIResponse() throws {
        // Given
        let expectation = XCTestExpectation(description: "End-to-end flow completed")
        try registerMockHomeTemplateResponse()
        let contentProvider = createMockContentProvider()
        
        // Load the expected data for comparison
        let jsonData = try JSONLoader.loadJSON(
            fromSubdirectory: TestConfiguration.MockResponseDirectories.homeTemplate,
            filename: "response.json"
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let internalModel = try decoder.decode(GomaModels.HomeTemplate.self, from: jsonData)
        let expectedDomainModel = GomaModelMapper.homeTemplate(from: internalModel)
        
        // When
        contentProvider.getHomeTemplate()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { homeTemplate in
                    // Then
                    XCTAssertEqual(homeTemplate.id, expectedDomainModel.id)
                    XCTAssertEqual(homeTemplate.name, expectedDomainModel.name)
                    XCTAssertEqual(homeTemplate.widgets.count, expectedDomainModel.widgets.count)
                    
                    // Compare each widget
                    for (index, expectedWidget) in expectedDomainModel.widgets.enumerated() {
                        let actualWidget = homeTemplate.widgets[index]
                        XCTAssertEqual(actualWidget.id, expectedWidget.id)
                        XCTAssertEqual(actualWidget.name, expectedWidget.name)
                        XCTAssertEqual(actualWidget.description, expectedWidget.description)
                        XCTAssertEqual(actualWidget.type, expectedWidget.type)
                    }
                    
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
} 