//
//  PromotionsViewModel.swift
//  BetssonCameroonApp
//
//  Created by Claude on 29/08/2025.
//

import Foundation
import Combine
import ServicesProvider
import GomaUI

class PromotionsViewModel {
    
    var promotions: [PromotionInfo] = []
    var categories: [PromotionCategory] = []
    var promotionsCacheCardViewModel: [Int: PromotionCardViewModelProtocol] = [:]
    var promotionalHeaderViewModel: PromotionalHeaderViewModelProtocol?
    var promotionSelectorBarViewModel: PromotionSelectorBarViewModelProtocol?
    
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Navigation Callbacks
    var onDismiss: (() -> Void)?
    var onCategorySelected: ((String?) -> Void)?
    
    let servicesProvider: ServicesProvider.Client
    
    init(servicesProvider: ServicesProvider.Client) {
        self.servicesProvider = servicesProvider
        self.setupPromotionalHeaderViewModel()
        self.setupPromotionSelectorBarViewModel()
        self.getPromotions()
    }
    
    private func getPromotions() {
        
        self.isLoadingPublisher.send(true)
        
        servicesProvider.getPromotions()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                
                switch completion {
                case .finished:
                    print("FINISHED GET PROMOTIONS")
                case .failure(let error):
                    print("ERROR GET PROMOTIONS: \(error)")
                }
                
                self?.isLoadingPublisher.send(false)

            }, receiveValue: { [weak self] promotionsInfo in
                
                self?.promotions = promotionsInfo
                self?.extractCategories(from: promotionsInfo)
            })
            .store(in: &cancellables)
    }
    
    func cardViewModel(forIndex index: Int) -> PromotionCardViewModelProtocol? {
        guard let promotion = self.promotions[safe: index] else {
            return nil
        }

        if let cachedCardViewModel = self.promotionsCacheCardViewModel[promotion.id] {
            return cachedCardViewModel
        }
        else {
            let cardData = PromotionCardData(
                id: String(promotion.id),
                title: promotion.title,
                description: promotion.listDisplayDescription ?? "",
                imageURL: promotion.listDisplayImageUrl,
                tag: promotion.tag,
                ctaText: promotion.ctaText,
                ctaURL: promotion.ctaUrl,
                showReadMoreButton: promotion.hasReadMoreButton
            )
            
            let cardViewModel = MockPromotionCardViewModel(cardData: cardData)
            self.promotionsCacheCardViewModel[promotion.id] = cardViewModel
            return cardViewModel
        }
    }
    
    private func setupPromotionalHeaderViewModel() {
        let headerData = PromotionalHeaderData(
            id: "promotions_bonuses",
            icon: "gift.fill",
            title: "Promotions & Bonuses",
            subtitle: nil
        )
        self.promotionalHeaderViewModel = MockPromotionalHeaderViewModel(headerData: headerData)
    }
    
    private func setupPromotionSelectorBarViewModel() {
        // Create initial empty selector bar ViewModel
        let initialData = PromotionSelectorBarData(
            id: "promotion-categories",
            promotionItems: [],
            selectedPromotionId: nil
        )
        self.promotionSelectorBarViewModel = MockPromotionSelectorBarViewModel(barData: initialData)
        
        self.promotionSelectorBarViewModel?.selectionEventPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] selectionEvent in
                print("SELECTION EVENT: \(selectionEvent)")
                self?.onCategorySelected?(selectionEvent.selectedId)
            })
            .store(in: &cancellables)
    }
    
    private func extractCategories(from promotions: [PromotionInfo]) {
        // Extract unique categories from all promotions
        let allCategories = Set(promotions.compactMap { $0.categories }.flatMap { $0 })
        
        // Sort categories by ID
        self.categories = Array(allCategories).sorted { $0.id < $1.id }
        
        // Update the selector bar ViewModel with categories
        updatePromotionSelectorBar()
    }
    
    private func updatePromotionSelectorBar() {
        // Create category items for the selector bar
        var categoryItems: [PromotionItemData] = []
        
        // Add category items only
        for category in self.categories {
            let item = PromotionItemData(
                id: String(category.id),
                title: category.name,
                isSelected: false
            )
            categoryItems.append(item)
        }
        
        // Update the selector bar ViewModel
        let barData = PromotionSelectorBarData(
            id: "promotion-categories",
            promotionItems: categoryItems,
            selectedPromotionId: categoryItems.first?.id // Select first category by default
        )
        
        self.promotionSelectorBarViewModel?.updateBarData(barData)
    }
    
    func getPromotions(for categoryId: String?) -> [PromotionInfo] {
        guard let categoryId = categoryId else {
            return self.promotions
        }
        
        return self.promotions.filter { promotion in
            promotion.categories?.contains { String($0.id) == categoryId } == true
        }
    }
    
    func didTapBack() {
        onDismiss?()
    }
}
