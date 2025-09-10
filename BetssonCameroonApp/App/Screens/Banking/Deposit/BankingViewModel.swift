//
//  BankingViewModel.swift
//  BetssonCameroonApp
//
//  Created by Banking Implementation on 10/09/2025.
//

import Foundation
import Combine
import ServicesProvider


/// States representing the banking WebView loading process
enum BankingState: Equatable {
    case idle
    case loading
    case loaded(webViewURL: URL)
    case error(message: String)
}

/// States representing different screens in the banking flow
enum BankingScreen: Equatable {
    case bonusSelection
    case amountInput
    case webView(url: URL)
    case success(amount: Double)
    case error(message: String)
}


/// Production implementation of banking operations ViewModel
 final class BankingViewModel {
    
    // MARK: - Dependencies
    
    private let client: ServicesProvider.Client
    
    // MARK: - Private State
    
    private let stateSubject = CurrentValueSubject<BankingState, Never>(.idle)
    private let screenSubject = CurrentValueSubject<BankingScreen, Never>(.amountInput)
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    
     let transactionType: CashierTransactionType
    
    // MARK: - Publishers
    
     var statePublisher: AnyPublisher<BankingState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
     var screenPublisher: AnyPublisher<BankingScreen, Never> {
        screenSubject.eraseToAnyPublisher()
    }
    
     var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    /// Initialize banking ViewModel
    /// - Parameters:
    ///   - transactionType: Type of banking transaction (Deposit/Withdraw)
    ///   - client: Services provider client for banking operations
     init(
        transactionType: CashierTransactionType,
        client: ServicesProvider.Client
    ) {
        self.transactionType = transactionType
        self.client = client
        
        setupBindings()
    }
    
    // MARK: - Private Setup
    
    private func setupBindings() {
        // Update loading state based on main state
        stateSubject
            .map { state in
                switch state {
                case .loading:
                    return true
                default:
                    return false
                }
            }
            .sink { [weak self] isLoading in
                self?.isLoadingSubject.send(isLoading)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
     func initializeBanking(currency: String, language: String, isFirstDeposit: Bool) {
        // Show bonus selection for first deposits only
        if isFirstDeposit && transactionType == .deposit {
            screenSubject.send(.bonusSelection)
            return
        }
        
        // Otherwise proceed directly to WebView
        loadBankingWebView(currency: currency, language: language)
    }
    
     func handleTransactionSuccess(amount: Double?) {
        let successAmount = amount ?? 0.0
        stateSubject.send(.idle)
        screenSubject.send(.success(amount: successAmount))
    }
    
     func handleTransactionError(error: String) {
        stateSubject.send(.error(message: error))
        screenSubject.send(.error(message: error))
    }
    
     func handleCancellation() {
        reset()
    }
    
     func reset() {
        stateSubject.send(.idle)
        screenSubject.send(.amountInput)
    }
    
     func showBonusSelection() {
        screenSubject.send(.bonusSelection)
    }
    
     func skipBonusSelection() {
        // This would typically be called after bonus selection
        // Implementation should load WebView with appropriate parameters
        // For now, transition to amount input
        screenSubject.send(.amountInput)
    }
    
    // MARK: - Private Methods
    
    private func loadBankingWebView(currency: String, language: String, bonusCode: String? = nil) {
        stateSubject.send(.loading)
        
        let parameters: CashierParameters
        
        switch transactionType {
        case .deposit:
            parameters = .forDeposit(
                language: language,
                currency: currency,
                bonusCode: bonusCode
            )
        case .withdraw:
            parameters = .forWithdraw(
                language: language,
                currency: currency
            )
        }
        
        client.getBankingWebView(parameters: parameters)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        self?.handleAPIError(error)
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] response in
                    self?.handleBankingResponse(response)
                }
            )
            .store(in: &cancellables)
    }
    
    private func handleBankingResponse(_ response: CashierWebViewResponse) {
        guard let cashierURL = URL(string: response.cashierInfo.url) else {
            handleAPIError(ServiceProviderError.errorMessage(message: "Invalid WebView URL received"))
            return
        }
        
        stateSubject.send(.loaded(webViewURL: cashierURL))
        screenSubject.send(.webView(url: cashierURL))
    }
    
    private func handleAPIError(_ error: ServiceProviderError) {
        let errorMessage = error.localizedDescription
        stateSubject.send(.error(message: errorMessage))
        screenSubject.send(.error(message: errorMessage))
    }
}

// MARK: - Convenience Methods

 extension BankingViewModel {
    
    /// Create a deposit ViewModel
    /// - Parameter client: Services provider client
    /// - Returns: Configured ViewModel for deposit operations
    static func forDeposit(
        client: ServicesProvider.Client
    ) -> BankingViewModel {
        return BankingViewModel(
            transactionType: .deposit,
            client: client
        )
    }
    
    /// Create a withdraw ViewModel
    /// - Parameter client: Services provider client
    /// - Returns: Configured ViewModel for withdraw operations
    static func forWithdraw(
        client: ServicesProvider.Client
    ) -> BankingViewModel {
        return BankingViewModel(
            transactionType: .withdraw,
            client: client
        )
    }
}
