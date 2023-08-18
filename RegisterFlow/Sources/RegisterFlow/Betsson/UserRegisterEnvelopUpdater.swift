//
//  UserRegisterEnvelopUpdater.swift
//  
//
//  Created by Ruben Roques on 24/01/2023.
//

import Foundation
import SharedModels
import Combine

public class UserRegisterEnvelopUpdater {

    public var didUpdateUserRegisterEnvelop: AnyPublisher<UserRegisterEnvelop, Never> {
        return self.filledDataUpdated.eraseToAnyPublisher()
    }

    public var generatedNickname: AnyPublisher<String, Never> {
        return self.filledDataUpdated
            .map { updatedUserRegisterEnvelop -> String? in
                let firstLetter = (updatedUserRegisterEnvelop.name ?? "").first
                let surname = updatedUserRegisterEnvelop.surname?.replacingOccurrences(of: " ", with: "")
                if let firstLetter, let surname {
                    let suggestion = "\(String(firstLetter))\(surname)"
                    return suggestion.lowercased()
                }
                return nil
            }
            .removeDuplicates()
            .compactMap({ $0 })
            .eraseToAnyPublisher()
    }

    public var fullPhoneNumberPublisher: AnyPublisher<String, Never> {
        return self.filledDataUpdated
            .map { updatedUserRegisterEnvelop -> String? in
                let prefix = updatedUserRegisterEnvelop.phonePrefixCountry?.phonePrefix
                let phoneNumber = updatedUserRegisterEnvelop.phoneNumber
                if let prefix, let phoneNumber, !prefix.isEmpty, !phoneNumber.isEmpty {
                    let fullPhoneNumber = "\(prefix)\(phoneNumber)"
                    return fullPhoneNumber.lowercased()
                }
                return nil
            }
            .compactMap({ $0 })
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public var isPhoneNumberVerified: Bool {
        if let phonePrefix = self.userRegisterEnvelop.phonePrefixCountry?.phonePrefix,
            let phoneNumber = self.userRegisterEnvelop.phoneNumber,
           let verifiedPhoneNumber = self.userRegisterEnvelop.verifiedPhoneNumber {
            return "\(phonePrefix)\(phoneNumber)" == verifiedPhoneNumber
        }
        return false
    }

    private var filledDataUpdated: CurrentValueSubject<UserRegisterEnvelop, Never>
    private var userRegisterEnvelop: UserRegisterEnvelop

    public init(userRegisterEnvelop: UserRegisterEnvelop) {
        self.userRegisterEnvelop = userRegisterEnvelop
        self.filledDataUpdated = .init(userRegisterEnvelop)
    }

    func setGender(_ gender: UserRegisterEnvelop.Gender) {
        self.userRegisterEnvelop.gender = gender
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }
    
    func setName(_ name: String?) {
        self.userRegisterEnvelop.name = name
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setSurname(_ surname: String?) {
        self.userRegisterEnvelop.surname = surname
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setAvatarName(_ avatarName: String) {
        self.userRegisterEnvelop.avatarName = avatarName
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setNickname(_ nickname: String?) {
        self.userRegisterEnvelop.nickname = nickname
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setDateOfBirth(_ dateOfBirth: Date) {
        self.userRegisterEnvelop.dateOfBirth = dateOfBirth
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setCountryBirth(_ countryBirth: SharedModels.Country) {
        self.userRegisterEnvelop.countryBirth = countryBirth
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setDepartmentOfBirth(_ deparmentOfBirth: String?) {
        self.userRegisterEnvelop.deparmentOfBirth = deparmentOfBirth
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setPlaceBirth(_ placeBirth: String?) {
        self.userRegisterEnvelop.placeBirth = placeBirth
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setPlaceAddress(_ placeAddress: String?) {
        self.userRegisterEnvelop.placeAddress = placeAddress
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setPostcode(_ postcode: String?) {
        self.userRegisterEnvelop.postcode = postcode
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setStreetAddress(_ streetAddress: String?) {
        self.userRegisterEnvelop.streetAddress = streetAddress
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setStreetNumber(_ streetNumber: String?) {
        self.userRegisterEnvelop.streetNumber = streetNumber
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setEmail(_ email: String?) {
        self.userRegisterEnvelop.email = email
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setPhonePrefixCountry(_ phonePrefixCountry: SharedModels.Country) {
        self.userRegisterEnvelop.phonePrefixCountry = phonePrefixCountry
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setPhoneNumber(_ phoneNumber: String) {
        self.userRegisterEnvelop.phoneNumber = phoneNumber
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setVerifiedPhoneNumber(_ verifiedPhoneNumber: String?) {
        self.userRegisterEnvelop.verifiedPhoneNumber = verifiedPhoneNumber
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setPassword(_ password: String?) {
        self.userRegisterEnvelop.password = password
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setAcceptedMarketing(_ acceptedMarketing: Bool) {
        self.userRegisterEnvelop.acceptedMarketing = acceptedMarketing
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setAcceptedTerms(_ acceptedTerms: Bool) {
        self.userRegisterEnvelop.acceptedTerms = acceptedTerms
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setPromoCode(_ promoCode: String) {
        self.userRegisterEnvelop.promoCode = promoCode
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setGodfatherCode(_ godfatherCode: String) {
        self.userRegisterEnvelop.godfatherCode = godfatherCode
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setSimpleRegistered(_ registered: Bool) {
        self.userRegisterEnvelop.simpleRegistered = registered
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

    func setConfirmationCode(_ code: String?) {
        self.userRegisterEnvelop.confirmationCode = code
        self.filledDataUpdated.send(self.userRegisterEnvelop)
    }

}
