//
//  File.swift
//  
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public enum ServiceProviderError: Error {
    
    case privilegedAccessManagerNotFound
    case eventsProviderNotFound
    case bettingProviderNotFound
    case subscriptionNotFound

    case invalidEmailPassword
    case quickSignUpIncomplete
    
    case invalidSignUpEmail
    case invalidSignUpUsername
    case invalidSignUpPassword

    case incompletedSportData
    case userSessionNotFound

    case notPlacedBet(message: String)
    
    case onSubscribe
    case resourceNotFound

    case noResponseFromSocketOnContent

    case invalidRequestFormat
    case internalServerError
    case request
    case unauthorized
    case forbidden
    case invalidResponse
    case emptyData

    case decodingError(message: String)
    case errorMessage(message: String)
    
    case unknown
}
