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
                    var formattedPhoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
                    while formattedPhoneNumber.hasPrefix("0") {
                        formattedPhoneNumber.removeFirst()
                    }
                    let fullPhoneNumber = "\(prefix)\(formattedPhoneNumber)"
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
    
    public func getUserRegisterEnvelop() -> UserRegisterEnvelop {
        return self.userRegisterEnvelop
    }

    public func setGender(_ gender: UserRegisterEnvelop.Gender) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.gender = gender
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }
    
    public func setName(_ name: String?) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.name = name
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setSurname(_ surname: String?) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.surname = surname
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }
    
    public func setMiddleName(_ middleName: String?) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.middleName = middleName
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setAvatarName(_ avatarName: String) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.avatarName = avatarName
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setNickname(_ nickname: String?) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.nickname = nickname
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setDateOfBirth(_ dateOfBirth: Date) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.dateOfBirth = dateOfBirth
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setCountryBirth(_ countryBirth: SharedModels.Country) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.countryBirth = countryBirth
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setDepartmentOfBirth(_ deparmentOfBirth: String?) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.deparmentOfBirth = deparmentOfBirth
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setPlaceBirth(_ placeBirth: String?) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.placeBirth = placeBirth
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setPlaceAddress(_ placeAddress: String?) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.placeAddress = placeAddress
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setPostcode(_ postcode: String?) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.postcode = postcode
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setStreetAddress(_ streetAddress: String?) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.streetAddress = streetAddress
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setStreetNumber(_ streetNumber: String?) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.streetNumber = streetNumber
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setEmail(_ email: String?) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.email = email
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setPhonePrefixCountry(_ phonePrefixCountry: SharedModels.Country) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.phonePrefixCountry = phonePrefixCountry
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setPhoneNumber(_ phoneNumber: String) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.phoneNumber = phoneNumber
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setVerifiedPhoneNumber(_ verifiedPhoneNumber: String?) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.verifiedPhoneNumber = verifiedPhoneNumber
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setPassword(_ password: String?) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.password = password
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setAcceptedMarketing(_ acceptedMarketing: Bool) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.acceptedMarketing = acceptedMarketing
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setAcceptedTerms(_ acceptedTerms: Bool) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.acceptedTerms = acceptedTerms
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setPromoCode(_ promoCode: String) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.promoCode = promoCode
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setGodfatherCode(_ godfatherCode: String) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.godfatherCode = godfatherCode
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setSimpleRegistered(_ registered: Bool) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.simpleRegistered = registered
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

    public func setConfirmationCode(_ code: String?) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.confirmationCode = code
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }
    
    public func setMobileVerificationRequestId(_ requestId: String?) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.mobileVerificationRequestId = requestId
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }
    
}

extension UserRegisterEnvelopUpdater {
    
    public func setFullName(_ name: String?) {
        var newUserEnvelop = self.userRegisterEnvelop
        newUserEnvelop.fullName = name
        self.filledDataUpdated.send(newUserEnvelop)
        self.userRegisterEnvelop = newUserEnvelop
    }

}
