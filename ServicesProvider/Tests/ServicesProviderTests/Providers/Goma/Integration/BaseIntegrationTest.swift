import XCTest
import Combine
@testable import ServicesProvider

/// Base class for integration tests
class BaseIntegrationTest: XCTestCase {
    
    /// URLSession configured with MockURLProtocol
    var mockURLSession: URLSession!
    
    /// Set of cancellables for Combine subscriptions
    var cancellables: Set<AnyCancellable> = []
    
    /// Setup method called before each test
    override func setUp() {
        super.setUp()
        
        // Reset mock responses
        MockURLProtocol.reset()
        
        // Create a configuration with the mock protocol
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        
        // Create a URLSession with the configuration
        mockURLSession = URLSession(configuration: configuration)
    }
    
    /// Teardown method called after each test
    override func tearDown() {
        // Cancel all subscriptions
        cancellables.removeAll()
        
        // Reset mock responses
        MockURLProtocol.reset()
        
        // Nil out the session
        mockURLSession = nil
        
        super.tearDown()
    }
    
    /// Create a GomaAPIAuthenticator with a mock token
    /// - Returns: A configured GomaAPIAuthenticator
    func createMockAuthenticator() -> GomaAPIAuthenticator {
        let authenticator = GomaAPIAuthenticator(deviceUUID: TestConfiguration.API.deviceUUID, 
                                                deviceType: TestConfiguration.API.deviceType,
                                                apiKey: TestConfiguration.API.apiKey)
        
        // Set a mock token
        authenticator.setToken(TestConfiguration.authToken)
        
        return authenticator
    }
    
    /// Create a GomaManagedContentProvider with mock dependencies
    /// - Returns: A configured GomaManagedContentProvider
    func createMockContentProvider() -> GomaManagedContentProvider {
        let authenticator = createMockAuthenticator()
        return GomaManagedContentProvider(gomaAPIAuthenticator: authenticator)
    }
    
    /// Register mock responses for all endpoints
    /// - Throws: If loading the mock responses fails
    func registerAllMockResponses() throws {
        try registerMockHomeTemplateResponse()
        try registerMockAlertBannerResponse()
        try registerMockBannersResponse()
        try registerMockSportBannersResponse()
        try registerMockBoostedOddsBannersResponse()
        try registerMockHeroCardsResponse()
        try registerMockStoriesResponse()
        try registerMockNewsResponse()
        try registerMockProChoicesResponse()
        try registerMockInitialDumpResponse()
    }
    
    /// Register a mock response for the home template endpoint
    /// - Throws: If loading the mock response fails
    func registerMockHomeTemplateResponse() throws {
        try MockURLProtocol.registerMockResponseForGomaEndpoint(
            endpoint: TestConfiguration.EndpointPaths.homeTemplate,
            subdirectory: TestConfiguration.MockResponseDirectories.homeTemplate
        )
    }
    
    /// Register a mock response for the alert banner endpoint
    /// - Throws: If loading the mock response fails
    func registerMockAlertBannerResponse() throws {
        try MockURLProtocol.registerMockResponseForGomaEndpoint(
            endpoint: TestConfiguration.EndpointPaths.alertBanner,
            subdirectory: TestConfiguration.MockResponseDirectories.alertBanner
        )
    }
    
    /// Register a mock response for the banners endpoint
    /// - Throws: If loading the mock response fails
    func registerMockBannersResponse() throws {
        try MockURLProtocol.registerMockResponseForGomaEndpoint(
            endpoint: TestConfiguration.EndpointPaths.banners,
            subdirectory: TestConfiguration.MockResponseDirectories.banners
        )
    }
    
    /// Register a mock response for the sport banners endpoint
    /// - Throws: If loading the mock response fails
    func registerMockSportBannersResponse() throws {
        try MockURLProtocol.registerMockResponseForGomaEndpoint(
            endpoint: TestConfiguration.EndpointPaths.sportBanners,
            subdirectory: TestConfiguration.MockResponseDirectories.sportBanners
        )
    }
    
    /// Register a mock response for the boosted odds banners endpoint
    /// - Throws: If loading the mock response fails
    func registerMockBoostedOddsBannersResponse() throws {
        try MockURLProtocol.registerMockResponseForGomaEndpoint(
            endpoint: TestConfiguration.EndpointPaths.boostedOddsBanners,
            subdirectory: TestConfiguration.MockResponseDirectories.boostedOddsBanners
        )
    }
    
    /// Register a mock response for the hero cards endpoint
    /// - Throws: If loading the mock response fails
    func registerMockHeroCardsResponse() throws {
        try MockURLProtocol.registerMockResponseForGomaEndpoint(
            endpoint: TestConfiguration.EndpointPaths.heroCards,
            subdirectory: TestConfiguration.MockResponseDirectories.heroCards
        )
    }
    
    /// Register a mock response for the stories endpoint
    /// - Throws: If loading the mock response fails
    func registerMockStoriesResponse() throws {
        try MockURLProtocol.registerMockResponseForGomaEndpoint(
            endpoint: TestConfiguration.EndpointPaths.stories,
            subdirectory: TestConfiguration.MockResponseDirectories.stories
        )
    }
    
    /// Register a mock response for the news endpoint
    /// - Throws: If loading the mock response fails
    func registerMockNewsResponse() throws {
        try MockURLProtocol.registerMockResponseForGomaEndpoint(
            endpoint: TestConfiguration.EndpointPaths.news,
            subdirectory: TestConfiguration.MockResponseDirectories.news
        )
    }
    
    /// Register a mock response for the pro choices endpoint
    /// - Throws: If loading the mock response fails
    func registerMockProChoicesResponse() throws {
        try MockURLProtocol.registerMockResponseForGomaEndpoint(
            endpoint: TestConfiguration.EndpointPaths.proChoices,
            subdirectory: TestConfiguration.MockResponseDirectories.proChoices
        )
    }
    
    /// Register a mock response for the initial dump endpoint
    /// - Throws: If loading the mock response fails
    func registerMockInitialDumpResponse() throws {
        try MockURLProtocol.registerMockResponseForGomaEndpoint(
            endpoint: TestConfiguration.EndpointPaths.initialDump,
            subdirectory: TestConfiguration.MockResponseDirectories.initialDump
        )
    }
} 