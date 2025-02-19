//
//  PromotionsProvider.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 19/02/2025.
//


//
//  PromotionsProvider.swift
//  
//
//  Created by André Lascas on 16/08/2024.
//

import Foundation
import Combine
import SharedModels

protocol PromotionsProvider {
    
    var userSessionStatePublisher: AnyPublisher<UserSessionStatus, Error> { get }
    var userProfilePublisher: AnyPublisher<UserProfile?, Error> { get }
    var providerEnabled: Bool { get }
    
    func updateDeviceIdentifier(deviceIdentifier: String) -> AnyPublisher<BasicResponse, ServiceProviderError>
    
    func isPromotionsProviderEnabled(isEnabled: Bool) -> AnyPublisher<Bool, ServiceProviderError>
    
    func login(username: String, password: String) -> AnyPublisher<UserProfile, ServiceProviderError>
    
    func anonymousLogin() -> AnyPublisher<String, ServiceProviderError>
            
    func logoutUser() -> AnyPublisher<String, ServiceProviderError>
    
    func basicSignUp(form: SignUpForm) -> AnyPublisher<DetailedSignUpResponse, ServiceProviderError>
    
}
