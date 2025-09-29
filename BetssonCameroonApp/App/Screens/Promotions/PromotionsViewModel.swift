//
//  PromotionsViewModel.swift
//  BetssonCameroonApp
//
//  Created by Claude on 29/08/2025.
//

import Foundation
import Combine
import ServicesProvider

class PromotionsViewModel {
    
    var promotions: [PromotionInfo] = []
    var promotionsCacheCellViewModel: [Int: PromotionCellViewModel] = [:]
    
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Navigation Callbacks
    var onDismiss: (() -> Void)?
    
    let servicesProvider: ServicesProvider.Client
    
    init(servicesProvider: ServicesProvider.Client) {
        self.servicesProvider = servicesProvider
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
            })
            .store(in: &cancellables)
    }
    
    func viewModel(forIndex index: Int) -> PromotionCellViewModel? {
        guard
            let promotion = self.promotions[safe: index]
        else {
            return nil
        }

        if let promotionCellViewModel = self.promotionsCacheCellViewModel[promotion.id] {
            return promotionCellViewModel
        }
        else {
            
            let promotionCellViewModel = PromotionCellViewModel(promotionInfo: promotion)
            self.promotionsCacheCellViewModel[promotion.id] = promotionCellViewModel
            return promotionCellViewModel
        }
    }
    
    func didTapBack() {
        onDismiss?()
    }
}
