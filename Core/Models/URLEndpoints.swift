import Foundation

/// Represents all possible URL endpoints categories in the application
enum URLEndpoint {

    /// Represents all possible URL endpoints categories in the application
    struct Links: Hashable {
        let api: APIs
        let support: Support
        let responsibleGaming: ResponsibleGaming
        let socialMedia: SocialMedia
        let legalAndInfo: LegalAndInfo

        static var empty: Links {
            Links(
                api: .empty,
                support: .empty,
                responsibleGaming: .empty,
                socialMedia: .empty,
                legalAndInfo: .empty
            )
        }
    }

    struct APIs: Hashable {
        let gomaGaming: String
        let sportsbook: String
        let firebase: String
        let casino: String
        let promotions: String
        let affiliateSystem: String
        let secundaryMarketSpecsUrl: String

        static var empty: APIs {
            APIs(
                gomaGaming: "",
                sportsbook: "",
                firebase: "",
                casino: "",
                promotions: "",
                affiliateSystem: "",
                secundaryMarketSpecsUrl: ""
            )
        }
    }

    struct Support: Hashable {
        let helpCenter: String
        let zendesk: String
        let customerSupport: String

        static var empty: Support {
            Support(
                helpCenter: "",
                zendesk: "",
                customerSupport: ""
            )
        }
    }

    struct ResponsibleGaming: Hashable {
        let gamblingAddictionHelpline: String
        let gamblingBlockingSoftware: String
        let gamblingBehaviorAssessment: String
        let timeManagementApp: String
        let gamblingAddictionSupport: String
        let gamblingAuthority: String
        let parentalControl: String
        let addictionTreatmentCenter: String
        let selfExclusionService: String

        static var empty: ResponsibleGaming {
            ResponsibleGaming(
                gamblingAddictionHelpline: "",
                gamblingBlockingSoftware: "",
                gamblingBehaviorAssessment: "",
                timeManagementApp: "",
                gamblingAddictionSupport: "",
                gamblingAuthority: "",
                parentalControl: "",
                addictionTreatmentCenter: "",
                selfExclusionService: ""
            )
        }
    }

    struct SocialMedia: Hashable {
        let facebook: String
        let twitter: String
        let youtube: String
        let instagram: String

        static var empty: SocialMedia {
            SocialMedia(
                facebook: "",
                twitter: "",
                youtube: "",
                instagram: ""
            )
        }
    }

    struct LegalAndInfo: Hashable {
        let responsibleGambling: String
        let privacyPolicy: String
        let cookiePolicy: String
        let sportsBettingRules: String
        let termsAndConditions: String
        let bonusRules: String
        let partners: String
        let about: String
        let appStoreUrl: String

        static var empty: LegalAndInfo {
            LegalAndInfo(
                responsibleGambling: "",
                privacyPolicy: "",
                cookiePolicy: "",
                sportsBettingRules: "",
                termsAndConditions: "",
                bonusRules: "",
                partners: "",
                about: "",
                appStoreUrl: ""
            )
        }
    }
}

/// Protocol to be implemented by each client to provide their specific URLs
protocol URLEndpointProvider {
    static var links: URLEndpoint.Links { get }
}
