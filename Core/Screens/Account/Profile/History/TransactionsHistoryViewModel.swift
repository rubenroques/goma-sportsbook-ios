//
//  TransactionsHistoryViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/04/2022.
//

import Foundation
import Combine
import OrderedCollections
import ServicesProvider

class TransactionsHistoryViewModel {

    enum TransactionsType: Int {
        case all = 0
        case deposit = 1
        case withdraw = 2
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
//    var transactionsPublisher: CurrentValueSubject<[EveryMatrix.TransactionHistory], Never> = .init([])
//    var depositTransactions: CurrentValueSubject<[EveryMatrix.TransactionHistory], Never> = .init([])
//    var withdrawTransactions: CurrentValueSubject<[EveryMatrix.TransactionHistory], Never> = .init([])
    var transactionsPublisher: CurrentValueSubject<[TransactionHistory], Never> = .init([])

    var allTransactions: CurrentValueSubject<[TransactionHistory], Never> = .init([])
    var depositTransactions: CurrentValueSubject<[TransactionHistory], Never> = .init([])
    var withdrawTransactions: CurrentValueSubject<[TransactionHistory], Never> = .init([])
    var pendingWithdrawals = [PendingWithdrawal]()

    var shouldShowAlert: ((AlertType) -> Void)?

    // MARK: - Private Properties
    private var allPage = 1
    private var depositPage = 1
    private var withdrawPage = 1
    private let recordsPerPage = 10
    private var cancellables = Set<AnyCancellable>()

    private var transactionsHasNextPage = true
    private var hasLoadedPendingWithdrawals: CurrentValueSubject<Bool, Never> = .init(false)

    private let dateFormatter = DateFormatter()

    // MARK: - Life Cycle
    init(transactionsType: TransactionsType, filterApplied: FilterHistoryViewModel.FilterValue) {

        self.transactionsType = transactionsType
        self.transactionTypePublisher.send(transactionsType)
        self.filterApplied = filterApplied
        
        switch transactionsType {
        case .all:
            self.titlePublisher = .init("All")
        case .deposit:
            self.titlePublisher = .init("Deposits")
        case .withdraw:
            self.titlePublisher = .init("Withdraws")
        }
        self.calculateDate(filterApplied: filterApplied)
   
//        Env.everyMatrixClient.serviceStatusPublisher
//            .sink { serviceStatus in
//                if serviceStatus == .connected {
//                    self.initialContentLoad()
//                }
//            }
//            .store(in: &cancellables)
        self.setupPublishers()
        self.initialContentLoad()
       
    }

    private func setupPublishers() {

        Publishers.CombineLatest(self.transactionsPublisher, self.hasLoadedPendingWithdrawals)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] transactions, hasLoadedPendingWithdrawals in

                guard let self = self else { return }

