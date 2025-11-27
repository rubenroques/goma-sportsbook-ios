//
//  ExtendedListFooterViewModel.swift
//  BetssonCameroonApp
//
//  Created on 03/11/2025.
//

import Foundation
import Combine
import ServicesProvider
import GomaUI

// MARK: - Extended List Footer View Model

class ExtendedListFooterViewModel: ExtendedListFooterViewModelProtocol {

    // MARK: - Content Properties

    let paymentOperators: [PaymentOperator]
    let socialMediaPlatforms: [SocialPlatform]
    let partnerClubs: [PartnerClub]
    private(set) var navigationLinks: [FooterLink]
    private(set) var sponsors: [FooterSponsor] = []
    private(set) var socialLinks: [FooterSocialLink] = []
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
    var onSponsorsUpdated: (([FooterSponsor]) -> Void)?
    var onSocialLinksUpdated: (([FooterSocialLink]) -> Void)?

    // MARK: - Dependencies

    private let servicesProvider: ServicesProvider.Client
    private var cancellables: Set<AnyCancellable> = []

    /// Stores the last raw responses retrieved from CMS so logs/debugging can inspect them.
    private(set) var fetchedFooterLinks: [ServicesProvider.FooterCMSLink] = []
    private(set) var fetchedFooterSponsors: [ServicesProvider.FooterCMSSponsor] = []
    private(set) var fetchedFooterSocialLinks: [ServicesProvider.FooterCMSSocialLink] = []

    // MARK: - Initialization

    init(
        imageResolver: ExtendedListFooterImageResolver,
        servicesProvider: ServicesProvider.Client = Env.servicesProvider
    ) {
        self.imageResolver = imageResolver
        self.servicesProvider = servicesProvider

        // Cameroon-specific content
        self.paymentOperators = PaymentOperator.allCases
        self.socialMediaPlatforms = SocialPlatform.allCases
        self.partnerClubs = PartnerClub.allCases
        self.navigationLinks = Self.cameroonNavigationLinks()
        
        // Sponsors will be populated from CMS or shown as defaults via partnerClubs in the view

        self.responsibleGamblingText = ResponsibleGamblingText(
            warning: localized("gambling_can_be_addictive"),
            advice: localized("please_play_responsibly")
        )

        self.copyrightText = localized("copyright_betsson")
        self.licenseHeaderText = localized("licenses")
        self.licenseBodyText = Self.cameroonLicenseText()
        self.partnershipHeaderText = localized("in_collaboration_with")
        self.socialMediaHeaderText = localized("follow_us")

        // Set up link tap handler to map to URL/email requests
        self.onLinkTap = { [weak self] linkType in
            self?.handleLinkTap(linkType)
        }
        
        let language = localized("current_language_code")

        self.fetchFooterLinks(language: language)
        self.fetchFooterSponsors(language: language)
        self.fetchFooterSocialLinks(language: language)
    }

    // MARK: - Private Methods

    func handleSponsorTap(_ sponsor: FooterSponsor) {
        guard let url = sponsor.url else { return }
        onURLOpenRequested?(url)
    }

    func handleSocialLinkTap(_ link: FooterSocialLink) {
        guard let url = link.url else { return }
        onURLOpenRequested?(url)
    }

    private func handleLinkTap(_ linkType: FooterLinkType) {
        if let cmsLink = cmsLink(for: linkType) {
            handleCMSLinkTap(for: linkType, cmsLink: cmsLink)
            return
        }

        if let url = linkType.url {
            onURLOpenRequested?(url)
        } else if let email = linkType.email {
            onEmailRequested?(email)
        }
    }

    private static func cameroonNavigationLinks() -> [FooterLink] {
        return FooterLinkType.defaultOrderedTypes.map { type in
            FooterLink(title: type.defaultFallbackTitle, type: type)
        }
    }

    private static func cameroonLicenseText() -> String {
        return localized("license_text")
    }

    // MARK: - Remote Footer Links Fetching

