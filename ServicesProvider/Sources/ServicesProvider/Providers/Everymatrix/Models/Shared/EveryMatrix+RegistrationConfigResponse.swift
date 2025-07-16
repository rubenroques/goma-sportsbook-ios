//
//  EveryMatrix+RegistrationConfigResponse.swift
//  ServicesProvider
//
//  Created by André Lascas on 09/07/2025.
//

import Foundation

extension EveryMatrix {
    // RegistrationConfigResponse.swift
    struct RegistrationConfigResponse: Codable {
        let type: String
        let content: RegistrationConfigContent
    }
    
    struct RegistrationConfigContent: Codable {
        let step: String
        let registrationID: String
        let actions: [String]
        let fields: [RegistrationField]
    }
    
    struct RegistrationField: Codable {
        let name: String
        let displayName: String
        let entityName: String?
        let defaultValue: String?
        let data: String?
        let inputType: String
        let action: String
        let multiple: Bool
        let autofill: Bool
        let readOnly: Bool
        let validate: RegistrationFieldValidation
        let decorate: String?
        let tooltip: String?
        let placeholder: String?
        let isDefaultContact: Bool
        let contactTypeMapping: String?
        let customInfo: [String: String]?
    }
    
    struct RegistrationFieldValidation: Codable {
        let mandatory: Bool
        let type: String
        let custom: [RegistrationCustomValidation]
        let minLength: Int?
        let maxLength: Int?
        let min: String?
        let max: String?
    }
    
    struct RegistrationCustomValidation: Codable {
        let rule: String
        let displayName: String?
        let pattern: String?
        let correlationField: String?
        let correlationValue: String?
        let errorMessage: String
        let errorKey: String
    }
    
    struct RegisterStepResponse: Codable {
        let registrationId: String
    }
    
    struct RegisterResponse: Codable {
        let userId: String
    }
}
