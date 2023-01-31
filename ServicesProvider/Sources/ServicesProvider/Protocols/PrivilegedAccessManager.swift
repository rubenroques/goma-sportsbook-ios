//
//  PrivilegedAccessManager.swift
//  
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine
import SharedModels

enum UserSessionStatus {
    case anonymous
    case logged
}

protocol PrivilegedAccessManager {
    
    var userSessionStatePublisher: AnyPublisher<UserSessionStatus, Error> { get }
    var userProfilePublisher: AnyPublisher<UserProfile?, Error> { get }
    
    var hasSecurityQuestions: Bool { get }
    
    func login(username: String, password: String) -> AnyPublisher<UserProfile, ServiceProviderError>
    
    func getUserProfile() -> AnyPublisher<UserProfile, ServiceProviderError>
    func updateUserProfile(form: UpdateUserProfileForm) -> AnyPublisher<Bool, ServiceProviderError>
    
    func checkEmailRegistered(_ email: String) -> AnyPublisher<Bool, ServiceProviderError>

    func validateUsername(_ username: String) -> AnyPublisher<UsernameValidation, ServiceProviderError>

    func simpleSignUp(form: SimpleSignUpForm) -> AnyPublisher<Bool, ServiceProviderError>
    func signUp(form: SignUpForm) -> AnyPublisher<SignUpResponse, ServiceProviderError>
    
    func getCountries() -> AnyPublisher<[Country], ServiceProviderError>
    func getCurrentCountry() -> AnyPublisher<Country?, ServiceProviderError>
        
    func signupConfirmation(_ email: String, confirmationCode: String) -> AnyPublisher<Bool, ServiceProviderError>

    func forgotPassword(email: String, secretQuestion: String?, secretAnswer: String?) -> AnyPublisher<Bool, ServiceProviderError>
    func updatePassword(oldPassword: String, newPassword: String) -> AnyPublisher<Bool, ServiceProviderError>

    func updateWeeklyDepositLimits(newLimit: Double) -> AnyPublisher<Bool, ServiceProviderError>
    func updateWeeklyBettingLimits(newLimit: Double) -> AnyPublisher<Bool, ServiceProviderError>

    func getUserBalance() -> AnyPublisher<UserWallet, ServiceProviderError>
    func signUpCompletion(form: ServicesProvider.UpdateUserProfileForm)  -> AnyPublisher<Bool, ServiceProviderError>

    func getDocumentTypes() -> AnyPublisher<DocumentTypesResponse, ServiceProviderError>
    func getUserDocuments() -> AnyPublisher<UserDocumentsResponse, ServiceProviderError>
    func uploadUserDocument(documentType: String, file: Data, fileName: String) -> AnyPublisher<UploadDocumentResponse, ServiceProviderError>
    
}
