//
//  MatchLineTableCellViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 10/05/2024.
//

import Foundation
import Combine
import ServicesProvider

class MatchLineTableCellViewModel {
    
    @Published private(set) var match: Match?
    @Published private(set) var matchWidgetCellViewModel: MatchWidgetCellViewModel?
    
    @Published private(set) var status: MatchWidgetStatus = .unknown
    
    private var secundaryMarketsSubscription: ServicesProvider.Subscription?
    private var secundaryMarketsPublisher: AnyCancellable?
    
    private var cancellables: Set<AnyCancellable> = []
    
    //
    init(matchId: String, status: MatchWidgetStatus) {
        self.status = status
        self.loadEventDetails(fromId: matchId)
        
        self.observeMatch()
    }
    
    init(match: Match, withFullMarkets fullMarkets: Bool = false) {
        if !fullMarkets {
            self.match = match
            self.loadEventDetails(fromId: match.id)
        }
        else {
            self.match = match
        }
        self.observeMatch()
    }
    
    private func observeMatch() {
        
        self.$match
            .compactMap({ $0 })
            .removeDuplicates(by: { oldMatch, newMatch in
                return oldMatch.id == newMatch.id
            })
            .sink { [weak self] match in
                self?.matchWidgetCellViewModel = MatchWidgetCellViewModel(match: match, matchWidgetStatus: self?.status ?? .unknown)
            }
            .store(in: &self.cancellables)
            
    }
    
    deinit {
        print("MatchLineTableCellViewModel.deinit")
    }
    
    //
    private func loadEventDetails(fromId id: String) {
        
        if let match = self.match {
            // We already have an event
            if match.status.isLive {
                self.loadLiveEventDetails(matchId: match.id)
            }
            else {
                self.loadPreLiveEventDetails(matchId: match.id)
            }
        }
        else if self.status == .live {
            // We only have the event Id but we know its live
            self.loadLiveEventDetails(matchId: id)
        }
        else {
            // We only have the event Id, we need to check if it's live or prelive
            Env.servicesProvider.getEventLiveData(eventId: id)
                .sink { [weak self] completion in
                    switch completion {
                    case .finished:
                        print("getEventLiveData completed")
                    case .failure(let error):
                        switch error {
                        case .resourceUnavailableOrDeleted:
                            self?.loadPreLiveEventDetails(matchId: id)
                        default:
                            print("getEventLiveData other error:", dump(error))
                        }
                    }
                } receiveValue: { [weak self] eventLiveData in
                    // The event is live
                    self?.loadLiveEventDetails(matchId: id)
                }
                .store(in: &self.cancellables)
            
        }
        
    }
}

extension MatchLineTableCellViewModel {
    
    private func loadLiveEventDetails(matchId: String) {
        
        self.secundaryMarketsPublisher?.cancel()
        self.secundaryMarketsPublisher = nil
        
        self.secundaryMarketsPublisher = Publishers.CombineLatest(
            Env.servicesProvider.subscribeEventSecundaryMarkets(eventId: matchId),
            SecundaryMarketsService.fetchSecundaryMarkets()
                .mapError { error in ServiceProviderError.errorMessage(message: error.localizedDescription) }
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            print("loadLiveEventDetails subscribeEventSecundaryMarkets completion \(matchId) \(completion)")
        } receiveValue: { [weak self] subscribableContentMatch, secundaryMarkets in
            switch subscribableContentMatch {
            case .connected(subscription: let subscription):
                self?.secundaryMarketsSubscription = subscription
            case .contentUpdate(content: let updatedEvent):
                print("subscribeEventSecundaryMarkets match with sec markets: \(updatedEvent)")
                let mappedMatch = ServiceProviderModelMapper.match(fromEvent: updatedEvent)
                
                var statsForMarket: [String: String?] = [:]
                
                if var oldMatch = self?.match {
                    let firstMarket = oldMatch.markets.first // Capture the first market
                    
                    var newMarkets: [Market] = []
                    var mergedMarkets: [Market] = []
                    
                    for market in  mappedMatch.markets {
                        if market.id != firstMarket?.id {
                            newMarkets.append(market)
                        }
                    }
                    
                    if let first = firstMarket {
                        mergedMarkets = [first] + newMarkets
                    }
                    else {
                        mergedMarkets = newMarkets
                    }
                    
                    if let secundaryMarketsForSport = secundaryMarkets.first(where: { secundarySportMarket in
                        if secundarySportMarket.sportId == (mappedMatch.sport.alphaId ?? "") {
                            return true
                        }
                        if secundarySportMarket.sportId == (mappedMatch.sportIdCode ?? "") {
                            return true
                        }
                        return false
                    }) {
                        for secundaryMarket in secundaryMarketsForSport.markets {
                            if var foundMarket = mergedMarkets.first(where: { market in
                                (market.marketTypeId ?? "") == secundaryMarket.typeId
                            }) {
                                foundMarket.statsTypeId = secundaryMarket.statsId
                                statsForMarket[foundMarket.id] = secundaryMarket.statsId
                                
                                print("foundMarket updated \(foundMarket)")
                            }
                        }
                    }
                    
                    var finalMarkets: [Market] = []
                    
                    for market in mergedMarkets {
                        if let statsTypeId = statsForMarket[market.id] {
                            var newMarket = market
                            newMarket.statsTypeId = statsTypeId
                            finalMarkets.append(newMarket)
                        }
                        else {
                            var newMarket = market
                            finalMarkets.append(newMarket)
                        }
                    }
                    
                    oldMatch.markets = finalMarkets
                    self?.match = oldMatch
                } else {
                    self?.match = mappedMatch
                }
                
            case .disconnected:
                break
            }
        }
    }
    
