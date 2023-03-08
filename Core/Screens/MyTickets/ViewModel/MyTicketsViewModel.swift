//
//  MyTicketsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 17/12/2021.
//

import Foundation
import UIKit
import Combine

enum MyTicketsType: Int {
    case opened = 0
    case resolved = 1
    case won = 2
}

enum ListState {
    case loading
    case serverError
    case noUserFoundError
    case empty
    case loaded
}

class MyTicketsViewModel: NSObject {

    private var selectedMyTicketsTypeIndex: Int = 0
    var myTicketsTypePublisher: CurrentValueSubject<MyTicketsType, Never> = .init(.opened)
    var isTicketsEmptyPublisher: AnyPublisher<Bool, Never>
    var listStatePublisher: CurrentValueSubject<ListState, Never> = .init(.loading)
    
    var clickedCellSnapshot: UIImage?
    var clickedBetId: String?
    var clickedBetStatus: String?
    var clickedBetTokenPublisher: CurrentValueSubject<String, Never> = .init("")
    var clickedBetHistory: BetHistoryEntry?
    
    var reloadTableViewAction: (() -> Void)?
    var redrawTableViewAction: (() -> Void)?
    var tappedMatchDetail: ((String) -> Void)?
    var requestShareActivityView: ((UIImage, String, String) -> Void)?

    private var matchDetailsDictionary: [String: Match] = [:]

