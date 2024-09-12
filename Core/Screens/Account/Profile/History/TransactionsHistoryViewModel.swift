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

    private var loadedInitialContent: Bool = false

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
   
        Env.servicesProvider.eventsConnectionStatePublisher
            .sink { serviceStatus in
                if !self.loadedInitialContent {
                    self.initialContentLoad()
                    self.loadedInitialContent = true
                }
            }
            .store(in: &cancellables)

        self.setupPublishers()
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
        default:
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

        let types = TransactionType.allCases

        Env.servicesProvider.getTransactionsHistory(startDate: startDate, endDate: endDate, transactionTypes: types, pageNumber: page)
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

                guard let self = self else { return }

                let filteredTransactions = transactionsDeposits.filter({
                    $0.type != .automatedWithdrawal
                })

                if transactionsDeposits.count < self.recordsPerPage {
                    self.transactionsHasNextPage = false
                }

                self.processTransactions(transactions: filteredTransactions, transactionType: .all)
            })
            .store(in: &cancellables)
    }

    func loadDeposits(page: Int, isNextPage: Bool = false) {

        if !isNextPage {
            self.listStatePublisher.send(.loading)
        }

        let startDate = self.getDateString(date: self.startDatePublisher.value)

        let endDate = self.getDateString(date: self.endDatePublisher.value)

        let types = [TransactionType.deposit]

        Env.servicesProvider.getTransactionsHistory(startDate: startDate, endDate: endDate, transactionTypes: types, pageNumber: page)
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

                guard let self = self else { return }

                let filteredTransactions = transactionsDeposits.filter({
                    $0.type != .automatedWithdrawal
                })

                if transactionsDeposits.count < self.recordsPerPage {
                    self.transactionsHasNextPage = false
                }

                self.processTransactions(transactions: filteredTransactions, transactionType: .deposit)

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

        let types = [TransactionType.withdrawal, TransactionType.withdrawalCancel, TransactionType.withdrawalReject,
            TransactionType.automatedWithdrawalThreshold]

        Env.servicesProvider.getTransactionsHistory(startDate: startDate, endDate: endDate, transactionTypes: types, pageNumber: page)
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

                guard let self = self else { return }

                let filteredTransactions = transactionsWithdrawals.filter({
                    $0.type != .automatedWithdrawal
                }).filter({
                    $0.type != .automatedWithdrawalThreshold && $0.escrowType != "ESC_AML"
                })

                if transactionsWithdrawals.count < self.recordsPerPage {
                    self.transactionsHasNextPage = false
                }

                self.processTransactions(transactions: filteredTransactions, transactionType: .withdraw)

            })
            .store(in: &cancellables)

    }

    func processTransactions(transactions: [TransactionDetail], transactionType: TransactionsType) {
        
        var transactionsHistory = transactions.map { transactionDetail -> TransactionHistory in

            let transactionHistory = ServiceProviderModelMapper.transactionHistory(fromServiceProviderTransactionDetail: transactionDetail)

            return transactionHistory
        }

        switch transactionType {
        case .all:
            if self.allTransactions.value.isEmpty {
                
                let verifiedTransactionHistory = self.verifyTransactionsHistory(transactionsHistory: transactionsHistory)
                
                self.allTransactions.send(verifiedTransactionHistory)
                self.transactionsPublisher.send(verifiedTransactionHistory)
            }
            else {
                var nextTransactions = self.allTransactions.value
                nextTransactions.append(contentsOf: transactionsHistory)
                
                let verifiedTransactionHistory = self.verifyTransactionsHistory(transactionsHistory: nextTransactions)
                
                self.allTransactions.send(verifiedTransactionHistory)
                self.transactionsPublisher.send(verifiedTransactionHistory)
            }

            self.getPendingWithdrawals()

        case .deposit:
            if self.depositTransactions.value.isEmpty {
                
                let verifiedTransactionHistory = self.verifyTransactionsHistory(transactionsHistory: transactionsHistory)
                
                self.depositTransactions.send(transactionsHistory)
                self.transactionsPublisher.send(transactionsHistory)
            }
            else {
                var nextTransactions = self.depositTransactions.value
                nextTransactions.append(contentsOf: transactionsHistory)
                
                let verifiedTransactionHistory = self.verifyTransactionsHistory(transactionsHistory: nextTransactions)
                
                self.depositTransactions.send(verifiedTransactionHistory)
                self.transactionsPublisher.send(verifiedTransactionHistory)
            }

            self.hasLoadedPendingWithdrawals.send(true)
        case .withdraw:
            if self.withdrawTransactions.value.isEmpty {
                
                let verifiedTransactionHistory = self.verifyTransactionsHistory(transactionsHistory: transactionsHistory)
                
                self.withdrawTransactions.send(verifiedTransactionHistory)
                self.transactionsPublisher.send(verifiedTransactionHistory)
            }
            else {
                var nextTransactions = self.withdrawTransactions.value
                nextTransactions.append(contentsOf: transactionsHistory)
                
                let verifiedTransactionHistory = self.verifyTransactionsHistory(transactionsHistory: nextTransactions)
                
                self.withdrawTransactions.send(verifiedTransactionHistory)
                self.transactionsPublisher.send(verifiedTransactionHistory)
            }

            self.getPendingWithdrawals()

        }

    }
    
