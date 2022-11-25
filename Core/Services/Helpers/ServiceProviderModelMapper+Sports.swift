//
//  ServiceProviderModelMapper+Sports.swift
//  Sportsbook
//
//  Created by Ruben Roques on 12/10/2022.
//

import Foundation
import ServiceProvider

extension ServiceProviderModelMapper {
    
    // Sports
    static func sport(fromServiceProviderSportType sportType: ServiceProvider.SportType) -> Sport {
        return Sport(id: sportType.iconId ?? "0",
                     name: sportType.name,
                     alphaId: sportType.alphaId,
                     numericId: sportType.numericId,
                     showEventCategory: false)
    }

    // TODO: TASK André - sport vs liveSport ? são iguais
    static func liveSport(fromServiceProviderSportType sportType: ServiceProvider.SportType) -> Sport {
        let sportTypeFilter = SportTypeInfo.allCases.filter({
            $0.name.lowercased() == sportType.name.lowercased()
        }).first

        return Sport(id: sportTypeFilter?.id ?? "0",
                     name: sportType.name,
                     alphaId: sportType.alphaId,
                     numericId: sportType.numericId,
                     showEventCategory: false,
                     liveEventsCount: Int(sportType.numberEvents ?? "0") ?? 0)
    }
    
    static func serviceProviderSportType(fromSport sport: Sport) -> ServiceProvider.SportType {
        return ServiceProvider.SportType(name: sport.name,
                                         numericId: sport.numericId,
                                         alphaId: sport.alphaId,
                                         iconId: sport.id,
                                         numberEvents: nil,
                                         numberOutrightEvents: nil,
                                         numberOutrightMarkets: nil)
    }
    
    static func sport(fromServiceProviderSportTypeDetails sportTypeDetails: ServiceProvider.SportTypeDetails) -> Sport {
        return Sport(id: sportTypeDetails.sportType.iconId ?? "0",
                     name: sportTypeDetails.sportType.name,
                     alphaId: sportTypeDetails.sportType.alphaId,
                     numericId: sportTypeDetails.sportType.numericId,
                     showEventCategory: false,
                     liveEventsCount: sportTypeDetails.eventsCount)
    }
    
}

extension Sport {
    init(serviceProviderSportType sportType: ServiceProvider.SportType) {
        self = ServiceProviderModelMapper.sport(fromServiceProviderSportType: sportType)
    }
}
