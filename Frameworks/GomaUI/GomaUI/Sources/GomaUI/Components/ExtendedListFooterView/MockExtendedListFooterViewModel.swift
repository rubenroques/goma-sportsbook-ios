//
//  MockExtendedListFooterViewModel.swift
//  GomaUI
//
//  Created on 02/11/2025.
//

import Foundation

// MARK: - Mock Extended List Footer View Model

public class MockExtendedListFooterViewModel: ExtendedListFooterViewModelProtocol {

    // MARK: - Content Properties

    public let partnerClubs: [PartnerClub]
    public let paymentOperators: [PaymentOperator]
    public let socialMediaPlatforms: [SocialPlatform]
    public let navigationLinks: [FooterLink]
    public let responsibleGamblingText: ResponsibleGamblingText
    public let copyrightText: String
    public let licenseHeaderText: String
    public let licenseBodyText: String
    public let partnershipHeaderText: String
    public let socialMediaHeaderText: String

    // MARK: - Image Resolution

    public let imageResolver: ExtendedListFooterImageResolver

    // MARK: - Interaction

    public var onLinkTap: ((FooterLinkType) -> Void)?

    // MARK: - Initialization

    public init(
        partnerClubs: [PartnerClub] = PartnerClub.allCases,
        paymentOperators: [PaymentOperator] = PaymentOperator.allCases,
        socialMediaPlatforms: [SocialPlatform] = SocialPlatform.allCases,
        navigationLinks: [FooterLink] = [],
        responsibleGamblingText: ResponsibleGamblingText = ResponsibleGamblingText(
            warning: "Gambling can be addictive.",
            advice: "Please play responsibly."
        ),
        copyrightText: String = "© Betsson 2025",
        licenseHeaderText: String = "Licenses",
        licenseBodyText: String = "",
        partnershipHeaderText: String = "In collaboration with",
        socialMediaHeaderText: String = "Follow us",
        imageResolver: ExtendedListFooterImageResolver = DefaultExtendedListFooterImageResolver()
    ) {
        self.partnerClubs = partnerClubs
        self.paymentOperators = paymentOperators
        self.socialMediaPlatforms = socialMediaPlatforms
        self.navigationLinks = navigationLinks.isEmpty ? Self.defaultNavigationLinks() : navigationLinks
        self.responsibleGamblingText = responsibleGamblingText
        self.copyrightText = copyrightText
        self.licenseHeaderText = licenseHeaderText
        self.licenseBodyText = licenseBodyText.isEmpty ? Self.defaultLicenseText() : licenseBodyText
        self.partnershipHeaderText = partnershipHeaderText
        self.socialMediaHeaderText = socialMediaHeaderText
        self.imageResolver = imageResolver
    }

    // MARK: - Private Helpers

    private static func defaultNavigationLinks() -> [FooterLink] {
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

    private static func defaultLicenseText() -> String {
        return "The operator of this website is Ngantat Sarl, a licensed company with registration number RCCM N° RC/DLN/2024/B/137 and with registered address at Makepe Douala Cour Supreme, Bâtiment Domino, Unit 33, Douala, Cameroon."
    }
}

// MARK: - Factory Methods

extension MockExtendedListFooterViewModel {

    /// Standard Cameroon footer with all content
    public static var cameroonFooter: MockExtendedListFooterViewModel {
        return MockExtendedListFooterViewModel()
    }

    /// Minimal footer with reduced content for testing
    public static var minimalFooter: MockExtendedListFooterViewModel {
        return MockExtendedListFooterViewModel(
            partnerClubs: [.interMiami, .bocaJuniors],
            paymentOperators: [.mtn],
            socialMediaPlatforms: [.facebook, .instagram],
            navigationLinks: [
                FooterLink(title: "Terms", type: .termsAndConditions),
                FooterLink(title: "Privacy", type: .privacyPolicy),
                FooterLink(title: "Help", type: .helpCenter)
            ]
        )
    }

    /// Footer without navigation links for testing
    public static var noLinksFooter: MockExtendedListFooterViewModel {
        return MockExtendedListFooterViewModel(
            navigationLinks: []
        )
    }

    /// Footer with 3 partner logos (tests dynamic grid with odd count)
    public static var threePartnersFooter: MockExtendedListFooterViewModel {
        return MockExtendedListFooterViewModel(
            partnerClubs: [.interMiami, .bocaJuniors, .racingClub]
        )
    }

    /// Footer with 1 partner logo (tests single logo layout)
    public static var singlePartnerFooter: MockExtendedListFooterViewModel {
        return MockExtendedListFooterViewModel(
            partnerClubs: [.interMiami]
        )
    }

    /// Footer with 5 partner logos (tests 3 rows: 2+2+1)
    public static var fivePartnersFooter: MockExtendedListFooterViewModel {
        return MockExtendedListFooterViewModel(
            partnerClubs: [.interMiami, .bocaJuniors, .racingClub, .atleticoNacional, .interMiami]
        )
    }
}
