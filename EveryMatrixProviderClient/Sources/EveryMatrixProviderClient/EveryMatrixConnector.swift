import Foundation
import Combine

/// A class responsible for making authenticated HTTP requests to the EveryMatrix API
public final class EveryMatrixConnector {
    /// The authenticator used for managing session tokens
    private let authenticator: EveryMatrixAuthenticator
    
    /// URLSession for making network requests
    private let session: URLSession
    
    /// JSON decoder for parsing responses
    private let decoder: JSONDecoder
    
    /// Initialize a new EveryMatrixConnector
    /// - Parameters:
    ///   - authenticator: The authenticator to use for managing session tokens
    ///   - session: URLSession to use for network requests (defaults to shared session)
    ///   - decoder: JSONDecoder to use for response parsing (defaults to new instance)
    public init(
        authenticator: EveryMatrixAuthenticator,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.authenticator = authenticator
        self.session = session
        self.decoder = decoder
    }
    
    /// Make a request to the EveryMatrix API
    /// - Parameter endpoint: The endpoint to request
    /// - Returns: A publisher that emits the decoded response or an error
    public func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, EveryMatrixAuthenticationError> {
        guard let request = endpoint.request() else {
            return Fail(error: EveryMatrixAuthenticationError.invalidRequest("Unable to assemble Request")).eraseToAnyPublisher()
        }
        
        // Add session token if required
        var finalRequest = request
        if endpoint.requireSessionKey, let token = authenticator.getToken() {
            finalRequest.setValue(token, forHTTPHeaderField: "X-SessionId")
        }
        
        return session.dataTaskPublisher(for: finalRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 401:
                    throw EveryMatrixAuthenticationError.loginRequired
                case 403:
                    throw EveryMatrixAuthenticationError.invalidToken
                default:
                    throw EveryMatrixAuthenticationError.unknown("Unknown error: \(httpResponse.statusCode)")
                }
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { error -> EveryMatrixAuthenticationError in
                if let emError = error as? EveryMatrixAuthenticationError {
                    return emError
                } else {
                    return EveryMatrixAuthenticationError.unknown(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}
