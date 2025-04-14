//
//  ClientVariables.swift
//  ShowcaseBeta
//
//  Created by Ruben Roques on 20/07/2021.
//

import Foundation

struct TargetVariablesMB: SportsbookTarget {

    static var environmentType: EnvironmentType = .prod

    static var gomaGamingHost: String {
        return "https://api.gomademo.com"
    }

    static var gomaGamingAnonymousAuthEndpoint: String {
        return "https://api.gomademo.com/api/auth/v1"
    }

    static var gomaGamingLoggedAuthEndpoint: String {
        return "https://api.gomademo.com/api/auth/v1/login"
    }

    static var firebaseDatabaseURL: String {
//        return "https://multibet-fcm.firebaseio.com/"
        return "https://goma-demo-ios-dev.europe-west1.firebasedatabase.app/"
    }
    
    static var staticImagesURL: String {
        return "https://media.multibet.pt/logos"
    }

    static var everyMatrixHost: String {
        return ""
    }

    static var supportedThemes: [AppearanceMode] {
        return AppearanceMode.allCases
    }

    static var defaultCardStyle: CardsStyle {
        return .normal
    }

    static var defaultOddsValueType: OddsValueType {
        return .allOdds
    }

    static var serviceProviderType: ServiceProviderType {
        return .goma
    }

    static var homeTemplateBuilder: HomeTemplateBuilderType {
        return HomeTemplateBuilderType.clientDynamic
    }

    static var features: [SportsbookTargetFeatures] {
        return [.tips, .userWalletBalance, .myBets, .betting, .cashbackReplay, .suggestedBets, .chat, .casino]
    }

    static var userRequiredFeatures: [SportsbookTargetFeatures] {
        return [.myBets, .betting]
    }

    static var shouldUseBlurEffectTabBar: Bool {
        return false
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
        return [SportsbookSupportedLanguage.english]
    }

    static var clientBaseUrl: String {
        return "https://sportsbook.gomagaming.com"
    }
    
    static var appStoreUrl: String? {
        return ""
    }

    static var secundaryMarketSpecsUrl: String? {
        return ""
    }
    
    static var shouldUseListsFooter: Bool {
        return false
    }
    
    static var shouldUseMenuFooter: Bool {
        return false
    }
    
    static var registerType: RegisterType {
        return .multibet
    }
    
    static var profileType: ProfileType {
        return .finantial
    }
    
    static var ticketsLayoutType: TicketsLayoutType {
        return .cashback
    }
    
    static var appName: String {
        return "Goma"
    }
    
    static var betslipMode: SportsbookTargetBetslipAmountMode {
        return .anyDouble
    }
    
    static var shouldUseTeamLogos: Bool {
        return true
    }
    
    static var shouldUseAnonymousMenu: Bool {
        return true
    }
    
    static var updatePasswordNeedsOldPassword: Bool {
        return true
    }
    
    static var showPromotionalProviderLogos: Bool {
        return false
    }
    
    static var casinoURL: String {
        return "https://sportsbook-cms.gomagaming.com/casino/"
    }
}
