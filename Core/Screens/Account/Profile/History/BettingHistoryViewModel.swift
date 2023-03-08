//
//  BettingHistoryViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/04/2022.
//

import Foundation
import Combine
import ServicesProvider

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
    var filterApplied: FilterHistoryViewModel.FilterValue = .past30Days
    
    // MARK: - Publishers
    var titlePublisher: CurrentValueSubject<String, Never>
    var listStatePublisher: CurrentValueSubject<ListState, Never> = .init(.loading)
    var bettingTicketsPublisher: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])

    var isTicketsEmptyPublisher: AnyPublisher<Bool, Never>?
    var isTransactionsEmptyPublisher: AnyPublisher<Bool, Never>?
    
    var startDatePublisher: CurrentValueSubject<Date, Never> = .init(Date())
    var endDatePublisher: CurrentValueSubject<Date, Never> = .init(Date())
    
    // MARK: - data
    var resolvedTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    var openedTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    var wonTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    var cashoutTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])

    private var matchesPublisher: AnyCancellable?
    private var matchesRegister: EndpointPublisherIdentifiable?
    
    // MARK: - Private Properties

    private var recordsPerPage = 10
    
    private var ticketsHasNextPage = true

    private var resolvedPage = 0
    private var openedPage = 0
    private var wonPage = 0
    private var cashoutPage = 0

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Life Cycle
    init(bettingTicketsType: BettingTicketsType, filterApplied: FilterHistoryViewModel.FilterValue) {

        self.bettingTicketsType = bettingTicketsType
        self.filterApplied = filterApplied
        
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

        self.calculateDate(filterApplied: filterApplied)
   
//        Env.everyMatrixClient.serviceStatusPublisher
//            .sink { serviceStatus in
//                if serviceStatus == .connected {
//                    self.initialContentLoad()
//                }
//            }
//            .store(in: &cancellables)

        self.initialContentLoad()
        
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
        self.ticketsHasNextPage = true
        self.calculateDate(filterApplied: filterApplied)
        self.initialContentLoad()
    }

    func calculateDate(filterApplied: FilterHistoryViewModel.FilterValue) {
        
        self.endDatePublisher.send(Date())

        switch filterApplied {
        case .dateRange(let startTime, let endTime):
            self.startDatePublisher.send(startTime)
            self.endDatePublisher.send(endTime)
        case .past30Days:
            if let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) {
                self.startDatePublisher.send(startDate)
            }
        default :
            if let startDate = Calendar.current.date(byAdding: .day, value: -90, to: Date()) {
                self.startDatePublisher.send(startDate)
            }
        }
    }
    
    func shouldShowLoadingCell() -> Bool {
        switch self.bettingTicketsType {
        case .opened:
            return self.openedTickets.value.isNotEmpty && ticketsHasNextPage
        case .resolved:
            return self.resolvedTickets.value.isNotEmpty && ticketsHasNextPage
        case .won:
            return self.wonTickets.value.isNotEmpty && ticketsHasNextPage
        case .cashout:
            return self.cashoutTickets.value.isNotEmpty && ticketsHasNextPage
        }
        
    }
    func convertDateToString(date: Date) -> String {
        let auxDate = "\(date)"
        let dateSplited = auxDate.split(separator: " ")
        return "\(dateSplited[0])"
    }

    func processBettingHistory(betHistoryEntries: [BetHistoryEntry]) {

        switch self.bettingTicketsType {
        case .opened:
            if self.openedTickets.value.isEmpty {
                self.openedTickets.send(betHistoryEntries)
            }
            else {
                var nextTickets = self.openedTickets.value
                nextTickets.append(contentsOf: betHistoryEntries)
                self.openedTickets.send(nextTickets)
            }
        case .resolved:
            if self.resolvedTickets.value.isEmpty {
                self.resolvedTickets.send(betHistoryEntries)
            }
            else {
                var nextTickets = self.resolvedTickets.value
                nextTickets.append(contentsOf: betHistoryEntries)
                self.resolvedTickets.send(nextTickets)
            }
        case .won:
            if self.wonTickets.value.isEmpty {
                self.wonTickets.send(betHistoryEntries)
            }
            else {
                var nextTickets = self.wonTickets.value
                nextTickets.append(contentsOf: betHistoryEntries)
                self.wonTickets.send(nextTickets)
            }
        default: ()
        }

        self.listStatePublisher.send(.loaded)

    }

    func loadOpenedTickets(page: Int, isNextPage: Bool = false) {

        if !isNextPage {
            self.listStatePublisher.send(.loading)
        }

        Env.servicesProvider.getOpenBetsHistory(pageIndex: self.openedPage)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("BETTING OPEN HISTORY ERROR: \(error)")
                    self?.listStatePublisher.send(.serverError)

                }
            }, receiveValue: { [weak self] bettingHistory in

                guard let self = self else { return }

                let bettingHistoryResponse = ServiceProviderModelMapper.bettingHistory(fromServiceProviderBettingHistory: bettingHistory)

                if let bettingHistoryEntries = bettingHistoryResponse.betList {

                    if bettingHistoryEntries.isNotEmpty {

                        self.processBettingHistory(betHistoryEntries: bettingHistoryEntries)

                    }
                    else {
                        self.ticketsHasNextPage = false
                        if self.openedTickets.value.isEmpty {
                            self.listStatePublisher.send(.empty)
                        }
                        else {
                            self.listStatePublisher.send(.loaded)
                        }
                    }
                }
            })
            .store(in: &cancellables)

