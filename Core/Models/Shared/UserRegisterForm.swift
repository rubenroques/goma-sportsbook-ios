//
//  UserRegisterForm.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/09/2021.
//

import Foundation

struct UserRegisterForm {
    let username: String
    let email: String
    let mobile: String
    let birthDate: String
    let userProviderId: String
}

enum EveryMatrix {

    struct SimpleRegisterForm {
        let email: String
        let username: String
        let password: String
        let birthDate: String
        let mobilePrefix: String
        let mobileNumber: String
        let emailVerificationURL: String
    }

    struct CompleteRegisterForm {

    }

    struct EmailAvailability: Decodable {

        let email: String
        let isAvailable: Bool
        let errorMessage: String?

        enum CodingKeys: String, CodingKey {
            case email = "email"
            case isAvailable = "isAvailable"
            case errorMessage = "error"
        }
    }

    struct UsernameAvailability: Decodable {
        let username: String
        let isAvailable: Bool
        let errorMessage: String?

        enum CodingKeys: String, CodingKey {
            case username = "username"
            case isAvailable = "isAvailable"
            case errorMessage = "error"
        }
    }

    struct RegistrationResponse: Codable {
        let username: String?
        let email: String?
        let anonymousRegistration: Bool?

        enum CodingKeys: String, CodingKey {
            case username = "username"
            case email = "email"
            case anonymousRegistration = "anonymousRegistration"
        }
    }

    struct CountryListing: Decodable {
        var countries: [Country]
        var currentIpCountry: String

        enum CodingKeys: String, CodingKey {
            case countries = "countries"
            case currentIpCountry = "currentIPCountry"
        }
    }

    struct Country: Decodable {
        var isoCode: String?
        var name: String
        var phonePrefix: String
        var currency: String

        enum CodingKeys: String, CodingKey {
        case isoCode = "code"
        case name = "name"
        case phonePrefix = "phonePrefix"
        case currency = "currency"
        }
    }

}
