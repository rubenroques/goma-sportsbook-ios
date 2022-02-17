//
//  HistoryViewModel.swift
//  Sportsbook
//
//  Created by Teresa on 14/02/2022.
//

import Foundation
import Combine
import OrderedCollections

class HistoryViewModel {
    enum ListType {
        case transactions
        case bettings
        
        var identifier: Int {
            switch self {
            case .transactions: return 0
            case .bettings: return 1
            
            }
        }
    }
    
    enum BettingType {
        case resolved
        case open
        case won
        case cashout
        case none
        
        var identifier: String {
            switch self {
            case .resolved: return "Resolved"
            case .open: return "Open"
            case .won: return "Won"
            case .cashout: return "Cashout"
            case .none: return "None"
            }
        }
    }
    
    private var selectedMyTicketsTypeIndex: Int = 0
    var myTicketsTypePublisher: CurrentValueSubject<MyTicketsType, Never> = .init(.opened)
    var isTicketsEmptyPublisher: AnyPublisher<Bool, Never>

    enum MyTicketsType: Int {
        case opened = 0
        case resolved = 1
        case won = 2
    }


    var clickedBetId: String?
    var clickedBetStatus: String?
    var clickedBetTokenPublisher: CurrentValueSubject<String, Never> = .init("")
    
    var reloadTableViewAction: (() -> Void)?
    var redrawTableViewAction: (() -> Void)?

    private var matchDetailsDictionary: [String: Match] = [:]

    var resolvedMyTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    var openedMyTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    var wonMyTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    var cashoutTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])

    private var isLoadingResolved: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingOpened: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingWon: CurrentValueSubject<Bool, Never> = .init(true)

    private var locationsCodesDictionary: [String: String] = [:]

    var isLoading: AnyPublisher<Bool, Never>

    private let recordsPerPage = 1000

    private var resolvedPage = 0
    private var openedPage = 0
    private var wonPage = 0

    // Cached view models
    var cachedViewModels: [String: MyTicketCellViewModel] = [:]

    //
    private var cancellables = Set<AnyCancellable>()
    
    

    var refreshPublisher = PassthroughSubject<Void, Never>.init()
    var scrollToContentPublisher = PassthroughSubject<Int?, Never>.init()
    
    var listTypeSelected : CurrentValueSubject<ListType, Never> = .init(.transactions)
    
    var bettingTypeSelected : CurrentValueSubject<BettingType, Never> = .init(.none)



    // MARK: - Life Cycle
     init(){
        isLoading = Publishers.CombineLatest3(isLoadingResolved, isLoadingOpened, isLoadingWon)
            .map({ isLoadingResolved, isLoadingOpened, isLoadingWon in
                return isLoadingResolved || isLoadingOpened || isLoadingWon
            })
            .eraseToAnyPublisher()

        self.isTicketsEmptyPublisher = CurrentValueSubject<Bool, Never>.init(false).eraseToAnyPublisher()


        isTicketsEmptyPublisher = Publishers.CombineLatest4(myTicketsTypePublisher, isLoadingResolved, isLoadingOpened, isLoadingWon)
            .map { [weak self] myTicketsType, isLoadingResolved, isLoadingOpened, isLoadingWon in
                switch myTicketsType {
                case .resolved:
                    if isLoadingResolved { return false }
                    return self?.resolvedMyTickets.value.isEmpty ?? false
                case .opened:
                    if isLoadingOpened { return false }
                    return self?.openedMyTickets.value.isEmpty ?? false
                case .won:
                    if isLoadingWon { return false }
                    return self?.wonMyTickets.value.isEmpty ?? false
                }
            }
            .eraseToAnyPublisher()

        myTicketsTypePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] myTicketsType in
                self?.selectedMyTicketsTypeIndex =  myTicketsType.rawValue

                self?.reloadTableView()
            }
            .store(in: &cancellables)

        Env.everyMatrixClient.userSessionStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userSessionStatus in
                switch userSessionStatus {
                case .logged:
                    self?.refresh()
                case .anonymous:
                    self?.clearData()
                }
            }
            .store(in: &cancellables)

        self.loadLocations()
        self.initialLoadMyTickets()

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
                self?.resolvedMyTickets.value = betHistoryResponse.betList ?? []
                if case .resolved = self?.myTicketsTypePublisher.value {
                    self?.reloadTableView()
                }
            })
            .store(in: &cancellables)
    }
    
    func loadCashoutTickets(page: Int) {
        var cashoutsArray: [BetHistoryEntry] = []
        for ticket in self.resolvedMyTickets.value{
            if ticket.status == "CASHED_OUT"{
                cashoutsArray.append(ticket)
               
            }
        }
        print(cashoutsArray)
        self.cashoutTickets.value = cashoutsArray
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
                self?.openedMyTickets.value = betHistoryResponse.betList ?? []
                if case .opened = self?.myTicketsTypePublisher.value {
                    self?.reloadTableView()
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
                self?.wonMyTickets.value = betHistoryResponse.betList ?? []
                if case .won = self?.myTicketsTypePublisher.value {
                    self?.reloadTableView()
                }
            })
            .store(in: &cancellables)

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
    
    func reloadTableView() {
        self.reloadTableViewAction?()
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
        self.loadCashoutTickets(page: 0)
    }

    func clearData() {
        self.resolvedMyTickets.value = []
        self.openedMyTickets.value = []
        self.wonMyTickets.value = []
        self.reloadTableView()
    }

    func numberOfRowsInTable() -> Int {
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
    
}

extension HistoryViewModel {

    func didSelectShortcut(atSection section: Int) {
        self.scrollToContentPublisher.send(section)
    }

}

extension HistoryViewModel {

    func numberOfShortcutsSections() -> Int {
        return 1
    }

    func numberOfShortcuts(forSection section: Int) -> Int {
        if listTypeSelected.value == .transactions {
            return 2
        }
        else{
            return 4
        }
       
    }

    func shortcutTitle(forIndex index: Int) -> String? {
        
        if listTypeSelected.value == .transactions {
            switch index {
            case 0:
                return "Deposits"
            case 1:
                return "Withdraws"
            default:
                return ""
            }
        }else{
            switch index {
            case 0:
                return "Resolved"
            case 1:
                return "Open"
            case 2:
                return "Won"
            case 3:
                return "Cashout"
            default:
                return ""
            }
        }
        
        
        
    }

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {
        return 2
    }


}


/*

extension HistoryViewModel: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
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
                let cell = tableView.dequeueReusableCell(withIdentifier: BettingsTableViewCell.identifier, for: indexPath) as? BettingsTableViewCell,
                let ticketValue = ticket
            else {
                fatalError("")
            }
     
            cell.configure(withBetHistoryEntry: ticketValue)
            return cell
        
        
    }

}
*/