    private var resolvedMyTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    private var openedMyTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    private var wonMyTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])

    var isLoadingTickets: CurrentValueSubject<Bool, Never> = .init(true)
    private var locationsCodesDictionary: [String: String] = [:]
    
    private let recordsPerPage = 10
    
    private var resolvedPage = 0
    private var openedPage = 0
    private var wonPage = 0
    
    private var hasNextPage = true

    // Cached view models
    var cachedViewModels: [String: MyTicketCellViewModel] = [:]
    //
    private var cancellables = Set<AnyCancellable>()

    private var highlightTicket: String?

    init(myTicketType: MyTicketsType = .opened, highlightTicket: String? = nil) {

        self.myTicketsTypePublisher.send(myTicketType)
        self.highlightTicket = highlightTicket

        self.isTicketsEmptyPublisher = CurrentValueSubject<Bool, Never>.init(false).eraseToAnyPublisher()

        super.init()

        self.isTicketsEmptyPublisher = Publishers.CombineLatest(myTicketsTypePublisher, isLoadingTickets)
            .map { [weak self] myTicketsType, isLoadingTickets in
                switch myTicketsType {
                case .resolved:
                    if isLoadingTickets { return false }
                    return self?.resolvedMyTickets.value.isEmpty ?? false
                case .opened:
                    if isLoadingTickets { return false }
                    return self?.openedMyTickets.value.isEmpty ?? false
                case .won:
                    if isLoadingTickets { return false }
                    return self?.wonMyTickets.value.isEmpty ?? false
                }
            }
            .eraseToAnyPublisher()

        self.myTicketsTypePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] myTicketsType in
                self?.selectedMyTicketsTypeIndex =  myTicketsType.rawValue

                self?.reloadTableView()
            }
            .store(in: &cancellables)

        Env.betslipManager.newBetsPlacedPublisher
            .delay(for: 0.8, scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.refresh()
            }
            .store(in: &cancellables)

        Env.userSessionStore.userSessionStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self]  userSessionStatus in
                switch userSessionStatus {
                case .logged:
                    self?.refresh()
                case .anonymous:
                    self?.clearData()
                }
            }
            .store(in: &cancellables)

    }

    deinit {
        print("MyTicketsViewModel deinit")
    }

    func setMyTicketsType(_ type: MyTicketsType) {
        self.myTicketsTypePublisher.value = type
    }

    func isTicketsTypeSelected(forIndex index: Int) -> Bool {
        return index == selectedMyTicketsTypeIndex
    }

    //
    func clearData() {
        self.resolvedMyTickets.value = []
        self.openedMyTickets.value = []
        self.wonMyTickets.value = []

        self.reloadTableView()
    }

    func processBettingHistory(betHistoryEntries: [BetHistoryEntry]) {

        switch self.myTicketsTypePublisher.value {
        case .opened:
            if self.openedMyTickets.value.isEmpty {
                self.openedMyTickets.send(betHistoryEntries)
            }
            else {
                var nextTickets = self.openedMyTickets.value
                nextTickets.append(contentsOf: betHistoryEntries)
                self.openedMyTickets.send(nextTickets)
            }
        case .resolved:
            if self.resolvedMyTickets.value.isEmpty {
                self.resolvedMyTickets.send(betHistoryEntries)
            }
            else {
                var nextTickets = self.resolvedMyTickets.value
                nextTickets.append(contentsOf: betHistoryEntries)
                self.resolvedMyTickets.send(nextTickets)
            }
        case .won:
            if self.wonMyTickets.value.isEmpty {
                self.wonMyTickets.send(betHistoryEntries)
            }
            else {
                var nextTickets = self.wonMyTickets.value
                nextTickets.append(contentsOf: betHistoryEntries)
                self.wonMyTickets.send(nextTickets)
            }
        default: ()
        }

        self.listStatePublisher.send(.loaded)

    }

    func loadResolvedTickets(page: Int, isNextPage: Bool = false) {

        if !isNextPage {
            self.isLoadingTickets.send(true)
        }

        Env.servicesProvider.getResolvedBetsHistory(pageIndex: page)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.clearData()
                }
                self?.isLoadingTickets.send(false)
            } receiveValue: { [weak self] bettingHistory in
//                let betHistoryEntries = ServiceProviderModelMapper.bettingHistory(fromServiceProviderBettingHistory: bettingHistory).betList ?? []
//                self.resolvedMyTickets.send(betHistoryEntries)
//                if betHistoryEntries.isEmpty {
//                    self.listStatePublisher.send(.empty)
//                }
//                else {
//                    self.listStatePublisher.send(.loaded)
//                }

                guard let self = self else { return }

                let bettingHistoryResponse = ServiceProviderModelMapper.bettingHistory(fromServiceProviderBettingHistory: bettingHistory)

                if let bettingHistoryEntries = bettingHistoryResponse.betList {

                    if bettingHistoryEntries.isNotEmpty {

                        self.processBettingHistory(betHistoryEntries: bettingHistoryEntries)

                    }
                    else {
                        self.hasNextPage = false
                        if self.resolvedMyTickets.value.isEmpty {
                            self.listStatePublisher.send(.empty)
                        }
                        else {
                            self.listStatePublisher.send(.loaded)
                        }
                    }
                }
            }
            .store(in: &cancellables)
