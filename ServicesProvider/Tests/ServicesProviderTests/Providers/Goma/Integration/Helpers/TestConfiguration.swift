import Foundation

/// Configuration for integration tests
struct TestConfiguration {
    
    /// Endpoint paths for the Goma API
    struct EndpointPaths {
        static let homeTemplate = "/api/promotions/v1/home-template"
        static let alertBanner = "/api/promotions/v1/alert-banner"
        static let banners = "/api/promotions/v1/banners"
        static let sportBanners = "/api/promotions/v1/sport-banners"
        static let boostedOddsBanners = "/api/promotions/v1/boosted-odds-banners"
        static let heroCards = "/api/promotions/v1/hero-cards"
        static let stories = "/api/promotions/v1/stories"
        static let news = "/api/promotions/v1/news"
        static let proChoices = "/api/promotions/v1/pro-choices"
    }
    
    /// Subdirectory names for mock responses
    struct MockResponseDirectories {
        static let homeTemplate = "HomeTemplate"
        static let alertBanner = "AlertBanner"
        static let banners = "Banners"
        static let sportBanners = "SportBanners"
        static let boostedOddsBanners = "BoostedOddsBanners"
        static let heroCards = "HeroCards"
        static let stories = "Stories"
        static let news = "News"
        static let proChoices = "ProChoices"
    }
    
    /// API configuration
    struct API {
        static let baseURL = "https://api.gomademo.com"
        static let apiKey = "i4iStOcZWBFbrmWvwaccKpdVhyRpRB6uZGE9akT6IFMpSwIa0Ghl4lqsFSvqPNhi"
        static let deviceUUID = "68de20be-0e53-3cac-a822-ad0414f13502"
        static let deviceType = "ios"
    }
    
    /// Test authentication token
    /// This is a placeholder and should be replaced with a real token in tests
    static let authToken = "5944|V61S5ZW8Cn98tup13y3TWaOT4yHdclRwDIPrNrPib4ae0087"
} 