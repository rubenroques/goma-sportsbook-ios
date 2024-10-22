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
    
//    var match2: Match {
//        return match2Subject.value
//    }
//    
//    private var match2Subject: CurrentValueSubject<Match, Never>
//    private var match2Publisher: AnyPublisher<Match, Never> {
//        return match2Subject.eraseToAnyPublisher()
//    }
    
    @Published private(set) var match: Match
    @Published private(set) var matchWidgetCellViewModel: MatchWidgetCellViewModel
    
    @Published private(set) var status: MatchWidgetStatus = .unknown
    
    private var secundaryMarketsSubscription: ServicesProvider.Subscription?
    private var secundaryMarketsPublisher: AnyCancellable?
    
    private var cancellables: Set<AnyCancellable> = []

    //
    init(match: Match, status: MatchWidgetStatus = .unknown) {
        self.status = status
        
        self.match = match
        self.matchWidgetCellViewModel = MatchWidgetCellViewModel(match: match, matchWidgetStatus: status)
        
        self.observeMatchValues()
        self.loadEventDetails()
    }
    
    private func observeMatchValues() {

        self.$match
            .removeDuplicates(by: { oldMatch, newMatch in
                
                // let oldMatchDesc = "[\(oldMatch.id) \(oldMatch.homeParticipant.name) vs \(oldMatch.awayParticipant.name)]"
                // let newMatchDesc = "[\(newMatch.id) \(newMatch.homeParticipant.name) vs \(newMatch.awayParticipant.name)]"
                // print("BlinkDebug >LineVC - comparing \(oldMatchDesc) to \(newMatchDesc)")
                      
                let visuallySimilar = Match.visuallySimilar(lhs: oldMatch, rhs: newMatch)
                if visuallySimilar.0 {
                    // print("BlinkDebug >LineVC - ignoring")
                    return true
                }
                else {
                    // print("BlinkDebug >LineVC - not ignoring due to diff:\(visuallySimilar.1 ?? "")")
                    return false
                }
            })
            .sink { [weak self] match in
                self?.matchWidgetCellViewModel.updateWithMatch(match)
            }
            .store(in: &self.cancellables)
    }
    
    deinit {
        print("MatchLineTableCellViewModel.deinit")
    }
    
    //
    private func loadEventDetails() {
        if self.match.status.isLive {
            self.loadLiveEventDetails(matchId: match.id)
        }
        else if self.status == .live {
            self.loadLiveEventDetails(matchId: match.id)
        }
        else {
            self.loadPreLiveEventDetails(matchId: match.id)
        }
    }
}

extension MatchLineTableCellViewModel {
    