//
//
//        let resolvedRoute = TSRouter.getMyTickets(language: "en", ticketsType: EveryMatrix.MyTicketsType.resolved, records: recordsPerPage, page: page)
//        Env.everyMatrixClient.manager.getModel(router: resolvedRoute, decodingType: BetHistoryResponse.self)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure(let apiError):
//                    switch apiError {
//                    case .requestError(let value) where value.lowercased().contains("you must be logged in to perform this action"):
//                        self?.clearData()
//                    case .notConnected:
//                        self?.clearData()
//                    default:
//                        ()
//                    }
//                case .finished:
//                    ()
//                }
//                self?.isLoadingTickets.send(false)
//            },
//            receiveValue: { [weak self] betHistoryResponse in
//                guard let self = self else {return}
//
//                if self.resolvedMyTickets.value.isEmpty {
//                    self.resolvedMyTickets.send(betHistoryResponse.betList ?? [])
//
//                    if (betHistoryResponse.betList ?? []).isEmpty {
//                        self.listStatePublisher.send(.empty)
//                    }
//                    else {
//                        self.listStatePublisher.send(.loaded)
//                    }
//
//                    if let betHistory = betHistoryResponse.betList {
//                        if betHistory.count < self.recordsPerPage {
//                            self.hasNextPage = false
//                        }
//                    }
//                }
//                else {
//                    var newResolvedTickets = self.resolvedMyTickets.value
//                    newResolvedTickets.append(contentsOf: betHistoryResponse.betList ?? [])
//
//                    self.resolvedMyTickets.send(newResolvedTickets)
//
//                    self.listStatePublisher.send(.loaded)
//
//                    if self.resolvedMyTickets.value.count < self.recordsPerPage * (self.resolvedPage + 1) {
//                        self.hasNextPage = false
//                    }
//                    else {
//                        self.hasNextPage = true
//                    }
//                }
//            })
//            .store(in: &cancellables)
    }

    func loadOpenedTickets(page: Int, isNextPage: Bool = false) {

        if !isNextPage {
            self.isLoadingTickets.send(true)
        }

        Env.servicesProvider.getOpenBetsHistory(pageIndex: page)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    Logger.log("loadOpenedTickets error \(error)")
                    self?.clearData()
                }
                self?.isLoadingTickets.send(false)
            } receiveValue: { [weak self] bettingHistory in
                guard let self = self else { return }

                let bettingHistoryResponse = ServiceProviderModelMapper.bettingHistory(fromServiceProviderBettingHistory: bettingHistory)

                if let bettingHistoryEntries = bettingHistoryResponse.betList {

                    if bettingHistoryEntries.isNotEmpty {

                        self.processBettingHistory(betHistoryEntries: bettingHistoryEntries)

                    }
                    else {
                        self.hasNextPage = false
                        if self.openedMyTickets.value.isEmpty {
                            self.listStatePublisher.send(.empty)
                        }
                        else {
                            self.listStatePublisher.send(.loaded)
                        }
                    }
                }
            }
            .store(in: &cancellables)

//        let openedRoute = TSRouter.getMyTickets(language: "en", ticketsType: EveryMatrix.MyTicketsType.opened, records: recordsPerPage, page: page)
//        Env.everyMatrixClient.manager.getModel(router: openedRoute, decodingType: BetHistoryResponse.self)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure(let apiError):
//                    switch apiError {
//                    case .requestError(let value) where value.lowercased().contains("you must be logged in to perform this action"):
//                        self?.clearData()
//                    case .notConnected:
//                        self?.clearData()
//                    default:
//                        ()
//                    }
//                case .finished:
//                    ()
//                }
//                self?.isLoadingTickets.send(false)
//            },
//            receiveValue: { [weak self] betHistoryResponse in
//                guard let self = self else {return}
//
//                if self.openedMyTickets.value.isEmpty {
//                    self.openedMyTickets.send(betHistoryResponse.betList ?? [])
//
//                    if (betHistoryResponse.betList ?? []).isEmpty {
//                        self.listStatePublisher.send(.empty)
//                    }
//                    else {
//                        self.listStatePublisher.send(.loaded)
//                    }
//
//                    if let betHistory = betHistoryResponse.betList {
//                        if betHistory.count < self.recordsPerPage {
//                            self.hasNextPage = false
//                        }
//                    }
//                }
//                else {
//                    var newOpenedTickets = self.openedMyTickets.value
//                    newOpenedTickets.append(contentsOf: betHistoryResponse.betList ?? [])
//
//                    self.openedMyTickets.send(newOpenedTickets)
//
//                    self.listStatePublisher.send(.loaded)
//
//                    if self.openedMyTickets.value.count < self.recordsPerPage * (self.openedPage + 1) {
//                        self.hasNextPage = false
//                    }
//                    else {
//                        self.hasNextPage = true
//                    }
//                }
//
//            })
//            .store(in: &cancellables)
    }

    func loadWonTickets(page: Int, isNextPage: Bool = false) {

        if !isNextPage {
            self.isLoadingTickets.send(true)
        }

        Env.servicesProvider.getWonBetsHistory(pageIndex: page)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.clearData()
                }
                self?.isLoadingTickets.send(false)
            } receiveValue: { [weak self] bettingHistory in
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
                        self.hasNextPage = false
                        if self.wonMyTickets.value.isEmpty {
                            self.listStatePublisher.send(.empty)
                        }
                        else {
                            self.listStatePublisher.send(.loaded)
                        }
                    }
                }
            }
            .store(in: &cancellables)

