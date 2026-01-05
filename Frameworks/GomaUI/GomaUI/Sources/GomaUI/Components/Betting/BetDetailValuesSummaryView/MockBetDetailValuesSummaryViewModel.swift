import Foundation
import Combine


public class MockBetDetailValuesSummaryViewModel: BetDetailValuesSummaryViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject = CurrentValueSubject<BetDetailValuesSummaryData, Never>(.empty)
    
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
        
        let headerRow = BetDetailRowData(label: "Bet Placed on Sun 01/01 - 18:59", value: "", style: .header)
        
        let contentRows = [
            BetDetailRowData(label: "Odds", value: "1.86", style: .standard),
            BetDetailRowData(label: "Amount", value: "XAF 100.75", style: .standard),
            BetDetailRowData(label: "Stake After Tax", value: "XAF 86.96", style: .standard),
            BetDetailRowData(label: "Potential Winnings", value: "XAF 74.78", style: .standard),
            BetDetailRowData(label: "WHT (20%)", value: "-XAF 18.70", style: .standard),
            BetDetailRowData(label: "Payout", value: "XAF 161.75", style: .standard)
        ]
        
        let footerRow = BetDetailRowData(label: "Bet result", value: LocalizationProvider.string("lost"), style: .standard)
        
        let data = BetDetailValuesSummaryData(
            headerRow: headerRow,
            contentRows: contentRows,
            footerRow: footerRow
        )
        viewModel.updateData(data)
        return viewModel
    }
    
    public static func singleRowMock() -> MockBetDetailValuesSummaryViewModel {
        let viewModel = MockBetDetailValuesSummaryViewModel()
        
        let contentRows = [
            BetDetailRowData(label: "Total Amount", value: "XAF 500.00", style: .standard)
        ]
        
        let data = BetDetailValuesSummaryData(
            headerRow: nil,
            contentRows: contentRows,
            footerRow: nil
        )
        viewModel.updateData(data)
        return viewModel
    }
    
    public static func customMock(
        headerRow: BetDetailRowData? = nil,
        contentRows: [BetDetailRowData],
        footerRow: BetDetailRowData? = nil
    ) -> MockBetDetailValuesSummaryViewModel {
        let viewModel = MockBetDetailValuesSummaryViewModel()
        let data = BetDetailValuesSummaryData(
            headerRow: headerRow,
            contentRows: contentRows,
            footerRow: footerRow
        )
        viewModel.updateData(data)
        return viewModel
    }
}

// MARK: - Extensions
extension BetDetailValuesSummaryData {
    static var empty: BetDetailValuesSummaryData {
        BetDetailValuesSummaryData(contentRows: [])
    }
}
