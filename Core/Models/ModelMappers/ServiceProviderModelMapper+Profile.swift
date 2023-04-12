//
//  ServiceProviderModelMapper+Profile.swift
//  Sportsbook
//
//  Created by Ruben Roques on 31/10/2022.
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


        return UserProfile(userIdentifier: serviceProviderProfile.userIdentifier,
                           username: serviceProviderProfile.username,
                           email: serviceProviderProfile.email,
                           firstName: serviceProviderProfile.firstName,
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
                           avatarName: serviceProviderProfile.avatarName,
                           godfatherCode: serviceProviderProfile.godfatherCode,
                           placeOfBirth: serviceProviderProfile.placeOfBirth,
                           additionalStreetLine: serviceProviderProfile.additionalStreetLine,

                           isEmailVerified: serviceProviderProfile.isEmailVerified,
                           isRegistrationCompleted: serviceProviderProfile.isRegistrationCompleted,
                           kycStatus: localKYCStatus)
    }
    
}
