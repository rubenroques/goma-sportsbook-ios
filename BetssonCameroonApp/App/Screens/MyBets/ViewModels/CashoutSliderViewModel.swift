import Foundation
import Combine
import GomaUI

final class CashoutSliderViewModel: CashoutSliderViewModelProtocol {
    
    // MARK: - Properties
    
    private let dataSubject: CurrentValueSubject<CashoutSliderData, Never>
    private let _buttonViewModel: ButtonViewModel
    
    // MARK: - Publishers
    
    var dataPublisher: AnyPublisher<CashoutSliderData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    var buttonViewModel: ButtonViewModelProtocol {
        _buttonViewModel
    }
    
    // MARK: - Callbacks
    
    var onCashoutRequested: ((Float) -> Void)?
    
    // MARK: - Initialization
    
    init(
        title: String,
        minimumValue: Float,
        maximumValue: Float,
        currentValue: Float,
        currency: String,
        isEnabled: Bool = true
    ) {
        let sliderData = CashoutSliderData(
            title: title,
            minimumValue: minimumValue,
            maximumValue: maximumValue,
            currentValue: currentValue,
            currency: currency,
            isEnabled: isEnabled
        )
        
        self.dataSubject = CurrentValueSubject(sliderData)
        self._buttonViewModel = ButtonViewModel.cashoutButton(isEnabled: isEnabled)
        
        // Wire up button action
        self._buttonViewModel.onButtonTapped = { [weak self] in
            self?.handleCashoutTap()
        }
    }
    
    // MARK: - Protocol Methods
    
    func updateSliderValue(_ value: Float) {
        let currentData = dataSubject.value
        let clampedValue = max(currentData.minimumValue, min(currentData.maximumValue, value))
        
        let newData = CashoutSliderData(
            title: currentData.title,
            minimumValue: currentData.minimumValue,
            maximumValue: currentData.maximumValue,
            currentValue: clampedValue,
            currency: currentData.currency,
            isEnabled: currentData.isEnabled
        )
        
        dataSubject.send(newData)
        
        // Update button title with current amount
        let formattedAmount = formatCurrency(Double(clampedValue), currency: currentData.currency)
        let buttonTitle = localized("mybets_cashout_amount")
            .replacingOccurrences(of: "{amount}", with: formattedAmount)
        _buttonViewModel.updateTitle(buttonTitle)
    }
    
    func handleCashoutTap() {
        let currentValue = dataSubject.value.currentValue
        onCashoutRequested?(currentValue)
    }
    
    func setEnabled(_ isEnabled: Bool) {
        let currentData = dataSubject.value
        let newData = CashoutSliderData(
            title: currentData.title,
            minimumValue: currentData.minimumValue,
            maximumValue: currentData.maximumValue,
            currentValue: currentData.currentValue,
            currency: currentData.currency,
            isEnabled: isEnabled
        )
        
        dataSubject.send(newData)
        _buttonViewModel.setEnabled(isEnabled)
    }
}

// MARK: - Factory Methods

extension CashoutSliderViewModel {
    
    static func create(
        totalCashoutAmount: Double,
        currency: String,
        title: String? = nil
    ) -> CashoutSliderViewModel {
        let defaultTitle = title ?? localized("mybets_choose_cashout_amount")
        let minimumValue: Float = 0.1
        let maximumValue = Float(totalCashoutAmount)
        let currentValue = maximumValue // Start at maximum

        return CashoutSliderViewModel(
            title: defaultTitle,
            minimumValue: minimumValue,
            maximumValue: maximumValue,
            currentValue: currentValue,
            currency: currency,
            isEnabled: true
        )
    }
    
    static func create(
        minimumAmount: Double,
        maximumAmount: Double,
        currentAmount: Double,
        currency: String,
        title: String? = nil
    ) -> CashoutSliderViewModel {
        let defaultTitle = title ?? localized("mybets_choose_cashout_amount")
        return CashoutSliderViewModel(
            title: defaultTitle,
            minimumValue: Float(minimumAmount),
            maximumValue: Float(maximumAmount),
            currentValue: Float(currentAmount),
            currency: currency,
            isEnabled: true
        )
    }
    
    // MARK: - Private Helper Methods
    
    private func formatCurrency(_ amount: Double, currency: String) -> String {
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
    
    private func getCurrencySymbol(for currency: String) -> String {
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