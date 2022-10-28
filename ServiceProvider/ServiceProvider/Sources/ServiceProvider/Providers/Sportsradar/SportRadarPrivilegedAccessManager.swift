//
//  SportRadarPrivilegedAccessManager.swift
//  
//
//  Created by Ruben Roques on 24/10/2022.
//

import Foundation
import Combine

class SportRadarPrivilegedAccessManager: PrivilegedAccessManager {
    
    var connector: Connector
    
    var userSessionStatePublisher: AnyPublisher<UserSessionStatus, Error> {
        return userSessionStateSubject.eraseToAnyPublisher()
    }

    var userProfilePublisher: AnyPublisher<UserProfile?, Error> {
        return userProfileSubject.eraseToAnyPublisher()
    }
    
    private var networkManager: NetworkManager
    
    private let userSessionStateSubject: CurrentValueSubject<UserSessionStatus, Error>
    private let userProfileSubject: CurrentValueSubject<UserProfile?, Error>
    
    required init(connector: Connector = OmegaConnector()) {
        self.connector = connector
        self.networkManager = NetworkManager()
        
        self.userSessionStateSubject = .init(.anonymous)
        self.userProfileSubject = .init(nil)
    }
    
    func login(username: String, password: String) -> AnyPublisher<UserProfile, ServiceProviderError> {
        
        let publisher: AnyPublisher<SportRadarModels.LoginResponse, ServiceProviderError> = self.networkManager.request(OmegaAPIClient.login(username: username, password: password))
        
        return publisher.flatMap({ [weak self] loginResponse -> AnyPublisher<UserProfile, ServiceProviderError> in
            
            guard
                let self = self
            else {
                return Fail(outputType: UserProfile.self, failure: ServiceProviderError.unknown).eraseToAnyPublisher()
            }
            
            if loginResponse.status == "FAIL_UN_PW" {
                self.connector.token = nil
                return Fail(outputType: UserProfile.self, failure: ServiceProviderError.invalidEmailPassword).eraseToAnyPublisher()
            }
            else if loginResponse.status == "FAIL_QUICK_OPEN_STATUS" {
                self.connector.token = nil
                return Fail(outputType: UserProfile.self, failure: ServiceProviderError.quickSignUpIncomplete).eraseToAnyPublisher()
            }
            else if loginResponse.status == "SUCCESS", let user = SportRadarModelMapper.userOverview(fromInternalLoginResponse: loginResponse) {
                self.connector.token = OmegaSessionAccessToken(hash: user.sessionKey)
                return self.getUserProfile()
                // return Just(user).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            return Fail(outputType: UserProfile.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .print("SportRadarPrivilegedAccessManager publisher")
        .eraseToAnyPublisher()
        
    }

    func getUserProfile() -> AnyPublisher<UserProfile, ServiceProviderError> {
        
        guard let sessionKey = self.retrieveSessionKey() else {
            return Fail(outputType: UserProfile.self, failure: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }
        
        let endpoint = OmegaAPIClient.playerInfo(sessionKey: sessionKey)
        let publisher: AnyPublisher<SportRadarModels.PlayerInfoResponse, ServiceProviderError> = self.networkManager.request(endpoint)
        
        return publisher.flatMap({ playerInfoResponse -> AnyPublisher<UserProfile, ServiceProviderError> in
            if playerInfoResponse.status == "SUCCESS", let userOverview = SportRadarModelMapper.userProfile(fromPlayerInfoResponse: playerInfoResponse) {
                return Just(userOverview).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            return Fail(outputType: UserProfile.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
    
    private func retrieveSessionKey() -> String? {
        return self.connector.token?.hash
    }
    
    func checkEmailRegistered(_ email: String) -> AnyPublisher<Bool, ServiceProviderError> {
        let endpoint = OmegaAPIClient.checkCredentialEmail(email: email)
        
        let publisher: AnyPublisher<SportRadarModels.CheckCredentialResponse, ServiceProviderError> = self.networkManager.request(endpoint)
        
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
        
        let publisher: AnyPublisher<SportRadarModels.QuickSignUpResponse, ServiceProviderError> = self.networkManager.request(endpoint)
        
        return publisher.flatMap({ quickSignUpResponse -> AnyPublisher<Bool, ServiceProviderError> in
            if quickSignUpResponse.status == "SUCCESS" {
                return Just(true).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else if let errors = quickSignUpResponse.errors {
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
 
    
    
    public func getCountries() -> AnyPublisher<[Country], ServiceProviderError> {
        
        let endpoint = OmegaAPIClient.getCountries
        let publisher: AnyPublisher<SportRadarModels.GetCountriesResponse, ServiceProviderError> = self.networkManager.request(endpoint)
        
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
        let publisher: AnyPublisher<SportRadarModels.GetCountryInfoResponse, ServiceProviderError> = self.networkManager.request(endpoint)
        
        return publisher.flatMap({ countryInfo -> AnyPublisher<Country?, ServiceProviderError> in
            if countryInfo.status == "SUCCESS" {
                return Just(Country(isoCode: countryInfo.countryInfo.iso2Code)).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            else {
                return Fail(outputType: Country?.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }
    
    
}
