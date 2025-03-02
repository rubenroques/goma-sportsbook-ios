import XCTest
import Combine
@testable import ServicesProvider

/// A mock implementation of GomaConnector for testing purposes
class MockGomaConnector: GomaConnector {
    var mockSession: URLSession
    var baseURL: URL
    var apiKey: String
    
    // Track requests that would have been made
    var capturedEndpoints: [Endpoint] = []
    
    // Store prepared responses for endpoints
    var mockResponses: [String: (Data, HTTPURLResponse)] = [:]
    
    init(baseURL: URL, apiKey: String, session: URLSession) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.mockSession = session
    }
    
    // Method to capture the request and return a pre-defined response
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, ServiceProviderError> {
        capturedEndpoints.append(endpoint)
        
        // Get the request that would be created
        guard let urlRequest = endpoint.request() else {
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }
        
        // If we have a mock response for this endpoint, return it
        if let urlString = urlRequest.url?.absoluteString,
           let (data, response) = mockResponses[urlString] {
            
            // Try to decode the response data
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedResponse = try decoder.decode(T.self, from: data)
                return Just(decodedResponse)
                    .setFailureType(to: ServiceProviderError.self)
                    .eraseToAnyPublisher()
            } catch {
                return Fail(error: ServiceProviderError.decodingError(error)).eraseToAnyPublisher()
            }
        }
        
        // Otherwise, return a generic error
        return Fail(error: ServiceProviderError.networkError("No mock response configured for this endpoint")).eraseToAnyPublisher()
    }
    
    // Method to register a mock response for a specific URL
    func registerMockResponse(for url: URL, data: Data, statusCode: Int = 200) {
        let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        
        mockResponses[url.absoluteString] = (data, response)
    }
} 