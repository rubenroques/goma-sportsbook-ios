//
//  ExtendedListFooterViewModel.swift
//  BetssonCameroonApp
//
//  Created on 03/11/2025.
//

import Foundation
import GomaUI

// MARK: - Extended List Footer View Model

class ExtendedListFooterViewModel: ExtendedListFooterViewModelProtocol {

    // MARK: - Content Properties

    let partnerClubs: [PartnerClub]
    let paymentOperators: [PaymentOperator]
    let socialMediaPlatforms: [SocialPlatform]
    let navigationLinks: [FooterLink]
    let responsibleGamblingText: ResponsibleGamblingText
    let copyrightText: String
    let licenseHeaderText: String
    let licenseBodyText: String
    let partnershipHeaderText: String
    let socialMediaHeaderText: String
    let imageResolver: ExtendedListFooterImageResolver

    // MARK: - MVVM-C Navigation Closures

    /// Coordinator handles URL opening
    var onURLOpenRequested: ((URL) -> Void)?

    /// Coordinator handles email composition
    var onEmailRequested: ((String) -> Void)?

    // MARK: - Link Tap Handler (Internal)

    var onLinkTap: ((FooterLinkType) -> Void)?

    // MARK: - Initialization

    init(imageResolver: ExtendedListFooterImageResolver) {
        self.imageResolver = imageResolver

        // Cameroon-specific content
        self.partnerClubs = PartnerClub.allCases
        self.paymentOperators = PaymentOperator.allCases
        self.socialMediaPlatforms = SocialPlatform.allCases
        self.navigationLinks = Self.cameroonNavigationLinks()

        self.responsibleGamblingText = ResponsibleGamblingText(
            warning: "Gambling can be addictive.",
            advice: "Please play responsibly."
        )

        self.copyrightText = "© Betsson 2025"
        self.licenseHeaderText = "Licenses"
        self.licenseBodyText = Self.cameroonLicenseText()
        self.partnershipHeaderText = "In collaboration with"
        self.socialMediaHeaderText = "Follow us"

        // Set up link tap handler to map to URL/email requests
        self.onLinkTap = { [weak self] linkType in
            self?.handleLinkTap(linkType)
        }
    }

    // MARK: - Private Methods

    private func handleLinkTap(_ linkType: FooterLinkType) {
        // Map link types to URLs and request opening via coordinator
        if let url = linkType.url {
            onURLOpenRequested?(url)
        } else if let email = linkType.email {
            onEmailRequested?(email)
        }
    }

    private static func cameroonNavigationLinks() -> [FooterLink] {
        return [
            FooterLink(title: "Terms and Conditions", type: .termsAndConditions),
            FooterLink(title: "Affiliates", type: .affiliates),
            FooterLink(title: "Privacy Policy", type: .privacyPolicy),
            FooterLink(title: "Cookie Policy", type: .cookiePolicy),
            FooterLink(title: "Responsible Gambling", type: .responsibleGambling),
            FooterLink(title: "Game Rules", type: .gameRules),
            FooterLink(title: "Help Center", type: .helpCenter),
            FooterLink(title: "Contact Us", type: .contactUs)
        ]
    }

    private static func cameroonLicenseText() -> String {
        return "The operator of this website is Ngantat Sarl, a licensed company with registration number RCCM N° RC/DLN/2024/B/137 and with registered address at Makepe Douala Cour Supreme, Bâtiment Domino, Unit 33, Douala, Cameroon."
    }
}
