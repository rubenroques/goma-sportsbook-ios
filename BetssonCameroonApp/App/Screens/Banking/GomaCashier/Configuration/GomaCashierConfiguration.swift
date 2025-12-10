//
//  GomaCashierConfiguration.swift
//  BetssonCameroonApp
//
//  Created by Goma Cashier Implementation on 10/12/2025.
//

import UIKit

/// Configuration for Goma-hosted cashier URL construction
/// Builds cashier URLs client-side with environment-aware base URLs
struct GomaCashierConfiguration {

    // MARK: - Transaction Type

    enum TransactionType: String {
        case deposit = "Deposit"
        case withdraw = "Withdraw"
    }

    // MARK: - Environment URLs

    /// Base URL for the cashier page (environment-specific)
    static var baseURL: String {
        switch TargetVariables.BuildEnvironment.current {
        case .staging:
            return "https://sportsbook-stage.gomagaming.com"
        case .uat, .production:
            return "https://www.betssonem.com"
        }
    }

    /// API endpoint for the cashier to use (environment-specific)
    static var apiEndpoint: String {
        switch TargetVariables.BuildEnvironment.current {
        case .staging:
            return "https://betsson-api.stage.norway.everymatrix.com"
        case .uat, .production:
            return "https://betsson.nwacdn.com"
        }
    }

    // MARK: - URL Construction

    /// Build the complete cashier URL with all required parameters
    /// - Parameters:
    ///   - transactionType: Deposit or Withdraw
    ///   - sessionId: User's session key from UserProfile
    ///   - userId: User's identifier from UserProfile
    ///   - currency: Currency code (e.g., "XAF")
    ///   - language: Language code (e.g., "fr", "en")
    ///   - theme: Theme string ("dark" or "light")
    /// - Returns: Constructed URL or nil if construction fails
    static func buildCashierURL(
        transactionType: TransactionType,
        sessionId: String,
        userId: String,
        currency: String,
        language: String,
        theme: String
    ) -> URL? {
        let urlString = "\(baseURL)/cashier-page/index.html"

        guard var components = URLComponents(string: urlString) else {
            return nil
        }

        // Build query parameters
        // URLComponents automatically URL-encodes the values
        components.queryItems = [
            // Required parameters
            URLQueryItem(name: "sessionId", value: sessionId),
            URLQueryItem(name: "userId", value: userId),
            URLQueryItem(name: "endpoint", value: apiEndpoint),
            URLQueryItem(name: "currency", value: currency),
            // Optional parameters with defaults
            URLQueryItem(name: "lang", value: language.lowercased()),
            URLQueryItem(name: "theme", value: theme),
            URLQueryItem(name: "type", value: transactionType.rawValue),
            URLQueryItem(name: "showheader", value: "false"),
            URLQueryItem(name: "numberofmethodsshown", value: "3")
        ]

        return components.url
    }

    // MARK: - Theme Helper

    /// Get the current theme as a string for the cashier URL
    /// - Returns: "dark" or "light" based on current interface style
    static func getCurrentThemeString() -> String {
        switch UIScreen.main.traitCollection.userInterfaceStyle {
        case .dark:
            return "dark"
        case .light:
            return "light"
        case .unspecified:
            return "dark"
        @unknown default:
            return "dark"
        }
    }
}
