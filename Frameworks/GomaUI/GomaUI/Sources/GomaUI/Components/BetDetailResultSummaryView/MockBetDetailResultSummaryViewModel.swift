import Foundation
import Combine

public class MockBetDetailResultSummaryViewModel: BetDetailResultSummaryViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject = CurrentValueSubject<BetDetailResultSummaryData, Never>(BetDetailResultSummaryData.empty)
    
    public var dataPublisher: AnyPublisher<BetDetailResultSummaryData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    public init() {}
    
    // MARK: - Public Methods
    public func updateData(_ data: BetDetailResultSummaryData) {
        dataSubject.send(data)
    }
    
    // MARK: - Mock Factory Methods
    public static func wonMock() -> MockBetDetailResultSummaryViewModel {
        let viewModel = MockBetDetailResultSummaryViewModel()
        let data = BetDetailResultSummaryData(
            betPlacedDate: "Bet Placed on Sun 01/01 - 18:59",
            matchDetails: "Ceara SC CE x CR Vasco da Gama RJ",
            betType: "Double chance - Ceara SC CE",
            resultState: .won
        )
        viewModel.updateData(data)
        return viewModel
    }
    
    public static func lostMock() -> MockBetDetailResultSummaryViewModel {
        let viewModel = MockBetDetailResultSummaryViewModel()
        let data = BetDetailResultSummaryData(
            betPlacedDate: "Bet Placed on Sun 01/01 - 18:59",
            matchDetails: "Ceara SC CE x CR Vasco da Gama RJ",
            betType: "Double chance - Ceara SC CE",
            resultState: .lost
        )
        viewModel.updateData(data)
        return viewModel
    }
    
    public static func drawMock() -> MockBetDetailResultSummaryViewModel {
        let viewModel = MockBetDetailResultSummaryViewModel()
        let data = BetDetailResultSummaryData(
            betPlacedDate: "Bet Placed on Sun 01/01 - 18:59",
            matchDetails: "Ceara SC CE x CR Vasco da Gama RJ",
            betType: "Double chance - Ceara SC CE",
            resultState: .draw
        )
        viewModel.updateData(data)
        return viewModel
    }
    
    public static func customMock(
        betPlacedDate: String,
        matchDetails: String,
        betType: String,
        resultState: BetDetailResultState
    ) -> MockBetDetailResultSummaryViewModel {
        let viewModel = MockBetDetailResultSummaryViewModel()
        let data = BetDetailResultSummaryData(
            betPlacedDate: betPlacedDate,
            matchDetails: matchDetails,
            betType: betType,
            resultState: resultState
        )
        viewModel.updateData(data)
        return viewModel
    }
}

// MARK: - Extensions
extension BetDetailResultSummaryData {
    static var empty: BetDetailResultSummaryData {
        BetDetailResultSummaryData(
            betPlacedDate: "",
            matchDetails: "",
            betType: "",
            resultState: .won
        )
    }
}
