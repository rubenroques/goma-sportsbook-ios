//
//  SportRadarError.swift
//
//
//  Created by Ruben Roques on 10/10/2022.
//

import Foundation
import SharedModels

extension SportRadarModelMapper {

    static func eventsGroup(fromInternalEvents internalEvents: [SportRadarModels.Event]) -> EventsGroup {
        let events = internalEvents.map(Self.event(fromInternalEvent:))
        return EventsGroup(events: events)
    }

    static func event(fromInternalEvent internalEvent: SportRadarModels.Event) -> Event {

        let country: Country? = Country.country(withName: internalEvent.tournamentCountryName ?? "")

        let eventMarkets = internalEvent.markets ?? []
        let markets = eventMarkets.map(Self.market(fromInternalMarket:))

        let sportRadarSportType = SportRadarModels.SportType(name: internalEvent.sportTypeName ?? "",
                                               alphaId: internalEvent.sportTypeCode,
                                               numberEvents: 0,
                                               numberOutrightEvents: 0,
                                               numberOutrightMarkets: 0)

        let sport = SportRadarModelMapper.sportType(fromSportRadarSportType: sportRadarSportType)

        return Event(id: internalEvent.id,
                     homeTeamName: internalEvent.homeName ?? "",
                     awayTeamName: internalEvent.awayName ?? "",
                     homeTeamScore: internalEvent.homeScore,
                     awayTeamScore: internalEvent.awayScore,
                     competitionId: internalEvent.competitionId ?? "",
                     competitionName: internalEvent.competitionName ?? "",
                     sport: sport,
                     startDate: internalEvent.startDate ?? Date(),
                     markets: markets,
                     venueCountry: country,
                     numberMarkets: internalEvent.numberMarkets,
                     name: internalEvent.name,
                     status: Self.eventStatus(fromInternalEvent: internalEvent.status),
                     matchTime: internalEvent.matchTime)
    }

    static func eventStatus(fromInternalEvent internalEventStatus: SportRadarModels.Event.Status) -> Event.Status? {
        switch internalEventStatus {
        case .unknown:
            return nil
        case .notStarted:
            return Event.Status.notStarted
        case .inProgress(let detail):
            return Event.Status.inProgress(detail)
        case .ended:
            return Event.Status.ended
        }
    }
    
    static func market(fromInternalMarket internalMarket: SportRadarModels.Market) -> Market {
        let outcomes = internalMarket.outcomes.map(Self.outcome(fromInternalOutcome:))
        return Market(id: internalMarket.id,
                      name: internalMarket.name,
                      outcomes: outcomes,
                      marketTypeId: internalMarket.marketTypeId,
                      eventMarketTypeId: internalMarket.eventMarketTypeId,
                      eventName: internalMarket.eventName,
                      isMainOutright: false,
                      eventMarketCount: internalMarket.eventMarketCount,
                      isTradable: internalMarket.isTradable ?? true,
                      startDate: internalMarket.startDate,
                      homeParticipant: internalMarket.homeParticipant,
                      awayParticipant: internalMarket.awayParticipant,
                      eventId: internalMarket.eventId)
    }

    static func outcome(fromInternalOutcome internalOutcome: SportRadarModels.Outcome) -> Outcome {
        return Outcome(id: internalOutcome.id,
                       name: internalOutcome.name,
                       odd: internalOutcome.odd,
                       marketId: internalOutcome.marketId,
                       orderValue: internalOutcome.orderValue,
                       externalReference: internalOutcome.externalReference,
                       isTradable: internalOutcome.isTradable ?? true)
    }

    static func bannerResponse(fromInternalBannerResponse internalBannerResponse: SportRadarModels.BannerResponse) -> BannerResponse {

        let banners = internalBannerResponse.bannerItems.map({ banner -> Banner in
            let banner = Self.banner(fromInternalBanner: banner)

            return banner

        })

        return BannerResponse(bannerItems: banners)

    }

    static func banner(fromInternalBanner internalBanner: SportRadarModels.Banner) -> Banner {
        return Banner(id: internalBanner.id, name: internalBanner.name, title: internalBanner.title, imageUrl: internalBanner.imageUrl, bodyText: internalBanner.bodyText, type: internalBanner.type, linkUrl: internalBanner.linkUrl, marketId: internalBanner.marketId)
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
        return FavoriteList(id: internalFavoriteList.id, name: internalFavoriteList.name, customerId: internalFavoriteList.customerId)
    }

    static func favoritesListAddResponse(fromInternalFavoritesListAddResponse internalFavoritesListAddResponse: SportRadarModels.FavoritesListAddResponse) -> FavoritesListAddResponse {

        let favoritesListAddResponse = FavoritesListAddResponse(listId: internalFavoritesListAddResponse.listId)

        return favoritesListAddResponse

    }

    static func favoritesListDeleteResponse(fromInternalFavoritesListDeleteResponse internalFavoritesListDeleteResponse: SportRadarModels.FavoritesListDeleteResponse) -> FavoritesListDeleteResponse {

        let favoritesListDeleteResponse = FavoritesListDeleteResponse(listId: internalFavoritesListDeleteResponse.listId)

        return favoritesListDeleteResponse

    }

    static func favoriteAddResponse(fromInternalFavoriteAddResponse internalFavoriteAddResponse: SportRadarModels.FavoriteAddResponse) -> FavoriteAddResponse {

        let favoriteAddResponse = FavoriteAddResponse(displayOrder: internalFavoriteAddResponse.displayOrder, idAccountFavorite: internalFavoriteAddResponse.idAccountFavorite)

        return favoriteAddResponse

    }

    static func favoritesEventResponse(fromInternalFavoritesEventResponse internalFavoritesEventResponse: SportRadarModels.FavoriteEventResponse) -> FavoriteEventResponse {

        let favoritesEvent = internalFavoritesEventResponse.favoriteEvents.map({ favoriteEvent -> FavoriteEvent in
            let favoriteEvent = Self.favoriteEvent(fromInternalFavoriteEvent: favoriteEvent)

            return favoriteEvent

        })

        return FavoriteEventResponse(favoriteEvents: favoritesEvent)

    }

    static func favoriteEvent(fromInternalFavoriteEvent internalFavoriteEvent: SportRadarModels.FavoriteEvent) -> FavoriteEvent {
        return FavoriteEvent(id: internalFavoriteEvent.id, name: internalFavoriteEvent.name, favoriteListId: internalFavoriteEvent.favoriteListId, accountFavoriteId: internalFavoriteEvent.accountFavoriteId)
    }

}
