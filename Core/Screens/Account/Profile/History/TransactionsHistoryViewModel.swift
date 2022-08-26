//
//  TransactionsHistoryViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/04/2022.
//

import Foundation
import Combine
import OrderedCollections

class TransactionsHistoryViewModel {

    enum TransactionsType: Int {
        case deposit = 0
        case withdraw = 1
    }

    enum ListState {
        case loading
        case serverError
        case noUserFoundError
        case empty
        case loaded
    }

    var transactionsType: TransactionsType = .deposit
    var filterApplied: FilterHistoryViewModel.FilterValue = .past30Days

    // MARK: - Publishers
    var titlePublisher: CurrentValueSubject<String, Never>
    var listStatePublisher: CurrentValueSubject<ListState, Never> = .init(.loading)
    var transactionTypePublisher: CurrentValueSubject<TransactionsType, Never> = .init(.deposit)
    var startDatePublisher: CurrentValueSubject<Date, Never> = .init(Date())
    var endDatePublisher: CurrentValueSubject<Date, Never> = .init(Date())
    var transactionsPublisher: CurrentValueSubject<[EveryMatrix.TransactionHistory], Never> = .init([])

    var depositTransactions: CurrentValueSubject<[EveryMatrix.TransactionHistory], Never> = .init([])
    var withdrawTransactions: CurrentValueSubject<[EveryMatrix.TransactionHistory], Never> = .init([])

    // MARK: - Private Properties
    private var depositPage = 0
    private var withdrawPage = 0
    private let recordsPerPage = 80
    private var cancellables = Set<AnyCancellable>()

    private var transactionsHasNextPage = true

    // MARK: - Life Cycle
    init(transactionsType: TransactionsType, filterApplied: FilterHistoryViewModel.FilterValue) {

        self.transactionsType = transactionsType
        self.transactionTypePublisher.send(transactionsType)
        self.filterApplied = filterApplied
        
        switch transactionsType {
        case .deposit:
            self.titlePublisher = .init("Deposits")
        case .withdraw:
            self.titlePublisher = .init("Withdraws")
        }
        self.calculateDate(filterApplied: filterApplied)
   
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
        self.transactionsPublisher.send([])
        self.depositTransactions.send([])
        self.withdrawTransactions.send([])

        switch self.transactionsType {
        case .deposit:
            self.loadDeposits(page: 1)
        case .withdraw:
            self.loadWithdraws(page: 1)
        }

    }

    func refreshContent() {
        self.transactionsHasNextPage = true
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
        switch self.transactionsType {
        case .deposit:
            return self.depositTransactions.value.isNotEmpty && transactionsHasNextPage
        case .withdraw:
            return self.withdrawTransactions.value.isNotEmpty && transactionsHasNextPage
        }

    }

    func loadDeposits(page: Int) {
        self.listStatePublisher.send(.loading)
        let depositsRoute = TSRouter.getTransactionHistory(type: "Deposit",
                                                           startTime: convertDateToString(date: self.startDatePublisher.value),
                                                           endTime: convertDateToString(date: self.endDatePublisher.value),
                                                           pageIndex: page,
                                                           pageSize: recordsPerPage)

        Env.everyMatrixClient.manager.getModel(router: depositsRoute, decodingType: EveryMatrix.TransactionsHistoryResponse.self)
            .map(\.transactions)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let apiError):
                    self?.transactionsPublisher.send([])
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
            }, receiveValue: { [weak self] depositsTransactions in
                let deposits = depositsTransactions
                self?.depositTransactions.send(depositsTransactions)
                //self?.transactionsPublisher.send(depositsTransactions)
                if depositsTransactions.isEmpty {
                    self?.listStatePublisher.send(.empty)
                }
                else {
                    self?.listStatePublisher.send(.loaded)
                }
            })
            .store(in: &cancellables)
    }
    
    func convertDateToString(date: Date) -> String{
        let auxDate = "\(date)"
        let dateSplited = auxDate.split(separator: " ")
        return "\(dateSplited[0])"
        
    }

    func loadWithdraws(page: Int) {
        self.listStatePublisher.send(.loading)

        let withdrawsRoute = TSRouter.getTransactionHistory(type: "Withdraw",
                                                            startTime: convertDateToString(date: self.startDatePublisher.value),
                                                            endTime: convertDateToString(date: self.endDatePublisher.value),
                                                            pageIndex: page,
                                                            pageSize: recordsPerPage)
        Env.everyMatrixClient.manager.getModel(router: withdrawsRoute, decodingType: EveryMatrix.TransactionsHistoryResponse.self)
            .map(\.transactions)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let apiError):
                    self?.transactionsPublisher.send([])
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
            }, receiveValue: { [weak self] withdrawsTransactions in
                self?.withdrawTransactions.send(withdrawsTransactions)
                //self?.transactionsPublisher.send(withdrawsTransactions)
                if withdrawsTransactions.isEmpty {
                    self?.listStatePublisher.send(.empty)
                }
                else {
                    self?.listStatePublisher.send(.loaded)
                }
            })
            .store(in: &cancellables)
    }

    func requestNextPage() {

        switch self.transactionsType {
        case .deposit:
            if self.depositTransactions.value.count < self.recordsPerPage * (self.depositPage + 1) {
                self.transactionsHasNextPage = false
                return
            }
            depositPage += 1
            self.loadDeposits(page: depositPage)
        case .withdraw:
            if self.withdrawTransactions.value.count < self.recordsPerPage * (self.withdrawPage + 1) {
                self.transactionsHasNextPage = false
                return
            }
            withdrawPage += 1
            self.loadWithdraws(page: withdrawPage)
        }
        //self.fetchNextPage()
    }

}

extension TransactionsHistoryViewModel {

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows() -> Int {
        switch self.transactionsType {
        case .deposit:
            return self.depositTransactions.value.count
        case .withdraw:
            return self.withdrawTransactions.value.count
        }
        //return self.transactionsPublisher.value.count
    }

    func transactionForRow(atIndex index: Int) -> EveryMatrix.TransactionHistory? {
        switch self.transactionsType {
        case .deposit:
            return self.depositTransactions.value[safe: index]
        case .withdraw:
            return self.withdrawTransactions.value[safe: index]

        }
        //return self.transactionsPublisher.value[safe: index]
    }

}
