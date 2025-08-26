import Foundation
import Combine

public class MockCashoutAmountViewModel: CashoutAmountViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject = CurrentValueSubject<CashoutAmountData, Never>(CashoutAmountData.empty)
    
    public var dataPublisher: AnyPublisher<CashoutAmountData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    public init() {}
    
    // MARK: - Public Methods
    public func updateData(_ data: CashoutAmountData) {
        dataSubject.send(data)
    }
    
    // MARK: - Mock Factory Methods
    public static func defaultMock() -> MockCashoutAmountViewModel {
        let viewModel = MockCashoutAmountViewModel()
        let data = CashoutAmountData(
            title: "Partial Cashout",
            currency: "XAF",
            amount: "32.00"
        )
        viewModel.updateData(data)
        return viewModel
    }
    
    public static func customMock(
        title: String,
        currency: String,
        amount: String
    ) -> MockCashoutAmountViewModel {
        let viewModel = MockCashoutAmountViewModel()
        let data = CashoutAmountData(
            title: title,
            currency: currency,
            amount: amount
        )
        viewModel.updateData(data)
        return viewModel
    }
}

// MARK: - Extensions
extension CashoutAmountData {
    static var empty: CashoutAmountData {
        CashoutAmountData(
            title: "",
            currency: "",
            amount: ""
        )
    }
}