//    func verifyTransactionsDetail(transactionsDetail: [TransactionDetail]) -> [TransactionDetail] {
//        // Initial setup
//        var skipNextTwo = false
//        var matchCount = 0
//        
//        var transactionsList = [TransactionDetail]()
//
//        transactionsDetail.enumerated().forEach { index, element in
//                // Early return if skipNextTwo is active
//                if skipNextTwo {
//                    skipNextTwo = matchCount > 0
//                    matchCount -= 1
//                    return
//                }
//
//            // Check if element.tranType is 'DP_RBACK'
//            if element.type == .depositReturned {
//                    // Safely get the next and third elements
//                    let nextElement = transactionsDetail[safe: index + 1]
//                    let thirdElement = transactionsDetail[safe: index + 2]
//
//                    // Check conditions for nextElement and thirdElement
//                    if let nextElement = nextElement,
//                       nextElement.reference == nil,
//                       nextElement.escrowTranType == "TRANSFER",
//                       nextElement.escrowTranSubType == "TO_ACCOUNT",
//                       nextElement.escrowType == "ESC_AML",
//                       let thirdElement = thirdElement,
//                       thirdElement.reference == "ESC_AML",
//                       thirdElement.escrowTranType == "TRANSFER",
//                       thirdElement.escrowTranSubType == "FROM_ACCOUNT",
//                       thirdElement.escrowType == "ESC_AML" {
//
//                        // Modify the tranType
//                        let newElement = TransactionDetail(id: element.id, dateTime: element.dateTime, type: .depositCancel, amount: element.amount, postBalance: element.postBalance, amountBonus: element.amountBonus, postBalanceBonus: element.postBalanceBonus, currency: element.currency, paymentId: element.paymentId, gameTranId: element.gameTranId, reference: element.reference, escrowTranType: element.escrowTranType, escrowTranSubType: element.escrowTranSubType, escrowType: element.escrowType)
//
//                        // Add to transactionsList and adjust flags
//                        transactionsList.append(newElement)
//                        skipNextTwo = true
//                        matchCount = 1
//                        return
//                    }
//                }
//
//                // Add element to transactionsList
//                transactionsList.append(element)
//            }
//        
//        return transactionsList
//    }
    
    func verifyTransactionsHistory(transactionsHistory: [TransactionHistory]) -> [TransactionHistory] {
        // Initial setup
        var skipNextTwo = false
        var matchCount = 0
        
        var transactionsList = [TransactionHistory]()

        transactionsHistory.enumerated().forEach { index, element in
                // Early return if skipNextTwo is active
                if skipNextTwo {
                    skipNextTwo = matchCount > 0
                    matchCount -= 1
                    return
                }

            // Check if element.tranType is 'DP_RBACK'
            if element.transactionType == .depositReturned {
                    // Safely get the next and third elements
                    let nextElement = transactionsHistory[safe: index + 1]
                    let thirdElement = transactionsHistory[safe: index + 2]

                    // Check conditions for nextElement and thirdElement
                    if let nextElement = nextElement,
                       nextElement.reference == nil,
                       nextElement.escrowTranType == "TRANSFER",
                       nextElement.escrowTranSubType == "TO_ACCOUNT",
                       nextElement.escrowType == "ESC_AML",
                       let thirdElement = thirdElement,
                       thirdElement.reference == "ESC_AML",
                       thirdElement.escrowTranType == "TRANSFER",
                       thirdElement.escrowTranSubType == "FROM_ACCOUNT",
                       thirdElement.escrowType == "ESC_AML" {

                        // Modify the tranType
                        let newElement = TransactionHistory(transactionID: element.transactionID, time: element.time, type: localized("deposit_cancel"), transactionType: .depositReturned, valueType: element.valueType, debit: element.debit, credit: element.credit, fees: element.fees, status: element.status, transactionReference: element.transactionReference, id: element.id, isRallbackAllowed: element.isRallbackAllowed, paymentId: element.paymentId, reference: element.reference, escrowTranType: element.escrowTranType, escrowTranSubType: element.escrowTranSubType, escrowType: element.escrowType)

                        // Add to transactionsList and adjust flags
                        transactionsList.append(newElement)
                        skipNextTwo = true
                        matchCount = 1
                        return
                    }
                }

                // Add element to transactionsList
                transactionsList.append(element)
            }
        
        return transactionsList
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

    func convertDateToString(date: Date) -> String{
        let auxDate = "\(date)"
        let dateSplited = auxDate.split(separator: " ")
        return "\(dateSplited[0])"
        
    }

    func requestNextPage() {

        switch self.transactionsType {
        case .all:
            if !self.transactionsHasNextPage {
                return
            }
            allPage += 1
            self.loadAll(page: allPage, isNextPage: true)
        case .deposit:
            if !self.transactionsHasNextPage {
                return
            }
            depositPage += 1
            self.loadDeposits(page: depositPage, isNextPage: true)
        case .withdraw:
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
