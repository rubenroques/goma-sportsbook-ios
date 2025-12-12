//
//  ClientVariables.swift
//  ShowcaseBeta
//
//  Created by Ruben Roques on 20/07/2021.
//

import Foundation
import ServicesProvider

struct TargetVariables: SportsbookTarget {

    // MARK: - Build Environment
    enum BuildEnvironment: String {
        case staging = "Staging"
        case uat = "UAT"
        case production = "Production"
        case betAtHomeProd = "BetAtHomeProd"

        /// Reads current environment from Info.plist (set by APP_ENVIRONMENT build setting)
        static var current: BuildEnvironment {
            let envString = Bundle.main.object(forInfoDictionaryKey: "AppEnvironment") as? String ?? ""
            print("[BuildEnvironment] Raw AppEnvironment from plist: '\(envString)'")

            let result: BuildEnvironment
            switch envString {
            case "Staging":
                result = .staging
            case "UAT":
                result = .uat
            case "Production":
                result = .production
            case "BetAtHomeProd":
                result = .betAtHomeProd
            default:
                // Default to production for safety if value is invalid/missing
                print("[BuildEnvironment] WARNING: Unknown value, defaulting to .production")
                result = .production
            }
            print("[BuildEnvironment] Resolved to: \(result.rawValue)")
            return result
        }

        /// Returns true if this is a BetAtHome client build
        var isBetAtHome: Bool {
            switch self {
            case .betAtHomeProd:
                return true
            default:
                return false
            }
        }
    }

    // MARK: - Environment Configuration

    static var environmentType: EnvironmentType {
        switch BuildEnvironment.current {
        case .staging:
            return .dev
        case .uat, .production, .betAtHomeProd:
            return .prod
        }
    }

    static var firebaseDatabaseURL: String {
        switch BuildEnvironment.current {
        case .staging:
            return "https://goma-sportsbook-betsson-cm-prod.europe-west1.firebasedatabase.app"
        case .uat:
            return "https://goma-sportsbook-betsson-cm-prod.europe-west1.firebasedatabase.app"
        case .production:
            return "https://betsson-cameroon-default-rtdb.europe-west1.firebasedatabase.app"
        case .betAtHomeProd:
            return "https://goma-sportsbook-betsson-cm-prod.europe-west1.firebasedatabase.app"
        }
    }

    static var appStoreURL: String {
        // TODO: this needs to have the final app store URL
        return "https://appdistribution.firebase.google.com/"
    }
    
    static var supportedThemes: [AppearanceMode] {
        return AppearanceMode.allCases
    }

    static var serviceProviderEnvironment: EnvironmentType {
        switch BuildEnvironment.current {
        case .staging:
            return .staging
        case .uat, .production, .betAtHomeProd:
            return .prod
        }
    }

    /// EveryMatrix operator ID (varies by client and environment)
    static var operatorId: String {
        switch BuildEnvironment.current {
        case .staging:
            return "4093"  // Betsson Cameroon staging
        case .uat, .production:
            return "4374"  // Betsson Cameroon production
        case .betAtHomeProd:
            return "2687"  // BetAtHome
        }
    }

    /// EveryMatrix WebSocket configuration (varies by client and environment)
    static var socketConfiguration: ServicesProvider.Configuration.SocketConfiguration {
        switch BuildEnvironment.current {
        case .staging:
            return .init(
                url: "wss://sportsapi-betsson-stage.everymatrix.com",
                origin: "https://sportsbook-stage.gomagaming.com",
                realm: "www.betsson.cm"
            )
        case .uat, .production:
            return .init(
                url: "wss://sportsapi.betssonem.com",
                origin: "https://www.betssonem.com/",
                realm: "www.betsson.cm"
            )
        case .betAtHomeProd:
            return .init(
                url: "wss://sportsapi.bet-at-home.de",
                origin: "https://sports2.bet-at-home.de",
                realm: "www.bet-at-home.de"
            )
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

    /// Brand logo asset name (varies by client)
    static var brandLogoAssetName: String {
        switch BuildEnvironment.current {
        case .betAtHomeProd:
            return "bet_at_home_brand_horizontal"
        case .staging, .uat, .production:
            return "default_brand_horizontal"
        }
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