                    if hasLoadedPendingWithdrawals {
                        if transactions.isEmpty {
                            self.listStatePublisher.send(.empty)
                        }
                        else {
                            self.listStatePublisher.send(.loaded)
                        }

                        self.hasLoadedPendingWithdrawals.send(false)
                    }

            })
            .store(in: &cancellables)
    }

    func initialContentLoad() {
        self.listStatePublisher.send(.loading)
        self.transactionsPublisher.send([])
        self.allTransactions.send([])
        self.depositTransactions.send([])
        self.withdrawTransactions.send([])

        switch self.transactionsType {
        case .all:
            self.loadAll(page: self.allPage)
        case .deposit:
            self.loadDeposits(page: self.depositPage)
        case .withdraw:
            self.loadWithdraws(page: self.withdrawPage)
        }

    }

    func refreshContent(withUserWalletRefresh: Bool = false) {

        if withUserWalletRefresh {
            Env.userSessionStore.refreshUserWallet()
        }

        self.allPage = 1
        self.depositPage = 1
        self.withdrawPage = 1

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
        case .all:
            return self.allTransactions.value.isNotEmpty && transactionsHasNextPage
        case .deposit:
            return self.depositTransactions.value.isNotEmpty && transactionsHasNextPage
        case .withdraw:
            return self.withdrawTransactions.value.isNotEmpty && transactionsHasNextPage

        }

    }

    func getPendingWithdrawals() {

        Env.servicesProvider.getPendingWithdrawals()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("PENDING WITHDRAWALS ERROR: \(error)")
                }
            }, receiveValue: { [weak self] pendingWithdrawals in

                self?.pendingWithdrawals = pendingWithdrawals
                self?.hasLoadedPendingWithdrawals.send(true)
            })
            .store(in: &cancellables)
    }

    func loadAll(page: Int, isNextPage: Bool = false) {

        if !isNextPage {
            self.listStatePublisher.send(.loading)
        }

        let startDate = self.getDateString(date: self.startDatePublisher.value)

        let endDate = self.getDateString(date: self.endDatePublisher.value)

        Env.servicesProvider.getTransactionsHistory(startDate: startDate, endDate: endDate, pageNumber: page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("TRANSACTIONS DEPOSITS ERROR: \(error)")

                    self?.transactionsPublisher.send([])

                    self?.listStatePublisher.send(.serverError)

                }
            }, receiveValue: { [weak self] transactionsDeposits in

                self?.processTransactions(transactions: transactionsDeposits, transactionType: .all)

            })
            .store(in: &cancellables)
    }

    func loadDeposits(page: Int, isNextPage: Bool = false) {

        if !isNextPage {
            self.listStatePublisher.send(.loading)
        }

        let startDate = self.getDateString(date: self.startDatePublisher.value)

        let endDate = self.getDateString(date: self.endDatePublisher.value)

        Env.servicesProvider.getTransactionsHistory(startDate: startDate, endDate: endDate, transactionType: "DEPOSIT", pageNumber: page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("TRANSACTIONS DEPOSITS ERROR: \(error)")

                    self?.transactionsPublisher.send([])

                    self?.listStatePublisher.send(.serverError)

                }
            }, receiveValue: { [weak self] transactionsDeposits in

                self?.processTransactions(transactions: transactionsDeposits, transactionType: .deposit)

            })
            .store(in: &cancellables)

//        Env.servicesProvider.getTransactionsHistory()
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//
//                switch completion {
//                case .finished:
//                    ()
//                case .failure(let error):
//                    print("TRANSACTIONS HISTORY ERROR: \(error)")
//
//                    self?.transactionsPublisher.send([])
//
//                    self?.listStatePublisher.send(.serverError)
//
//                }
//            }, receiveValue: { [weak self] transactionsHistoryResponse in
//
//                let transactionsHistoryResponse = transactionsHistoryResponse
//
//                if let transactions = transactionsHistoryResponse.transactions {
//
//                    self?.processTransactions(transactions: transactions)
//                }
//                else {
//                    self?.depositTransactions.send([])
//                    self?.transactionsPublisher.send([])
//                    self?.listStatePublisher.send(.empty)
//                }
//
//            })
//            .store(in: &cancellables)
    }

    func loadWithdraws(page: Int, isNextPage: Bool = false) {

        if !isNextPage {
            self.listStatePublisher.send(.loading)
        }

        let startDate = self.getDateString(date: self.startDatePublisher.value)

        let endDate = self.getDateString(date: self.endDatePublisher.value)

        Env.servicesProvider.getTransactionsHistory(startDate: startDate, endDate: endDate, transactionType: "WITHDRAWAL", pageNumber: page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("TRANSACTIONS WITHDRAWALS ERROR: \(error)")

                    self?.transactionsPublisher.send([])

                    self?.listStatePublisher.send(.serverError)

                }
            }, receiveValue: { [weak self] transactionsWithdrawals in

                self?.processTransactions(transactions: transactionsWithdrawals, transactionType: .withdraw)

            })
            .store(in: &cancellables)
