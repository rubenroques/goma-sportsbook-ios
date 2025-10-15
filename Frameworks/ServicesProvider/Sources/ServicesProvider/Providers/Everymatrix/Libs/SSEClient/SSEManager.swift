//
//  SSEManager.swift
//  ServicesProvider
//
//  Created on 15/10/2025.
//

import Foundation
import Combine
import DictionaryCoding

/// Server-Sent Events (SSE) manager for real-time streaming
/// Parses SSE format: id, event, data fields
final class SSEManager {

    private var dataTask: URLSessionDataTask?
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
        self.decoder.dateDecodingStrategy = .iso8601
    }

    deinit {
        disconnect()
    }

    /// Subscribe to SSE stream and decode JSON messages
    ///
    /// - Parameters:
    ///   - url: SSE endpoint URL
    ///   - headers: HTTP headers (must include "Accept: text/event-stream")
    ///   - decodingType: Type to decode from JSON data field
    ///   - timeout: Maximum time to wait for events (default: 5 seconds)
    /// - Returns: Publisher emitting SSE events
    func subscribe<T: Decodable>(
        url: URL,
        headers: [String: String],
        decodingType: T.Type,
        timeout: TimeInterval = 5.0
    ) -> AnyPublisher<SSEEvent<T>, EveryMatrix.APIError> {

        let subject = PassthroughSubject<SSEEvent<T>, EveryMatrix.APIError>()

        // Create request
        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = "GET"

        // Set headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Ensure SSE accept header
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")

        print("📡 SSEManager: Connecting to \(url.absoluteString)")

        // Buffer for incomplete lines
        var buffer = ""

        // Track timeout
        let startTime = Date()

        // Create data task
        dataTask = session.dataTask(with: request) { [weak self] data, response, error in

            if let error = error {
                print("❌ SSEManager: Connection error - \(error.localizedDescription)")
                subject.send(completion: .failure(.requestError(value: error.localizedDescription)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ SSEManager: Invalid response type")
                subject.send(completion: .failure(.requestError(value: "Invalid response")))
                return
            }

            print("📡 SSEManager: HTTP Status \(httpResponse.statusCode)")

            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = "HTTP \(httpResponse.statusCode)"
                print("❌ SSEManager: \(errorMessage)")
                subject.send(completion: .failure(.requestError(value: errorMessage)))
                return
            }

            // Check timeout
            if Date().timeIntervalSince(startTime) > timeout {
                print("⏱️ SSEManager: Timeout reached, closing connection")
                self?.disconnect()
                subject.send(.disconnected)
                subject.send(completion: .finished)
                return
            }

            guard let data = data else {
                print("✅ SSEManager: Stream ended")
                subject.send(.disconnected)
                subject.send(completion: .finished)
                return
            }

            // Parse SSE data
            guard let chunk = String(data: data, encoding: .utf8) else {
                print("⚠️ SSEManager: Failed to decode chunk as UTF-8")
                return
            }

            buffer += chunk
            self?.parseSSEBuffer(&buffer, subject: subject, decoder: self?.decoder ?? JSONDecoder())
        }

        // Use delegate-based streaming for better real-time performance
        let streamingTask = session.dataTask(with: request)

        // Override with streaming session
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout

        let streamingSession = URLSession(configuration: configuration,
                                         delegate: SSEStreamDelegate(
                                            subject: subject,
                                            decoder: decoder,
                                            timeout: timeout
                                         ),
                                         delegateQueue: nil)

        dataTask = streamingSession.dataTask(with: request)
        dataTask?.resume()

        print("🚀 SSEManager: Connection started")
        subject.send(.connected)

        return subject
            .handleEvents(
                receiveCancel: { [weak self] in
                    print("🛑 SSEManager: Subscription cancelled")
                    self?.disconnect()
                }
            )
            .eraseToAnyPublisher()
    }

    /// Parse SSE buffer and extract events
    private func parseSSEBuffer<T: Decodable>(
        _ buffer: inout String,
        subject: PassthroughSubject<SSEEvent<T>, EveryMatrix.APIError>,
        decoder: JSONDecoder
    ) {
        // Split by double newline (event separator)
        let events = buffer.components(separatedBy: "\n\n")

        // Keep last incomplete event in buffer
        if events.count > 1 {
            buffer = events.last ?? ""

            // Process complete events
            for eventText in events.dropLast() {
                parseSSEEvent(eventText, subject: subject, decoder: decoder)
            }
        }
    }

    /// Parse single SSE event
    private func parseSSEEvent<T: Decodable>(
        _ eventText: String,
        subject: PassthroughSubject<SSEEvent<T>, EveryMatrix.APIError>,
        decoder: JSONDecoder
    ) {
        var eventId: String?
        var eventType: String?
        var eventData: String?

        // Parse SSE fields
        for line in eventText.components(separatedBy: "\n") {
            if line.hasPrefix("id:") {
                eventId = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
            } else if line.hasPrefix("event:") {
                eventType = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)
            } else if line.hasPrefix("data:") {
                eventData = String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)
            }
        }

        guard let data = eventData, !data.isEmpty else {
            print("⚠️ SSEManager: Empty data field, skipping")
            return
        }

        print("📨 SSEManager: Received event (id: \(eventId ?? "none"), type: \(eventType ?? "none"))")

        // Decode JSON from data field
        guard let jsonData = data.data(using: .utf8) else {
            print("❌ SSEManager: Failed to convert data to UTF-8")
            return
        }

        do {
            let decoded = try decoder.decode(T.self, from: jsonData)
            print("✅ SSEManager: Successfully decoded message")
            subject.send(.message(decoded))
        } catch {
            print("❌ SSEManager: JSON decoding error - \(error)")
            subject.send(completion: .failure(.decodingError(value: error.localizedDescription)))
        }
    }

    /// Disconnect from SSE stream
    func disconnect() {
        print("🔌 SSEManager: Disconnecting")
        dataTask?.cancel()
        dataTask = nil
    }
}

