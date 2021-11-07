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

extension EveryMatrix {

    struct SimpleRegisterForm {
        let email: String
        let username: String
        let password: String
        let birthDate: String
        let mobilePrefix: String
        let mobileNumber: String
        let emailVerificationURL: String
    }

    struct BetslipTicketSelection: Decodable {

        var id: String
        var currentOdd: Double

        init(id: String, currentOdd: Double) {
            self.id = id
            self.currentOdd = currentOdd
        }
        enum CodingKeys: String, CodingKey {
            case id = "bettingOfferId"
            case currentOdd = "priceValue"
        }
    }

    enum BetslipSubmitionType {
        case single
        case multiple

        var typeKeyword: String {
            switch self {
            case .single:
                return "SINGLE"
            case .multiple:
                return "MULTIPLE"
            }
        }
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
        var legalAge: Int

        enum CodingKeys: String, CodingKey {
        case isoCode = "code"
        case name = "name"
        case phonePrefix = "phonePrefix"
        case currency = "currency"
        case legalAge = "legalAge"
        }
    }

    struct UserProfileField: Decodable {
        var fields: UserProfile
        var isFirstnameUpdatable: Bool
        var isSurnameUpdatable: Bool
        var isBirthDateUpdatable: Bool
        var isCountryUpdatable: Bool
        var isCurrencyUpdatable: Bool
        var isEmailUpdatable: Bool
        var isProfileUpdatable: Bool

        enum CodingKeys: String, CodingKey {
            case fields = "fields"
            case isFirstnameUpdatable = "isFirstnameUpdatable"
            case isSurnameUpdatable = "isSurnameUpdatable"
            case isBirthDateUpdatable = "isBirthDateUpdatable"
            case isCountryUpdatable = "isCountryUpdatable"
            case isCurrencyUpdatable = "isCurrencyUpdatable"
            case isEmailUpdatable = "isEmailUpdatable"
            case isProfileUpdatable = "isProfileUpdatable"
        }
    }

    struct UserProfile: Decodable {
        var username: String
        var email: String
        var title: String
        var firstname: String
        var surname: String
        var birthDate: String
        var country: String
        var address1: String
        var address2: String
        var city: String
        var postalCode: String
        var mobile: String
        var mobilePrefix: String
        var phone: String
        var phonePrefix: String
        var personalID: String

        enum CodingKeys: String, CodingKey {
            case username = "username"
            case email = "email"
            case title = "title"
            case firstname = "firstname"
            case surname = "surname"
            case birthDate = "birthDate"
            case country = "country"
            case address1 = "address1"
            case address2 = "address2"
            case city = "city"
            case postalCode = "postalCode"
            case mobile = "mobile"
            case mobilePrefix = "mobilePrefix"
            case phone = "phone"
            case phonePrefix = "phonePrefix"
            case personalID = "personalID"
        }
    }

    struct ProfileForm {
        var email: String
        var title: String
        var gender: String
        var firstname: String
        var surname: String
        var birthDate: String
        var country: String
        var address1: String
        var address2: String
        var city: String
        var postalCode: String
        var mobile: String
        var mobilePrefix: String
        var phone: String
        var phonePrefix: String
        var personalID: String
    }

    struct ProfileUpdateResponse: Codable {

    }

    struct PasswordPolicy: Decodable {
        var regularExpression: String
        var message: String

        enum CodingKeys: String, CodingKey {
            case regularExpression = "regularExpression"
            case message = "message"
        }
    }

    struct PasswordChange: Decodable {
        var isCaptchaEnabled: Bool

        enum CodingKeys: String, CodingKey {
            case isCaptchaEnabled = "isCaptchaEnabled"
        }
    }

}
