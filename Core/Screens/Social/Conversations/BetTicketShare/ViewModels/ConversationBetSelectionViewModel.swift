//
//  ConversationBetSelectionViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 23/05/2022.
//

import Foundation
import Combine

class ConversationBetSelectionViewModel {

    // MARK: Public Properties
    var cachedCellViewModels: [String: BetSelectionCellViewModel] = [:]
    var isChatGroup: Bool = false
    private var selectedMyTicketsTypeIndex: Int = 0
    var myTicketsTypePublisher: CurrentValueSubject<MyTicketsType, Never> = .init(.opened)
    var isTicketsEmptyPublisher: AnyPublisher<Bool, Never>

    var chatTitlePublisher: CurrentValueSubject<String, Never> = .init("")
    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()

    var hasTicketSelectedPublisher: CurrentValueSubject<Bool, Never> = .init(true)
    var selectedTicket: BetSelectionCellViewModel?

//    var isLoadingOpened: CurrentValueSubject<Bool, Never> = .init(true)
//    var isLoadingResolved: CurrentValueSubject<Bool, Never> = .init(true)
//    var isLoadingWon: CurrentValueSubject<Bool, Never> = .init(true)

    private var openedTicketsPublisher: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    private var resolvedTicketsPublisher: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    private var wonTicketsPublisher: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    private var allTicketsPublisher: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])

    var isLoadingSharedBetPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isLoadingTickets: CurrentValueSubject<Bool, Never> = .init(true)

    var messageSentAction: (() -> Void)?

    var selectedTicketTypeIndexPublisher: CurrentValueSubject<Int?, Never> = .init(nil)

    // MARK: Private Properties
    private var conversationData: ConversationData?
    private var cancellables = Set<AnyCancellable>()

    private var locationsCodesDictionary: [String: String] = [:]

    private let recordsPerPage = 20
    private var openedTicketsPage = 0
    private var resolvedTicketsPage = 0
    private var wonTicketsPage = 0
    private var allTicketsPage = 0

