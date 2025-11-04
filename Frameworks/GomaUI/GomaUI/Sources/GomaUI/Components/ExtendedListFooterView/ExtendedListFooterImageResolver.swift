//
//  ExtendedListFooterImageResolver.swift
//  GomaUI
//
//  Created on 02/11/2025.
//

import UIKit

// MARK: - Image Resolver Protocol

public protocol ExtendedListFooterImageResolver {
    func image(for imageType: FooterImageType) -> UIImage?
}

// MARK: - Default Image Resolver (SF Symbols)

public struct DefaultExtendedListFooterImageResolver: ExtendedListFooterImageResolver {

    public init() {}

    public func image(for imageType: FooterImageType) -> UIImage? {
        switch imageType {
        case .partnerLogo(let club):
            return partnerLogoPlaceholder(for: club)

        case .paymentProvider(let paymentOperator):
            return paymentProviderPlaceholder(for: paymentOperator)

        case .socialMedia(let platform):
            return socialMediaIcon(for: platform)

        case .certification(let type):
            return certificationBadge(for: type)
        }
    }

    // MARK: - Private Helpers

    private func partnerLogoPlaceholder(for club: PartnerClub) -> UIImage? {
        let imageName: String

        switch club {
        case .interMiami:
            imageName = "inter_partner_footer_icon"
        case .bocaJuniors:
            imageName = "boca_partner_footer_icon"
        case .racingClub:
            imageName = "racing_partner_footer_icon"
        case .atleticoNacional:
            imageName = "atletico_colombia_partner_footer_icon"
        }

        return UIImage(named: imageName, in: .module, compatibleWith: nil) ?? fallbackSFSymbol(for: club)
    }

    private func paymentProviderPlaceholder(for paymentOperator: PaymentOperator) -> UIImage? {
        let imageName: String

        switch paymentOperator {
        case .mtn:
            imageName = "mtn_operator_footer_icon"
        case .orange:
            imageName = "orange_operator_footer_icon"
        }

        return UIImage(named: imageName, in: .module, compatibleWith: nil) ?? fallbackSFSymbol(for: paymentOperator)
    }

    private func socialMediaIcon(for platform: SocialPlatform) -> UIImage? {
        let imageName: String

        switch platform {
        case .x:
            imageName = "x_social_footer_icon"
        case .facebook:
            imageName = "facebook_social_footer_icon"
        case .instagram:
            imageName = "instagram_social_footer_icon"
        case .youtube:
            imageName = "youtube_social_footer_icon"
        }

        return UIImage(named: imageName, in: .module, compatibleWith: nil) ?? fallbackSFSymbol(for: platform)
    }

    private func certificationBadge(for type: FooterImageType.CertificationType) -> UIImage? {
        let imageName: String

        switch type {
        case .egba:
            imageName = "egba_regulator_footer_icon"
        case .ecogra:
            imageName = "ecogra_regulator_footer_icon"
        }

        return UIImage(named: imageName, in: .module, compatibleWith: nil) ?? fallbackSFSymbol(for: type)
    }

    // MARK: - SF Symbol Fallbacks

    private func fallbackSFSymbol(for club: PartnerClub) -> UIImage? {
        switch club {
        case .interMiami:
            return UIImage(systemName: "sportscourt")
        case .bocaJuniors:
            return UIImage(systemName: "figure.soccer")
        case .racingClub:
            return UIImage(systemName: "trophy")
        case .atleticoNacional:
            return UIImage(systemName: "soccerball")
        }
    }

    private func fallbackSFSymbol(for paymentOperator: PaymentOperator) -> UIImage? {
        switch paymentOperator {
        case .mtn:
            return UIImage(systemName: "creditcard")
        case .orange:
            return UIImage(systemName: "dollarsign.circle")
        }
    }

    private func fallbackSFSymbol(for platform: SocialPlatform) -> UIImage? {
        switch platform {
        case .x:
            return UIImage(systemName: "xmark")
        case .facebook:
            return UIImage(systemName: "f.circle")
        case .instagram:
            return UIImage(systemName: "camera.circle")
        case .youtube:
            return UIImage(systemName: "play.circle")
        }
    }

    private func fallbackSFSymbol(for type: FooterImageType.CertificationType) -> UIImage? {
        switch type {
        case .egba:
            return UIImage(systemName: "shield.checkered")
        case .ecogra:
            return UIImage(systemName: "shield.lefthalf.filled.badge.checkmark")
        }
    }
}
