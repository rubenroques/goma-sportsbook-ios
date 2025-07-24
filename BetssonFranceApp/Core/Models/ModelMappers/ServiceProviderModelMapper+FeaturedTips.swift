//
//  ServiceProviderModelMapper+FeaturedTips.swift
//  MultiBet
//
//  Created by Ruben Roques on 18/01/2024.
//

import Foundation
import ServicesProvider

extension ServiceProviderModelMapper {
    
    static func featuredTips(fromServiceProviderFeaturedTips featuredTips: [ServicesProvider.FeaturedTip]) -> [FeaturedTip] {
        return featuredTips.map(Self.featuredTip(fromServiceProviderFeaturedTip:))
    }
    
    static func featuredTip(fromServiceProviderFeaturedTip featuredTip: ServicesProvider.FeaturedTip) -> FeaturedTip {
        
        let selections = featuredTip.selections.map(Self.featuredTipSelection(fromServiceProvider:))
        
        return FeaturedTip(betId: featuredTip.id,
                           selections: selections,
                           type: featuredTip.type,
                           systemBetType: nil,
                           status: featuredTip.status,
                           statusLabel: featuredTip.status,
                           placedDate: nil,
                           userId: featuredTip.user.id,
                           username: featuredTip.user.name ?? " ",
                           totalOdds: featuredTip.odd,
                           avatar: featuredTip.user.avatar)
    }
    
    static func featuredTipSelection(fromServiceProvider featuredTipSelections: [ServicesProvider.FeaturedTipSelection]) -> [FeaturedTipSelection] {
        return featuredTipSelections.map(Self.featuredTipSelection(fromServiceProvider:))
    }
    
    static func featuredTipSelection(fromServiceProvider featuredTipSelection: ServicesProvider.FeaturedTipSelection) -> FeaturedTipSelection {
        
        let convertedEvent = Self.match(fromEvent: featuredTipSelection.event)
        
        var eventName = (convertedEvent?.homeParticipant.name ?? "") + " x " + (convertedEvent?.awayParticipant.name ?? "")
        
        if let originalEventName = featuredTipSelection.event.name {
            eventName = originalEventName
        }
        
        let outcomeId = Int(featuredTipSelection.outcomeId) ?? 0
        
        let extraInfos = ExtraSelectionInfo(bettingOfferId: outcomeId,
                                            marketName: featuredTipSelection.marketName,
                                            outcomeEntity: OutcomeEntity(id: 0, statusId: 0))
        
        return FeaturedTipSelection.init(outcomeId: featuredTipSelection.outcomeId,
                                         status: nil,
                                         sportId: convertedEvent?.sport.id ?? "",
                                         sportName: convertedEvent?.sport.name ?? "",
                                         sportParentName: convertedEvent?.competitionName ?? "",
                                         sportIconId: convertedEvent?.sport.id ?? "",
                                         venueId: convertedEvent?.venue?.id,
                                         venueName: convertedEvent?.venue?.name,
                                         eventId: convertedEvent?.id ?? "",
                                         eventName: eventName,
                                         marketId: featuredTipSelection.marketId,
                                         bettingTypeId: "",
                                         bettingTypeName: featuredTipSelection.marketName,
                                         betName: featuredTipSelection.outcomeName,
                                         odd: featuredTipSelection.odd,
                                         extraSelectionInfo: extraInfos)
    }
    
    static func rankingsTips(fromServiceProviderTipsRankings tipsRankings: [ServicesProvider.TipRanking]) -> [RankingTip] {
        return tipsRankings.map(Self.rankingTip(fromServiceProviderTipRanking:))
    }
    
    static func rankingTip(fromServiceProviderTipRanking tipRanking: ServicesProvider.TipRanking) -> RankingTip {
        return RankingTip(position: tipRanking.position,
                          username: tipRanking.name,
                          userId: tipRanking.userId,
                          result: tipRanking.result,
                          avatar: tipRanking.avatar,
                          code: tipRanking.code,
                          anonymous: tipRanking.anonymous)
    }
    
    static func suggestedBetCardSummary(fromFeaturedTip featuredTip: FeaturedTip) -> SuggestedBetCardSummary {
        
        let suggestedBetSummaryArray = featuredTip.selections?.map({
            return Self.suggestedBetSummary(fromFeaturedTipsSelection: $0)
        })
                
        return SuggestedBetCardSummary(bets: suggestedBetSummaryArray ?? [], type: featuredTip.type, totalOdd: featuredTip.totalOdds)
    }
    
    static func suggestedBetSummary(fromFeaturedTipsSelection featuredTipSelection: FeaturedTipSelection) -> SuggestedBetSummary {
        
        return SuggestedBetSummary(matchId: featuredTipSelection.eventId,
                                   matchName: featuredTipSelection.eventName,
                                   marketId: featuredTipSelection.marketId ?? "",
                                   outcomeId: featuredTipSelection.outcomeId,
                                   homeParticipantName: "",
                                   awayParticipantName: "",
                                   venueId: featuredTipSelection.venueId ?? "",
                                   sportName: featuredTipSelection.sportName,
                                   marketName: featuredTipSelection.betName,
                                   outcomeName: featuredTipSelection.bettingTypeName,
                                   paramFloat: nil,
                                   odd: OddFormat.decimal(odd: featuredTipSelection.odd),
                                   competitionName: featuredTipSelection.sportParentName ?? "",
                                   extraSelectionInfo: featuredTipSelection.extraSelectionInfo)
        
//        return SuggestedBetSummary(matchId: featuredTipSelection.eventId, matchName: featuredTipSelection.eventName, competitionName: featuredTipSelection.sportParentName ?? "", bettingType: 0, eventPartId: 0, venueId: 0, venueISO: featuredTipSelection.venueId, venueName: featuredTipSelection.venueName, bettingName: featuredTipSelection.bettingTypeName, bettingId: featuredTipSelection.marketId, bettingOption: featuredTipSelection.betName, bettingOptionId: featuredTipSelection.outcomeId, paramFloat: nil, odd: featuredTipSelection.odd, extraSelectionInfo: featuredTipSelection.extraSelectionInfo)
    }
}