// MARK: - SSE Event Type

/// Server-Sent Event with decoded payload
enum SSEEvent<T> {
    /// Connection established
    case connected

    /// Message received with decoded payload
    case message(T)

    /// Connection closed
    case disconnected
}

// MARK: - URLSession Delegate for Streaming

private class SSEStreamDelegate<T: Decodable>: NSObject, URLSessionDataDelegate {

    let subject: PassthroughSubject<SSEEvent<T>, EveryMatrix.APIError>
    let decoder: JSONDecoder
    let timeout: TimeInterval
    let startTime: Date
    var buffer: String = ""

    init(subject: PassthroughSubject<SSEEvent<T>, EveryMatrix.APIError>, decoder: JSONDecoder, timeout: TimeInterval) {
        self.subject = subject
        self.decoder = decoder
        self.timeout = timeout
        self.startTime = Date()
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        // Check timeout
        if Date().timeIntervalSince(startTime) > timeout {
            print("⏱️ SSEManager: Timeout reached during streaming")
            dataTask.cancel()
            subject.send(.disconnected)
            subject.send(completion: .finished)
            return
        }

        guard let chunk = String(data: data, encoding: .utf8) else {
            print("⚠️ SSEManager: Failed to decode streaming chunk")
            return
        }

        buffer += chunk
        parseBuffer()
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("❌ SSEManager: Stream ended with error - \(error.localizedDescription)")
            subject.send(completion: .failure(.requestError(value: error.localizedDescription)))
        } else {
            print("✅ SSEManager: Stream completed successfully")
            subject.send(.disconnected)
            subject.send(completion: .finished)
        }
    }

    private func parseBuffer() {
        let events = buffer.components(separatedBy: "\n\n")

        if events.count > 1 {
            buffer = events.last ?? ""

            for eventText in events.dropLast() {
                parseEvent(eventText)
            }
        }
    }

    private func parseEvent(_ eventText: String) {
        var eventData: String?

        for line in eventText.components(separatedBy: "\n") {
            if line.hasPrefix("data:") {
                eventData = String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)
            }
        }

        guard let data = eventData,
              !data.isEmpty,
              let jsonData = data.data(using: .utf8) else {
            return
        }

        do {
            let decoded = try decoder.decode(T.self, from: jsonData)
            subject.send(.message(decoded))
        } catch {
            print("❌ SSEManager: Decoding error - \(error)")
            subject.send(completion: .failure(.decodingError(value: error.localizedDescription)))
        }
    }
}
