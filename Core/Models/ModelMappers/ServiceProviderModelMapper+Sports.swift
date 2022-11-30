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

        let sport = Sport(id: sportType.iconId ?? "0",
                          name: sportType.name,
                          alphaId: sportType.alphaId,
                          numericId: sportType.numericId,
                          showEventCategory: sportType.showEventCategory,
                          liveEventsCount: sportType.numberEvents)
        return sport
    }

    static func serviceProviderSportType(fromSport sport: Sport) -> ServiceProvider.SportType {
        let serviceProviderSportType = ServiceProvider.SportType(name: sport.name,
                                                                 numericId: sport.numericId,
                                                                 alphaId: sport.alphaId,
                                                                 iconId: sport.id,
                                                                 showEventCategory: sport.showEventCategory,
                                                                 numberEvents: sport.liveEventsCount,
                                                                 numberOutrightEvents: 0,
                                                                 numberOutrightMarkets: 0)
        return serviceProviderSportType
    }

}

extension Sport {
    init(serviceProviderSportType sportType: ServiceProvider.SportType) {
        self = ServiceProviderModelMapper.sport(fromServiceProviderSportType: sportType)
    }
}
