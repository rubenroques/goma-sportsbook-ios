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
        /// Link: "https://sportsbook-stage.gomagaming.com/", (for betsson)
        let gomaGaming: String
        /// Link: "https://sportsbook.betsson.fr/", (for betsson)
        let sportsbook: String
        /// Link: "https://betsson-fr.firebaseapp.com/", (for betsson)
        let firebase: String
        /// Link: "https://casino.betsson.fr/", (for betsson)
        let casino: String
        /// Link: "https://promotions.betsson.fr/", (for betsson)
        let promotions: String
        /// Link: "http://www.partenaire-betsson.fr/", (for betsson)
        let affiliateSystem: String
        /// Link: "https://betsson.fr/secondary_markets_config.json" (for betsson)
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
        /// Link: "https://support.betsson.fr/hc/fr" (for betsson)
        let helpCenter: String
        /// Link: "https://betssonfrance.zendesk.com/hc/fr" (for betsson)
        let zendesk: String
        /// Link: "https://support.betsson.fr/hc/fr/requests/new" (for betsson)
        let customerSupport: String

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
        
        /// Link:  https://sosjoueurs.org/ (for betsson)
        let gamblingAddictionHelpline: String
        
        /// Link:  https://gamban.com/ (for betsson)
        let gamblingBlockingSoftware: String
        
        /// Link:  https://www.evalujeu.fr/ (for betsson)
        let gamblingBehaviorSelfAssessment: String
        
        /// Link:  https://www.evalujeu.fr/ou-en-etes-vous-avec-les-jeux-dargent (for betsson)
        let gamblingBehaviorSelfAssessmentQuiz: String
        
        /// Link:  https://www.bettor-time.com/ (for betsson)
        let timeManagementApp: String
        
        /// Link:  https://www.joueurs-info-service.fr/ (for betsson)
        let gamblingAddictionSupport: String
        
        /// Link:  https://anj.fr/ (for betsson)
        let gamblingAuthority: String
        
        /// Link:  https://anj.fr/ts (for betsson)
        let gamblingAuthorityTerms: String
        
        /// Link: https://e-enfance.org/informer/controle-parental/ (for betsson)
        let parentalControl: String
        
        /// Link:  https://www.chu-nimes.fr/addictologie-unite-de-coordination-et-de-soins-en-addictologie.html (for betsson)
        let addictionTreatmentCenter: String
        
        /// Link:  https://interdictiondejeux.anj.fr (for betsson)
        let selfExclusionService: String
        
        /// Link: https://play.google.com/store/apps/details?id=com.goozix.bettor_time&hl=fr_CA&gl=US&pli=1 (for betsson)
        let gamblingHabitsApp: String
        
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

    struct SocialMedia: Hashable {
        
        /// Link:  "https://www.facebook.com/profile.php?id=61551148828863&locale=fr_FR" (for betsson)
        let facebook: String
        /// Link:  "https://twitter.com/BetssonFrance" (for betsson)
        let twitter: String
        /// Link:  "https://www.youtube.com/@betssonfrance" (for betsson)
        let youtube: String
        /// Link:  "https://www.instagram.com/betssonfrance/" (for betsson)
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
        
        /// Link:  "https://betsson.fr/fr/jeu-responsable" (for betsson)
        let responsibleGambling: String
        /// Link:  "https://betsson.fr/fr/politique-de-confidentialite" (for betsson)
        let privacyPolicy: String
        /// Link:  "https://betsson.fr/fr/politique-de-cookies" (for betsson)
        let cookiePolicy: String
        /// Link:  "https://betsson.fr/betting-rules.pdf" (for betsson)
        let sportsBettingRules: String
        /// Link:  "https://betsson.fr/terms-and-conditions.pdf" (for betsson)
        let termsAndConditions: String
        /// Link:  "https://betsson.fr/bonus_TC.pdf" (for betsson)
        let bonusRules: String
        /// Link:  "https://betsson.fr/fr/partenaires" (for betsson)
        let partners: String
        /// Link:  "https://betsson.fr/fr/a-propos" (for betsson)
        let about: String
        /// Link:  "https://apps.apple.com/fr/app/betsson/id6463237718" (for betsson)
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
