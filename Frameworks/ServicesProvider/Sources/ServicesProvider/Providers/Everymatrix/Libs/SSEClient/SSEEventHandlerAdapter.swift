//
//  SSEEventHandlerAdapter.swift
//  ServicesProvider
//
//  Created on 15/01/2025.
//

import Foundation
import Combine
import LDSwiftEventSource

/// SSE stream event wrapper for connection lifecycle
enum SSEStreamEvent {
    case connected
    case message(MessageEvent)
    case disconnected
}

/// Reusable adapter that bridges LDSwiftEventSource EventHandler callbacks to Combine publishers
/// Generic over any Decodable type for flexibility across SSE endpoints (Cashout, Wallet, User Session, etc.)
final class SSEEventHandlerAdapter<T: Decodable>: EventHandler {

    // MARK: - Properties

    /// Subject for emitting SSE events as Combine publisher
    let subject: PassthroughSubject<SSEStreamEvent, ServiceProviderError>

    /// JSON decoder for parsing SSE message data
    private let decoder: JSONDecoder

    /// Strong reference to EventSource to prevent deallocation
    private var eventSource: EventSource?

    // MARK: - Initialization

    init(decoder: JSONDecoder = JSONDecoder()) {
        self.subject = PassthroughSubject<SSEStreamEvent, ServiceProviderError>()
        self.decoder = decoder
        self.decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - EventHandler Protocol

    func onOpened() {
        print("✅ SSEEventHandlerAdapter: Connection opened")
        subject.send(.connected)
    }

    func onClosed() {
        print("🔌 SSEEventHandlerAdapter: Connection closed")
        subject.send(.disconnected)
        subject.send(completion: .finished)
    }

    func onMessage(eventType: String, messageEvent: MessageEvent) {
        print("📨 SSEEventHandlerAdapter: Received event (type: \(eventType))")

        // Emit MessageEvent wrapped in SSEStreamEvent
        subject.send(.message(messageEvent))
    }

    func onComment(comment: String) {
        print("💬 SSEEventHandlerAdapter: Comment received: \(comment)")
        // Comments are ignored for now
    }

    func onError(error: Error) {
        print("❌ SSEEventHandlerAdapter: Error - \(error.localizedDescription)")

        // Map LDSwiftEventSource errors to ServiceProviderError
        let serviceError: ServiceProviderError

        if let unsuccessfulResponse = error as? UnsuccessfulResponseError {
            serviceError = .errorMessage(message: "HTTP \(unsuccessfulResponse.responseCode)")
        } else {
            serviceError = .errorMessage(message: error.localizedDescription)
        }

        subject.send(completion: .failure(serviceError))
    }

    // MARK: - Lifecycle Management

    func setEventSource(_ eventSource: EventSource) {
        self.eventSource = eventSource
    }

    func stop() {
        print("🛑 SSEEventHandlerAdapter: Stopping event source")
        eventSource?.stop()
        eventSource = nil
    }
}
