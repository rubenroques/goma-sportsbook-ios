//
//  UserRegisterEnvelopUpdater.swift
//  
//
//  Created by Ruben Roques on 24/01/2023.
//

import Foundation
import SharedModels

public class UserRegisterEnvelopUpdater {

    public var filledDataUpdated: (UserRegisterEnvelop) -> (Void) = { _ in }
    private var userRegisterEnvelop: UserRegisterEnvelop

    public init(userRegisterEnvelop: UserRegisterEnvelop) {
        self.userRegisterEnvelop = userRegisterEnvelop
    }

    func setGender(_ gender: UserRegisterEnvelop.Gender) {
        self.userRegisterEnvelop.gender = gender
        self.filledDataUpdated(self.userRegisterEnvelop)
    }
    
    func setName(_ name: String) {
        self.userRegisterEnvelop.name = name
        self.filledDataUpdated(self.userRegisterEnvelop)
    }

    func setSurname(_ surname: String) {
        self.userRegisterEnvelop.surname = surname
        self.filledDataUpdated(self.userRegisterEnvelop)
    }

    func setAvatarName(_ avatarName: String) {
        self.userRegisterEnvelop.avatarName = avatarName
        self.filledDataUpdated(self.userRegisterEnvelop)
    }

    func setNickname(_ nickname: String) {
        self.userRegisterEnvelop.nickname = nickname
        self.filledDataUpdated(self.userRegisterEnvelop)
    }

    func setDateOfBirth(_ dateOfBirth: Date) {
        self.userRegisterEnvelop.dateOfBirth = dateOfBirth
        self.filledDataUpdated(self.userRegisterEnvelop)
    }

    func setCountryBirth(_ countryBirth: SharedModels.Country) {
        self.userRegisterEnvelop.countryBirth = countryBirth
        self.filledDataUpdated(self.userRegisterEnvelop)
    }

    func setPlaceBirth(_ placeBirth: String) {
        self.userRegisterEnvelop.placeBirth = placeBirth
        self.filledDataUpdated(self.userRegisterEnvelop)
    }

    func setPlaceAddress(_ placeAddress: String) {
        self.userRegisterEnvelop.placeAddress = placeAddress
        self.filledDataUpdated(self.userRegisterEnvelop)
    }

    func setStreetAddress(_ streetAddress: String) {
        self.userRegisterEnvelop.streetAddress = streetAddress
        self.filledDataUpdated(self.userRegisterEnvelop)
    }

    func setAdditionalStreetAddress(_ additionalStreetAddress: String) {
        self.userRegisterEnvelop.additionalStreetAddress = additionalStreetAddress
        self.filledDataUpdated(self.userRegisterEnvelop)
    }

    func setEmail(_ email: String) {
        self.userRegisterEnvelop.email = email
        self.filledDataUpdated(self.userRegisterEnvelop)
    }

    func setPhonePrefixCountry(_ phonePrefixCountry: SharedModels.Country) {
        self.userRegisterEnvelop.phonePrefixCountry = phonePrefixCountry
        self.filledDataUpdated(self.userRegisterEnvelop)
    }

    func setPhoneNumber(_ phoneNumber: String) {
        self.userRegisterEnvelop.phoneNumber = phoneNumber
        self.filledDataUpdated(self.userRegisterEnvelop)
    }

    func setPassword(_ password: String) {
        self.userRegisterEnvelop.password = password
        self.filledDataUpdated(self.userRegisterEnvelop)
    }

    func setAcceptedMarketing(_ acceptedMarketing: Bool) {
        self.userRegisterEnvelop.acceptedMarketing = acceptedMarketing
        self.filledDataUpdated(self.userRegisterEnvelop)
    }

    func setAcceptedTerms(_ acceptedTerms: Bool) {
        self.userRegisterEnvelop.acceptedTerms = acceptedTerms
        self.filledDataUpdated(self.userRegisterEnvelop)
    }

    func setPromoCode(_ promoCode: String) {
        self.userRegisterEnvelop.promoCode = promoCode
        self.filledDataUpdated(self.userRegisterEnvelop)
    }

    func setGodfatherCode(_ godfatherCode: String) {
        self.userRegisterEnvelop.godfatherCode = godfatherCode
        self.filledDataUpdated(self.userRegisterEnvelop)
    }


}
