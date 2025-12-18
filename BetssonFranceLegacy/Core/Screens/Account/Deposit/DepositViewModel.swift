//
//  DepositViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 31/03/2022.
//

import Foundation
import Combine
import ServicesProvider
import OptimoveSDK

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

//    var isFirstDeposit: Bool = true
    var isFirstDeposit: CurrentValueSubject<Bool, Never> = .init(true)


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
            // Send Event with no bonus
            let bonusAvailable = self.availableBonuses.value.isEmpty ? "no" : "yes"
            
            let amountDouble = self.getAmountAsDouble(amountText: amountText)
            
            Optimove.shared.reportEvent(
                name: "deposit_started",
                parameters: [
                    "partyId": "\(Env.userSessionStore.userProfilePublisher.value?.userIdentifier ?? "")",
                    "amount": amountDouble,
                    "bonus_available": bonusAvailable,
                    "bonus_accepted": "no"
                ]
            )
            
            Optimove.shared.reportScreenVisit(screenTitle: "deposit_started")
            
            AnalyticsClient.sendEvent(event: .depositStarted(value: amountDouble, bonusAvailable: bonusAvailable, bonusAccepted: "no"))
            
            self.paymentsDropIn.setupBonusInfo(bonusAvailable: bonusAvailable == "yes" ? true : false, bonusAccepted: false)
            
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
        
        if let userProfile = Env.userSessionStore.userProfilePublisher.value {
            
            self.isFirstDeposit.send(!userProfile.hasMadeDeposit)
            
        }
        else {
            self.isFirstDeposit.send(false)
        }
//        let endDate = Date()
//        var startDate = endDate
//
//        let calendar = Calendar.current
//        var oneYearAgoComponents = DateComponents()
//        oneYearAgoComponents.year = -1
//
//        if let startDateFinal = calendar.date(byAdding: oneYearAgoComponents, to: endDate) {
//            startDate = startDateFinal
//        } else {
//            print("There was an error calculating the date.")
//        }
//
//        let startDateString = self.getDateString(date: startDate)
//
//        let endDateString = self.getDateString(date: endDate)
//
//        Env.servicesProvider.getTransactionsHistory(startDate: startDateString, endDate: endDateString, transactionTypes: [TransactionType.deposit], pageNumber: 1)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//
//                switch completion {
//                case .finished:
//                    ()
//                case .failure(let error):
//                    print("TRANSACTIONS WITHDRAWALS ERROR: \(error)")
//                    self?.isFirstDeposit.send(false)
//
//                }
//            }, receiveValue: { [weak self] transactionsWithdrawals in
//
//                guard let self = self else { return }
//
//                self.isFirstDeposit.value = transactionsWithdrawals.isNotEmpty ? false : true
//
//            })
//            .store(in: &cancellables)
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

                    // Send Event with bonus
                    let amountDouble = self?.getAmountAsDouble(amountText: amountText) ?? 0.0
                    
                    Optimove.shared.reportEvent(
                        name: "deposit_started",
                        parameters: [
                            "partyId": partyId,
                            "amount": amountDouble,
                            "bonus_available": "yes",
                            "bonus_accepted": "yes"
                        ]
                    )
                    
                    Optimove.shared.reportScreenVisit(screenTitle: "deposit_started")
                    
                    AnalyticsClient.sendEvent(event: .depositStarted(value: amountDouble, bonusAvailable: "yes", bonusAccepted: "yes"))
                    
                    self?.paymentsDropIn.setupBonusInfo(bonusAvailable: true, bonusAccepted: true)

                    self?.paymentsDropIn.getDepositInfo(amountText: amountText)

                })
                .store(in: &cancellables)
        }
    }
    
    private func getAmountAsDouble(amountText: String) -> Double {
        if amountText.contains(",") {
            let amount = amountText.replacingOccurrences(of: ",", with: ".")
            return Double(amount) ?? 0.0
        }
        else {
            return Double(amountText) ?? 0.0
        }
    }
}
