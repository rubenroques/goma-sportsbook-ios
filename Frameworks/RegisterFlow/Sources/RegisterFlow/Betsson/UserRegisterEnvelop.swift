//
//  UserRegisterEnvelop.swift
//  
//
//  Created by Ruben Roques on 24/01/2023.
//

import Foundation
import ServicesProvider
import SharedModels

public struct UserRegisterEnvelop: Codable, Equatable {
    
    public enum Gender: String, Codable, Equatable {
        case male = "M"
        case female = "F"
    }
    
    public var gender: Gender?
    
    public var name: String?
    public var surname: String?
    public var middleName: String?
    public var fullName: String?
    
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
    public var verifiedPhoneNumber: String?
    
    public var password: String?
    
    public var acceptedMarketing: Bool
    public var acceptedTerms: Bool
    
    public var promoCode: String?
    public var godfatherCode: String?
    
    public var simpleRegistered: Bool
    public var confirmationCode: String?
    
    public var mobileVerificationRequestId: String?
    
    enum CodingKeys: String, CodingKey {
        case gender
        case name
        case surname
        case middleName
        case avatarName
        case nickname
        case dateOfBirth
        case countryBirth
        case deparmentOfBirth
        case placeBirth
        case placeAddress
        case postcode
        case streetAddress
        case streetNumber
        case email
        case phonePrefixCountry
        case phoneNumber
        case verifiedPhoneNumber
        case password
        case acceptedMarketing
        case acceptedTerms
        case promoCode
        case godfatherCode
        case simpleRegistered
        case confirmationCode
        case mobileVerificationRequestId
    }
    
