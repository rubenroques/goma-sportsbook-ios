import Foundation

/// Protocol for URL management services
protocol LinksManagementServiceProtocol {
    /// The current links configuration
    var links: URLEndpoint.Links { get }
    
    /// Fetch dynamic URLs from the server
    /// - Parameter completion: Completion handler called when the operation completes
    func fetchDynamicURLs(completion: @escaping (Bool) -> Void)
} 
