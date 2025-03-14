import Foundation
import Combine

/// A URL provider that uses the URL management service to provide dynamic URLs
class DynamicLinksProvider: LinksProviderProtocol {
    private let urlManagementService: LinksManagementServiceProtocol

    /// The current links configuration
    var links: URLEndpoint.Links {
        return urlManagementService.links
    }

    /// Initialize the dynamic URL provider
    /// - Parameter urlManagementService: The URL management service
    init(urlManagementService: LinksManagementServiceProtocol) {
        self.urlManagementService = urlManagementService
    }

    /// Get a URL for a specific path
    /// - Parameter path: The URL path
    /// - Returns: The URL string
    func getURL(for path: URLPath) -> String {
        return links.getURL(for: path)
    }

    /// Fetch dynamic URLs from the server
    /// - Parameter completion: Completion handler called when the operation completes
    func fetchDynamicURLsIfNeeded(completion: @escaping (Bool) -> Void) {
        urlManagementService.fetchDynamicURLs(completion: completion)
    }
}
