//
//  UserRegisterEnvelop.swift
//  
//
//  Created by Ruben Roques on 24/01/2023.
//

import Foundation
import ServicesProvider
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
    public var deparmentOfBirth: String?
    public var placeBirth: String?

    public var placeAddress: String?
    public var postcode: String?
    public var streetAddress: String?
    public var streetNumber: String?

    public var email: String?
    public var phonePrefixCountry: Country?
    public var phoneNumber: String?

    public var password: String?

    public var acceptedMarketing: Bool
    public var acceptedTerms: Bool

    public var promoCode: String?
    public var godfatherCode: String?

    public var simpleRegistered: Bool
    public var confirmationCode: String?

    public init(gender: Gender? = nil,
                name: String? = nil,
                surname: String? = nil,
                avatarName: String? = nil,
                nickname: String? = nil,
                dateOfBirth: Date? = nil,
                countryBirth: Country? = nil,
                deparmentOfBirth: String? = nil,
                placeBirth: String? = nil,
                placeAddress: String? = nil,
                postcode: String? = nil,
                streetAddress: String? = nil,
                streetNumber: String? = nil,
                email: String? = nil,
                phonePrefixCountry: Country? = nil,
                phoneNumber: String? = nil,
                password: String? = nil,
                acceptedMarketing: Bool = false,
                acceptedTerms: Bool = false,
                promoCode: String? = nil,
                godfatherCode: String? = nil,
                simpleRegistered: Bool = false,
                confirmationCode: String? = nil
    ) {

        self.gender = gender
        self.name = name
        self.surname = surname
        self.avatarName = avatarName
        self.nickname = nickname
        self.dateOfBirth = dateOfBirth
        self.countryBirth = countryBirth
        self.deparmentOfBirth = deparmentOfBirth
        self.placeBirth = placeBirth
        self.placeAddress = placeAddress
        self.postcode = postcode
        self.streetAddress = streetAddress
        self.streetNumber = streetNumber
        self.email = email
        self.phonePrefixCountry = phonePrefixCountry
        self.phoneNumber = phoneNumber
        self.password = password
        self.acceptedMarketing = acceptedMarketing
        self.acceptedTerms = acceptedTerms
        self.promoCode = promoCode
        self.godfatherCode = godfatherCode
        self.simpleRegistered = simpleRegistered
        self.confirmationCode = confirmationCode
    }

    func currentRegisterStep() -> Int {
        
        if self.gender == nil || self.name.isEmptyOrNil || self.surname.isEmptyOrNil {
            return 0
        }
        if self.avatarName == nil || self.nickname.isEmptyOrNil {
            return 1
        }
        if self.dateOfBirth == nil || self.countryBirth == nil || self.deparmentOfBirth.isEmptyOrNil || self.placeBirth.isEmptyOrNil {
            return 2
        }
        if self.placeAddress.isEmptyOrNil || self.postcode.isEmptyOrNil || self.streetAddress.isEmptyOrNil || self.streetNumber.isEmptyOrNil {
            return 3
        }
        if self.email.isEmptyOrNil || self.phonePrefixCountry == nil || self.phoneNumber.isEmptyOrNil {
            return 4
        }

        return 5
    }

}

public extension UserRegisterEnvelop {
    static var debug: UserRegisterEnvelop {
        return UserRegisterEnvelop(gender: Gender.male,
                                   name: "Ruben",
                                   surname: "Roques",
                                   avatarName: "avatar3",
                                   nickname: "rroques7",
                                   dateOfBirth: Date.init(timeIntervalSince1970: 824848591),
                                   countryBirth: Country.country(withISOCode: "FR"),
                                   deparmentOfBirth: "2A",
                                   placeBirth: "Paris",
                                   placeAddress: "place name",
                                   postcode: "83727",
                                   streetAddress: "Long street",
                                   streetNumber: "1",
                                   email: "habee12bi3740@breazeim.com",
                                   phonePrefixCountry: Country.country(withISOCode: "FR"),
                                   phoneNumber: "918437482",
                                   password: "Ruben12345!",
                                   acceptedMarketing: false,
                                   acceptedTerms: false,
                                   promoCode: nil,
                                   godfatherCode: nil,
                                   simpleRegistered: false,
                                   confirmationCode: nil)
    }
}

public extension UserRegisterEnvelop {

    func convertToSignUpForm() -> ServicesProvider.SignUpForm? {

        guard
            let email = self.email,
            let username = self.nickname,
            let password = self.password,
            let mobilePrefix = self.phonePrefixCountry?.phonePrefix,
            let mobileNumber = self.phoneNumber,
            let countryBirthIsoCode = self.countryBirth?.iso2Code,
            let firstName = self.name,
            let lastName = self.surname,
            let gender = self.gender,
            let streetAddress = self.streetAddress,
            let birthDate = self.dateOfBirth,
            let placeAddress = self.placeAddress,
            let postcode = self.postcode,
            let deparmentOfBirth = self.deparmentOfBirth,
            let streetNumber = self.streetNumber,
            let birthCityName = self.placeBirth
        else {
            return nil
        }

        var genderString = ""
        switch gender {
        case .male:
            genderString = "M"
        case .female:
            genderString = "F"
        }

        return ServicesProvider.SignUpForm.init(email: email,
                                                username: username,
                                                password: password,
                                                birthDate: birthDate,
                                                mobilePrefix: mobilePrefix,
                                                mobileNumber: mobileNumber,
                                                nationalityIsoCode: countryBirthIsoCode,
                                                currencyCode: "EUR",
                                                firstName: firstName,
                                                lastName: lastName,
                                                gender: genderString,
                                                address: streetAddress,
                                                city: placeAddress,
                                                countryIsoCode: "FR",
                                                bonusCode: self.promoCode,
                                                receiveMarketingEmails: self.acceptedMarketing,
                                                avatarName: self.avatarName,
                                                godfatherCode: self.godfatherCode,
                                                postCode: postcode,
                                                birthDepartment: deparmentOfBirth,
                                                streetNumber: streetNumber,
                                                birthCountry: countryBirthIsoCode,
                                                birthCity: birthCityName)
    }

}

private extension Optional where Wrapped == String {

    var isEmptyOrNil: Bool {
        return self?.isEmpty ?? true
    }

}
