//
//  GomaCashierWebViewConfiguration.swift
//  BetssonCameroonApp
//
//  Created by Goma Cashier Implementation on 10/12/2025.
//

import Foundation
import WebKit

/// Configuration helper for Goma cashier WebView setup
struct GomaCashierWebViewConfiguration {

    // MARK: - WebView Configuration

    /// Create a configured WKWebViewConfiguration for Goma cashier operations
    /// - Parameter bridge: The Goma cashier JavaScript bridge handler
    /// - Returns: Configured WKWebViewConfiguration
    static func forGomaCashier(with bridge: GomaCashierBridge) -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()

        // Enable JavaScript
        configuration.preferences.javaScriptEnabled = true

        // Allow JavaScript to open windows without user interaction
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

        // Add JavaScript bridge
        let userScript = WKUserScript(
            source: GomaCashierBridge.injectionScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )

        configuration.userContentController.addUserScript(userScript)
        configuration.userContentController.add(bridge, name: GomaCashierBridge.handlerName)

        // Configure for mobile
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        // Set user agent for mobile identification
        configuration.applicationNameForUserAgent = "BetssonCameroonApp/1.0 Mobile"

        return configuration
    }

    // MARK: - WebView Appearance

    /// Configure WebView appearance and behavior
    /// Reuses the same appearance settings as the EM cashier for consistency
    /// - Parameter webView: WKWebView to configure
    static func configureAppearance(for webView: WKWebView) {
        // Delegate to existing WebViewConfiguration for consistency
        WebViewConfiguration.configureAppearance(for: webView)
    }

    // MARK: - Security Headers

    /// Get security headers for cashier requests
    /// Reuses the same security headers as the EM cashier
    /// - Returns: Dictionary of security headers
    static func securityHeaders() -> [String: String] {
        return WebViewConfiguration.securityHeaders()
    }
}
