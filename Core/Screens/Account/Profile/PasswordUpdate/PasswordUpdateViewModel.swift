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
    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
//    var policyPublisher: CurrentValueSubject<EveryMatrix.PasswordPolicy?, Never> = .init(nil)
    var policyPublisher: CurrentValueSubject<PasswordPolicy?, Never> = .init(nil)
    var userProfilePublisher: CurrentValueSubject<EveryMatrix.UserProfile?, Never> = .init(nil)
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var shouldShowAlertPublisher: CurrentValueSubject<AlertInfo?, Never> = .init(nil)
    var newPassword: CurrentValueSubject<String?, Never> = .init("")

    var passwordState: AnyPublisher<PasswordState, Never> {
        return self.newPassword
            .map { password in
                guard let password else { return PasswordState.empty }
                if password.isEmpty { return PasswordState.empty }
                if password.count < 8 { return PasswordState.short }
                if password.count > 16 { return PasswordState.long }

                let numbersCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "0123456789")
                if password.rangeOfCharacter(from: numbersCharacterSet.inverted) == nil {
                    return PasswordState.onlyNumbers
                }

                let validCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "-!@$^&*abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
                if password.rangeOfCharacter(from: validCharacterSet.inverted) != nil {
                    return PasswordState.invalidChars
                }

                let specialCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "-!@$^&*")
                let lowerCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz")
                let upperCharacterSet: NSCharacterSet = NSCharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ")

                if password.rangeOfCharacter(from: lowerCharacterSet as CharacterSet) == nil {
                    return PasswordState.needLowercase
                }
                if password.rangeOfCharacter(from: upperCharacterSet as CharacterSet) == nil {
                    return PasswordState.needUppercase
                }
                if password.rangeOfCharacter(from: numbersCharacterSet as CharacterSet) == nil {
                    return PasswordState.needNumber
                }
                if password.rangeOfCharacter(from: specialCharacterSet as CharacterSet) == nil {
                    return PasswordState.needSpecial
                }

                return PasswordState.valid
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

//        self.getProfile()

    }

    func setPassword(_ password: String) {
        self.newPassword.send(password)
    }

    private func getPolicy() {

//        Env.everyMatrixClient.getPolicy()
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//            .sink(receiveCompletion: { [weak self] _ in
//                self?.isLoadingPublisher.send(false)
//            }, receiveValue: { [weak self] policy in
//                self?.policyPublisher.send(policy)
//            })
//            .store(in: &cancellables)

        Env.servicesProvider.getPasswordPolicy()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                self?.isLoadingPublisher.send(false)

            }, receiveValue: { [weak self] passwordPolicy in
                self?.policyPublisher.send(passwordPolicy)
            })
            .store(in: &cancellables)



    }

//    private func getProfile() {
//
//        Env.everyMatrixClient.getProfile()
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//            .sink(receiveCompletion: { [weak self] _ in
//                self?.isLoadingPublisher.send(false)
//            }, receiveValue: { [weak self] profile in
//                self?.userProfilePublisher.send(profile.fields)
//
//            })
//            .store(in: &cancellables)
//
//    }

    func savePassword(oldPassword: String, newPassword: String) {
        self.isLoadingPublisher.send(true)

        // TO-DO: Put EM changePassword to its specific service provider
//        Env.everyMatrixClient.changePassword(oldPassword: oldPassword,
//                                             newPassword: newPassword,
//                                             captchaPublicKey: "",
//                                             captchaChallenge: "",
//                                             captchaResponse: "")
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//            .sink( receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .finished:
//                    break
//                case .failure(let error):
//                    var errorMessage = ""
//                    switch error {
//                    case .requestError(let value):
//                        errorMessage = value
//                    case .decodingError:
//                        errorMessage = "\(error)"
//                    case .httpError:
//                        errorMessage = "\(error)"
//                    case .unknown:
//                        errorMessage = "\(error)"
//                    case .missingTransportSessionID:
//                        errorMessage = "\(error)"
//                    case .notConnected:
//                        errorMessage = "\(error)"
//                    case .noResultsReceived:
//                        errorMessage = "\(error)"
//                    }
//                    let alertInfo = AlertInfo(alertType: .error, message: errorMessage)
//                    self?.shouldShowAlertPublisher.send(alertInfo)
//                }
//
//                self?.isLoadingPublisher.send(false)
//            }, receiveValue: { [weak self] _ in
//                let alertInfo = AlertInfo(alertType: .success, message: localized("success_edit_password"))
//                self?.shouldShowAlertPublisher.send(alertInfo)
//                UserDefaults.standard.userSession?.password = newPassword
//            }).store(in: &cancellables)

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

//    func saveSecurityInfo(securityQuestion: String, securityAnswer: String) {
//        self.isLoadingPublisher.send(true)
//
//        if let userProfile = self.userProfilePublisher.value {
//
//            let email = userProfile.email
//            let title = userProfile.title
//            let gender = userProfile.title == "Mr." ? "M" : "F"
//            let firstName = userProfile.firstname
//            let lastName = userProfile.surname
//            let birthDate = userProfile.birthDate
//            let mobilePrefix = userProfile.mobilePrefix
//            let mobile = userProfile.mobile
//            let phonePrefix = userProfile.phonePrefix
//            let phone = userProfile.phone
//            let country = userProfile.country
//            let address1 = userProfile.address1
//            let address2 = userProfile.address2
//            let city = userProfile.city
//            let postalCode = userProfile.postalCode
//            let personalId = userProfile.personalID
//            let securityQuestion = securityQuestion
//            let securityAnswer = securityAnswer
//
//            let form = EveryMatrix.ProfileForm(email: email,
//                                               title: title,
//                                               gender: gender,
//                                               firstname: firstName,
//                                               surname: lastName,
//                                               birthDate: birthDate,
//                                               country: country,
//                                               address1: address1,
//                                               address2: address2,
//                                               city: city,
//                                               postalCode: postalCode,
//                                               mobile: mobile,
//                                               mobilePrefix: mobilePrefix,
//                                               phone: phone,
//                                               phonePrefix: phonePrefix, personalID: personalId,
//                                               securityQuestion: securityQuestion,
//                                               securityAnswer: securityAnswer)
//
//            Env.everyMatrixClient.updateProfile(form: form)
//                .breakpointOnError()
//                .receive(on: DispatchQueue.main)
//                .sink { [weak self] completion in
//                    switch completion {
//                    case .failure(let error):
//                        switch error {
//                        case let .requestError(message):
//                            let alertInfo = AlertInfo(alertType: .error, message: message)
//                            self?.shouldShowAlertPublisher.send(alertInfo)
//                        default:
//                            let alertInfo = AlertInfo(alertType: .error, message: "\(error)")
//                            self?.shouldShowAlertPublisher.send(alertInfo)
//                        }
//                    case .finished:
//                        ()
//                    }
//                    self?.isLoadingPublisher.send(false)
//
//                } receiveValue: { [weak self] _ in
//                    let alertInfo = AlertInfo(alertType: .success, message: localized("profile_updated_success"))
//                    self?.shouldShowAlertPublisher.send(alertInfo)
//                }
//                .store(in: &cancellables)
//        }
//    }
}

struct AlertInfo {
    var alertType: EditAlertView.AlertState
    var message: String
}

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
