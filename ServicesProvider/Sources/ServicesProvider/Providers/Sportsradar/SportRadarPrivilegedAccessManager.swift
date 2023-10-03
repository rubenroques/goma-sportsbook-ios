//
//  SportRadarPrivilegedAccessManager.swift
//
//
//  Created by Ruben Roques on 24/10/2022.
//

import Foundation
import Combine
import SharedModels
import CryptoKit

class SportRadarPrivilegedAccessManager: PrivilegedAccessManager {

    var connector: OmegaConnector
    var userSessionStatePublisher: AnyPublisher<UserSessionStatus, Error> {
        return userSessionStateSubject.eraseToAnyPublisher()
    }
    var userProfilePublisher: AnyPublisher<UserProfile?, Error> {
        return userProfileSubject.eraseToAnyPublisher()
    }

    var hasSecurityQuestions: Bool = false

    private var sessionCoordinator: SportRadarSessionCoordinator

    private let userSessionStateSubject: CurrentValueSubject<UserSessionStatus, Error> = .init(.anonymous)
    private let userProfileSubject: CurrentValueSubject<UserProfile?, Error> = .init(nil)

    private var cancellables: Set<AnyCancellable> = []

    //Sumsub
    private let sumsubAppToken = "sbx:yjCFqKsuTX6mTY7XMFFPe6hR.v9i5YpFrNND0CeLcZiHeJnnejrCUDZKT"
    private let sumsubSecretKey = "4PH7gdufQfrFpFS35gJiwz9d2NFZs4kM"

    init(sessionCoordinator: SportRadarSessionCoordinator, connector: OmegaConnector = OmegaConnector()) {

        self.connector = connector
        self.sessionCoordinator = sessionCoordinator

        self.connector.tokenPublisher.sink { [weak self] omegaSessionAccessToken in
            if let omegaSessionAccessToken {
                self?.sessionCoordinator.saveToken(omegaSessionAccessToken.sessionKey, withKey: .restSessionToken)

                if let launchToken = omegaSessionAccessToken.launchKey {
                    self?.sessionCoordinator.saveToken(launchToken, withKey: .launchToken)
                }
                else {
                    self?.sessionCoordinator.clearToken(withKey: .launchToken)
                }
            }
            else {
                self?.sessionCoordinator.clearToken(withKey: .restSessionToken)
            }
        }
        .store(in: &cancellables)

    }

