//
//  SportRadarError.swift
//
//
//  Created by Ruben Roques on 10/10/2022.
//

import Foundation
import SharedModels

extension SportRadarModelMapper {

    static func eventsGroup(fromInternalEventsGroup internalEventsGroup: SportRadarModels.EventsGroup) -> EventsGroup {
        let events = internalEventsGroup.events.map(Self.event(fromInternalEvent:))
        return EventsGroup(events: events,
                           marketGroupId: internalEventsGroup.marketGroupId)
    }

    static func eventsGroup(fromInternalEvents internalEvents: [SportRadarModels.Event]) -> EventsGroup {
        let events = internalEvents.map(Self.event(fromInternalEvent:))
        return EventsGroup(events: events, marketGroupId: nil)
    }

    static func event(fromInternalEvent internalEvent: SportRadarModels.Event) -> Event {

        let country: Country? = Country.country(withName: internalEvent.tournamentCountryName ?? "")

        let eventMarkets = internalEvent.markets
        let markets = eventMarkets.map(Self.market(fromInternalMarket:))

        let sportRadarSportType = SportRadarModels.SportType(name: internalEvent.sportTypeName ?? "",
                                                             alphaId: internalEvent.sportTypeCode,
                                                             numberEvents: 0,
                                                             numberOutrightEvents: 0,
                                                             numberOutrightMarkets: 0,
                                                             numberLiveEvents: 0)

        let sport = SportRadarModelMapper.sportType(fromSportRadarSportType: sportRadarSportType)

        let scores = Self.scoresDictionary(fromInternalScoresDictionary: internalEvent.scores)

        var mappedActivePlayerServing: ActivePlayerServe?
        if let internalActivePlayerServing = internalEvent.activePlayerServing {
            mappedActivePlayerServing = Self.activePlayerServe(fromInternalActivePlayerServe: internalActivePlayerServing)
        }

        return Event(id: internalEvent.id,
                     homeTeamName: internalEvent.homeName ?? "",
                     awayTeamName: internalEvent.awayName ?? "",
                     homeTeamScore: internalEvent.homeScore,
                     awayTeamScore: internalEvent.awayScore,
                     homeTeamLogoUrl: nil,
                     awayTeamLogoUrl: nil,
                     competitionId: internalEvent.competitionId ?? "",
                     competitionName: internalEvent.competitionName ?? "",
                     sport: sport,
                     sportIdCode: internalEvent.sportIdCode,
                     startDate: internalEvent.startDate ?? Date(),
                     markets: markets,
                     venueCountry: country,
                     numberMarkets: internalEvent.numberMarkets,
                     name: internalEvent.name,
                     trackableReference: internalEvent.trackableReference,
                     status: Self.eventStatus(fromInternalEvent: internalEvent.status),
                     matchTime: internalEvent.matchTime,
                     activePlayerServing: mappedActivePlayerServing,
                     boostedMarket: nil,
                     promoImageURL: nil,
                     scores: scores)
    }

    static func event(fromInternalMarkets internalMarkets: [SportRadarModels.Market]) -> Event? {
        let mappedMarkets = internalMarkets.map(SportRadarModelMapper.market(fromInternalMarket: ))

        guard
            let firstMarket = mappedMarkets.first,
            let eventId = firstMarket.eventId,
            let competitionId = firstMarket.competitionId,
            let competitionName = firstMarket.competitionName,
            let sport = firstMarket.sport
        else {
            return nil
        }

        let event = Event(id: eventId,
                          homeTeamName: "",
                          awayTeamName: "",
                          homeTeamScore: nil,
                          awayTeamScore: nil,
                          homeTeamLogoUrl: nil,
                          awayTeamLogoUrl: nil,
                          competitionId: competitionId,
                          competitionName: competitionName,
                          sport: sport,
                          sportIdCode: nil,
                          startDate: firstMarket.startDate ?? Date(timeIntervalSince1970: 0),
                          markets: mappedMarkets,
                          venueCountry: firstMarket.venueCountry,
                          trackableReference: nil,
                          status: nil,
                          matchTime: nil,
                          activePlayerServing: nil,
                          boostedMarket: nil,
                          promoImageURL: nil,
                          scores: [:])
        return event
    }

