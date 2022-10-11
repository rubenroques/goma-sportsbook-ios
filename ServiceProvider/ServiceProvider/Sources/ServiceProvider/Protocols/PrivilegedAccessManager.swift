//
//  PrivilegedAccessManager.swift
//  
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine

enum UserSessionState {
    case anonymous
    case logged
}

protocol PrivilegedAccessManager {

    init(connector: Connector)
    
    var userSessionStatePublisher: AnyPublisher<UserSessionState, Error> { get }
    
    func login()
    func register()
    func recoverPassword()
    func changePassword()
    func getProfile()
    func getProfileStatus()

}
