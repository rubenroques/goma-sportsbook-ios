//
//  BonusViewModel.swift
//  BetssonCameroonApp
//
//  Created by Claude on 23/10/2025.
//

import Foundation
import Combine
import ServicesProvider
import GomaUI

class BonusViewModel {
    
    var bonuses: [AvailableBonus] = []
    var grantedBonuses: [GrantedBonus] = []
    var bonusesCacheCardViewModel: [Int: BonusCardViewModelProtocol] = [:]
    var grantedBonusesCacheCardViewModel: [String: BonusCardViewModelProtocol] = [:]
    
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Display Type
    let displayType: BonusDisplayType
    
    // MARK: - Selected Tab
    private var selectedBonusTab: BonusTab = .available
    
    // MARK: - ViewModels
    var bonusSelectorBarViewModel: PromotionSelectorBarViewModelProtocol?
    var depositWithoutBonusButtonViewModel: ButtonViewModelProtocol
    
    // MARK: - Navigation Callbacks
    var onNavigateBack: (() -> Void) = { }
    var onBonusURLOpened: ((String?) -> Void)?
    var onTermsURLRequested: ((String?) -> Void)?
    var onDepositWithoutBonus: (() -> Void)?
    var onBonusTabSelected: ((BonusTab) -> Void)?
    
    let servicesProvider: ServicesProvider.Client
    
    init(servicesProvider: ServicesProvider.Client, displayType: BonusDisplayType) {
        self.servicesProvider = servicesProvider
        self.displayType = displayType
        
        // Initialize deposit without bonus button ViewModel
        let depositButtonData = ButtonData(
            id: "deposit_without_bonus",
            title: localized("deposit_without_bonus"),
            style: .bordered,
            backgroundColor: .clear,
            disabledBackgroundColor: .clear,
            borderColor: StyleProvider.Color.highlightPrimary,
            textColor: StyleProvider.Color.highlightPrimary,
            isEnabled: true
        )
        self.depositWithoutBonusButtonViewModel = MockButtonViewModel(buttonData: depositButtonData)
        
        // Setup selector bar for history type
        if displayType == .history {
            self.setupBonusSelectorBarViewModel()
        }
        
        self.setupButtonCallbacks()
        self.loadBonuses()
    }
    
