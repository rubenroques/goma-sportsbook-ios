import Foundation

/// A URLProtocol subclass that intercepts network requests and returns mock responses
class MockURLProtocol: URLProtocol {
    
    /// Dictionary mapping URL strings to mock response data
    static var mockResponses: [String: (data: Data, statusCode: Int, headers: [String: String])] = [:]
    
    /// Dictionary mapping URL patterns (regex) to mock response data
    static var mockResponsePatterns: [(pattern: NSRegularExpression, handler: (URLRequest) -> (data: Data, statusCode: Int, headers: [String: String])?)] = []
    
    /// Dictionary to track requests that have been made
    static var requestsMap: [String: Int] = [:]
    
    /// Reset all mock responses and request tracking
    static func reset() {
        mockResponses = [:]
        mockResponsePatterns = []
        requestsMap = [:]
    }
    
    /// Register a mock response for a specific URL
    /// - Parameters:
    ///   - url: The URL to mock
    ///   - data: The response data
    ///   - statusCode: The HTTP status code (default: 200)
    ///   - headers: The HTTP headers (default: empty)
    static func registerMockResponse(for url: URL, 
                                    data: Data, 
                                    statusCode: Int = 200, 
                                    headers: [String: String] = [:]) {
        mockResponses[url.absoluteString] = (data, statusCode, headers)
    }
    
    /// Register a mock response for a URL pattern (regex)
    /// - Parameters:
    ///   - pattern: The regex pattern to match URLs
    ///   - handler: A closure that returns the mock response for a matching request
    static func registerMockResponsePattern(pattern: String, 
                                           handler: @escaping (URLRequest) -> (data: Data, statusCode: Int, headers: [String: String])?) {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            mockResponsePatterns.append((regex, handler))
        } catch {
            print("Error creating regex for pattern \(pattern): \(error)")
        }
    }
    
    /// Register a mock response for a specific endpoint in the Goma API
    /// - Parameters:
    ///   - endpoint: The endpoint path (e.g., "/api/promotions/v1/home-template")
    ///   - subdirectory: The subdirectory in the mock responses directory
    ///   - fileName: The name of the JSON file (default: "response.json")
    ///   - statusCode: The HTTP status code (default: 200)
    ///   - headers: The HTTP headers (default: empty)
    static func registerMockResponseForGomaEndpoint(endpoint: String,
                                                  subdirectory: String,
                                                  fileName: String = "response.json",
                                                  statusCode: Int = 200,
                                                  headers: [String: String] = [:]) throws {
        let data = try JSONLoader.loadJSON(fileName: fileName, subdirectory: subdirectory)
        
        // Create a pattern that matches the endpoint with any query parameters
        let pattern = "https://api\\.gomademo\\.com\(endpoint)(\\?.*)?$"
        
        registerMockResponsePattern(pattern: pattern) { _ in
            return (data, statusCode, headers)
        }
    }
    
    /// Check if this protocol can handle the given request
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    /// Canonicalize the request (required by URLProtocol)
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    /// Start loading the request
    override func startLoading() {
        guard let url = request.url?.absoluteString else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "MockURLProtocol", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL is nil"]))
            return
        }
        
        // Track the request
        MockURLProtocol.requestsMap[url] = (MockURLProtocol.requestsMap[url] ?? 0) + 1
        
        // Check for exact URL match
        if let mockResponse = MockURLProtocol.mockResponses[url] {
            sendResponse(mockResponse.data, statusCode: mockResponse.statusCode, headers: mockResponse.headers)
            return
        }
        
        // Check for pattern matches
        for (pattern, handler) in MockURLProtocol.mockResponsePatterns {
            let urlRange = NSRange(location: 0, length: url.count)
            if pattern.firstMatch(in: url, options: [], range: urlRange) != nil {
                if let mockResponse = handler(request) {
                    sendResponse(mockResponse.data, statusCode: mockResponse.statusCode, headers: mockResponse.headers)
                    return
                }
            }
        }
        
        // No mock found, return a 404
        let errorData = "No mock response found for URL: \(url)".data(using: .utf8)!
        sendResponse(errorData, statusCode: 404, headers: ["Content-Type": "text/plain"])
    }
    
    /// Stop loading the request (required by URLProtocol)
    override func stopLoading() {
        // Nothing to do
    }
    
    /// Send a mock response to the client
    /// - Parameters:
    ///   - data: The response data
    ///   - statusCode: The HTTP status code
    ///   - headers: The HTTP headers
    private func sendResponse(_ data: Data, statusCode: Int, headers: [String: String]) {
        guard let url = request.url else { return }
        
        // Create a response
        var responseHeaders = headers
        responseHeaders["Content-Length"] = "\(data.count)"
        
        let response = HTTPURLResponse(url: url, 
                                      statusCode: statusCode, 
                                      httpVersion: "HTTP/1.1", 
                                      headerFields: responseHeaders)!
        
        // Send the response to the client
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }
} 