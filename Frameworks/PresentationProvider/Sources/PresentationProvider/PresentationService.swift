import Foundation
import Combine

/// Protocol for fetching presentation configuration data
///
/// Implement this protocol to provide a mechanism for fetching presentation configuration,
/// such as from a local JSON file, a remote API, or any other data source.
///
/// - Example:
///   ```swift
///   let fetcher: PresentationConfigurationServicing = // ... your fetcher instance
///   fetcher.fetchPresentationConfiguration()
///       .sink(
///           receiveCompletion: { completion in
///               if case .failure(let error) = completion {
///                   // Handle error
///               }
///           },
///           receiveValue: { config in
///               // Use the configuration
///               updateTabBar(with: config.tabItems(forNavbar: .sports))
///           }
///       )
///       .store(in: &cancellables) // Assuming you have a Set<AnyCancellable>
///   ```

public protocol PresentationConfigurationFetching {
    /// Fetches the presentation configuration asynchronously
    ///
    /// - Returns: A publisher that emits a `PresentationConfiguration` on success or an `Error` on failure.
    func fetchPresentationConfiguration() -> AnyPublisher<PresentationConfiguration, Error>
}

/// Type alias for the main presentation configuration service type
/// This allows for future extension of the protocol while maintaining backward compatibility
public typealias PresentationConfigurationServicing = PresentationConfigurationFetching 
