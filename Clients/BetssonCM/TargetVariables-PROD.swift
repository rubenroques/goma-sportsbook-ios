//
//  ClientVariables.swift
//  ShowcaseBeta
//
//  Created by Ruben Roques on 20/07/2021.
//

import Foundation

struct TargetVariables: SportsbookTarget {

    static var environmentType: EnvironmentType = .prod

    static var gomaGamingHost: String {
        return "https://gomagaming.com" // https://sportsbook-api.gomagaming.com"
    }

    static var gomaGamingAnonymousAuthEndpoint: String {
        return "https://gomagaming.com" // https://sportsbook-api.gomagaming.com/api/auth/v1"
    }

    static var gomaGamingLoggedAuthEndpoint: String {
        return "https://gomagaming.com" // https://sportsbook-api.gomagaming.com/api/auth/v1/login"
    }

    static var firebaseDatabaseURL: String {
        return "https://goma-sportsbook.europe-west1.firebasedatabase.app/"
    }

    static var supportedThemes: [AppearanceMode] {
        return AppearanceMode.allCases
    }

    static var supportedCardStyles: [CardsStyle] {
        return [CardsStyle.normal]
    }

    static var defaultCardStyle: CardsStyle {
        return .normal
    }

    static var competitionListStyle: CompetitionListStyle {
        return .navigateToDetails
    }

    static var defaultOddsValueType: OddsValueType {
        return .allOdds
    }

    static var casinoURL: String {
        return "https://sportsbook-cms.gomagaming.com/casino/"
    }

    static var serviceProviderType: ServiceProviderType {
        return .sportradar
    }

    static var homeTemplateBuilder: HomeTemplateBuilderType {
        return HomeTemplateBuilderType.cmsManaged
    }

    static var features: [SportsbookTargetFeatures] {
        return [.cashback, .legalAgeWarning, .mixMatch, .featuredCompetitionInTabBar]
    }
    
    static var userRequiredFeatures: [SportsbookTargetFeatures] {
        return []
    }

    static var shouldUseBlurEffectTabBar: Bool {
        return true
    }

    static var shouldUseGradientBackgrounds: Bool {
        return true
    }

    static var shouldUseAlternateTopBar: Bool {
        return true
    }

    static var serviceProviderEnvironment: EnvironmentType {
        return .prod
    }

    static var supportedLanguages: [SportsbookSupportedLanguage] {
        return [SportsbookSupportedLanguage.french]
    }

    static var clientBaseUrl: String {
//        return "https://goma-uat.betsson.fr"
        return "https://sportsbook.gomagaming.com"
    }

    static func generatePromotionsPageUrlString(forAppLanguage appLanguage: String?, isDarkTheme: Bool?) -> String {
        let baseUrl = self.links.api.promotions
        let isDarkThemeString = isDarkTheme?.description ?? ""
        let urlString = "\(baseUrl)/\(appLanguage ?? "")/in-app/promotions?dark=\(isDarkThemeString)"
        return urlString
    }

    static var secundaryMarketSpecsUrl: String? {
        return "https://goma-uat.betsson.fr/secondary_markets_config.json"
    }

    static var knowYourClientLevels: [KnowYourCustomerLevel: String] {
        return [.identification: "kyc-level-1-id-verification-UAT",
                .proofOfAddress: "kyc-level-2-poa-verification-UAT",
                .bankAccountIdentification: "RIB Verification"]
    }

    static var localizationOverrides: [String: String] {
        return [:]
    }

    static var registerFlowType: RegisterFlowType {
        return .betsson
    }

    static var enableDeveloperSettings: Bool {
        return true
    }
    
    static var topCompetitionWidgetVersion: TopCompetitionWidgetVersion {
        return .version1
    }
    
    static var useAdaptiveRootViewController: Bool {
        return true
    }
}


extension TargetVariables {

    // MARK: - URLEndpointProvider Implementation
    static var links: URLEndpoint.Links {
        URLEndpoint.Links(
            api: URLEndpoint.APIs(
                gomaGaming: "https://sportsbook-stage.gomagaming.com/",
                sportsbook: "https://sportsbook.betsson.fr/",
                firebase: "https://betsson-fr.firebaseapp.com/",
                casino: "",
                promotions: "https://promotions.betsson.fr/",
                affiliateSystem: "http://www.partenaire-betsson.fr/",
                secundaryMarketSpecsUrl: "https://betsson.fr/secondary_markets_config.json"
            ),
            support: URLEndpoint.Support(
                helpCenter: "https://support.betsson.fr/hc/fr",
                zendesk: "https://betssonfrance.zendesk.com/hc/fr",
                customerSupport: "https://support.betsson.fr/hc/fr/requests/new"
            ),
            responsibleGaming: URLEndpoint.ResponsibleGaming(
                gamblingAddictionHelpline: "https://sosjoueurs.org/", // used
                gamblingBlockingSoftware: "https://gamban.com/fr/", // used
                gamblingBehaviorSelfAssessment: "https://www.evalujeu.fr/",
                gamblingBehaviorSelfAssessmentQuiz: "https://www.evalujeu.fr/ou-en-etes-vous-avec-les-jeux-dargent", // used
                timeManagementApp: "https://www.bettor-time.com/",
                gamblingAddictionSupport: "https://www.joueurs-info-service.fr/", // used
                gamblingAuthority: "https://anj.fr/",
                gamblingAuthorityTerms: "https://anj.fr/ts",
                parentalControl: "https://e-enfance.org/informer/controle-parental/", // used
                addictionTreatmentCenter: "https://www.chu-nimes.fr/actu-cht/addiction-aux-jeux--participez-a-letude-train-online.html", // used
                selfExclusionService: "https://interdictiondejeux.anj.fr",
                gamblingHabitsApp: "https://play.google.com/store/apps/details?id=com.goozix.bettor_time&hl=fr_CA&gl=US&pli=1" // used
            ),

            socialMedia: URLEndpoint.SocialMedia(
                facebook: "https://www.facebook.com/profile.php?id=61551148828863&locale=fr_FR",
                twitter: "https://twitter.com/BetssonFrance",
                youtube: "https://www.youtube.com/@betssonfrance",
                instagram: "https://www.instagram.com/betsson_france/"
            ),
            legalAndInfo: URLEndpoint.LegalAndInfo(
                responsibleGambling: "https://betsson.fr/fr/jeu-responsable",
                privacyPolicy: "https://betsson.fr/fr/politique-de-confidentialite",
                cookiePolicy: "https://betsson.fr/fr/politique-de-confidentialite/#cookies",
                sportsBettingRules: "https://betsson.fr/betting-rules.pdf",
                termsAndConditions: "https://betsson.fr/terms-and-conditions.pdf",
                bonusRules: "https://betsson.fr/bonus_TC.pdf",
                partners: "https://betsson.fr/fr/nos-partenaires",
                about: "https://betsson.fr/fr/about",
                appStoreUrl: "https://apps.apple.com/fr/app/betsson/id6463237718"
            )
        )
    }
}
