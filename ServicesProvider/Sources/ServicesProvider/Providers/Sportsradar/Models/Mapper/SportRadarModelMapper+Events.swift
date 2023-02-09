//
//  SportRadarError.swift
//
//
//  Created by Ruben Roques on 10/10/2022.
//

import Foundation
import SharedModels

extension SportRadarModelMapper {

//    static func eventsGroup(fromInternalEvents internalEvents: [SportRadarModels.Event]) -> EventsGroup {
//        let events = internalEvents.map({ event -> Event in
//            let country: Country? = Country.country(withName: event.tournamentCountryName ?? "")
//
//            if let eventMarkets = event.markets {
//                let markets = eventMarkets.map(Self.market(fromInternalMarket:))
//                return Event(id: event.id,
//                             homeTeamName: event.homeName ?? "",
//                             awayTeamName: event.awayName ?? "",
//                             sportTypeName: event.sportTypeName ?? "",
//                             competitionId: event.competitionId ?? "",
//                             competitionName: event.competitionName ?? "",
//                             startDate: event.startDate ?? Date(),
//                             markets: markets,
//                             venueCountry: country,
//                             numberMarkets: event.numberMarkets)
//            }
//            else {
//                return Event(id: event.id,
//                             homeTeamName: event.homeName ?? "",
//                             awayTeamName: event.awayName ?? "",
//                             sportTypeName: event.sportTypeName ?? "",
//                             competitionId: event.competitionId ?? "",
//                             competitionName: event.competitionName ?? "",
//                             startDate: event.startDate ?? Date(),
//                             markets: [],
//                             numberMarkets: event.numberMarkets)
//            }
//        })
//
//        let filterEvents = events.filter({
//            !$0.markets.isEmpty
//        })
//
//        return EventsGroup(events: filterEvents)
//    }


    // TODO: André - o model mapper não serve para manituplar assim os dados, é apenas para mappear
    static func eventsGroup(fromInternalEvents internalEvents: [SportRadarModels.Event]) -> EventsGroup {

        let events = internalEvents.map({ event -> Event in

            let country: Country? = Country.country(withName: event.tournamentCountryName ?? "")

            if let eventMarkets = event.markets {
                let markets = eventMarkets.map(Self.market(fromInternalMarket:))
                return Event(id: event.id,
                             homeTeamName: event.homeName ?? "",
                             awayTeamName: event.awayName ?? "",
                             sportTypeName: event.sportTypeName ?? "",
                             competitionId: event.competitionId ?? "",
                             competitionName: event.competitionName ?? "",
                             startDate: event.startDate ?? Date(),
                             markets: markets,
                             venueCountry: country,
                             numberMarkets: event.numberMarkets)
            }
            return Event(id: event.id,
                         homeTeamName: event.homeName ?? "",
                         awayTeamName: event.awayName ?? "",
                         sportTypeName: event.sportTypeName ?? "",
                         competitionId: event.competitionId ?? "",
                         competitionName: event.competitionName ?? "",
                         startDate: event.startDate ?? Date(),
                         markets: [],
                         venueCountry: country,
                         numberMarkets: event.numberMarkets)
        })

        return EventsGroup(events: events)
    }
    
    static func market(fromInternalMarket internalMarket: SportRadarModels.Market) -> Market {
        let outcomes = internalMarket.outcomes.map(Self.outcome(fromInternalOutcome:))
        return Market(id: internalMarket.id, name: internalMarket.name, outcomes: outcomes, marketTypeId: internalMarket.marketTypeId, eventMarketTypeId: internalMarket.eventMarketTypeId, eventName: internalMarket.eventName)
    }

    static func outcome(fromInternalOutcome internalOutcome: SportRadarModels.Outcome) -> Outcome {
        return Outcome(id: internalOutcome.id,
                       name: internalOutcome.name,
                       odd: internalOutcome.odd,
                       marketId: internalOutcome.marketId,
                       orderValue: internalOutcome.orderValue,
                       externalReference: internalOutcome.externalReference)
    }

    static func bannerResponse(fromInternalBannerResponse internalBannerResponse: SportRadarModels.BannerResponse) -> BannerResponse {

        let banners = internalBannerResponse.bannerItems.map({ banner -> Banner in
            let banner = Self.banner(fromInternalBanner: banner)

            return banner

        })

        return BannerResponse(bannerItems: banners)

    }

    static func banner(fromInternalBanner internalBanner: SportRadarModels.Banner) -> Banner {
        return Banner(id: internalBanner.id, name: internalBanner.name, title: internalBanner.title, imageUrl: internalBanner.imageUrl, bodyText: internalBanner.bodyText, type: internalBanner.type)
    }

    // Favorites
    static func favoritesListResponse(fromInternalFavoritesListResponse internalFavoritesListResponse: SportRadarModels.FavoritesListResponse) -> FavoritesListResponse {

        let favoritesList = internalFavoritesListResponse.favoritesList.map({ favoriteList -> FavoriteList in
            let favoriteList = Self.favoriteList(fromInternalFavoriteList: favoriteList)

            return favoriteList

        })

        return FavoritesListResponse(favoritesList: favoritesList)

    }

    static func favoriteList(fromInternalFavoriteList internalFavoriteList: SportRadarModels.FavoriteList) -> FavoriteList {
        return FavoriteList(id: internalFavoriteList.id)
    }

}
