//
//  PromotionalCampaignsProvider.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 21/04/2025.
//

import Foundation
import Combine

protocol PromotionalCampaignsProvider {
    
    func getPromotions(language: String?) -> AnyPublisher<[PromotionInfo], ServiceProviderError>
    
    func getPromotionDetails(promotionSlug: String, staticPageSlug: String, language: String?) -> AnyPublisher<PromotionInfo, ServiceProviderError>
    
}
