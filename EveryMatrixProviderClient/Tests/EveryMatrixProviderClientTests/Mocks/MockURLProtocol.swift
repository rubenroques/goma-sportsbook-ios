import Foundation
import XCTest // Needed for potential XCTFail in handler if desired

/// A custom URLProtocol for mocking network responses in tests.
///
/// Configure the desired response using the static properties (`responseData`, `responseError`, `httpResponse`)
/// or the `requestHandler` closure before making the network request.
class MockURLProtocol: URLProtocol {

    // MARK: - Configuration Properties (Static)

    /// Static property to hold the data to be returned in the response.
    static var responseData: Data?

    /// Static property to hold an error to be returned instead of a response.
    static var responseError: Error?

    /// Static property to hold the HTTPURLResponse to be returned. If nil, a default 200 OK response is used.
    static var httpResponse: HTTPURLResponse?

    /// Optional: A closure that can be used for more complex request handling logic.
    /// If set, it overrides the static properties.
    /// It receives the request and should return a tuple containing (Data?, Error?, HTTPURLResponse?).
    static var requestHandler: ((URLRequest) -> (Data?, Error?, HTTPURLResponse?))?

    // MARK: - URLProtocol Overrides

    /// Determines if this protocol can handle the given request. Returns `true` to intercept all requests.
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    /// Returns the canonical version of the request (usually the same request).
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        // If we have a body stream but no body, read the stream into the body
        var modifiedRequest = request
        if request.httpBody == nil, let bodyStream = request.httpBodyStream {
            bodyStream.open()

            // Read the stream into Data
            let bufferSize = 1024
            var buffer = [UInt8](repeating: 0, count: bufferSize)
            var data = Data()

            repeat {
                let result = bodyStream.read(&buffer, maxLength: bufferSize)
                if result < 0 {
                    // Handle error
                    break
                } else if result == 0 {
                    // Reached end of stream
                    break
                } else {
                    data.append(buffer, count: result)
                }
            } while true

            bodyStream.close()

            // Store the read data as httpBody
            modifiedRequest.httpBody = data
        }
        return modifiedRequest
    }

    /// Starts loading the request. This is where the configured response or error is delivered.
    override func startLoading() {
        // Prioritize the requestHandler if it's set
        if let handler = MockURLProtocol.requestHandler {
            let (data, error, response) = handler(request)

            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                let responseToSend = response ?? HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
                client?.urlProtocol(self, didReceive: responseToSend, cacheStoragePolicy: .notAllowed)
                if let data = data {
                    client?.urlProtocol(self, didLoad: data)
                }
                client?.urlProtocolDidFinishLoading(self)
            }
            return
        }

        // Otherwise, use the static properties
        if let error = MockURLProtocol.responseError {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            let response = MockURLProtocol.httpResponse ?? HTTPURLResponse(
                url: request.url!,
                statusCode: 200, // Default to 200 OK if no response specified
                httpVersion: "HTTP/1.1",
                headerFields: nil)!

            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

            if let data = MockURLProtocol.responseData {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    /// Stops loading the request (required override, but typically does nothing for mocks).
    override func stopLoading() {
        // No-op
    }

    // MARK: - Helper Methods (Static)

    /// Resets all static configuration properties to their default state (nil).
    /// Call this in `tearDown` to ensure clean state between tests.
    static func reset() {
        responseData = nil
        responseError = nil
        httpResponse = nil
        requestHandler = nil
    }
}