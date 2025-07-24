import Foundation

/// A URL provider that uses static links
class StaticLinksProvider: LinksProviderProtocol {
    /// The current links configuration
    let links: URLEndpoint.Links
    
    /// Initialize the static URL provider
    /// - Parameter links: The static links
    init(links: URLEndpoint.Links) {
        self.links = links
    }
    
    /// Get a URL for a specific path
    /// - Parameter path: The URL path
    /// - Returns: The URL string
    func getURL(for path: URLPath) -> String {
        return links.getURL(for: path)
    }
    
    /// Fetch dynamic URLs from the server (no-op for static provider)
    /// - Parameter completion: Completion handler called when the operation completes
    func fetchDynamicURLs(completion: @escaping (Bool) -> Void) {
        // Static provider doesn't fetch dynamic URLs
        completion(true)
    }
} 
