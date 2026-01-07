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
        isEnabled: Bool = true,
        selectionTitle: String,
        fullCashoutValue: Float
    ) {
        let sliderData = CashoutSliderData(
            title: title,
            minimumValue: minimumValue,
            maximumValue: maximumValue,
            currentValue: currentValue,
            currency: currency,
            isEnabled: isEnabled,
            selectionTitle: selectionTitle,
            fullCashoutValue: fullCashoutValue
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
        let partialCashoutReturn = (currentData.fullCashoutValue * currentData.currentValue) / currentData.maximumValue
        
        // Update button title with current amount
        let formattedAmount = CurrencyHelper.formatAmountWithCurrency(Double(partialCashoutReturn), currency: currentData.currency)
        let buttonTitle = localized("mybets_cashout_amount")
            .replacingOccurrences(of: "{amount}", with: formattedAmount)
        
        let newData = CashoutSliderData(
            title: currentData.title,
            minimumValue: currentData.minimumValue,
            maximumValue: currentData.maximumValue,
            currentValue: clampedValue,
            currency: currentData.currency,
            isEnabled: currentData.isEnabled,
            selectionTitle: buttonTitle,
            fullCashoutValue: currentData.fullCashoutValue
        )
        
        dataSubject.send(newData)
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
            isEnabled: isEnabled,
            selectionTitle: currentData.selectionTitle,
            fullCashoutValue: currentData.fullCashoutValue
        )

        dataSubject.send(newData)
//        _buttonViewModel.setEnabled(isEnabled)
    }

    /// Update slider bounds after partial cashout success
    /// - Parameters:
    ///   - newMaximumValue: New maximum stake value (remaining stake after partial cashout)
    ///   - resetToPercentage: Percentage of new max to reset slider to (default 80%)
    func updateBounds(newMaximumValue: Float, resetToPercentage: Float = 0.8) {
        let currentData = dataSubject.value
        let newCurrentValue = newMaximumValue * resetToPercentage

        // Update button title with new amount
        let formattedAmount = CurrencyHelper.formatAmountWithCurrency(Double(newCurrentValue), currency: currentData.currency)
        let buttonTitle = localized("mybets_cashout_amount")
            .replacingOccurrences(of: "{amount}", with: formattedAmount)
        
        let newData = CashoutSliderData(
            title: currentData.title,
            minimumValue: currentData.minimumValue,
            maximumValue: newMaximumValue,
            currentValue: newCurrentValue,
            currency: currentData.currency,
            isEnabled: currentData.isEnabled,
            selectionTitle: buttonTitle,
            fullCashoutValue: currentData.fullCashoutValue
        )

        dataSubject.send(newData)

//        _buttonViewModel.updateTitle(buttonTitle)
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

        let formattedAmount = CurrencyHelper.formatAmountWithCurrency(Double(currentValue), currency: currency)
        let buttonTitle = localized("mybets_cashout_amount")
            .replacingOccurrences(of: "{amount}", with: formattedAmount)
        
        return CashoutSliderViewModel(
            title: defaultTitle,
            minimumValue: minimumValue,
            maximumValue: maximumValue,
            currentValue: currentValue,
            currency: currency,
            isEnabled: true,
            selectionTitle: buttonTitle,
            fullCashoutValue: 0.0
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
        let formattedAmount = CurrencyHelper.formatAmountWithCurrency(currentAmount, currency: currency)
        let buttonTitle = localized("mybets_cashout_amount")
            .replacingOccurrences(of: "{amount}", with: formattedAmount)
        
        return CashoutSliderViewModel(
            title: defaultTitle,
            minimumValue: Float(minimumAmount),
            maximumValue: Float(maximumAmount),
            currentValue: Float(currentAmount),
            currency: currency,
            isEnabled: true,
            selectionTitle: buttonTitle,
            fullCashoutValue: 0.0
        )
    }
    
}
