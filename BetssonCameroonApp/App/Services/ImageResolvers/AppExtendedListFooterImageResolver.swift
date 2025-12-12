//
//  AppExtendedListFooterImageResolver.swift
//  BetssonCameroonApp
//
//  Created on 02/11/2025.
//

import UIKit
import GomaUI

// MARK: - App Extended List Footer Image Resolver

struct AppExtendedListFooterImageResolver: ExtendedListFooterImageResolver {

    // MARK: - Image Resolution

    func image(for imageType: FooterImageType) -> UIImage? {
        switch imageType {
        case .partnerLogo(let club):
            return partnerLogoImage(for: club)

        case .paymentProvider(let paymentOperator):
            return paymentProviderImage(for: paymentOperator)

        case .socialMedia(let platform):
            return socialMediaImage(for: platform)

        case .certification(let type):
            return certificationImage(for: type)
        }
    }

    // MARK: - Private Image Resolution Methods

    private func partnerLogoImage(for club: PartnerClub) -> UIImage? {
        let languageCode = LanguageManager.shared.currentLanguageCode.lowercased()
        let imageName: String

        switch club {
        case .interMiami:
            imageName = "inter_partner_footer_icon_\(languageCode)"
        case .bocaJuniors:
            imageName = "boca_partner_footer_icon_\(languageCode)"
        case .racingClub:
            imageName = "racing_partner_footer_icon_\(languageCode)"
        case .atleticoNacional:
            imageName = "atletico_colombia_partner_footer_icon_\(languageCode)"
        }

        return UIImage(named: imageName) ?? fallbackPartnerLogo(for: club)
    }

    private func paymentProviderImage(for paymentOperator: PaymentOperator) -> UIImage? {
        let imageName: String

        switch paymentOperator {
        case .mtn:
            imageName = "mtn_operator_footer_icon"
        case .orange:
            imageName = "orange_operator_footer_icon"
        }

        return UIImage(named: imageName) ?? fallbackPaymentProvider(for: paymentOperator)
    }

    private func socialMediaImage(for platform: SocialPlatform) -> UIImage? {
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

        return UIImage(named: imageName) ?? fallbackSocialMedia(for: platform)
    }

    private func certificationImage(for type: FooterImageType.CertificationType) -> UIImage? {
        let imageName: String

        switch type {
        case .egba:
            imageName = "egba_regulator_footer_icon"
        case .ecogra:
            imageName = "ecogra_regulator_footer_icon"
        }

        return UIImage(named: imageName) ?? fallbackCertification(for: type)
    }

    // MARK: - Fallback Images (SF Symbols)

    private func fallbackPartnerLogo(for club: PartnerClub) -> UIImage? {
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

    private func fallbackPaymentProvider(for paymentOperator: PaymentOperator) -> UIImage? {
        switch paymentOperator {
        case .mtn:
            return UIImage(systemName: "creditcard")
        case .orange:
            return UIImage(systemName: "dollarsign.circle")
        }
    }

    private func fallbackSocialMedia(for platform: SocialPlatform) -> UIImage? {
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

    private func fallbackCertification(for type: FooterImageType.CertificationType) -> UIImage? {
        switch type {
        case .egba:
            return UIImage(systemName: "shield.checkered")
        case .ecogra:
            return UIImage(systemName: "shield.lefthalf.filled.badge.checkmark")
        }
    }
}
