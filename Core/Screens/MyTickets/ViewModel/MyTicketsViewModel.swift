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
    var redrawTableViewAction: ((Bool) -> Void)?
    var tappedMatchDetail: ((String) -> Void)?
    var requestShareActivityView: ((UIImage, String, String) -> Void)?
    var updateCellAtIndexPath: ((IndexPath) -> Void)?

    var requestAlertAction: ((String, String) -> Void)?
    var requestPartialAlertAction: ((String, String) -> Void)?
    var showCashoutSuspendedAction: (() -> Void)?
    var showCashoutState: ((AlertType, String) -> Void)?
    var shouldShowCashbackInfo: (() -> Void)?

    private var matchDetailsDictionary: [String: Match] = [:]

    private var resolvedMyTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    private var openedMyTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    private var wonMyTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])

    var isLoadingTickets: CurrentValueSubject<Bool, Never> = .init(true)
    private var locationsCodesDictionary: [String: String] = [:]
    
    private let recordsPerPage = 20
    
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
            .delay(for: 1.0, scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.refresh()
            }
            .store(in: &cancellables)

        Env.userSessionStore.userProfileStatusPublisher
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

        self.cachedViewModels = [:]

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
                if case let .failure(error) = completion {
                    Logger.log("loadResolvedTickets error \(error)")
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

    }

    func loadWonTickets(page: Int, isNextPage: Bool = false) {

        if !isNextPage {
            self.isLoadingTickets.send(true)
        }

        Env.servicesProvider.getWonBetsHistory(pageIndex: page)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    Logger.log("loadWonTickets error \(error)")
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
            let viewModel = MyTicketCellViewModel(ticket: ticket)
            viewModel.requestDataRefreshAction = { [weak self] in
                Env.userSessionStore.refreshUserWalletAfterDelay()
                self?.refresh()
            }

            viewModel.requestAlertAction = { [weak self] cashoutReoffer, betId in
                self?.requestAlertAction?(cashoutReoffer, betId)
            }

            viewModel.requestPartialAlertAction = { [weak self] cashoutReoffer, betId in
                self?.requestPartialAlertAction?(cashoutReoffer, betId)
            }

            viewModel.showCashoutSuspendedAction = { [weak self] in
                self?.showCashoutSuspendedAction?()
            }

            viewModel.showCashoutState = { [weak self] alertType, text in
                self?.showCashoutState?(alertType, text)
            }

            cachedViewModels[ticket.betId] = viewModel
            return viewModel
        }
    }

    func getSharedBetTokens() {

        // TODO: Get a bet token for the shared clicked bet
        // Send it to self?.clickedBetTokenPublisher.send(betToken)
        if let betslipId = self.clickedBetId {
            print("BETSLIP TICKET ID: \(betslipId)")
            self.clickedBetTokenPublisher.send(betslipId)
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
            self.openedPage += 1
            self.loadOpenedTickets(page: openedPage, isNextPage: true)
        case .resolved:
            self.resolvedPage += 1
            self.loadResolvedTickets(page: resolvedPage, isNextPage: true)
        case .won:
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
                ticket = openedMyTickets.value[safe: indexPath.row] ?? nil
            case .won:
                ticket = wonMyTickets.value[safe: indexPath.row] ?? nil
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

            cell.needsHeightRedraw = { [weak self] withScroll in
                self?.redrawTableViewAction?(withScroll)
            }

            cell.needsDataUpdate = { [weak self] in
                self?.updateCellAtIndexPath?(indexPath)
            }

            cell.configure(withBetHistoryEntry: ticketValue, countryCodes: locationsCodes, viewModel: viewModel)

            cell.tappedShareAction = { [weak self] in
                if let cellSnapshot = cell.snapshot,
                   let ticketStatus = ticketValue.status,
                   let betslipId = ticketValue.betslipId {
                    self?.requestShareActivityView?(cellSnapshot, "\(betslipId)", ticketStatus)
                    self?.clickedBetHistory = ticketValue
                }
            }
        
            cell.tappedMatchDetail = { [weak self] matchId in
                self?.tappedMatchDetail?(matchId)

            }

            cell.shouldShowCashbackInfo = { [weak self] in
                self?.shouldShowCashbackInfo?()
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
