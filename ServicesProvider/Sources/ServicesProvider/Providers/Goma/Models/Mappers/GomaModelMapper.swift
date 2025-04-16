//
//  File.swift
//  
//
//  Created by Ruben Roques on 21/12/2023.
//

import Foundation

struct GomaModelMapper {
    
    // Shared ISO8601DateFormatter for use across all mapping methods
    // This is more efficient than creating a new formatter in each method
    static let isoDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter() // 2024-04-01T12:34:56.789Z
        return formatter
    }()
    
    static func parseDateString(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        return dateFormatter.date(from: dateString)
    }

    static func basicRegisterResponse(fromInternalBasicRegisterResponse basicRegisterResponse: GomaModels.BasicRegisterResponse) -> DetailedSignUpResponse {

        let userData = SignUpUserData(id: basicRegisterResponse.id,
                                      name: basicRegisterResponse.name,
                                      email: basicRegisterResponse.email,
                                      username: basicRegisterResponse.username,
                                      avatarName: basicRegisterResponse.avatar ?? "")
        
        let signUpResponse = DetailedSignUpResponse(successful: true, errors: nil, userData: userData)
        return signUpResponse
    }
    
    static func loginResponse(fromInternalLoginResponse loginResponse: GomaModels.LoginResponse) -> LoginResponse {
        let userProfile = UserProfile(userIdentifier: "\(loginResponse.data.userData.id)",
                                        sessionKey: "",
                                          username: loginResponse.data.userData.username,
                                          email: loginResponse.data.userData.email,
                                          firstName: loginResponse.data.userData.name,
                                        middleName: nil,  // Added
                                        lastName: nil,
                                        birthDate: Date(),
                                        gender: nil,
                                        nationalityCode: nil,
                                        countryCode: nil,
                                        personalIdNumber: nil,
                                        address: nil,
                                        province: nil,
                                        city: nil,
                                        postalCode: nil,
                                        birthDepartment: nil,
                                        streetNumber: nil,
                                        phoneNumber: nil,
                                        mobilePhone: nil,
                                        mobileCountryCode: nil,
                                        mobileLocalNumber: nil,
                                      avatarName: loginResponse.data.userData.avatar,
                                      godfatherCode: loginResponse.data.userData.code,
                                        placeOfBirth: nil,
                                        additionalStreetLine: nil,
                                        emailVerificationStatus: .verified,
                                        userRegistrationStatus: .completed,
                                        kycStatus: .pass,
                                        lockedStatus: .notLocked,  // Added
                                        hasMadeDeposit: false,    // Added
                                        kycExpiryDate: nil,      // Added
                                        currency: nil)
            
        let mappedLoginResponse = LoginResponse(token: loginResponse.data.token,
                                                userProfile: userProfile)
        
        return mappedLoginResponse
    }
    
    static func favoriteList(fromInternalFavoriteItem favoriteItem: GomaModels.FavoriteItem) -> FavoriteList {
        
        let type = favoriteItem.type.typeString
        
        let favoriteList = FavoriteList(id: favoriteItem.favoriteId, name: type, customerId: favoriteItem.userId)
        
        return favoriteList
    }
    
}
