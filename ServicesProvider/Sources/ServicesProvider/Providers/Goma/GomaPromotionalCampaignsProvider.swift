//
//  GomaPromotionalCampaignsProvider.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 21/04/2025.
//

import Foundation
import Combine

class GomaPromotionalCampaignsProvider: PromotionalCampaignsProvider {
    
    private let authenticator: GomaAPIAuthenticator
    private let apiClient: GomaPromotionalCampaignsAPIClient
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(authenticator: GomaAPIAuthenticator,
         apiClient: GomaPromotionalCampaignsAPIClient) {
        self.authenticator = authenticator
        self.apiClient = apiClient
    }
    
    convenience init(authenticator: GomaAPIAuthenticator = GomaAPIAuthenticator(deviceIdentifier: "")) {
        let connector = GomaConnector(authenticator: authenticator)
        let apiClient = GomaPromotionalCampaignsAPIClient(connector: connector)
        self.init(authenticator: authenticator, apiClient: apiClient)
    }
    
    func getPromotions() -> AnyPublisher<[PromotionInfo], ServiceProviderError> {
        
        return self.apiClient.getPromotions().map({ promotionsInfo in
            let convertedPromotionsResponse = promotionsInfo.map({
                GomaModelMapper.promotionInfo(fromInternalPromotionInfo: $0)
            })
            return convertedPromotionsResponse
        }).eraseToAnyPublisher()
    }
    
    func getPromotionDetails(promotionSlug: String, staticPageSlug: String) -> AnyPublisher<PromotionInfo, ServiceProviderError> {
        return self.apiClient.getPromotionDetails(promotionSlug: promotionSlug, staticPageSlug: staticPageSlug)
            .map({ promotionInfo in
                let convertedPromotionsResponse = GomaModelMapper.promotionInfo(fromInternalPromotionInfo: promotionInfo)
                return convertedPromotionsResponse
            }).eraseToAnyPublisher()
    }
}
