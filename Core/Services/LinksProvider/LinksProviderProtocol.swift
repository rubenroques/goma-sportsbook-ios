import Foundation

/// Protocol for URL providers
protocol LinksProviderProtocol {
    /// The current links configuration
    var links: URLEndpoint.Links { get }

    /// Get a URL for a specific path
    /// - Parameter path: The URL path
    /// - Returns: The URL string
    func getURL(for path: URLPath) -> String

    /// Fetch dynamic URLs from the server
    /// - Parameter completion: Completion handler called when the operation completes
    func fetchDynamicURLsIfNeeded(completion: @escaping (Bool) -> Void)
}