    static func scoresDictionary(fromInternalScoresDictionary internalScores: [String: SportRadarModels.Score]) -> [String: Score] {
        return internalScores.mapValues(Self.score(fromInternalScore:))
    }

    static func scores(fromInternalScores internalScores: [SportRadarModels.Score]) -> [Score] {
        return internalScores.map(Self.score(fromInternalScore:))
    }

    static func score(fromInternalScore internalScore: SportRadarModels.Score) -> Score {
        switch internalScore {

        case .set(index: let index, home: let home, away: let away):
            return Score.set(index: index, home: home, away: away)
        case .gamePart(home: let home, away: let away):
            return Score.gamePart(home: home, away: away)
        case .matchFull(home: let home, away: let away):
            return Score.matchFull(home: home, away: away)
        }

    }

    static func eventStatus(fromInternalEvent internalEventStatus: SportRadarModels.EventStatus) -> EventStatus? {
        switch internalEventStatus {
        case .unknown:
            return nil
        case .notStarted:
            return EventStatus.notStarted
        case .inProgress(let detail):
            return EventStatus.inProgress(detail)
        case .ended:
            return EventStatus.ended(internalEventStatus.stringValue)
        }
    }

    static func eventLiveData(fromInternalEventLiveData internalEventLiveData: SportRadarModels.EventLiveDataExtended) -> EventLiveData {

        var eventStatus: EventStatus?
        if let statusValue = internalEventLiveData.status {
            eventStatus = Self.eventStatus(fromInternalEvent: statusValue)
        }

        let mappedScores = Self.scoresDictionary(fromInternalScoresDictionary: internalEventLiveData.scores)

        var mappedActivePlayerServing: ActivePlayerServe?
        if let internalActivePlayerServing = internalEventLiveData.activePlayerServing {
            mappedActivePlayerServing = Self.activePlayerServe(fromInternalActivePlayerServe: internalActivePlayerServing)
        }

        return EventLiveData(id: internalEventLiveData.id,
                             homeScore: internalEventLiveData.homeScore,
                             awayScore: internalEventLiveData.awayScore,
                             matchTime: internalEventLiveData.matchTime,
                             status: eventStatus,
                             detailedScores: mappedScores,
                             activePlayerServing: mappedActivePlayerServing)
    }



    static func market(fromInternalMarket internalMarket: SportRadarModels.Market) -> Market {
        var country: Country?
        if let tournamentCountryName = internalMarket.tournamentCountryName {
           country = Country.country(withName: tournamentCountryName)
        }

        var mappedSport: SportType?
        if  let sportTypeCode = internalMarket.sportTypeCode {
            let sportRadarSportType = SportRadarModels.SportType(name: internalMarket.sportTypeName ?? "",
                                                                 alphaId: sportTypeCode,
                                                                 numberEvents: 0,
                                                                 numberOutrightEvents: 0,
                                                                 numberOutrightMarkets: 0,
                                                                 numberLiveEvents: 0)
            mappedSport = SportRadarModelMapper.sportType(fromSportRadarSportType: sportRadarSportType)
        }

        let outcomes = internalMarket.outcomes.map(Self.outcome(fromInternalOutcome:))

        var outcomesOrder: Market.OutcomesOrder
        switch internalMarket.outcomesOrder {
        case .name:
            outcomesOrder = .name
        case .odds:
            outcomesOrder = .odds
        case .setup:
            outcomesOrder = .setup
        case.none:
            outcomesOrder = .none
        }

        return Market(id: internalMarket.id,
                      name: internalMarket.name,
                      outcomes: outcomes,
                      marketTypeId: internalMarket.marketTypeId,
                      marketFilterId: internalMarket.marketFilterId,
                      eventMarketTypeId: internalMarket.eventMarketTypeId,
                      eventName: internalMarket.eventName,
                      isMainOutright: false,
                      eventMarketCount: internalMarket.eventMarketCount,
                      isTradable: internalMarket.isTradable,
                      startDate: internalMarket.startDate,
                      homeParticipant: internalMarket.homeParticipant,
                      awayParticipant: internalMarket.awayParticipant,
                      eventId: internalMarket.eventId,
                      marketDigitLine: internalMarket.marketDigitLine,
                      outcomesOrder: outcomesOrder,
                      // event related properties
                      competitionId: internalMarket.competitionId,
                      competitionName: internalMarket.competitionName,
                      sport: mappedSport,
                      sportIdCode: internalMarket.sportIdCode,
                      venueCountry: country,
                      customBetAvailable: internalMarket.customBetAvailable,
                      isMainMarket: internalMarket.isMainMarket)
    }

