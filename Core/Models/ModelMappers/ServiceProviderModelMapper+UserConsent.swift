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

        return UserConsent(id: userConsent.consentInfo.id,
                           consentVersionId: userConsent.consentInfo.consentVersionId,
                           name: userConsent.consentInfo.name,
                           key: userConsent.consentInfo.key,
                           consentStatus: Self.userConsentStatus(fromServiceProviderUserConsentStatus: userConsent.consentStatus ?? .notConsented),
                           consentType: Self.userConsentType(fromServiceProviderUserConsentType: userConsent.consentType ?? .sms))
    }

    static func userConsentStatus(fromServiceProviderUserConsentStatus userConsentStatus: ServicesProvider.UserConsentStatus) -> UserConsentStatus {

        switch userConsentStatus {
        case .notConsented:
            return .notConsented
        case .consented:
            return .consented
        }
    }

    static func userConsentType(fromServiceProviderUserConsentType userConsentType: ServicesProvider.UserConsentType) -> UserConsentType {

        switch userConsentType {
        case .sms:
            return .sms
        case .email:
            return .email
        }
    }}
