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
    var grantedBonusesCacheCardViewModel: [String: BonusInfoCardViewModelProtocol] = [:]
    
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Display Type
    let displayType: BonusDisplayType
    
    // MARK: - Selected Tab
    private var selectedBonusTab: BonusTab = .available
    
    // MARK: - ViewModels
    var bonusSelectorBarViewModel: PromotionSelectorBarViewModelProtocol?
    var depositWithoutBonusButtonViewModel: ButtonViewModelProtocol
    var refreshButtonViewModel: ButtonViewModelProtocol
    
    // MARK: - Navigation Callbacks
    var onNavigateBack: (() -> Void) = { }
    var onBonusURLOpened: ((String?) -> Void)?
    var onTermsURLRequested: ((String?) -> Void)?
    var onDepositWithoutBonus: (() -> Void)?
    var onBonusTabSelected: ((BonusTab) -> Void)?
    var onDepositBonus: ((String) -> Void)?
    
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
        
        // Initialize refresh button ViewModel
        let refreshButtonData = ButtonData(
            id: "refresh_bonuses",
            title: localized("refresh"),
            style: .solidBackground,
            backgroundColor: StyleProvider.Color.highlightPrimary,
            isEnabled: true
        )
        self.refreshButtonViewModel = MockButtonViewModel(buttonData: refreshButtonData)
        
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
    
    func refreshBonuses() {
        loadBonuses()
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
                return nil // Granted bonuses use different view model type
            }
        }
    }
    
    func grantedCardViewModel(forIndex index: Int) -> BonusInfoCardViewModelProtocol? {
        return grantedBonusInfoCardViewModel(forIndex: index)
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
    
    func getBonusTabSelection() -> BonusTab {
        return selectedBonusTab
    }
    
    private func availableBonusCardViewModel(forIndex index: Int) -> BonusCardViewModelProtocol? {
        guard let bonus = self.bonuses[safe: index] else {
            return nil
        }

        // Check cache first
        if let cachedCardViewModel = self.bonusesCacheCardViewModel[bonus.bonusPlanId] {
            // Setup callbacks for cached view model
            return cachedCardViewModel
        }
        else {
            // Create new view model
            let cardData = BonusCardData(
                id: bonus.id,
                title: bonus.name,
                description: bonus.description ?? "",
                imageURL: bonus.imageUrl ?? "",
                tag: bonus.type,
                ctaText: localized("opt_in_and_deposit"),
                ctaURL: bonus.code,
                termsText: localized("terms_and_conditions"),
                termsURL: bonus.actionUrl
            )
            
            let cardViewModel = MockBonusCardViewModel(cardData: cardData)
            
            cardViewModel.onCTATapped = { [weak self] actionString in
                self?.onDepositBonus?(actionString ?? "")
            }
            
            cardViewModel.onTermsTapped = { [weak self] termsString in
                self?.onBonusURLOpened?(termsString)
            }
            
            self.bonusesCacheCardViewModel[bonus.bonusPlanId] = cardViewModel
            return cardViewModel
        }
    }
    
    private func grantedBonusInfoCardViewModel(forIndex index: Int) -> BonusInfoCardViewModelProtocol? {
        guard let grantedBonus = self.grantedBonuses[safe: index] else {
            return nil
        }

        let bonusIdString = String(grantedBonus.id)
        if let cachedCardViewModel = self.grantedBonusesCacheCardViewModel[bonusIdString] {
            return cachedCardViewModel
        }
        else {
            // Parse amounts from strings
            let bonusAmount = parseAmount(grantedBonus.amount)
            let remainingAmount = parseAmount(grantedBonus.remainingAmount ?? "0")
            let wagerRequirement = parseAmount(grantedBonus.wagerRequirement ?? "0")
            let remainingToWager = parseAmount(grantedBonus.amountWagered ?? "0")
            
            let currency = grantedBonus.currency
            
            // Determine status
            let status: BonusStatus = grantedBonus.status.lowercased() == "released" ? .released : .active
            
            // Format expiry date
            let expiryText = formatExpiryDate(grantedBonus.expiryDate)
            
            let cardData = BonusInfoCardData(
                id: bonusIdString,
                title: grantedBonus.name,
                subtitle: grantedBonus.type,
                status: status,
                headerImageURL: grantedBonus.imageUrl,
                bonusAmountType: .simple,
                bonusAmount: bonusAmount,
                remainingAmount: remainingAmount,
                currency: currency ?? (Env.userSessionStore.userProfilePublisher.value?.currency ?? ""),
                initialWagerAmount: wagerRequirement,
                remainingToWagerAmount: remainingToWager,
                expiryText: expiryText,
                actionUrl: grantedBonus.linkUrl
            )
            
            let cardViewModel = MockBonusInfoCardViewModel(cardData: cardData)
            
            // Setup callback for terms button
            cardViewModel.onTermsTapped = { [weak self] actionUrl in
                self?.onTermsURLRequested?(actionUrl)
            }
            
            self.grantedBonusesCacheCardViewModel[bonusIdString] = cardViewModel
            return cardViewModel
        }
    }
    
    // MARK: - Helper Methods
    
    private func parseAmount(_ amountString: String) -> Double {
        // Remove currency symbols and spaces, then parse
        let cleanString = amountString
            .replacingOccurrences(of: "[^0-9.,]", with: "", options: .regularExpression)
            .replacingOccurrences(of: ",", with: ".")
        return Double(cleanString) ?? 0.0
    }
    
    private func formatExpiryDate(_ date: Date?) -> String {
        guard let date = date else {
            return "No expiry"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE dd/MM - HH:mm"
        return formatter.string(from: date)
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
        
        // Setup refresh button callback
        refreshButtonViewModel.onButtonTapped = { [weak self] in
            self?.refreshBonuses()
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
