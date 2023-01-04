//
//  SportRadarModelMapper.swift
//  
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

struct SportRadarModelMapper {

    static func sportRegionInfo(fromInternalSportRegionInfo sportRegionInfo: SportRadarModels.SportRegionInfo) -> SportRegionInfo {
        let regionCompetitionNodes = sportRegionInfo.competitionNodes.map(self.regionCompetitionNode(fromInternalSportCompetition:))

        let sportRegionInfo = SportRegionInfo(id: sportRegionInfo.id, name: sportRegionInfo.name, competitionNodes: regionCompetitionNodes)

        return sportRegionInfo
    }

    static func regionCompetitionNode(fromInternalSportCompetition sportCompetition: SportRadarModels.SportCompetition) -> SportCompetition {

        let sportCompetition = SportCompetition(id: sportCompetition.id, name: sportCompetition.name)

        return sportCompetition
    }

    static func sportCompetitionInfo(fromInternalSportCompetitionInfo sportCompetitionInfo: SportRadarModels.SportCompetitionInfo) -> SportCompetitionInfo {
        let marketGroups = sportCompetitionInfo.marketGroups.map(self.competitionMarketGroup(fromInternalSportCompetitionMarketGroup:))

        let sportCompetitionInfo = SportCompetitionInfo(id: sportCompetitionInfo.id,
                                                        name: sportCompetitionInfo.name,
                                                        marketGroups: marketGroups,
                                                        numberOutrightEvents: sportCompetitionInfo.numberOutrightEvents,
                                                        numberOutrightMarkets: sportCompetitionInfo.numberOutrightMarkets)

        return sportCompetitionInfo
    }

    static func competitionMarketGroup(fromInternalSportCompetitionMarketGroup sportCompetitionMarketGroup: SportRadarModels.SportCompetitionMarketGroup) -> SportCompetitionMarketGroup {

        let sportCompetitionMarketGroup = SportCompetitionMarketGroup(id: sportCompetitionMarketGroup.id, name: sportCompetitionMarketGroup.name)

        return sportCompetitionMarketGroup
    }
    // ==========================================

}
