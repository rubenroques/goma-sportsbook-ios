//
//  PaymentsDropIn.swift
//  Sportsbook
//
//  Created by André Lascas on 31/01/2023.
//

import Foundation
import Adyen
import AdyenDropIn
import Combine
import ServicesProvider

class PaymentsDropIn {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var shouldShowPaymentDropIn: CurrentValueSubject<Bool, Never> = .init(false)
    var hasPaymentOptions: CurrentValueSubject<Bool, Never> = .init(false)
    var hasProcessedDeposit: CurrentValueSubject<Bool, Never> = .init(false)
    var showErrorAlertTypePublisher: CurrentValueSubject<BalanceErrorType?, Never> = .init(nil)
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    var dropInDepositAmount: String = ""
    var depositAmount: Double = 0.0
    var clientKey: String?
    var paymentId: String?
    var paymentMethodsResponse: SimplePaymentMethodsResponse?

    // MARK: Lifetime and Cycle
    init() {

        self.setupPublishers()
    }

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

        let amountText = amountText
        if amountText.contains(",") {
            var dropInAmount = ""
            let amountSplit = amountText.split(separator: ",")

            if let decimals = amountSplit[safe: 1],
               let numbers = amountSplit[safe: 0] {
                if decimals.count == 1 {
                    var fullDecimal = "\(decimals)0"
                    dropInAmount = "\(numbers)\(fullDecimal)"
                }
                else {
                    dropInAmount = amountText.replacingOccurrences(of: ",", with: "")
                }
            }
            
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

    func setupPaymentDropIn() -> DropInComponent? {

        if let paymentMethodsResponse = self.paymentMethodsResponse,
           let clientKey = self.clientKey,
           let apiContext = try? APIContext(environment: Adyen.Environment.test, clientKey: clientKey) {

            if let paymentResponseData = try? JSONEncoder().encode(paymentMethodsResponse),
                let paymentMethods = try? JSONDecoder().decode(PaymentMethods.self, from: paymentResponseData) {

                // Optional Payment
                let payment = Payment(amount: Amount(value: Int(self.dropInDepositAmount) ?? 0, currencyCode: "EUR"), countryCode: "PT")

                let dropInComponent = DropInComponent(paymentMethods: paymentMethods, context: AdyenContext(apiContext: apiContext, payment: payment))

                return dropInComponent

            }

            return nil
        }

        return nil
    }
}
