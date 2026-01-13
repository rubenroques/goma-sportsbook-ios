//
//  SSEEventHandlerAdapter.swift
//  ServicesProvider
//
//  Created on 15/01/2025.
//

import Foundation
import Combine
import LDSwiftEventSource
import GomaLogger

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
        GomaLogger.debug(.realtime, category: "SSE", "✅ SSEEventHandlerAdapter: Connection opened")
        subject.send(.connected)
    }

    func onClosed() {
        GomaLogger.debug(.realtime, category: "SSE", "🔌 SSEEventHandlerAdapter: Connection closed")
        GomaLogger.debug(.realtime, category: "SSE", "   - LDSwiftEventSource will auto-reconnect (NOT terminating publisher)")
        subject.send(.disconnected)
        // DO NOT send completion here - let LDSwiftEventSource handle reconnection!
        // Only send completion when stop() is explicitly called or on error
    }

    func onMessage(eventType: String, messageEvent: MessageEvent) {
        GomaLogger.debug(.realtime, category: "SSE", "📨 SSEEventHandlerAdapter: Received event (type: \(eventType))")

        // Emit MessageEvent wrapped in SSEStreamEvent
        subject.send(.message(messageEvent))
    }

    func onComment(comment: String) {
        GomaLogger.debug(.realtime, category: "SSE", "💬 SSEEventHandlerAdapter: Comment received: \(comment)")
        // Comments are ignored for now
    }

    func onError(error: Error) {
        GomaLogger.error(.realtime, category: "SSE", "❌ SSEEventHandlerAdapter: Error - \(error.localizedDescription)")

        // Check if this is an authentication/authorization error (401/403)
        // These errors should TERMINATE the stream, not trigger reconnection
        // LDSwiftEventSource wraps HTTP errors in UnsuccessfulResponseError
        if let unsuccessfulError = error as? UnsuccessfulResponseError {
            let responseCode = unsuccessfulError.responseCode
            GomaLogger.error(.realtime, category: "SSE", "❌ SSEEventHandlerAdapter: HTTP error code: \(responseCode)")

            if responseCode == 401 || responseCode == 403 {
                GomaLogger.error(.realtime, category: "SSE", "🛑 SSEEventHandlerAdapter: Auth error (\(responseCode)) - TERMINATING stream (no reconnection)")

                // Stop the EventSource to prevent LDSwiftEventSource auto-reconnection
                eventSource?.stop()
                eventSource = nil

                // Send failure completion to terminate the publisher
                let serviceError = ServiceProviderError.errorMessage(
                    message: "SSE authentication failed (HTTP \(responseCode))"
                )
                subject.send(completion: .failure(serviceError))
                return
            }
        }

        // Network errors (timeout, connection failure) should trigger reconnection, not terminate stream
        // Send .disconnected event to let UserInfoStreamManager handle reconnection logic
        // DO NOT send completion here - only stop() should terminate the publisher

        GomaLogger.debug(.realtime, category: "SSE", "🔌 SSEEventHandlerAdapter: Error treated as disconnection - will trigger reconnection")
        subject.send(.disconnected)

        // Note: Completion is ONLY sent when stop() is explicitly called
        // This allows reconnection logic to handle transient errors (timeouts, network failures)
    }

    // MARK: - Lifecycle Management

    func setEventSource(_ eventSource: EventSource) {
        self.eventSource = eventSource
    }

    func stop() {
        GomaLogger.debug(.realtime, category: "SSE", "🛑 SSEEventHandlerAdapter: Stopping event source")
        GomaLogger.debug(.realtime, category: "SSE", "   - Explicitly stopping SSE stream (will send completion)")

        // Stop the underlying EventSource to prevent auto-reconnection
        eventSource?.stop()
        GomaLogger.debug(.realtime, category: "SSE", "🔌 SSEEventHandlerAdapter: EventSource stopped - auto-reconnection prevented")
        eventSource = nil

        // Only send completion when explicitly stopped (not on auto-reconnect)
        subject.send(completion: .finished)
        GomaLogger.debug(.realtime, category: "SSE", "✅ SSEEventHandlerAdapter: Publisher terminated - no auto-reconnection will occur")
    }
}
