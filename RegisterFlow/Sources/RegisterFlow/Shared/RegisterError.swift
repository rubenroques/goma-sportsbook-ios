//
//  RegisterError.swift
//
//
//  Created by André Lascas on 08/01/2024.
//

import Foundation

public struct RegisterError {

    public var field: String
    public var error: String

    public var associatedFormStep: FormStep? {
        switch field {
        case "gender": return .gender
        case "firstName", "lastName", "fullName": return .names
        case "username": return .nickname
        case "password": return .password
        case "email", "mobile": return .contacts
        case "birthDate", "nationality", "country": return .ageCountry
        case "city", "address", "province": return .address
        case "phoneConfirmation": return .phoneConfirmation
        case "bonusCode": return .promoCodes
        case "receiveEmail": return .terms
        case "personalInfo": return .personalInfo
        default:
            return nil
        }
    }
    
}
