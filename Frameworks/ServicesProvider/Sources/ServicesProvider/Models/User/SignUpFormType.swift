//
//  SignUpFormType.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 22/07/2025.
//

public enum SignUpFormType {
    case simple(SimpleSignUpForm)
    case full(SignUpForm)
    case phone(PhoneSignUpForm)
}
