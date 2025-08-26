import Foundation
import Combine

public class MockBetDetailValuesSummaryViewModel: BetDetailValuesSummaryViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject = CurrentValueSubject<BetDetailValuesSummaryData, Never>(BetDetailValuesSummaryData.empty)
    
    public var dataPublisher: AnyPublisher<BetDetailValuesSummaryData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    public init() {}
    
    // MARK: - Public Methods
    public func updateData(_ data: BetDetailValuesSummaryData) {
        dataSubject.send(data)
    }
    
    // MARK: - Mock Factory Methods
    public static func defaultMock() -> MockBetDetailValuesSummaryViewModel {
        let viewModel = MockBetDetailValuesSummaryViewModel()
        let rows = [
            BetDetailRowData(label: "Odds", value: "1.86"),
            BetDetailRowData(label: "Amount", value: "XAF 100.75"),
            BetDetailRowData(label: "Stake After Tax", value: "XAF 86.96"),
            BetDetailRowData(label: "Potential Winnings", value: "XAF 74.78"),
            BetDetailRowData(label: "WHT (20%)", value: "-XAF 18.70"),
            BetDetailRowData(label: "Payout", value: "XAF 161.75")
        ]
        let data = BetDetailValuesSummaryData(rows: rows)
        viewModel.updateData(data)
        return viewModel
    }
    
    public static func singleRowMock() -> MockBetDetailValuesSummaryViewModel {
        let viewModel = MockBetDetailValuesSummaryViewModel()
        let rows = [
            BetDetailRowData(label: "Total Amount", value: "XAF 500.00")
        ]
        let data = BetDetailValuesSummaryData(rows: rows)
        viewModel.updateData(data)
        return viewModel
    }
    
    public static func customMock(rows: [BetDetailRowData]) -> MockBetDetailValuesSummaryViewModel {
        let viewModel = MockBetDetailValuesSummaryViewModel()
        let data = BetDetailValuesSummaryData(rows: rows)
        viewModel.updateData(data)
        return viewModel
    }
}

// MARK: - Extensions
extension BetDetailValuesSummaryData {
    static var empty: BetDetailValuesSummaryData {
        BetDetailValuesSummaryData(rows: [])
    }
}
