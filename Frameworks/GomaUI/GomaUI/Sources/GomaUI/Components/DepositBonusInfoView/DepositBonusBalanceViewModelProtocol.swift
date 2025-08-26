import Foundation
import UIKit
import Combine

// MARK: - Data Models
public struct DepositBonusInfoData: Equatable, Hashable {
    public let id: String
    public let icon: String
    public let balanceText: String
    public let currencyAmount: String
    
    public init(id: String, icon: String, balanceText: String, currencyAmount: String) {
        self.id = id
        self.icon = icon
        self.balanceText = balanceText
        self.currencyAmount = currencyAmount
    }
}

// MARK: - View Model Protocol
public protocol DepositBonusBalanceViewModelProtocol {
    /// Publisher for reactive updates
    var depositBonusInfoPublisher: AnyPublisher<DepositBonusInfoData, Never> { get }
    
    /// Update the currency amount
    func updateAmount(_ newAmount: String)
}
