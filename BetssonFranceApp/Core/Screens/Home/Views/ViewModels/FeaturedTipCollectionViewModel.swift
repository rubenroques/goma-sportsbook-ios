//
//  FeaturedTipCollectionViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 01/09/2022.
//

import Foundation
import Combine
import ServicesProvider
import Extensions

class FeaturedTipCollectionViewModel {

    var shouldShowBetslip: (() -> Void)?
    
    private enum DataType {
        case featuredTip(FeaturedTip)
        case suggestedBetslip(SuggestedBetslip)
    }
    private var dataType: DataType
    
    enum SizeType {
        case small
        case fullscreen
    }
    var sizeType: SizeType
    
    var selectionViewModels: [FeaturedTipSelectionViewModel] = []
    
    var totalOddPulisher: AnyPublisher<String, Never> {
        return self.totalOddSubject.eraseToAnyPublisher()
    }
    private var totalOddSubject: CurrentValueSubject<String, Never> = .init("1,0")
    
    private var totalOddCancelable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    init(featuredTip: FeaturedTip, sizeType: SizeType) {
        self.dataType = .featuredTip(featuredTip)
        self.sizeType = sizeType
        self.commonInit()
    }

    init(suggestedBetslip: SuggestedBetslip, sizeType: SizeType) {
        self.dataType = .suggestedBetslip(suggestedBetslip)
        self.sizeType = sizeType
        self.commonInit()
    }
    
    private func commonInit() {
        self.generateSelectionViewModels()
        
        self.totalOddCancelable?.cancel()
        self.totalOddCancelable = nil
        
        self.totalOddCancelable = self.selectionViewModels.map { $0.oddPublisher }
            .combineLatest()
            .map({ odds in
                let totalOdd = odds.reduce(1.0, *)
                return OddFormatter.formatOdd(withValue: totalOdd)
            })
            .sink { [weak self] newOddFormatted in
                self?.totalOddSubject.send(newOddFormatted)
            }
    }
    
    private func generateSelectionViewModels() {
        
        switch self.dataType {
        case .featuredTip(let featuredTip):
            self.selectionViewModels = (featuredTip.selections ?? []).map(FeaturedTipSelectionViewModel.init(featuredTipSelection:))
            self.selectionViewModels = []
            for selection in (featuredTip.selections ?? []) {
                self.selectionViewModels.append(FeaturedTipSelectionViewModel.init(featuredTipSelection: selection))
            }
            
        case .suggestedBetslip(let suggestedBetslip):
            self.selectionViewModels = []
            for (_, selection) in suggestedBetslip.selections.enumerated() {
                self.selectionViewModels.append(FeaturedTipSelectionViewModel.init(suggestedBetslipSelection: selection))
            }
            
        }
    }
    
    var identifier: String {
        switch self.dataType {
        case .featuredTip(let featuredTip):
            return featuredTip.betId
        case .suggestedBetslip(let suggestedBetslip):
            return suggestedBetslip.id
        }
    }
    
    var shouldCropList: Bool {
        return self.sizeType == .small
    }
    
    func getUsername() -> String? {
        switch self.dataType {
        case .featuredTip(let featuredTip):
            return featuredTip.username
        case .suggestedBetslip:
            return nil
        }
    }

    func getTotalOdds() -> String? {
        
        switch self.dataType {
        case .featuredTip(let featuredTip):
            let oddsDouble = Double(featuredTip.totalOdds)
            let oddFormatted = OddFormatter.formatOdd(withValue: oddsDouble)
            return "\(oddFormatted)"
            
        case .suggestedBetslip(let suggestedBetslip):
            let totalOdd = suggestedBetslip.selections.map(\.odd).reduce(1, *)
            let oddFormatted = OddFormatter.formatOdd(withValue: totalOdd)
            return "\(oddFormatted)"
        }
        
        return nil
    }

    func getNumberSelections() -> String? {
        
        switch self.dataType {
        case .featuredTip(let featuredTip):
            if let numberSelections = featuredTip.selections?.count {
                return "\(numberSelections)"
            }
        case .suggestedBetslip:
            return nil
        }
        return nil
    }

    func getUserId() -> String? {
        switch self.dataType {
        case .featuredTip(let featuredTip):
            return featuredTip.userId
        case .suggestedBetslip:
            return nil
        }
        
    }
    
    func addTicketBetslip() {
        switch self.dataType {
        case .featuredTip(let featuredTip):
            self.addTicketBetslip(forFeaturedTip: featuredTip)
        case .suggestedBetslip(let suggestedBetslip):
            self.addTicketBetslip(forSuggestedBetslip: suggestedBetslip)
        }
    }

