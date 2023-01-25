//
//  UserRegisterEnvelop.swift
//  
//
//  Created by Ruben Roques on 24/01/2023.
//

import Foundation
import SharedModels

public final class UserRegisterEnvelop: Codable {

    public enum Gender: String, Codable {
        case male = "M"
        case female = "F"
    }

    public var gender: Gender?

    public var name: String?
    public var surname: String?

    public var avatarName: String?
    public var nickname: String?

    public var dateOfBirth: Date?
    public var countryBirth: Country?
    public var placeBirth: String?

    public var placeAddress: String?
    public var streetAddress: String?
    public var additionalStreetAddress: String?

    public var email: String?
    public var phonePrefixCountry: Country?
    public var phoneNumber: String?

    public var password: String?

    public var acceptedMarketing: Bool
    public var acceptedTerms: Bool

    public var promoCode: String?
    public var godfatherCode: String?

    public init(gender: Gender? = nil,
                name: String? = nil,
                surname: String? = nil,
                avatarName: String? = nil,
                nickname: String? = nil,
                dateOfBirth: Date? = nil,
                countryBirth: Country? = nil,
                placeBirth: String? = nil,
                placeAddress: String? = nil,
                streetAddress: String? = nil,
                additionalStreetAddress: String? = nil,
                email: String? = nil,
                phonePrefixCountry: Country? = nil,
                phoneNumber: String? = nil,
                password: String? = nil,
                acceptedMarketing: Bool = false,
                acceptedTerms: Bool = false,
                promoCode: String? = nil,
                godfatherCode: String? = nil) {

        self.gender = gender
        self.name = name
        self.surname = surname
        self.avatarName = avatarName
        self.nickname = nickname
        self.dateOfBirth = dateOfBirth
        self.countryBirth = countryBirth
        self.placeBirth = placeBirth
        self.placeAddress = placeAddress
        self.streetAddress = streetAddress
        self.additionalStreetAddress = additionalStreetAddress
        self.email = email
        self.phonePrefixCountry = phonePrefixCountry
        self.phoneNumber = phoneNumber
        self.password = password
        self.acceptedMarketing = acceptedMarketing
        self.acceptedTerms = acceptedTerms
        self.promoCode = promoCode
        self.godfatherCode = godfatherCode
    }

    func currentRegisterStep() -> Int {
        if self.gender == nil || self.name == nil || self.surname == nil {
            return 0
        }
        if self.avatarName == nil || self.nickname == nil {
            return 1
        }
        if self.dateOfBirth == nil || self.countryBirth == nil || self.placeBirth == nil {
            return 2
        }
        if self.placeAddress == nil || self.streetAddress == nil {
            return 3
        }
        if self.email == nil || self.phonePrefixCountry == nil || self.phoneNumber == nil {
            return 4
        }
        if self.password == nil {
            return 5
        }
        if !self.acceptedTerms {
            return 6
        }
        return 7
    }

}
