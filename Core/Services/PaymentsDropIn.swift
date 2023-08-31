//
//  PaymentsDropIn.swift
//  Sportsbook
//
//  Created by André Lascas on 31/01/2023.
//

import Foundation
import Adyen
import AdyenDropIn
import AdyenSession
import Combine
import ServicesProvider

class PaymentsDropIn {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var shouldShowPaymentDropIn: CurrentValueSubject<Bool, Never> = .init(false)
    var hasPaymentOptions: CurrentValueSubject<Bool, Never> = .init(false)
    var hasProcessedDeposit: CurrentValueSubject<Bool, Never> = .init(false)
    var hasSessionInitialized: CurrentValueSubject<Bool, Never> = .init(false)
    var showErrorAlertTypePublisher: CurrentValueSubject<BalanceErrorType?, Never> = .init(nil)
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var shouldProccessPayment: ((String) -> Void)?
    var showPaymentStatus: ((PaymentStatus) -> Void)?

    var dropInDepositAmount: String = ""
    var depositAmount: Double = 0.0
    var clientKey: String?
    var paymentId: String?
    var sessionId: String?
    var sessionData: String?
    var adyenSession: AdyenSession?
    var apiContext: APIContext?
    var payment: Payment?
    var paymentMethodsResponse: SimplePaymentMethodsResponse?
    var dropInComponent: DropInComponent?

    // MARK: Lifetime and Cycle
    init() {

        self.setupPublishers()

        //AdyenLogging.isEnabled = true
    }

    private func setupPublishers() {

        Publishers.CombineLatest(self.hasProcessedDeposit, self.hasPaymentOptions)
            .sink(receiveValue: { [weak self] hasProcessedDeposit, hasPaymentOptions in

                if hasProcessedDeposit && hasPaymentOptions {

                    self?.setupSession()

                    self?.hasProcessedDeposit.value = false
                    self?.hasPaymentOptions.value = false
                }
            })
            .store(in: &cancellables)

        self.hasSessionInitialized
            .sink(receiveValue: { [weak self] hasSession in

                if hasSession {
                    self?.shouldShowPaymentDropIn.send(true)
                    self?.isLoadingPublisher.send(false)
                }
            })
            .store(in: &cancellables)
    }

    private func setupSession() {

        if let clientKey = self.clientKey,
           let apiContext = try? APIContext(environment: Adyen.Environment.test, clientKey: clientKey) {
            // test_HNOW5H423JB7JEJYVXMQF655YAT7M5IB
            self.apiContext = apiContext

            if let sessionId = self.sessionId,
               let sessionData = self.sessionData {

                // Optional Payment
                let payment = Payment(amount: Amount(value: Int(self.dropInDepositAmount) ?? 0, currencyCode: "EUR"), countryCode: "FR")

                self.payment = payment

                let adyenSessionConfiguration = AdyenSession.Configuration(sessionIdentifier: sessionId,
                                                                           initialSessionData: sessionData,
                                                                           context: AdyenContext(apiContext: apiContext, payment: payment))

                AdyenSession.initialize(with: adyenSessionConfiguration, delegate: self, presentationDelegate: self) { [weak self] result in
                        switch result {
                        case let .success(session):
                            //Store the session object.
                            self?.adyenSession = session
                            self?.hasSessionInitialized.send(true)
                        case let .failure(error):
                            //Handle the error.
                            print("ADYEN SESSION INIT FAILURE: \(error)")
                        }
                    }
            }
        }
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
                    let fullDecimal = "\(decimals)0"
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
        else if amountText.contains(".") {
            var dropInAmount = ""
            let amountSplit = amountText.split(separator: ".")

            if let decimals = amountSplit[safe: 1],
               let numbers = amountSplit[safe: 0] {
                if decimals.count == 1 {
                    let fullDecimal = "\(decimals)0"
                    dropInAmount = "\(numbers)\(fullDecimal)"
                }
                else {
                    dropInAmount = amountText.replacingOccurrences(of: ".", with: "")
                }
            }

            self.dropInDepositAmount = dropInAmount
            self.depositAmount = Double(amountText) ?? 0.0
        }
        else {
            let dropInAmount = amountText.appending("00")
            self.dropInDepositAmount = dropInAmount
            self.depositAmount = Double(amountText) ?? 0.0
        }

        self.processDepositResponse(amount: self.depositAmount)
    }

    private func processDepositResponse(amount: Double) {

        print("AMOUNT DEPOSIT: \(amount)")

        // TODO: ADYEN_IDEAL -> ADYEN_CARD
        Env.servicesProvider.processDeposit(paymentMethod: "ADYEN_CARD", amount: amount, option: "DROP_IN")
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

                self?.clientKey = processDepositResponse.clientKey

                self?.paymentId = processDepositResponse.paymentId

                self?.sessionId = processDepositResponse.sessionId

                self?.sessionData = processDepositResponse.sessionData

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

                self?.paymentMethodsResponse = paymentsResponse

                self?.hasPaymentOptions.send(true)

            })
            .store(in: &cancellables)
    }

    func setupPaymentDropIn() -> DropInComponent? {

        if let paymentMethodsResponse = self.paymentMethodsResponse,
           let clientKey = self.clientKey,
           let apiContext = self.apiContext,
           let payment = self.payment ,
           let session = self.adyenSession {

            if let paymentResponseData = try? JSONEncoder().encode(paymentMethodsResponse),
                let paymentMethods = try? JSONDecoder().decode(PaymentMethods.self, from: paymentResponseData) {

                // Optional Payment
                let payment = Payment(amount: Amount(value: Int(self.dropInDepositAmount) ?? 0, currencyCode: "EUR"), countryCode: "FR")

                let adyenContext = AdyenContext(apiContext: apiContext, payment: payment)

                // Without session payments
//                let dropInConfiguration = DropInComponent.Configuration()
//
//                dropInConfiguration.card.allowedCardTypes = [.visa, .masterCard, .carteBancaire]
//
//                let dropInComponent = DropInComponent(paymentMethods: paymentMethods, context: adyenContext, configuration: dropInConfiguration)

                // With session payments
                let dropInComponent = DropInComponent(paymentMethods: session.sessionContext.paymentMethods, context: adyenContext)

                dropInComponent.delegate = self.adyenSession

                self.dropInComponent = dropInComponent

                return dropInComponent

            }

            return nil
        }

        return nil
    }

    func cancelDeposit(paymentId: String) {

        Env.servicesProvider.cancelDeposit(paymentId: paymentId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("CANCEL DEPOSIT ERROR: \(error)")
                    self?.showPaymentStatus?(.refused)

                }
            }, receiveValue: { [weak self] cancelDepositResponse in

                print("CANCEL DEPOSIT SUCCESS: \(cancelDepositResponse)")


            })
            .store(in: &cancellables)
    }
}

