import Foundation
import Combine



/// API errors that can occur during network requests
public enum APIError: Error {
    /// Invalid Request
    case invalidRequest
    /// Invalid or malformed URL
    case invalidURL
    /// Request failed with a specific HTTP status code
    case httpError(statusCode: Int, data: Data?)
    /// Error during response decoding
    case decodingError(Error)
    /// Network error during request
    case networkError(Error)
    /// Unknown error
    case unknown(Error?)

    /// Human-readable error description
    public var description: String {
        switch self {
        case .invalidRequest:
            return "Invalid Request, cloud not the assembled"
        case .invalidURL:
            return "Invalid URL"
        case .httpError(let statusCode, _):
            return "HTTP Error: Status code \(statusCode)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown(let error):
            return error.map { "Unknown error: \($0.localizedDescription)" } ?? "Unknown error"
        }
    }
}

/// Generic network client for making API requests
public class NetworkClient {
    /// URLSession used for network requests
    private let session: URLSession

    /// JSON decoder with default configuration
    private let decoder: JSONDecoder

    /// Initialize a new NetworkClient
    /// - Parameter session: URLSession to use for network requests (defaults to .shared)
    public init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.decoder.keyDecodingStrategy = .useDefaultKeys
    }

    // MARK: - Async/Await Methods

    /// Perform a network request and decode the response as a specified type
    /// - Parameters:
    ///   - endpoint: The API endpoint to request
    /// - Returns: Decoded response of type T
    /// - Throws: APIError if the request fails or cannot be decoded
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        do {
            guard
                let request = endpoint.request()
            else {
                throw APIError.invalidRequest
            }
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown(nil)
            }

            // Check for successful HTTP status code
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
            }

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    // MARK: - Combine Methods

    /// Perform a network request and return a publisher with the decoded response
    /// - Parameter endpoint: The API endpoint to request
    /// - Returns: A publisher that emits the decoded response or an error
    func requestPublisher<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, Error> {
        do {
            guard
                let request = endpoint.request()
            else {
                throw APIError.invalidRequest
            }
            return session.dataTaskPublisher(for: request)
                .tryMap { data, response in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw APIError.unknown(nil)
                    }

                    guard (200...299).contains(httpResponse.statusCode) else {
                        throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
                    }

                    return data
                }
                .decode(type: T.self, decoder: decoder)
                .mapError { error in
                    if let apiError = error as? APIError {
                        return apiError
                    } else if error is DecodingError {
                        return APIError.decodingError(error)
                    } else {
                        return APIError.unknown(error)
                    }
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }

}
