//
//  SportRadarError.swift
//
//
//  Created by Ruben Roques on 10/10/2022.
//

import Foundation
import SharedModels

extension SportRadarModelMapper {

    static func sportType(fromSportRadarSportType sportRadarSportType: SportRadarModels.SportType) -> SportType {

        // Try get the internal sport id by alpha code or name if it fails
        var sportTypeId = ""

        if let sportAlphaId = sportRadarSportType.alphaId {
            sportTypeId = SportTypeInfo.init(alphaCode: sportAlphaId)?.id ?? ""
        }
        else {
            let cleanedSportRadarSportTypeName = Self.simplify(string: sportRadarSportType.name)
            let sportTypeInfoId = SportTypeInfo.allCases.first { sportTypeInfo in
                let cleanedName = Self.simplify(string: sportTypeInfo.name)
                return cleanedName == cleanedSportRadarSportTypeName
            }?.id

            sportTypeId = sportTypeInfoId ?? ""
        }
        
        let sportType = SportType(name: sportRadarSportType.name,
                                  numericId: sportRadarSportType.numericId,
                                  alphaId: sportRadarSportType.alphaId,
                                  iconId: sportTypeId,
                                  showEventCategory: false,
                                  numberEvents: sportRadarSportType.numberEvents,
                                  numberOutrightEvents: sportRadarSportType.numberOutrightEvents,
                                  numberOutrightMarkets: sportRadarSportType.numberOutrightMarkets,
                                  numberLiveEvents: sportRadarSportType.numberLiveEvents)
        return sportType
    }

    static func sportType(fromSportNode sportNode: SportRadarModels.SportNode) -> SportRadarModels.SportType {

        let sportUnique = SportRadarModels.SportType(name: sportNode.name,
                                    numericId: sportNode.id,
                                                     alphaId: sportNode.alphaCode,
                                    numberEvents: sportNode.numberEvents,
                                    numberOutrightEvents: sportNode.numberOutrightEvents,
                                    numberOutrightMarkets: sportNode.numberOutrightMarkets,
                                                     numberLiveEvents: sportNode.numberLiveEvents)
        return sportUnique
    }

    static func sportType(fromScheduledSport scheduledSport: SportRadarModels.ScheduledSport) -> SportRadarModels.SportType {


        let sportUnique = SportRadarModels.SportType(name: scheduledSport.name,
                                                     numericId: nil,
                                                     alphaId: scheduledSport.id,
                                                     numberEvents: 0,
                                                     numberOutrightEvents: 0,
                                                     numberOutrightMarkets: 0, numberLiveEvents: 0)
        return sportUnique

    }
    
    static func sportTypeName(fromAlphaCode alphaCode: String) -> String {
        
        let sportTypeInfoName = SportTypeInfo.init(alphaCode: alphaCode)?.name ?? ""
        
        return sportTypeInfoName
    }

    private static func simplify(string: String) -> String {
        let validChars = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return string.filter { validChars.contains($0) }.lowercased()
    }

    static func sportNodeInfo(fromInternalSportNodeInfo sportNodeInfo: SportRadarModels.SportNodeInfo) -> SportNodeInfo {
        let sportRegionNodes = sportNodeInfo.regionNodes.map(self.sportNodeRegion(fromInternalSportNodeRegion:))

        let sportNodeInfo = SportNodeInfo(id: sportNodeInfo.id, regionNodes: sportRegionNodes, defaultOrder: sportNodeInfo.defaultOrder)

        return sportNodeInfo
    }

    static func sportNodeRegion(fromInternalSportNodeRegion sportNodeRegion: SportRadarModels.SportRegion) -> SportRegion {

        let country: Country? = Country.country(withName: sportNodeRegion.name ?? "")

        let sportRegionNode = SportRegion(id: sportNodeRegion.id,
                                          name: sportNodeRegion.name,
                                          numberEvents: sportNodeRegion.numberEvents,
                                          numberOutrightEvents: sportNodeRegion.numberOutrightEvents,
                                          country: country)

        return sportRegionNode
    }

    static func sportRegionInfo(fromInternalSportRegionInfo sportRegionInfo: SportRadarModels.SportRegionInfo) -> SportRegionInfo {
        let regionCompetitionNodes = sportRegionInfo.competitionNodes.map(SportRadarModelMapper.regionCompetitionNode(fromInternalSportCompetition:))

        let sportRegionInfo = SportRegionInfo(id: sportRegionInfo.id, name: sportRegionInfo.name, competitionNodes: regionCompetitionNodes)

        return sportRegionInfo
    }

    static func regionCompetitionNode(fromInternalSportCompetition sportCompetition: SportRadarModels.SportCompetition) -> SportCompetition {

        let sportCompetition = SportCompetition(id: sportCompetition.id,
                                                name: sportCompetition.name,
                                                numberEvents: sportCompetition.numberEvents,
                                                numberOutrightEvents: sportCompetition.numberOutrightEvents)

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

}
