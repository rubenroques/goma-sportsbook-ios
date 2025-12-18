//
//  WidgetCashierBridge.swift
//  BetssonCameroonApp
//
//  Created by Widget Cashier Implementation on 10/12/2025.
//

import Foundation
import WebKit
import GomaLogger

/// Protocol for handling JavaScript messages from the Widget Cashier WebView
protocol WidgetCashierBridgeDelegate: AnyObject {
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

/// JavaScript bridge for handling Widget Cashier WebView communication
/// Uses "cashierHandler" as the message handler name
final class WidgetCashierBridge: NSObject {

    // MARK: - Properties

    private let logCategory = "WidgetCashier"
    weak var delegate: WidgetCashierBridgeDelegate?

    /// The handler name registered with WKWebView - must match what the cashier page expects
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
    /// The cashier page already forwards postMessage events to native handlers,
    /// but we include this script as a fallback for consistency
    static var injectionScript: String {
        return """
        // Widget Cashier Bridge - forwards postMessage events to iOS native code
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

        console.log('Widget Cashier JavaScript bridge initialized');
        """
    }

    // MARK: - Message Processing

    /// Process a JavaScript message and determine the appropriate action
    /// - Parameter messageData: Raw message data from JavaScript
    func processMessage(_ messageData: Any) {
        guard let messageString = convertToString(messageData) else {
            GomaLogger.error(.payments, category: logCategory, "Failed to convert message to string: \(messageData)")
            return
        }

        GomaLogger.debug(.payments, category: logCategory, "Received message: \(messageString)")

        // Try to parse as JSON to check message type
        if let jsonDict = parseJSON(messageString) {
            if handleTypedMessage(jsonDict, rawMessage: messageString) {
                return
            }
        }

        // Fallback to string pattern matching for non-JSON or unhandled types
        handleStringPatternMessage(messageString)
    }

    /// Handle typed JSON messages from the cashier
    /// - Returns: true if message was handled, false otherwise
    private func handleTypedMessage(_ json: [String: Any], rawMessage: String) -> Bool {
        guard let messageType = json["type"] as? String else {
            return false
        }

        switch messageType {
        case "ErrorResponseCode":
            // Only treat as error if errorResponseCode is non-empty
            if let errorCode = json["errorResponseCode"] as? String, !errorCode.isEmpty {
                GomaLogger.error(.payments, category: logCategory, "Transaction error: \(errorCode)")
                delegate?.didReceiveTransactionFailure(message: rawMessage)
                return true
            }
            // Empty errorResponseCode is just a status message, ignore it
            GomaLogger.debug(.payments, category: logCategory, "ErrorResponseCode with empty code (status message)")
            return true

        case "TransactionComplete", "TransactionSuccess":
            GomaLogger.info(.payments, category: logCategory, "Transaction success: \(messageType)")
            handleRedirectMessage(rawMessage)
            return true

        case "TransactionFailed", "TransactionError":
            GomaLogger.error(.payments, category: logCategory, "Transaction failed: \(messageType)")
            delegate?.didReceiveTransactionFailure(message: rawMessage)
            return true

        case "TransactionCancelled":
            GomaLogger.info(.payments, category: logCategory, "Transaction cancelled")
            delegate?.didReceiveTransactionCancellation(message: rawMessage)
            return true

        case "DataLoading", "CashierMethodsListReady", "PrecisionCurrenciesMap",
             "PromotedPaymentMethods", "StartSessionCountdown", "SelectPayMeth":
            // Status/info messages - log but don't take action
            GomaLogger.debug(.payments, category: logCategory, "Status message: \(messageType)")
            return true

        default:
            // Unknown type - fall through to string pattern matching
            return false
        }
    }

    /// Handle messages using string pattern matching (legacy/fallback)
    private func handleStringPatternMessage(_ messageString: String) {
        // Check for redirect pattern (main success indicator)
        if messageString.contains(MessagePatterns.redirect) {
            GomaLogger.info(.payments, category: logCategory, "Transaction redirect detected")
            handleRedirectMessage(messageString)
        }
        // Check for explicit success
        else if messageString.contains(MessagePatterns.success) {
            GomaLogger.info(.payments, category: logCategory, "Transaction success detected")
            handleRedirectMessage(messageString)
        }
        // Check for explicit fail (not "error" to avoid false positives like "ErrorResponseCode")
        else if messageString.contains(MessagePatterns.fail) {
            GomaLogger.error(.payments, category: logCategory, "Transaction failure detected: \(messageString)")
            delegate?.didReceiveTransactionFailure(message: messageString)
        }
        // Check for cancellation
        else if messageString.contains(MessagePatterns.cancel) {
            GomaLogger.info(.payments, category: logCategory, "Transaction cancellation detected")
            delegate?.didReceiveTransactionCancellation(message: messageString)
        }
        // Log other messages for debugging
        else {
            GomaLogger.debug(.payments, category: logCategory, "Unhandled message: \(messageString)")
        }
    }

    private func parseJSON(_ string: String) -> [String: Any]? {
        guard let data = string.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
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

extension WidgetCashierBridge: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == Self.handlerName else {
            GomaLogger.debug(.payments, category: logCategory, "Unexpected message handler name: \(message.name)")
            return
        }

        processMessage(message.body)
    }
}
