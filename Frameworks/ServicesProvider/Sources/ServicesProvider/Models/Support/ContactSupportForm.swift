//
//  ContactSupportForm.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 21/04/2025.
//


/// Data form for the `contactSupport` API.
public struct ContactSupportForm: Codable, Hashable {
    public let userIdentifier: String
    public let firstName: String
    public let lastName: String
    public let email: String
    public let subject: String
    public let subjectType: String
    public let message: String
    public let isLogged: Bool
    
    public init(userIdentifier: String, firstName: String, lastName: String, email: String, subject: String, subjectType: String, message: String, isLogged: Bool) {
        self.userIdentifier = userIdentifier
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.subject = subject
        self.subjectType = subjectType
        self.message = message
        self.isLogged = isLogged
    }
    
}
