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
import AdyenComponents
import AdyenActions

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
    var showPaymentStatus: ((PaymentStatus, String?) -> Void)?

    var presentSafariViewControllerAction: ((URL) -> Void) = { _ in }
    
    var dropInDepositAmount: String = ""
    var depositAmount: Double = 0.0
    var clientKey: String?
    var paymentId: String?
    var sessionId: String?
    var sessionData: String?
    var adyenSession: AdyenSession?
    var adyenEnvironment = Adyen.Environment.liveEurope
    
    var payment: Payment?
    var paymentMethodsResponse: SimplePaymentMethodsResponse?
    var dropInComponent: DropInComponent?

    // MARK: Lifetime and Cycle
    init() {

        if TargetVariables.serviceProviderEnvironment == .dev {
            adyenEnvironment = Adyen.Environment.test
        }

        self.setupPublishers()

        if TargetVariables.serviceProviderEnvironment == .dev {
            adyenEnvironment = Adyen.Environment.test
        }

        AdyenLogging.isEnabled = true
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

        Env.servicesProvider.processDeposit(paymentMethod: "ADYEN_ALL", amount: amount, option: "DROP_IN")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("PROCESS DEPOSIT RESPONSE ERROR: \(error)")
                    switch error {
                    case .errorMessage(let message):
                        let messageLocalized = localized(message)

                        self?.showErrorAlertTypePublisher.send(.error(message: messageLocalized))
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

    private func setupSession() {
        
        guard
            let clientKey = self.clientKey,
            let apiContext = try? APIContext(environment: self.adyenEnvironment, clientKey: clientKey), // test_HNOW5H423JB7JEJYVXMQF655YAT7M5IB
            let sessionId = self.sessionId,
            let sessionData = self.sessionData
        else {
            return
        }
        
        // Optional Payment
        let payment = Payment(amount: Amount(value: Int(self.dropInDepositAmount) ?? 0, currencyCode: "EUR"), countryCode: "FR")
        
        self.payment = payment
        
        let context = AdyenContext(apiContext: apiContext, payment: payment)
        let adyenSessionConfiguration = AdyenSession.Configuration(sessionIdentifier: sessionId,
                                                                   initialSessionData: sessionData,
                                                                   context: context)
        
        AdyenSession.initialize(with: adyenSessionConfiguration, delegate: self, presentationDelegate: self) { [weak self] result in
            switch result {
            case let .success(session):
                // Store the session object.
                self?.adyenSession = session
                self?.hasSessionInitialized.send(true)
            case let .failure(error):
                // Handle the error.
                print("ADYEN SESSION INIT FAILURE: \(error)")
            }
        }
        
    }
    
    func setupPaymentDropIn() -> DropInComponent? {
        
        
        guard
            let paymentMethodsResponse = self.paymentMethodsResponse
        else {
            return nil
        }
            
        print("paymentMethodsResponse: \(paymentMethodsResponse)")
        
        guard
            let paymentResponseData = try? JSONEncoder().encode(paymentMethodsResponse),
            let paymentMethods = try? JSONDecoder().decode(PaymentMethods.self, from: paymentResponseData),
            //
            let adyenSession = self.adyenSession,
            //
            let clientKey = self.clientKey,
            let apiContext = try? APIContext(environment: self.adyenEnvironment, clientKey: clientKey)
        else {
            return nil
        }
        
        let payment = Payment(amount: Amount(value: Int(self.dropInDepositAmount) ?? 0, currencyCode: "EUR"), countryCode: "FR")
        let dropInConfiguration = DropInComponent.Configuration()
        
        dropInConfiguration.card = DropInComponent.Card(showsStorePaymentMethodField: false)
        
        if let applePayPayment = try? ApplePayPayment(payment: payment, brand: "Betsson France") {
            dropInConfiguration.applePay = ApplePayComponent.Configuration.init(payment: applePayPayment, 
                                                                                merchantIdentifier: "merchant.com.adyen.betssonfrance.ecom")
            dropInConfiguration.applePay?.allowOnboarding = true
        }
        
        let adyenContext = AdyenContext(apiContext: apiContext, payment: payment)
        
        let dropInComponent = DropInComponent(paymentMethods: paymentMethods, context: adyenContext, configuration: dropInConfiguration)
        dropInComponent.delegate = self // self.adyenSession
 
        self.dropInComponent = dropInComponent
        return dropInComponent
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
                    self?.showPaymentStatus?(.refused, nil)
                }
            }, receiveValue: { [weak self] cancelDepositResponse in
                print("CANCEL DEPOSIT SUCCESS: \(cancelDepositResponse)")
            })
            .store(in: &cancellables)
    }
}

extension PaymentsDropIn: PresentationDelegate {
    func present(component: Adyen.PresentableComponent) {
        print("PaymentsDropIn - ADYEN SESSION PRESENT")
    }
}

extension PaymentsDropIn: AdyenSessionDelegate {

