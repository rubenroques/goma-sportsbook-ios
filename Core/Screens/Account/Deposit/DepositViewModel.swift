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

    var paymentMethodsResponse: SimplePaymentMethodsResponse?
    var shouldShowPaymentDropIn: CurrentValueSubject<Bool, Never> = .init(false)
    var depositAmount: String = ""

    // MARK: Lifetime and Cycle
    override init() {
        super.init()

    }

    // MARK: Functions
    func getDepositInfo(amountText: String) {
        self.isLoadingPublisher.send(true)
//
//        let amountText = amountText
//        let amount = amountText.replacingOccurrences(of: ",", with: ".")
//        var currency = ""
//        var gamingAccountId = ""
//
//        if let walletCurrency = Env.userSessionStore.userBalanceWallet.value?.currency {
//            currency = walletCurrency
//        }
//        else {
//
//            self.showErrorAlertTypePublisher.send(.wallet)
//            self.isLoadingPublisher.send(false)
//        }
//
//        if let walletGamingAccountId = Env.userSessionStore.userBalanceWallet.value?.id {
//            gamingAccountId = "\(walletGamingAccountId)"
//        }
//        else {
//
//            self.showErrorAlertTypePublisher.send(.wallet)
//            self.isLoadingPublisher.send(false)
//        }
//
//        Env.everyMatrixClient.getDepositResponse(currency: currency, amount: amount, gamingAccountId: gamingAccountId)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure:
//                    self?.showErrorAlertTypePublisher.send(.deposit)
//                case .finished:
//                    ()
//                }
//                self?.isLoadingPublisher.send(false)
//
//            }, receiveValue: { [weak self] value in
//
//                self?.cashierUrlPublisher.value = value.cashierUrl
//
//            })
//            .store(in: &cancellables)

        let amountText = amountText
        if amountText.contains(",") {
            let amount = amountText.replacingOccurrences(of: ",", with: "")
            self.depositAmount = amount
        }
        else {
            let amount = amountText.appending("00")
            self.depositAmount = amount
        }

        Env.servicesProvider.getPayments()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("PAYMENTS RESPONSE ERROR: \(error)")
                }
            }, receiveValue: { [weak self] paymentsResponse in
                print("PAYMENTS RESPONSE: \(paymentsResponse)")

                self?.paymentMethodsResponse = paymentsResponse

                self?.shouldShowPaymentDropIn.send(true)

                self?.isLoadingPublisher.send(false)
            })
            .store(in: &cancellables)
    }

}
