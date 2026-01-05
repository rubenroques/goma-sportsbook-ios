import Foundation
import Combine


public class MockCashoutSliderViewModel: CashoutSliderViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject = CurrentValueSubject<CashoutSliderData, Never>(CashoutSliderData.empty)
    
    public var dataPublisher: AnyPublisher<CashoutSliderData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public lazy var buttonViewModel: ButtonViewModelProtocol = {
        let viewModel = MockButtonViewModel(buttonData: ButtonData(id: "cashout", title: LocalizationProvider.string("cashout"), style: .solidBackground, backgroundColor: StyleProvider.Color.buttonBackgroundSecondary, disabledBackgroundColor: StyleProvider.Color.buttonDisableSecondary))
        viewModel.onButtonTapped = { [weak self] in
            self?.handleCashoutTap()
        }
        return viewModel
    }()
    
    // MARK: - Callbacks
    public var onCashoutTap: (() -> Void)?
    
    // MARK: - Initialization
    public init() {}
    
    // MARK: - Public Methods
    public func updateSliderValue(_ value: Float) {
        let currentData = dataSubject.value
        let updatedData = CashoutSliderData(
            title: currentData.title,
            minimumValue: currentData.minimumValue,
            maximumValue: currentData.maximumValue,
            currentValue: value,
            currency: currentData.currency,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(updatedData)
        
        // Update button title
        let cashoutAmount = String(format: "%.0f", value)
        let buttonTitle = "Cashout \(currentData.currency) \(cashoutAmount)"
        buttonViewModel.updateTitle(buttonTitle)
    }
    
    public func handleCashoutTap() {
        print("Cashout tapped!")
        onCashoutTap?()
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        let currentData = dataSubject.value
        let updatedData = CashoutSliderData(
            title: currentData.title,
            minimumValue: currentData.minimumValue,
            maximumValue: currentData.maximumValue,
            currentValue: currentData.currentValue,
            currency: currentData.currency,
            isEnabled: isEnabled
        )
        dataSubject.send(updatedData)
    }
    
    public func updateData(_ data: CashoutSliderData) {
        dataSubject.send(data)
        
        // Update button title
        let cashoutAmount = String(format: "%.0f", data.currentValue)
        let buttonTitle = "Cashout \(data.currency) \(cashoutAmount)"
        buttonViewModel.updateTitle(buttonTitle)
        buttonViewModel.setEnabled(data.isEnabled)
    }
    
    // MARK: - Mock Factory Methods
    public static func defaultMock() -> MockCashoutSliderViewModel {
        let viewModel = MockCashoutSliderViewModel()
        let data = CashoutSliderData(
            title: LocalizationProvider.string("choose_a_cash_out_amount"),
            minimumValue: 0.1,
            maximumValue: 200.0,
            currentValue: 200.0,
            currency: "XAF"
        )
        viewModel.updateData(data)
        return viewModel
    }
    
    public static func maximumMock() -> MockCashoutSliderViewModel {
        let viewModel = MockCashoutSliderViewModel()
        let data = CashoutSliderData(
            title: LocalizationProvider.string("choose_a_cash_out_amount"),
            minimumValue: 0.1,
            maximumValue: 200.0,
            currentValue: 200.0,
            currency: "XAF"
        )
        viewModel.updateData(data)
        return viewModel
    }
    
    public static func minimumMock() -> MockCashoutSliderViewModel {
        let viewModel = MockCashoutSliderViewModel()
        let data = CashoutSliderData(
            title: LocalizationProvider.string("choose_a_cash_out_amount"),
            minimumValue: 0.1,
            maximumValue: 200.0,
            currentValue: 0.1,
            currency: "XAF"
        )
        viewModel.updateData(data)
        return viewModel
    }
    
    public static func customMock(
        title: String = LocalizationProvider.string("choose_a_cash_out_amount"),
        minimumValue: Float = 0.1,
        maximumValue: Float = 200.0,
        currentValue: Float = 100.0,
        currency: String = "XAF"
    ) -> MockCashoutSliderViewModel {
        let viewModel = MockCashoutSliderViewModel()
        let data = CashoutSliderData(
            title: title,
            minimumValue: minimumValue,
            maximumValue: maximumValue,
            currentValue: currentValue,
            currency: currency
        )
        viewModel.updateData(data)
        return viewModel
    }
}

// MARK: - Extensions
extension CashoutSliderData {
    static var empty: CashoutSliderData {
        CashoutSliderData(
            title: "",
            minimumValue: 0.0,
            maximumValue: 1.0,
            currentValue: 0.0,
            currency: ""
        )
    }
} 
