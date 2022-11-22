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
        return Sport(id: sportType.id,
                     name: sportType.name,
                     showEventCategory: false)
    }
    
    static func serviceProviderSportType(fromSport sport: Sport) -> ServiceProvider.SportType? {
        return ServiceProvider.SportType(id: sport.id)
    }
    
    static func sport(fromServiceProviderSportTypeDetails sportTypeDetails: ServiceProvider.SportTypeDetails) -> Sport {
        return Sport(id: sportTypeDetails.sportType.id,
                     name: sportTypeDetails.sportType.name,
                     showEventCategory: false,
                     liveEventsCount: sportTypeDetails.eventsCount)
    }
    
}

extension Sport {
    init(serviceProviderSportType sportType: ServiceProvider.SportType) {
        self = ServiceProviderModelMapper.sport(fromServiceProviderSportType: sportType)
    }
}
