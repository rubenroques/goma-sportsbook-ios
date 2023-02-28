//
//  BannerCellViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 21/10/2021.
//

import Foundation
import Combine

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

    var eventPartId: String?
    var betTypeId: String?

    var match: CurrentValueSubject<EveryMatrix.Match?, Never> = .init(nil)

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

    var cancellables = Set<AnyCancellable>()

    init(id: String, matchId: String?, imageURL: String) {
        self.id = id
        self.matchId = matchId
        let imageURLString = imageURL

        if let matchId = self.matchId {
            self.presentationType = .match(id: matchId)

            if imageURL.contains("https") {
                self.imageURL = URL(string: imageURLString)
            }
            else {
                self.imageURL = URL(string: EveryMatrixInfo.staticHost + imageURLString)
            }

            // self.requestMatchInfo(matchId)
            // self.requestMatchOdds()
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
    
}