    static func outcome(fromInternalOutcome internalOutcome: SportRadarModels.Outcome) -> Outcome {
        return Outcome(id: internalOutcome.id,
                       name: internalOutcome.name,
                       odd: internalOutcome.odd,
                       marketId: internalOutcome.marketId,
                       orderValue: internalOutcome.orderValue,
                       externalReference: internalOutcome.externalReference,
                       isTradable: internalOutcome.isTradable ?? true,
                       isTerminated: internalOutcome.isTerminated ?? false,
                       customBetAvailableMarket: internalOutcome.customBetAvailableMarket)
    }

    static func banners(fromInternalBanners internalBanners: [SportRadarModels.Banner]) -> BannerResponse {
        let banners = internalBanners.map({ internalBanner in
            return banner(fromInternalBanner: internalBanner)
        })
        return BannerResponse(bannerItems: banners)
    }

    static func banner(fromInternalBanner internalBanner: SportRadarModels.Banner) -> EventBanner {
        return EventBanner(id: internalBanner.id,
                      name: internalBanner.name,
                      title: internalBanner.title,
                      imageUrl: internalBanner.imageUrl,
                      bodyText: internalBanner.bodyText,
                      type: internalBanner.type,
                      linkUrl: internalBanner.linkUrl,
                      marketId: internalBanner.marketId)
    }

    static func promotionalStoriesResponse(fromInternalPromotionalStoriesResponse internalPromotionalStoriesResponse: SportRadarModels.PromotionalStoriesResponse) -> PromotionalStoriesResponse {

        let promotionalStories = internalPromotionalStoriesResponse.promotionalStories.map({ promotionalStory -> PromotionalStory in

            let mappedPromotionalStory = Self.promotionalStory(fromInternalPromotionalStory: promotionalStory)

            return mappedPromotionalStory

        })

        return PromotionalStoriesResponse(promotionalStories: promotionalStories)

    }

    static func promotionalStory(fromInternalPromotionalStory internalPromotionalStory: SportRadarModels.PromotionalStory) -> PromotionalStory {
        return PromotionalStory(id: internalPromotionalStory.id,
                                title: internalPromotionalStory.title,
                                imageUrl: internalPromotionalStory.imageUrl,
                                linkUrl: internalPromotionalStory.linkUrl,
                                bodyText: internalPromotionalStory.bodyText,
                                callToActionText: nil)
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
        return FavoriteList(id: internalFavoriteList.id,
                            name: internalFavoriteList.name,
                            customerId: internalFavoriteList.customerId)
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

    static func topCompetitionData(fromInternalTopCompetitionData internalTopCompetitionData: SportRadarModels.TopCompetitionData) -> TopCompetitionData {

        let topCompetitions = internalTopCompetitionData.competitions.map({ topCompetition -> TopCompetitionPointer in
            let topCompetition = Self.topCompetitionPointer(fromInternalTopCompetitionPointer: topCompetition)
            return topCompetition
        })

        return TopCompetitionData(title: internalTopCompetitionData.title, competitions: topCompetitions)
    }

    static func topCompetitionPointer(fromInternalTopCompetitionPointer internalTopCompetition: SportRadarModels.TopCompetitionPointer) -> TopCompetitionPointer {
        return TopCompetitionPointer(id: internalTopCompetition.id,
                                     name: internalTopCompetition.name,
                                     competitionId: internalTopCompetition.competitionId)
    }

    static func activePlayerServe(fromInternalActivePlayerServe internalActivePlayerServe: SportRadarModels.ActivePlayerServe) -> ActivePlayerServe {
        switch internalActivePlayerServe {
        case .home: return .home
        case .away: return .away
        }
    }

}
