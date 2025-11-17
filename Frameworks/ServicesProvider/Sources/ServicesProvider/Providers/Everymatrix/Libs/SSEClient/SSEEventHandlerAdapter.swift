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
        print("[SSEDebug] ✅ SSEEventHandlerAdapter: Connection opened")
        subject.send(.connected)
    }

    func onClosed() {
        print("[SSEDebug] 🔌 SSEEventHandlerAdapter: Connection closed")
        print("[SSEDebug]    - LDSwiftEventSource will auto-reconnect (NOT terminating publisher)")
        subject.send(.disconnected)
        // DO NOT send completion here - let LDSwiftEventSource handle reconnection!
        // Only send completion when stop() is explicitly called or on error
    }

    func onMessage(eventType: String, messageEvent: MessageEvent) {
        print("[SSEDebug] 📨 SSEEventHandlerAdapter: Received event (type: \(eventType))")

        // Emit MessageEvent wrapped in SSEStreamEvent
        subject.send(.message(messageEvent))
    }

    func onComment(comment: String) {
        print("[SSEDebug] 💬 SSEEventHandlerAdapter: Comment received: \(comment)")
        // Comments are ignored for now
    }

    func onError(error: Error) {
        print("[SSEDebug] ❌ SSEEventHandlerAdapter: Error - \(error.localizedDescription)")

        // Network errors (timeout, connection failure) should trigger reconnection, not terminate stream
        // Send .disconnected event to let UserInfoStreamManager handle reconnection logic
        // DO NOT send completion here - only stop() should terminate the publisher

        print("[SSEDebug] 🔌 SSEEventHandlerAdapter: Error treated as disconnection - will trigger reconnection")
        subject.send(.disconnected)

        // Note: Completion is ONLY sent when stop() is explicitly called
        // This allows reconnection logic to handle transient errors (timeouts, network failures)
    }

    // MARK: - Lifecycle Management

    func setEventSource(_ eventSource: EventSource) {
        self.eventSource = eventSource
    }

    func stop() {
        print("[SSEDebug] 🛑 SSEEventHandlerAdapter: Stopping event source")
        print("[SSEDebug]    - Explicitly stopping SSE stream (will send completion)")

        // Stop the underlying EventSource to prevent auto-reconnection
        eventSource?.stop()
        print("[SSEDebug] 🔌 SSEEventHandlerAdapter: EventSource stopped - auto-reconnection prevented")
        eventSource = nil

        // Only send completion when explicitly stopped (not on auto-reconnect)
        subject.send(completion: .finished)
        print("[SSEDebug] ✅ SSEEventHandlerAdapter: Publisher terminated - no auto-reconnection will occur")
    }
}
