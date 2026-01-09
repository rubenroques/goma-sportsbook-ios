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
    
    // MARK: - Child ViewModels
    let quickLinksTabBarViewModel: QuickLinksTabBarViewModel
    
    // MARK: - Navigation Callbacks
    var onDismiss: (() -> Void)?
    var onCasinoQuickLinkSelected: ((QuickLinkType) -> Void)?
    
    private let servicesProvider: ServicesProvider.Client
    
    init(promotion: PromotionInfo, servicesProvider: ServicesProvider.Client) {
        self.promotion = promotion
        self.servicesProvider = servicesProvider
        // Create QuickLinks ViewModel for sports screens (same as PromotionsViewController)
        self.quickLinksTabBarViewModel = QuickLinksTabBarViewModel.forSportsScreens()
        
        self.getPromotionDetails()
        self.setupBindings()
    }
    
    private func setupBindings() {
        // Setup QuickLinks navigation callback
        quickLinksTabBarViewModel.onQuickLinkSelected = { [weak self] quickLinkType in
            // Ignore promo quickLink, we are already here
            if quickLinkType == .promos {
                self?.onDismiss?()
            }
            else {
                self?.onCasinoQuickLinkSelected?(quickLinkType)
            }
        }
    }
    
    private func getPromotionDetails() {
        self.isLoadingPublisher.send(true)
        
        let language = LanguageManager.shared.currentLanguageCode

        if let staticPageSlug = promotion.staticPageSlug {
            servicesProvider.getPromotionDetails(promotionSlug: self.promotion.slug, staticPageSlug: staticPageSlug, language: language)
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
