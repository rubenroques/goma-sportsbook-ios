
import Foundation
import Combine
import GomaUI

protocol MyBetsViewModelProtocol {
    
    // MARK: - Tab Management
    
    var selectedTabType: MyBetsTabType { get set }
    var marketGroupSelectorTabViewModel: MarketGroupSelectorTabViewModelProtocol { get }
    
    // MARK: - Status Filter Management
    
    var selectedStatusType: MyBetStatusType { get set }
    var pillSelectorBarViewModel: PillSelectorBarViewModelProtocol { get }
    
    // MARK: - Publishers
    
    var selectedTabTypePublisher: AnyPublisher<MyBetsTabType, Never> { get }
    var selectedStatusTypePublisher: AnyPublisher<MyBetStatusType, Never> { get }
    
    // MARK: - Actions
    
    func selectTab(_ tabType: MyBetsTabType)
    func selectStatus(_ statusType: MyBetStatusType)
}
