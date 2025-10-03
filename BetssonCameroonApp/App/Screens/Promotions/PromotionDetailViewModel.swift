//
//  PromotionDetailViewModel.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 02/10/2025.
//

import Foundation
import Combine
import GomaUI
import ServicesProvider

class PromotionDetailViewModel {
    
    var promotion: PromotionInfo
    
    var promotionDetailsPublisher: CurrentValueSubject<PromotionInfo?, Never> = .init(nil)
    
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Navigation Callbacks
    var onDismiss: (() -> Void)?
    
    private let servicesProvider: ServicesProvider.Client
    
    init(promotion: PromotionInfo, servicesProvider: ServicesProvider.Client) {
        self.promotion = promotion
        self.servicesProvider = servicesProvider
        
        self.getPromotionDetails()
    }
    
    private func getPromotionDetails() {
        self.isLoadingPublisher.send(true)
        
        if let staticPageSlug = promotion.staticPageSlug {
            servicesProvider.getPromotionDetails(promotionSlug: self.promotion.slug, staticPageSlug: staticPageSlug)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    
                    switch completion {
                    case .finished:
                        print("FINISHED GET PROMOTION DETAILS")
                    case .failure(let error):
                        print("ERROR GET PROMOTION DETAILS: \(error)")
                    }
                    
                    self?.isLoadingPublisher.send(false)

                }, receiveValue: { [weak self] promotionsInfo in
                    
                    self?.promotionDetailsPublisher.send(promotionsInfo)
                                        
                })
                .store(in: &cancellables)
        }
    }
}
