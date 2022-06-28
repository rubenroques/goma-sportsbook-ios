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

    var isLoadingOpened: CurrentValueSubject<Bool, Never> = .init(true)
    var isLoadingResolved: CurrentValueSubject<Bool, Never> = .init(true)
    var isLoadingWon: CurrentValueSubject<Bool, Never> = .init(true)

    var openedTicketsPublisher: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    private var resolvedTicketsPublisher: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    private var wonTicketsPublisher: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])

    var isLoadingSharedBetPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    var messageSentAction: (() -> Void)?

    var selectedTicketTypeIndexPublisher: CurrentValueSubject<Int?, Never> = .init(nil)

    // MARK: Private Properties
    private var conversationData: ConversationData?
    private var cancellables = Set<AnyCancellable>()

    private var locationsCodesDictionary: [String: String] = [:]

    private let recordsPerPage = 30
    private var openedTicketsPage = 0
    private var resolvedTicketsPage = 0
    private var wonTicketsPage = 0

    var isLoading: AnyPublisher<Bool, Never>

    // MARK: Lifetime and Cycle
    init(conversationData: ConversationData, ticketType: MyTicketsType = .opened) {
        self.conversationData = conversationData

        self.myTicketsTypePublisher.send(ticketType)

        self.isLoading = Publishers.CombineLatest3(isLoadingResolved, isLoadingOpened, isLoadingWon)
            .map({ isLoadingResolved, isLoadingOpened, isLoadingWon in
                return isLoadingResolved || isLoadingOpened || isLoadingWon
            })
            .eraseToAnyPublisher()

        self.isTicketsEmptyPublisher = CurrentValueSubject<Bool, Never>.init(false).eraseToAnyPublisher()

        self.setupPublishers()
        
        self.setupConversationInfo()

        self.loadLocations()

        self.initialLoadMyTickets()
    }

    init(ticketType: MyTicketsType = .opened) {
        self.myTicketsTypePublisher.send(ticketType)

        self.isLoading = Publishers.CombineLatest3(isLoadingResolved, isLoadingOpened, isLoadingWon)
            .map({ isLoadingResolved, isLoadingOpened, isLoadingWon in
                return isLoadingResolved || isLoadingOpened || isLoadingWon
            })
            .eraseToAnyPublisher()

        self.isTicketsEmptyPublisher = CurrentValueSubject<Bool, Never>.init(false).eraseToAnyPublisher()

        self.setupPublishers()

        self.setupConversationInfo()

        self.loadLocations()

        self.initialLoadMyTickets()
    }

    // MARK: Functions
    private func setupConversationInfo() {

        self.chatTitlePublisher.value = "\(self.conversationData?.name)"

    }

    private func setupPublishers() {

        self.isTicketsEmptyPublisher = Publishers.CombineLatest4(myTicketsTypePublisher, isLoadingResolved, isLoadingOpened, isLoadingWon)
            .map { [weak self] myTicketsType, isLoadingResolved, isLoadingOpened, isLoadingWon in
                switch myTicketsType {
                case .resolved:
                    if isLoadingResolved { return false }
                    return self?.resolvedTicketsPublisher.value.isEmpty ?? false
                case .opened:
                    if isLoadingOpened { return false }
                    return self?.openedTicketsPublisher.value.isEmpty ?? false
                case .won:
                    if isLoadingWon { return false }
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
        self.reloadData()
    }

    func reloadData() {
        self.dataNeedsReload.send()
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
        }
    }

    func refresh() {
        self.openedTicketsPage = 0
        self.loadOpenedTickets(page: 0)
    }

    func loadLocations() {
        let resolvedRoute = TSRouter.getLocations(language: "en", sortByPopularity: false)
        Env.everyMatrixClient.manager.getModel(router: resolvedRoute, decodingType: EveryMatrixSocketResponse<EveryMatrix.Location>.self)
            .sink(receiveCompletion: { _ in

            },
            receiveValue: { [weak self] response in
                self?.locationsCodesDictionary = [:]
                (response.records ?? []).forEach { location in
                    if let code = location.code {
                        self?.locationsCodesDictionary[location.id] = code
                    }
                }
            })
            .store(in: &cancellables)
    }

    func initialLoadMyTickets() {
        self.loadOpenedTickets(page: 0)
        self.loadResolvedTickets(page: 0)
        self.loadWonTickets(page: 0)
    }

    func loadOpenedTickets(page: Int) {

        self.isLoadingOpened.send(true)

        let openedRoute = TSRouter.getMyTickets(language: "en", ticketsType: EveryMatrix.MyTicketsType.opened, records: recordsPerPage, page: page)
        Env.everyMatrixClient.manager.getModel(router: openedRoute, decodingType: BetHistoryResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let apiError):
                    switch apiError {
                    case .requestError(let value) where value.lowercased().contains("you must be logged in to perform this action"):
                        self?.clearData()
                    case .notConnected:
                        self?.clearData()
                    default:
                        ()
                    }
                case .finished:
                    ()
                }
                self?.isLoadingOpened.send(false)
            },
            receiveValue: { [weak self] betHistoryResponse in
                self?.openedTicketsPublisher.value = betHistoryResponse.betList ?? []
                self?.reloadData()
            })
            .store(in: &cancellables)
    }

    func loadResolvedTickets(page: Int) {

        self.isLoadingResolved.send(true)

        let resolvedRoute = TSRouter.getMyTickets(language: "en", ticketsType: EveryMatrix.MyTicketsType.resolved, records: recordsPerPage, page: page)
        Env.everyMatrixClient.manager.getModel(router: resolvedRoute, decodingType: BetHistoryResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let apiError):
                    switch apiError {
                    case .requestError(let value) where value.lowercased().contains("you must be logged in to perform this action"):
                        self?.clearData()
                    case .notConnected:
                        self?.clearData()
                    default:
                        ()
                    }
                case .finished:
                    ()
                }
                self?.isLoadingResolved.send(false)
            },
            receiveValue: { [weak self] betHistoryResponse in
                self?.resolvedTicketsPublisher.value = betHistoryResponse.betList ?? []
                if case .resolved = self?.myTicketsTypePublisher.value {
                    self?.reloadData()
                }
            })
            .store(in: &cancellables)
    }

    func loadWonTickets(page: Int) {

        self.isLoadingWon.send(true)

        let wonRoute = TSRouter.getMyTickets(language: "en", ticketsType: EveryMatrix.MyTicketsType.won, records: recordsPerPage, page: page)
        Env.everyMatrixClient.manager.getModel(router: wonRoute, decodingType: BetHistoryResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let apiError):
                    switch apiError {
                    case .requestError(let value) where value.lowercased().contains("you must be logged in to perform this action"):
                        self?.clearData()
                    case .notConnected:
                        self?.clearData()
                    default:
                        ()
                    }
                case .finished:
                    ()
                }
                self?.isLoadingWon.send(false)
            },
            receiveValue: { [weak self] betHistoryResponse in
                self?.wonTicketsPublisher.value = betHistoryResponse.betList ?? []
                if case .won = self?.myTicketsTypePublisher.value {
                    self?.reloadData()
                }
            })
            .store(in: &cancellables)

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

        self.isLoadingSharedBetPublisher.send(true)

        let betTokenRoute = TSRouter.getSharedBetTokens(betId: viewModelValue.id)

        Env.everyMatrixClient.manager.getModel(router: betTokenRoute, decodingType: SharedBetToken.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    self?.isLoadingSharedBetPublisher.send(false)
                case .finished:
                    ()
                }
            },
            receiveValue: { [weak self] betToken in
                guard let self = self else { return }

                let attachment = self.generateAttachmentString(viewModel: viewModelValue,
                                                               withToken: betToken.sharedBetTokens.betTokenWithAllInfo)

                Env.gomaSocialClient.sendMessage(chatroomId: self.conversationData?.id ?? 0,
                                                 message: message,
                                                 attachment: attachment)
  
                self.isLoadingSharedBetPublisher.send(false)
                self.messageSentAction?()
            })
            .store(in: &cancellables)

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
