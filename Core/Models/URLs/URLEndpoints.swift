import Foundation

/// Represents all possible URL endpoints categories in the application
enum URLEndpoint {

    /// Represents all possible URL endpoints categories in the application
    struct Links: Hashable, Codable {
        var api: APIs
        var support: Support
        var responsibleGaming: ResponsibleGaming
        var socialMedia: SocialMedia
        var legalAndInfo: LegalAndInfo

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

    struct APIs: Hashable, Codable {
        /// Link: "https://sportsbook-stage.gomagaming.com/", (for betsson)
        var gomaGaming: String
        /// Link: "https://sportsbook.betsson.fr/", (for betsson)
        var sportsbook: String
        /// Link: "https://betsson-fr.firebaseapp.com/", (for betsson)
        var firebase: String
        /// Link: "https://casino.betsson.fr/", (for betsson)
        var casino: String
        /// Link: "https://promotions.betsson.fr/", (for betsson)
        var promotions: String
        /// Link: "http://www.partenaire-betsson.fr/", (for betsson)
        var affiliateSystem: String
        /// Link: "https://betsson.fr/secondary_markets_config.json" (for betsson)
        var secundaryMarketSpecsUrl: String

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

    struct Support: Hashable, Codable {
        /// Link: "https://support.betsson.fr/hc/fr" (for betsson)
        var helpCenter: String
        /// Link: "https://betssonfrance.zendesk.com/hc/fr" (for betsson)
        var zendesk: String
        /// Link: "https://support.betsson.fr/hc/fr/requests/new" (for betsson)
        var customerSupport: String

        static var empty: Support {
            Support(
                helpCenter: "",
                zendesk: "",
                customerSupport: ""
            )
        }
    }

    /// ResponsibleGaming links
    struct ResponsibleGaming: Hashable, Codable {

        /// Link:  https://sosjoueurs.org/ (for betsson)
        var gamblingAddictionHelpline: String

        /// Link:  https://gamban.com/ (for betsson)
        var gamblingBlockingSoftware: String

        /// Link:  https://www.evalujeu.fr/ (for betsson)
        var gamblingBehaviorSelfAssessment: String

        /// Link:  https://www.evalujeu.fr/ou-en-etes-vous-avec-les-jeux-dargent (for betsson)
        var gamblingBehaviorSelfAssessmentQuiz: String

        /// Link:  https://www.bettor-time.com/ (for betsson)
        var timeManagementApp: String

        /// Link:  https://www.joueurs-info-service.fr/ (for betsson)
        var gamblingAddictionSupport: String

        /// Link:  https://anj.fr/ (for betsson)
        var gamblingAuthority: String

        /// Link:  https://anj.fr/ts (for betsson)
        var gamblingAuthorityTerms: String

        /// Link: https://e-enfance.org/informer/controle-parental/ (for betsson)
        var parentalControl: String

        /// Link:  https://www.chu-nimes.fr/addictologie-unite-de-coordination-et-de-soins-en-addictologie.html (for betsson)
        var addictionTreatmentCenter: String

        /// Link:  https://interdictiondejeux.anj.fr (for betsson)
        var selfExclusionService: String

        /// Link: https://play.google.com/store/apps/details?id=com.goozix.bettor_time&hl=fr_CA&gl=US&pli=1 (for betsson)
        var gamblingHabitsApp: String

        static var empty: ResponsibleGaming {
            ResponsibleGaming(
                gamblingAddictionHelpline: "",
                gamblingBlockingSoftware: "",
                gamblingBehaviorSelfAssessment: "",
                gamblingBehaviorSelfAssessmentQuiz: "",
                timeManagementApp: "",
                gamblingAddictionSupport: "",
                gamblingAuthority: "",
                gamblingAuthorityTerms: "",
                parentalControl: "",
                addictionTreatmentCenter: "",
                selfExclusionService: "",
                gamblingHabitsApp: ""
            )
        }
    }

    struct SocialMedia: Hashable, Codable {

        /// Link:  "https://www.facebook.com/profile.php?id=61551148828863&locale=fr_FR" (for betsson)
        var facebook: String
        /// Link:  "https://twitter.com/BetssonFrance" (for betsson)
        var twitter: String
        /// Link:  "https://www.youtube.com/@betssonfrance" (for betsson)
        var youtube: String
        /// Link:  "https://www.instagram.com/betssonfrance/" (for betsson)
        var instagram: String

        static var empty: SocialMedia {
            SocialMedia(
                facebook: "",
                twitter: "",
                youtube: "",
                instagram: ""
            )
        }
    }

    struct LegalAndInfo: Hashable, Codable {

        /// Link:  "https://betsson.fr/fr/jeu-responsable" (for betsson)
        var responsibleGambling: String
        /// Link:  "https://betsson.fr/fr/politique-de-confidentialite" (for betsson)
        var privacyPolicy: String
        /// Link:  "https://betsson.fr/fr/politique-de-cookies" (for betsson)
        var cookiePolicy: String
        /// Link:  "https://betsson.fr/betting-rules.pdf" (for betsson)
        var sportsBettingRules: String
        /// Link:  "https://betsson.fr/terms-and-conditions.pdf" (for betsson)
        var termsAndConditions: String
        /// Link:  "https://betsson.fr/bonus_TC.pdf" (for betsson)
        var bonusRules: String
        /// Link:  "https://betsson.fr/fr/partenaires" (for betsson)
        var partners: String
        /// Link:  "https://betsson.fr/fr/a-propos" (for betsson)
        var about: String
        /// Link:  "https://apps.apple.com/fr/app/betsson/id6463237718" (for betsson)
        var appStoreUrl: String

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
