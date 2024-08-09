//
//  FeaturedTipCollectionViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 01/09/2022.
//

import Foundation
import Combine

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
            countryIdentifier = featuredTipSelection.venueName ?? featuredTipSelection.venueId
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

    var tournamentName: String {
        switch dataType {
        case .featuredTipSelection(let featuredTipSelection):
            return featuredTipSelection.sportParentName
        case .suggestedBetslipSelection(let suggestedBetslipSelection):
            return suggestedBetslipSelection.competitionName
        }
    }
    
    var marketNameName: String {
        switch dataType {
        case .featuredTipSelection(let featuredTipSelection):
            return featuredTipSelection.extraSelectionInfo.marketName
        case .suggestedBetslipSelection(let suggestedBetslipSelection):
            return suggestedBetslipSelection.marketName
        }
        
    }
    
    private  enum DataType {
        case featuredTipSelection(FeaturedTipSelection)
        case suggestedBetslipSelection(SuggestedBetslipSelection)
    }
    
    private var dataType: DataType
    
    init(featuredTipSelection: FeaturedTipSelection) {
        self.dataType = .featuredTipSelection(featuredTipSelection)
    }
    
    init(suggestedBetslipSelection: SuggestedBetslipSelection) {
        self.dataType = .suggestedBetslipSelection(suggestedBetslipSelection)
    }
    
}

class FeaturedTipCollectionViewModel {

    var shouldShowBetslip: (() -> Void)?
    
    private enum DataType {
        case featuredTip(FeaturedTip)
        case suggestedBetslip(SuggestedBetslip)
    }
    
    enum SizeType {
        case small
        case fullscreen
    }
    
    var selectionViewModels: [FeaturedTipSelectionViewModel] = []
    
    private var dataType: DataType
    var sizeType: SizeType

    
    init(featuredTip: FeaturedTip, sizeType: SizeType) {
        self.dataType = .featuredTip(featuredTip)
        self.sizeType = sizeType
        self.generateSelectionViewModels()
    }

    init(suggestedBetslip: SuggestedBetslip, sizeType: SizeType) {
        self.dataType = .suggestedBetslip(suggestedBetslip)
        self.sizeType = sizeType
        self.generateSelectionViewModels()
    }
    
    private func generateSelectionViewModels() {
        switch self.dataType {
        case .featuredTip(let featuredTip):
            self.selectionViewModels = (featuredTip.selections ?? []).map(FeaturedTipSelectionViewModel.init(featuredTipSelection:))
        case .suggestedBetslip(let suggestedBetslip):
            self.selectionViewModels = suggestedBetslip.selections.map(FeaturedTipSelectionViewModel.init(suggestedBetslipSelection:))
        }
    }
    
    var shouldCropList: Bool {
        return self.sizeType == .small
    }
    
    func getUsername() -> String? {
        switch self.dataType {
        case .featuredTip(let featuredTip):
            return featuredTip.username
        case .suggestedBetslip(let suggestedBetslip):
            return nil
        }
        
    }

    func getTotalOdds() -> String? {
        
        switch self.dataType {
        case .featuredTip(let featuredTip):
            if let oddsDouble = Double(featuredTip.totalOdds) {
                let oddFormatted = OddFormatter.formatOdd(withValue: oddsDouble)
                return "\(oddFormatted)"
            }
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
        case .suggestedBetslip(let suggestedBetslip):
            return nil
        }
        return nil
    }

    func getUserId() -> String? {
        switch self.dataType {
        case .featuredTip(let featuredTip):
            return featuredTip.userId
        case .suggestedBetslip(let suggestedBetslip):
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
                                       decimalOdd: Double(selection.odds) ?? 0.0,
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
