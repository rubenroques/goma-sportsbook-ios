import Foundation
import Combine

/// `PresentationManager` is the main entry point for fetching presentation configuration.
/// It acts as a facade, deciding whether to use a local or a (future) remote fetcher.
public class PresentationManager: PresentationConfigurationServicing {

    private let localFetcher: PresentationConfigurationFetching
    // private let remoteFetcher: PresentationConfigurationFetching // To be implemented

    /// Configuration for the PresentationManager.
    public struct Configuration {
        let useLocalFallback: Bool
        let localFileName: String
        let localBundle: Bundle
        // Add other relevant configurations, e.g., remoteURL

        public init(
            useLocalFallback: Bool = true,
            localFileName: String = "presentation_config.json",
            localBundle: Bundle = .main
        ) {
            self.useLocalFallback = useLocalFallback
            self.localFileName = localFileName
            self.localBundle = localBundle
        }
    }

    private let configuration: Configuration

    /// Initializes a new `PresentationManager`.
    ///
    /// - Parameter configuration: The configuration for the manager.
    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
        self.localFetcher = LocalJSONPresentationFetcher(
            fileName: configuration.localFileName,
            bundle: configuration.localBundle
        )
        // self.remoteFetcher = RemotePresentationFetcher() // Initialize when implemented
    }

    /// Determines if the remote fetcher should be used.
    /// This is a placeholder for more complex logic (e.g., checking network, feature flags).
    private func shouldUseRemote() -> Bool {
        // For now, always prefer local until remote is implemented
        return false
    }

    /// Fetches the presentation configuration.
    ///
    /// It will attempt to use a remote fetcher if configured and available.
    /// If the remote fetch fails or is not preferred, it may fall back to the local fetcher
    /// based on the `useLocalFallback` configuration.
    ///
    /// - Returns: A publisher that emits a `PresentationConfiguration` on success or an `Error` on failure.
    public func fetchPresentationConfiguration() -> AnyPublisher<PresentationConfiguration, Error> {
        if shouldUseRemote() {
            // return remoteFetcher.fetchPresentationConfiguration()
            //    .catch { error -> AnyPublisher<PresentationConfiguration, Error> in
            //        if self.configuration.useLocalFallback {
            //            return self.localFetcher.fetchPresentationConfiguration()
            //        } else {
            //            return Fail(error: error).eraseToAnyPublisher()
            //        }
            //    }
            //    .eraseToAnyPublisher()
            // For now, since remoteFetcher is not implemented, directly use local or fail.
            // This part needs to be updated when remoteFetcher is available.
             return localFetcher.fetchPresentationConfiguration() // Placeholder
        } else {
            return localFetcher.fetchPresentationConfiguration()
        }
    }
} 
