//
//  GomaAPIDownloadableContentClient.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 14/03/2025.
//


//
//  GomaAPIDownloadableContentClient.swift
//
//

import Foundation
import Combine

/// Client for interacting with the Goma Promotions API
class GomaPromotionalCampaignsAPIClient {

    // MARK: - Properties

    /// The connector for handling authenticated requests
    private let connector: GomaConnector

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /// Initialize the client with a connector for request handling and cache
    /// - Parameters:
    ///   - connector: The GomaConnector to use for authenticated requests
    ///   - cache: The cache instance to use for storing promotional content
    init(connector: GomaConnector) {
        self.connector = connector
    }
        /// Get downloadable content
    /// - Returns: A publisher with the decoded response or error
    func downloadableContents() -> AnyPublisher<[GomaModels.DownloadableContent], ServiceProviderError> {
        let endpoint = GomaAPIDownloadableContentSchema.downloadableContents
        return self.connector.request(endpoint)
    }
    
    func getPromotions() -> AnyPublisher<[GomaModels.PromotionInfo], ServiceProviderError> {
        let endpoint = GomaPromotionalCampaignsSchema.allPromotions
        let publisher: AnyPublisher<[GomaModels.PromotionInfo], ServiceProviderError> = self.connector.request(endpoint)
        return publisher.eraseToAnyPublisher()
    }

    func getPromotionDetails(promotionSlug: String, staticPageSlug: String) -> AnyPublisher<GomaModels.PromotionInfo, ServiceProviderError> {
        let endpoint = GomaPromotionalCampaignsSchema.promotionDetails(promotionSlug: promotionSlug, staticPageSlug: staticPageSlug)
        let publisher: AnyPublisher<GomaModels.PromotionInfo, ServiceProviderError> = self.connector.request(endpoint)
        return publisher.eraseToAnyPublisher()
    }
    
}
