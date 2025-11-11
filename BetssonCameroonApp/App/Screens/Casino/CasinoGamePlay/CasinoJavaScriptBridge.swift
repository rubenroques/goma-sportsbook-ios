//
//  CasinoJavaScriptBridge.swift
//  BetssonCameroonApp
//
//  Created for handling EveryMatrix casino iframe postMessage communication
//

import Foundation
import WebKit

// MARK: - CasinoJavaScriptBridgeDelegate

/// Delegate protocol for handling casino game JavaScript messages
public protocol CasinoJavaScriptBridgeDelegate: AnyObject {
    /// Called when the casino game is fully loaded and ready to play
    func didReceiveGameReady(message: String)

    /// Called during game loading with progress updates (0-100)
    func didReceiveGameLoadProgress(progress: Int)

    /// Called when the game requests navigation to deposit screen
    func didReceiveNavigateDeposit(message: String)

    /// Called when the game requests navigation to lobby/exit
    func didReceiveNavigateLobby(message: String)

    /// Called when the game encounters an error
    func didReceiveGameError(errorCode: Int, message: String)
}

// MARK: - CasinoJavaScriptBridge

/// Handles JavaScript bridge communication for EveryMatrix casino games
public class CasinoJavaScriptBridge: NSObject {

    // MARK: - Properties

    /// Delegate to receive casino game events
    public weak var delegate: CasinoJavaScriptBridgeDelegate?

    // MARK: - Message Types

    /// EveryMatrix casino game message types
    private enum MessageType {
        static let gameReady = "gameReady"
        static let gameLoadStart = "gameLoadStart"
        static let gameLoadProgress = "gameLoadProgress"
        static let gameLoadCompleted = "gameLoadCompleted"
        static let navigateDeposit = "navigateDeposit"
        static let navigateLobby = "navigateLobby"
        static let error = "error"
    }

    // MARK: - Initialization

    public override init() {
        super.init()
        print("[CasinoJS] Bridge initialized")
    }

    deinit {
        print("[CasinoJS] Bridge deinitialized")
    }

    // MARK: - JavaScript Injection

    /// JavaScript code to inject into the WebView for listening to EveryMatrix postMessage events
    public static var injectionScript: String {
        return """
        (function() {
            console.log('[CasinoJS] Initializing EveryMatrix postMessage bridge...');

            // Listen for postMessage events from EveryMatrix iframe
            window.addEventListener('message', function(event) {
                try {
                    // Extract message data from the event
                    let messageData = event.data;

                    // Log received message for debugging
                    console.log('[CasinoJS] Received postMessage:', messageData);

                    // Validate message structure
                    if (!messageData || typeof messageData !== 'object') {
                        console.log('[CasinoJS] Invalid message format - not an object');
                        return;
                    }

                    // Check if message has required fields
                    if (!messageData.type || !messageData.sender) {
                        console.log('[CasinoJS] Message missing type or sender field');
                        return;
                    }

                    // Only process messages from the game (not from operator)
                    if (messageData.sender !== 'game') {
                        console.log('[CasinoJS] Ignoring message - sender is not "game":', messageData.sender);
                        return;
                    }

                    // Convert to JSON string for native processing
                    const jsonString = JSON.stringify(messageData);
                    console.log('[CasinoJS] Forwarding to native:', jsonString);

                    // Send to iOS native code if handler is available
                    if (window.webkit &&
                        window.webkit.messageHandlers &&
                        window.webkit.messageHandlers.casinoGame) {
                        window.webkit.messageHandlers.casinoGame.postMessage(jsonString);
                        console.log('[CasinoJS] Message sent to native handler');
                    } else {
                        console.warn('[CasinoJS] Native message handler not available');
                    }

                } catch (error) {
                    console.error('[CasinoJS] Error processing message:', error);
                }
            }, false);

            console.log('[CasinoJS] EveryMatrix postMessage bridge ready');
        })();
        """
    }

    // MARK: - Message Processing

