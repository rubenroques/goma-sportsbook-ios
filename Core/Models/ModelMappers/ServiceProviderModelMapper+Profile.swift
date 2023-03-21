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
         
        var title: UserTitle?
        if let gender = serviceProviderProfile.gender {
            if gender.lowercased() == "f" {
                title = .mizz // "Ms"
            }
            else if gender.lowercased() == "m" {
                title = .mister // "Mr"
            }
        }
        
        return UserProfile(userIdentifier: serviceProviderProfile.userIdentifier,
                           username: serviceProviderProfile.username,
                           email: serviceProviderProfile.email,
                           firstName: serviceProviderProfile.firstName,
                           lastName: serviceProviderProfile.lastName,
                           birthDate: serviceProviderProfile.birthDate,
                           nationality: nationalityCountry,
                           country: country,
                           gender: serviceProviderProfile.gender,
                           title: title,
                           personalIdNumber: serviceProviderProfile.personalIdNumber,
                           address: serviceProviderProfile.address,
                           province: serviceProviderProfile.province,
                           city: serviceProviderProfile.city,
                           postalCode: serviceProviderProfile.postalCode,
                           birthDepartment: serviceProviderProfile.birthDepartment,
                           streetNumber: serviceProviderProfile.streetNumber,
                           isEmailVerified: serviceProviderProfile.isEmailVerified,
                           isRegistrationCompleted: serviceProviderProfile.isRegistrationCompleted,
                           avatarName: serviceProviderProfile.avatarName,
                           godfatherCode: serviceProviderProfile.godfatherCode,
                           placeOfBirth: serviceProviderProfile.placeOfBirth,
                           additionalStreetLine: serviceProviderProfile.additionalStreetLine,
                           kycStatus: serviceProviderProfile.kycStatus)
    }
    
}
