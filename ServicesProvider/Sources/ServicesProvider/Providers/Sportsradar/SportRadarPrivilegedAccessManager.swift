//
//  SportRadarPrivilegedAccessManager.swift
//
//
//  Created by Ruben Roques on 24/10/2022.
//

import Foundation
import Combine
import SharedModels

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
                              province: form.province,
                              city: form.city,
                              postalCode: nil,
                              countryIso2Code: form.countryIsoCode,
                              cardId: nil,
                              securityQuestion: nil,
                              securityAnswer: nil,
                              bonusCode: form.bonusCode,
                              receiveMarketingEmails: form.receiveMarketingEmails,
                              avatarName: form.avatarName,
                              placeOfBirth: form.placeOfBirth,
                              additionalStreetAddress: form.additionalStreetAddress,
                              godfatherCode: form.godfatherCode)

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
            print("STATUS RESPONSE: \(statusResponse)")
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

    func getPayments() -> AnyPublisher<SimplePaymentMethodsResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.getPayments
        let publisher: AnyPublisher<SportRadarModels.PaymentsResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ paymentsResponse -> AnyPublisher<SimplePaymentMethodsResponse, ServiceProviderError> in
            if paymentsResponse.status == "SUCCESS" {
                let paymentsResponse = SportRadarModelMapper.paymentsResponse(fromPaymentsResponse: paymentsResponse)

                // Aditional encoding/decoding data needed for Omega
                // If needed to get all methods
                let paymentMethods = paymentsResponse.depositMethods.compactMap({ $0.methods }).filter({!$0.isEmpty}).flatMap({$0})

                    //                if let paymentMethods = paymentsResponse.depositMethods[safe: 0]?.methods {
                if !paymentMethods.isEmpty {
                    let simplePaymentMethods = paymentMethods.map({ method -> SimplePaymentMethod in
                        return SimplePaymentMethod(name: method.name, type: method.type)
                    })

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

    func updatePayment(paymentMethod: String, amount: Double, paymentId: String, type: String, issuer: String) -> AnyPublisher<UpdatePaymentResponse, ServiceProviderError> {

        let endpoint = OmegaAPIClient.updatePayment(paymentMethod: paymentMethod, amount: amount, paymentId: paymentId, type: type, issuer: issuer)
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

    func getTransactionsHistory(startDate: String, endDate: String, transactionType: String? = nil, pageNumber: Int? = nil) -> AnyPublisher<[TransactionDetail], ServiceProviderError> {

        let endpoint = OmegaAPIClient.getTransactionsHistory(startDate: startDate, endDate: endDate, transactionType: transactionType, pageNumber: pageNumber, pageSize: 10)

        let publisher: AnyPublisher<SportRadarModels.TransactionsHistoryResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ transactionsHistoryResponse -> AnyPublisher<[TransactionDetail], ServiceProviderError> in
            if transactionsHistoryResponse.status == "SUCCESS" {

                let transactionsHistoryResponse = SportRadarModelMapper.transactionsHistoryResponse(fromTransactionsHistoryResponse: transactionsHistoryResponse)

                if let transactions = transactionsHistoryResponse.transactions {

                    return Just(transactions).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                }

                return Just([]).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
//                return Just(transactionsHistoryResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()

            }
            else {
                return Fail(outputType: [TransactionDetail].self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }
}

