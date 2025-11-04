//
//  ExtendedListFooterModels.swift
//  GomaUI
//
//  Created on 02/11/2025.
//

import Foundation

// MARK: - Footer Link Type

public enum FooterLinkType {
    case termsAndConditions
    case affiliates
    case privacyPolicy
    case cookiePolicy
    case responsibleGambling
    case gameRules
    case helpCenter
    case contactUs
    case socialMedia(SocialPlatform)
}

// MARK: - Partner Club

public enum PartnerClub: String, CaseIterable {
    case interMiami = "inter_miami"
    case bocaJuniors = "boca_juniors"
    case racingClub = "racing_club"
    case atleticoNacional = "atletico_nacional"

    public var displayName: String {
        switch self {
        case .interMiami: return "Inter Miami"
        case .bocaJuniors: return "Boca Juniors"
        case .racingClub: return "Racing Club"
        case .atleticoNacional: return "Atlético Nacional"
        }
    }
}

// MARK: - Payment Operator

public enum PaymentOperator: String, CaseIterable {
    case mtn = "mtn"
    case orange = "orange"

    public var displayName: String {
        switch self {
        case .mtn: return "MTN Mobile Money"
        case .orange: return "Orange Money"
        }
    }
}

// MARK: - Social Platform

public enum SocialPlatform: String, CaseIterable {
    case x = "x"
    case facebook = "facebook"
    case instagram = "instagram"
    case youtube = "youtube"

    public var displayName: String {
        switch self {
        case .x: return "X"
        case .facebook: return "Facebook"
        case .instagram: return "Instagram"
        case .youtube: return "YouTube"
        }
    }
}

// MARK: - Footer Link

public struct FooterLink {
    public let title: String
    public let type: FooterLinkType

    public init(title: String, type: FooterLinkType) {
        self.title = title
        self.type = type
    }
}

// MARK: - Footer Image Type

public enum FooterImageType: Hashable {
    case partnerLogo(club: PartnerClub)
    case paymentProvider(operator: PaymentOperator)
    case socialMedia(platform: SocialPlatform)
    case certification(type: CertificationType)

    public enum CertificationType: String {
        case egba = "egba"
        case ecogra = "ecogra"
    }
}

// MARK: - Responsible Gambling Text

public struct ResponsibleGamblingText {
    public let warning: String
    public let advice: String

    public init(warning: String, advice: String) {
        self.warning = warning
        self.advice = advice
    }
}
