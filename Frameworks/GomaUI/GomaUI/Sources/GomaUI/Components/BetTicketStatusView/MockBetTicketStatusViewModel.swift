import Foundation
import Combine

public class MockBetTicketStatusViewModel: BetTicketStatusViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<BetTicketStatusData, Never>
    
    public var dataPublisher: AnyPublisher<BetTicketStatusData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    public init(betTicketStatusData: BetTicketStatusData) {
        self.dataSubject = .init(betTicketStatusData)
    }
 
    public func updateData(_ data: BetTicketStatusData) {
        dataSubject.send(data)
    }
    
    // MARK: - Mock Factory Methods
    public static func wonMock() -> MockBetTicketStatusViewModel {
        let data = BetTicketStatusData(status: .won)
        let viewModel = MockBetTicketStatusViewModel(betTicketStatusData: data)
        return viewModel
    }
    
    public static func lostMock() -> MockBetTicketStatusViewModel {
        let data = BetTicketStatusData(status: .lost)
        let viewModel = MockBetTicketStatusViewModel(betTicketStatusData: data)
        return viewModel
    }
    
    public static func drawMock() -> MockBetTicketStatusViewModel {
        let data = BetTicketStatusData(status: .draw)
        let viewModel = MockBetTicketStatusViewModel(betTicketStatusData: data)
        return viewModel
    }
    
    public static func customMock(status: BetTicketStatus) -> MockBetTicketStatusViewModel {
        let data = BetTicketStatusData(status: status)
        let viewModel = MockBetTicketStatusViewModel(betTicketStatusData: data)
        return viewModel
    }
}
