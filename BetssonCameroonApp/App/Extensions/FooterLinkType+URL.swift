//
//  FooterLinkType+URL.swift
//  BetssonCameroonApp
//
//  Created on 03/11/2025.
//

import Foundation
import GomaUI

// MARK: - Footer Link Type URL Mapping

extension FooterLinkType {

    /// Returns the URL for this link type, if applicable
    var url: URL? {
        let urlString: String

        switch self {
        case .termsAndConditions:
            urlString = localized("footer_tc_link")

        case .affiliates:
            urlString = localized("footer_affiliates_link")

        case .privacyPolicy:
            urlString = localized("footer_privacy_policy_link")

        case .cookiePolicy:
            urlString = localized("footer_cookie_policy_link")

        case .responsibleGambling:
            urlString = localized("footer_responsible_gambling_link")

        case .gameRules:
            urlString = localized("footer_game_rules_link")

        case .helpCenter:
            urlString = localized("footer_help_center_link")

        case .socialMedia(let platform):
            urlString = platform.socialMediaURL

        case .contactUs:
            // Contact Us uses email, not URL
            return nil
        
        case .casinoRules:
            urlString = localized("footer_casino_rules_link")
        case .custom(let urlString, _):
            return URL(string: urlString)
        }

        return URL(string: urlString)
    }

    /// Returns the email address for this link type, if applicable
    var email: String? {
        if case .contactUs = self {
            return localized("footer_betsson_mail")
        }
        return nil
    }
}

// MARK: - Social Platform URL Mapping

extension SocialPlatform {

    /// Returns the social media URL for this platform
    var socialMediaURL: String {
        switch self {
        case .x:
            return localized("footer_twitter_link")
        case .facebook:
            return localized("footer_facebook_link")
        case .instagram:
            return localized("footer_instagram_link")
        case .youtube:
            return localized("footer_youtube_link")
        }
    }
}
