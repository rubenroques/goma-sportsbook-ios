//
//  RegisterUserError.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 22/07/2025.
//

import Foundation

enum RegisterUserError: Error {
    case usernameInvalid
    case emailInvalid
    case passwordInvalid
    case usernameAlreadyUsed
    case emailAlreadyUsed
    case passwordWeak
    case serverError
}
