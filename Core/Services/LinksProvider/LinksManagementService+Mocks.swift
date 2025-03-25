//
//  URLManagementService+Mocks.swift
//  Sportsbook
//
//  Created by Ruben Roques on 14/03/2025.
//

// MARK: - Mock Implementation for Testing
import Foundation

extension LinksManagementService {
    /// A mock implementation of URLManagementService for testing
    static var mock: LinksManagementService {
        let mockLinks = URLEndpoint.Links(
            api: URLEndpoint.APIs(
                gomaGaming: "https://mock.gomagaming.com/",
                sportsbook: "https://mock.sportsbook.com/",
                firebase: "https://mock.firebase.com/",
                casino: "https://mock.casino.com/",
                promotions: "https://mock.promotions.com/",
                affiliateSystem: "https://mock.affiliate.com/",
                secundaryMarketSpecsUrl: "https://mock.specs.com/config.json"
            ),
            support: URLEndpoint.Support(
                helpCenter: "https://mock.help.com/",
                zendesk: "https://mock.zendesk.com/",
                customerSupport: "https://mock.support.com/"
            ),
            responsibleGaming: URLEndpoint.ResponsibleGaming(
                gamblingAddictionHelpline: "https://mock.helpline.com/",
                gamblingBlockingSoftware: "https://mock.blocking.com/",
                gamblingBehaviorSelfAssessment: "https://mock.assessment.com/",
                gamblingBehaviorSelfAssessmentQuiz: "https://mock.quiz.com/",
                timeManagementApp: "https://mock.timeapp.com/",
                gamblingAddictionSupport: "https://mock.support.com/",
                gamblingAuthority: "https://mock.authority.com/",
                gamblingAuthorityTerms: "https://mock.terms.com/",
                parentalControl: "https://mock.parental.com/",
                addictionTreatmentCenter: "https://mock.treatment.com/",
                selfExclusionService: "https://mock.exclusion.com/",
                gamblingHabitsApp: "https://mock.habits.com/"
            ),
            socialMedia: URLEndpoint.SocialMedia(
                facebook: "https://mock.facebook.com/",
                twitter: "https://mock.twitter.com/",
                youtube: "https://mock.youtube.com/",
                instagram: "https://mock.instagram.com/"
            ),
            legalAndInfo: URLEndpoint.LegalAndInfo(
                responsibleGambling: "https://mock.responsible.com/",
                privacyPolicy: "https://mock.privacy.com/",
                cookiePolicy: "https://mock.cookie.com/",
                sportsBettingRules: "https://mock.rules.com/",
                termsAndConditions: "https://mock.terms.com/",
                bonusRules: "https://mock.bonus.com/",
                partners: "https://mock.partners.com/",
                about: "https://mock.about.com/",
                appStoreUrl: "https://mock.appstore.com/"
            )
        )
        
        // Create a mock UserDefaults
        let mockUserDefaults = MockUserDefaults()
        
        return LinksManagementService(
            initialLinks: mockLinks,
            servicesProvider: Env.servicesProvider,
            userDefaults: mockUserDefaults
        )
    }
}

// MARK: - Mock Classes for Testing

/// A mock UserDefaults for testing
class MockUserDefaults: UserDefaults {
    private var storage: [String: Any] = [:]
    
    override func object(forKey defaultName: String) -> Any? {
        return storage[defaultName]
    }
    
    override func set(_ value: Any?, forKey defaultName: String) {
        storage[defaultName] = value
    }
    
    override func data(forKey defaultName: String) -> Data? {
        return storage[defaultName] as? Data
    }
}