    private func loadLiveEventDetails(matchId: String) {
        self.secundaryMarketsPublisher?.cancel()
        self.secundaryMarketsPublisher = nil
        
        self.secundaryMarketsPublisher = Publishers.CombineLatest(
            Env.servicesProvider.subscribeEventMarkets(eventId: matchId),
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
    
    private func processMarkets(forMatch oldMatch: Match?, 
                                newMarkets: [Market],
                                marketsAdditionalInfo: [SecundarySportMarket], 
                                sportId: String) -> [Market]
    {
        var statsForMarket: [String: String?] = [:]
        var firstMarket = oldMatch?.markets.first // Capture the first market
        var additionalMarkets: [Market] = []

        var newMainMarket: Market? = newMarkets.first { newMarket in
            newMarket.isMainMarket == true
        }

        // Ignore the current market
        for market in newMarkets {
            if market.id != firstMarket?.id && market.id != (newMainMarket?.id ?? "") {
                additionalMarkets.append(market)
            }
        }

        // Get the position for each market and it's stats id
        var marketsAdditionalInfoOrder: [String: Int] = [:]
        if let secundaryMarketsForSport = marketsAdditionalInfo.first(where: {
            $0.sportId.lowercased() == sportId.lowercased()
        }) {
            for (index, secundaryMarket) in secundaryMarketsForSport.markets.enumerated() {
                
                if marketsAdditionalInfoOrder[secundaryMarket.marketTypeId] == nil {
                    marketsAdditionalInfoOrder[secundaryMarket.marketTypeId] = index
                }
                
                if var foundMarket = additionalMarkets.first(where: { market in
                    (market.marketTypeId ?? "") == secundaryMarket.marketTypeId
                }) {
                    foundMarket.statsTypeId = secundaryMarket.statsId
                    statsForMarket[foundMarket.id] = secundaryMarket.statsId                    
                }
            }
        }
        
        var finalMarkets: [Market] = []
        
        for market in additionalMarkets {
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
        
        let mergedMarkets: [Market]

        // replace new first market in the array with a the main market
        if let newMainMarketValue = newMainMarket {


            print("Replacing main market for \(oldMatch?.homeParticipant.name) \(newMainMarketValue.name) \(newMainMarket?.name ?? "---")")

            firstMarket = newMainMarketValue
        }

        // arrange the final list of markets
        if let first = firstMarket {
            mergedMarkets = [first] + finalMarkets
        }
        else {
            mergedMarkets = finalMarkets
        }
        
        return mergedMarkets
    }

}

public protocol VisuallySimilar {
    /// Returns a Boolean value indicating whether two values are visually similar.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func visuallySimilar(lhs: Self, rhs: Self) -> (Bool, String?)
}


extension Match: VisuallySimilar {
    static func visuallySimilar(lhs: Self, rhs: Self) -> (Bool, String?) {
        var equalValue = true
        
        equalValue = equalValue && lhs.id == rhs.id
        if !equalValue { return (false, "Match id diff") }
        
        equalValue = equalValue && lhs.status == rhs.status
        if !equalValue { return (false, "Match status diff") }
        
        equalValue = equalValue && lhs.homeParticipant.id == rhs.homeParticipant.id
        if !equalValue { return (false, "Match awayParticipant id diff") }
        
        equalValue = equalValue && lhs.awayParticipant.id == rhs.awayParticipant.id
        if !equalValue { return (false, "Match awayParticipant id diff") }
        
        equalValue = equalValue && lhs.detailedScores == rhs.detailedScores
        if !equalValue { return (false, "Match detailedScores") }
        
        equalValue = equalValue && lhs.matchTime == rhs.matchTime
        if !equalValue { return (false, "Match detailedScores") }
        
        let arrayEqualValue = Array<Market>.visuallySimilar(lhs: lhs.markets, rhs: rhs.markets)
        equalValue = equalValue && arrayEqualValue.0
        if !equalValue { return (false, arrayEqualValue.1) }
            
        return (equalValue, nil)
    }
}

extension Market: VisuallySimilar {
    static func visuallySimilar(lhs: Self, rhs: Self) -> (Bool, String?) {
        var equalValue = true
        
        equalValue = equalValue && lhs.id == rhs.id
        if !equalValue { return (false, "Market id diff") }
        
        equalValue = equalValue && lhs.name == rhs.name
        if !equalValue { return (false, "Market name diff") }
        
        equalValue = equalValue && lhs.isAvailable == rhs.isAvailable
        if !equalValue { return (false, "Market isAvailable") }
        
        let arrayEqualValue = Array.visuallySimilar(lhs: lhs.outcomes, rhs: rhs.outcomes)
        equalValue = equalValue && arrayEqualValue.0
        if !equalValue { return (false, arrayEqualValue.1) }
        
        return (equalValue, nil)
    }
}

extension Outcome: VisuallySimilar {
    static func visuallySimilar(lhs: Self, rhs: Self) -> (Bool, String?) {
        var equalValue = lhs.id == rhs.id
        if !equalValue { return (false, "Outcome id diff") }
            
        equalValue = equalValue && lhs.translatedName == rhs.translatedName
        if !equalValue { return (false, "Outcome translatedName diff") }
                
        let bettingOfferValue = BettingOffer.visuallySimilar(lhs: lhs.bettingOffer, rhs: rhs.bettingOffer)
        equalValue = equalValue && bettingOfferValue.0
        if !equalValue { return (false, bettingOfferValue.1) }
        
        return (equalValue, nil)
    }
}

extension BettingOffer: VisuallySimilar {
    static func visuallySimilar(lhs: Self, rhs: BettingOffer) -> (Bool, String?) {
        var equalValue = lhs.id == rhs.id
        
        if !equalValue { return (false, "BettingOffer id diff") }
            
        return (equalValue, nil)
    }
}

extension Array: VisuallySimilar where Element: VisuallySimilar {
    public static func visuallySimilar(lhs: Array<Element>, rhs: Array<Element>) -> (Bool, String?) {
        guard lhs.count == rhs.count else { return (false, "array count diff") }
        for (left, right) in zip(lhs, rhs) {
            let equalValue = Element.visuallySimilar(lhs: left, rhs: right)
            if !equalValue.0 {
                return (false, equalValue.1)
            }
        }
        return (true, nil)
    }
}
