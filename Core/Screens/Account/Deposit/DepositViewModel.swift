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

    // MARK: Lifetime and Cycle
    override init() {

        self.paymentsDropIn = PaymentsDropIn()

        super.init()

        self.setupPublishers()
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

        self.minimumValue.send("50.00")
    }

    func getDepositInfo(amountText: String) {
        self.paymentsDropIn.getDepositInfo(amountText: amountText)
    }

}
