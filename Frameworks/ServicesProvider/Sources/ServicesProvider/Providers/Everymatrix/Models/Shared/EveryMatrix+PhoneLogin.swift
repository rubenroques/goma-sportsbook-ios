//
//  EveryMatrix+PhoneLogin.swift
//  ServicesProvider
//
//  Created by André Lascas on 16/07/2025.
//

import Foundation

extension EveryMatrix {
    
    struct PhoneLoginResponse: Codable {
        let sessionId: String
        let id: String
        let userId: String
        let sessionBlockers: [String]
        let hasToAcceptTC: Bool
        let hasToSetPass: Bool
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<EveryMatrix.PhoneLoginResponse.CodingKeys> = try decoder.container(keyedBy: EveryMatrix.PhoneLoginResponse.CodingKeys.self)
            self.sessionId = try container.decode(String.self, forKey: EveryMatrix.PhoneLoginResponse.CodingKeys.sessionId)
            self.id = try container.decode(String.self, forKey: EveryMatrix.PhoneLoginResponse.CodingKeys.id)
            
            if let userIdInt: Int = try? container.decode(Int.self, forKey: EveryMatrix.PhoneLoginResponse.CodingKeys.userId) {
                self.userId = "\(userIdInt)"
            }
            else {
                self.userId = try container.decode(String.self, forKey: EveryMatrix.PhoneLoginResponse.CodingKeys.userId)
            }
            
            self.sessionBlockers = try container.decode([String].self, forKey: EveryMatrix.PhoneLoginResponse.CodingKeys.sessionBlockers)
            self.hasToAcceptTC = try container.decode(Bool.self, forKey: EveryMatrix.PhoneLoginResponse.CodingKeys.hasToAcceptTC)
            self.hasToSetPass = try container.decode(Bool.self, forKey: EveryMatrix.PhoneLoginResponse.CodingKeys.hasToSetPass)
        }
    }
    
    struct PlayerProfile: Codable {
        let id: Int
        let userName: String
        let gender: String
        let countryName: String
        let countryCode: String
        let userActiveStatus: String
        let mobilePrefixCountryName: String
        let phonePrefixCountryName: String
        let type: String
        let displayName: String
        let activeStatus: String
        let address3: String
        let zip: String
        let state: String
        let signupIP: String
        let isEmailVerified: Bool
        let currency: String
        let lastLogin: String
        let preferredCurrency: String
        let secondFactorType: String
        let domainID: Int
        let firstName: String
        let lastName: String
        let birthDate: String
        let email: String
        let title: String
        let address1: String
        let address2: String
        let city: String
        let countryId: Int
        let stateId: Int
        let mobilePhonePrefix: String
        let mobilePhone: String
        let phonePrefix: String
        let phone: String
        let affiliateMarker: String
        let securityQuestion: String
        let securityAnswer: String
        let language: String
        let allowNewsEmail: Bool
        let alias: String
        let companyName: String
        let companyRegNo: String
        let taxCode: String
        let allowSmsOffer: Bool
        let personalId: String
        let nationality: String
        let birthName: String
        let birthPlace: String
        let birthCountryId: Int
        let registrationTime: String
        let preLoginDate: String
        let iban: String
    }
}
