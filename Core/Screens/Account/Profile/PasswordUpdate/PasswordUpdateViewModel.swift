//
//  PasswordUpdateViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 29/03/2022.
//

import Foundation
import Combine
import ServicesProvider

class PasswordUpdateViewModel: NSObject {

    enum PasswordState {
        case empty
        case short
        case long
        case invalidChars
        case onlyNumbers
        case needUppercase
        case needLowercase
        case needNumber
        case needSpecial
        case valid
    }

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var policyPublisher: CurrentValueSubject<PasswordPolicy?, Never> = .init(nil)

    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var shouldShowAlertPublisher: CurrentValueSubject<AlertInfo?, Never> = .init(nil)
    var newPassword: CurrentValueSubject<String?, Never> = .init("")

    var passwordState: AnyPublisher<[PasswordState], Never> {
        return self.newPassword
            .map { password in
                var passwordStates: [PasswordState] = []

                guard let password else { return [PasswordState.empty] }

                if password.isEmpty { passwordStates.append(PasswordState.empty) }
                if password.count < 8 { passwordStates.append(PasswordState.short) }
                if password.count > 16 { passwordStates.append(PasswordState.long) }

                let numbersCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "0123456789")
                if password.rangeOfCharacter(from: numbersCharacterSet.inverted) == nil {
                    passwordStates.append(PasswordState.onlyNumbers)
                }

                let validCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "-!@$^&*abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
                if password.rangeOfCharacter(from: validCharacterSet.inverted) != nil {
                    passwordStates.append(PasswordState.invalidChars)
                }

                let specialCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "-!@$^&*")
                let lowerCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz")
                let upperCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ")

                if password.rangeOfCharacter(from: lowerCharacterSet as CharacterSet) == nil {
                    passwordStates.append(PasswordState.needLowercase)
                }
                if password.rangeOfCharacter(from: upperCharacterSet as CharacterSet) == nil {
                    passwordStates.append(PasswordState.needUppercase)
                }
                if password.rangeOfCharacter(from: numbersCharacterSet as CharacterSet) == nil {
                    passwordStates.append(PasswordState.needNumber)
                }
                if password.rangeOfCharacter(from: specialCharacterSet as CharacterSet) == nil {
                    passwordStates.append(PasswordState.needSpecial)
                }

                if !passwordStates.isEmpty {
                    return passwordStates
                }

                return [PasswordState.valid]
            }
            .eraseToAnyPublisher()
    }

    // MARK: Lifetime and Cycle
    override init() {
        super.init()

        self.setupPublishers()

    }

    private func setupPublishers() {
        self.isLoadingPublisher.send(true)
        self.getPolicy()
    }

    func setPassword(_ password: String) {
        self.newPassword.send(password)
    }

    private func getPolicy() {

        Env.servicesProvider.getPasswordPolicy()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                self?.isLoadingPublisher.send(false)

            }, receiveValue: { [weak self] passwordPolicy in
                self?.policyPublisher.send(passwordPolicy)
            })
            .store(in: &cancellables)



    }

    func savePassword(oldPassword: String, newPassword: String) {
        self.isLoadingPublisher.send(true)

        Env.servicesProvider.updatePassword(oldPassword: oldPassword, newPassword: newPassword)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {

                case .finished:
                    ()
                case .failure(let error):
                    if case .errorMessage(message: let message) = error {
                        if message.contains("CURRENT_PASSWORD_INCORRECT") {
                            let alertInfo = AlertInfo(alertType: .error, message: localized("current_password_incorrect"))
                            self?.shouldShowAlertPublisher.send(alertInfo)
                        }
                    }
                    else {
                        let alertInfo = AlertInfo(alertType: .error, message: localized("server_error_message"))
                        self?.shouldShowAlertPublisher.send(alertInfo)
                    }

                }
                self?.isLoadingPublisher.send(false)
            }, receiveValue: { [weak self] success in
                if success {
                    let alertInfo = AlertInfo(alertType: .success, message: localized("success_edit_password"))
                    self?.shouldShowAlertPublisher.send(alertInfo)
                    UserDefaults.standard.userSession?.password = newPassword
                }
            })
            .store(in: &cancellables)
    }

}

struct AlertInfo {
    var alertType: EditAlertView.AlertState
    var message: String
}