//        let withdrawsRoute = TSRouter.getTransactionHistory(type: "Withdraw",
//                                                            startTime: convertDateToString(date: self.startDatePublisher.value),
//                                                            endTime: convertDateToString(date: self.endDatePublisher.value),
//                                                            pageIndex: page,
//                                                            pageSize: recordsPerPage)
//        Env.everyMatrixClient.manager.getModel(router: withdrawsRoute, decodingType: EveryMatrix.TransactionsHistoryResponse.self)
//            .map(\.transactions)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure(let apiError):
//                    self?.transactionsPublisher.send([])
//                    switch apiError {
//                    case .requestError(let value) where value.lowercased().contains("must be logged in to perform this action"):
//                        self?.listStatePublisher.send(.noUserFoundError)
//                    case .notConnected:
//                        self?.listStatePublisher.send(.noUserFoundError)
//                    default:
//                        self?.listStatePublisher.send(.serverError)
//                    }
//                case .finished:
//                    ()
//                }
//            }, receiveValue: { [weak self] withdrawsTransactions in
//                self?.withdrawTransactions.send(withdrawsTransactions)
//                //self?.transactionsPublisher.send(withdrawsTransactions)
//                if withdrawsTransactions.isEmpty {
//                    self?.listStatePublisher.send(.empty)
//                }
//                else {
//                    self?.listStatePublisher.send(.loaded)
//                }
//            })
//            .store(in: &cancellables)
    }

    func processTransactions(transactions: [TransactionDetail], transactionType: TransactionsType) {

        // Filter unwanted transactions types
        let unwantedTypes = ["RSV_COMMIT", "RESERVE", "RSV_CANCEL"]

        let filteredTransactions = transactions.filter({
            !unwantedTypes.contains($0.type)
        })

        let transactionsHistory = filteredTransactions.map { transactionDetail -> TransactionHistory in

            var valueType = TransactionValueType.neutral

            let transactionType = TransactionTypeMapper.init(transactionType: transactionDetail.type)?.transactionName ?? transactionDetail.type

            if transactionDetail.amount < 0.0 {
                valueType = .loss
            }
            else if transactionDetail.amount > 0.0 {
                valueType = .won
            }
            else {
                valueType = .neutral
            }

            let transactionHistory = TransactionHistory(transactionID: "\(transactionDetail.id)",
                                                        time: transactionDetail.dateTime,
                                                        type: transactionType,
                                                        valueType: valueType,
                                                        debit: DebitCredit(currency: transactionDetail.currency,
                                                                           amount: transactionDetail.amount,
                                                                           name: "Debit"),
                                                        credit: DebitCredit(currency: transactionDetail.currency,
                                                                            amount: transactionDetail.amount,
                                                                            name: "Credit"),
                                                        fees: [],
                                                        status: nil,
                                                        transactionReference: nil,
                                                        id: "\(transactionDetail.id)",
                                                        isRallbackAllowed: nil,
                                                        paymentId: transactionDetail.paymentId)

            return transactionHistory
        }

        if transactions.count < self.recordsPerPage {
            self.transactionsHasNextPage = false
        }

        switch transactionType {
        case .all:
            if self.allTransactions.value.isEmpty {
                self.allTransactions.send(transactionsHistory)
                self.transactionsPublisher.send(transactionsHistory)
            }
            else {
                var nextTransactions = self.allTransactions.value
                nextTransactions.append(contentsOf: transactionsHistory)
                self.allTransactions.send(nextTransactions)
                self.transactionsPublisher.send(nextTransactions)
            }

            self.getPendingWithdrawals()

        case .deposit:
            if self.depositTransactions.value.isEmpty {
                self.depositTransactions.send(transactionsHistory)
                self.transactionsPublisher.send(transactionsHistory)
            }
            else {
                var nextTransactions = self.depositTransactions.value
                nextTransactions.append(contentsOf: transactionsHistory)
                self.depositTransactions.send(nextTransactions)
                self.transactionsPublisher.send(nextTransactions)
            }

            self.hasLoadedPendingWithdrawals.send(true)
        case .withdraw:
            if self.withdrawTransactions.value.isEmpty {
                self.withdrawTransactions.send(transactionsHistory)
                self.transactionsPublisher.send(transactionsHistory)
            }
            else {
                var nextTransactions = self.withdrawTransactions.value
                nextTransactions.append(contentsOf: transactionsHistory)
                self.withdrawTransactions.send(nextTransactions)
                self.transactionsPublisher.send(nextTransactions)
            }

            self.getPendingWithdrawals()

        }

    }

    func cancelPendingTransaction(paymentId: Int) {

        Env.servicesProvider.cancelWithdrawal(paymentId: paymentId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("CANCEL WITHDRAWAL ERROR: \(error)")
                    self?.shouldShowAlert?(.error)

                }
            }, receiveValue: { [weak self] cancelWithdrawalResponse in

                self?.shouldShowAlert?(.success)
            })
            .store(in: &cancellables)

    }

