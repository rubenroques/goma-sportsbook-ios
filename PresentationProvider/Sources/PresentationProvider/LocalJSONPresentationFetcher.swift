import Foundation
import Combine

// All types are in the same module, so no need for additional imports

/// Implementation of `PresentationConfigurationFetching` that loads configuration from a local JSON file
///
/// This class provides a way to load presentation configuration from a JSON file in the app bundle.
/// It's useful for apps with static configuration or for testing purposes.
///
/// - Example:
///   ```swift
///   // Load from the default "presentation_config.json" file
///   let fetcher = LocalJSONPresentationFetcher()
///
///   // Or specify a custom file name and bundle
///   let fetcher = LocalJSONPresentationFetcher(fileName: "custom_config.json", bundle: myBundle)
///
///   fetcher.fetchPresentationConfiguration()
///       .sink(receiveCompletion: { _ in }, receiveValue: { config in
///           // Use the configuration
///       })
///       .store(in: &cancellables)
///   ```

public class LocalJSONPresentationFetcher: PresentationConfigurationFetching {
    /// Errors that can occur during the fetch process
    public enum FetchError: Error, Equatable {
        /// The JSON file was not found in the specified bundle
        case fileNotFound
        
        /// The JSON data was corrupted or malformed
        case dataCorrupted(description: String)
        
        /// An error occurred while decoding the JSON
        case decodingError(Error)
        
        /// An unknown error occurred
        case unknown(Error)
        
        public static func == (lhs: FetchError, rhs: FetchError) -> Bool {
            switch (lhs, rhs) {
            case (.fileNotFound, .fileNotFound):
                return true
            case (.dataCorrupted(let lDesc), .dataCorrupted(let rDesc)):
                return lDesc == rDesc
            case (.decodingError(let lErr), .decodingError(let rErr)):
                // Comparing underlying errors can be tricky, this is a simplified comparison
                return String(describing: lErr) == String(describing: rErr)
            case (.unknown(let lErr), .unknown(let rErr)):
                return String(describing: lErr) == String(describing: rErr)
            default:
                return false
            }
        }
    }
    
    /// The name of the JSON file to load
    private let fileName: String
    
    /// The bundle containing the JSON file
    private let bundle: Bundle
    
    /// Initializes a new `LocalJSONPresentationFetcher`
    ///
    /// - Parameters:
    ///   - fileName: The name of the JSON file to load (default: "presentation_config.json")
    ///   - bundle: The bundle containing the JSON file (default: Bundle.main)
    public init(fileName: String = "presentation_config.json", bundle: Bundle = .main) {
        self.fileName = fileName
        self.bundle = bundle
    }
    
    /// Fetches presentation configuration from the local JSON file
    ///
    /// - Returns: A publisher that emits a `PresentationConfiguration` on success or an `Error` on failure.
    public func fetchPresentationConfiguration() -> AnyPublisher<PresentationConfiguration, Error> {
        return Deferred {
            Future { promise in
                guard let url = self.bundle.url(forResource: self.fileName, withExtension: nil) else {
                    promise(.failure(FetchError.fileNotFound))
                    return
                }
                
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let configuration = try decoder.decode(PresentationConfiguration.self, from: data)
                    promise(.success(configuration))
                } catch let error as DecodingError {
                    promise(.failure(FetchError.decodingError(error)))
                } catch {
                    promise(.failure(FetchError.unknown(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
} 
