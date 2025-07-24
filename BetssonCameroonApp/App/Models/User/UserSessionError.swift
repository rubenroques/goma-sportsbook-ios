//
//  UserSessionError.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 22/07/2025.
//

import Foundation

enum UserSessionError: Error {
    case invalidEmailPassword
    case restrictedCountry
    case serverError
    case quickSignUpIncomplete
    case errorMessage(errorMessage: String)
    case failedTempLock(date: String)
}
