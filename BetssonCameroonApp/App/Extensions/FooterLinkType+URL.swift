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
            urlString = "https://www.betsson.com/en/terms-and-conditions"

        case .affiliates:
            urlString = "https://www.betssongroupaffiliates.com/"

        case .privacyPolicy:
            urlString = "https://www.betsson.com/en/privacy-policy"

        case .cookiePolicy:
            urlString = "https://www.betsson.com/en/cookie-policy"

        case .responsibleGambling:
            urlString = "https://www.betsson.com/en/responsible-gaming/information"

        case .gameRules:
            urlString = "https://www.betsson.com/en/game-rules"

        case .helpCenter:
            urlString = "https://support.betsson.com/"

        case .socialMedia(let platform):
            urlString = platform.socialMediaURL

        case .contactUs:
            // Contact Us uses email, not URL
            return nil
        }

        return URL(string: urlString)
    }

    /// Returns the email address for this link type, if applicable
    var email: String? {
        if case .contactUs = self {
            return "support-en@betsson.com"
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
            return "https://twitter.com/betsson"
        case .facebook:
            return "https://facebook.com/betsson"
        case .instagram:
            return "https://instagram.com/betsson"
        case .youtube:
            return "https://youtube.com/betsson"
        }
    }
}