//        let wonRoute = TSRouter.getMyTickets(language: "en", ticketsType: EveryMatrix.MyTicketsType.won, records: recordsPerPage, page: page)
//        Env.everyMatrixClient.manager.getModel(router: wonRoute, decodingType: BetHistoryResponse.self)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure(let apiError):
//                    switch apiError {
//                    case .requestError(let value) where value.lowercased().contains("you must be logged in to perform this action"):
//                        self?.clearData()
//                    case .notConnected:
//                        self?.clearData()
//                    default:
//                        ()
//                    }
//                case .finished:
//                    ()
//                }
//                self?.isLoadingTickets.send(false)
//            },
//            receiveValue: { [weak self] betHistoryResponse in
//                guard let self = self else {return}
//
//                if self.wonMyTickets.value.isEmpty {
//                    self.wonMyTickets.send(betHistoryResponse.betList ?? [])
//
//                    if (betHistoryResponse.betList ?? []).isEmpty {
//                        self.listStatePublisher.send(.empty)
//                    }
//                    else {
//                        self.listStatePublisher.send(.loaded)
//                    }
//
//                    if let betHistory = betHistoryResponse.betList {
//                        if betHistory.count < self.recordsPerPage {
//                            self.hasNextPage = false
//                        }
//                    }
//                }
//                else {
//                    var newWonTickets = self.wonMyTickets.value
//                    newWonTickets.append(contentsOf: betHistoryResponse.betList ?? [])
//
//                    self.wonMyTickets.send(newWonTickets)
//
//                    self.listStatePublisher.send(.loaded)
//
//                    if self.wonMyTickets.value.count < self.recordsPerPage * (self.wonPage + 1) {
//                        self.hasNextPage = false
//                    }
//                    else {
//                        self.hasNextPage = true
//                    }
//                }
//            })
//            .store(in: &cancellables)

    }

    func refresh() {
        self.clearData()

        self.resolvedPage = 0
        self.openedPage = 0
        self.wonPage = 0
        
        switch self.myTicketsTypePublisher.value {
        case .opened:
            self.loadOpenedTickets(page: self.openedPage)
        case .resolved:
            self.loadResolvedTickets(page: self.resolvedPage)
        case .won:
            self.loadWonTickets(page: self.wonPage)
        }
    }
        
    func reloadTableView() {
        self.reloadTableViewAction?()
    }

    func numberOfRows() -> Int {
        switch myTicketsTypePublisher.value {
        case .resolved:
            return resolvedMyTickets.value.count
        case .opened:
            return openedMyTickets.value.count
        case .won:
            return wonMyTickets.value.count
        }
    }

    func isEmpty() -> Bool {
        switch myTicketsTypePublisher.value {
        case .resolved:
            return resolvedMyTickets.value.isEmpty
        case .opened:
            return openedMyTickets.value.isEmpty
        case .won:
            return wonMyTickets.value.isEmpty
        }
    }

    func viewModel(forIndex index: Int) -> MyTicketCellViewModel? {
        let ticket: BetHistoryEntry?

        switch myTicketsTypePublisher.value {
        case .resolved:
            ticket = resolvedMyTickets.value[safe: index] ?? nil
        case .opened:
            ticket = openedMyTickets.value[safe: index] ?? nil
        case .won:
            ticket = wonMyTickets.value[safe: index] ?? nil
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

    func getSharedBetTokens() {
        if let betId = self.clickedBetId {
            let betTokenRoute = TSRouter.getSharedBetTokens(betId: betId)

            Env.everyMatrixClient.manager.getModel(router: betTokenRoute, decodingType: SharedBetToken.self)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let apiError):
                        switch apiError {
                        case .requestError(let value):
                            print("Bet token request error: \(value)")
                        case .notConnected:
                            ()
                        default:
                            ()
                        }
                    case .finished:
                        ()
                    }
                },
                receiveValue: { [weak self] betTokens in
                    print("BET TOKEN: \(betTokens)")
                    let betToken = betTokens.sharedBetTokens.betTokenWithAllInfo
                    self?.clickedBetTokenPublisher.send(betToken)

                })
                .store(in: &cancellables)
        }
    }
    
    func shouldShowLoadingCell() -> Bool {
        switch self.myTicketsTypePublisher.value {
        case .opened:
            return self.openedMyTickets.value.isNotEmpty && hasNextPage
        case .resolved:
            return self.resolvedMyTickets.value.isNotEmpty && hasNextPage
        case .won:
            return self.wonMyTickets.value.isNotEmpty && hasNextPage
         
       }
    }
    
    func requestNextPage() {
           
        switch myTicketsTypePublisher.value {
        case .opened:
//           if self.openedMyTickets.value.count < self.recordsPerPage * (self.openedPage + 1) {
//               self.hasNextPage = false
//               self.listStatePublisher.send(.loaded)
//               return
//            }
            self.openedPage += 1
            self.loadOpenedTickets(page: openedPage, isNextPage: true)
        case .resolved :
//            if self.resolvedMyTickets.value.count < self.recordsPerPage * (self.resolvedPage + 1) {
//                self.hasNextPage = false
//                self.listStatePublisher.send(.loaded)
//                return
//            }
            self.resolvedPage += 1
            self.loadResolvedTickets(page: resolvedPage, isNextPage: true)
        case .won :
//            if self.wonMyTickets.value.count < self.recordsPerPage * (self.wonPage + 1) {
//               self.hasNextPage = false
//               self.listStatePublisher.send(.loaded)
//               return
//            }
            self.wonPage += 1
            self.loadWonTickets(page: wonPage, isNextPage: true)
       }
    }
}

