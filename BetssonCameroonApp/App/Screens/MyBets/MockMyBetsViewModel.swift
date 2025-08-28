
import Foundation
import Combine
import GomaUI

class MockMyBetsViewModel: MyBetsViewModelProtocol {
    
    // MARK: - Tab Management
    
    @Published var selectedTabType: MyBetsTabType = .sports
    
    // MARK: - Status Filter Management
    
    @Published var selectedStatusType: MyBetStatusType = .open
    
    // MARK: - Data State
    
    private let betsStateSubject = CurrentValueSubject<MyBetsState, Never>(.loaded([]))
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let errorMessageSubject = CurrentValueSubject<String?, Never>(nil)
    
    lazy var marketGroupSelectorTabViewModel: MarketGroupSelectorTabViewModelProtocol = {
        let mock = MockMarketGroupSelectorTabViewModel(tabData: MarketGroupSelectorTabData(id: "myBets", marketGroups: []))
        
        // Configure tabs for Sports and Virtuals
        let tabs = [
            MarketGroupTabItemData(
                id: MyBetsTabType.sports.rawValue,
                title: MyBetsTabType.sports.title,
                visualState: .selected,
                iconTypeName: MyBetsTabType.sports.iconTypeName
            ),
            MarketGroupTabItemData(
                id: MyBetsTabType.virtuals.rawValue,
                title: MyBetsTabType.virtuals.title,
                visualState: .idle,
                iconTypeName: MyBetsTabType.virtuals.iconTypeName
            )
        ]
        
        mock.updateMarketGroups(tabs)
        mock.selectMarketGroup(id: MyBetsTabType.sports.rawValue)
        
        // Handle tab selection
        mock.selectionEventPublisher
            .sink { [weak self] event in
                if let tabType = MyBetsTabType(rawValue: event.selectedId) {
                    self?.selectTab(tabType)
                }
            }
            .store(in: &cancellables)
        
        return mock
    }()
    
    lazy var pillSelectorBarViewModel: PillSelectorBarViewModelProtocol = {
        // Configure pills for bet statuses
        let pills = MyBetStatusType.allCases.map { statusType in
            PillData(
                id: statusType.pillId,
                title: statusType.title,
                leftIconName: nil,
                showExpandIcon: false,
                isSelected: statusType == .open
            )
        }
        
        let barData = PillSelectorBarData(
            id: "betStatus",
            pills: pills,
            selectedPillId: MyBetStatusType.open.pillId
        )
        
        let mock = MockPillSelectorBarViewModel(barData: barData)
        
        // Handle pill selection
        mock.selectionEventPublisher
            .sink { [weak self] event in
                if let statusType = MyBetStatusType(rawValue: event.selectedId) {
                    self?.selectStatus(statusType)
                }
            }
            .store(in: &cancellables)
        
        return mock
    }()
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Publishers
    
    var selectedTabTypePublisher: AnyPublisher<MyBetsTabType, Never> {
        $selectedTabType.eraseToAnyPublisher()
    }
    
    var selectedStatusTypePublisher: AnyPublisher<MyBetStatusType, Never> {
        $selectedStatusType.eraseToAnyPublisher()
    }
    
    // MARK: - Data Publishers
    
    var betsStatePublisher: AnyPublisher<MyBetsState, Never> {
        betsStateSubject.eraseToAnyPublisher()
    }
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    var errorMessagePublisher: AnyPublisher<String?, Never> {
        errorMessageSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    init() {
        // Minimal setup - no dummy data
    }
    
    // MARK: - Actions
    
    func selectTab(_ tabType: MyBetsTabType) {
        selectedTabType = tabType
        print("🎯 MockMyBetsViewModel: Selected tab: \(tabType.title)")
    }
    
    func selectStatus(_ statusType: MyBetStatusType) {
        selectedStatusType = statusType
        print("🎯 MockMyBetsViewModel: Selected status: \(statusType.title)")
    }
    
    func loadBets(forced: Bool) {
        print("🎯 MockMyBetsViewModel: loadBets called (forced: \(forced))")
    }
    
    func loadMoreBets() {
        print("🎯 MockMyBetsViewModel: loadMoreBets called")
    }
    
    func refreshBets() {
        print("🎯 MockMyBetsViewModel: refreshBets called")
    }
}
