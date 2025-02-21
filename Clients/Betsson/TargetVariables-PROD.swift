//
//  ClientVariables.swift
//  ShowcaseBeta
//
//  Created by Ruben Roques on 20/07/2021.
//

import Foundation
import Core

struct TargetVariables: SportsbookTarget {

    // MARK: - URLEndpointProvider Implementation

    static var api: URLEndpoint.APIs {
        URLEndpoint.APIs(
            gomaGaming: "https://sportsbook-stage.gomagaming.com/",
            sportsbook: "https://sportsbook.betsson.fr/",
            firebase: "https://betsson-fr.firebaseapp.com/",
            casino: "https://casino.betsson.fr/",
            promotions: "https://promotions.betsson.fr/"
        )
    }

    static var support: URLEndpoint.Support {
        URLEndpoint.Support(
            helpCenter: "https://support.betsson.fr/hc/fr",
            zendesk: "https://betssonfrance.zendesk.com/hc/fr",
            customerSupport: "https://support.betsson.fr/hc/fr/requests/new"
        )
    }

    static var responsibleGaming: URLEndpoint.ResponsibleGaming {
        URLEndpoint.ResponsibleGaming(
            sosjoueurs: "https://sosjoueurs.org/",
            gamban: "https://gamban.com/",
            evalujeu: "https://www.evalujeu.fr/ou-en-etes-vous-avec-les-jeux-dargent",
            bettorTime: "https://www.bettor-time.com/",
            jouersInfoService: "https://www.joueurs-info-service.fr/",
            anj: "https://anj.fr/",
            eEnfance: "https://e-enfance.org/",
            chuNimes: "https://www.chu-nimes.fr/addictologie-unite-de-coordination-et-de-soins-en-addictologie.html"
        )
    }

    static var socialMedia: URLEndpoint.SocialMedia {
        URLEndpoint.SocialMedia(
            facebook: "https://www.facebook.com/profile.php?id=61551148828863&locale=fr_FR",
            twitter: "https://twitter.com/BetssonFrance",
            youtube: "https://www.youtube.com/@betssonfrance",
            instagram: "https://www.instagram.com/betssonfrance/"
        )
    }

    // MARK: - Other SportsbookTarget Requirements

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
        return "https://betssonfr-74f1b-default-rtdb.europe-west1.firebasedatabase.app/"
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
        return [.cashback]
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
        return .prod
    }

    static var supportedLanguages: [SportsbookSupportedLanguage] {
        return [SportsbookSupportedLanguage.french]
    }

    static var clientBaseUrl: String {
        return "https://betsson.fr"
    }

    static func generatePromotionsPageUrlString(forAppLanguage appLanguage: String?, isDarkTheme: Bool?) -> String {
        let baseUrl = api.promotions
        let isDarkThemeString = isDarkTheme?.description ?? ""
        return "\(baseUrl)/\(appLanguage ?? "")/in-app/promotions?dark=\(isDarkThemeString)"
    }

    static var appStoreUrl: String? {
        return "https://apps.apple.com/fr/app/betsson/id6463237718"
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

}