    func didComplete(with result: AdyenSessionResult, component: Component, session: AdyenSession) {

        print("PaymentsDropIn - ADYEN SESSION RESULT: \(result)")

        if result.resultCode == .refused {
            self.dropInComponent?.viewController.dismiss(animated: true)
            self.showPaymentStatus?(.refused, self.paymentId)
        }

        if result.resultCode == .authorised {
            self.dropInComponent?.viewController.dismiss(animated: true)
            self.showPaymentStatus?(.authorised, self.paymentId)
        }
    }

    func didFail(with error: Error, from component: Component, session: AdyenSession) {

        print("PaymentsDropIn - ADYEN SESSION FAIL: \(error)")

        // Remove cancel deposit
//        if let paymentId = self.paymentId {
//            self.cancelDeposit(paymentId: paymentId)
//        }

        self.dropInComponent?.viewController.dismiss(animated: true)
    }

    func didOpenExternalApplication(component: ActionComponent, session: AdyenSession) {
        
    }
    
    func handlerForAdditionalDetails(in component: ActionComponent, session: AdyenSession) -> AdyenSessionPaymentDetailsHandler? {
        return self
    }
    
    func handlerForPayments(in component: PaymentComponent, session: AdyenSession) -> AdyenSessionPaymentsHandler? {
        return self
    }
    
}

extension PaymentsDropIn: AdyenSessionPaymentsHandler, AdyenSessionPaymentDetailsHandler {
 
    func didSubmit(_ paymentComponentData: PaymentComponentData, from component: Component, dropInComponent: AnyDropInComponent?, session: AdyenSession) {
        self.adyenSession?.didSubmit(paymentComponentData,
                                     from: component,
                                     dropInComponent: dropInComponent,
                                     session: session)
    }
    
    func didProvide(_ actionComponentData: ActionComponentData, from component: ActionComponent, session: AdyenSession) {
        self.adyenSession?.didProvide(actionComponentData,
                                      from: component,
                                      session: session)
    }
 
}

extension PaymentsDropIn: DropInComponentDelegate {
    
    func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        if (data.paymentMethod as? InstantPaymentDetails)?.type == .other("paysafecard") {
            Env.servicesProvider.updatePayment(amount: self.depositAmount,
                                               paymentId: self.paymentId ?? "",
                                               type: "paysafecard",
                                               returnUrl: nil)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("updatePayment completion: \(completion)")
            } receiveValue: { updatePaymentResponse in
                print("updatePayment: \(updatePaymentResponse)")
                
                if let redirectURL = URL(string: updatePaymentResponse.action.url) {
                    self.presentSafariViewController(onURL: redirectURL)
                }
            }
            .store(in: &self.cancellables)
        }
        else {
            if let adyenSession  = self.adyenSession, let castedAdyenSession = adyenSession as? DropInComponentDelegate {
                castedAdyenSession.didSubmit(data, from: component, in: dropInComponent)
            }
        }
    }
    
    func didProvide(_ data: ActionComponentData, from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        if let adyenSession  = self.adyenSession, let castedAdyenSession = adyenSession as? DropInComponentDelegate {
            castedAdyenSession.didProvide(data, from: component, in: dropInComponent)
        }
    }
    
    func didComplete(from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        if let adyenSession  = self.adyenSession, let castedAdyenSession = adyenSession as? DropInComponentDelegate {
            castedAdyenSession.didComplete(from: component, in: dropInComponent)
        }
    }

    
    func didOpenExternalApplication(component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        if let adyenSession  = self.adyenSession, let castedAdyenSession = adyenSession as? DropInComponentDelegate {
            castedAdyenSession.didOpenExternalApplication(component: component, in: dropInComponent)
        }
    }
    
    //
    func didCancel(component: PaymentComponent, from dropInComponent: AnyDropInComponent) {
        if let adyenSession  = self.adyenSession, let castedAdyenSession = adyenSession as? DropInComponentDelegate {
            castedAdyenSession.didCancel(component: component, from: dropInComponent)
        }
    }
    
    //
    func didFail(with error: Error, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        // Invoked when a payment component fails.
        if let adyenSession  = self.adyenSession, let castedAdyenSession = adyenSession as? DropInComponentDelegate {
            castedAdyenSession.didFail(with: error, from: component, in: dropInComponent)
        }
    }
    
    func didFail(with error: Error, from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        // Invoked when the action component fails.
        if let adyenSession  = self.adyenSession, let castedAdyenSession = adyenSession as? DropInComponentDelegate {
            castedAdyenSession.didFail(with: error, from: component, in: dropInComponent)
        }
    }
    
    func didFail(with error: Error, from dropInComponent: AnyDropInComponent) {
        if let adyenSession  = self.adyenSession, let castedAdyenSession = adyenSession as? DropInComponentDelegate {
            castedAdyenSession.didFail(with: error, from: dropInComponent)
        }
    }
        
}

extension PaymentsDropIn {
    
    func presentSafariViewController(onURL url: URL) {
        self.presentSafariViewControllerAction(url)
    }
    
    func checkSuccessOnRedirectURL(_ url: URL) {
        if url.absoluteString.contains("deposit-results.html") && url.absoluteString.contains("resultCode=authorised") {
            self.dropInComponent?.viewController.dismiss(animated: true)
            if let paymentId = self.paymentId {
                self.showPaymentStatus?(.startedProcessing, paymentId)
            }
        }
    }
    
}
