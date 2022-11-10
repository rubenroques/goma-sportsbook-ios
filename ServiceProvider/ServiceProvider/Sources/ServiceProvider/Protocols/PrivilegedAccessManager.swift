//
//  PrivilegedAccessManager.swift
//  
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine

enum UserSessionStatus {
    case anonymous
    case logged
}

protocol PrivilegedAccessManager {

    init(connector: Connector)
    
    var userSessionStatePublisher: AnyPublisher<UserSessionStatus, Error> { get }
    var userProfilePublisher: AnyPublisher<UserProfile?, Error> { get }
    var hasSecurityQuestions: Bool { get }
    
    func login(username: String, password: String) -> AnyPublisher<UserProfile, ServiceProviderError>
    
    func getUserProfile() -> AnyPublisher<UserProfile, ServiceProviderError>
    func updateUserProfile(form: UpdateUserProfileForm) -> AnyPublisher<Bool, ServiceProviderError>
    
    func checkEmailRegistered(_ email: String) -> AnyPublisher<Bool, ServiceProviderError>
    
    func simpleSignUp(form: SimpleSignUpForm) -> AnyPublisher<Bool, ServiceProviderError>
    
    func getCountries() -> AnyPublisher<[Country], ServiceProviderError>
    func getCurrentCountry() -> AnyPublisher<Country?, ServiceProviderError>
        
    func signupConfirmation(_ email: String, confirmationCode: String) -> AnyPublisher<Bool, ServiceProviderError>

    func forgotPassword(email: String, secretQuestion: String?, secretAnswer: String?) -> AnyPublisher<Bool, ServiceProviderError>
    func updatePassword(oldPassword: String, newPassword: String) -> AnyPublisher<Bool, ServiceProviderError>

    func getUserBalance() -> AnyPublisher<UserWallet, ServiceProviderError>
    func signUpCompletion(form: ServiceProvider.UpdateUserProfileForm)  -> AnyPublisher<Bool, ServiceProviderError>
    
}
