//
//  ContactUsForm.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 21/04/2025.
//


/// Data form for the `contactUs` API.
public struct ContactUsForm: Codable, Hashable {
    public let firstName: String
    public let lastName: String
    public let email: String
    public let subject: String
    public let message: String
}
