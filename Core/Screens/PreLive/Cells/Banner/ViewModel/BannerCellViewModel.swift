//
//  BannerCellViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 21/10/2021.
//

import Foundation
import Combine
import ServicesProvider

class BannerLineCellViewModel {

    var banners: [BannerCellViewModel]

    init(banners: [BannerCellViewModel]) {
        self.banners = banners
    }
}

class BannerCellViewModel {

    enum PresentationType {
        case image
        case match(id: String)
        case externalMatch(contentId: String, imageURLString: String,
                           eventPartId: String, betTypeId: String)
        case externalLink(imageURLString: String, linkURLString: String)
        case externalStream(imageURLString: String, streamURLString: String)
    }

    var id: String
    var presentationType: PresentationType
    var matchId: String?
    var imageURL: URL?
    var marketId: String?

    var eventPartId: String?
    var betTypeId: String?

    var match: CurrentValueSubject<Match?, Never> = .init(nil)

    var completeMatch: CurrentValueSubject<Match?, Never> = .init(nil)

    // Aggregator variables
    var matches: [String: EveryMatrix.Match] = [:]
    // var markets: [String: EveryMatrix.Market] = [:]
    var marketsForMatch: [String: Set<String>] = [:]   // [Match ID: [Markets IDs] ]
    var betOutcomes: [String: EveryMatrix.BetOutcome] = [:]     // [Market: Content]
    var bettingOffers: [String: EveryMatrix.BettingOffer] = [:] // [OutcomeId: Content]

    var marketsPublishers: [String: CurrentValueSubject<EveryMatrix.Market, Never>] = [:]
    var bettingOfferPublishers: [String: CurrentValueSubject<EveryMatrix.BettingOffer, Never>] = [:]

    var bettingOutcomesForMarket: [String: Set<String>] = [:]

    var marketOutcomeRelations: [String: EveryMatrix.MarketOutcomeRelation] = [:]

    private var serviceProviderSubscriptions: [String: ServicesProvider.Subscription] = [:]
    private var marketsCancellables: [String: AnyCancellable] = [:]

    var cancellables = Set<AnyCancellable>()

    let dateFormatter = DateFormatter()

    init(id: String, matchId: String?, imageURL: String, marketId: String?) {
        self.id = id
        self.matchId = matchId
        self.marketId = marketId
        let imageURLString = imageURL

        if let matchId = self.matchId {
            self.presentationType = .match(id: matchId)

            if imageURL.contains("https") {
                self.imageURL = URL(string: imageURLString)
            }
            else {
                self.imageURL = URL(string: EveryMatrixInfo.staticHost + imageURLString)
            }

            if let marketId = marketId {
                self.requestMatchInfo(matchId: matchId, marketId: marketId)
                // self.requestMatchOdds()
            }
        }
        else {
            self.presentationType = .image

            if imageURL.contains("https") {
                self.imageURL = URL(string: imageURLString)
            }
            else {
                self.imageURL = URL(string: EveryMatrixInfo.staticHost + imageURLString)
            }
        }

    }

    init(presentationType: PresentationType, imageURL: String? = nil) {

        self.id = ""
        self.presentationType = presentationType

        let imageURLString = imageURL ?? ""

        switch presentationType {
        case .image:
            self.imageURL = URL(string: EveryMatrixInfo.staticHost + imageURLString)

        case .match(let id):
            self.imageURL = URL(string: EveryMatrixInfo.staticHost + imageURLString)
            // self.requestMatchInfo(id)
            // self.requestMatchOdds()

        case .externalMatch(let contentId, let imageURLString, let eventPartId, let betTypeId):
            self.matchId = contentId
            self.imageURL = URL(string: imageURLString)
            self.eventPartId = eventPartId
            self.betTypeId = betTypeId
            // self.requestMatchInfo(contentId)
            // self.requestMatchOdds()

        case .externalLink(let imageURLString, _):
            self.imageURL = URL(string: imageURLString)

        case .externalStream(let imageURLString, _):
            self.imageURL = URL(string: imageURLString)
        }

    }

    func oddPublisherForBettingOfferId(_ id: String) -> AnyPublisher<EveryMatrix.BettingOffer, Never>? {
        return bettingOfferPublishers[id]?.eraseToAnyPublisher()
    }

    func requestMatchInfo(matchId: String, marketId: String) {

        let marketSubscriber = Env.servicesProvider.subscribeToMarketDetails(withId: marketId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error retrieving data! \(error)")
                case .finished:
                    print("Data retrieved!")
                }
            } receiveValue: { [weak self] subscribableContent in
                switch subscribableContent {
                case .connected(let subscription):
                    self?.serviceProviderSubscriptions[marketId] = subscription
                case .contentUpdate(let market):
                    let market = market
                    let internalMarket = ServiceProviderModelMapper.market(fromServiceProviderMarket: market)
                    self?.setupMarketInfo(market: internalMarket, matchId: matchId)
                case .disconnected:
                    print("Banner subscribeToMarketDetails disconnected")
                }
            }
        
        self.marketsCancellables[marketId] = marketSubscriber
    }

    private func setupMarketInfo(market: Market, matchId: String) {
        
        //        if self.completeMatch.value == nil {

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
        let matchDate = dateFormatter.date(from: market.startDate ?? "")

        let match = Match(id: matchId,
                          competitionId: "",
                          competitionName: "",
                          homeParticipant: Participant(id: "", name: market.homeParticipant ?? ""),
                          awayParticipant: Participant(id: "", name: market.awayParticipant ?? ""),
                          date: matchDate,
                          sport: Sport(id: "1", name: "", alphaId: "", numericId: "", showEventCategory: false, liveEventsCount: 0),
                          numberTotalOfMarkets: 1,
                          markets: [market],
                          rootPartId: "",
                          status: .unknown)

        if self.match.value.noValue {
            self.match.send(match)
        }
        self.completeMatch.send(match)
        //        }
    }
    
}
