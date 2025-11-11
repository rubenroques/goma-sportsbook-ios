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

    /// Partner clubs to display in the footer
    var partnerClubs: [PartnerClub] { get }

    /// Payment operators to display in the footer
    var paymentOperators: [PaymentOperator] { get }

    /// Social media platforms to display
    var socialMediaPlatforms: [SocialPlatform] { get }

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
}