    func login(username: String, password: String) -> AnyPublisher<UserProfile, ServiceProviderError> {

        return self.connector.login(username: username, password: password)
            .flatMap({ [weak self] loginResponse -> AnyPublisher<UserProfile, ServiceProviderError> in

            guard
                let self = self
            else {
                return Fail(outputType: UserProfile.self, failure: ServiceProviderError.unknown).eraseToAnyPublisher()
            }

            if loginResponse.status == "FAIL_UN_PW" {
                return Fail(outputType: UserProfile.self, failure: ServiceProviderError.invalidEmailPassword).eraseToAnyPublisher()
            }
            else if loginResponse.status == "FAIL_QUICK_OPEN_STATUS" {
                return Fail(outputType: UserProfile.self, failure: ServiceProviderError.quickSignUpIncomplete).eraseToAnyPublisher()
            }
            else if loginResponse.status == "SUCCESS" {
                return self.getUserProfile()
            }
            return Fail(outputType: UserProfile.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }

    func logout() {
        return self.connector.logout()
    }

    func getUserProfile() -> AnyPublisher<UserProfile, ServiceProviderError> {

        let endpoint = OmegaAPIClient.playerInfo
        let publisher: AnyPublisher<SportRadarModels.PlayerInfoResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ playerInfoResponse -> AnyPublisher<UserProfile, ServiceProviderError> in
            if playerInfoResponse.status == "SUCCESS", let userOverview = SportRadarModelMapper.userProfile(fromPlayerInfoResponse: playerInfoResponse) {
                return Just(userOverview).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            return Fail(outputType: UserProfile.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }

    func checkEmailRegistered(_ email: String) -> AnyPublisher<Bool, ServiceProviderError> {
        let endpoint = OmegaAPIClient.checkCredentialEmail(email: email)

        let publisher: AnyPublisher<SportRadarModels.CheckCredentialResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ checkCredentialResponse -> AnyPublisher<Bool, ServiceProviderError> in
            if checkCredentialResponse.exists == "true" {
                return Just(true).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else if checkCredentialResponse.exists == "false"  {
                return Just(false).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            return Fail(outputType: Bool.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()

    }

    func validateUsername(_ username: String) -> AnyPublisher<UsernameValidation, ServiceProviderError> {
        let endpoint = OmegaAPIClient.checkUsername(username: username)

        let publisher: AnyPublisher<SportRadarModels.CheckUsernameResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ checkCredentialResponse -> AnyPublisher<UsernameValidation, ServiceProviderError> in

            let suggestions = checkCredentialResponse.additionalInfos?
                .compactMap({ $0 })
                .map { additionalInfo -> String in
                    return additionalInfo.value
                }

            if checkCredentialResponse.status == "SUCCESS", let suggestionsValue = suggestions, !suggestionsValue.isEmpty {
                let usernameValidation = UsernameValidation(username: username,
                                                            isAvailable: false,
                                                            suggestedUsernames: suggestionsValue,
                                                            hasErrors: false)
                return Just(usernameValidation)
                    .setFailureType(to: ServiceProviderError.self)
                    .eraseToAnyPublisher()
            }
            else if checkCredentialResponse.status == "USERNAME_AVAILABLE" {
                if (checkCredentialResponse.errors ?? []).isEmpty {
                    let usernameValidation = UsernameValidation(username: username,
                                                                isAvailable: true,
                                                                suggestedUsernames: nil,
                                                                hasErrors: false)
                    return Just(usernameValidation)
                        .setFailureType(to: ServiceProviderError.self)
                        .eraseToAnyPublisher()
                }
                else {
                    let usernameValidation = UsernameValidation(username: username,
                                                                isAvailable: true,
                                                                suggestedUsernames: nil,
                                                                hasErrors: true)
                    return Just(usernameValidation)
                        .setFailureType(to: ServiceProviderError.self)
                        .eraseToAnyPublisher()
                }
            }
            return Fail(outputType: UsernameValidation.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }

    func simpleSignUp(form: SimpleSignUpForm) -> AnyPublisher<Bool, ServiceProviderError> {

        let endpoint = OmegaAPIClient.quickSignup(email: form.email,
                                                  username: form.username,
                                                  password: form.password,
                                                  birthDate: form.birthDate,
                                                  mobilePrefix: form.mobilePrefix,
                                                  mobileNumber: form.mobileNumber,
                                                  countryIsoCode: form.countryIsoCode,
                                                  currencyCode: form.currencyCode)

        let publisher: AnyPublisher<SportRadarModels.StatusResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ statusResponse -> AnyPublisher<Bool, ServiceProviderError> in
            if statusResponse.status == "SUCCESS" {
                return Just(true).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else if let errors = statusResponse.errors {
                if errors.contains(where: { $0.field == "username" }) {
                    return Fail(outputType: Bool.self, failure: ServiceProviderError.invalidSignUpUsername).eraseToAnyPublisher()
                }
                else if errors.contains(where: { $0.field == "email" }) {
                    return Fail(outputType: Bool.self, failure: ServiceProviderError.invalidSignUpEmail).eraseToAnyPublisher()
                }
                else if errors.contains(where: { $0.field == "password" }) {
                    return Fail(outputType: Bool.self, failure: ServiceProviderError.invalidSignUpPassword).eraseToAnyPublisher()
                }
            }
            return Fail(outputType: Bool.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }

    func signUp(form: SignUpForm) -> AnyPublisher<SignUpResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.signUp(email: form.email,
                                             username: form.username,
                                             password: form.password,
                                             birthDate: form.birthDate,
                                             mobilePrefix: form.mobilePrefix,
                                             mobileNumber: form.mobileNumber,
                                             nationalityIso2Code: form.nationalityIsoCode,
                                             currencyCode: form.currencyCode,
                                             firstName: form.firstName,
                                             lastName: form.lastName,
                                             gender: form.gender,
                                             address: form.address,
                                             city: form.city,
                                             postalCode: form.postCode,
                                             countryIso2Code: form.countryIsoCode,
                                             bonusCode: form.bonusCode,
                                             receiveMarketingEmails: form.receiveMarketingEmails,
                                             avatarName: form.avatarName,
                                             godfatherCode: form.godfatherCode,
                                             birthDepartment: form.birthDepartment,
                                             birthCity: form.birthCity,
                                             birthCountry: form.birthCountry,
                                             streetNumber: form.streetNumber)

        let publisher: AnyPublisher<SportRadarModels.StatusResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ (statusResponse: SportRadarModels.StatusResponse) -> AnyPublisher<SignUpResponse, ServiceProviderError> in
            if statusResponse.status == "SUCCESS" || statusResponse.status == "BONUSPLAN_NOT_FOUND" {
                return Just( SignUpResponse(successful: true) ).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else if let errors = statusResponse.errors {
                let mappedErrors = errors.map { error -> SignUpResponse.SignUpError in
                    return SignUpResponse.SignUpError(field: error.field, error: error.error)
                }
                return Just( SignUpResponse(successful: false, errors: mappedErrors) ).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            return Fail(outputType: SignUpResponse.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }

    func updateUserProfile(form: UpdateUserProfileForm) -> AnyPublisher<Bool, ServiceProviderError> {

        let endpoint = OmegaAPIClient.updatePlayerInfo(username: form.username,
                                                       email: form.email,
                                                       firstName: form.firstName,
                                                       lastName: form.lastName,
                                                       birthDate: form.birthDate,
                                                       gender: form.gender,
                                                       address: form.address,
                                                       province: form.province,
                                                       city: form.city,
                                                       postalCode: form.postalCode,
                                                       country: form.country?.iso2Code,
                                                       cardId: form.cardId)

        let publisher: AnyPublisher<SportRadarModels.StatusResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ statusResponse -> AnyPublisher<Bool, ServiceProviderError> in
            if statusResponse.status == "SUCCESS" {
                return Just(true).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            return Fail(outputType: Bool.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }

    func updateExtraInfo(placeOfBirth: String?, address2: String?) -> AnyPublisher<BasicResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.updateExtraInfo(placeOfBirth: placeOfBirth, address2: address2)

        let publisher: AnyPublisher<SportRadarModels.BasicResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ basicResponse -> AnyPublisher<BasicResponse, ServiceProviderError> in
            if basicResponse.status == "SUCCESS" {

                let basicResponse = SportRadarModelMapper.basicResponse(fromInternalBasicResponse: basicResponse)

                return Just(basicResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            return Fail(outputType: BasicResponse.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
    
    func updateDeviceIdentifier(deviceIdentifier: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.updateDeviceIdentifier(deviceIdentifier: deviceIdentifier)
        let publisher: AnyPublisher<SportRadarModels.BasicResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ basicResponse -> AnyPublisher<BasicResponse, ServiceProviderError> in
            if basicResponse.status == "SUCCESS" {

                let basicResponse = SportRadarModelMapper.basicResponse(fromInternalBasicResponse: basicResponse)

                return Just(basicResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            return Fail(outputType: BasicResponse.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }


    public func getCountries() -> AnyPublisher<[Country], ServiceProviderError> {

        let endpoint = OmegaAPIClient.getCountries
        let publisher: AnyPublisher<SportRadarModels.GetCountriesResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ countriesResponse -> AnyPublisher<[Country], ServiceProviderError> in
            if countriesResponse.status == "SUCCESS" {
                let countries: [Country] = countriesResponse.countries.map({ isoCode in
                    return Country(isoCode: isoCode)
                }).compactMap({ $0 })

                return Just(countries).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else {
                return Fail(outputType: [Country].self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    public func getCurrentCountry() -> AnyPublisher<Country?, ServiceProviderError> {

        let endpoint = OmegaAPIClient.getCurrentCountry
        let publisher: AnyPublisher<SportRadarModels.GetCountryInfoResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ countryInfo -> AnyPublisher<Country?, ServiceProviderError> in
            if countryInfo.status == "SUCCESS" {
                return Just(Country(isoCode: countryInfo.countryInfo.iso2Code)).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else {
                return Fail(outputType: Country?.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func signupConfirmation(_ email: String, confirmationCode: String) -> AnyPublisher<Bool, ServiceProviderError> {
        let endpoint = OmegaAPIClient.signupConfirmation(email: email, confirmationCode: confirmationCode)
        let publisher: AnyPublisher<SportRadarModels.StatusResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ statusResponse -> AnyPublisher<Bool, ServiceProviderError> in
            if statusResponse.status == "SUCCESS" {
                return Just(true).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            if !(statusResponse.errors?.isEmpty ?? true), let message = statusResponse.message {
                return Fail(outputType: Bool.self, failure: ServiceProviderError.errorMessage(message: message)).eraseToAnyPublisher()
            }
            return Fail(outputType: Bool.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }

    func forgotPassword(email: String, secretQuestion: String? = nil, secretAnswer: String? = nil) -> AnyPublisher<Bool, ServiceProviderError> {
        let endpoint = OmegaAPIClient.forgotPassword(email: email, secretQuestion: secretQuestion, secretAnswer: secretAnswer)
        let publisher: AnyPublisher<SportRadarModels.StatusResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ statusResponse -> AnyPublisher<Bool, ServiceProviderError> in
            if statusResponse.status == "SUCCESS" {
                return Just(true).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }

            return Fail(outputType: Bool.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()

    }

    func updatePassword(oldPassword: String, newPassword: String) -> AnyPublisher<Bool, ServiceProviderError> {
        let endpoint = OmegaAPIClient.updatePassword(oldPassword: oldPassword, newPassword: newPassword)
        let publisher: AnyPublisher<SportRadarModels.StatusResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ statusResponse -> AnyPublisher<Bool, ServiceProviderError> in
            if statusResponse.status == "SUCCESS" {
                return Just(true).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }

            return Fail(outputType: Bool.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()

    }

    func getPasswordPolicy() -> AnyPublisher<PasswordPolicy, ServiceProviderError> {

        let passwordPolicy = PasswordPolicy(regularExpression: "", message: "Your password must be between 8-16 characters long, have uppercase and lowercase letters, a number and one special character.")

        let publisher = Just(passwordPolicy).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()

        return publisher
    }

    func updateWeeklyDepositLimits(newLimit: Double) -> AnyPublisher<Bool, ServiceProviderError> {
        let endpoint = OmegaAPIClient.updateWeeklyDepositLimits(newLimit: newLimit)
        let publisher: AnyPublisher<SportRadarModels.StatusResponse, ServiceProviderError> = self.connector.request(endpoint)


        return publisher.flatMap({ statusResponse -> AnyPublisher<Bool, ServiceProviderError> in
            if statusResponse.status == "SUCCESS" {
                return Just(true).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }

            return Fail(outputType: Bool.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }

    func updateWeeklyBettingLimits(newLimit: Double) -> AnyPublisher<Bool, ServiceProviderError> {
        let endpoint = OmegaAPIClient.updateWeeklyBettingLimits(newLimit: newLimit)
        let publisher: AnyPublisher<SportRadarModels.StatusResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ statusResponse -> AnyPublisher<Bool, ServiceProviderError> in
            if statusResponse.status == "SUCCESS" {
                return Just(true).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            if let fieldError = statusResponse.errors?[0] {
                let messageError = fieldError.error

                return Fail(outputType: Bool.self, failure: ServiceProviderError.errorMessage(message: messageError)).eraseToAnyPublisher()
            }

            return Fail(outputType: Bool.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }

    func updateResponsibleGamingLimits(newLimit: Double) -> AnyPublisher<Bool, ServiceProviderError> {
        let endpoint = OmegaAPIClient.updateResponsibleGamingLimits(newLimit: newLimit)
        let publisher: AnyPublisher<SportRadarModels.StatusResponse, ServiceProviderError> = self.connector.request(endpoint)


        return publisher.flatMap({ statusResponse -> AnyPublisher<Bool, ServiceProviderError> in
            print("AUTO_PAYOUT: \(statusResponse)")
            if statusResponse.status == "SUCCESS" {
                return Just(true).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }

            return Fail(outputType: Bool.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }

    func getPersonalDepositLimits() -> AnyPublisher<PersonalDepositLimitResponse, ServiceProviderError> {
        let endpoint = OmegaAPIClient.getPersonalDepositLimits
        let publisher: AnyPublisher<SportRadarModels.PersonalDepositLimitResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ personalDepositLimitResponse -> AnyPublisher<PersonalDepositLimitResponse, ServiceProviderError> in
            if personalDepositLimitResponse.status == "SUCCESS" {

                let personalDepositLimitResponse = SportRadarModelMapper.personalDepositLimitsResponse(fromPersonalDepositLimitsResponse: personalDepositLimitResponse)

                return Just(personalDepositLimitResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }

            return Fail(outputType: PersonalDepositLimitResponse.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }

    func getLimits() -> AnyPublisher<LimitsResponse, ServiceProviderError> {
        let endpoint = OmegaAPIClient.getLimits

        let publisher: AnyPublisher<SportRadarModels.LimitsResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ limitsResponse -> AnyPublisher<LimitsResponse, ServiceProviderError> in
            if limitsResponse.status == "SUCCESS" {

                let limitsResponse = SportRadarModelMapper.limitsResponse(fromInternalLimitsResponse: limitsResponse)

                return Just(limitsResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }

            return Fail(outputType: LimitsResponse.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }

    func getResponsibleGamingLimits() -> AnyPublisher<ResponsibleGamingLimitsResponse, ServiceProviderError> {
        let endpoint = OmegaAPIClient.getResponsibleGamingLimits(limitType: "BALANCE_LIMIT", periodType: "PERMANENT")

        let publisher: AnyPublisher<SportRadarModels.ResponsibleGamingLimitsResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ responsibleGamingLimitsResponse -> AnyPublisher<ResponsibleGamingLimitsResponse, ServiceProviderError> in
            if responsibleGamingLimitsResponse.status == "SUCCESS" {
                let responsibleGamingLimitsResponse = SportRadarModelMapper.responsibleGamingLimitsResponse(fromResponsibleGamingLimitsResponse: responsibleGamingLimitsResponse)

                return Just(responsibleGamingLimitsResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }

            return Fail(outputType: ResponsibleGamingLimitsResponse.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }

    func lockPlayer(isPermanent: Bool? = nil, lockPeriodUnit: String? = nil, lockPeriod: String? = nil) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        let endpoint = OmegaAPIClient.lockPlayer(isPermanent: isPermanent, lockPeriodUnit: lockPeriodUnit, lockPeriod: lockPeriod)

        let publisher: AnyPublisher<SportRadarModels.BasicResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ lockPlayerResponse -> AnyPublisher<BasicResponse, ServiceProviderError> in
            if lockPlayerResponse.status == "SUCCESS" {

                let lockPlayerResponse = SportRadarModelMapper.basicResponse(fromInternalBasicResponse: lockPlayerResponse)

                return Just(lockPlayerResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }

            return Fail(outputType: BasicResponse.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }

    func getUserBalance() -> AnyPublisher<UserWallet, ServiceProviderError> {
        let endpoint = OmegaAPIClient.getBalance
        let publisher: AnyPublisher<SportRadarModels.BalanceResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ balanceResponse -> AnyPublisher<UserWallet, ServiceProviderError> in
            if balanceResponse.status == "SUCCESS" {
                let userWallet = SportRadarModelMapper.userWallet(fromBalanceResponse: balanceResponse)
                return Just(userWallet).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            return Fail(outputType: UserWallet.self,
                        failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }

    func getUserCashbackBalance() -> AnyPublisher<CashbackBalance, ServiceProviderError> {
        let endpoint = OmegaAPIClient.getCashbackBalance
        let publisher: AnyPublisher<SportRadarModels.CashbackBalance, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ cashbackBalance -> AnyPublisher<CashbackBalance, ServiceProviderError> in
            if cashbackBalance.status == "SUCCESS" {

                let mappedCashbackBalance = SportRadarModelMapper.cashbackBalance(fromCashbackBalance: cashbackBalance)

                return Just(mappedCashbackBalance).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            return Fail(outputType: CashbackBalance.self,
                        failure: ServiceProviderError.errorMessage(message: cashbackBalance.message ?? "Error")).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }

    func signUpCompletion(form: ServicesProvider.UpdateUserProfileForm)  -> AnyPublisher<Bool, ServiceProviderError> {
        let endpoint = OmegaAPIClient.quickSignupCompletion(firstName: form.firstName,
                                                            lastName: form.lastName,
                                                            birthDate: form.birthDate,
                                                            gender: form.gender,
                                                            mobileNumber: form.mobileNumber,
                                                            address: form.address,
                                                            province: form.province,
                                                            city: form.city,
                                                            postalCode: form.postalCode,
                                                            country: form.country?.iso2Code,
                                                            cardId: form.cardId,
                                                            securityQuestion: form.securityQuestion,
                                                            securityAnswer: form.securityAnswer)

        let publisher: AnyPublisher<SportRadarModels.StatusResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ statusResponse -> AnyPublisher<Bool, ServiceProviderError> in
            if statusResponse.status == "SUCCESS" {
                return Just(true).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }

            return Fail(outputType: Bool.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()

    }

    // Documents
    func getDocumentTypes() -> AnyPublisher<DocumentTypesResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.getDocumentTypes
        let publisher: AnyPublisher<SportRadarModels.DocumentTypesResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ documentTypesResponse -> AnyPublisher<DocumentTypesResponse, ServiceProviderError> in
            if documentTypesResponse.status == "SUCCESS" {
                let documentTypesResponse = SportRadarModelMapper.documentTypesResponse(fromDocumentTypesResponse: documentTypesResponse)
                return Just(documentTypesResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else {
                return Fail(outputType: DocumentTypesResponse.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func getUserDocuments() -> AnyPublisher<UserDocumentsResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.getUserDocuments
        let publisher: AnyPublisher<SportRadarModels.UserDocumentsResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ userDocumentsResponse -> AnyPublisher<UserDocumentsResponse, ServiceProviderError> in
            if userDocumentsResponse.status == "SUCCESS" {
                let userDocumentsResponse = SportRadarModelMapper.userDocumentsResponse(fromUserDocumentsResponse: userDocumentsResponse)
                return Just(userDocumentsResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else {
                return Fail(outputType: UserDocumentsResponse.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func uploadUserDocument(documentType: String, file: Data, fileName: String) -> AnyPublisher<UploadDocumentResponse, ServiceProviderError> {

        var multipart = MultipartRequest()

        let mimeType = mimeType(for: file)

        multipart.add(key: "documentType", value: documentType)

        multipart.add(
            key: "file",
            fileName: fileName,
            fileMimeType: mimeType,
            fileData: file
        )

        if documentType == "IDENTITY_CARD" {
            multipart.add(key: "issueDate", value: "2022-12-01")
            multipart.add(key: "expiryDate", value: "2024-08-01")
            multipart.add(key: "documentNumber", value: "123456789")
        }
        else if documentType == "OTHERS" {
            multipart.add(key: "expiryDate", value: "2024-08-01")
            multipart.add(key: "documentNumber", value: "120123128")
        }

        let endpoint = OmegaAPIClient.uploadUserDocument(documentType: documentType, file: file, body: multipart.httpBody, header: multipart.httpContentTypeHeaderValue)

        let publisher: AnyPublisher<SportRadarModels.UploadDocumentResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ uploadDocumentResponse -> AnyPublisher<UploadDocumentResponse, ServiceProviderError> in
            if uploadDocumentResponse.status == "SUCCESS" {
                let uploadDocumentResponse = SportRadarModelMapper.uploadDocumentResponse(fromUploadDocumentResponse: uploadDocumentResponse)
                return Just(uploadDocumentResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else {
                return Fail(outputType: UploadDocumentResponse.self, failure: ServiceProviderError.errorMessage(message: uploadDocumentResponse.message ?? "Error")).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func uploadMultipleUserDocuments(documentType: String, files: [String: Data]) -> AnyPublisher<UploadDocumentResponse, ServiceProviderError> {

        var multipart = MultipartRequest()

        multipart.add(key: "documentType", value: documentType)

        var fileCount = 0

        for (key, file) in files {
            let mimeType = mimeType(for: file)

            multipart.add(
                key: "_file_\(fileCount)",
                fileName: key,
                fileMimeType: mimeType,
                fileData: file
            )

            fileCount += 1
        }

        let currentDate = Date()

        var issuedDateComponent = DateComponents()
        issuedDateComponent.year = -1
        let issuedDate = Calendar.current.date(byAdding: issuedDateComponent, to: currentDate) ?? currentDate

        var expiryDateComponent = DateComponents()
        expiryDateComponent.year = 3
        let expiryDate = Calendar.current.date(byAdding: expiryDateComponent, to: currentDate) ?? currentDate

        // Create a date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let expiryDateString = dateFormatter.string(from: expiryDate)
        let issuedDateString = dateFormatter.string(from: issuedDate)

        if documentType == "IDENTITY_CARD" {
            multipart.add(key: "issueDate", value: issuedDateString)
            multipart.add(key: "expiryDate", value: expiryDateString)
            multipart.add(key: "documentNumber", value: "123456789")
        }
        else if documentType == "RESIDENCE_ID" {
            multipart.add(key: "issueDate", value: issuedDateString)
            multipart.add(key: "expiryDate", value: expiryDateString)
            multipart.add(key: "documentNumber", value: "123456789")
        }
        else if documentType == "DRIVING_LICENCE" {
            multipart.add(key: "issueDate", value: issuedDateString)
            multipart.add(key: "expiryDate", value: expiryDateString)
            multipart.add(key: "documentNumber", value: "123456789")
        }
        else if documentType == "RESIDENCE_ID" {
            multipart.add(key: "issueDate", value: issuedDateString)
            multipart.add(key: "expiryDate", value: expiryDateString)
            multipart.add(key: "documentNumber", value: "123456789")
        }
        else if documentType == "OTHERS" {
            multipart.add(key: "expiryDate", value: expiryDateString)
            multipart.add(key: "documentNumber", value: "120123128")
        }

        let endpoint = OmegaAPIClient.uploadMultipleUserDocuments(documentType: documentType, files: files, body: multipart.httpBody, header: multipart.httpContentTypeHeaderValue)

        let publisher: AnyPublisher<SportRadarModels.UploadDocumentResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ uploadDocumentResponse -> AnyPublisher<UploadDocumentResponse, ServiceProviderError> in
            if uploadDocumentResponse.status == "SUCCESS" {
                let uploadDocumentResponse = SportRadarModelMapper.uploadDocumentResponse(fromUploadDocumentResponse: uploadDocumentResponse)
                return Just(uploadDocumentResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else {
                return Fail(outputType: UploadDocumentResponse.self, failure: ServiceProviderError.errorMessage(message: uploadDocumentResponse.message ?? "Error")).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func getPayments() -> AnyPublisher<SimplePaymentMethodsResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.getPayments
        let publisher: AnyPublisher<SportRadarModels.PaymentsResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ paymentsResponse -> AnyPublisher<SimplePaymentMethodsResponse, ServiceProviderError> in
            if paymentsResponse.status == "SUCCESS" {
                let paymentsResponse = SportRadarModelMapper.paymentsResponse(fromPaymentsResponse: paymentsResponse)

                // Only ADYEN_ALL methods
                let allPaymentMethods = paymentsResponse.depositMethods.filter({
                    $0.code == "ADYEN_ALL"
                })

                // Aditional encoding/decoding data needed for Omega
                // If needed to get all methods
                let paymentMethods = allPaymentMethods.compactMap({ $0.methods }).filter({!$0.isEmpty}).flatMap({$0})

                if !paymentMethods.isEmpty {

                    let simplePaymentMethods = paymentMethods.map({ method -> SimplePaymentMethod in
                        return SimplePaymentMethod(name: method.name, type: method.type)
                    })

//                    // Remove duplicates
//                    var uniqueSimplePaymentMethods = [SimplePaymentMethod]()
//
//                    for method in simplePaymentMethods {
//                        if !uniqueSimplePaymentMethods.contains(method) {
//                            uniqueSimplePaymentMethods.append(method)
//                        }
//                    }

                    let simplePaymentMethodsResponse = SimplePaymentMethodsResponse(paymentMethods: simplePaymentMethods)

                    return Just(simplePaymentMethodsResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                }
                else {
                    return Fail(outputType: SimplePaymentMethodsResponse.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
                }

            }
            else {
                return Fail(outputType: SimplePaymentMethodsResponse.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func processDeposit(paymentMethod: String, amount: Double, option: String) -> AnyPublisher<ProcessDepositResponse, ServiceProviderError> {
        
        let endpoint = OmegaAPIClient.processDeposit(paymentMethod: paymentMethod, amount: amount, option: option)
        let publisher: AnyPublisher<SportRadarModels.ProcessDepositResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ processDepositResponse -> AnyPublisher<ProcessDepositResponse, ServiceProviderError> in
            if processDepositResponse.status == "CONTINUE_TO_PAYMENT_SITE" {
                let processDepositResponse = SportRadarModelMapper.processDepositResponse(fromProcessDepositResponse: processDepositResponse)
                return Just(processDepositResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else {
                return Fail(outputType: ProcessDepositResponse.self, failure: ServiceProviderError.errorMessage(message: processDepositResponse.message ?? "Error")).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func updatePayment(amount: Double, paymentId: String, type: String, returnUrl: String?) -> AnyPublisher<UpdatePaymentResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.updatePayment(amount: amount, paymentId: paymentId, type: type, returnUrl: returnUrl)
        
        let publisher: AnyPublisher<SportRadarModels.UpdatePaymentResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ updatePaymentResponse -> AnyPublisher<UpdatePaymentResponse, ServiceProviderError> in

            if updatePaymentResponse.resultCode == "RedirectShopper" {

                let updatePaymentResponse = SportRadarModelMapper.updatePaymentResponse(fromUpdatePaymentResponse: updatePaymentResponse)
                return Just(updatePaymentResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else {
                return Fail(outputType: UpdatePaymentResponse.self, failure: ServiceProviderError.errorMessage(message: "Update Payment Error")).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func cancelDeposit(paymentId: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.cancelDeposit(paymentId: paymentId)

        let publisher: AnyPublisher<SportRadarModels.BasicResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ basicResponse -> AnyPublisher<BasicResponse, ServiceProviderError> in

            if basicResponse.status == "SUCCESS" {

                let basicResponse = SportRadarModelMapper.basicResponse(fromInternalBasicResponse: basicResponse)

                return Just(basicResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else {
                return Fail(outputType: BasicResponse.self, failure: ServiceProviderError.errorMessage(message: basicResponse.message ?? "Error"))
                    .eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func checkPaymentStatus(paymentMethod: String, paymentId: String) -> AnyPublisher<PaymentStatusResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.checkPaymentStatus(paymentMethod: paymentMethod, paymentId: paymentId)
        let publisher: AnyPublisher<SportRadarModels.PaymentStatusResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ paymentStatusResponse -> AnyPublisher<PaymentStatusResponse, ServiceProviderError> in
            if paymentStatusResponse.status == "SUCCESS" {
                let basicResponse = SportRadarModelMapper.paymentStatusResponse(fromPaymentStatusResponse: paymentStatusResponse)
                return Just(basicResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else {
                return Fail(outputType: PaymentStatusResponse.self, failure: ServiceProviderError.errorMessage(message: paymentStatusResponse.message ?? "Error"))
                    .eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }
    
    func getWithdrawalMethods() -> AnyPublisher<[WithdrawalMethod], ServiceProviderError> {

        let endpoint = OmegaAPIClient.getWithdrawalsMethods
        let publisher: AnyPublisher<SportRadarModels.WithdrawalMethodsResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ withdrawalMethodsResponse -> AnyPublisher<[WithdrawalMethod], ServiceProviderError> in
            if withdrawalMethodsResponse.status == "SUCCESS" {

                let withdrawalMethodsResponse = SportRadarModelMapper.withdrawalMethodsResponse(fromWithdrawalMethodsResponse: withdrawalMethodsResponse)

                return Just(withdrawalMethodsResponse.withdrawalMethods).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()

            }
            else {
                return Fail(outputType: [WithdrawalMethod].self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func processWithdrawal(paymentMethod: String, amount: Double) -> AnyPublisher<ProcessWithdrawalResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.processWithdrawal(withdrawalMethod: paymentMethod, amount: amount)
        let publisher: AnyPublisher<SportRadarModels.ProcessWithdrawalResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ processWithdrawalResponse -> AnyPublisher<ProcessWithdrawalResponse, ServiceProviderError> in
            if processWithdrawalResponse.status == "SUCCESS" {

                let processWithdrawalResponse = SportRadarModelMapper.processWithdrawalResponse(fromProcessWithdrawalResponse: processWithdrawalResponse)

                return Just(processWithdrawalResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else {
                return Fail(outputType: ProcessWithdrawalResponse.self, failure: ServiceProviderError.errorMessage(message: processWithdrawalResponse.message ?? "Error")).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func getPendingWithdrawals() -> AnyPublisher<[PendingWithdrawal], ServiceProviderError> {

        let endpoint = OmegaAPIClient.getPendingWithdrawals
        let publisher: AnyPublisher<SportRadarModels.PendingWithdrawalResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ pendingWithdrawalsResponse -> AnyPublisher<[PendingWithdrawal], ServiceProviderError> in
            if pendingWithdrawalsResponse.status == "SUCCESS" {

                let pendingWithdrawalsResponse = SportRadarModelMapper.pendingWithdrawalResponse(fromPendingWithdrawalResponse: pendingWithdrawalsResponse)

                return Just(pendingWithdrawalsResponse.pendingWithdrawals).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()

            }
            else {
                return Fail(outputType: [PendingWithdrawal].self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func cancelWithdrawal(paymentId: Int) -> AnyPublisher<CancelWithdrawalResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.cancelWithdrawal(paymentId: paymentId)
        let publisher: AnyPublisher<SportRadarModels.CancelWithdrawalResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ cancelWithdrawalResponse -> AnyPublisher<CancelWithdrawalResponse, ServiceProviderError> in
            if cancelWithdrawalResponse.status == "SUCCESS" {

                let cancelWithdrawalResponse = SportRadarModelMapper.cancelWithdrawalResponse(fromCancelWithdrawalResponse: cancelWithdrawalResponse)

                return Just(cancelWithdrawalResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else {
                return Fail(outputType: CancelWithdrawalResponse.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func getPaymentInformation() -> AnyPublisher<PaymentInformation, ServiceProviderError> {

        let endpoint = OmegaAPIClient.getPaymentInformation
        let publisher: AnyPublisher<SportRadarModels.PaymentInformation, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ paymentInformation -> AnyPublisher<PaymentInformation, ServiceProviderError> in
            if paymentInformation.status == "SUCCESS" {

                let paymentInformation = SportRadarModelMapper.paymentInformation(fromPaymentInformation: paymentInformation)

                return Just(paymentInformation).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()

            }
            else {
                return Fail(outputType: PaymentInformation.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func addPaymentInformation(type: String, fields: String) -> AnyPublisher<AddPaymentInformationResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.addPaymentInformation(type: type, fields: fields)
        let publisher: AnyPublisher<SportRadarModels.AddPaymentInformationResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ addPaymentInformation -> AnyPublisher<AddPaymentInformationResponse, ServiceProviderError> in
            if addPaymentInformation.status == "SUCCESS" {

                let addPaymentInformation = SportRadarModelMapper.addPaymentInformationResponse(fromAddPaymentInformationResponse: addPaymentInformation)

                return Just(addPaymentInformation).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()

            }
            else {
                return Fail(outputType: AddPaymentInformationResponse.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func getTransactionsHistory(startDate: String, endDate: String, transactionTypes: [TransactionType]? = nil, pageNumber: Int? = nil) -> AnyPublisher<[TransactionDetail], ServiceProviderError> {

        var transactionTypesKeys = [String]()

        if let transactionTypes {
            for transactionType in transactionTypes {
                transactionTypesKeys.append(transactionType.transactionKey)
            }
        }

        let endpoint = OmegaAPIClient.getTransactionsHistory(startDate: startDate, endDate: endDate, transactionType: transactionTypesKeys, pageNumber: pageNumber, pageSize: 10)

        let publisher: AnyPublisher<SportRadarModels.TransactionsHistoryResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ transactionsHistoryResponse -> AnyPublisher<[TransactionDetail], ServiceProviderError> in
            if transactionsHistoryResponse.status == "SUCCESS" {

                let mappedTransactionsHistoryResponse = SportRadarModelMapper.transactionsHistoryResponse(fromTransactionsHistoryResponse: transactionsHistoryResponse)

                if let transactions = mappedTransactionsHistoryResponse.transactions {

                    return Just(transactions).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                }

                return Just([]).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()

            }
            else {
                return Fail(outputType: [TransactionDetail].self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func getGrantedBonuses() -> AnyPublisher<[GrantedBonus], ServiceProviderError> {

        let endpoint = OmegaAPIClient.getGrantedBonuses

        let publisher: AnyPublisher<SportRadarModels.GrantedBonusResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ grantedBonusResponse -> AnyPublisher<[GrantedBonus], ServiceProviderError> in
            if grantedBonusResponse.status == "SUCCESS" {

                let grantedBonusResponse = SportRadarModelMapper.grantedBonusesResponse(fromGrantedBonusesResponse: grantedBonusResponse)

                let grantedBonuses = grantedBonusResponse.bonuses

                return Just(grantedBonuses).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()

            }
            else {
                return Fail(outputType: [GrantedBonus].self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func redeemBonus(code: String) -> AnyPublisher<RedeemBonusResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.redeemBonus(code: code)

        let publisher: AnyPublisher<SportRadarModels.RedeemBonusResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ redeemBonusResponse -> AnyPublisher<RedeemBonusResponse, ServiceProviderError> in
            if redeemBonusResponse.status == "SUCCESS" {

                let redeemBonusResponse = SportRadarModelMapper.redeemBonusesResponse(fromRedeemBonusesResponse: redeemBonusResponse)


                return Just(redeemBonusResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()

            }
            else {
                return Fail(outputType: RedeemBonusResponse.self, failure: ServiceProviderError.errorMessage(message: redeemBonusResponse.status)).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func getAvailableBonuses() -> AnyPublisher<[AvailableBonus], ServiceProviderError> {

        let endpoint = OmegaAPIClient.getAvailableBonuses

        let publisher: AnyPublisher<SportRadarModels.AvailableBonusResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ availableBonusResponse -> AnyPublisher<[AvailableBonus], ServiceProviderError> in
            if availableBonusResponse.status == "SUCCESS" {

                let availableBonusResponse = SportRadarModelMapper.availableBonusesResponse(fromAvailableBonusesResponse: availableBonusResponse)

                let availableBonuses = availableBonusResponse.bonuses

                return Just(availableBonuses).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()

            }
            else {
                return Fail(outputType: [AvailableBonus].self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func redeemAvailableBonus(partyId: String, code: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.redeemAvailableBonuses(partyId: partyId, bonusId: code)

        let publisher: AnyPublisher<SportRadarModels.BasicResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ basicResponse -> AnyPublisher<BasicResponse, ServiceProviderError> in
            if basicResponse.status == "SUCCESS" {

                let basicResponse = SportRadarModelMapper.basicResponse(fromInternalBasicResponse: basicResponse)

                return Just(basicResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()

            }
            else {
                return Fail(outputType: BasicResponse.self, failure: ServiceProviderError.errorMessage(message: basicResponse.message ?? "Error")).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func cancelBonus(bonusId: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.cancelBonus(bonusId: bonusId)

        let publisher: AnyPublisher<SportRadarModels.BasicResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ basicResponse -> AnyPublisher<BasicResponse, ServiceProviderError> in
            if basicResponse.status == "SUCCESS" {

                let basicResponse = SportRadarModelMapper.basicResponse(fromInternalBasicResponse: basicResponse)

                return Just(basicResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()

            }
            else {
                return Fail(outputType: BasicResponse.self, failure: ServiceProviderError.errorMessage(message: basicResponse.message ?? "Error")).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func optOutBonus(partyId: String, code: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.optOutBonus(partyId: partyId, bonusId: code)

        let publisher: AnyPublisher<SportRadarModels.BasicResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ basicResponse -> AnyPublisher<BasicResponse, ServiceProviderError> in
            if basicResponse.status == "SUCCESS" {

                let basicResponse = SportRadarModelMapper.basicResponse(fromInternalBasicResponse: basicResponse)

                return Just(basicResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()

            }
            else {
                return Fail(outputType: BasicResponse.self, failure: ServiceProviderError.errorMessage(message: basicResponse.message ?? "Error")).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func contactUs(firstName: String, lastName: String, email: String, subject: String, message: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.contactUs(firstName: firstName, lastName: lastName, email: email, subject: subject, message: message)

        let publisher: AnyPublisher<SportRadarModels.BasicResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ basicResponse -> AnyPublisher<BasicResponse, ServiceProviderError> in
            if basicResponse.status == "SUCCESS" {

                let basicResponse = SportRadarModelMapper.basicResponse(fromInternalBasicResponse: basicResponse)

                return Just(basicResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()

            }
            else {
                return Fail(outputType: BasicResponse.self, failure: ServiceProviderError.errorMessage(message: basicResponse.message ?? "Error")).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func contactSupport(userIdentifier: String, firstName: String, lastName: String, email: String, subject: String, subjectType: String, message: String, isLogged: Bool) -> AnyPublisher<SupportResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.contactSupport(userIdentifier: userIdentifier, firstName: firstName, lastName: lastName, email: email, subject: subject, subjectType: subjectType, message: message, isLogged: isLogged)

        let publisher: AnyPublisher<SportRadarModels.SupportResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ supportResponse -> AnyPublisher<SupportResponse, ServiceProviderError> in
            
            if supportResponse.request != nil {

                let supportResponse = SportRadarModelMapper.supportResponse(fromInternalSupportResponse: supportResponse)

                return Just(supportResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()

            }
            else {
                return Fail(outputType: SupportResponse.self, failure: ServiceProviderError.errorMessage(message: supportResponse.description ?? "Error")).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func getUserConsents() -> AnyPublisher<[UserConsent], ServiceProviderError> {

        let endpoint = OmegaAPIClient.getUserConsents

        let publisher: AnyPublisher<SportRadarModels.UserConsentsResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ userConsentsResponse -> AnyPublisher<[UserConsent], ServiceProviderError> in
            if userConsentsResponse.status == "SUCCESS" {

                let mappedUserConsentsResponse = SportRadarModelMapper.userConsentResponse(fromUserConsentsResponse: userConsentsResponse)

                return Just(mappedUserConsentsResponse.userConsents).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()

            }
            else {
                return Fail(outputType: [UserConsent].self, failure: ServiceProviderError.errorMessage(message: userConsentsResponse.message ?? "Error")).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func setUserConsents(consentVersionIds: [Int]?, unconsenVersionIds: [Int]?) -> AnyPublisher<BasicResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.setUserConsents(consentVersionIds: consentVersionIds, unconsentVersionIds: unconsenVersionIds)

        let publisher: AnyPublisher<SportRadarModels.BasicResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ basicResponse -> AnyPublisher<BasicResponse, ServiceProviderError> in
            if basicResponse.status == "SUCCESS" {

                let basicResponse = SportRadarModelMapper.basicResponse(fromInternalBasicResponse: basicResponse)

                return Just(basicResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            return Fail(outputType: BasicResponse.self, failure: ServiceProviderError.errorMessage(message: basicResponse.message ?? "Error")).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }

    func getSumsubAccessToken(userId: String, levelName: String) -> AnyPublisher<AccessTokenResponse, ServiceProviderError> {

        // let url = "/resources/accessTokens?userId=\(userId)&levelName=\(levelName)&ttlInSecs=600".replacingOccurrences(of: " ", with: "%20")
        var customAllowedSet =  NSCharacterSet(charactersIn:"; ").inverted

        let url = "/resources/accessTokens?userId=\(userId)&levelName=\(levelName)".addingPercentEncoding(withAllowedCharacters: customAllowedSet) ?? ""

        let method = "post"

        let secretKeyData = self.sumsubSecretKey.data(using: String.Encoding.utf8) ?? Data()

        let signatureHeaders = self.generateSignatureHeaders(url: url, method: method, secretKeyData: secretKeyData, appToken: self.sumsubAppToken)

        let endpoint = OmegaAPIClient.getSumsubAccessToken(userId: userId, levelName: levelName, body: nil, header: signatureHeaders)

        let publisher: AnyPublisher<SportRadarModels.AccessTokenResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ accessTokenResponse -> AnyPublisher<AccessTokenResponse, ServiceProviderError> in
            if let acessToken = accessTokenResponse.token {
                let mappedAccessTokenResponse = SportRadarModelMapper.accessTokenResponse(fromInternalAccessTokenResponse: accessTokenResponse)

                return Just(mappedAccessTokenResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else {
                return Fail(outputType: AccessTokenResponse.self, failure: ServiceProviderError.errorMessage(message: accessTokenResponse.description ?? "Error")).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func getSumsubApplicantData(userId: String) -> AnyPublisher<ApplicantDataResponse, ServiceProviderError> {

        //let url = "/resources/applicants/-;externalUserId=\(userId)/one".replacingOccurrences(of: " ", with: "%20")
        var customAllowedSet =  NSCharacterSet(charactersIn:" ").inverted

        let url = "/resources/applicants/-;externalUserId=\(userId)/one".addingPercentEncoding(withAllowedCharacters: customAllowedSet) ?? ""

        let method = "get"

        let secretKeyData = self.sumsubSecretKey.data(using: String.Encoding.utf8) ?? Data()

        let signatureHeaders = self.generateSignatureHeaders(url: url, method: method, secretKeyData: secretKeyData, appToken: self.sumsubAppToken)

        let endpoint = OmegaAPIClient.getSumsubApplicantData(userId: userId, header: signatureHeaders)

        let publisher: AnyPublisher<SportRadarModels.ApplicantDataResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ applicantDataResponse -> AnyPublisher<ApplicantDataResponse, ServiceProviderError> in
            if let acessToken = applicantDataResponse.info {
                let mappedApplicantDataResponse = SportRadarModelMapper.applicantDataResponse(fromInternalApplicantDataResponse: applicantDataResponse)

                return Just(mappedApplicantDataResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else {
                return Fail(outputType: ApplicantDataResponse.self, failure: ServiceProviderError.errorMessage(message: applicantDataResponse.description ?? "Error")).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func generateDocumentTypeToken(docType: String) -> AnyPublisher<AccessTokenResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.generateDocumentTypeToken(docType: docType)

        let publisher: AnyPublisher<SportRadarModels.AccessTokenResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ accessTokenResponse -> AnyPublisher<AccessTokenResponse, ServiceProviderError> in
            if let acessToken = accessTokenResponse.token {
                
                let mappedAccessTokenResponse = SportRadarModelMapper.accessTokenResponse(fromInternalAccessTokenResponse: accessTokenResponse)

                return Just(mappedAccessTokenResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else {
                return Fail(outputType: AccessTokenResponse.self, failure: ServiceProviderError.errorMessage(message: accessTokenResponse.description ?? "Error")).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func checkDocumentationData() -> AnyPublisher<ApplicantDataResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.checkDocumentationData

        let publisher: AnyPublisher<SportRadarModels.ApplicantRootResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ applicantRootResponse -> AnyPublisher<ApplicantDataResponse, ServiceProviderError> in

            if applicantRootResponse.status == "SUCCESS" {

                let mappedApplicantDataResponse = SportRadarModelMapper.applicantDataResponse(fromInternalApplicantDataResponse: applicantRootResponse.data)

                return Just(mappedApplicantDataResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else {
                return Fail(outputType: ApplicantDataResponse.self, failure: ServiceProviderError.errorMessage(message: applicantRootResponse.message ?? "Error")).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }
    
    func getMobileVerificationCode(forMobileNumber mobileNumber: String) -> AnyPublisher<MobileVerifyResponse, ServiceProviderError> {
        let endpoint = OmegaAPIClient.getMobileVerificationCode(mobileNumber: mobileNumber)

        let publisher: AnyPublisher<SportRadarModels.MobileVerifyResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ mobileVerifyResponse -> AnyPublisher<MobileVerifyResponse, ServiceProviderError> in
            if mobileVerifyResponse.status == "PENDING" {
                let response = SportRadarModelMapper.mobileVerifyResponse(fromInternalMobileVerifyResponse: mobileVerifyResponse)
                return Just(response).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            return Fail(outputType: MobileVerifyResponse.self, failure: ServiceProviderError.errorMessage(message: mobileVerifyResponse.message ?? "Error")).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
        
    }
    
    func verifyMobileCode(code: String, requestId: String) -> AnyPublisher<MobileVerifyResponse, ServiceProviderError> {
        let endpoint = OmegaAPIClient.verifyMobileCode(code: code, requestId: requestId)

        let publisher: AnyPublisher<SportRadarModels.MobileVerifyResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ mobileVerifyResponse -> AnyPublisher<MobileVerifyResponse, ServiceProviderError> in
            if mobileVerifyResponse.status == "SUCCESS" {
                let response = SportRadarModelMapper.mobileVerifyResponse(fromInternalMobileVerifyResponse: mobileVerifyResponse)
                return Just(response).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else if mobileVerifyResponse.status == "INVALID_VALUE" {
                return Fail(outputType: MobileVerifyResponse.self, failure: ServiceProviderError.invalidMobileVerifyCode).eraseToAnyPublisher()
            }
            
            return Fail(outputType: MobileVerifyResponse.self, failure: ServiceProviderError.errorMessage(message: mobileVerifyResponse.message ?? "Error")).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
        
    }
    
}

extension SportRadarPrivilegedAccessManager: SportRadarSessionTokenUpdater {
    func forceTokenRefresh(forKey key: SessionCoordinatorKey) -> AnyPublisher<String?, Never> {

        if key == .launchToken {
            return self.connector
                .forceRefreshSession()
                .map(\.launchKey)
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        }
        else if key == .restSessionToken {
            return self.connector
                .forceRefreshSession()
                .map(\.sessionKey)
                .map(Optional<String>.init)
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        }
        else {
            return Just(nil)
                .eraseToAnyPublisher()
        }

    }

    func generateSignatureHeaders(url: String, method: String, bodyData: Data? = nil, secretKeyData: Data, appToken: String) -> [String: String] {

        let ts = Int(Date().timeIntervalSince1970)

        var dataToSign = "\(ts)\(method.uppercased())\(url)"

        if let bodyData {
            dataToSign += String(data: bodyData, encoding: .utf8) ?? ""
        }

        let data = Data(dataToSign.utf8)

        let hmac = HMAC<SHA256>.authenticationCode(for: data, using: SymmetricKey(data: secretKeyData))
        let signature = hmac.compactMap { String(format: "%02x", $0) }.joined()

        let headers = [
            "X-App-Token": "\(appToken)",
            "X-App-Access-Sig": signature,
            "X-App-Access-Ts": "\(ts)"
        ]

        return headers
    }
}
