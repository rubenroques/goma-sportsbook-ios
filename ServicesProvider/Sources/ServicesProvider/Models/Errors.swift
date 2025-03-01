//
//  File.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public enum ServiceProviderError: Error, Equatable, Hashable {

    case privilegedAccessManagerNotFound
    case eventsProviderNotFound
    case bettingProviderNotFound
    case promotionsProviderNotFound
    case subscriptionNotFound

    case invalidEmailPassword
    case quickSignUpIncomplete

    case invalidSignUpEmail
    case invalidSignUpUsername
    case invalidSignUpPassword

    case invalidMobileVerifyCode

    case failedTempLock(date: String)

    case incompletedSportData
    case userSessionNotFound

    case notPlacedBet(message: String)
    case betNeedsUserConfirmation(betDetails: PlacedBetsResponse)

    case onSubscribe
    case resourceNotFound

    case resourceUnavailableOrDeleted

    case badRequest
    case pageNotFound
    case invalidRequestFormat
    case internalServerError
    case request
    case unauthorized
    case forbidden
    case invalidResponse
    case emptyData

    case decodingError(message: String)
    case errorMessage(message: String)

    case errorDetailedMessage(key: String, message: String)

    case invalidUserLocation
    case notSupportedForProvider
    case unknown
}
