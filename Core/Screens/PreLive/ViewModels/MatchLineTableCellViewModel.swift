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
    init(matchId: String, status: MatchWidgetStatus = .unknown) {
        self.status = status
        self.loadEventDetails(fromId: matchId)
        
        self.observeMatchValues()
    }
    
    init(match: Match, status: MatchWidgetStatus = .unknown) {
        self.status = status

        self.match = match
        self.loadEventDetails(fromId: match.id)
        
        self.observeMatchValues()
    }
    
    private func observeMatchValues() {
        
        self.$match
            .compactMap({ $0 })
            .removeDuplicates(by: { oldMatch, newMatch in
                let sameMatch = oldMatch.id == newMatch.id
                let sameMarkets = oldMatch.markets.map(\.id) == newMatch.markets.map(\.id)
                return sameMatch && sameMarkets
            })
            .sink { [weak self] match in
                if let matchWidgetCellViewModel = self?.matchWidgetCellViewModel {
                    matchWidgetCellViewModel.updateWithMatch(match)
                }
                else {
                    self?.matchWidgetCellViewModel = MatchWidgetCellViewModel(match: match, matchWidgetStatus: self?.status ?? .unknown)
                }
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
            else if self.status == .live {
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
            print("loadLiveEventDetails \(matchId) completion  \(completion)")
        } receiveValue: { [weak self] subscribableContentMatch, marketsAdditionalInfos in
            switch subscribableContentMatch {
            case .connected(subscription: let subscription):
                self?.secundaryMarketsSubscription = subscription
            case .contentUpdate(content: let updatedEvent):
                guard
                    var newMatch = ServiceProviderModelMapper.match(fromEvent: updatedEvent)
                else {
                    return
                }
                
                let sportId = newMatch.sport.alphaId ?? (newMatch.sportIdCode ?? "")
                
                let finalMarkets = self?.processMarkets(forMatch: self?.match,
                                                        newMarkets: newMatch.markets,
                                                        marketsAdditionalInfo: marketsAdditionalInfos,
                                                        sportId: sportId) ?? []
                
                if var oldMatch = self?.match, oldMatch.markets.isNotEmpty {
                    oldMatch.markets = finalMarkets
                    self?.match = oldMatch
                } else {
                    newMatch.markets = finalMarkets
                    self?.match = newMatch
                }
                
            case .disconnected:
                break
            }
        }
    }
    
    private func loadPreLiveEventDetails(matchId: String) {
        self.secundaryMarketsPublisher?.cancel()
        self.secundaryMarketsPublisher = nil
        
        self.secundaryMarketsPublisher = Publishers.CombineLatest(
            Env.servicesProvider.getEventSecundaryMarkets(eventId: matchId),
            SecundaryMarketsService.fetchSecundaryMarkets()
                .mapError { error in ServiceProviderError.errorMessage(message: error.localizedDescription) }
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            print("loadPreLiveEventDetails completion \(completion)")
        } receiveValue: { [weak self] eventWithSecundaryMarkets, marketsAdditionalInfos in
            guard
                var newMatch = ServiceProviderModelMapper.match(fromEvent: eventWithSecundaryMarkets)
            else {
                return
            }
            
            let sportId = newMatch.sport.alphaId ?? (newMatch.sportIdCode ?? "")
            
            let finalMarkets = self?.processMarkets(forMatch: self?.match,
                                                    newMarkets: newMatch.markets,
                                                    marketsAdditionalInfo: marketsAdditionalInfos,
                                                    sportId: sportId) ?? []
            
            // If we got the event detail via EventSummary
            // the event come has no markets.
            if var oldMatch = self?.match, oldMatch.markets.isNotEmpty {
                oldMatch.markets = finalMarkets
                self?.match = oldMatch
            }
            else {
                newMatch.markets = finalMarkets
                self?.match = newMatch
            }
        }
    }
    
    private func processMarkets(forMatch oldMatch: Match?, newMarkets: [Market], marketsAdditionalInfo: [SecundarySportMarket], sportId: String) -> [Market] {
        var statsForMarket: [String: String?] = [:]
        
        let firstMarket = oldMatch?.markets.first // Capture the first market
        
        var additionalMarkets: [Market] = []
        var mergedMarkets: [Market] = []
        
        for market in newMarkets {
            if market.id != firstMarket?.id {
                additionalMarkets.append(market)
            }
        }
        
        if let first = firstMarket {
            mergedMarkets = [first] + additionalMarkets
        }
        else {
            mergedMarkets = additionalMarkets
        }
        
        var marketsAdditionalInfoOrder: [String: Int] = [:]
        if let secundaryMarketsForSport = marketsAdditionalInfo.first(where: {
            $0.sportId.lowercased() == sportId.lowercased()
        }) {
            for (index, secundaryMarket) in secundaryMarketsForSport.markets.enumerated() {
                marketsAdditionalInfoOrder[secundaryMarket.marketTypeId] = index
                if var foundMarket = mergedMarkets.first(where: { market in
                    (market.marketTypeId ?? "") == secundaryMarket.marketTypeId
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
                let newMarket = market
                finalMarkets.append(newMarket)
            }
        }
        
        // Sort the finalMarkets based on the order in marketsAdditionalInfoOrder
        finalMarkets.sort { market1, market2 -> Bool in
            let index1 = marketsAdditionalInfoOrder[market1.marketTypeId ?? ""] ?? 0
            let index2 = marketsAdditionalInfoOrder[market2.marketTypeId ?? ""] ?? 0
            return index1 < index2
        }
        
        return finalMarkets
        
    }

}