extension MyTicketsViewModel: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.numberOfRows()
        case 1:
            return self.shouldShowLoadingCell() ? 1 : 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            
            let ticket: BetHistoryEntry?

            switch myTicketsTypePublisher.value {
            case .resolved:
                ticket = resolvedMyTickets.value[safe: indexPath.row] ?? nil
            case .opened:
                ticket =  openedMyTickets.value[safe: indexPath.row] ?? nil
            case .won:
                ticket =  wonMyTickets.value[safe: indexPath.row] ?? nil
            }

            guard
                let cell = tableView.dequeueCellType(MyTicketTableViewCell.self),
                let viewModel = self.viewModel(forIndex: indexPath.row),
                let ticketValue = ticket
            else {
                fatalError("tableView.dequeueCellType(MyTicketTableViewCell.self)")
            }

            let locationsCodes = (ticketValue.selections ?? [])
                .map({ event -> String in
                    let id = event.venueId ?? ""
                    return self.locationsCodesDictionary[id] ?? ""
                })

            cell.needsHeightRedraw = { [weak self] in
                self?.redrawTableViewAction?()
            }
            cell.configure(withBetHistoryEntry: ticketValue, countryCodes: locationsCodes, viewModel: viewModel)

            cell.tappedShareAction = { [weak self] in
                if let cellSnapshot = cell.snapshot,
                    let ticketStatus = ticketValue.status {
                    self?.requestShareActivityView?(cellSnapshot, ticketValue.betId, ticketStatus)
                    self?.clickedBetHistory = ticketValue
                }
            }
        
            cell.tappedMatchDetail = { [weak self] matchId in
                self?.tappedMatchDetail?(matchId)

            }
            return cell
            
        case 1:
           if let cell = tableView.dequeueCellType(LoadingMoreTableViewCell.self) {
               cell.startAnimating()
               return cell
           }
            
        default:
           fatalError()
       }
       return UITableViewCell()
   }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1, self.shouldShowLoadingCell() {
            self.requestNextPage()
        }
        
    }

}
