import Foundation
import Combine

public class MockBetDetailRowViewModel: BetDetailRowViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject = CurrentValueSubject<BetDetailRowData, Never>(BetDetailRowData.empty)
    
    public var dataPublisher: AnyPublisher<BetDetailRowData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    public init() {}
    
    // MARK: - Public Methods
    public func updateData(_ data: BetDetailRowData) {
        dataSubject.send(data)
    }
    
    // MARK: - Mock Factory Methods
    public static func defaultMock() -> MockBetDetailRowViewModel {
        let viewModel = MockBetDetailRowViewModel()
        let data = BetDetailRowData(
            label: "Amount",
            value: "XAF 100.75"
        )
        viewModel.updateData(data)
        return viewModel
    }
    
    public static func customMock(
        label: String,
        value: String,
        showSeparator: Bool = true
    ) -> MockBetDetailRowViewModel {
        let viewModel = MockBetDetailRowViewModel()
        let data = BetDetailRowData(
            label: label,
            value: value
        )
        viewModel.updateData(data)
        return viewModel
    }
}

// MARK: - Extensions
extension BetDetailRowData {
    static var empty: BetDetailRowData {
        BetDetailRowData(
            label: "",
            value: ""
        )
    }
}
