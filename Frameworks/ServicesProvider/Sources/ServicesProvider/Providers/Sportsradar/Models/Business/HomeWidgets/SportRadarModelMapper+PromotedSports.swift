//
//  File.swift
//  
//
//  Created by Ruben Roques on 09/06/2023.
//

import Foundation


extension SportRadarModelMapper {

    static func promotedSport(fromInternalPromotedSport internalPromotedSport: SportRadarModels.PromotedSport) -> PromotedSport {
        return PromotedSport(id: internalPromotedSport.id,
                             name: internalPromotedSport.name,
                             marketGroups: internalPromotedSport.marketGroups.map(Self.marketGroupPromotedSport(fromInternalMarketGroupPromotedSport:)))
    }

    static func marketGroupPromotedSport(fromInternalMarketGroupPromotedSport marketGroupPromotedSport: SportRadarModels.MarketGroupPromotedSport) -> MarketGroupPromotedSport {
        return MarketGroupPromotedSport(id: marketGroupPromotedSport.id, typeId: marketGroupPromotedSport.typeId, name: marketGroupPromotedSport.name)
    }

}
