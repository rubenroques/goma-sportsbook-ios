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

    static var supportedThemes: [Theme] {
        return Theme.allCases
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
        return HomeTemplateBuilderType.clientDynamic
    }

    static var features: [SportsbookTargetFeatures] {
        return [.cashback, .legalAgeWarning]
    }

    static var shouldUserBlurEffectTabBar: Bool {
        return true
    }

    static var shouldUseGradientBackgrounds: Bool {
        return true
    }

    static var shouldUseAlternateTopBar: Bool {
        return true
    }

    static var serviceProviderEnvironment: EnvironmentType {
        return .dev
    }

    static var supportedLanguages: [SportsbookSupportedLanguage] {
        return [SportsbookSupportedLanguage.french]
    }

    static var clientBaseUrl: String {
        return "https://goma-uat.betsson.fr"
    }

    static func generatePromotionsPageUrlString(forAppLanguage appLanguage: String?, isDarkTheme: Bool?) -> String {
        let baseUrl = self.links.api.promotions
        let isDarkThemeString = isDarkTheme?.description ?? ""
        let urlString = "\(baseUrl)/\(appLanguage ?? "")/in-app/promotions?dark=\(isDarkThemeString)"
        return urlString
    }

    static var appStoreUrl: String? {
        return "https://apps.apple.com/fr/app/betsson/id6463237718"
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
}

extension TargetVariables {
    // MARK: - URLEndpointProvider Implementation
    static var links: URLEndpoint.Links {
        URLEndpoint.Links(
            api: URLEndpoint.APIs(
                gomaGaming: "https://sportsbook-stage.gomagaming.com/",
                sportsbook: "https://sportsbook.betsson.fr/",
                firebase: "https://betsson-fr.firebaseapp.com/",
                casino: "https://casino.betsson.fr/",
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
                gamblingAddictionHelpline: "https://sosjoueurs.org/",
                gamblingBlockingSoftware: "https://gamban.com/",
                gamblingBehaviorAssessment: "https://www.evalujeu.fr/ou-en-etes-vous-avec-les-jeux-dargent",
                timeManagementApp: "https://www.bettor-time.com/",
                gamblingAddictionSupport: "https://www.joueurs-info-service.fr/",
                gamblingAuthority: "https://anj.fr/",
                parentalControl: "https://e-enfance.org/",
                addictionTreatmentCenter: "https://www.chu-nimes.fr/addictologie-unite-de-coordination-et-de-soins-en-addictologie.html",
                selfExclusionService: "https://interdictiondejeux.anj.fr"
            ),
            socialMedia: URLEndpoint.SocialMedia(
                facebook: "https://www.facebook.com/profile.php?id=61551148828863&locale=fr_FR",
                twitter: "https://twitter.com/BetssonFrance",
                youtube: "https://www.youtube.com/@betssonfrance",
                instagram: "https://www.instagram.com/betssonfrance/"
            ),
            legalAndInfo: URLEndpoint.LegalAndInfo(
                responsibleGambling: "https://betsson.fr/fr/jeu-responsable",
                privacyPolicy: "https://betsson.fr/fr/politique-de-confidentialite",
                cookiePolicy: "https://betsson.fr/fr/politique-de-cookies",
                sportsBettingRules: "https://betsson.fr/betting-rules.pdf",
                termsAndConditions: "https://betsson.fr/terms-and-conditions.pdf",
                bonusRules: "https://betsson.fr/bonus_TC.pdf",
                partners: "https://betsson.fr/fr/partenaires",
                about: "https://betsson.fr/fr/a-propos",
                appStoreUrl: "https://apps.apple.com/fr/app/betsson/id6463237718"
            )
        )
    }
}