    /// Fetches footer links from CMS so we can inspect the raw payload before wiring it into the UI.
    /// - Parameter language: Optional language override passed to the CMS endpoint.
    func fetchFooterLinks(language: String? = nil) {
        servicesProvider
            .getFooterLinks(language: language)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("[ExtendedListFooterViewModel] ✅ Footer links fetch completed")
                case .failure(let error):
                    print("[ExtendedListFooterViewModel] ❌ Failed to fetch footer links: \(error)")
                }
            } receiveValue: { [weak self] links in
                self?.fetchedFooterLinks = links
                self?.applyCMSFooterLinks()
            }
            .store(in: &cancellables)
    }

    /// Fetches footer sponsors from CMS so we can inspect the payload and eventually power the logos section.
    func fetchFooterSponsors(language: String? = nil) {
        servicesProvider
            .getFooterSponsors(language: language)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("[ExtendedListFooterViewModel] ✅ Footer sponsors fetch completed")
                case .failure(let error):
                    print("[ExtendedListFooterViewModel] ❌ Failed to fetch footer sponsors: \(error)")
                }
            } receiveValue: { [weak self] sponsors in
                self?.fetchedFooterSponsors = sponsors
                self?.applyCMSFooterSponsors()
            }
            .store(in: &cancellables)
    }

    /// Fetches footer social links from CMS to power the social icons
    func fetchFooterSocialLinks(language: String? = nil) {
        servicesProvider
            .getFooterSocialLinks(language: language)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("[ExtendedListFooterViewModel] ✅ Footer social links fetch completed")
                case .failure(let error):
                    print("[ExtendedListFooterViewModel] ❌ Failed to fetch footer social links: \(error)")
                }
            } receiveValue: { [weak self] links in
                self?.fetchedFooterSocialLinks = links
                self?.applyCMSSocialLinks()
            }
            .store(in: &cancellables)
    }

    private func applyCMSFooterLinks() {
        guard !fetchedFooterLinks.isEmpty else { return }

        var updatedLinks = Self.cameroonNavigationLinks()
        for index in updatedLinks.indices {
            let type = updatedLinks[index].type
            guard let cmsLink = cmsLink(for: type) else { continue }
            let localizedTitle = localized(cmsLink.label)
            let displayTitle = localizedTitle.isEmpty ? updatedLinks[index].title : localizedTitle
            updatedLinks[index] = FooterLink(title: displayTitle, type: type)
        }

        navigationLinks = updatedLinks
    }

    private func applyCMSFooterSponsors() {
        if !fetchedFooterSponsors.isEmpty {
            sponsors = fetchedFooterSponsors.map { sponsor in
                let iconURL = sponsor.iconURL
                let tapURL = URL(string: sponsor.url)
                return FooterSponsor(
                    id: sponsor.id,
                    iconURL: iconURL,
                    url: tapURL
                )
            }
            onSponsorsUpdated?(sponsors)
        }
        // If CMS sponsors are empty, the view will show default sponsors from partnerClubs
    }

    private func applyCMSSocialLinks() {
        guard !fetchedFooterSocialLinks.isEmpty else { return }

        socialLinks = fetchedFooterSocialLinks.compactMap { link in
            let iconURL = link.iconURL
            let destination = URL(string: link.url)
            return FooterSocialLink(
                id: link.id,
                iconURL: iconURL,
                url: destination,
                target: link.target
            )
        }

        onSocialLinksUpdated?(socialLinks)
    }

    private func cmsLink(for linkType: FooterLinkType) -> ServicesProvider.FooterCMSLink? {
        let candidates = linkType.cmsIdentifiers
        guard !candidates.isEmpty else { return nil }

        return fetchedFooterLinks.first { link in
            let keys = [
                normalizedFooterKey(from: link.subType),
                normalizedFooterKey(from: link.label)
            ].compactMap { $0 }

            return keys.contains { candidates.contains($0) }
        }
    }

    private func handleCMSLinkTap(for linkType: FooterLinkType, cmsLink: ServicesProvider.FooterCMSLink) {
        switch cmsLink.type {
        case .mailto:
            let email = cmsLink.computedUrl.replacingOccurrences(of: "mailto:", with: "")
            onEmailRequested?(email)
        case .pdf, .external, .unknown:
            guard let url = URL(string: cmsLink.computedUrl) ?? linkType.url else { return }
            onURLOpenRequested?(url)
        }
    }

    // Produces stable slugs ("terms_and_conditions", "privacy_policy", etc.) so we can match CMS entries against our own semantic on FooterLinkTypes.cmsIdentifiers
    private func normalizedFooterKey(from value: String?) -> String? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }

        return value
            .lowercased()
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")
    }
}

// MARK: - Footer Link Helpers

private extension FooterLinkType {
    static var defaultOrderedTypes: [FooterLinkType] {
        return [
            .termsAndConditions,
            .affiliates,
            .privacyPolicy,
            .cookiePolicy,
            .responsibleGambling,
            .gameRules,
            .helpCenter,
            .contactUs
        ]
    }

    var defaultFallbackTitle: String {
        switch self {
        case .termsAndConditions: return localized("terms_and_conditions")
        case .affiliates: return localized("affiliates")
        case .privacyPolicy: return localized("privacy_policy")
        case .cookiePolicy: return localized("cookie_policy")
        case .responsibleGambling: return localized("responsible_gambling")
        case .gameRules: return localized("game_rules")
        case .helpCenter: return localized("help_center")
        case .contactUs: return localized("contact_us")
        case .socialMedia(let platform): return platform.displayName
        }
    }

    var cmsIdentifiers: [String] {
        switch self {
        case .termsAndConditions:
            return ["terms_and_conditions", "terms_conditions", "termsconditions", "terms"]
        case .affiliates:
            return ["affiliates", "affiliate_program"]
        case .privacyPolicy:
            return ["privacy_policy", "privacypolicy"]
        case .cookiePolicy:
            return ["cookie_policy", "cookiepolicy"]
        case .responsibleGambling:
            return ["responsible_gambling", "responsiblegambling"]
        case .gameRules:
            return ["game_rules", "gamerules"]
        case .helpCenter:
            return ["help_center", "helpcenter", "support_center"]
        case .contactUs:
            return ["contact_us", "contactus", "support_email"]
        case .socialMedia:
            return []
        }
    }
}
