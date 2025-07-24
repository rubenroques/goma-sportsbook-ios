//
//  ServiceProviderModelMapper+Profile.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 22/07/2025.
//

import Foundation
import ServicesProvider

extension ServiceProviderModelMapper {
    
    static func userProfile(_ serviceProviderProfile: ServicesProvider.UserProfile) -> UserProfile {
        var nationalityCountry: Country?
        if let serviceProviderCountry = serviceProviderProfile.nationalityCountry {
            nationalityCountry = ServiceProviderModelMapper.country(fromServiceProviderCountry: serviceProviderCountry)
        }
        
        var country: Country?
        if let serviceProviderCountry = serviceProviderProfile.country {
            country = ServiceProviderModelMapper.country(fromServiceProviderCountry: serviceProviderCountry)
        }

        var gender: UserGender = .male
        var title: UserTitle = .mister
        if let genderString = serviceProviderProfile.gender {
            if genderString.lowercased() == "f" {
                title = .mizz // "Ms"
                gender = .female
            }
        }

        var localKYCStatus = KnowYourCustomerStatus.request
        switch serviceProviderProfile.kycStatus {
        case .request: localKYCStatus = .request
        case .pass: localKYCStatus = .pass
        case .passConditional: localKYCStatus = .passConditional
        }
        
        var localLockedStatus = LockedStatus.notLocked
        switch serviceProviderProfile.lockedStatus {
        case .locked:
            localLockedStatus = .locked
        case .notLocked:
            localLockedStatus = .notLocked
        }
        
        let hasMadeDeposit = serviceProviderProfile.hasMadeDeposit

        return UserProfile(userIdentifier: serviceProviderProfile.userIdentifier,
                           sessionKey: serviceProviderProfile.sessionKey,
                           username: serviceProviderProfile.username,
                           email: serviceProviderProfile.email,
                           firstName: serviceProviderProfile.firstName,
                           middleName: serviceProviderProfile.middleName,
                           lastName: serviceProviderProfile.lastName,
                           birthDate: serviceProviderProfile.birthDate,
                           nationality: nationalityCountry,
                           country: country,
                           gender: gender,
                           title: title,
                           personalIdNumber: serviceProviderProfile.personalIdNumber,
                           address: serviceProviderProfile.address,
                           province: serviceProviderProfile.province,
                           city: serviceProviderProfile.city,
                           postalCode: serviceProviderProfile.postalCode,
                           birthDepartment: serviceProviderProfile.birthDepartment,
                           streetNumber: serviceProviderProfile.streetNumber,
                           phoneNumber: serviceProviderProfile.phoneNumber,
                           mobilePhone: serviceProviderProfile.mobilePhone,
                           mobileCountryCode: serviceProviderProfile.mobileCountryCode,
                           mobileLocalNumber: serviceProviderProfile.mobileLocalNumber,
                           avatarName: serviceProviderProfile.avatarName,
                           godfatherCode: serviceProviderProfile.godfatherCode,
                           placeOfBirth: serviceProviderProfile.placeOfBirth,
                           additionalStreetLine: serviceProviderProfile.additionalStreetLine,

                           isEmailVerified: serviceProviderProfile.isEmailVerified,
                           isRegistrationCompleted: serviceProviderProfile.isRegistrationCompleted,
                           kycStatus: localKYCStatus,
                           lockedStatus: localLockedStatus,
                           hasMadeDeposit: hasMadeDeposit,
                           kycExpire: serviceProviderProfile.kycExpiryDate,
                           currency: serviceProviderProfile.currency)
    }
    
}
