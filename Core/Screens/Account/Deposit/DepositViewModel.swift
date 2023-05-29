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

    // MARK: Public Properties
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var showErrorAlertTypePublisher: CurrentValueSubject<BalanceErrorType?, Never> = .init(nil)
    var cashierUrlPublisher: CurrentValueSubject<String?, Never> = .init(nil)
    var minimumValue: CurrentValueSubject<String, Never> = .init("")

//    var paymentMethodsResponse: SimplePaymentMethodsResponse?
    var shouldShowPaymentDropIn: CurrentValueSubject<Bool, Never> = .init(false)
//    var hasPaymentOptions: CurrentValueSubject<Bool, Never> = .init(false)
//    var hasProcessedDeposit: CurrentValueSubject<Bool, Never> = .init(false)
//
//    var dropInDepositAmount: String = ""
//    var depositAmount: Double = 0.0
//    var clientKey: String?
//    var paymentId: String?
    var paymentsDropIn: PaymentsDropIn

    var availableBonuses: CurrentValueSubject<[AvailableBonus], Never> = .init([])

    var bonusState: BonusState = .declined

    // MARK: Lifetime and Cycle
    override init() {

        self.paymentsDropIn = PaymentsDropIn()

        super.init()

        self.setupPublishers()

        self.getOptInBonus()

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

        self.minimumValue.send("20.00")
    }

    func getDepositInfo(amountText: String) {

        if self.bonusState == .accepted {
            if let bonusId = self.availableBonuses.value.first?.id {
                self.redeemBonus(bonusId: bonusId)
            }
        }

        self.paymentsDropIn.getDepositInfo(amountText: amountText)
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

    private func redeemBonus(bonusId: String) {

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
                    }
                }, receiveValue: { [weak self] redeemAvailableBonusResponse in

                    print("REDEEM CODE SUCCESS: \(redeemAvailableBonusResponse)")

                })
                .store(in: &cancellables)
        }
    }
    
}
