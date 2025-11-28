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

    public let paymentOperators: [PaymentOperator]
    public let socialMediaPlatforms: [SocialPlatform]
    public let partnerClubs: [PartnerClub]
    public let socialLinks: [FooterSocialLink]
    public let sponsors: [FooterSponsor]
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
    public var onSponsorsUpdated: (([FooterSponsor]) -> Void)?
    public var onSocialLinksUpdated: (([FooterSocialLink]) -> Void)?
    public var onNavigationLinksUpdated: (([FooterLink]) -> Void)?
    public func handleSponsorTap(_ sponsor: FooterSponsor) {
        print("[MockExtendedListFooterViewModel] Sponsor tapped: \(sponsor.id) -> \(sponsor.url?.absoluteString ?? "nil")")
    }
    public func handleSocialLinkTap(_ link: FooterSocialLink) {
        print("[MockExtendedListFooterViewModel] Social link tapped: \(link.id) -> \(link.url?.absoluteString ?? "nil")")
    }

    // MARK: - Initialization

    public init(
        paymentOperators: [PaymentOperator] = PaymentOperator.allCases,
        socialMediaPlatforms: [SocialPlatform] = SocialPlatform.allCases,
        partnerClubs: [PartnerClub] = PartnerClub.allCases,
        sponsors: [FooterSponsor] = MockExtendedListFooterViewModel.defaultSponsors(),
        socialLinks: [FooterSocialLink] = MockExtendedListFooterViewModel.defaultSocialLinks(),
        navigationLinks: [FooterLink] = [],
        responsibleGamblingText: ResponsibleGamblingText = ResponsibleGamblingText(
            warning: LocalizationProvider.string("gambling_can_be_addictive"),
            advice: LocalizationProvider.string("please_play_responsibly")
        ),
        copyrightText: String = LocalizationProvider.string("copyright_betsson"),
        licenseHeaderText: String = LocalizationProvider.string("licenses"),
        licenseBodyText: String = "",
        partnershipHeaderText: String = LocalizationProvider.string("in_collaboration_with"),
        socialMediaHeaderText: String = "Follow us",
        imageResolver: ExtendedListFooterImageResolver = DefaultExtendedListFooterImageResolver()
    ) {
        self.paymentOperators = paymentOperators
        self.socialMediaPlatforms = socialMediaPlatforms
        self.partnerClubs = partnerClubs
        self.sponsors = sponsors
        self.socialLinks = socialLinks
        self.navigationLinks = navigationLinks.isEmpty ? Self.defaultNavigationLinks() : navigationLinks
        self.responsibleGamblingText = responsibleGamblingText
        self.copyrightText = copyrightText
        self.licenseHeaderText = licenseHeaderText
        self.licenseBodyText = licenseBodyText.isEmpty ? Self.defaultLicenseText() : licenseBodyText
        self.partnershipHeaderText = partnershipHeaderText
        self.socialMediaHeaderText = socialMediaHeaderText
        self.imageResolver = imageResolver

        let navigationLinksCopy = self.navigationLinks
        DispatchQueue.main.async { [sponsors, socialLinks, navigationLinksCopy] in
            self.onSponsorsUpdated?(sponsors)
            self.onSocialLinksUpdated?(socialLinks)
            self.onNavigationLinksUpdated?(navigationLinksCopy)
        }
    }

    // MARK: - Private Helpers

    private static func defaultNavigationLinks() -> [FooterLink] {
        return [
            FooterLink(title: LocalizationProvider.string("terms_consent_popup_title"), type: .termsAndConditions),
            FooterLink(title: LocalizationProvider.string("affiliates"), type: .affiliates),
            FooterLink(title: LocalizationProvider.string("privacy_policy_footer_link"), type: .privacyPolicy),
            FooterLink(title: LocalizationProvider.string("cookie_policy_footer_link"), type: .cookiePolicy),
            FooterLink(title: LocalizationProvider.string("responsible_gambling_footer_link"), type: .responsibleGambling),
            FooterLink(title: LocalizationProvider.string("game_rules"), type: .gameRules),
            FooterLink(title: LocalizationProvider.string("support_helpcenter_button_text"), type: .helpCenter),
            FooterLink(title: LocalizationProvider.string("contact_us"), type: .contactUs)
        ]
    }

    private static func defaultLicenseText() -> String {
        return "The operator of this website is Ngantat Sarl, a licensed company with registration number RCCM N° RC/DLN/2024/B/137 and with registered address at Makepe Douala Cour Supreme, Bâtiment Domino, Unit 33, Douala, Cameroon."
    }

    public static func defaultSponsors() -> [FooterSponsor] {
        return [
            FooterSponsor(
                id: "sponsor_1",
                iconURL: URL(string: "https://placehold.co/200x80/111111/FFFFFF/png?text=Sponsor+1"),
                url: URL(string: "https://example.com/sponsor1")
            ),
            FooterSponsor(
                id: "sponsor_2",
                iconURL: URL(string: "https://placehold.co/200x80/222222/FFFFFF/png?text=Sponsor+2"),
                url: URL(string: "https://example.com/sponsor2")
            ),
            FooterSponsor(
                id: "sponsor_3",
                iconURL: URL(string: "https://placehold.co/200x80/333333/FFFFFF/png?text=Sponsor+3"),
                url: URL(string: "https://example.com/sponsor3")
            ),
            FooterSponsor(
                id: "sponsor_4",
                iconURL: URL(string: "https://placehold.co/200x80/444444/FFFFFF/png?text=Sponsor+4"),
                url: URL(string: "https://example.com/sponsor4")
            ),
            FooterSponsor(
                id: "sponsor_5",
                iconURL: URL(string: "https://placehold.co/200x80/555555/FFFFFF/png?text=Sponsor+5"),
                url: URL(string: "https://example.com/sponsor5")
            ),
            FooterSponsor(
                id: "sponsor_6",
                iconURL: URL(string: "https://placehold.co/200x80/666666/FFFFFF/png?text=Sponsor+6"),
                url: URL(string: "https://example.com/sponsor6")
            )
        ]
    }

    public static func defaultSocialLinks() -> [FooterSocialLink] {
        return [
            FooterSocialLink(
                id: "social_x",
                iconURL: URL(string: "https://placehold.co/80x80/000000/FFFFFF/png?text=X"),
                url: URL(string: "https://twitter.com/example"),
                target: "_blank"
            ),
            FooterSocialLink(
                id: "social_fb",
                iconURL: URL(string: "https://placehold.co/80x80/1877F2/FFFFFF/png?text=FB"),
                url: URL(string: "https://facebook.com/example"),
                target: "_blank"
            ),
            FooterSocialLink(
                id: "social_ig",
                iconURL: URL(string: "https://placehold.co/80x80/E4405F/FFFFFF/png?text=IG"),
                url: URL(string: "https://instagram.com/example"),
                target: "_blank"
            )
        ]
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
            paymentOperators: [.mtn],
            socialMediaPlatforms: [.facebook, .instagram],
            sponsors: Array(defaultSponsors().prefix(2)),
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
            sponsors: Array(defaultSponsors().prefix(3)),
            navigationLinks: []
        )
    }

    /// Footer with 3 sponsor logos (tests dynamic grid with odd count)
    public static var threePartnersFooter: MockExtendedListFooterViewModel {
        return MockExtendedListFooterViewModel(
            sponsors: Array(defaultSponsors().prefix(3))
        )
    }

    /// Footer with 1 sponsor logo (tests single logo layout)
    public static var singlePartnerFooter: MockExtendedListFooterViewModel {
        return MockExtendedListFooterViewModel(
            sponsors: Array(defaultSponsors().prefix(1))
        )
    }

    /// Footer with 5 sponsor logos (tests 3 rows: 2+2+1)
    public static var fivePartnersFooter: MockExtendedListFooterViewModel {
        return MockExtendedListFooterViewModel(
            sponsors: Array(defaultSponsors().prefix(5))
        )
    }
}