extension PaymentsDropIn: DropInComponentDelegate, AdyenSessionDelegate, PresentationDelegate {

    func didSubmit(_ data: Adyen.PaymentComponentData, from component: Adyen.PaymentComponent, in dropInComponent: Adyen.AnyDropInComponent) {

        if let paymentIssuerType = data.paymentMethod.dictionary.value?["type"],
           let paymentId = self.paymentId {

            let paymentIssuer = "\(paymentIssuerType)"
            let amount = self.depositAmount

            // TODO: Not working, enable later
            self.shouldProccessPayment?("\(paymentIssuer) - \(amount)")
//            Env.servicesProvider.updatePayment(paymentMethod: "ADYEN_IDEAL", amount: amount, paymentId: paymentId, type: "ideal", issuer: paymentIssuer)
//                .receive(on: DispatchQueue.main)
//                .sink(receiveCompletion: { [weak self] completion in
//                    switch completion {
//                    case .finished:
//                        ()
//                    case .failure(let error):
//                        print("UPDATE PAYMENT RESPONSE ERROR: \(error)")
//                        switch error {
//                        case .errorMessage(let message):
//                            self?.showErrorAlert(errorType: .error(message: message))
//                        default:
//                            ()
//                        }
//                    }
//
//                }, receiveValue: { [weak self] updatePaymentResponse in
//                    print("UPDATE PAYMENT RESPONSE: \(updatePaymentResponse)")
//                })
//                .store(in: &cancellables)
        }

    }

    func didFail(with error: Error, from component: Adyen.PaymentComponent, in dropInComponent: Adyen.AnyDropInComponent) {

        print("PAYMENT FAIL: \(error)")

        dropInComponent.viewController.dismiss(animated: true)

    }

    func didProvide(_ data: Adyen.ActionComponentData, from component: Adyen.ActionComponent, in dropInComponent: Adyen.AnyDropInComponent) {

        print("PAYMENT PROVIDE: \(data)")

    }

    func didComplete(from component: Adyen.ActionComponent, in dropInComponent: Adyen.AnyDropInComponent) {

        print("PAYMENT COMPLETE")

    }

    func didFail(with error: Error, from component: Adyen.ActionComponent, in dropInComponent: Adyen.AnyDropInComponent) {

        print("PAYMENT FAIL 2: \(error)")

    }

    func didFail(with error: Error, from dropInComponent: Adyen.AnyDropInComponent) {

        print("PAYMENT FAIL FULL: \(error)")

        dropInComponent.viewController.dismiss(animated: true)

    }

    func didCancel(component: PaymentComponent, from dropInComponent: AnyDropInComponent) {
        print("PAYMENT CANCEL")

        dropInComponent.viewController.dismiss(animated: true)
    }

    // ADYEN SESSION
    // LEGACY COMPLETE
//    func didComplete(with resultCode: SessionPaymentResultCode, component: Adyen.Component, session: AdyenSession) {
//
//        print("ADYEN SESSION RESULT: \(resultCode)")
//
//        if resultCode.rawValue == "Refused" {
//
//            if let paymentId = self.paymentId {
//                self.cancelDeposit(paymentId: paymentId)
//            }
//
//            self.dropInComponent?.viewController.dismiss(animated: true)
//            self.showPaymentStatus?(.refused)
//        }
//
//        if resultCode.rawValue == "Authorised" {
//            self.dropInComponent?.viewController.dismiss(animated: true)
//            self.showPaymentStatus?(.authorised)
//        }
//
//    }

    func didComplete(with result: AdyenSessionResult, component: Adyen.Component, session: AdyenSession) {

        print("ADYEN SESSION RESULT: \(result)")

        if result.resultCode == .refused {

            if let paymentId = self.paymentId {
                self.cancelDeposit(paymentId: paymentId)
            }

            self.dropInComponent?.viewController.dismiss(animated: true)
            self.showPaymentStatus?(.refused)
        }

        if result.resultCode == .authorised {
            self.dropInComponent?.viewController.dismiss(animated: true)
            self.showPaymentStatus?(.authorised)
        }

    }

    func didFail(with error: Error, from component: Adyen.Component, session: AdyenSession) {

        print("ADYEN SESSION FAIL: \(error)")

        if let paymentId = self.paymentId {
            self.cancelDeposit(paymentId: paymentId)
        }

        self.dropInComponent?.viewController.dismiss(animated: true)

    }

    func present(component: Adyen.PresentableComponent) {
        print("ADYEN SESSION PRESENT")

    }
}
