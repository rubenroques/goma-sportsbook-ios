//
//  ServiceProviderModelMapper+Sports.swift
//  Sportsbook
//
//  Created by Ruben Roques on 12/10/2022.
//

import Foundation
import ServicesProvider

extension ServiceProviderModelMapper {
    
    // Sports
    static func sport(fromServiceProviderSportType sportType: ServicesProvider.SportType) -> Sport {

        let sport = Sport(id: sportType.iconId ?? "0",
                          name: sportType.name,
                          alphaId: sportType.alphaId,
                          numericId: sportType.numericId,
                          showEventCategory: sportType.showEventCategory,
                          liveEventsCount: sportType.numberEvents)
        return sport
    }

    static func serviceProviderSportType(fromSport sport: Sport) -> ServicesProvider.SportType {
        let serviceProviderSportType = ServicesProvider.SportType(name: sport.name,
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
    init(serviceProviderSportType sportType: ServicesProvider.SportType) {
        self = ServiceProviderModelMapper.sport(fromServiceProviderSportType: sportType)
    }
}
