//
//  File.swift
//  
//
//  Created by Ruben Roques on 17/01/2024.
//

import Foundation

extension GomaModelMapper {
    
    static func featuredTips(fromInternaFeaturedTips internalFeaturedTips: [GomaModels.FeaturedTip]) -> [FeaturedTip] {
        return internalFeaturedTips.map(Self.featuredTip(fromInternaFeaturedTip:))
    }
    
    static func featuredTip(fromInternaFeaturedTip internalFeaturedTip: GomaModels.FeaturedTip) -> FeaturedTip {
    
        let tipUser = FeaturedTipUser(id: "\(internalFeaturedTip.user.id)",
                name: internalFeaturedTip.user.name,
                code: internalFeaturedTip.user.code,
                avatar: internalFeaturedTip.user.avatar)
        
        let selections = internalFeaturedTip.selections.map(Self.featuredTipSelection(fromInternalTipSelection:))
        
        return FeaturedTip(id: "\(internalFeaturedTip.id)",
                    stake: internalFeaturedTip.stake,
                    odd: internalFeaturedTip.odds,
                    status: internalFeaturedTip.status,
                    type: internalFeaturedTip.type,
                    selections: selections,
                    user: tipUser)
    }
    
    static func featuredTipSelection(fromInternalTipSelection featuredTipSelection: GomaModels.FeaturedTipSelection) -> FeaturedTipSelection {
        let mappedEvent = Self.event(fromInternalEvent: featuredTipSelection.event)
        return FeaturedTipSelection(id: "\(featuredTipSelection.id)",
                                    marketId: "\(featuredTipSelection.outcome.market.id)",
                                    outcomeId: "\(featuredTipSelection.outcome.id)",
                                    marketName: featuredTipSelection.outcome.market.name,
                                    outcomeName: featuredTipSelection.outcome.name,
                                    odd: featuredTipSelection.odd,
                                    event: mappedEvent)
    }
        
}
