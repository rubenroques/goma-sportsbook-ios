import Foundation
import Combine

/// Data model for cashout amount information
public struct CashoutAmountData: Equatable {
    public let title: String
    public let currency: String
    public let amount: String
    
    public init(
        title: String,
        currency: String,
        amount: String
    ) {
        self.title = title
        self.currency = currency
        self.amount = amount
    }
}

/// Protocol defining the interface for CashoutAmountView ViewModels
public protocol CashoutAmountViewModelProtocol {
    /// Publisher for the cashout amount data
    var dataPublisher: AnyPublisher<CashoutAmountData, Never> { get }
}
