//
//  GomaPromotionalCampaignsProvider.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 21/04/2025.
//

import Foundation
import Combine

class GomaPromotionalCampaignsProvider: PromotionalCampaignsProvider {
    
    private let authenticator: GomaAuthenticator
    private let apiClient: GomaPromotionalCampaignsAPIClient
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(authenticator: GomaAuthenticator,
         apiClient: GomaPromotionalCampaignsAPIClient) {
        self.authenticator = authenticator
        self.apiClient = apiClient
    }
    
    convenience init(authenticator: GomaAuthenticator = GomaAuthenticator(deviceIdentifier: "")) {
        let connector = GomaConnector(authenticator: authenticator)
        let apiClient = GomaPromotionalCampaignsAPIClient(connector: connector)
        self.init(authenticator: authenticator, apiClient: apiClient)
    }
    
    func getPromotions(language: String?) -> AnyPublisher<[PromotionInfo], ServiceProviderError> {
        
        return self.apiClient.getPromotions(language: language).map({ promotionsInfo in
            let convertedPromotionsResponse = promotionsInfo.map({
                GomaModelMapper.promotionInfo(fromInternalPromotionInfo: $0)
            })
            return convertedPromotionsResponse
        }).eraseToAnyPublisher()
    }
    
    func getPromotionDetails(promotionSlug: String, staticPageSlug: String, language: String?) -> AnyPublisher<PromotionInfo, ServiceProviderError> {
        return self.apiClient.getPromotionDetails(promotionSlug: promotionSlug, staticPageSlug: staticPageSlug, language: language)
            .map({ promotionInfo in
                let convertedPromotionsResponse = GomaModelMapper.promotionInfo(fromInternalPromotionInfo: promotionInfo)
                return convertedPromotionsResponse
            }).eraseToAnyPublisher()
    }
}
