import Foundation

/// Enum representing all possible URL paths in the application
enum URLPath {
    // API endpoints
    case gomaGaming
    case sportsbook
    case firebase
    case casino
    case promotions
    case affiliateSystem
    case secundaryMarketSpecs

    // Support endpoints
    case helpCenter
    case zendesk
    case customerSupport

    // Responsible Gaming endpoints
    case gamblingAddictionHelpline
    case gamblingBlockingSoftware
    case gamblingBehaviorSelfAssessment
    case gamblingBehaviorSelfAssessmentQuiz
    case timeManagementApp
    case gamblingAddictionSupport
    case gamblingAuthority
    case gamblingAuthorityTerms
    case parentalControl
    case addictionTreatmentCenter
    case selfExclusionService
    case gamblingHabitsApp

    // Social Media endpoints
    case facebook
    case twitter
    case youtube
    case instagram

    // Legal and Info endpoints
    case responsibleGambling
    case privacyPolicy
    case cookiePolicy
    case sportsBettingRules
    case termsAndConditions
    case bonusRules
    case partners
    case about
    case appStoreUrl
}

extension URLEndpoint.Links {
    func getURL(for path: URLPath) -> String {
        switch path {
        // API endpoints
        case .gomaGaming: return self.api.gomaGaming
        case .sportsbook: return self.api.sportsbook
        case .firebase: return self.api.firebase
        case .casino: return self.api.casino
        case .promotions: return self.api.promotions
        case .affiliateSystem: return self.api.affiliateSystem
        case .secundaryMarketSpecs: return self.api.secundaryMarketSpecsUrl

        // Support endpoints
        case .helpCenter: return self.support.helpCenter
        case .zendesk: return self.support.zendesk
        case .customerSupport: return self.support.customerSupport

        // Responsible Gaming endpoints
        case .gamblingAddictionHelpline: return self.responsibleGaming.gamblingAddictionHelpline
        case .gamblingBlockingSoftware: return self.responsibleGaming.gamblingBlockingSoftware
        case .gamblingBehaviorSelfAssessment: return self.responsibleGaming.gamblingBehaviorSelfAssessment
        case .gamblingBehaviorSelfAssessmentQuiz: return self.responsibleGaming.gamblingBehaviorSelfAssessmentQuiz
        case .timeManagementApp: return self.responsibleGaming.timeManagementApp
        case .gamblingAddictionSupport: return self.responsibleGaming.gamblingAddictionSupport
        case .gamblingAuthority: return self.responsibleGaming.gamblingAuthority
        case .gamblingAuthorityTerms: return self.responsibleGaming.gamblingAuthorityTerms
        case .parentalControl: return self.responsibleGaming.parentalControl
        case .addictionTreatmentCenter: return self.responsibleGaming.addictionTreatmentCenter
        case .selfExclusionService: return self.responsibleGaming.selfExclusionService
        case .gamblingHabitsApp: return self.responsibleGaming.gamblingHabitsApp

        // Social Media endpoints
        case .facebook: return self.socialMedia.facebook
        case .twitter: return self.socialMedia.twitter
        case .youtube: return self.socialMedia.youtube
        case .instagram: return self.socialMedia.instagram

        // Legal and Info endpoints
        case .responsibleGambling: return self.legalAndInfo.responsibleGambling
        case .privacyPolicy: return self.legalAndInfo.privacyPolicy
        case .cookiePolicy: return self.legalAndInfo.cookiePolicy
        case .sportsBettingRules: return self.legalAndInfo.sportsBettingRules
        case .termsAndConditions: return self.legalAndInfo.termsAndConditions
        case .bonusRules: return self.legalAndInfo.bonusRules
        case .partners: return self.legalAndInfo.partners
        case .about: return self.legalAndInfo.about
        case .appStoreUrl: return self.legalAndInfo.appStoreUrl
        }
    }
}