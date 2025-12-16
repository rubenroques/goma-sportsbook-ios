//
//  GomaCashierDepositViewModel.swift
//  BetssonCameroonApp
//
//  Created by Goma Cashier Implementation on 10/12/2025.
//

import Foundation
import Combine
import GomaLogger


/// ViewModel for Goma cashier deposit operations
/// Builds cashier URL client-side without API call
final class GomaCashierDepositViewModel: ObservableObject {

    private let logPrefix = "[GomaCashier][Deposit]"

    // MARK: - Published Properties

    /// Current state of the cashier frame
    @Published private(set) var state: CashierFrameState = .idle

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Public Methods

    /// Load deposit cashier by building URL directly (no API call)
    func loadDeposit() {
        // Get user session data
        guard let userProfile = Env.userSessionStore.loggedUserProfile else {
            state = .error(localized("error_user_not_logged_in"))
            return
        }

        guard let sessionKey = Optional(userProfile.sessionKey), !sessionKey.isEmpty else {
            state = .error(localized("error_session_expired"))
            return
        }

        let userId = userProfile.userIdentifier
        let currency = userProfile.currency ?? "XAF"
        let language = LanguageManager.shared.currentLanguageCode
        let theme = GomaCashierConfiguration.getCurrentThemeString()

        // Build URL directly (no API call needed)
        guard let url = GomaCashierConfiguration.buildCashierURL(
            transactionType: .deposit,
            sessionId: sessionKey,
            userId: userId,
            currency: currency,
            language: language,
            theme: theme
        ) else {
            state = .error(localized("error_failed_to_build_url"))
            return
        }

        // Log URL for debugging
        GomaLogger.info("\(logPrefix) Cashier URL: \(url.absoluteString)")

        // Transition directly to loadingWebView (skip loadingURL - no API call)
        state = .loadingWebView(url)
    }

    /// Call when WebView finishes loading
    func webViewDidFinishLoading() {
        if case .loadingWebView(let url) = state {
            state = .ready(url)
        }
    }

    /// Call when WebView fails to load
    /// - Parameter error: Error message
    func webViewDidFail(error: String) {
        state = .error(error)
    }

    /// Reset to idle state
    func reset() {
        state = .idle
        cancellables.removeAll()
    }
}
