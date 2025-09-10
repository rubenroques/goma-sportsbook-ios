
import Foundation
import WebKit

/// Configuration helper for banking WebView setup
public struct WebViewConfiguration {
    
    // MARK: - WebView Configuration
    
    /// Create a configured WKWebViewConfiguration for banking operations
    /// - Parameter javaScriptBridge: The JavaScript bridge handler
    /// - Returns: Configured WKWebViewConfiguration
    public static func forBanking(with javaScriptBridge: JavaScriptBridge) -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        
        // Enable JavaScript
        configuration.preferences.javaScriptEnabled = true
        
        // Allow JavaScript to open windows without user interaction
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        // Add JavaScript bridge
        let userScript = WKUserScript(
            source: JavaScriptBridge.injectionScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        
        configuration.userContentController.addUserScript(userScript)
        configuration.userContentController.add(javaScriptBridge, name: "iOS")
        
        // Configure for mobile banking
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // Set user agent for mobile identification
        configuration.applicationNameForUserAgent = "BetssonCameroonApp/1.0 Mobile"
        
        return configuration
    }
    
    // MARK: - WebView Appearance
    
    /// Configure WebView appearance and behavior
    /// - Parameter webView: WKWebView to configure
    public static func configureAppearance(for webView: WKWebView) {
        // Enable transparent background
        webView.backgroundColor = .clear
        webView.isOpaque = false
        
        // Configure scrolling behavior
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.showsVerticalScrollIndicator = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        // Disable zoom
        webView.scrollView.bouncesZoom = false
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.minimumZoomScale = 1.0
        
        // Configure content insets
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        // Improve rendering performance
        webView.configuration.suppressesIncrementalRendering = false
    }
 
    // MARK: - Security Headers
    
    /// Get security headers for banking requests
    /// - Returns: Dictionary of security headers
    public static func securityHeaders() -> [String: String] {
        return [
            "X-Frame-Options": "SAMEORIGIN",
            "X-Content-Type-Options": "nosniff",
            "X-XSS-Protection": "1; mode=block",
            "Referrer-Policy": "strict-origin-when-cross-origin"
        ]
    }
}
