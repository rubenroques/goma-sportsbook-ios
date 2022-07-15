//
//  BettingHistoryViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/04/2022.
//

import Foundation
import Combine

class BettingHistoryViewModel {

    enum BettingTicketsType {
        case opened
        case resolved
        case won
        case cashout
    }

    enum ListState {
        case loading
        case serverError
        case noUserFoundError
        case empty
        case loaded
    }

    // MARK: - Publishers
    var bettingTicketsType: BettingTicketsType = .opened
    var cachedViewModels: [String: MyTicketCellViewModel] = [:]

    // MARK: - Publishers
    var titlePublisher: CurrentValueSubject<String, Never>
    var listStatePublisher: CurrentValueSubject<ListState, Never> = .init(.loading)
    var bettingTicketsPublisher: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])

    var isTicketsEmptyPublisher: AnyPublisher<Bool, Never>?
    var isTransactionsEmptyPublisher: AnyPublisher<Bool, Never>?

    // MARK: - data
    var resolvedTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    var openedTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    var wonTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    var cashoutTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])

    // MARK: - Private Properties

    private let recordsPerPage = 80

    private var resolvedPage = 0
    private var openedPage = 0
    private var wonPage = 0

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Life Cycle
    init(bettingTicketsType: BettingTicketsType) {

        self.bettingTicketsType = bettingTicketsType

        switch bettingTicketsType {
        case .opened:
            self.titlePublisher = .init("Open")
        case .resolved:
            self.titlePublisher = .init("Resolved")
        case .won:
            self.titlePublisher = .init("Won")
        case .cashout:
            self.titlePublisher = .init("Cashout")
        }

        Env.everyMatrixClient.serviceStatusPublisher
            .sink { serviceStatus in
                if serviceStatus == .connected {
                    self.initialContentLoad()
                }
            }
            .store(in: &cancellables)
    }

    func initialContentLoad() {
        self.listStatePublisher.send(.loading)

        self.cashoutTickets.value = []
        self.resolvedTickets.value = []
        self.openedTickets.value = []
        self.wonTickets.value = []

        switch self.bettingTicketsType {
        case .opened:
            self.loadOpenedTickets(page: 0)
        case .resolved:
            self.loadResolvedTickets(page: 0)
        case .won:
            self.loadWonTickets(page: 0)
        case .cashout:
            self.loadCashoutTickets(page: 0)
        }
    }

    func refreshContent() {
        self.initialContentLoad()
    }

    func loadOpenedTickets(page: Int) {

        self.listStatePublisher.send(.loading)

        let openedRoute = TSRouter.getMyTickets(language: "en",
                                                ticketsType: EveryMatrix.MyTicketsType.opened,
                                                records: recordsPerPage,
                                                page: page)

        Env.everyMatrixClient.manager.getModel(router: openedRoute, decodingType: BetHistoryResponse.self)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let apiError):
                    self?.openedTickets.send([])
                    switch apiError {
                    case .requestError(let value) where value.lowercased().contains("must be logged in to perform this action"):
                        self?.listStatePublisher.send(.noUserFoundError)
                    case .notConnected:
                        self?.listStatePublisher.send(.noUserFoundError)
                    default:
                        self?.listStatePublisher.send(.serverError)
                    }
                case .finished:
                    ()
                }
            },
            receiveValue: { [weak self] betHistoryResponse in
                self?.openedTickets.send(betHistoryResponse.betList ?? [])
                if (betHistoryResponse.betList ?? []).isEmpty {
                    self?.listStatePublisher.send(.empty)
                }
                else {
                    self?.listStatePublisher.send(.loaded)
                }
            })
            .store(in: &cancellables)
    }

    func loadResolvedTickets(page: Int) {

        self.listStatePublisher.send(.loading)

        let openedRoute = TSRouter.getMyTickets(language: "en",
                                                ticketsType: EveryMatrix.MyTicketsType.resolved,
                                                records: recordsPerPage,
                                                page: page)

        Env.everyMatrixClient.manager.getModel(router: openedRoute, decodingType: BetHistoryResponse.self)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let apiError):
                    self?.resolvedTickets.send([])
                    switch apiError {
                    case .requestError(let value) where value.lowercased().contains("must be logged in to perform this action"):
                        self?.listStatePublisher.send(.noUserFoundError)
                    case .notConnected:
                        self?.listStatePublisher.send(.noUserFoundError)
                    default:
                        self?.listStatePublisher.send(.serverError)
                    }
                case .finished:
                    ()
                }
            },
            receiveValue: { [weak self] betHistoryResponse in
                self?.resolvedTickets.send(betHistoryResponse.betList ?? [])
                if (betHistoryResponse.betList ?? []).isEmpty {
                    self?.listStatePublisher.send(.empty)
                }
                else {
                    self?.listStatePublisher.send(.loaded)
                }
            })
            .store(in: &cancellables)
    }

    func loadCashoutTickets(page: Int) {

        self.listStatePublisher.send(.loading)

        let openedRoute = TSRouter.getMyTickets(language: "en",
                                                ticketsType: EveryMatrix.MyTicketsType.resolved,
                                                records: recordsPerPage,
                                                page: page)

        Env.everyMatrixClient.manager.getModel(router: openedRoute, decodingType: BetHistoryResponse.self)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let apiError):
                    self?.cashoutTickets.send([])
                    switch apiError {
                    case .requestError(let value) where value.lowercased().contains("must be logged in to perform this action"):
                        self?.listStatePublisher.send(.noUserFoundError)
                    case .notConnected:
                        self?.listStatePublisher.send(.noUserFoundError)
                    default:
                        self?.listStatePublisher.send(.serverError)
                    }
                case .finished:
                    ()
                }
            },
            receiveValue: { [weak self] betHistoryResponse in
                let cashoutTickets = (betHistoryResponse.betList ?? []).filter { ticket in
                    ticket.status == "CASHED_OUT"
                }
                self?.cashoutTickets.send(cashoutTickets)
                if cashoutTickets.isEmpty {
                    self?.listStatePublisher.send(.empty)
                }
                else {
                    self?.listStatePublisher.send(.loaded)
                }
            })
            .store(in: &cancellables)
    }
    
    func refresh() {
        self.resolvedPage = 0
        self.openedPage = 0
        self.wonPage = 0

        self.initialLoadMyTickets()
    }

    func initialLoadMyTickets() {
        self.loadResolvedTickets(page: 0)
        self.loadOpenedTickets(page: 0)
        self.loadWonTickets(page: 0)
    }
    
    func loadWonTickets(page: Int) {

        self.listStatePublisher.send(.loading)

        let openedRoute = TSRouter.getMyTickets(language: "en",
                                                ticketsType: EveryMatrix.MyTicketsType.won,
                                                records: recordsPerPage,
                                                page: page)

        Env.everyMatrixClient.manager.getModel(router: openedRoute, decodingType: BetHistoryResponse.self)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let apiError):
                    self?.wonTickets.send([])
                    switch apiError {
                    case .requestError(let value) where value.lowercased().contains("must be logged in to perform this action"):
                        self?.listStatePublisher.send(.noUserFoundError)
                    case .notConnected:
                        self?.listStatePublisher.send(.noUserFoundError)
                    default:
                        self?.listStatePublisher.send(.serverError)
                    }
                case .finished:
                    ()
                }
            },
            receiveValue: { [weak self] betHistoryResponse in
                self?.wonTickets.send(betHistoryResponse.betList ?? [])
                if (betHistoryResponse.betList ?? []).isEmpty {
                    self?.listStatePublisher.send(.empty)
                }
                else {
                    self?.listStatePublisher.send(.loaded)
                }
            })
            .store(in: &cancellables)
    }
    
    func viewModel(forIndex index: Int) -> MyTicketCellViewModel? {
        let ticket: BetHistoryEntry?

        switch bettingTicketsType {
        case .resolved:
            ticket = resolvedTickets.value[safe: index] ?? nil
        case .opened:
            ticket = openedTickets.value[safe: index] ?? nil
        default:
            ticket = wonTickets.value[safe: index] ?? nil
        }

        guard let ticket = ticket else {
            return nil
        }

        if let viewModel = cachedViewModels[ticket.betId] {
            return viewModel
        }
        else {
            let viewModel =  MyTicketCellViewModel(ticket: ticket)
            viewModel.requestDataRefreshAction = { [weak self] in
                self?.refresh()
            }
            cachedViewModels[ticket.betId] = viewModel
            return viewModel
        }

    }


}

extension BettingHistoryViewModel {

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows() -> Int {
        switch self.bettingTicketsType {
        case .resolved:
            return resolvedTickets.value.count
        case .opened:
            return openedTickets.value.count
        case .won:
            return wonTickets.value.count
        case .cashout:
            return cashoutTickets.value.count
        }
    }

    func bettingTicketForRow(atIndex index: Int) -> BetHistoryEntry? {
        switch self.bettingTicketsType {
        case .resolved:
            return self.resolvedTickets.value[safe: index]
        case .opened:
            return self.openedTickets.value[safe: index]
        case .won:
            return self.wonTickets.value[safe: index]
        case .cashout:
            return self.cashoutTickets.value[safe: index]
        }
    }

}
