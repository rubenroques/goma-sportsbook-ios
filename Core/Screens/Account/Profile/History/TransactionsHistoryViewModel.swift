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
    var startData: CurrentValueSubject<String, Never> = .init("2000-01-01T12:00:00Z")
    var endData: CurrentValueSubject<String, Never> = .init("2022-01-01T12:00:00Z")
    var transactionsPublisher: CurrentValueSubject<[EveryMatrix.TransactionHistory], Never> = .init([])

    // MARK: - Private Properties
    private let recordsPerPage = 80
    private var cancellables = Set<AnyCancellable>()

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
        self.calculateData(filterApplied: filterApplied)
        self.transactionTypePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                self.initialContentLoad()

            })
            .store(in: &self.cancellables)
    
        Env.everyMatrixClient.serviceStatusPublisher
            .sink { serviceStatus in
                if serviceStatus == .connected {
                    self.initialContentLoad()
                }
            }
            .store(in: &cancellables)
        
        self.startData
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                self.initialContentLoad()
            })
            .store(in: &self.cancellables)
        
        self.endData
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                self.initialContentLoad()
            })
            .store(in: &self.cancellables)
        
    }

    func initialContentLoad() {
        self.listStatePublisher.send(.loading)
        self.transactionsPublisher.send([])

        switch self.transactionsType {
        case .deposit:
            self.loadDeposits(page: 1)
        case .withdraw:
            self.loadWithdraws(page: 1)
        }

    }

    func refreshContent() {
        self.initialContentLoad()
    }
    
    func calculateData(filterApplied: FilterHistoryViewModel.FilterValue) {
        
        self.endData.send("\("\(Date())".split(separator: " ")[0])T\("\(Date())".split(separator: " ")[1])Z")
        print(filterApplied)
        
        switch filterApplied {
        case .dateRange(let startTime, let endTime):
            self.startData.send("\("\(startTime)".split(separator: " ")[0])T\("\(startTime)".split(separator: " ")[1])Z")      
            self.endData.send("\("\(endTime)".split(separator: " ")[0])T\("\(endTime)".split(separator: " ")[1])Z")
        case .past30Days:
            if let date = Calendar.current.date(byAdding: .day, value: -30, to: Date()) {
                self.startData.send("\("\(date)".split(separator: " ")[0])T\("\(date)".split(separator: " ")[1])Z")
            }
        default :
       
            if let date = Calendar.current.date(byAdding: .day, value: -90, to: Date()) {
                self.startData.send("\("\(date)".split(separator: " ")[0])T\("\(date)".split(separator: " ")[1])Z")
            }
        }
    }

    func loadDeposits(page: Int) {
        self.listStatePublisher.send(.loading)
        let depositsRoute = TSRouter.getTransactionHistory(type: "Deposit",
                                                           startTime: self.startData.value,
                                                           endTime: self.endData.value,
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
                self?.transactionsPublisher.send(depositsTransactions)
                if depositsTransactions.isEmpty {
                    self?.listStatePublisher.send(.empty)
                }
                else {
                    self?.listStatePublisher.send(.loaded)
                }
            })
            .store(in: &cancellables)
    }

    func loadWithdraws(page: Int) {
        self.listStatePublisher.send(.loading)

        let withdrawsRoute = TSRouter.getTransactionHistory(type: "Withdraw",
                                                            startTime: self.startData.value,
                                                            endTime: self.endData.value,
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
                self?.transactionsPublisher.send(withdrawsTransactions)
                if withdrawsTransactions.isEmpty {
                    self?.listStatePublisher.send(.empty)
                }
                else {
                    self?.listStatePublisher.send(.loaded)
                }
            })
            .store(in: &cancellables)
    }

}

extension TransactionsHistoryViewModel {

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows() -> Int {
        return self.transactionsPublisher.value.count
    }

    func transactionForRow(atIndex index: Int) -> EveryMatrix.TransactionHistory? {
        return self.transactionsPublisher.value[safe: index]
    }

}