/*
        self.listStatePublisher.send(.loading)

        let openedRoute = TSRouter.getMyTickets(language: "en",
                                                ticketsType: EveryMatrix.MyTicketsType.opened,
                                                records: recordsPerPage,
                                                page: page,
                                                startDate: convertDateToString(date: self.startDatePublisher.value),
                                                endDate: convertDateToString(date: self.endDatePublisher.value))
        
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
                guard let self = self else {return}
                let betHistory = betHistoryResponse

                if self.openedTickets.value.isEmpty {
                    self.openedTickets.send(betHistoryResponse.betList ?? [])

                    if (betHistoryResponse.betList ?? []).isEmpty {
                        self.listStatePublisher.send(.empty)
                    }
                    else {
                        self.listStatePublisher.send(.loaded)
                    }

                    if let betHistory = betHistoryResponse.betList {
                        if betHistory.count < self.recordsPerPage {
                            self.ticketsHasNextPage = false
                        }
                    }
                }
                else {
                    var newOpenTickets = self.openedTickets.value
                    newOpenTickets.append(contentsOf: betHistoryResponse.betList ?? [])

                    self.openedTickets.send(newOpenTickets)

                    self.listStatePublisher.send(.loaded)

                    if self.openedTickets.value.count < self.recordsPerPage * (self.openedPage + 1) {
                        self.ticketsHasNextPage = false
                    }
                    else {
                        self.ticketsHasNextPage = true
                    }
                }

            })
            .store(in: &cancellables)
        */
    }

    func loadResolvedTickets(page: Int, isNextPage: Bool = false) {

        if !isNextPage {
            self.listStatePublisher.send(.loading)
        }

        Env.servicesProvider.getResolvedBetsHistory(pageIndex: page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("BETTING RESOLVED HISTORY ERROR: \(error)")
                    self?.listStatePublisher.send(.serverError)

                }
            }, receiveValue: { [weak self] bettingHistory in

                guard let self = self else { return }

                let bettingHistoryResponse = ServiceProviderModelMapper.bettingHistory(fromServiceProviderBettingHistory: bettingHistory)

                if let bettingHistoryEntries = bettingHistoryResponse.betList {

                    if bettingHistoryEntries.isNotEmpty {

                        self.processBettingHistory(betHistoryEntries: bettingHistoryEntries)

                    }
                    else {
                        self.ticketsHasNextPage = false
                        if self.resolvedTickets.value.isEmpty {
                            self.listStatePublisher.send(.empty)
                        }
                        else {
                            self.listStatePublisher.send(.loaded)
                        }
                    }
                }
            })
            .store(in: &cancellables)

        /*let openedRoute = TSRouter.getMyTickets(language: "en",
                                                ticketsType: EveryMatrix.MyTicketsType.resolved,
                                                records: recordsPerPage,
                                                page: page,
                                                startDate: convertDateToString(date: self.startDatePublisher.value),
                                                endDate: convertDateToString(date: self.endDatePublisher.value))

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
                guard let self = self else {return}

                if self.resolvedTickets.value.isEmpty {
                    self.resolvedTickets.send(betHistoryResponse.betList ?? [])

                    if (betHistoryResponse.betList ?? []).isEmpty {
                        self.listStatePublisher.send(.empty)
                    }
                    else {
                        self.listStatePublisher.send(.loaded)
                    }

                    if let betHistory = betHistoryResponse.betList {
                        if betHistory.count < self.recordsPerPage {
                            self.ticketsHasNextPage = false
                        }
                    }
                }
                else {
                    var newResolvedTickets = self.resolvedTickets.value
                    newResolvedTickets.append(contentsOf: betHistoryResponse.betList ?? [])

                    self.resolvedTickets.send(newResolvedTickets)

                    self.listStatePublisher.send(.loaded)

                    if self.resolvedTickets.value.count < self.recordsPerPage * (self.resolvedPage + 1) {
                        self.ticketsHasNextPage = false
                    }
                    else {
                        self.ticketsHasNextPage = true
                    }
                }

            })
            .store(in: &cancellables)
        */
    }

    func loadWonTickets(page: Int, isNextPage: Bool = false) {

        if !isNextPage {
            self.listStatePublisher.send(.loading)
        }

        Env.servicesProvider.getWonBetsHistory(pageIndex: page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("BETTING WON HISTORY ERROR: \(error)")
                    self?.listStatePublisher.send(.serverError)

                }
            }, receiveValue: { [weak self] bettingHistory in

                guard let self = self else { return }

                let bettingHistoryResponse = ServiceProviderModelMapper.bettingHistory(fromServiceProviderBettingHistory: bettingHistory)

                if let bettingHistoryEntries = bettingHistoryResponse.betList {

                    if bettingHistoryEntries.isNotEmpty {

                        let filteredWonBettingHistoryEntries = bettingHistoryEntries.filter({
                            $0.status == "won"
                        })

                        if filteredWonBettingHistoryEntries.isNotEmpty {
                            self.processBettingHistory(betHistoryEntries: filteredWonBettingHistoryEntries)
                        }
                        else {
                            self.requestNextPage()
                        }

                    }
                    else {
                        self.ticketsHasNextPage = false
                        if self.wonTickets.value.isEmpty {
                            self.listStatePublisher.send(.empty)
                        }
                        else {
                            self.listStatePublisher.send(.loaded)
                        }
                    }
                }
            })
            .store(in: &cancellables)

        /*let openedRoute = TSRouter.getMyTickets(language: "en",
                                                ticketsType: EveryMatrix.MyTicketsType.won,
                                                records: recordsPerPage,
                                                page: page,
                                                startDate: convertDateToString(date: self.startDatePublisher.value),
                                                endDate: convertDateToString(date: self.endDatePublisher.value))

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
//                self?.wonTickets.send(betHistoryResponse.betList ?? [])
//                if (betHistoryResponse.betList ?? []).isEmpty {
//                    self?.listStatePublisher.send(.empty)
//                }
//                else {
//                    self?.listStatePublisher.send(.loaded)
//                }
                guard let self = self else {return}

                if self.wonTickets.value.isEmpty {
                    self.wonTickets.send(betHistoryResponse.betList ?? [])

                    if (betHistoryResponse.betList ?? []).isEmpty {
                        self.listStatePublisher.send(.empty)
                    }
                    else {
                        self.listStatePublisher.send(.loaded)
                    }

                    if let betHistory = betHistoryResponse.betList {
                        if betHistory.count < self.recordsPerPage {
                            self.ticketsHasNextPage = false
                        }
                    }
                }
                else {
                    var newWonTickets = self.wonTickets.value
                    newWonTickets.append(contentsOf: betHistoryResponse.betList ?? [])

                    self.wonTickets.send(newWonTickets)

                    self.listStatePublisher.send(.loaded)

                    if self.wonTickets.value.count < self.recordsPerPage * (self.wonPage + 1) {
                        self.ticketsHasNextPage = false
                    }
                    else {
                        self.ticketsHasNextPage = true
                    }
                }
            })
            .store(in: &cancellables)
        */
    }
    func loadCashoutTickets(page: Int, isNextPage: Bool = false) {

        if !isNextPage {
            self.listStatePublisher.send(.loading)
        }

        Env.servicesProvider.getBettingHistory(pageIndex: page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("BETTING CASHOUT HISTORY ERROR: \(error)")
                    self?.listStatePublisher.send(.serverError)

                }
            }, receiveValue: { [weak self] bettingHistory in

                print("BETTING CASHOUT HISTORY: \(bettingHistory)")
                self?.listStatePublisher.send(.empty)
            })
            .store(in: &cancellables)

        /*let openedRoute = TSRouter.getMyTickets(language: "en",
                                                ticketsType: EveryMatrix.MyTicketsType.resolved,
                                                records: recordsPerPage,
                                                page: page,
                                                startDate: convertDateToString(date: self.startDatePublisher.value),
                                                endDate: convertDateToString(date: self.endDatePublisher.value))

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
                guard let self = self else {return}

                let cashoutTickets = (betHistoryResponse.betList ?? []).filter { ticket in
                    ticket.status == "CASHED_OUT"
                }

                if self.cashoutTickets.value.isEmpty {

                    self.cashoutTickets.send(cashoutTickets)

                    if cashoutTickets.isEmpty {
                        self.listStatePublisher.send(.empty)
                    }
                    else {
                        self.listStatePublisher.send(.loaded)
                    }

                    if cashoutTickets.count < self.recordsPerPage {
                        self.ticketsHasNextPage = false
                    }

                }
                else {
                    var newCashoutTickets = self.cashoutTickets.value
                    newCashoutTickets.append(contentsOf: cashoutTickets)

                    self.cashoutTickets.send(newCashoutTickets)

                    self.listStatePublisher.send(.loaded)

                    if self.cashoutTickets.value.count < self.recordsPerPage * (self.cashoutPage + 1) {
                        self.ticketsHasNextPage = false
                    }
                    else {
                        self.ticketsHasNextPage = true
                    }
                }
            })
            .store(in: &cancellables)
 */
    }
    
    func refresh() {
        self.resolvedPage = 1
        self.openedPage = 1
        self.wonPage = 1
        self.cashoutPage = 1

        self.initialLoadMyTickets()
    }

    func initialLoadMyTickets() {
        self.loadResolvedTickets(page: 1)
        self.loadOpenedTickets(page: 1)
        self.loadWonTickets(page: 1)
        self.loadCashoutTickets(page: 1)
    }
    
    func requestNextPage() {
        
        switch bettingTicketsType {
        case .opened:
//            if self.openedTickets.value.count < self.recordsPerPage * (self.openedPage + 1) {
//                self.ticketsHasNextPage = false
//                return
//            }
            openedPage += 1
            self.loadOpenedTickets(page: openedPage, isNextPage: true)
        case .resolved:
//            if self.resolvedTickets.value.count < self.recordsPerPage * (self.resolvedPage + 1) {
//                self.ticketsHasNextPage = false
//                return
//            }
            resolvedPage += 1
            self.loadResolvedTickets(page: resolvedPage, isNextPage: true)
        case .won:
//            if self.wonTickets.value.count < self.recordsPerPage * (self.wonPage + 1) {
//                self.ticketsHasNextPage = false
//                return
//            }
            wonPage += 1
            self.loadWonTickets(page: wonPage, isNextPage: true)
        case .cashout:
//            if self.cashoutTickets.value.count < self.recordsPerPage * (self.cashoutPage + 1) {
//                self.ticketsHasNextPage = false
//                return
//            }
            cashoutPage += 1
            self.loadCashoutTickets(page: cashoutPage)
        }
    }
    
    private func resetPageCount() {
        self.recordsPerPage = 10
        self.ticketsHasNextPage = true
    }

/*
    private func storeAggregatorProcessor(_ aggregator: EveryMatrix.Aggregator) {
        self.store.processAggregator(aggregator, withListType: .popularEvents,
                                                 shouldClear: true)

        let matches = self.store.matchesForListType(.popularEvents)
        if matches.count < self.matchesCount * self.matchesPage {
            self.ticketsHasNextPage = false
        }

        self.matches = matches

        self.isLoading.send(false)

        self.refreshPublisher.send()
    }

    private func updateWithAggregatorProcessor(_ aggregator: EveryMatrix.Aggregator) {
        self.store.processContentUpdateAggregator(aggregator)
    }
*/
    
    func viewModel(forIndex index: Int) -> MyTicketCellViewModel? {
        let ticket: BetHistoryEntry?

        switch bettingTicketsType {
        case .resolved:
            ticket = resolvedTickets.value[safe: index] ?? nil
        case .opened:
            ticket = openedTickets.value[safe: index] ?? nil
        case .won:
            ticket = wonTickets.value[safe: index] ?? nil
        case .cashout:
            ticket = cashoutTickets.value[safe: index] ?? nil
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
        return 2
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
