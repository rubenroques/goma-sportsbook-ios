//
//  EmailState.swift
//
//
//  Created by André Lascas on 09/01/2024.
//

import Foundation

enum EmailState {
    case empty
    case needsValidation
    case validating
    case serverError
    case alreadyInUse
    case invalidSyntax
    case valid
}
