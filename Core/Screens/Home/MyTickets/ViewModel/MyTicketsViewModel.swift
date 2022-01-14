//
//  MyTicketsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 17/12/2021.
//

import Foundation
import UIKit
import Combine

class MyTicketsViewModel: NSObject {

    private var selectedMyTicketsTypeIndex: Int = 0
    var myTicketsTypePublisher: CurrentValueSubject<MyTicketsType, Never> = .init(.opened)
    var isTicketsEmptyPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isUserLoggedInPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    
    enum MyTicketsType: Int {
        case opened = 0
        case resolved = 1
        case won = 2
    }

    var reloadTableViewAction: (() -> Void)?
    var redrawTableViewAction: (() -> Void)?

    private var matchDetailsDictionary: [String: Match] = [:]

    private var resolvedMyTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    private var openedMyTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    private var wonMyTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])

    private var isLoadingResolved: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingOpened: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingWon: CurrentValueSubject<Bool, Never> = .init(true)

    private var locationsCodesDictionary: [String: String] = [:]

    var isLoading: AnyPublisher<Bool, Never>

    private let recordsPerPage = 1000

    private var resolvedPage = 0
    private var openedPage = 0
    private var wonPage = 0

    //Cached view models
    var cachedViewModels: [String: MyTicketCellViewModel] = [:]

    //
    private var cancellables = Set<AnyCancellable>()

    override init() {

        isLoading = Publishers.CombineLatest3(isLoadingResolved, isLoadingOpened, isLoadingWon)
            .map({ isLoadingResolved, isLoadingOpened, isLoadingWon in
                return isLoadingResolved || isLoadingOpened || isLoadingWon
            })
            .eraseToAnyPublisher()

        super.init()

        myTicketsTypePublisher.sink { [weak self] myTicketsType in
            self?.selectedMyTicketsTypeIndex =  myTicketsType.rawValue

            self?.reloadTableView()
        }
        .store(in: &cancellables)
        
        if  UserSessionStore.isUserLogged() {
            self.isUserLoggedInPublisher.send(true)
        }else{
            self.isUserLoggedInPublisher.send(false)
            self.isTicketsEmptyPublisher.send(true)
        }
    

        Env.userSessionStore
            .userSessionPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.refresh()
            }
            .store(in: &cancellables)


        self.loadLocations()
        self.initialLoadMyTickets()
        
    }

    func setMyTicketsType(_ type: MyTicketsType) {
        self.myTicketsTypePublisher.value = type
    }

    func isTicketsTypeSelected(forIndex index: Int) -> Bool {
        return index == selectedMyTicketsTypeIndex
    }

    //
    //
    func loadLocations() {
        let resolvedRoute = TSRouter.getLocations(language: "en", sortByPopularity: false)
        TSManager.shared.getModel(router: resolvedRoute, decodingType: EveryMatrixSocketResponse<EveryMatrix.Location>.self)
            .sink(receiveCompletion: { _ in

            },
            receiveValue: { response in
                self.locationsCodesDictionary = [:]
                (response.records ?? []).forEach { location in
                    if let code = location.code {
                        self.locationsCodesDictionary[location.id] = code
                    }
                }

            })
            .store(in: &cancellables)
    }

    //
    //
    func initialLoadMyTickets() {

        self.loadResolvedTickets(page: 0)
        self.loadOpenedTickets(page: 0)
        self.loadWonTickets(page: 0)

    }

    func clearData() {
        self.resolvedMyTickets.value = []
        self.openedMyTickets.value = []
        self.wonMyTickets.value = []
        self.reloadTableView()
    }

    func loadResolvedTickets(page: Int) {

        self.isLoadingResolved.send(true)

        let resolvedRoute = TSRouter.getMyTickets(language: "en", ticketsType: EveryMatrix.MyTicketsType.resolved, records: recordsPerPage, page: page)
        TSManager.shared.getModel(router: resolvedRoute, decodingType: BetHistoryResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let apiError):
                    switch apiError {
                    case .requestError(let value) where value.lowercased().contains("you must be logged in to perform this action"):
                        self.clearData()
                    default:
                        ()
                    }
                    print("\(apiError)")
                case .finished:
                    ()
                }
                self.isLoadingResolved.send(false)
            },
            receiveValue: { betHistoryResponse in
                self.resolvedMyTickets.value = betHistoryResponse.betList ?? []

                if case .resolved = self.myTicketsTypePublisher.value {
                    self.reloadTableView()
                }
                self.isTicketsEmptyPublisher.send(self.isEmpty())
            })
            .store(in: &cancellables)
    }

    func loadOpenedTickets(page: Int) {

        self.isLoadingOpened.send(true)

        let openedRoute = TSRouter.getMyTickets(language: "en", ticketsType: EveryMatrix.MyTicketsType.opened, records: recordsPerPage, page: page)
        TSManager.shared.getModel(router: openedRoute, decodingType: BetHistoryResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let apiError):
                    switch apiError {
                    case .requestError(let value) where value.lowercased().contains("you must be logged in to perform this action"):
                        self.clearData()
                    default:
                        ()
                    }
                    print("\(apiError)")
                case .finished:
                    ()
                }
                self.isLoadingOpened.send(false)
            },
            receiveValue: { betHistoryResponse in
                self.openedMyTickets.value = betHistoryResponse.betList ?? []

                if case .opened = self.myTicketsTypePublisher.value {
                    self.reloadTableView()
                }
                self.isTicketsEmptyPublisher.send(self.isEmpty())
            })
            .store(in: &cancellables)

    }

    func loadWonTickets(page: Int) {

        self.isLoadingWon.send(true)

        let wonRoute = TSRouter.getMyTickets(language: "en", ticketsType: EveryMatrix.MyTicketsType.won, records: recordsPerPage, page: page)
        TSManager.shared.getModel(router: wonRoute, decodingType: BetHistoryResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let apiError):
                    switch apiError {
                    case .requestError(let value) where value.lowercased().contains("you must be logged in to perform this action"):
                        self.clearData()
                    default:
                        ()
                    }
                    print("\(apiError)")
                case .finished:
                    ()
                }
                self.isLoadingWon.send(false)
            },
            receiveValue: { betHistoryResponse in
                self.wonMyTickets.value = betHistoryResponse.betList ?? []

                if case .won = self.myTicketsTypePublisher.value {
                    self.reloadTableView()
                }
                self.isTicketsEmptyPublisher.send(self.isEmpty())
            })
            .store(in: &cancellables)

    }

    func requestNextPage() {
        switch myTicketsTypePublisher.value {
        case .resolved:
            resolvedPage += 1
            self.loadResolvedTickets(page: resolvedPage)
        case .opened:
            openedPage += 1
            self.loadOpenedTickets(page: openedPage)
        case .won:
            wonPage += 1
            self.loadWonTickets(page: wonPage)
        }
    }

    func refresh() {
        self.resolvedPage = 0
        self.openedPage = 0
        self.wonPage = 0

        self.initialLoadMyTickets()
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
            ticket =  openedMyTickets.value[safe: index] ?? nil
        case .won:
            ticket =  wonMyTickets.value[safe: index] ?? nil
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

extension MyTicketsViewModel: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

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

        debugPrint("MyTicketCellViewModel \(viewModel)")

        let locationsCodes = (ticketValue.selections ?? [])
            .map({ event -> String in
                let id = event.venueId ?? ""
                return self.locationsCodesDictionary[id] ?? ""
            })

        cell.needsHeightRedraw = { [weak self] in
            self?.redrawTableViewAction?()
        }
        cell.configure(withBetHistoryEntry: ticketValue, countryCodes: locationsCodes, viewModel: viewModel)

        return cell
    }

}