    private func addTicketBetslip(forFeaturedTip featuredTip: FeaturedTip) {

        guard let selections = featuredTip.selections else {return}

        for selection in selections {
            let bettingOfferId = "\(selection.extraSelectionInfo.bettingOfferId)"
            let ticket = BettingTicket(id: bettingOfferId,
                                       outcomeId: selection.outcomeId,
                                       marketId: selection.bettingTypeId,
                                       matchId: selection.eventId,
                                       decimalOdd: Double(selection.odd),
                                       isAvailable: true,
                                       matchDescription: selection.eventName,
                                       marketDescription: selection.extraSelectionInfo.marketName,
                                       outcomeDescription: selection.betName,
                                       homeParticipantName: nil,
                                       awayParticipantName: nil,
                                       sportIdCode: nil)

            if !Env.betslipManager.hasBettingTicket(withId: "\(selection.extraSelectionInfo.bettingOfferId)") {

                Env.betslipManager.addBettingTicket(ticket)

                self.shouldShowBetslip?()
            }

        }
    }
    
    private func addTicketBetslip(forSuggestedBetslip suggestedBetslip: SuggestedBetslip) {
        for selection in suggestedBetslip.selections {
            
            let ticket = BettingTicket(id: selection.outcomeId,
                                       outcomeId: selection.outcomeId,
                                       marketId: selection.marketId,
                                       matchId: selection.eventId,
                                       decimalOdd: selection.odd,
                                       isAvailable: true,
                                       matchDescription: selection.eventName,
                                       marketDescription: selection.marketName,
                                       outcomeDescription: selection.outcomeName,
                                       homeParticipantName: nil,
                                       awayParticipantName: nil,
                                       sport: selection.sport,
                                       sportIdCode: selection.sport?.id)

            if !Env.betslipManager.hasBettingTicket(withId: selection.outcomeId) {
                Env.betslipManager.addBettingTicket(ticket)
                self.shouldShowBetslip?()
            }

        }
    }
    
    func followUser(userId: String) {

    }

    func unfollowUser(userId: String) {

    }

}

class FeaturedTipSelectionViewModel {
    
    var outcomeName: String {
        switch dataType {
        case .featuredTipSelection(let featuredTipSelection):
            return "\(featuredTipSelection.betName) (\(featuredTipSelection.bettingTypeName))"
        case .suggestedBetslipSelection(let suggestedBetslipSelection):
            return suggestedBetslipSelection.outcomeName
        }
        
    }
    
    var matchName: String {
        switch dataType {
        case .featuredTipSelection(let featuredTipSelection):
            return featuredTipSelection.eventName
        case .suggestedBetslipSelection(let suggestedBetslipSelection):
            return suggestedBetslipSelection.eventName
        }
    }
    
    var sportIconImageName: String {
        switch dataType {
        case .featuredTipSelection(let featuredTipSelection):
            return "sport_type_icon_\(featuredTipSelection.sportId)"
        case .suggestedBetslipSelection(let suggestedBetslipSelection):
            if let sportId = suggestedBetslipSelection.sport?.id {
                return "sport_type_icon_\(sportId)"
            }
            else {
                return "sport_type_icon_default"
            }
        }
    }
    
    var countryFlagImageName: String {
        var countryIdentifier: String?
        switch dataType {
        case .featuredTipSelection(let featuredTipSelection):
            countryIdentifier = featuredTipSelection.venueName 
        case .suggestedBetslipSelection(let suggestedBetslipSelection):
            countryIdentifier = suggestedBetslipSelection.location?.id
        }
        
        if let countryIdentifierValue = countryIdentifier {
            return Assets.flagName(withCountryCode: countryIdentifierValue)
        }
        else {
            return "country_flag_240"
        }
        
    }

    var competitiontName: String {
        switch dataType {
        case .featuredTipSelection(let featuredTipSelection):
            return featuredTipSelection.sportParentName ?? ""
        case .suggestedBetslipSelection(let suggestedBetslipSelection):
            return suggestedBetslipSelection.competitionName
        }
    }
    
    var marketName: String {
        switch dataType {
        case .featuredTipSelection(let featuredTipSelection):
            return featuredTipSelection.extraSelectionInfo.marketName
        case .suggestedBetslipSelection(let suggestedBetslipSelection):
            return suggestedBetslipSelection.marketName
        }
    }
    
