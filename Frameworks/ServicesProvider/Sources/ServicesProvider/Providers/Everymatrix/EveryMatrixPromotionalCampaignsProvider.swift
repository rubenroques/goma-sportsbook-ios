import Foundation
import Combine

/// Implementation of PromotionalCampaignsProvider for the EveryMatrix API
/// Delegates to Goma CMS for promotional content since EveryMatrix doesn't have its own CMS
class EveryMatrixPromotionalCampaignsProvider: PromotionalCampaignsProvider {

    // MARK: - Properties
    private let gomaPromotionalCampaignsProvider: GomaPromotionalCampaignsProvider

    // MARK: - Initialization
    init(gomaPromotionalCampaignsProvider: GomaPromotionalCampaignsProvider) {
        self.gomaPromotionalCampaignsProvider = gomaPromotionalCampaignsProvider
    }

    // MARK: - PromotionalCampaignsProvider Implementation
    // All methods delegate to GomaPromotionalCampaignsProvider for CMS data

    func getPromotions() -> AnyPublisher<[PromotionInfo], ServiceProviderError> {
        return gomaPromotionalCampaignsProvider.getPromotions()
    }

    func getPromotionDetails(promotionSlug: String, staticPageSlug: String) -> AnyPublisher<PromotionInfo, ServiceProviderError> {
        return gomaPromotionalCampaignsProvider.getPromotionDetails(promotionSlug: promotionSlug, staticPageSlug: staticPageSlug)
    }
}
