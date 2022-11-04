//
//  SportRadarPrivilegedAccessManager.swift
//  
//
//  Created by Ruben Roques on 24/10/2022.
//

import Foundation
import Combine

class SportRadarPrivilegedAccessManager: PrivilegedAccessManager {
    
    var connector: OmegaConnector
    var userSessionStatePublisher: AnyPublisher<UserSessionStatus, Error> {
        return userSessionStateSubject.eraseToAnyPublisher()
    }
    var userProfilePublisher: AnyPublisher<UserProfile?, Error> {
        return userProfileSubject.eraseToAnyPublisher()
    }
    
    private let userSessionStateSubject: CurrentValueSubject<UserSessionStatus, Error>
    private let userProfileSubject: CurrentValueSubject<UserProfile?, Error>
    
    required init(connector: Connector = OmegaConnector()) {
        self.connector = OmegaConnector()
        
        self.userSessionStateSubject = .init(.anonymous)
        self.userProfileSubject = .init(nil)
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
            if let fieldError = statusResponse.errors?[0] {
                let messageError = fieldError.error
                
                return Fail(outputType: Bool.self, failure: ServiceProviderError.errorMessage(message: messageError)).eraseToAnyPublisher()
            }

            return Fail(outputType: Bool.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()

    }

}
