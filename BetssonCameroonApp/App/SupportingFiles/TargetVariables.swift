//
//  ClientVariables.swift
//  ShowcaseBeta
//
//  Created by Ruben Roques on 20/07/2021.
//

import Foundation

struct TargetVariables: SportsbookTarget {

    // MARK: - Build Environment
    enum BuildEnvironment: String {
        case staging = "Staging"
        case production = "Production"

        /// Reads current environment from Info.plist (set by APP_ENVIRONMENT build setting)
        static var current: BuildEnvironment {
            let envString = Bundle.main.object(forInfoDictionaryKey: "AppEnvironment") as? String ?? ""

            switch envString {
            case "Staging":
                return .staging
            case "Production":
                return .production
            default:
                // Default to production for safety if value is invalid/missing
                return .production
            }
        }
    }

    // MARK: - Environment Configuration

    static var environmentType: EnvironmentType {
        switch BuildEnvironment.current {
        case .staging:
            return .dev
        case .production:
            return .prod
        }
    }

    static var firebaseDatabaseURL: String {
        return "https://goma-sportsbook-betsson-cm-ios.europe-west1.firebasedatabase.app/"
        return "https://goma-sportsbook-betsson-cm-prod.europe-west1.firebasedatabase.app"
    }

    static var appStoreURL: String {
        return "https://goma-sportsbook-betsson-cm-ios.europe-west1.firebasedatabase.app/"
    }
    
    static var supportedThemes: [AppearanceMode] {
        return AppearanceMode.allCases
    }

    static var serviceProviderEnvironment: EnvironmentType {
        switch BuildEnvironment.current {
        case .staging:
            return .staging
        case .production:
            return .prod
        }
    }

    static var supportedLanguages: [SportsbookSupportedLanguage] {
        return [SportsbookSupportedLanguage.french, SportsbookSupportedLanguage.english]
    }
    
    
    static var features: [SportsbookTargetFeatures] {
        return []
    }
    
    static var userRequiredFeatures: [SportsbookTargetFeatures] {
        return []
    }
    
    static var serviceProviderType: ServiceProviderType {
        return .everymatrix
    }

    static var cmsClientBusinessUnit: CMSClientBusinessUnit {
        return .betssonCameroon
    }

    static var links: URLEndpoint.Links {
        return URLEndpoint.Links(
            api: URLEndpoint.APIs(
                gomaGaming: "",
                sportsbook: "",
                firebase: "",
                casino: "",
                promotions: "",
                affiliateSystem: "",
                secundaryMarketSpecsUrl: ""
            ),
            support: URLEndpoint.Support(
                helpCenter: localized("footer_help_center_link"),
                zendesk: "",
                customerSupport: localized("footer_help_center_link")
            ),
            responsibleGaming: URLEndpoint.ResponsibleGaming(
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
            ),
            socialMedia: URLEndpoint.SocialMedia(
                facebook: "",
                twitter: "",
                youtube: "",
                instagram: ""
            ),
            legalAndInfo: URLEndpoint.LegalAndInfo(
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
        )
    }

}

/*
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
        return .everymatrix
    }

    static var homeTemplateBuilder: HomeTemplateBuilderType {
        return HomeTemplateBuilderType.cmsManaged
    }

    static var features: [SportsbookTargetFeatures] {
        return []
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
        return .dev
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

}

*/
