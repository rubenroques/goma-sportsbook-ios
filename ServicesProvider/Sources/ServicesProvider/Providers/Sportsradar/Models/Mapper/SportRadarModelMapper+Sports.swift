//
//  SportRadarError.swift
//
//
//  Created by Ruben Roques on 10/10/2022.
//

import Foundation

extension SportRadarModelMapper {

    static func sportType(fromSportRadarSportType sportRadarSportType: SportRadarModels.SportType) -> SportType {
        // Try get the internal sport id name
        let cleanedSportRadarSportTypeName = Self.simplify(string: sportRadarSportType.name)
        let sportTypeInfoId = SportTypeInfo.allCases.first { sportTypeInfo in
            let cleanedName = Self.simplify(string: sportTypeInfo.name)
            return cleanedName == cleanedSportRadarSportTypeName
        }?.id

        let sportType = SportType(name: sportRadarSportType.name,
                                  numericId: sportRadarSportType.numericId,
                                  alphaId: sportRadarSportType.alphaId,
                                  iconId: sportTypeInfoId,
                                  showEventCategory: false,
                                  numberEvents: sportRadarSportType.numberEvents,
                                  numberOutrightEvents: sportRadarSportType.numberOutrightEvents,
                                  numberOutrightMarkets: sportRadarSportType.numberOutrightMarkets)

        return sportType
    }

    static func sportType(fromSportNode sportNode: SportRadarModels.SportNode) -> SportRadarModels.SportType {
        let sportUnique = SportRadarModels.SportType(name: sportNode.name,
                                    numericId: sportNode.id,
                                    alphaId: nil,
                                    numberEvents: sportNode.numberEvents,
                                    numberOutrightEvents: sportNode.numberOutrightEvents,
                                    numberOutrightMarkets: sportNode.numberOutrightMarkets)
        return sportUnique
    }

    static func sportType(fromScheduledSport scheduledSport: SportRadarModels.ScheduledSport) -> SportRadarModels.SportType {
        let sportUnique = SportRadarModels.SportType(name: scheduledSport.name,
                                                     numericId: nil,
                                                     alphaId: scheduledSport.id,
                                                     numberEvents: 0,
                                                     numberOutrightEvents: 0,
                                                     numberOutrightMarkets: 0)
        return sportUnique

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

        let sportRegionNode = SportRegion(id: sportNodeRegion.id, name: sportNodeRegion.name)

        return sportRegionNode
    }

}
