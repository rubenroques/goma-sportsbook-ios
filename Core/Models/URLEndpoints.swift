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
        let gomaGaming: String // "https://sportsbook-stage.gomagaming.com/",
        let sportsbook: String // "https://sportsbook.betsson.fr/",
        let firebase: String // "https://betsson-fr.firebaseapp.com/",
        let casino: String // "https://casino.betsson.fr/",
        let promotions: String // "https://promotions.betsson.fr/",
        let affiliateSystem: String // "http://www.partenaire-betsson.fr/",
        let secundaryMarketSpecsUrl: String // "https://betsson.fr/secondary_markets_config.json"

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
        let helpCenter: String // "https://support.betsson.fr/hc/fr"
        let zendesk: String // "https://betssonfrance.zendesk.com/hc/fr"
        let customerSupport: String // "https://support.betsson.fr/hc/fr/requests/new"

        static var empty: Support {
            Support(
                helpCenter: "",
                zendesk: "",
                customerSupport: ""
            )
        }
    }

    /// ResponsibleGaming links 
    struct ResponsibleGaming: Hashable {
        
        /// Link:  https://sosjoueurs.org/
        let gamblingAddictionHelpline: String
        
        /// Link:  https://gamban.com/
        let gamblingBlockingSoftware: String
        
        /// Link:  https://www.evalujeu.fr/ou-en-etes-vous-avec-les-jeux-dargent
        let gamblingBehaviorSelfAssessment: String
        
        /// Link:  https://www.bettor-time.com/
        let timeManagementApp: String
        
        /// Link:  https://www.joueurs-info-service.fr/
        let gamblingAddictionSupport: String
        
        /// Link:  https://anj.fr/
        let gamblingAuthority: String
        
        /// Link:  https://anj.fr/ts
        let gamblingAuthorityTerms: String
        
        /// Link:  https://e-enfance.org/
        let parentalControl: String
        
        /// Link:  https://www.chu-nimes.fr/addictologie-unite-de-coordination-et-de-soins-en-addictologie.html
        let addictionTreatmentCenter: String
        
        /// Link:  https://interdictiondejeux.anj.fr
        let selfExclusionService: String

        static var empty: ResponsibleGaming {
            ResponsibleGaming(
                gamblingAddictionHelpline: "",
                gamblingBlockingSoftware: "",
                gamblingBehaviorSelfAssessment: "",
                timeManagementApp: "",
                gamblingAddictionSupport: "",
                gamblingAuthority: "",
                gamblingAuthorityTerms:"",
                parentalControl: "",
                addictionTreatmentCenter: "",
                selfExclusionService: ""
            )
        }
    }

    struct SocialMedia: Hashable {
        let facebook: String // "https://www.facebook.com/profile.php?id=61551148828863&locale=fr_FR"
        let twitter: String // "https://twitter.com/BetssonFrance"
        let youtube: String // "https://www.youtube.com/@betssonfrance"
        let instagram: String // "https://www.instagram.com/betssonfrance/"

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
        let responsibleGambling: String // "https://betsson.fr/fr/jeu-responsable"
        let privacyPolicy: String // "https://betsson.fr/fr/politique-de-confidentialite"
        let cookiePolicy: String // "https://betsson.fr/fr/politique-de-cookies"
        let sportsBettingRules: String // "https://betsson.fr/betting-rules.pdf"
        let termsAndConditions: String // "https://betsson.fr/terms-and-conditions.pdf"
        let bonusRules: String // "https://betsson.fr/bonus_TC.pdf"
        let partners: String // "https://betsson.fr/fr/partenaires"
        let about: String // "https://betsson.fr/fr/a-propos"
        let appStoreUrl: String // "https://apps.apple.com/fr/app/betsson/id6463237718"
 
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
