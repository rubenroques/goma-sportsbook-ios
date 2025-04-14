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
        return "https://goma-demo-ios-dev.europe-west1.firebasedatabase.app/"
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
        return .goma
    }

    static var homeTemplateBuilder: HomeTemplateBuilderType {
        return HomeTemplateBuilderType.cmsManaged
    }

    static var features: [SportsbookTargetFeatures] {
        return [.cashback, .mixMatch, .casino, .chat, .featuredCompetitionInTabBar]
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
        return "https://betsson.fr"
    }

    static func generatePromotionsPageUrlString(forAppLanguage appLanguage: String?, isDarkTheme: Bool?) -> String {
        let baseUrl = self.links.api.promotions
        let isDarkThemeString = isDarkTheme?.description ?? ""
        return "\(baseUrl)/\(appLanguage ?? "")/in-app/promotions?dark=\(isDarkThemeString)"
    }

    static var secundaryMarketSpecsUrl: String? {
        return "https://betsson.fr/secondary_markets_config.json"
    }

    static var knowYourClientLevels: [KnowYourCustomerLevel: String] {
        return [.identification: "kyc-level-1-id-verification",
                .proofOfAddress: "kyc-level-2-poa-verification",
                .bankAccountIdentification: "RIB Verification"]
    }

    static var localizationOverrides: [String: String] {
        return [:]
    }

    static var registerFlowType: RegisterFlowType {
        return .goma
    }
    
    static var enableDeveloperSettings: Bool {
        return true
    }
    
}

extension TargetVariables {

    // MARK: - URLEndpointProvider Implementation
    static var links: URLEndpoint.Links {
        URLEndpoint.Links.init(
            api: URLEndpoint.APIs.init(
                gomaGaming: "https://www.gomadevelopment.pt/",
                sportsbook: "https://www.gomadevelopment.pt/",
                firebase: "https://www.gomadevelopment.pt/",
                casino: "https://www.gomadevelopment.pt/",
                promotions: "https://www.gomadevelopment.pt/",
                affiliateSystem: "http://www.partenaire-betsson.fr/",
                secundaryMarketSpecsUrl: "https://www.gomadevelopment.pt/"
            ),
            support: URLEndpoint.Support.init(
                helpCenter: "https://www.gomadevelopment.pt/",
                zendesk: "https://www.gomadevelopment.pt/",
                customerSupport: "https://www.gomadevelopment.pt/"
            ),
            responsibleGaming: URLEndpoint.ResponsibleGaming.init(
                gamblingAddictionHelpline: "https://www.gomadevelopment.pt/",
                gamblingBlockingSoftware: "https://www.gomadevelopment.pt/",
                gamblingBehaviorSelfAssessment: "https://www.gomadevelopment.pt/",
                gamblingBehaviorSelfAssessmentQuiz: "https://www.gomadevelopment.pt/",
                timeManagementApp: "https://www.gomadevelopment.pt/",
                gamblingAddictionSupport: "https://www.gomadevelopment.pt/",
                gamblingAuthority: "https://www.gomadevelopment.pt/",
                gamblingAuthorityTerms: "https://www.gomadevelopment.pt/",
                parentalControl: "https://www.gomadevelopment.pt/",
                addictionTreatmentCenter: "https://www.gomadevelopment.pt/",
                selfExclusionService: "https://www.gomadevelopment.pt/",
                gamblingHabitsApp: "https://www.gomadevelopment.pt/"
            ),
            socialMedia: URLEndpoint.SocialMedia.init(
                facebook: "https://www.gomadevelopment.pt/",
                twitter: "https://www.gomadevelopment.pt/",
                youtube: "https://www.gomadevelopment.pt/",
                instagram: "https://www.gomadevelopment.pt/"
            ),
            legalAndInfo: URLEndpoint.LegalAndInfo.init(
                responsibleGambling: "https://www.gomadevelopment.pt/",
                privacyPolicy: "https://www.gomadevelopment.pt/",
                cookiePolicy: "https://www.gomadevelopment.pt/",
                sportsBettingRules: "https://www.gomadevelopment.pt/",
                termsAndConditions: "https://www.gomadevelopment.pt/",
                bonusRules: "https://www.gomadevelopment.pt/",
                partners: "https://www.gomadevelopment.pt/",
                about: "https://www.gomadevelopment.pt/",
                appStoreUrl: "https://www.gomadevelopment.pt/"
            )
        )
    }

}