//    var isLoading: AnyPublisher<Bool, Never>

    // MARK: Lifetime and Cycle
    init(conversationData: ConversationData, ticketType: MyTicketsType = .opened) {
        self.conversationData = conversationData

        self.myTicketsTypePublisher.send(ticketType)

//        self.isLoading = Publishers.CombineLatest3(isLoadingResolved, isLoadingOpened, isLoadingWon)
//            .map({ isLoadingResolved, isLoadingOpened, isLoadingWon in
//                return isLoadingResolved || isLoadingOpened || isLoadingWon
//            })
//            .eraseToAnyPublisher()

        self.isTicketsEmptyPublisher = CurrentValueSubject<Bool, Never>.init(false).eraseToAnyPublisher()
        
        self.setupPublishers()
        
        self.setupConversationInfo()

        self.initialLoadMyTickets()
    }

    init(ticketType: MyTicketsType = .opened) {
        self.myTicketsTypePublisher.send(ticketType)

//        self.isLoading = Publishers.CombineLatest3(isLoadingResolved, isLoadingOpened, isLoadingWon)
//            .map({ isLoadingResolved, isLoadingOpened, isLoadingWon in
//                return isLoadingResolved || isLoadingOpened || isLoadingWon
//            })
//            .eraseToAnyPublisher()

        self.isTicketsEmptyPublisher = CurrentValueSubject<Bool, Never>.init(false).eraseToAnyPublisher()

        self.setupPublishers()

        self.setupConversationInfo()

        self.initialLoadMyTickets()
    }

    // MARK: Functions
    private func setupConversationInfo() {

        self.chatTitlePublisher.value = "\(self.conversationData?.name)"

    }

    private func setupPublishers() {

//        self.isTicketsEmptyPublisher = Publishers.CombineLatest4(myTicketsTypePublisher, isLoadingResolved, isLoadingOpened, isLoadingWon)
//            .map { [weak self] myTicketsType, isLoadingResolved, isLoadingOpened, isLoadingWon in
//                switch myTicketsType {
//                case .resolved:
//                    if isLoadingResolved { return false }
//                    return self?.resolvedTicketsPublisher.value.isEmpty ?? false
//                case .opened:
//                    if isLoadingOpened { return false }
//                    return self?.openedTicketsPublisher.value.isEmpty ?? false
//                case .won:
//                    if isLoadingWon { return false }
//                    return self?.wonTicketsPublisher.value.isEmpty ?? false
//                case .all:
//                    if isLoadingWon { return false }
//                    return self?.allTicketsPublisher.value.isEmpty ?? false
//                }
//            }
//            .eraseToAnyPublisher()
        
        self.isTicketsEmptyPublisher = Publishers.CombineLatest(myTicketsTypePublisher, isLoadingTickets)
            .map { [weak self] myTicketsType, isLoadingTickets in
                switch myTicketsType {
//                case .all:
//                    if isLoadingTickets { return false }
//                    return self?.allTicketsPublisher.value.isEmpty ?? false
                case .resolved:
                    if isLoadingTickets { return false }
                    return self?.resolvedTicketsPublisher.value.isEmpty ?? false
                case .opened:
                    if isLoadingTickets { return false }
                    return self?.openedTicketsPublisher.value.isEmpty ?? false
                case .won:
                    if isLoadingTickets { return false }
                    return self?.wonTicketsPublisher.value.isEmpty ?? false
                }
            }
            .eraseToAnyPublisher()

        self.myTicketsTypePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] myTicketsType in
                self?.selectedMyTicketsTypeIndex =  myTicketsType.rawValue

                self?.reloadData()
            }
            .store(in: &cancellables)
    }

    func selectTicketType(atIndex index: Int) {
        self.selectedTicketTypeIndexPublisher.send(index)
    }

    func clearData() {
        self.openedTicketsPublisher.value = []
        self.resolvedTicketsPublisher.value = []
        self.wonTicketsPublisher.value = []
        self.allTicketsPublisher.value = []
        
        self.cachedCellViewModels = [:]
        
        self.reloadData()
    }

    func reloadData() {
        self.dataNeedsReload.send()
    }
    
    func processBettingHistory(betHistoryEntries: [BetHistoryEntry]) {

        switch self.myTicketsTypePublisher.value {
        case .opened:
            if self.openedTicketsPublisher.value.isEmpty {
                self.openedTicketsPublisher.send(betHistoryEntries)
            }
            else {
                var nextTickets = self.openedTicketsPublisher.value
                nextTickets.append(contentsOf: betHistoryEntries)
                self.openedTicketsPublisher.send(nextTickets)
            }
        case .resolved:
            if self.resolvedTicketsPublisher.value.isEmpty {
                self.resolvedTicketsPublisher.send(betHistoryEntries)
            }
            else {
                var nextTickets = self.resolvedTicketsPublisher.value
                nextTickets.append(contentsOf: betHistoryEntries)
                self.resolvedTicketsPublisher.send(nextTickets)
            }
        case .won:
            if self.wonTicketsPublisher.value.isEmpty {
                self.wonTicketsPublisher.send(betHistoryEntries)
            }
            else {
                var nextTickets = self.wonTicketsPublisher.value
                nextTickets.append(contentsOf: betHistoryEntries)
                self.wonTicketsPublisher.send(nextTickets)
            }
//        case .all:
//            if self.allTicketsPublisher.value.isEmpty {
//                self.allTicketsPublisher.send(betHistoryEntries)
//            }
//            else {
//                var nextTickets = self.allTicketsPublisher.value
//                nextTickets.append(contentsOf: betHistoryEntries)
//                self.allTicketsPublisher.send(nextTickets)
//            }
        default:
            ()
        }

        //self.listStatePublisher.send(.loaded)
        self.reloadData()
    }

    func requestNextPage() {
        switch myTicketsTypePublisher.value {
        case .resolved:
            resolvedTicketsPage += 1
            self.loadResolvedTickets(page: resolvedTicketsPage)
        case .opened:
            openedTicketsPage += 1
            self.loadOpenedTickets(page: openedTicketsPage)
        case .won:
            wonTicketsPage += 1
            self.loadWonTickets(page: wonTicketsPage)
//        case .all:
//            allTicketsPage += 1
//            self.loadAllTickets(page: allTicketsPage)
        }
    }

    func refresh() {
        self.clearData()

        self.resolvedTicketsPage = 0
        self.openedTicketsPage = 0
        self.wonTicketsPage = 0
        self.allTicketsPage = 0
        
        switch self.myTicketsTypePublisher.value {
        case .opened:
            self.loadOpenedTickets(page: self.openedTicketsPage)
        case .resolved:
            self.loadResolvedTickets(page: self.resolvedTicketsPage)
        case .won:
            self.loadWonTickets(page: self.wonTicketsPage)
//        case .all:
//            self.loadAllTickets(page: self.allTicketsPage)
        }
    }

    func initialLoadMyTickets() {
        
        switch self.myTicketsTypePublisher.value {
        case .opened:
            self.loadOpenedTickets(page: self.openedTicketsPage)
        case .resolved:
            self.loadResolvedTickets(page: self.resolvedTicketsPage)
        case .won:
            self.loadWonTickets(page: self.wonTicketsPage)
//        case .all:
//            self.loadAllTickets(page: self.allTicketsPage)
        }
    }

    func loadOpenedTickets(page: Int) {
        
        self.isLoadingTickets.send(true)

        Env.servicesProvider.getOpenBetsHistory(pageIndex: page)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    print("loadOpenedTickets error \(error)")
                    self?.clearData()
                }
                self?.isLoadingTickets.send(false)
            } receiveValue: { [weak self] bettingHistory in
                guard let self = self else { return }

                let bettingHistoryResponse = ServiceProviderModelMapper.bettingHistory(fromServiceProviderBettingHistory: bettingHistory)
                
                if let bettingHistoryEntries = bettingHistoryResponse.betList {
                    self.processBettingHistory(betHistoryEntries: bettingHistoryEntries)
                }
                else {
                    self.reloadData()
                }
                
//                self.openedTicketsPublisher.value = bettingHistoryResponse.betList ?? []
//                self.reloadData()
                
            }
            .store(in: &cancellables)
    }

    func loadResolvedTickets(page: Int) {
        self.isLoadingTickets.send(true)
        
        Env.servicesProvider.getResolvedBetsHistory(pageIndex: page)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    print("loadResolvedTickets error \(error)")
                    self?.clearData()
                }
                self?.isLoadingTickets.send(false)
            } receiveValue: { [weak self] bettingHistory in
                guard let self = self else { return }

                let bettingHistoryResponse = ServiceProviderModelMapper.bettingHistory(fromServiceProviderBettingHistory: bettingHistory)
                
                if let bettingHistoryEntries = bettingHistoryResponse.betList {
                    self.processBettingHistory(betHistoryEntries: bettingHistoryEntries)
                }
                else {
                    self.reloadData()
                }
//                self.resolvedTicketsPublisher.value = bettingHistoryResponse.betList ?? []
//                self.reloadData()
                
            }
            .store(in: &cancellables)
    }

    func loadWonTickets(page: Int) {
        
        self.isLoadingTickets.send(true)
        
        Env.servicesProvider.getWonBetsHistory(pageIndex: page)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    print("loadOpenedTickets error \(error)")
                    self?.clearData()
                }
                self?.isLoadingTickets.send(false)
            } receiveValue: { [weak self] bettingHistory in
                guard let self = self else { return }

                let bettingHistoryResponse = ServiceProviderModelMapper.bettingHistory(fromServiceProviderBettingHistory: bettingHistory)
                
                if let bettingHistoryEntries = bettingHistoryResponse.betList {
                    self.processBettingHistory(betHistoryEntries: bettingHistoryEntries)
                }
                else {
                    self.reloadData()
                }
                
//                self.wonTicketsPublisher.value = bettingHistoryResponse.betList ?? []
//                self.reloadData()
                
            }
            .store(in: &cancellables)    }
    
    func loadAllTickets(page: Int) {
        // TODO: ServiceProvider get My Bets
    }

    private func getGroupInitials(text: String) -> String {
        var initials = ""

        for letter in text {
            if letter.isUppercase {
                if initials.count < 2 {
                    initials = "\(initials)\(letter)"
                }
            }
        }

        if initials == "" {
            if let firstChar = text.first {
                initials = "\(firstChar.uppercased())"
            }
        }

        return initials
    }

    func sendMessage(message: String) {

        var selectedBetSelectionCellViewModel: BetSelectionCellViewModel? = nil

        for cellViewModel in self.cachedCellViewModels.values {
            if cellViewModel.isCheckboxSelectedPublisher.value {
                selectedBetSelectionCellViewModel = cellViewModel

            }
        }

        guard
            let viewModelValue = selectedBetSelectionCellViewModel
        else {
            return
        }

    }

    func generateAttachmentString(viewModel: BetSelectionCellViewModel, withToken betShareToken: String) -> [String: AnyObject]? {

        guard let token = Env.gomaNetworkClient.getCurrentToken() else {
            return nil
        }

        let attachment = SharedBetTicketAttachment(id: viewModel.id,
                                                   type: "bet",
                                                   fromUser: "\(token.userId)",
                                                   content: SharedBetTicket(betHistoryEntry: viewModel.ticket,
                                                                            betShareToken: betShareToken))

        if let jsonData = try? JSONEncoder().encode(attachment) {
            let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: AnyObject]
            return dictionary
        }
        else {
            return nil
        }
    }

    func getDefaultDateFormatted(date: Date) -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd-MM-yyyy HH:mm"
        return dateFormatterPrint.string(from: date)
    }

    func checkSelectedTicket(withId id: String) {
        for cellViewModel in self.cachedCellViewModels.values {
            if cellViewModel.id != id {
                cellViewModel.unselectTicket()
            }
        }

        self.selectedTicket = nil

        if let cellViewModel = self.cachedCellViewModels[id] {
            cellViewModel.selectTicket()
            self.selectedTicket = cellViewModel
        }

        self.updateAnySelected()
    }

    func uncheckSelectedTicket(withId id: String) {
        if let cellViewModel = self.cachedCellViewModels[id] {
            cellViewModel.unselectTicket()
        }

        self.selectedTicket = nil

        self.updateAnySelected()
    }

    func updateAnySelected() {
        let anySelected = self.cachedCellViewModels.map { (_, value: BetSelectionCellViewModel) -> Bool in
            return value.isCheckboxSelectedPublisher.value
        }
        .contains(true)
        self.hasTicketSelectedPublisher.send(anySelected)
    }

    func createAttachement() -> [String: AnyObject]? {

        return nil
    }

}

