//
//  CashierFrameState.swift
//  BetssonCameroonApp
//
//  Created by Banking Implementation on 11/09/2025.
//

import Foundation

/// Simple state enum for cashier WebView operations
enum CashierFrameState: Equatable {
    /// Initial state - nothing happening
    case idle
    
    /// Fetching cashier URL from API
    case loadingURL
    
    /// WebView is loading the received URL
    case loadingWebView(URL)
    
    /// WebView fully loaded and ready for interaction
    case ready(URL)
    
    /// Error occurred during URL fetch or WebView loading
    case error(String)
}

// MARK: - Convenience Properties

extension CashierFrameState {
    
    /// Whether the state indicates any kind of loading
    var isLoading: Bool {
        switch self {
        case .loadingURL, .loadingWebView:
            return true
        case .idle, .ready, .error:
            return false
        }
    }
    
    /// Whether the WebView should be visible
    var shouldShowWebView: Bool {
        switch self {
        case .ready:
            return true
        case .idle, .loadingURL, .loadingWebView, .error:
            return false
        }
    }
    
    /// The current URL if available
    var currentURL: URL? {
        switch self {
        case .loadingWebView(let url), .ready(let url):
            return url
        case .idle, .loadingURL, .error:
            return nil
        }
    }
}