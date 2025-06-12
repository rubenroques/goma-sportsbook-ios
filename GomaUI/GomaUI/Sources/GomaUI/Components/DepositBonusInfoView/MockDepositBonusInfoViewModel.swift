//
//  MockDepositBonusInfoViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 06/06/2025.
//

import Foundation

import Combine
import UIKit

/// Mock implementation of `DepositBonusInfoViewModelProtocol` for testing.
final public class MockDepositBonusInfoViewModel: DepositBonusBalanceViewModelProtocol {
    
    // MARK: - Properties
    private let depositBonusInfoSubject: CurrentValueSubject<DepositBonusInfoData, Never>
    public var depositBonusInfoPublisher: AnyPublisher<DepositBonusInfoData, Never> {
        return depositBonusInfoSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    public init(depositBonusInfo: DepositBonusInfoData) {
        self.depositBonusInfoSubject = CurrentValueSubject(depositBonusInfo)
    }
    
    // MARK: - DepositBonusBalanceViewModelProtocol
    public func updateAmount(_ newAmount: String) {
        let currentData = depositBonusInfoSubject.value
        let updatedData = DepositBonusInfoData(
            id: currentData.id,
            icon: currentData.icon,
            balanceText: currentData.balanceText,
            currencyAmount: newAmount
        )
        depositBonusInfoSubject.send(updatedData)
    }
}

// MARK: - Mock Factory
extension MockDepositBonusInfoViewModel {
    
    /// Default mock matching the image (XAF currency)
    public static var defaultMock: MockDepositBonusInfoViewModel {
        let depositBonusInfo = DepositBonusInfoData(
            id: "deposit_bonus_balance",
            icon: "gift.fill",
            balanceText: "Your deposit + Bonus",
            currencyAmount: "XAF --"
        )
        
        return MockDepositBonusInfoViewModel(depositBonusInfo: depositBonusInfo)
    }
    
    /// Mock with USD currency
    public static var usdMock: MockDepositBonusInfoViewModel {
        let depositBonusInfo = DepositBonusInfoData(
            id: "usd_balance",
            icon: "gift.fill",
            balanceText: "Your deposit + Bonus",
            currencyAmount: "USD $150.00"
        )
        
        return MockDepositBonusInfoViewModel(depositBonusInfo: depositBonusInfo)
    }
}
