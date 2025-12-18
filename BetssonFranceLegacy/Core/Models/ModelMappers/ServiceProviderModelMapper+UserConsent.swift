//
//  ServiceProviderModelMapper+UserConsent.swift
//  Sportsbook
//
//  Created by André Lascas on 12/05/2023.
//

import Foundation
import ServicesProvider

extension ServiceProviderModelMapper {

    static func userConsent(fromServiceProviderUserConsent userConsent: ServicesProvider.UserConsent) -> UserConsent {

        return UserConsent(id: userConsent.info.id,
                           consentVersionId: userConsent.info.consentVersionId,
                           name: userConsent.info.name,
                           key: userConsent.info.key,
                           consentStatus: Self.userConsentStatus(fromServiceProviderUserConsentStatus: userConsent.status),
                           consentType: Self.userConsentType(fromServiceProviderUserConsentType: userConsent.type))
    }

    static func userConsentStatus(fromServiceProviderUserConsentStatus userConsentStatus: ServicesProvider.UserConsentStatus) -> UserConsentStatus {

        switch userConsentStatus {
        case .notConsented:
            return .notConsented
        case .consented:
            return .consented
        case .unknown:
            return .unknown
        }
    }

    static func userConsentType(fromServiceProviderUserConsentType userConsentType: ServicesProvider.UserConsentType) -> UserConsentType {

        switch userConsentType {
        case .sms:
            return .sms
        case .email:
            return .email
        case .terms:
            return .terms
        case .unknown:
            return .unknown
        }
    }}
