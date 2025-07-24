//
//  RegistrationConfigResponse.swift
//  ServicesProvider
//
//  Created by André Lascas on 09/07/2025.
//

import Foundation

public struct RegistrationConfigResponse: Codable {
    public let type: String
    public let content: RegistrationConfigContent
}

public struct RegistrationConfigContent: Codable {
    public let step: String
    public let registrationID: String
    public let actions: [String]
    public let fields: [RegistrationField]
}

public struct RegistrationField: Codable {
    public let name: String
    public let displayName: String
    public let entityName: String?
    public let defaultValue: String?
    public let data: String?
    public let inputType: String
    public let action: String
    public let multiple: Bool
    public let autofill: Bool
    public let readOnly: Bool
    public let validate: RegistrationFieldValidation
    public let decorate: String?
    public let tooltip: String?
    public let placeholder: String?
    public let isDefaultContact: Bool
    public let contactTypeMapping: String?
    public let customInfo: [String: String]?
}

public struct RegistrationFieldValidation: Codable {
    public let mandatory: Bool
    public let type: String
    public let custom: [RegistrationCustomValidation]
    public let minLength: Int?
    public let maxLength: Int?
    public let min: String?
    public let max: String?
}

public struct RegistrationCustomValidation: Codable {
    public let rule: String
    public let displayName: String?
    public let pattern: String?
    public let correlationField: String?
    public let correlationValue: String?
    public let errorMessage: String
    public let errorKey: String
}
