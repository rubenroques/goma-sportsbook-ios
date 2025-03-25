import Foundation
import ServicesProvider

/// Factory for creating URL providers
class LinksProviderFactory {
    /// Create a URL provider
    /// - Parameters:
    ///   - initialLinks: The initial links configuration
    ///   - servicesProvider: The services provider client
    /// - Returns: A URL provider
    static func createURLProvider(initialLinks: URLEndpoint.Links, servicesProvider: ServicesProvider.Client) -> LinksProviderProtocol {
        let urlManagementService = LinksManagementService(
            initialLinks: initialLinks,
            servicesProvider: servicesProvider
        )
        return DynamicLinksProvider(urlManagementService: urlManagementService)
    }
    
    /// Create a static URL provider
    /// - Parameter links: The static links
    /// - Returns: A static URL provider
    static func createStaticURLProvider(links: URLEndpoint.Links) -> LinksProviderProtocol {
        return StaticLinksProvider(links: links)
    }
} 
