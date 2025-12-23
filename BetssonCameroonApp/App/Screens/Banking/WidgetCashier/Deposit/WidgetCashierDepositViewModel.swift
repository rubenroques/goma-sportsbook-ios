//
//  WidgetCashierDepositViewModel.swift
//  BetssonCameroonApp
//
//  Created by Widget Cashier Implementation on 10/12/2025.
//

import Foundation
import Combine
import GomaLogger
import ServicesProvider
import UIKit

/// ViewModel for Widget Cashier deposit operations
/// Uses ServicesProvider to build cashier URL with internal session token
final class WidgetCashierDepositViewModel: ObservableObject {

    private let logCategory = "WidgetCashier"

    // MARK: - Published Properties

    /// Current state of the cashier frame
    @Published private(set) var state: CashierFrameState = .idle

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Public Methods

    /// Load deposit cashier URL from ServicesProvider
    func loadDeposit() {
        state = .loadingURL

        let language = LanguageManager.shared.currentLanguageCode
        let theme = Self.getCurrentThemeString()

        Env.servicesProvider.getWidgetCashierURL(type: .deposit, language: language, theme: theme)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    if case .failure(let error) = completion {
                        GomaLogger.error(.payments, category: self.logCategory, "Failed to build deposit URL: \(error)")
                        self.state = .error(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] url in
                    guard let self = self else { return }
                    GomaLogger.info(.payments, category: self.logCategory, "Deposit URL: \(url.absoluteString)")
                    self.state = .loadingWebView(url)
                }
            )
            .store(in: &cancellables)
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
        GomaLogger.error(.payments, category: logCategory, "WebView failed: \(error)")
        state = .error(error)
    }

    /// Reset to idle state
    func reset() {
        state = .idle
        cancellables.removeAll()
    }

    // MARK: - Private Methods

    private static func getCurrentThemeString() -> String {
        let savedMode = UserDefaults.standard.appearanceMode

        switch savedMode {
        case .dark:
            return "dark"
        case .light:
            return "light"
        case .device:
            // When following system, check the actual resolved style from the key window
            let resolvedStyle = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }?
                .traitCollection.userInterfaceStyle ?? .dark

            return resolvedStyle == .dark ? "dark" : "light"
        }
    }
}
