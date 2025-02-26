//
//  SportRadarModelMapper+RecommendedBetBuilders.swift
//
//
//  Created by Ruben Roques on 01/08/2024.
//

import Foundation

extension SportRadarModelMapper {

    static func recommendedBetBuildersResponse(fromInternalResponse internalResponse: SportRadarModels.RecommendedBetBuildersResponse) -> RecommendedBetBuilders {
        return RecommendedBetBuilders(
            recommendations: internalResponse.recommendations.flatMap { event in
                return event.betBuilders.map { selections in
                    // Calculate total odds from all selections
                    let totalOdds = calculateTotalOdds(selections: selections)
                    return recommendedBetBuilder(fromEventInfo: event, selections: selections, totalOdds: totalOdds)
                }
            }
        )
    }

    private static func calculateTotalOdds(selections: [SportRadarModels.BetBuilderSelection]) -> Double {
        // Calculate combined odds
        var totalOdds: Double = 1.0
        selections.forEach { selection in
            totalOdds *= selection.quote
        }
        return totalOdds
    }

    static func recommendedBetBuilder(fromEventInfo event: SportRadarModels.RecommendedBetBuilderEvent, selections: [SportRadarModels.BetBuilderSelection], totalOdds: Double) -> RecommendedBetBuilder {
        return RecommendedBetBuilder(
            selections: selections.map { selection in
                recommendedBetBuilderSelection(fromSelection: selection, eventInfo: event)
            },
            totalOdds: totalOdds
        )
    }

    static func recommendedBetBuilderSelection(fromSelection selection: SportRadarModels.BetBuilderSelection, eventInfo: SportRadarModels.RecommendedBetBuilderEvent) -> RecommendedBetBuilderSelection {

        let numericSportId = Self.sportNumericId(fromVaixSportId: eventInfo.sportId) ?? ""
        let alphaSportId = Self.sportAlphaId(fromVaixSportId: eventInfo.sportId) ?? ""

        let sport = SportType(name: eventInfo.sport,
                            numericId: numericSportId,
                            alphaId: alphaSportId,
                            iconId: numericSportId,
                            showEventCategory: false,
                            numberEvents: 0,
                            numberOutrightEvents: 0,
                            numberOutrightMarkets: 0,
                            numberLiveEvents: 0)

        // Determine outcome name based on the type (similar to promoted betslips)
        let outcomeName: String
        switch selection.outcomeType.lowercased() {
        case "home":
            outcomeName = (eventInfo.participants.first ?? "")
        case "draw":
            outcomeName = "draw"
        case "away":
            outcomeName = (eventInfo.participants.last ?? "")
        default:
            outcomeName = selection.outcomeType
        }

        // Extract home and away participant IDs if available
        let homeParticipantId = eventInfo.participantIds.first
        let awayParticipantId = eventInfo.participantIds.last

        return RecommendedBetBuilderSelection(
            countryName: eventInfo.country,
            competitionName: eventInfo.league,
            eventId: eventInfo.orakoEventId,
            marketId: selection.orakoMarketId,
            outcomeId: selection.orakoSelectionId,
            marketName: selection.marketTypeName,
            outcomeName: outcomeName,
            participantIds: eventInfo.participantIds,
            participants: eventInfo.participants,
            sport: sport,
            odd: selection.quote,
            leagueId: eventInfo.leagueId,
            sportId: eventInfo.sportId,
            countryId: eventInfo.countryId,
            homeParticipantId: homeParticipantId,
            awayParticipantId: awayParticipantId
        )
    }
}
