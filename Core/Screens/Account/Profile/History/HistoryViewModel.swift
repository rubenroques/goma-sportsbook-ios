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
    
    // MARK: - Enums
   
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
        case opened
        case won
        case cashout
        case none
        
        var identifier: String {
            switch self {
            case .resolved: return "Resolved"
            case .opened: return "Open"
            case .won: return "Won"
            case .cashout: return "Cashout"
            case .none: return "None"
            }
        }
    }
    
    enum TicketsType: Int {
        case opened = 0
        case resolved = 1
        case won = 2
        case cashout = 3
    }
    
    enum TransactionsType: Int {
        case deposit = 0
        case withdraw = 1
    }

    
    // MARK: - Publishers
   
    var transactionsTypePublisher: CurrentValueSubject<TransactionsType, Never> = .init(.deposit)
    var ticketsTypePublisher: CurrentValueSubject<TicketsType, Never> = .init(.resolved)
    var listTypePublisher: CurrentValueSubject<ListType, Never> = .init(.transactions)
    var isTicketsEmptyPublisher: AnyPublisher<Bool, Never>?
    var isTransactionsEmptyPublisher: AnyPublisher<Bool, Never>?
    var isLoading: AnyPublisher<Bool, Never>

    // MARK: - data
    var resolvedTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    var openedTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    var wonTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    var cashoutTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    
    var deposits: CurrentValueSubject<[EveryMatrix.TransactionHistory], Never> = .init([])
    var withdraws: CurrentValueSubject<[EveryMatrix.TransactionHistory], Never> = .init([])
    
    var reloadTableViewAction: (() -> Void)?
    var redrawTableViewAction: (() -> Void)?
    
    // MARK: - Private Properties
    
    private var isLoadingResolved: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingOpened: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingWon: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingCashout: CurrentValueSubject<Bool, Never> = .init(true)
    
    private var isLoadingDeposits: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingWithdraws: CurrentValueSubject<Bool, Never> = .init(true)
    

    private let recordsPerPage = 5000

    private var cancellables = Set<AnyCancellable>()
    
    var refreshPublisher = PassthroughSubject<Void, Never>.init()
    var scrollToContentPublisher = PassthroughSubject<Int?, Never>.init()


    // MARK: - Life Cycle
     init(){
    
         
             isLoading = Publishers.CombineLatest(isLoadingDeposits, isLoadingWithdraws)
                 .map({ isLoadingDeposits, isLoadingWithdraws in
                     return isLoadingDeposits || isLoadingWithdraws
                 })
                 .eraseToAnyPublisher()

             self.isTransactionsEmptyPublisher = CurrentValueSubject<Bool, Never>.init(false).eraseToAnyPublisher()
         self.isTicketsEmptyPublisher = CurrentValueSubject<Bool, Never>.init(false).eraseToAnyPublisher()
            /* self.transactionsTypePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] tansactionType in
                    switch tansactionType{
                    case .deposit:
                        self?.loadDeposits(page: 0)
                        
                    case .withdraw:
                        self?.loadWithdraws(page: 0)
                    }
                     
                }
                .store(in: &cancellables)*/
          
         self.loadDeposits(page: 0)
         self.loadWithdraws(page: 0)
         self.loadResolvedTickets(page: 0)
         self.loadOpenedTickets(page: 0)
         self.loadWonTickets(page: 0)
         //self.loadCashoutTickets(page: 0)

           
           /* self.loadResolvedTickets(page: 0)
             self.ticketsTypePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] ticketsType in
                    switch ticketsType{
                    case .resolved:
                        self?.loadResolvedTickets(page: 0)
                        self?.reloadTableView()
                    case .won:
                        self?.loadWonTickets(page: 0)
                        self?.reloadTableView()
                    case .opened:
                        self?.loadOpenedTickets(page: 0)
                        self?.reloadTableView()
                    case .cashout:
                        self?.loadCashoutTickets(page: 0)
                        self?.reloadTableView()
                    }
                }
                .store(in: &cancellables)
         */
         
     }
    
   
    func loadResolvedTickets(page: Int) {

        self.isLoadingResolved.send(true)
    

        let resolvedRoute = TSRouter.getMyTickets(language: "en", ticketsType: EveryMatrix.MyTicketsType.resolved , records: recordsPerPage, page: page)
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
               
                self?.refreshPublisher.send()
            },
            receiveValue: { [weak self] betHistoryResponse in
                self?.resolvedTickets.value = betHistoryResponse.betList ?? []
                self?.loadCashoutTickets(page: 0)
            })
            .store(in: &cancellables)
        
        
       
    }
    
    func loadCashoutTickets(page: Int) {
       
        var cashoutsArray: [BetHistoryEntry] = []
        for ticket in self.resolvedTickets.value{
            if ticket.status == "CASHED_OUT"{
                cashoutsArray.append(ticket)
            }else{
                print("berrou")
            }
        }
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
                self?.openedTickets.value = betHistoryResponse.betList ?? []
               
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
                self?.wonTickets.value = betHistoryResponse.betList ?? []
               
                
            })
            .store(in: &cancellables)

    }
    
    func loadDeposits(page: Int) {

        self.isLoadingDeposits.send(true)
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD T HH:MM:SS.MMMZ"
        dateFormatter.string(from: date)
        
        let startTime = "2021-11-04T16:00:00.000"
        let endTime = "2022-02-10T16:00:00.000"
        var pages = [2,3,4,5,6,7,8,9,10,11,12,13,14,15]
        for page in pages {
       // let depositRoute = TSRouter.getTransactionHistory(type: "Deposit", startTime: startTime, endTime: endTime, pageIndex: 0, pageSize: 20)
        let wonRoute = TSRouter.getTransactionHistory(type: "Deposit", startTime: "2021-05-04T16:00:00.000", endTime: "2022-02-10T16:00:00.000", pageIndex: page, pageSize: 1000)
        Env.everyMatrixClient.manager.getModel(router: wonRoute, decodingType: EveryMatrix.TransactionsHistoryResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let apiError):
                    switch apiError {
                   
                    case .requestError(let value):
                        print(value)
                        self?.clearData()
                    case .notConnected:
                        
                        self?.clearData()

                    default:
                        
                        ()
                    }
                case .finished:
                    ()
                }
                print(completion)
                self?.isLoadingDeposits.send(false)
            },
            receiveValue: { [weak self] depositHistoryResponse in
                
                print(depositHistoryResponse.transactions )
                self?.deposits.value = depositHistoryResponse.transactions ?? []
                self?.reloadTableView()
                
            })
            .store(in: &cancellables)
            
        }

    }
    func loadWithdraws(page: Int) {

        self.isLoadingDeposits.send(true)
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD T HH:MM:SS.MMMZ"
        dateFormatter.string(from: date)
        
        let startTime = "2021-11-04T16:00:00.000"
        let endTime = "2022-02-10T16:00:00.000"
        var pages = [2,3,4,5,6,7,8,9,10,11,12,13,14,15]
        for page in pages {
       // let depositRoute = TSRouter.getTransactionHistory(type: "Deposit", startTime: startTime, endTime: endTime, pageIndex: 0, pageSize: 20)
        let wonRoute = TSRouter.getTransactionHistory(type: "Withdraw", startTime: "2021-05-04T16:00:00.000", endTime: "2022-02-10T16:00:00.000", pageIndex: page, pageSize: 1000)
        Env.everyMatrixClient.manager.getModel(router: wonRoute, decodingType: EveryMatrix.TransactionsHistoryResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let apiError):
                    switch apiError {
                   
                    case .requestError(let value):
                        print(value)
                        self?.clearData()
                    case .notConnected:
                        
                        self?.clearData()

                    default:
                        
                        ()
                    }
                case .finished:
                    ()
                }
                print(completion)
                self?.isLoadingDeposits.send(false)
            },
            receiveValue: { [weak self] depositHistoryResponse in
                
                print(depositHistoryResponse.transactions )
                self?.deposits.value = depositHistoryResponse.transactions ?? []
                self?.reloadTableView()
                
            })
            .store(in: &cancellables)
            
        }

    }
    
    func reloadTableView() {
        self.reloadTableViewAction?()
    }
    
    func initialLoadTickets() {
        self.loadResolvedTickets(page: 0)
        self.loadOpenedTickets(page: 0)
        self.loadWonTickets(page: 0)
        self.loadCashoutTickets(page: 0)
    }

    func clearData() {
        self.resolvedTickets.value = []
        self.openedTickets.value = []
        self.wonTickets.value = []
        self.deposits.value = []
        self.withdraws.value = []
        
        self.reloadTableView()
    }

    func numberOfRowsInTable() -> Int {
        
       switch listTypePublisher.value{
        case .transactions:
            switch transactionsTypePublisher.value {
            case .deposit:
                print(deposits.value.count)

                return deposits.value.count
            case .withdraw:
                return withdraws.value.count
            
            }
        case .bettings:
            switch ticketsTypePublisher.value {
            case .resolved:
                return resolvedTickets.value.count
            case .opened:
                return openedTickets.value.count
            case .won:
                return wonTickets.value.count
            case .cashout:
                print(cashoutTickets.value.count)
                return cashoutTickets.value.count
            }
        }
        
    }

    func isEmpty() -> Bool {
        switch ticketsTypePublisher.value {
        case .resolved:
            return resolvedTickets.value.isEmpty
        case .opened:
            return openedTickets.value.isEmpty
        case .won:
            return wonTickets.value.isEmpty
        case .cashout:
            return cashoutTickets.value.isEmpty
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
        if listTypePublisher.value == .transactions {
            return 2
        }
        else{
            return 4
        }
       
    }

    func shortcutTitle(forIndex index: Int) -> String? {
        
        if listTypePublisher.value == .transactions {
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

            switch ticketsTypePublisher.value {
            case .resolved:
                ticket = resolvedTickets.value[safe: indexPath.row] ?? nil
            case .opened:
                ticket =  openedTickets.value[safe: indexPath.row] ?? nil
            case .won:
                ticket =  wonTickets.value[safe: indexPath.row] ?? nil
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
