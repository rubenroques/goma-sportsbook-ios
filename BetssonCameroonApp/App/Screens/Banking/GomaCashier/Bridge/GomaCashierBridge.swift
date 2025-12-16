//
//  GomaCashierBridge.swift
//  BetssonCameroonApp
//
//  Created by Goma Cashier Implementation on 10/12/2025.
//

import Foundation
import WebKit
import GomaLogger

/// Protocol for handling JavaScript messages from the Goma cashier WebView
protocol GomaCashierBridgeDelegate: AnyObject {
    /// Called when a transaction success is detected
    /// - Parameters:
    ///   - message: The complete message data
    ///   - navigationAction: The specific navigation action to perform
    func didReceiveTransactionSuccess(message: String, navigationAction: BankingNavigationAction)

    /// Called when a transaction failure is detected
    /// - Parameter message: The complete message data with error information
    func didReceiveTransactionFailure(message: String)

    /// Called when transaction is cancelled by user
    /// - Parameter message: The complete message data
    func didReceiveTransactionCancellation(message: String)
}

/// JavaScript bridge for handling Goma cashier WebView communication
/// Uses "cashierHandler" as the message handler name
final class GomaCashierBridge: NSObject {

    // MARK: - Properties

    private let logPrefix = "[GomaCashier][Bridge]"
    weak var delegate: GomaCashierBridgeDelegate?

    /// The handler name registered with WKWebView - must match what the Goma cashier page expects
    static let handlerName = "cashierHandler"

    // MARK: - Constants

    private struct MessagePatterns {
        static let redirect = "redirect"
        static let success = "success"
        static let fail = "fail"
        static let cancel = "cancel"
        static let error = "error"

        // Navigation patterns
        static let goToSports = "mm-hc-sports"
        static let goToCasino = "mm-hc-casino"
        static let closeDeposit = "mm-wm-hc-init-deposit"
    }

    // MARK: - JavaScript Injection

    /// Get the JavaScript code to inject into the WebView
    /// The Goma cashier page already forwards postMessage events to native handlers,
    /// but we include this script as a fallback for consistency
    static var injectionScript: String {
        return """
        // Goma Cashier Bridge - forwards postMessage events to iOS native code
        window.addEventListener('message', function(event) {
            let messageData = event.data;

            // Convert objects to JSON strings for consistent handling
            if (typeof messageData === 'object') {
                messageData = JSON.stringify(messageData);
            }

            // Send to iOS native code via the cashierHandler
            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.cashierHandler) {
                window.webkit.messageHandlers.cashierHandler.postMessage(messageData);
            }
        });

        // Listen for custom cashier events
        window.addEventListener('cashierEvent', function(event) {
            let eventData = JSON.stringify({
                type: 'cashierEvent',
                data: event.detail
            });

            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.cashierHandler) {
                window.webkit.messageHandlers.cashierHandler.postMessage(eventData);
            }
        });

        console.log('Goma Cashier JavaScript bridge initialized');
        """
    }

    // MARK: - Message Processing

    /// Process a JavaScript message and determine the appropriate action
    /// - Parameter messageData: Raw message data from JavaScript
    func processMessage(_ messageData: Any) {
        guard let messageString = convertToString(messageData) else {
            GomaLogger.error("\(logPrefix) Failed to convert message to string: \(messageData)")
            return
        }

        GomaLogger.debug("\(logPrefix) Received message: \(messageString)")

        // Check for redirect pattern (main success indicator)
        if messageString.contains(MessagePatterns.redirect) {
            GomaLogger.info("\(logPrefix) Transaction redirect detected")
            handleRedirectMessage(messageString)
        }
        // Check for explicit success
        else if messageString.contains(MessagePatterns.success) {
            GomaLogger.info("\(logPrefix) Transaction success detected")
            handleRedirectMessage(messageString)
        }
        // Check for explicit error patterns
        else if messageString.contains(MessagePatterns.error) || messageString.contains(MessagePatterns.fail) {
            GomaLogger.error("\(logPrefix) Transaction failure detected: \(messageString)")
            delegate?.didReceiveTransactionFailure(message: messageString)
        }
        // Check for cancellation
        else if messageString.contains(MessagePatterns.cancel) {
            GomaLogger.info("\(logPrefix) Transaction cancellation detected")
            delegate?.didReceiveTransactionCancellation(message: messageString)
        }
        // Log other messages for debugging
        else {
            GomaLogger.debug("\(logPrefix) Unhandled message pattern: \(messageString)")
        }
    }

    // MARK: - Private Methods

    private func handleRedirectMessage(_ message: String) {
        let navigationAction = BankingNavigationAction.from(message: message)
        delegate?.didReceiveTransactionSuccess(message: message, navigationAction: navigationAction)
    }

    private func convertToString(_ data: Any) -> String? {
        if let string = data as? String {
            return string
        } else if let dict = data as? [String: Any] {
            return try? String(data: JSONSerialization.data(withJSONObject: dict), encoding: .utf8)
        } else if let array = data as? [Any] {
            return try? String(data: JSONSerialization.data(withJSONObject: array), encoding: .utf8)
        } else {
            return String(describing: data)
        }
    }
}

// MARK: - WKScriptMessageHandler

extension GomaCashierBridge: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == Self.handlerName else {
            GomaLogger.debug("\(logPrefix) Unexpected message handler name: \(message.name)")
            return
        }

        processMessage(message.body)
    }
}
