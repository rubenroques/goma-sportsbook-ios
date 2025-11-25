//
//  ExtendedListFooterViewModelProtocol.swift
//  GomaUI
//
//  Created on 02/11/2025.
//

import Foundation

// MARK: - Extended List Footer View Model Protocol

public protocol ExtendedListFooterViewModelProtocol {

    // MARK: - Content Properties

    /// Payment operators to display in the footer
    var paymentOperators: [PaymentOperator] { get }

    /// Social media platforms to display when no CMS data available
    var socialMediaPlatforms: [SocialPlatform] { get }

    /// Social media links fetched from CMS
    var socialLinks: [FooterSocialLink] { get }

    /// Partner clubs to display when no CMS sponsor data available
    var partnerClubs: [PartnerClub] { get }

    /// Sponsor logos fetched from CMS, ordered as provided
    var sponsors: [FooterSponsor] { get }

    /// Navigation links displayed in the footer
    var navigationLinks: [FooterLink] { get }

    /// Responsible gambling warning and advice text
    var responsibleGamblingText: ResponsibleGamblingText { get }

    /// Copyright text (e.g., "© Betsson 2025")
    var copyrightText: String { get }

    /// License header text (e.g., "Licenses")
    var licenseHeaderText: String { get }

    /// Full license body text with regulatory information
    var licenseBodyText: String { get }

    /// Section headers
    var partnershipHeaderText: String { get }
    var socialMediaHeaderText: String { get }

    // MARK: - Image Resolution

    /// Image resolver for all footer images (logos, icons, badges)
    var imageResolver: ExtendedListFooterImageResolver { get }

    // MARK: - Interaction

    /// Callback when a footer link is tapped
    var onLinkTap: ((FooterLinkType) -> Void)? { get set }

    /// Called when the UI needs to handle a sponsor tap interaction
    func handleSponsorTap(_ sponsor: FooterSponsor)

    /// Called when the UI needs to handle a CMS social link tap
    func handleSocialLinkTap(_ link: FooterSocialLink)

    /// Called to notify when CMS social links have updated
    var onSocialLinksUpdated: (([FooterSocialLink]) -> Void)? { get set }

    /// Emits whenever the sponsor list changes (e.g. after CMS fetch)
    var onSponsorsUpdated: (([FooterSponsor]) -> Void)? { get set }
}
