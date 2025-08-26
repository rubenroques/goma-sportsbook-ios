import Foundation
import Combine

public class MockBetTicketStatusViewModel: BetTicketStatusViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject = CurrentValueSubject<BetTicketStatusData, Never>(BetTicketStatusData.empty)
    
    public var dataPublisher: AnyPublisher<BetTicketStatusData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    public init() {}
    
    // MARK: - Public Methods
    public func setVisible(_ isVisible: Bool) {
        let currentData = dataSubject.value
        let updatedData = BetTicketStatusData(
            status: currentData.status,
            isVisible: isVisible
        )
        dataSubject.send(updatedData)
    }
    
    public func updateData(_ data: BetTicketStatusData) {
        dataSubject.send(data)
    }
    
    // MARK: - Mock Factory Methods
    public static func wonMock() -> MockBetTicketStatusViewModel {
        let viewModel = MockBetTicketStatusViewModel()
        let data = BetTicketStatusData(status: .won)
        viewModel.updateData(data)
        return viewModel
    }
    
    public static func lostMock() -> MockBetTicketStatusViewModel {
        let viewModel = MockBetTicketStatusViewModel()
        let data = BetTicketStatusData(status: .lost)
        viewModel.updateData(data)
        return viewModel
    }
    
    public static func drawMock() -> MockBetTicketStatusViewModel {
        let viewModel = MockBetTicketStatusViewModel()
        let data = BetTicketStatusData(status: .draw)
        viewModel.updateData(data)
        return viewModel
    }
    
    public static func customMock(
        status: BetTicketStatus,
        isVisible: Bool = true
    ) -> MockBetTicketStatusViewModel {
        let viewModel = MockBetTicketStatusViewModel()
        let data = BetTicketStatusData(
            status: status,
            isVisible: isVisible
        )
        viewModel.updateData(data)
        return viewModel
    }
}

// MARK: - Extensions
extension BetTicketStatusData {
    static var empty: BetTicketStatusData {
        BetTicketStatusData(
            status: .won,
            isVisible: false
        )
    }
}
