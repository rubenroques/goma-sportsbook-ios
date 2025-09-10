//
//  JavaScriptBridge.swift
//  BetssonCameroonApp
//
//  Created by Banking Implementation on 10/09/2025.
//

import Foundation
import WebKit

/// Protocol for handling JavaScript messages from the banking WebView
public protocol JavaScriptBridgeDelegate: AnyObject {
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

/// Navigation actions that can be triggered from JavaScript messages
public enum BankingNavigationAction: Equatable {
    case goToSports
    case goToCasino
    case closeModal
    case none
    
    /// Parse navigation action from message content
    /// - Parameter message: JavaScript message string
    /// - Returns: Appropriate navigation action
    static func from(message: String) -> BankingNavigationAction {
        if message.contains("mm-hc-sports") {
            return .goToSports
        } else if message.contains("mm-hc-casino") {
            return .goToCasino
        } else if message.contains("mm-wm-hc-init-deposit") {
            return .closeModal
        } else {
            return .none
        }
    }
}

/// JavaScript bridge for handling WebView communication
public final class JavaScriptBridge: NSObject {
    
    // MARK: - Properties
    
    public weak var delegate: JavaScriptBridgeDelegate?
    
    // MARK: - Constants
    
    private struct MessagePatterns {
        static let redirect = "redirect"
        static let success = "success"
        static let fail = "fail"
        static let cancel = "cancel"
        static let error = "error"
        
        // Navigation patterns from Android implementation
        static let goToSports = "mm-hc-sports"
        static let goToCasino = "mm-hc-casino"
        static let closeDeposit = "mm-wm-hc-init-deposit"
    }
    
    // MARK: - JavaScript Injection
    
    /// Get the JavaScript code to inject into the WebView
    /// - Returns: JavaScript code as string
    public static var injectionScript: String {
        return """
        window.addEventListener('message', function(event) {
            // Extract message data from the event
            let messageData = event.data;
            
            // Convert objects to JSON strings for consistent handling
            if (typeof messageData === 'object') {
                messageData = JSON.stringify(messageData);
            }
            
            // Send to iOS native code if the handler is available
            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.iOS) {
                window.webkit.messageHandlers.iOS.postMessage(messageData);
            }
        });
        
        // Also listen for any custom banking events
        window.addEventListener('bankingEvent', function(event) {
            let eventData = JSON.stringify({
                type: 'bankingEvent',
                data: event.detail
            });
            
            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.iOS) {
                window.webkit.messageHandlers.iOS.postMessage(eventData);
            }
        });
        
        console.log('Banking JavaScript bridge initialized');
        """
    }
    
    // MARK: - Message Processing
    
    /// Process a JavaScript message and determine the appropriate action
    /// - Parameter messageData: Raw message data from JavaScript
    public func processMessage(_ messageData: Any) {
        guard let messageString = convertToString(messageData) else {
            print("[BankingJS] Failed to convert message to string: \(messageData)")
            return
        }
        
        print("[BankingJS] Received message: \(messageString)")
        
        // Check for redirect pattern (main success indicator)
        if messageString.contains(MessagePatterns.redirect) {
            handleRedirectMessage(messageString)
        } 
        // Check for explicit error patterns
        else if messageString.contains(MessagePatterns.error) || messageString.contains(MessagePatterns.fail) {
            delegate?.didReceiveTransactionFailure(message: messageString)
        }
        // Check for cancellation
        else if messageString.contains(MessagePatterns.cancel) {
            delegate?.didReceiveTransactionCancellation(message: messageString)
        }
        // Log other messages for debugging
        else {
            print("[BankingJS] Unhandled message pattern: \(messageString)")
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

extension JavaScriptBridge: WKScriptMessageHandler {
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "iOS" else {
            print("[BankingJS] Unexpected message handler name: \(message.name)")
            return
        }
        
        processMessage(message.body)
    }
}