//
//  File.swift
//
//
//  Created by Ruben Roques on 01/08/2024.
//

import Foundation

extension SportRadarModelMapper {
    
    static func promotedBetslipsBatchResponse(fromInternalPromotedBetslipsBatchResponse internalResponse: SportRadarModels.PromotedBetslipsBatchResponse) -> PromotedBetslipsBatchResponse {
        return PromotedBetslipsBatchResponse(
            promotedBetslips: internalResponse.promotedBetslips.map(promotedBetslip(fromInternalPromotedBetslip:))
        )
    }
    
    static func promotedBetslip(fromInternalPromotedBetslip internalBetslip: SportRadarModels.PromotedBetslip) -> PromotedBetslip {
        return PromotedBetslip(
            selections: internalBetslip.selections.map(promotedBetslipSelection(fromInternalPromotedBetslipSelection:)),
            betslipCount: internalBetslip.betslipCount
        )
    }
    
    static func promotedBetslipSelection(fromInternalPromotedBetslipSelection internalSelection: SportRadarModels.PromotedBetslipSelection) -> PromotedBetslipSelection {
        
        let mappedSportId = Self.sportAlphaId(fromVaixSportId: internalSelection.sportId) ?? ""
        
        let sport = SportType(name: internalSelection.sport,
                              numericId: mappedSportId,
                              alphaId: mappedSportId,
                              iconId: mappedSportId,
                              showEventCategory: false,
                              numberEvents: 0,
                              numberOutrightEvents: 0,
                              numberOutrightMarkets: 0,
                              numberLiveEvents: 0)
        
        return PromotedBetslipSelection(
            id: internalSelection.id,
            countryName: internalSelection.country ?? "international",
            league: internalSelection.league,
            marketType: internalSelection.marketType,
            eventId: internalSelection.orakoEventId,
            marketId: internalSelection.orakoMarketId,
            outcomeId: internalSelection.orakoSelectionId,
            participantIds: internalSelection.participantIds,
            participants: internalSelection.participants,
            sport: sport,
            odd: internalSelection.quote
        )
    }
    
}
