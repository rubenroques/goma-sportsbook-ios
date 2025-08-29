
import Foundation
import Combine
import GomaUI

// MARK: - Data Models

enum MyBetsState {
    case loading
    case loaded([MyBet])
    case error(String)
}

struct BetListData {
    let bets: [MyBet]
    let hasMore: Bool
    let currentPage: Int
    
    static let empty = BetListData(bets: [], hasMore: false, currentPage: 0)
}

protocol MyBetsViewModelProtocol {
    
    // MARK: - Tab Management
    
    var selectedTabType: MyBetsTabType { get set }
    var marketGroupSelectorTabViewModel: MarketGroupSelectorTabViewModelProtocol { get }
    
    // MARK: - Status Filter Management
    
    var selectedStatusType: MyBetStatusType { get set }
    var pillSelectorBarViewModel: PillSelectorBarViewModelProtocol { get }
    
    // MARK: - Data Publishers
    
    var betsStatePublisher: AnyPublisher<MyBetsState, Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var errorMessagePublisher: AnyPublisher<String?, Never> { get }
    
    // MARK: - Ticket View Models Publisher
    
    var ticketBetInfoViewModelsPublisher: AnyPublisher<[TicketBetInfoViewModelProtocol], Never> { get }
    
    // MARK: - Navigation Publishers
    
    var selectedTabTypePublisher: AnyPublisher<MyBetsTabType, Never> { get }
    var selectedStatusTypePublisher: AnyPublisher<MyBetStatusType, Never> { get }
    
    // MARK: - Actions
    
    func selectTab(_ tabType: MyBetsTabType)
    func selectStatus(_ statusType: MyBetStatusType)
    func loadBets(forced: Bool)
    func loadMoreBets()
    func refreshBets()
}
