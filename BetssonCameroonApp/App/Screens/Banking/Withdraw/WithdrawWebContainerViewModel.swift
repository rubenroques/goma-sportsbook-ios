//
//  WithdrawWebContainerViewModel.swift
//  BetssonCameroonApp
//
//  Created by Banking Implementation on 11/09/2025.
//

import Foundation
import Combine
import ServicesProvider

/// ViewModel for withdraw WebView operations
final class WithdrawWebContainerViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Single state publisher
    @Published private(set) var state: CashierFrameState = .idle
    
    // MARK: - Private Properties
    
    private let client: ServicesProvider.Client
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Initialize withdraw WebView ViewModel
    /// - Parameter client: Services provider client for withdraw operations
    init(client: ServicesProvider.Client) {
        self.client = client
    }
    
    // MARK: - Public Methods
    
    /// Load withdraw WebView URL from API
    /// - Parameters:
    ///   - currency: Currency code for the transaction
    func loadWithdraw(currency: String) {
        state = .loadingURL

        // Get current language from app localization
        let language = LanguageManager.shared.currentLanguageCode.uppercased()

        let parameters = CashierParameters.forWithdraw(
            language: language,
            currency: currency
        )
        
        client.getBankingWebView(parameters: parameters)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.state = .error(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] response in
                    self?.handleAPIResponse(response)
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
        state = .error(error)
    }
    
    /// Reset to idle state
    func reset() {
        state = .idle
        cancellables.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func handleAPIResponse(_ response: CashierWebViewResponse) {
        guard let url = URL(string: response.webViewURL) else {
            state = .error("Invalid WebView URL received from server")
            return
        }
        
        guard response.isSuccessful else {
            let errorMessage = "Server returned error: \(response.responseCode ?? "unknown")"
            state = .error(errorMessage)
            return
        }
        
        state = .loadingWebView(url)
    }
}

// MARK: - Factory Methods

extension WithdrawWebContainerViewModel {
    
    /// Create a ViewModel with ServicesProvider client
    /// - Parameter client: Services provider client
    /// - Returns: Configured WithdrawWebContainerViewModel
    static func create(with client: ServicesProvider.Client) -> WithdrawWebContainerViewModel {
        return WithdrawWebContainerViewModel(client: client)
    }
}