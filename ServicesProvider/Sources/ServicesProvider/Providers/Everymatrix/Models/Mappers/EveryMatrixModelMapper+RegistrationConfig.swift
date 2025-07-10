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
}
