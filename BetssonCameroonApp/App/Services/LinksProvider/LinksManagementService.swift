import Foundation
import Combine
import ServicesProvider

/// Service responsible for managing dynamic URLs
class LinksManagementService: LinksManagementServiceProtocol {

    // MARK: - Properties

    /// The current links configuration
    private var _links: URLEndpoint.Links
    private let linksQueue = DispatchQueue(label: "com.goma.LinksManagementService.queue")

    var links: URLEndpoint.Links {
        return linksQueue.sync { _links }
    }

    // Cache keys
    private let cacheKey = "cached_dynamic_urls"
    private let cacheExpirationKey = "cached_dynamic_urls_expiration"
    private let cacheVersionKey = "cached_dynamic_urls_version"
    private let currentCacheVersion = 1

    #if DEBUG
    private let cacheExpirationInterval: TimeInterval = 10
    #else
    private let cacheExpirationInterval: TimeInterval = (60 * 60 * 2) // 2 hours
    #endif

    private var cancellables = Set<AnyCancellable>()
    private let servicesProvider: ServicesProvider.Client
    private let userDefaults: UserDefaults

    // MARK: - Initialization

    /// Initialize the URL management service
    /// - Parameters:
    ///   - initialLinks: The initial links configuration
    ///   - servicesProvider: The services provider client
    ///   - userDefaults: The user defaults storage
    init(
        initialLinks: URLEndpoint.Links,
        servicesProvider: ServicesProvider.Client,
        userDefaults: UserDefaults = .standard
    ) {
        self._links = initialLinks
        self.servicesProvider = servicesProvider
        self.userDefaults = userDefaults

        // Try to load from cache first
        if !loadCachedURLs() {
            // If cache loading failed, schedule an immediate fetch
            DispatchQueue.main.async { [weak self] in
                self?.fetchIfNeeded()
            }
        }
        else {
            // Even if cache was loaded successfully, schedule a background refresh
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.fetchIfNeeded()
            }
        }
    }

    // MARK: - Public Methods

    /// Fetch dynamic URLs from the server
    /// - Parameter completion: Completion handler called when the operation completes
    func fetchDynamicURLs(completion: @escaping (Bool) -> Void = { _ in }) {
        self.fetchIfNeeded(completion: completion)
    }

    // MARK: - Private Methods

    private func fetchIfNeeded(completion: @escaping (Bool) -> Void = { _ in }) {
        // Check if cache is still valid
        if self.isCacheValid() {
            // Cache is still valid, no need to fetch
            print("Using cached URLs (valid until \(String(describing: userDefaults.object(forKey: cacheExpirationKey) as? Date)))")
            completion(true)
            return
        }

        // Cache is expired, corrupted, or doesn't exist, fetch from server
        servicesProvider.getDownloadableContentItems()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("Failed to fetch dynamic URLs: \(error)")
                    completion(false)
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] downloadableItems in
                guard let self = self else {
                    completion(false)
                    return
                }

                // Convert downloadable items to URLEndpoint.Links
                let dynamicLinks = self.convertDownloadableItemsToLinks(downloadableItems)

                // Get current static links for merging
                let currentLinks = self.links

                // Merge with static links
                let mergedLinks = self.mergeLinks(cachedLinks: dynamicLinks, staticLinks: currentLinks)

                // Update current links (thread-safe)
                self.linksQueue.sync {
                    self._links = mergedLinks
                }

                // Cache the merged links
                self.cacheURLs(mergedLinks)

                completion(true)
            })
            .store(in: &cancellables)
    }

    /// Check if the cache is valid
    private func isCacheValid() -> Bool {
        // Check if cache exists
        guard let cachedData = userDefaults.data(forKey: cacheKey),
              let expirationDate = userDefaults.object(forKey: cacheExpirationKey) as? Date,
              let cacheVersion = userDefaults.object(forKey: cacheVersionKey) as? Int else {
            return false
        }

        // Check if cache version matches current version
        guard cacheVersion == currentCacheVersion else {
            return false
        }

        // Check if cache has expired
        guard Date() < expirationDate else {
            return false
        }

        // Check if cache data is valid by attempting to decode it
        do {
            _ = try JSONDecoder().decode(URLEndpoint.Links.self, from: cachedData)
            return true
        } catch {
            print("Cache validation failed: corrupted data - \(error)")
            return false
        }
    }

    /// Load URLs from cache if available
    /// Returns true if cache was successfully loaded, false otherwise
    private func loadCachedURLs() -> Bool {
        // Check if cache exists and is valid
        guard
            let cachedData = userDefaults.data(forKey: cacheKey),
            let expirationDate = userDefaults.object(forKey: cacheExpirationKey) as? Date,
            let cacheVersion = userDefaults.object(forKey: cacheVersionKey) as? Int,
            cacheVersion == currentCacheVersion,
            Date() < expirationDate
        else {
            return false
        }

        do {
            let cachedLinks = try JSONDecoder().decode(URLEndpoint.Links.self, from: cachedData)
            // Merge cached links with static links (thread-safe)
            self.linksQueue.sync {
                self._links = self.mergeLinks(cachedLinks: cachedLinks, staticLinks: self._links)
            }
            print("Loaded URLs from cache")
            return true
        }
        catch {
            print("Failed to decode cached URLs: \(error)")
            // Clear corrupted cache
            self.userDefaults.removeObject(forKey: cacheKey)
            self.userDefaults.removeObject(forKey: cacheExpirationKey)
            self.userDefaults.removeObject(forKey: cacheVersionKey)
            return false
        }
    }

    /// Save URLs to cache
    private func cacheURLs(_ links: URLEndpoint.Links) {
        do {
            let data = try JSONEncoder().encode(links)
            userDefaults.set(data, forKey: cacheKey)
            userDefaults.set(Date().addingTimeInterval(cacheExpirationInterval), forKey: cacheExpirationKey)
            userDefaults.set(currentCacheVersion, forKey: cacheVersionKey)
            print("URLs cached successfully")
        }
        catch {
            print("Failed to cache URLs: \(error)")
        }
    }

    /// Convert DownloadableContentItems to URLEndpoint.Links
    private func convertDownloadableItemsToLinks(_ items: DownloadableContentItems) -> URLEndpoint.Links {
        // Start with empty links
        var api = URLEndpoint.APIs.empty
        var support = URLEndpoint.Support.empty
        var responsibleGaming = URLEndpoint.ResponsibleGaming.empty
        var socialMedia = URLEndpoint.SocialMedia.empty
        var legalAndInfo = URLEndpoint.LegalAndInfo.empty

        // Map each downloadable item to the appropriate URL in the links structure
        for item in items {
            switch item.type {
                // API endpoints
            case "goma_gaming":
                api.gomaGaming = item.downloadUrl
            case "sportsbook":
                api.sportsbook = item.downloadUrl
            case "firebase":
                api.firebase = item.downloadUrl
            case "casino":
                api.casino = item.downloadUrl
            case "promotions":
                api.promotions = item.downloadUrl
            case "affiliate_system":
                api.affiliateSystem = item.downloadUrl
            case "secondary_market_specs":
                api.secundaryMarketSpecsUrl = item.downloadUrl

                // Support endpoints
            case "help_center":
                support.helpCenter = item.downloadUrl
            case "zendesk":
                support.zendesk = item.downloadUrl
            case "customer_support":
                support.customerSupport = item.downloadUrl

                // Responsible Gaming endpoints
            case "gambling_addiction_helpline":
                responsibleGaming.gamblingAddictionHelpline = item.downloadUrl
            case "gambling_blocking_software":
                responsibleGaming.gamblingBlockingSoftware = item.downloadUrl
            case "gambling_behavior_self_assessment":
                responsibleGaming.gamblingBehaviorSelfAssessment = item.downloadUrl
            case "gambling_behavior_self_assessment_quiz":
                responsibleGaming.gamblingBehaviorSelfAssessmentQuiz = item.downloadUrl
            case "time_management_app":
                responsibleGaming.timeManagementApp = item.downloadUrl
            case "gambling_addiction_support":
                responsibleGaming.gamblingAddictionSupport = item.downloadUrl
            case "gambling_authority":
                responsibleGaming.gamblingAuthority = item.downloadUrl
            case "gambling_authority_terms":
                responsibleGaming.gamblingAuthorityTerms = item.downloadUrl
            case "parental_control":
                responsibleGaming.parentalControl = item.downloadUrl
            case "addiction_treatment_center":
                responsibleGaming.addictionTreatmentCenter = item.downloadUrl
            case "self_exclusion_service":
                responsibleGaming.selfExclusionService = item.downloadUrl
            case "gambling_habits_app":
                responsibleGaming.gamblingHabitsApp = item.downloadUrl

                // Social Media endpoints
            case "facebook":
                socialMedia.facebook = item.downloadUrl
            case "twitter":
                socialMedia.twitter = item.downloadUrl
            case "youtube":
                socialMedia.youtube = item.downloadUrl
            case "instagram":
                socialMedia.instagram = item.downloadUrl

                // Legal and Info endpoints
            case "responsible_gambling":
                legalAndInfo.responsibleGambling = item.downloadUrl
            case "privacy_policy":
                legalAndInfo.privacyPolicy = item.downloadUrl
            case "cookie_policy":
                legalAndInfo.cookiePolicy = item.downloadUrl

            case "partners":
                legalAndInfo.partners = item.downloadUrl
            case "about":
                legalAndInfo.about = item.downloadUrl
            case "app_store_url":
                legalAndInfo.appStoreUrl = item.downloadUrl

            //
            // IN USE RIGHT NOW
            case "betting_rules":
                legalAndInfo.sportsBettingRules = item.downloadUrl
            case "terms_and_conditions":
                legalAndInfo.termsAndConditions = item.downloadUrl
            case "bonus_terms_and_conditions":
                legalAndInfo.bonusRules = item.downloadUrl
            //

            default:
                print("Unknown downloadable content type: \(item.type)")
            }
        }

        return URLEndpoint.Links(
            api: api,
            support: support,
            responsibleGaming: responsibleGaming,
            socialMedia: socialMedia,
            legalAndInfo: legalAndInfo
        )
    }

    /// Helper function to merge strings, preferring non-empty cached values
    private func mergeString(cached cachedString: String, static staticString: String) -> String {
        return !cachedString.isEmpty ? cachedString : staticString
    }

    /// Merge cached links with static links, preferring cached values when available
    private func mergeLinks(cachedLinks: URLEndpoint.Links, staticLinks: URLEndpoint.Links) -> URLEndpoint.Links {

        // Merge APIs
        let mergedAPI = URLEndpoint.APIs(
            gomaGaming: mergeString(
                cached: cachedLinks.api.gomaGaming,
                static: staticLinks.api.gomaGaming),
            sportsbook: mergeString(
                cached: cachedLinks.api.sportsbook,
                static: staticLinks.api.sportsbook),
            firebase: mergeString(
                cached: cachedLinks.api.firebase,
                static: staticLinks.api.firebase),
            casino: mergeString(
                cached: cachedLinks.api.casino,
                static: staticLinks.api.casino),
            promotions: mergeString(
                cached: cachedLinks.api.promotions,
                static: staticLinks.api.promotions),
            affiliateSystem: mergeString(
                cached: cachedLinks.api.affiliateSystem,
                static: staticLinks.api.affiliateSystem),
            secundaryMarketSpecsUrl: mergeString(
                cached: cachedLinks.api.secundaryMarketSpecsUrl,
                static: staticLinks.api.secundaryMarketSpecsUrl)
        )

        // Merge Support
        let mergedSupport = URLEndpoint.Support(
            helpCenter: mergeString(
                cached: cachedLinks.support.helpCenter,
                static: staticLinks.support.helpCenter),
            zendesk: mergeString(
                cached: cachedLinks.support.zendesk,
                static: staticLinks.support.zendesk),
            customerSupport: mergeString(
                cached: cachedLinks.support.customerSupport,
                static: staticLinks.support.customerSupport)
        )

        // Merge ResponsibleGaming
        let mergedResponsibleGaming = URLEndpoint.ResponsibleGaming(
            gamblingAddictionHelpline: mergeString(
                cached: cachedLinks.responsibleGaming.gamblingAddictionHelpline,
                static: staticLinks.responsibleGaming.gamblingAddictionHelpline),
            gamblingBlockingSoftware: mergeString(
                cached: cachedLinks.responsibleGaming.gamblingBlockingSoftware,
                static: staticLinks.responsibleGaming.gamblingBlockingSoftware),
            gamblingBehaviorSelfAssessment: mergeString(
                cached: cachedLinks.responsibleGaming.gamblingBehaviorSelfAssessment,
                static: staticLinks.responsibleGaming.gamblingBehaviorSelfAssessment),
            gamblingBehaviorSelfAssessmentQuiz: mergeString(
                cached: cachedLinks.responsibleGaming.gamblingBehaviorSelfAssessmentQuiz,
                static: staticLinks.responsibleGaming.gamblingBehaviorSelfAssessmentQuiz),
            timeManagementApp: mergeString(
                cached: cachedLinks.responsibleGaming.timeManagementApp,
                static: staticLinks.responsibleGaming.timeManagementApp),
            gamblingAddictionSupport: mergeString(
                cached: cachedLinks.responsibleGaming.gamblingAddictionSupport,
                static: staticLinks.responsibleGaming.gamblingAddictionSupport),
            gamblingAuthority: mergeString(
                cached: cachedLinks.responsibleGaming.gamblingAuthority,
                static: staticLinks.responsibleGaming.gamblingAuthority),
            gamblingAuthorityTerms: mergeString(
                cached: cachedLinks.responsibleGaming.gamblingAuthorityTerms,
                static: staticLinks.responsibleGaming.gamblingAuthorityTerms),
            parentalControl: mergeString(
                cached: cachedLinks.responsibleGaming.parentalControl,
                static: staticLinks.responsibleGaming.parentalControl),
            addictionTreatmentCenter: mergeString(
                cached: cachedLinks.responsibleGaming.addictionTreatmentCenter,
                static: staticLinks.responsibleGaming.addictionTreatmentCenter),
            selfExclusionService: mergeString(
                cached: cachedLinks.responsibleGaming.selfExclusionService,
                static: staticLinks.responsibleGaming.selfExclusionService),
            gamblingHabitsApp: mergeString(
                cached: cachedLinks.responsibleGaming.gamblingHabitsApp,
                static: staticLinks.responsibleGaming.gamblingHabitsApp)
        )

        // Merge SocialMedia
        let mergedSocialMedia = URLEndpoint.SocialMedia(
            facebook: mergeString(
                cached: cachedLinks.socialMedia.facebook,
                static: staticLinks.socialMedia.facebook),
            twitter: mergeString(
                cached: cachedLinks.socialMedia.twitter,
                static: staticLinks.socialMedia.twitter),
            youtube: mergeString(
                cached: cachedLinks.socialMedia.youtube,
                static: staticLinks.socialMedia.youtube),
            instagram: mergeString(
                cached: cachedLinks.socialMedia.instagram,
                static: staticLinks.socialMedia.instagram)
        )

        // Merge LegalAndInfo
        let mergedLegalAndInfo = URLEndpoint.LegalAndInfo(
            responsibleGambling: mergeString(
                cached: cachedLinks.legalAndInfo.responsibleGambling,
                static: staticLinks.legalAndInfo.responsibleGambling),
            privacyPolicy: mergeString(
                cached: cachedLinks.legalAndInfo.privacyPolicy,
                static: staticLinks.legalAndInfo.privacyPolicy),
            cookiePolicy: mergeString(
                cached: cachedLinks.legalAndInfo.cookiePolicy,
                static: staticLinks.legalAndInfo.cookiePolicy),
            sportsBettingRules: mergeString(
                cached: cachedLinks.legalAndInfo.sportsBettingRules,
                static: staticLinks.legalAndInfo.sportsBettingRules),
            termsAndConditions: mergeString(
                cached: cachedLinks.legalAndInfo.termsAndConditions,
                static: staticLinks.legalAndInfo.termsAndConditions),
            bonusRules: mergeString(
                cached: cachedLinks.legalAndInfo.bonusRules,
                static: staticLinks.legalAndInfo.bonusRules),
            partners: mergeString(
                cached: cachedLinks.legalAndInfo.partners,
                static: staticLinks.legalAndInfo.partners),
            about: mergeString(
                cached: cachedLinks.legalAndInfo.about,
                static: staticLinks.legalAndInfo.about),
            appStoreUrl: mergeString(
                cached: cachedLinks.legalAndInfo.appStoreUrl,
                static: staticLinks.legalAndInfo.appStoreUrl)
        )

        return URLEndpoint.Links(
            api: mergedAPI,
            support: mergedSupport,
            responsibleGaming: mergedResponsibleGaming,
            socialMedia: mergedSocialMedia,
            legalAndInfo: mergedLegalAndInfo
        )
    }
}
