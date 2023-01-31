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
    var hasPaymentOptions: CurrentValueSubject<Bool, Never> = .init(false)
    var hasProcessedDeposit: CurrentValueSubject<Bool, Never> = .init(false)

    var dropInDepositAmount: String = ""
    var depositAmount: Double = 0.0
    var clientKey: String?
    var paymentId: String?

    // MARK: Lifetime and Cycle
    override init() {
        super.init()

        self.setupPublishers()
    }

    // MARK: Functions
    private func setupPublishers() {

        Publishers.CombineLatest(self.hasProcessedDeposit, self.hasPaymentOptions)
            .sink(receiveValue: { [weak self] hasProcessedDeposit, hasPaymentOptions in

                if hasProcessedDeposit && hasPaymentOptions {
                    self?.shouldShowPaymentDropIn.send(true)

                    self?.isLoadingPublisher.send(false)
                }
            })
            .store(in: &cancellables)
    }

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
            let dropInAmount = amountText.replacingOccurrences(of: ",", with: "")
            let amount = amountText.replacingOccurrences(of: ",", with: ".")
            self.dropInDepositAmount = dropInAmount
            self.depositAmount = Double(amount) ?? 0.0
        }
        else {
            let dropInAmount = amountText.appending("00")
            self.dropInDepositAmount = dropInAmount
            self.depositAmount = Double(amountText) ?? 0.0
        }

        self.processDepositResponse(amount: self.depositAmount)

    }

    private func processDepositResponse(amount: Double) {

        Env.servicesProvider.processDeposit(paymentMethod: "ADYEN_IDEAL", amount: amount, option: "DROP_IN")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("PROCESS DEPOSIT RESPONSE ERROR: \(error)")
                    switch error {
                    case .errorMessage(let message):
                        self?.showErrorAlertTypePublisher.send(.error(message: message))
                    default:
                        ()
                    }
                    self?.isLoadingPublisher.send(false)
                }
            }, receiveValue: { [weak self] processDepositResponse in
                print("PROCESS DEPOSIT RESPONSE: \(processDepositResponse)")

                self?.clientKey = processDepositResponse.clientKey

                self?.paymentId = processDepositResponse.paymentId
                
                self?.getPaymentMethods()

                self?.hasProcessedDeposit.send(true)
            })
            .store(in: &cancellables)

    }

    private func getPaymentMethods() {

        Env.servicesProvider.getPayments()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("PAYMENTS RESPONSE ERROR: \(error)")
                    self?.isLoadingPublisher.send(false)
                }
            }, receiveValue: { [weak self] paymentsResponse in
                print("PAYMENTS RESPONSE: \(paymentsResponse)")

                self?.paymentMethodsResponse = paymentsResponse

                self?.hasPaymentOptions.send(true)


            })
            .store(in: &cancellables)
    }

}
