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

        let identifier = sportType.iconId ?? sportType.alphaId ?? sportType.numericId ?? "0"
        let sport = Sport(id: identifier,
                          name: sportType.name,
                          alphaId: sportType.alphaId,
                          numericId: sportType.numericId,
                          showEventCategory: sportType.showEventCategory,
                          liveEventsCount: sportType.numberEvents,
                          outrightEventsCount: sportType.numberOutrightEvents)
        return sport
    }

    static func serviceProviderSportType(fromSport sport: Sport) -> ServicesProvider.SportType {
        let serviceProviderSportType = ServicesProvider.SportType(name: sport.name,
                                                                  numericId: sport.numericId,
                                                                  alphaId: sport.alphaId,
                                                                  iconId: sport.id,
                                                                  showEventCategory: sport.showEventCategory,
                                                                  numberEvents: sport.liveEventsCount,
                                                                  numberOutrightEvents: sport.outrightEventsCount,
                                                                  numberOutrightMarkets: 0)
        return serviceProviderSportType
    }

}

extension Sport {
    init(serviceProviderSportType sportType: ServicesProvider.SportType) {
        self = ServiceProviderModelMapper.sport(fromServiceProviderSportType: sportType)
    }
}