    private func loadPreLiveEventDetails(matchId: String) {
        self.secundaryMarketsPublisher = nil
        self.secundaryMarketsSubscription = nil
        
        Publishers.CombineLatest(
            Env.servicesProvider.getEventSecundaryMarkets(eventId: matchId),
            SecundaryMarketsService.fetchSecundaryMarkets()
                .mapError { error in ServiceProviderError.errorMessage(message: error.localizedDescription) }
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            print("getEventSecundaryMarkets completion \(completion)")
        } receiveValue: { [weak self] eventWithSecundaryMarkets, secundaryMarkets in
            var mappedMatch = ServiceProviderModelMapper.match(fromEvent: eventWithSecundaryMarkets)
            
            if var oldMatch = self?.match {
                
                var mergedMarkets: [Market] = mappedMatch.markets
                
                var statsForMarket: [String: String?] = [:]
                
                if let secundaryMarketsForSport = secundaryMarkets.first(where: { secundarySportMarket in
                    if secundarySportMarket.sportId == (mappedMatch.sport.alphaId ?? "") {
                        return true
                    }
                    if secundarySportMarket.sportId == (mappedMatch.sportIdCode ?? "") {
                        return true
                    }
                    return false
                }) {
                    
                    for secundaryMarket in secundaryMarketsForSport.markets {
                        if var foundMarket = mergedMarkets.first(where: { market in
                            (market.marketTypeId ?? "") == secundaryMarket.typeId
                        }) {
                            statsForMarket[foundMarket.id] = secundaryMarket.statsId
                            foundMarket.statsTypeId = secundaryMarket.statsId
                            print("foundMarket updated \(foundMarket)")
                        }
                    }
                }
                
                var finalMarkets: [Market] = []
                
                for market in mergedMarkets {
                    if let statsTypeId = statsForMarket[market.id] {
                        var newMarket = market
                        newMarket.statsTypeId = statsTypeId
                        finalMarkets.append(newMarket)
                    }
                    else {
                        var newMarket = market
                        finalMarkets.append(newMarket)
                    }
                }
                
                oldMatch.markets = finalMarkets
                self?.match = oldMatch
            }
            else {
                var mergedMarkets: [Market] = mappedMatch.markets
                var statsForMarket: [String: String?] = [:]
                
                if let secundaryMarketsForSport = secundaryMarkets.first(where: { secundarySportMarket in
                    if secundarySportMarket.sportId == (mappedMatch.sport.alphaId ?? "") {
                        return true
                    }
                    if secundarySportMarket.sportId == (mappedMatch.sportIdCode ?? "") {
                        return true
                    }
                    return false
                }) {
                    for secundaryMarket in secundaryMarketsForSport.markets {
                        if var foundMarket = mergedMarkets.first(where: { market in
                            (market.marketTypeId ?? "") == secundaryMarket.typeId
                        }) {
                            foundMarket.statsTypeId = secundaryMarket.statsId
                            statsForMarket[foundMarket.id] = secundaryMarket.statsId
                            print("foundMarket updated \(foundMarket)")
                        }
                    }
                }
                
                var finalMarkets: [Market] = []
                
                for market in mergedMarkets {
                    if let statsTypeId = statsForMarket[market.id] {
                        var newMarket = market
                        newMarket.statsTypeId = statsTypeId
                        finalMarkets.append(newMarket)
                    }
                    else {
                        var newMarket = market
                        finalMarkets.append(newMarket)
                    }
                }
                
                mappedMatch.markets = finalMarkets
                
                self?.match = mappedMatch
            }
        }
        .store(in: &self.cancellables)
    }
    
    func processMarkets(forMatch oldMatch: Match, newMarkets: [Market], marketsAdditionalInfo: [SecundarySportMarket], sportId: String) ->  [Market] {
        var statsForMarket: [String: String?] = [:]
        
        let firstMarket = oldMatch.markets.first // Capture the first market
        
        var newMarkets: [Market] = []
        var mergedMarkets: [Market] = []
        
        for market in newMarkets {
            if market.id != firstMarket?.id {
                newMarkets.append(market)
            }
        }
        
        if let first = firstMarket {
            mergedMarkets = [first] + newMarkets
        }
        else {
            mergedMarkets = newMarkets
        }
        
        var marketsAdditionalInfoOrder: [String] = []
        if let secundaryMarketsForSport = marketsAdditionalInfo.first(where: {
            $0.sportId.lowercased() == sportId.lowercased()
        }) {
            for secundaryMarket in secundaryMarketsForSport.markets {
                marketsAdditionalInfoOrder.append(secundaryMarket.typeId)
                if var foundMarket = mergedMarkets.first(where: { market in
                    (market.marketTypeId ?? "") == secundaryMarket.typeId
                }) {
                    foundMarket.statsTypeId = secundaryMarket.statsId
                    statsForMarket[foundMarket.id] = secundaryMarket.statsId
                    
                    print("foundMarket updated \(foundMarket)")
                }
            }
        }
        
        var finalMarkets: [Market] = []
        
        for market in mergedMarkets {
            if let statsTypeId = statsForMarket[market.id] {
                var newMarket = market
                newMarket.statsTypeId = statsTypeId
                finalMarkets.append(newMarket)
            }
            else {
                var newMarket = market
                finalMarkets.append(newMarket)
            }
        }
        
        // Sort the finalMarkets based on the order in marketsAdditionalInfoOrder
        finalMarkets.sort { (market1, market2) -> Bool in
            guard
                let index1 = marketsAdditionalInfoOrder.firstIndex(of: market1.typeId),
                let index2 = marketsAdditionalInfoOrder.firstIndex(of: market2.typeId)
            else {
                return false
            }
            return index1 < index2
        }
        
        return finalMarkets
        
    }

}