    /// Process incoming message from JavaScript
    public func processMessage(_ messageData: Any) {
        // Convert message to string
        guard let messageString = convertToString(messageData) else {
            print("[CasinoJS] Failed to convert message to string: \(messageData)")
            return
        }

        print("[CasinoJS] Processing message: \(messageString)")

        // Parse JSON
        guard let messageDict = parseJSON(messageString) else {
            print("[CasinoJS] Failed to parse JSON from message")
            return
        }

        // Validate sender
        guard let sender = messageDict["sender"] as? String, sender == "game" else {
            print("[CasinoJS] Ignoring message - sender is not 'game'")
            return
        }

        // Get message type
        guard let type = messageDict["type"] as? String else {
            print("[CasinoJS] Message missing 'type' field")
            return
        }

        print("[CasinoJS] Message type: \(type)")

        // Route message by type
        routeMessage(type: type, data: messageDict["data"], fullMessage: messageString)
    }

    // MARK: - Message Routing

    /// Route message to appropriate delegate method based on type
    private func routeMessage(type: String, data: Any?, fullMessage: String) {
        switch type {
        case MessageType.gameReady:
            print("[CasinoJS] Game is ready")
            delegate?.didReceiveGameReady(message: fullMessage)

        case MessageType.gameLoadProgress:
            if let progress = extractProgress(from: data) {
                print("[CasinoJS] Game load progress: \(progress)%")
                delegate?.didReceiveGameLoadProgress(progress: progress)
            }

        case MessageType.gameLoadStart:
            print("[CasinoJS] Game load started")
            delegate?.didReceiveGameLoadProgress(progress: 0)

        case MessageType.gameLoadCompleted:
            print("[CasinoJS] Game load completed")
            delegate?.didReceiveGameLoadProgress(progress: 100)

        case MessageType.navigateDeposit:
            print("[CasinoJS] Navigate to deposit requested")
            delegate?.didReceiveNavigateDeposit(message: fullMessage)

        case MessageType.navigateLobby:
            print("[CasinoJS] Navigate to lobby requested")
            delegate?.didReceiveNavigateLobby(message: fullMessage)

        case MessageType.error:
            let errorCode = extractErrorCode(from: data)
            print("[CasinoJS] Game error: code \(errorCode)")
            delegate?.didReceiveGameError(errorCode: errorCode, message: fullMessage)

        default:
            print("[CasinoJS] Unhandled message type: \(type)")
        }
    }

    // MARK: - Helper Methods

    /// Convert message data to string
    private func convertToString(_ messageData: Any) -> String? {
        if let string = messageData as? String {
            return string
        }

        if let data = messageData as? Data,
           let string = String(data: data, encoding: .utf8) {
            return string
        }

        // Try to convert dictionary to JSON string
        if let dict = messageData as? [String: Any],
           let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }

        return nil
    }

    /// Parse JSON string to dictionary
    private func parseJSON(_ jsonString: String) -> [String: Any]? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }

        do {
            if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return dictionary
            }
        } catch {
            print("[CasinoJS] ❌ JSON parsing error: \(error.localizedDescription)")
        }

        return nil
    }

    /// Extract progress value from message data
    private func extractProgress(from data: Any?) -> Int? {
        // Data can be an integer or a dictionary with progress field
        if let progress = data as? Int {
            return progress
        }

        if let dict = data as? [String: Any],
           let progress = dict["progress"] as? Int {
            return progress
        }

        return nil
    }

    /// Extract error code from message data
    private func extractErrorCode(from data: Any?) -> Int {
        // Data can be an integer or a dictionary with code/errorCode field
        if let errorCode = data as? Int {
            return errorCode
        }

        if let dict = data as? [String: Any] {
            if let code = dict["code"] as? Int {
                return code
            }
            if let errorCode = dict["errorCode"] as? Int {
                return errorCode
            }
        }

        // Default error code if not specified
        return -1
    }
}

// MARK: - WKScriptMessageHandler

extension CasinoJavaScriptBridge: WKScriptMessageHandler {

    /// Handle script message from WebKit
    public func userContentController(_ userContentController: WKUserContentController,
                                     didReceive message: WKScriptMessage) {
        // Validate message handler name
        guard message.name == "casinoGame" else {
            print("[CasinoJS] Unexpected message handler name: \(message.name)")
            return
        }

        print("[CasinoJS] Received message from handler: \(message.name)")

        // Process the message
        processMessage(message.body)
    }
}