    public init(gender: Gender? = nil,
                name: String? = nil,
                surname: String? = nil,
                middleName: String? = nil,
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
                verifiedPhoneNumber: String? = nil,
                password: String? = nil,
                acceptedMarketing: Bool = false,
                acceptedTerms: Bool = false,
                promoCode: String? = nil,
                godfatherCode: String? = nil,
                simpleRegistered: Bool = false,
                confirmationCode: String? = nil,
                mobileVerificationRequestId: String? = nil
    ) {
        
        self.gender = gender
        self.name = name
        self.surname = surname
        self.middleName = middleName
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
        self.verifiedPhoneNumber = verifiedPhoneNumber
        self.password = password
        self.acceptedMarketing = acceptedMarketing
        self.acceptedTerms = acceptedTerms
        self.promoCode = promoCode
        self.godfatherCode = godfatherCode
        self.simpleRegistered = simpleRegistered
        self.confirmationCode = confirmationCode
        self.mobileVerificationRequestId = mobileVerificationRequestId
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.gender = try container.decodeIfPresent(UserRegisterEnvelop.Gender.self, forKey: .gender)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.surname = try container.decodeIfPresent(String.self, forKey: .surname)
        self.middleName = try container.decodeIfPresent(String.self, forKey: .middleName)
        self.avatarName = try container.decodeIfPresent(String.self, forKey: .avatarName)
        self.nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
        self.dateOfBirth = try container.decodeIfPresent(Date.self, forKey: .dateOfBirth)
        self.countryBirth = try container.decodeIfPresent(Country.self, forKey: .countryBirth)
        self.deparmentOfBirth = try container.decodeIfPresent(String.self, forKey: .deparmentOfBirth)
        self.placeBirth = try container.decodeIfPresent(String.self, forKey: .placeBirth)
        self.placeAddress = try container.decodeIfPresent(String.self, forKey: .placeAddress)
        self.postcode = try container.decodeIfPresent(String.self, forKey: .postcode)
        self.streetAddress = try container.decodeIfPresent(String.self, forKey: .streetAddress)
        self.streetNumber = try container.decodeIfPresent(String.self, forKey: .streetNumber)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.phonePrefixCountry = try container.decodeIfPresent(Country.self, forKey: .phonePrefixCountry)
        self.phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        self.verifiedPhoneNumber = try? container.decodeIfPresent(String.self, forKey: .verifiedPhoneNumber)
        self.password = try container.decodeIfPresent(String.self, forKey: .password)
        self.acceptedMarketing = try container.decode(Bool.self, forKey: .acceptedMarketing)
        self.acceptedTerms = try container.decode(Bool.self, forKey: .acceptedTerms)
        self.promoCode = try container.decodeIfPresent(String.self, forKey: .promoCode)
        self.godfatherCode = try? container.decodeIfPresent(String.self, forKey: .godfatherCode)
        self.simpleRegistered = try container.decode(Bool.self, forKey: .simpleRegistered)
        self.confirmationCode = try container.decodeIfPresent(String.self, forKey: .confirmationCode)
        self.mobileVerificationRequestId = try? container.decodeIfPresent(String.self, forKey: .mobileVerificationRequestId)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.gender, forKey: .gender)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.surname, forKey: .surname)
        try container.encodeIfPresent(self.middleName, forKey: .middleName)
        try container.encodeIfPresent(self.avatarName, forKey: .avatarName)
        try container.encodeIfPresent(self.nickname, forKey: .nickname)
        try container.encodeIfPresent(self.dateOfBirth, forKey: .dateOfBirth)
        try container.encodeIfPresent(self.countryBirth, forKey: .countryBirth)
        try container.encodeIfPresent(self.deparmentOfBirth, forKey: .deparmentOfBirth)
        try container.encodeIfPresent(self.placeBirth, forKey: .placeBirth)
        try container.encodeIfPresent(self.placeAddress, forKey: .placeAddress)
        try container.encodeIfPresent(self.postcode, forKey: .postcode)
        try container.encodeIfPresent(self.streetAddress, forKey: .streetAddress)
        try container.encodeIfPresent(self.streetNumber, forKey: .streetNumber)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.phonePrefixCountry, forKey: .phonePrefixCountry)
        try container.encodeIfPresent(self.phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(self.verifiedPhoneNumber, forKey: .verifiedPhoneNumber)
        try container.encodeIfPresent(self.password, forKey: .password)
        try container.encode(self.acceptedMarketing, forKey: .acceptedMarketing)
        try container.encode(self.acceptedTerms, forKey: .acceptedTerms)
        try container.encodeIfPresent(self.promoCode, forKey: .promoCode)
        try container.encodeIfPresent(self.godfatherCode, forKey: .godfatherCode)
        try container.encode(self.simpleRegistered, forKey: .simpleRegistered)
        try container.encodeIfPresent(self.confirmationCode, forKey: .confirmationCode)
        try container.encodeIfPresent(self.mobileVerificationRequestId, forKey: .mobileVerificationRequestId)
    }
    
    public static func == (lhs: UserRegisterEnvelop, rhs: UserRegisterEnvelop) -> Bool {
        return lhs.gender == rhs.gender &&
        lhs.name == rhs.name &&
        lhs.surname == rhs.surname &&
        lhs.middleName == rhs.middleName &&
        lhs.avatarName == rhs.avatarName &&
        lhs.nickname == rhs.nickname &&
        lhs.dateOfBirth == rhs.dateOfBirth &&
        lhs.countryBirth == rhs.countryBirth &&
        lhs.deparmentOfBirth == rhs.deparmentOfBirth &&
        lhs.placeBirth == rhs.placeBirth &&
        lhs.placeAddress == rhs.placeAddress &&
        lhs.postcode == rhs.postcode &&
        lhs.streetAddress == rhs.streetAddress &&
        lhs.streetNumber == rhs.streetNumber &&
        lhs.email == rhs.email &&
        lhs.phonePrefixCountry == rhs.phonePrefixCountry &&
        lhs.phoneNumber == rhs.phoneNumber &&
        lhs.verifiedPhoneNumber == rhs.verifiedPhoneNumber &&
        lhs.password == rhs.password &&
        lhs.acceptedMarketing == rhs.acceptedMarketing &&
        lhs.acceptedTerms == rhs.acceptedTerms &&
        lhs.promoCode == rhs.promoCode &&
        lhs.godfatherCode == rhs.godfatherCode &&
        lhs.simpleRegistered == rhs.simpleRegistered &&
        lhs.confirmationCode == rhs.confirmationCode &&
        lhs.mobileVerificationRequestId == rhs.mobileVerificationRequestId &&
        lhs.fullName == rhs.fullName
    }
    
    func currentRegisterStep(registerFlowType: RegisterFlow.FlowType) -> Int {
        
        switch registerFlowType {
        case .goma:
            if self.fullName.isEmptyOrNil ||
                self.email.isEmptyOrNil ||
                self.nickname.isEmptyOrNil {
                return 0
            }
            if self.avatarName == nil {
                return 1
            }
            return 2
        case .betson:
            if self.gender == nil || self.name.isEmptyOrNil || self.surname.isEmptyOrNil || self.middleName.isEmptyOrNil {
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
    
}

extension UserRegisterEnvelop: CustomStringConvertible {
    public var description: String {
        return """
        UserRegisterEnvelop(
            gender: \(String(describing: gender)),
            name: \(String(describing: name)),
            surname: \(String(describing: surname)),
            middleName: \(String(describing: middleName)),
            avatarName: \(String(describing: avatarName)),
            nickname: \(String(describing: nickname)),
            dateOfBirth: \(String(describing: dateOfBirth)),
            countryBirth: \(String(describing: countryBirth)),
            deparmentOfBirth: \(String(describing: deparmentOfBirth)),
            placeBirth: \(String(describing: placeBirth)),
            placeAddress: \(String(describing: placeAddress)),
            postcode: \(String(describing: postcode)),
            streetAddress: \(String(describing: streetAddress)),
            streetNumber: \(String(describing: streetNumber)),
            email: \(String(describing: email)),
            phonePrefixCountry: \(String(describing: phonePrefixCountry)),
            phoneNumber: \(String(describing: phoneNumber)),
            verifiedPhoneNumber: \(String(describing: verifiedPhoneNumber)),
            password: \(String(describing: password)),
            acceptedMarketing: \(acceptedMarketing),
            acceptedTerms: \(acceptedTerms),
            promoCode: \(String(describing: promoCode)),
            godfatherCode: \(String(describing: godfatherCode)),
            simpleRegistered: \(simpleRegistered),
            confirmationCode: \(String(describing: confirmationCode)),
            mobileVerificationRequestId: \(String(describing: mobileVerificationRequestId)),
            fullName: \(String(describing: fullName))
        )
        """
    }
}


public extension UserRegisterEnvelop {
    static var debug: UserRegisterEnvelop {
        return UserRegisterEnvelop(gender: Gender.male,
                                   name: "Ruben",
                                   surname: "Roques",
                                   middleName: "Nome",
                                   avatarName: "avatar3",
                                   nickname: "rroques",
                                   dateOfBirth: Date.init(timeIntervalSince1970: 824848591),
                                   countryBirth: Country.country(withISOCode: "FR"),
                                   deparmentOfBirth: "2A",
                                   placeBirth: "Paris",
                                   placeAddress: "place name",
                                   postcode: "83727",
                                   streetAddress: "Long street",
                                   streetNumber: "1",
                                   email: "rroques@gomadevelopment.pt",
                                   phonePrefixCountry: Country.country(withISOCode: "FR"),
                                   phoneNumber: "967847034",
                                   verifiedPhoneNumber: "1234",
                                   password: nil,
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
        
        // We need to ignore the 0 on register and phone verification
        var formattedPhoneNumber = mobileNumber
        while formattedPhoneNumber.hasPrefix("0") {
            formattedPhoneNumber.removeFirst()
        }
        
        let middleName = self.middleName
        
        return ServicesProvider.SignUpForm.init(email: email,
                                                username: username,
                                                password: password,
                                                birthDate: birthDate,
                                                mobilePrefix: mobilePrefix,
                                                mobileNumber: formattedPhoneNumber,
                                                nationalityIsoCode: countryBirthIsoCode,
                                                currencyCode: "EUR",
                                                firstName: firstName,
                                                lastName: lastName,
                                                middleName: middleName,
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
                                                birthCity: birthCityName,
                                                mobileVerificationRequestId: self.mobileVerificationRequestId,
                                                consentedIds: [],
                                                unConsentedIds: [])
    }
    
}
