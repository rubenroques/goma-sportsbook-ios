//
//  DepositWebContainerViewModel.swift
//  BetssonCameroonApp
//
//  Created by Banking Implementation on 11/09/2025.
//

import Foundation
import Combine
import ServicesProvider

/// ViewModel for deposit WebView operations
final class DepositWebContainerViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Single state publisher
    @Published private(set) var state: CashierFrameState = .idle
    
    // MARK: - Private Properties
    
    private let client: ServicesProvider.Client
    private var cancellables = Set<AnyCancellable>()
    private var bonusCode: String?
    
    // MARK: - Initialization
    
    /// Initialize deposit WebView ViewModel
    /// - Parameter client: Services provider client for deposit operations
    init(client: ServicesProvider.Client, bonusCode: String? = nil) {
        self.client = client
        self.bonusCode = bonusCode
    }
    
    // MARK: - Public Methods
    
    /// Load deposit WebView URL from API
    /// - Parameters:
    ///   - currency: Currency code for the transaction
    ///   - language: Language code for the WebView
    ///   - bonusCode: Optional bonus code to apply
    func loadDeposit(currency: String, language: String, bonusCode: String? = nil) {
        state = .loadingURL
        
        let parameters = CashierParameters.forDeposit(
            language: language,
            currency: currency,
            bonusCode: self.bonusCode != nil ? self.bonusCode : bonusCode
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

extension DepositWebContainerViewModel {
    
    /// Create a ViewModel with ServicesProvider client
    /// - Parameter client: Services provider client
    /// - Returns: Configured DepositWebContainerViewModel
    static func create(with client: ServicesProvider.Client) -> DepositWebContainerViewModel {
        return DepositWebContainerViewModel(client: client)
    }
}
