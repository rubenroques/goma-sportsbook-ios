//
//  EveryMatrixModelMapper+RegistrationConfig.swift
//  ServicesProvider
//
//  Created by André Lascas on 09/07/2025.
//

import Foundation
import SharedModels

extension EveryMatrixModelMapper {
    static func registrationConfigResponse(fromInternalResponse internalResponse: EveryMatrix.RegistrationConfigResponse) -> RegistrationConfigResponse {
        return RegistrationConfigResponse(
            type: internalResponse.type,
            content: registrationConfigContent(fromInternalContent: internalResponse.content)
        )
    }
    
    static func registrationConfigContent(fromInternalContent internalContent: EveryMatrix.RegistrationConfigContent) -> RegistrationConfigContent {
        return RegistrationConfigContent(
            step: internalContent.step,
            registrationID: internalContent.registrationID,
            actions: internalContent.actions,
            fields: internalContent.fields.map { registrationField(fromInternalField: $0) }
        )
    }
    
    static func registrationField(fromInternalField internalField: EveryMatrix.RegistrationField) -> RegistrationField {
        return RegistrationField(
            name: internalField.name,
            displayName: internalField.displayName,
            entityName: internalField.entityName,
            defaultValue: internalField.defaultValue,
            data: internalField.data,
            inputType: internalField.inputType,
            action: internalField.action,
            multiple: internalField.multiple,
            autofill: internalField.autofill,
            readOnly: internalField.readOnly,
            validate: registrationFieldValidation(fromInternalValidation: internalField.validate),
            decorate: internalField.decorate,
            tooltip: internalField.tooltip,
            placeholder: internalField.placeholder,
            isDefaultContact: internalField.isDefaultContact,
            contactTypeMapping: internalField.contactTypeMapping,
            customInfo: internalField.customInfo
        )
    }
    
    static func registrationFieldValidation(fromInternalValidation internalValidation: EveryMatrix.RegistrationFieldValidation) -> RegistrationFieldValidation {
        return RegistrationFieldValidation(
            mandatory: internalValidation.mandatory,
            type: internalValidation.type,
            custom: internalValidation.custom.map { registrationCustomValidation(fromInternalValidation: $0) },
            minLength: internalValidation.minLength,
            maxLength: internalValidation.maxLength,
            min: internalValidation.min,
            max: internalValidation.max
        )
    }
    
    static func registrationCustomValidation(fromInternalValidation internalValidation: EveryMatrix.RegistrationCustomValidation) -> RegistrationCustomValidation {
        return RegistrationCustomValidation(
            rule: internalValidation.rule,
            displayName: internalValidation.displayName,
            pattern: internalValidation.pattern,
            correlationField: internalValidation.correlationField,
            correlationValue: internalValidation.correlationValue,
            errorMessage: internalValidation.errorMessage,
            errorKey: internalValidation.errorKey
        )
    }
    
    static func signUpResponse(fromInternalRegisterStepResponse internalRegisterStepResponse: EveryMatrix.RegisterStepResponse) -> SignUpResponse {
        
        return SignUpResponse(successful: internalRegisterStepResponse.registrationId.isEmpty ? false : true)
    }
    
    static func signUpResponse(fromInternalRegisterResponse internalRegisterResponse: EveryMatrix.RegisterResponse) -> SignUpResponse {
        
        return SignUpResponse(successful: internalRegisterResponse.userId.isEmpty ? false : true)
    }
    
    static func userProfile(fromInternalPlayerProfile internalPlayerProfile: EveryMatrix.PlayerProfile) -> UserProfile {
        // Date parsing
        let dateFormatter = ISO8601DateFormatter()
        let birthDate: Date = dateFormatter.date(from: internalPlayerProfile.birthDate) ?? Date(timeIntervalSince1970: 0)

        return UserProfile(
            userIdentifier: String(internalPlayerProfile.id),
            sessionKey: "",
            username: internalPlayerProfile.userName,
            email: internalPlayerProfile.email,
            firstName: internalPlayerProfile.firstName,
            middleName: nil, // No field in PlayerProfile
            lastName: internalPlayerProfile.lastName,
            birthDate: birthDate,
            gender: internalPlayerProfile.gender,
            nationalityCode: internalPlayerProfile.nationality,
            countryCode: internalPlayerProfile.countryCode,
            personalIdNumber: internalPlayerProfile.personalId,
            address: internalPlayerProfile.address1,
            province: internalPlayerProfile.state,
            city: internalPlayerProfile.city,
            postalCode: internalPlayerProfile.zip,
            birthDepartment: nil, // No field in PlayerProfile
            streetNumber: nil,    // No field in PlayerProfile
            phoneNumber: internalPlayerProfile.phone,
            mobilePhone: internalPlayerProfile.mobilePhone,
            mobileCountryCode: internalPlayerProfile.mobilePhonePrefix,
            mobileLocalNumber: nil, // No field in PlayerProfile
            avatarName: nil, // No field in PlayerProfile
            godfatherCode: nil, // No field in PlayerProfile
            placeOfBirth: internalPlayerProfile.birthPlace,
            additionalStreetLine: internalPlayerProfile.address2,
            emailVerificationStatus: internalPlayerProfile.isEmailVerified ? .verified : .unverified,
            userRegistrationStatus: .completed,
            kycStatus: .pass,
            lockedStatus: .notLocked,
            hasMadeDeposit: false, // No field in PlayerProfile
            kycExpiryDate: nil, // No field in PlayerProfile
            currency: internalPlayerProfile.currency
        )
    }
}
