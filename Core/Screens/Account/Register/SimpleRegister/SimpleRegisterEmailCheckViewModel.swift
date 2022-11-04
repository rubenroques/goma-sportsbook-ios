//
//  SimpleRegisterEmailCheckViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 31/03/2022.
//

import Foundation
import Combine
import ServiceProvider

class SimpleRegisterEmailCheckViewModel: NSObject {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isRegisterEnabled: CurrentValueSubject<Bool, Never> = .init(false)
    var shouldAnimateEmailValidityView: CurrentValueSubject<Bool, Never> = .init(false)
    var registerErrorTypePublisher: CurrentValueSubject<RegisterErrorType?, Never> = .init(nil)
    var shouldShowNextViewController: CurrentValueSubject<Bool, Never> = .init(false)

    // MARK: Lifetime and Cycle
    override init() {
        super.init()

    }

    // MARK: Functions

    func sendAnalyticsEvent(event: AnalyticsClient.Event) {
        AnalyticsClient.sendEvent(event: event)
    }

    func registerEmail(email: String) {
        self.isLoadingPublisher.send(true)

        if !isValidEmail(email) {
            self.registerErrorTypePublisher.value = .wrongEmail
            self.isLoadingPublisher.send(false)
            return
        }
        
        Env.serviceProvider.checkEmailRegistered(email)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.shouldAnimateEmailValidityView.send(true)
            })
            .sink { [weak self] completed in
                if case .failure = completed {
                    self?.registerErrorTypePublisher.value = .server
                }
                self?.shouldAnimateEmailValidityView.send(false)
                self?.isLoadingPublisher.send(false)
            }
            receiveValue: { [weak self] isEmailInUse in
                if isEmailInUse {
                    self?.registerErrorTypePublisher.value = .usedEmail
                    self?.sendAnalyticsEvent(event: .userSignUpFail)
                }
                else {
                    self?.shouldShowNextViewController.send(true)
                    self?.sendAnalyticsEvent(event: .userSignUpSuccess)
                }
                self?.shouldAnimateEmailValidityView.send(false)
            }
            .store(in: &cancellables)
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)

        if !emailPred.evaluate(with: email) {
            self.isRegisterEnabled.send(false)
        }

        return emailPred.evaluate(with: email)
    }

    func requestValidEmailCheck(email: String) {
        
        self.shouldAnimateEmailValidityView.send(true)
        self.isRegisterEnabled.send(false)
        
        Env.serviceProvider.checkEmailRegistered(email)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] _ in
                        self?.shouldAnimateEmailValidityView.send(false)
                    }
                    receiveValue: { [weak self] isEmailInUse in
                        
                        if isEmailInUse {
                            self?.registerErrorTypePublisher.value = .usedEmail
                            self?.isRegisterEnabled.send(false)
                        }
                        else {
                            self?.isRegisterEnabled.send(true)
                        }
                        self?.shouldAnimateEmailValidityView.send(false)
                    }
                    .store(in: &cancellables)

    }
}

enum RegisterErrorType {
    case server
    case wrongEmail
    case usedEmail
    case hideEmail
}
