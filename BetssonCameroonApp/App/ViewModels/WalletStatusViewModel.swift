//
//  WalletStatusViewModel.swift
//  BetssonCameroonApp
//
//  Created by Assistant on 02/09/2025.
//

import Foundation
import Combine
import GomaUI

final class WalletStatusViewModel: WalletStatusViewModelProtocol {
    
    // MARK: - Properties
    
    // Balance subjects
    private let totalBalanceSubject = CurrentValueSubject<String, Never>("-.--")
    private let currentBalanceSubject = CurrentValueSubject<String, Never>("-.--")
    private let bonusBalanceSubject = CurrentValueSubject<String, Never>("-.--")
    private let cashbackBalanceSubject = CurrentValueSubject<String, Never>("-.--")
    private let withdrawableAmountSubject = CurrentValueSubject<String, Never>("-.--")
    
    // Publishers
    var totalBalancePublisher: AnyPublisher<String, Never> {
        totalBalanceSubject.eraseToAnyPublisher()
    }
    
    var currentBalancePublisher: AnyPublisher<String, Never> {
        currentBalanceSubject.eraseToAnyPublisher()
    }
    
    var bonusBalancePublisher: AnyPublisher<String, Never> {
        bonusBalanceSubject.eraseToAnyPublisher()
    }
    
    var cashbackBalancePublisher: AnyPublisher<String, Never> {
        cashbackBalanceSubject.eraseToAnyPublisher()
    }
    
    var withdrawableAmountPublisher: AnyPublisher<String, Never> {
        withdrawableAmountSubject.eraseToAnyPublisher()
    }
    
    // Button view models
    let depositButtonViewModel: ButtonViewModelProtocol
    let withdrawButtonViewModel: ButtonViewModelProtocol
    
    // Dependencies
    private let userSessionStore: UserSessionStore
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(userSessionStore: UserSessionStore) {
        self.userSessionStore = userSessionStore
        
        self.depositButtonViewModel = ButtonViewModel.depositButton()
        self.withdrawButtonViewModel = ButtonViewModel.withdrawButton()
        
        setupWalletBinding()
    }
    
    // MARK: - WalletStatusViewModelProtocol
    
    func setTotalBalance(amount: String) {
        totalBalanceSubject.send(amount)
    }
    
    func setCurrentBalance(amount: String) {
        currentBalanceSubject.send(amount)
    }
    
    func setBonusBalance(amount: String) {
        bonusBalanceSubject.send(amount)
    }
    
    func setCashbackBalance(amount: String) {
        cashbackBalanceSubject.send(amount)
    }
    
    func setWithdrawableBalance(amount: String) {
        withdrawableAmountSubject.send(amount)
    }
    
    // MARK: - Private Methods
    
    private func setupWalletBinding() {
        // Subscribe to wallet updates from UserSessionStore
        userSessionStore.userWalletPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] wallet in
                self?.updateWalletDisplay(wallet: wallet)
            }
            .store(in: &cancellables)
        
        print("💰 WalletStatusViewModel: Wallet binding established")
    }
    
    private func updateWalletDisplay(wallet: UserWallet?) {
        if let wallet = wallet {
            // Update all balance displays with formatted amounts
            setTotalBalance(amount: CurrencyFormater.formatWalletAmount(wallet.total))
            setBonusBalance(amount: CurrencyFormater.formatWalletAmount(wallet.bonus ?? 0.0))
            setCurrentBalance(amount: CurrencyFormater.formatWalletAmount(wallet.total))
            setWithdrawableBalance(amount: CurrencyFormater.formatWalletAmount(wallet.totalWithdrawable ?? 0.0))
            setCashbackBalance(amount: CurrencyFormater.formatWalletAmount(0.0))
            
            print("💰 WalletStatusViewModel: Wallet balances updated - total: \(wallet.total)")
        } else {
            // No wallet data - show placeholders
            setTotalBalance(amount: "-.--")
            setBonusBalance(amount: "-.--")
            setCurrentBalance(amount: "-.--")
            setWithdrawableBalance(amount: "-.--")
            setCashbackBalance(amount: "-.--")
            
            print("💰 WalletStatusViewModel: Wallet cleared - showing placeholders")
        }
    }
}
