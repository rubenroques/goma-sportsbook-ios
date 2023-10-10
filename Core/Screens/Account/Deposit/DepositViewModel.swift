//
//  DepositViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 31/03/2022.
//

import Foundation
import Combine
import ServicesProvider

class DepositViewModel: NSObject {
    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let dateFormatter = DateFormatter()

    // MARK: Public Properties
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var showErrorAlertTypePublisher: CurrentValueSubject<BalanceErrorType?, Never> = .init(nil)
    var cashierUrlPublisher: CurrentValueSubject<String?, Never> = .init(nil)
    var minimumValue: CurrentValueSubject<String, Never> = .init("")
    var shouldShowPaymentDropIn: CurrentValueSubject<Bool, Never> = .init(false)
    var presentSafariViewControllerAction: ((URL) -> Void) = { _ in } {
        didSet {
            self.paymentsDropIn.presentSafariViewControllerAction = self.presentSafariViewControllerAction
        }
    }
    
    var paymentsDropIn: PaymentsDropIn

    var availableBonuses: CurrentValueSubject<[AvailableBonus], Never> = .init([])

    var bonusState: BonusState = .nonExistent

    var isFirstDeposit: Bool = true

    // MARK: Lifetime and Cycle
    override init() {
        self.paymentsDropIn = PaymentsDropIn()
        self.paymentsDropIn.presentSafariViewControllerAction = self.presentSafariViewControllerAction
        
        super.init()

        self.setupPublishers()
        self.getOptInBonus()

        self.getDepositHistory()
    }

    // MARK: Functions
    private func setupPublishers() {

        self.paymentsDropIn.shouldShowPaymentDropIn
            .sink(receiveValue: { [weak self] shouldShowDropIn in
                if shouldShowDropIn {
                    self?.shouldShowPaymentDropIn.send(shouldShowDropIn)

                }
            })
            .store(in: &cancellables)

        self.paymentsDropIn.isLoadingPublisher.sink(receiveValue: { [weak self] isLoading in
            self?.isLoadingPublisher.send(isLoading)
        })
        .store(in: &cancellables)

        self.paymentsDropIn.showErrorAlertTypePublisher
            .sink(receiveValue: { [weak self] errorType in

                self?.showErrorAlertTypePublisher.send(errorType)
            })
            .store(in: &cancellables)

        self.paymentsDropIn.shouldProccessPayment = { [weak self] paymentInfo in
            print(paymentInfo)
        }

//        self.minimumValue.send("20.00")
    }

    func getDepositInfo(amountText: String) {

        if self.bonusState == .accepted {
            if let bonusId = self.availableBonuses.value.first?.id {
                self.redeemBonus(bonusId: bonusId, amountText: amountText)
            }
        }
        else {
            self.paymentsDropIn.getDepositInfo(amountText: amountText)
        }

    }

    private func getOptInBonus() {

        Env.servicesProvider.getAvailableBonuses()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("AVAILABLE BONUSES ERROR: \(error)")
                }

            }, receiveValue: { [weak self] availableBonuses in

                let filteredBonus = availableBonuses.filter({
                    $0.type == "DEPOSIT"
                })

                self?.availableBonuses.send(filteredBonus)

            })
            .store(in: &cancellables)

    }

    private func getDepositHistory() {

        let endDate = Date()
        var startDate = endDate

        let calendar = Calendar.current
        var oneYearAgoComponents = DateComponents()
        oneYearAgoComponents.year = -1

        if let startDateFinal = calendar.date(byAdding: oneYearAgoComponents, to: endDate) {
            startDate = startDateFinal
        } else {
            print("There was an error calculating the date.")
        }

        let startDateString = self.getDateString(date: startDate)

        let endDateString = self.getDateString(date: endDate)

        Env.servicesProvider.getTransactionsHistory(startDate: startDateString, endDate: endDateString, transactionTypes: [TransactionType.deposit], pageNumber: 1)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("TRANSACTIONS WITHDRAWALS ERROR: \(error)")

                }
            }, receiveValue: { [weak self] transactionsWithdrawals in

                guard let self = self else { return }

                self.isFirstDeposit = transactionsWithdrawals.isNotEmpty ? false : true

            })
            .store(in: &cancellables)
    }

    private func getDateString(date: Date) -> String {
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let dateString = self.dateFormatter.string(from: date).appending("Z")

        return dateString
    }

    private func redeemBonus(bonusId: String, amountText: String) {

//        self.showErrorAlertTypePublisher.send(.bonus)

        if let partyId = Env.userSessionStore.userProfilePublisher.value?.userIdentifier {

            Env.servicesProvider.redeemAvailableBonus(partyId: partyId, code: bonusId)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in

                    switch completion {
                    case .finished:
                        ()
                    case .failure(let error):
                        print("REDEEM AVAILABLE BONUS ERROR: \(error)")
                        switch error {
                        case .errorMessage(let message):
                            if message == "BONUSPLAN_NOT_FOUND" {
                                print("REDEEM BONUS ERROR: \(message)")
                            }
                            else {
                                print("REDEEM BONUS ERROR: \(message)")
                            }
                        default:
                            ()
                        }

                        self?.showErrorAlertTypePublisher.send(.bonus)
                    }
                }, receiveValue: { [weak self] redeemAvailableBonusResponse in

                    print("REDEEM CODE SUCCESS: \(redeemAvailableBonusResponse)")

                    self?.paymentsDropIn.getDepositInfo(amountText: amountText)

                })
                .store(in: &cancellables)
        }
    }
    
}