    private func setupBonusSelectorBarViewModel() {
        let availableItem = PromotionItemData(
            id: BonusTab.available.rawValue,
            title: localized("available_bonus"),
            isSelected: true
        )
        
        let grantedItem = PromotionItemData(
            id: BonusTab.granted.rawValue,
            title: localized("granted_bonus"),
            isSelected: false
        )
        
        let barData = PromotionSelectorBarData(
            id: "bonus-tabs",
            promotionItems: [availableItem, grantedItem],
            selectedPromotionId: BonusTab.available.rawValue
        )
        
        self.bonusSelectorBarViewModel = MockPromotionSelectorBarViewModel(barData: barData)
        
        self.bonusSelectorBarViewModel?.selectionEventPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] selectionEvent in
                if let tab = BonusTab(rawValue: selectionEvent.selectedId) {
                    self?.selectedBonusTab = tab
                    self?.onBonusTabSelected?(tab)
                }
            })
            .store(in: &cancellables)
    }
    
    private func loadBonuses() {
        switch displayType {
        case .register:
            getAvailableBonuses()
        case .history:
            loadAllBonuses()
        }
    }
    
    private func loadAllBonuses() {
        self.isLoadingPublisher.send(true)
        
        let availableBonusesPublisher = servicesProvider.getAvailableBonuses()
        let grantedBonusesPublisher = servicesProvider.getGrantedBonuses()
        
        Publishers.Zip(availableBonusesPublisher, grantedBonusesPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished: print("FINISHED GET ALL BONUSES")
                case .failure(let error): print("ERROR GET ALL BONUSES: \(error)")
                }
                self?.isLoadingPublisher.send(false)
            }, receiveValue: { [weak self] (availableBonuses, grantedBonuses) in
                self?.bonuses = availableBonuses
                self?.grantedBonuses = grantedBonuses
            })
            .store(in: &cancellables)
    }
    
    private func getAvailableBonuses() {
        self.isLoadingPublisher.send(true)

        servicesProvider.getAvailableBonuses()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished: print("FINISHED GET AVAILABLE BONUSES")
                case .failure(let error): print("ERROR GET AVAILABLE BONUSES: \(error)")
                }
                self?.isLoadingPublisher.send(false)
            }, receiveValue: { [weak self] bonusesInfo in
                self?.bonuses = bonusesInfo
            })
            .store(in: &cancellables)
    }
    
    
    func cardViewModel(forIndex index: Int) -> BonusCardViewModelProtocol? {
        switch displayType {
        case .register:
            return availableBonusCardViewModel(forIndex: index)
        case .history:
            // Use selected tab for history type
            switch selectedBonusTab {
            case .available:
                return availableBonusCardViewModel(forIndex: index)
            case .granted:
                return grantedBonusCardViewModel(forIndex: index)
            }
        }
    }
    
    func getBonusCount() -> Int {
        switch displayType {
        case .register:
            return bonuses.count
        case .history:
            switch selectedBonusTab {
            case .available:
                return bonuses.count
            case .granted:
                return grantedBonuses.count
            }
        }
    }
    
    private func availableBonusCardViewModel(forIndex index: Int) -> BonusCardViewModelProtocol? {
        guard let bonus = self.bonuses[safe: index] else {
            return nil
        }

        if let cachedCardViewModel = self.bonusesCacheCardViewModel[bonus.bonusPlanId] {
            return cachedCardViewModel
        } else {
            let cardData = BonusCardData(
                id: bonus.id,
                title: bonus.name,
                description: bonus.description ?? "",
                imageURL: bonus.imageUrl ?? "",
                tag: bonus.type,
                ctaText: localized("opt_in_and_deposit"),
                ctaURL: nil,
                termsText: localized("terms_and_conditions"),
                termsURL: bonus.actionUrl
            )
            
            let cardViewModel = MockBonusCardViewModel(cardData: cardData)
            self.bonusesCacheCardViewModel[bonus.bonusPlanId] = cardViewModel
            return cardViewModel
        }
    }
    
    private func grantedBonusCardViewModel(forIndex index: Int) -> BonusCardViewModelProtocol? {
        guard let grantedBonus = self.grantedBonuses[safe: index] else {
            return nil
        }

        let bonusIdString = String(grantedBonus.id)
        if let cachedCardViewModel = self.grantedBonusesCacheCardViewModel[bonusIdString] {
            return cachedCardViewModel
        } else {
            // Build description with available information
            var descriptionParts: [String] = []
            if !grantedBonus.amount.isEmpty {
                descriptionParts.append("Amount: \(grantedBonus.amount)")
            }
            if let wagerReq = grantedBonus.wagerRequirement, !wagerReq.isEmpty {
                descriptionParts.append("Wager: \(wagerReq)")
            }
            let description = descriptionParts.isEmpty ? "Active bonus" : descriptionParts.joined(separator: " • ")
            
            let cardData = BonusCardData(
                id: bonusIdString,
                title: grantedBonus.name,
                description: description,
                imageURL: "",
                tag: grantedBonus.triggerDate?.toString(),
                ctaText: grantedBonus.name,
                ctaURL: nil,
                termsText: "Status: \(grantedBonus.status)",
                termsURL: nil
            )
            
            let cardViewModel = MockBonusCardViewModel(cardData: cardData)
            self.grantedBonusesCacheCardViewModel[bonusIdString] = cardViewModel
            return cardViewModel
        }
    }
    
    func navigateBack() {
        onNavigateBack()
    }
    
    func openBonusURL(urlString: String?) {
        onBonusURLOpened?(urlString)
    }
    
    func openTermsURL(urlString: String?) {
        onTermsURLRequested?(urlString)
    }
    
    func depositWithoutBonus() {
        onDepositWithoutBonus?()
    }
    
    // MARK: - Private Methods
    private func setupButtonCallbacks() {
        // Setup deposit without bonus button callback
        depositWithoutBonusButtonViewModel.onButtonTapped = { [weak self] in
            self?.depositWithoutBonus()
        }
    }
}

enum BonusDisplayType {
    case register
    case history
}

enum BonusTab: String {
    case available = "available"
    case granted = "granted"
}