extension ConversationBetSelectionViewModel {

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {
        if self.myTicketsTypePublisher.value == .opened {
            return self.openedTicketsPublisher.value.count
        }
        else if self.myTicketsTypePublisher.value == .resolved {
            return self.resolvedTicketsPublisher.value.count
        }
        else if self.myTicketsTypePublisher.value == .won {
            return self.wonTicketsPublisher.value.count
        }

        return 0
    }

    func sectionTitle(forSectionIndex section: Int) -> String {
        return "Share my tickets"
    }

    func viewModel(forIndex index: Int) -> BetSelectionCellViewModel? {

        if self.myTicketsTypePublisher.value == .opened {
            if let ticket = self.openedTicketsPublisher.value[safe: index] {
                if let cellViewModel = self.cachedCellViewModels[ticket.betId] {
                    return cellViewModel
                }
                else {
                    let cellViewModel = BetSelectionCellViewModel(ticket: ticket)
                    self.cachedCellViewModels[ticket.betId] = cellViewModel
                    return cellViewModel
                }
            }
        }
        else if self.myTicketsTypePublisher.value == .resolved {
            if let ticket = self.resolvedTicketsPublisher.value[safe: index] {
                if let cellViewModel = self.cachedCellViewModels[ticket.betId] {
                    return cellViewModel
                }
                else {
                    let cellViewModel = BetSelectionCellViewModel(ticket: ticket)
                    self.cachedCellViewModels[ticket.betId] = cellViewModel
                    return cellViewModel
                }
            }
        }
        else if self.myTicketsTypePublisher.value == .won {
            if let ticket = self.wonTicketsPublisher.value[safe: index] {
                if let cellViewModel = self.cachedCellViewModels[ticket.betId] {
                    return cellViewModel
                }
                else {
                    let cellViewModel = BetSelectionCellViewModel(ticket: ticket)
                    self.cachedCellViewModels[ticket.betId] = cellViewModel
                    return cellViewModel
                }
            }
        }

        return nil
    }

}