    var marketId: String {
        switch dataType {
        case .featuredTipSelection(let featuredTipSelection):
            return featuredTipSelection.extraSelectionInfo.marketName
        case .suggestedBetslipSelection(let suggestedBetslipSelection):
            return suggestedBetslipSelection.marketId
        }
        
    }
    
    private var outcomeUpdatesSubscription: ServicesProvider.Subscription?
    private var outcomeUpdatesCancellable: AnyCancellable?
    
    private var cancellables = Set<AnyCancellable>()

    private  enum DataType {
        case featuredTipSelection(FeaturedTipSelection)
        case suggestedBetslipSelection(SuggestedBetslipSelection)
    }
    
    private var dataType: DataType
    
    var oddPublisher: AnyPublisher<Double, Never> {
        return self.oddSubject.removeDuplicates().eraseToAnyPublisher()
    }
    private var oddSubject: CurrentValueSubject<Double, Never> = .init(1.0)

    var competitionNamePublisher: AnyPublisher<String?, Never> {
        return self.competitionNameSubject.removeDuplicates().eraseToAnyPublisher()
    }
    private var competitionNameSubject: CurrentValueSubject<String?, Never> = .init(nil)
    
    var marketNamePublisher: AnyPublisher<String, Never> {
        return self.marketNameSubject.removeDuplicates().eraseToAnyPublisher()
    }
    private var marketNameSubject: CurrentValueSubject<String, Never> = .init("-")
    
    var outcomeNamePublisher: AnyPublisher<String, Never> {
        return self.outcomeNameSubject.removeDuplicates().eraseToAnyPublisher()
    }
    private var outcomeNameSubject: CurrentValueSubject<String, Never> = .init("-")
    
    var eventNamePublisher: AnyPublisher<String, Never> {
        return self.eventNameSubject.removeDuplicates().eraseToAnyPublisher()
    }
    private var eventNameSubject: CurrentValueSubject<String, Never> = .init("-")
    
    init(featuredTipSelection: FeaturedTipSelection) {
        self.dataType = .featuredTipSelection(featuredTipSelection)
    }
    
    init(suggestedBetslipSelection: SuggestedBetslipSelection) {
        self.dataType = .suggestedBetslipSelection(suggestedBetslipSelection)
        
        self.marketNameSubject.send(suggestedBetslipSelection.marketName)
        
        self.subscribeOddUpdates(eventId: suggestedBetslipSelection.eventId,
                                 marketId: suggestedBetslipSelection.marketId,
                                 outcomeId: suggestedBetslipSelection.outcomeId)        
    }
    
    private func subscribeOddUpdates(eventId: String, marketId: String, outcomeId: String) {
        
        self.outcomeUpdatesCancellable?.cancel()
        self.outcomeUpdatesCancellable = nil
        
        self.outcomeUpdatesSubscription = nil
                
        Env.servicesProvider.getMarketInfo(marketId: marketId)
            .map(ServiceProviderModelMapper.market(fromServiceProviderMarket:))
            .sink { _ in
                
            } receiveValue: { [weak self] market in
                for outcome in market.outcomes {
                    if outcome.bettingOffer.id == outcomeId {
                        self?.oddSubject.send(outcome.bettingOffer.decimalOdd)
                        self?.outcomeNameSubject.send(outcome.translatedName)
                    }
                }
                
                self?.competitionNameSubject.send(market.competitionName)
                self?.marketNameSubject.send(market.name)
                
                let eventName = [market.homeParticipant, market.awayParticipant].compactMap({ $0 }).joined(separator: " x ")
                self?.eventNameSubject.send(eventName)
            }
            .store(in: &self.cancellables)
        
        /*
        self.outcomeUpdatesCancellable = Env.servicesProvider.subscribeToMarketDetails(withId: marketId, onEventId: eventId)
            .sink { [weak self] completion in
                
            } receiveValue: { [weak self] subscribableContent in
                switch subscribableContent {
                case .connected(let subscription):
                    self?.outcomeUpdatesSubscription  = subscription
                case .contentUpdate(let market):
                    
                    let mappedMarket = ServiceProviderModelMapper.market(fromServiceProviderMarket: market)
                    for outcome in mappedMarket.outcomes {
                        if outcome.bettingOffer.id == outcomeId {
                            self?.oddSubject.send(outcome.bettingOffer.decimalOdd)
                        }
                    }
                    self?.marketNameSubject.send(market.name)
                    
                case .disconnected:
                    print("Betslip subscribeToMarketDetails disconnected")
                }
            }
        */
    }
    
}
