import XCTest
import Combine
@testable import Core
@testable import ServicesProvider

class URLManagementServiceTests: XCTestCase {

    func testMockURLManagementService() {
        // Given
        let mockService = URLManagementService.mock

        // When
        let helpCenterURL = mockService.links.support.helpCenter

        // Then
        XCTAssertEqual(helpCenterURL, "https://mock.help.com/")
    }

    func testURLPathAccess() {
        // Given
        let mockService = URLManagementService.mock
        let urlProvider = DynamicURLProvider(urlManagementService: mockService)

        // When
        let helpCenterURL = urlProvider.getURL(for: .helpCenter)

        // Then
        XCTAssertEqual(helpCenterURL, "https://mock.help.com/")
    }
    
    func testFetchDynamicURLs() {
        // Given
        let mockService = URLManagementService.mock
        
        // Force cache expiration by setting it to the past
        let mockUserDefaults = MockUserDefaults()
        mockUserDefaults.set(Date().addingTimeInterval(-3600), forKey: "cached_dynamic_urls_expiration")
        
        // Create a service with the expired cache
        let service = URLManagementService(
            initialLinks: URLEndpoint.Links.empty,
            servicesProvider: MockServicesProviderClient(),
            userDefaults: mockUserDefaults
        )
        
        let urlProvider = DynamicURLProvider(urlManagementService: service)
        let expectation = XCTestExpectation(description: "Fetch dynamic URLs")
        
        // When
        urlProvider.fetchDynamicURLs { success in
            // Then
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchDynamicURLsWithValidCache() {
        // Given
        // Create a mock user defaults with a valid cache
        let mockUserDefaults = MockUserDefaults()
        mockUserDefaults.set(Date().addingTimeInterval(3600), forKey: "cached_dynamic_urls_expiration")
        
        // Create a mock service provider that would fail if called
        let mockServicesProvider = MockServicesProviderClient()
        mockServicesProvider.shouldFailIfCalled = true
        
        // Create a service with the valid cache
        let service = URLManagementService(
            initialLinks: URLEndpoint.Links.empty,
            servicesProvider: mockServicesProvider,
            userDefaults: mockUserDefaults
        )
        
        let urlProvider = DynamicURLProvider(urlManagementService: service)
        let expectation = XCTestExpectation(description: "Use cached URLs")
        
        // When
        urlProvider.fetchDynamicURLs { success in
            // Then
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testStaticURLProviderFetchDynamicURLs() {
        // Given
        let staticLinks = URLEndpoint.Links(
            api: URLEndpoint.APIs.empty,
            support: URLEndpoint.Support.empty,
            responsibleGaming: URLEndpoint.ResponsibleGaming.empty,
            socialMedia: URLEndpoint.SocialMedia.empty,
            legalAndInfo: URLEndpoint.LegalAndInfo.empty
        )
        let urlProvider = StaticURLProvider(links: staticLinks)
        let expectation = XCTestExpectation(description: "Fetch dynamic URLs from static provider")
        
        // When
        urlProvider.fetchDynamicURLs { success in
            // Then
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
