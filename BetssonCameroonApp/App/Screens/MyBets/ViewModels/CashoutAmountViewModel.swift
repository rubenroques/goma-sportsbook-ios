import Foundation
import Combine
import GomaUI

final class CashoutAmountViewModel: CashoutAmountViewModelProtocol {
    
    // MARK: - Properties
    
    private let dataSubject: CurrentValueSubject<CashoutAmountData, Never>
    
    // MARK: - Publishers
    
    var dataPublisher: AnyPublisher<CashoutAmountData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    init(title: String, currency: String, amount: String) {
        let cashoutData = CashoutAmountData(
            title: title,
            currency: currency,
            amount: amount
        )
        self.dataSubject = CurrentValueSubject(cashoutData)
    }
    
    // MARK: - Public Methods
    
    func updateAmount(_ amount: String) {
        let currentData = dataSubject.value
        let newData = CashoutAmountData(
            title: currentData.title,
            currency: currentData.currency,
            amount: amount
        )
        dataSubject.send(newData)
    }
    
    func updateTitle(_ title: String) {
        let currentData = dataSubject.value
        let newData = CashoutAmountData(
            title: title,
            currency: currentData.currency,
            amount: currentData.amount
        )
        dataSubject.send(newData)
    }
}

// MARK: - Factory Methods

extension CashoutAmountViewModel {
    
    static func create(partialCashoutValue: Double, currency: String) -> CashoutAmountViewModel {
        let formattedAmount = formatCurrency(partialCashoutValue, currency: currency)
        
        return CashoutAmountViewModel(
            title: "Partial Cashout",
            currency: currency,
            amount: formattedAmount
        )
    }
    
    static func create(title: String, amount: Double, currency: String) -> CashoutAmountViewModel {
        let formattedAmount = formatCurrency(amount, currency: currency)
        
        return CashoutAmountViewModel(
            title: title,
            currency: currency,
            amount: formattedAmount
        )
    }
    
    // MARK: - Private Helper Methods
    
    private static func formatCurrency(_ amount: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        if let formattedString = formatter.string(from: NSNumber(value: amount)) {
            return formattedString
        }
        
        // Fallback formatting
        let currencySymbol = getCurrencySymbol(for: currency)
        return "\(currencySymbol) \(String(format: "%.2f", amount))"
    }
    
    private static func getCurrencySymbol(for currency: String) -> String {
        switch currency.uppercased() {
        case "EUR":
            return "€"
        case "USD":
            return "$"
        case "GBP":
            return "£"
        case "XAF":
            return "XAF"
        default:
            return currency
        }
    }
}