//    func loadDeposits(page: Int) {
//        self.listStatePublisher.send(.loading)
//        let depositsRoute = TSRouter.getTransactionHistory(type: "Deposit",
//                                                           startTime: convertDateToString(date: self.startDatePublisher.value),
//                                                           endTime: convertDateToString(date: self.endDatePublisher.value),
//                                                           pageIndex: page,
//                                                           pageSize: recordsPerPage)
//
//        Env.everyMatrixClient.manager.getModel(router: depositsRoute, decodingType: EveryMatrix.TransactionsHistoryResponse.self)
//            .map(\.transactions)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure(let apiError):
//                    self?.transactionsPublisher.send([])
//                    switch apiError {
//                    case .requestError(let value) where value.lowercased().contains("must be logged in to perform this action"):
//                        self?.listStatePublisher.send(.noUserFoundError)
//                    case .notConnected:
//                        self?.listStatePublisher.send(.noUserFoundError)
//                    default:
//                        self?.listStatePublisher.send(.serverError)
//                    }
//                case .finished:
//                    ()
//                }
//            }, receiveValue: { [weak self] depositsTransactions in
//                let deposits = depositsTransactions
//                self?.depositTransactions.send(depositsTransactions)
//                //self?.transactionsPublisher.send(depositsTransactions)
//                if depositsTransactions.isEmpty {
//                    self?.listStatePublisher.send(.empty)
//                }
//                else {
//                    self?.listStatePublisher.send(.loaded)
//                }
//            })
//            .store(in: &cancellables)
//    }
    
    func convertDateToString(date: Date) -> String{
        let auxDate = "\(date)"
        let dateSplited = auxDate.split(separator: " ")
        return "\(dateSplited[0])"
        
    }

    func requestNextPage() {

        switch self.transactionsType {
        case .all:
//            if self.allTransactions.value.count < self.recordsPerPage * (self.allPage) {
//                self.transactionsHasNextPage = false
//                return
//            }
            if !self.transactionsHasNextPage {
                return
            }
            allPage += 1
            self.loadAll(page: allPage, isNextPage: true)
        case .deposit:
//            if self.depositTransactions.value.count < self.recordsPerPage * (self.depositPage) {
//                self.transactionsHasNextPage = false
//                return
//            }
            if !self.transactionsHasNextPage {
                return
            }
            depositPage += 1
            self.loadDeposits(page: depositPage, isNextPage: true)
        case .withdraw:
//            if self.withdrawTransactions.value.count < self.recordsPerPage * (self.withdrawPage) {
//                self.transactionsHasNextPage = false
//                return
//            }
            if !self.transactionsHasNextPage {
                return
            }
            withdrawPage += 1
            self.loadWithdraws(page: withdrawPage, isNextPage: true)
        }
    }

    private func getDateString(date: Date) -> String {
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let dateString = self.dateFormatter.string(from: date).appending("Z")

        return dateString
    }

}

extension TransactionsHistoryViewModel {

    func numberOfSections() -> Int {
        return 2
    }

    func numberOfRows() -> Int {
        switch self.transactionsType {
        case .all:
            return self.allTransactions.value.count
        case .deposit:
            return self.depositTransactions.value.count
        case .withdraw:
            return self.withdrawTransactions.value.count
        }
        //return self.transactionsPublisher.value.count
    }

    func transactionForRow(atIndex index: Int) -> TransactionHistory? {
        switch self.transactionsType {
        case .all:
            return self.allTransactions.value[safe: index]
        case .deposit:
            return self.depositTransactions.value[safe: index]
        case .withdraw:
            return self.withdrawTransactions.value[safe: index]
        }
        //return self.transactionsPublisher.value[safe: index]
    }

}
