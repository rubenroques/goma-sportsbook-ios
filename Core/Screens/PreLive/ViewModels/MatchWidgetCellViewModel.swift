//
//  MatchWidgetCellViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/10/2021.
//

import Foundation
import ServicesProvider
import Combine
import UIKit

enum MatchWidgetType: String, CaseIterable {
    case normal
    case topImage
    case topImageWithMixMatch
    case topImageOutright
    case boosted
    case backgroundImage
}

enum MatchWidgetStatus: String, CaseIterable {
    case unknown
    case live
    case preLive
}

class MatchWidgetCellViewModel {
    
    //
    //
    @Published private(set) var match: Match // Full match, with markets and live data
    
    private var matchMarketsSubject: CurrentValueSubject<Match, Never>
    private var matchLiveDataSubject: CurrentValueSubject<MatchLiveData?, Never>

    //
    //
    var homeTeamNamePublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { $0.homeParticipant.name }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var awayTeamNamePublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { $0.awayParticipant.name }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var activePlayerServePublisher: AnyPublisher<Match.ActivePlayerServe?, Never> {
        return self.$match
            .map { $0.activePlayerServe }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var mainMarketNamePublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { $0.markets.first?.name ?? ""}
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var countryIdPublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { $0.venue?.id ?? ""}
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var countryISOCodePublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { $0.venue?.isoCode ?? ""}
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var countryFlagImagePublisher: AnyPublisher<UIImage, Never> {
        return Publishers.CombineLatest(self.countryISOCodePublisher, self.countryIdPublisher)
            .map({ countryISOCode, countryId in
                let assetName = Assets.flagName(withCountryCode: countryISOCode != "" ? countryISOCode : countryId)
                return UIImage(named: assetName) ?? UIImage()
            })
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var startDateStringPublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { match in
                if let date = match.date {
                    return MatchWidgetCellViewModel.startDateString(fromDate: date)
                }
                else {
                    return ""
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var startTimeStringPublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { match in
                if let date = match.date {
                    return MatchWidgetCellViewModel.hourDateFormatter.string(from: date)
                }
                else {
                    return ""
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var isTodayPublisher: AnyPublisher<Bool, Never> {
        return self.$match
            .map { match in
                if let date = match.date {
                    return Env.calendar.isDateInToday(date)
                }
                else {
                    return false
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var isLiveCardPublisher: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest(self.$matchWidgetStatus, self.$match)
            .map { matchWidgetStatus, match in
                if matchWidgetStatus == .live {
                    return true
                }
                
                switch match.status {
                case .notStarted, .unknown:
                    return false
                case .inProgress, .ended:
                    return true
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    
    var matchScorePublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { match in
                var homeScore = "0"
                var awayScore = "0"
                if let homeScoreInt = match.homeParticipantScore {
                    homeScore = "\(homeScoreInt)"
                }
                if let awayScoreInt = match.awayParticipantScore {
                    awayScore = "\(awayScoreInt)"
                }
                return "\(homeScore) - \(awayScore)"
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var detailedScoresPublisher: AnyPublisher<([String: Score], String), Never> {
        return self.$match
            .map { match in
                return (match.detailedScores ?? [:], match.sport.alphaId ?? "")
            }
            .eraseToAnyPublisher()
    }
    
    var sportIconImagePublisher: AnyPublisher<UIImage, Never> {
        return self.$match
            .map { match in
                if let sportIconImage = UIImage(named: "sport_type_icon_\(match.sport.id)") {
                    return sportIconImage
                }
                else if let defaultImage = UIImage(named: "sport_type_icon_default") {
                    return defaultImage
                }
                else {
                    return UIImage()
                }
            }
            .eraseToAnyPublisher()
    }
    
    
    var matchTimeDetailsPublisher: AnyPublisher<String?, Never> {
        return self.$match.map { match in
            let details = [match.matchTime, match.detailedStatus]
            return details.compactMap({ $0 }).joined(separator: " - ")
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
        
    }
    
    var competitionNamePublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { $0.competitionName }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var promoImageURLPublisher: AnyPublisher<URL?, Never> {
        return self.$match
            .map { match in
                return URL(string: match.promoImageURL ?? "")
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var isDefaultMarketAvailablePublisher: AnyPublisher<Bool, Never> {
        return self.defaultMarketPublisher.flatMap { defaultMarket in
            guard
                let defaultMarketValue = defaultMarket
            else {
                return Just(false).setFailureType(to: Never.self).eraseToAnyPublisher()
            }
            
            let isMarketAvailable = defaultMarketValue.isAvailable
            
            // we try to subscribe to it on the lists 
            return Env.servicesProvider.subscribeToEventOnListsMarketUpdates(withId: defaultMarketValue.id)
                .map({ (serviceProviderMarket: ServicesProvider.Market?) -> Bool in
                    if let serviceProviderMarketValue = serviceProviderMarket {
                        return serviceProviderMarketValue.isTradable
                    }
                    else {
                        return isMarketAvailable
                    }
                })
                .replaceError(with: isMarketAvailable)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    var defaultMarketPublisher: AnyPublisher<Market?, Never> {
        return self.$match
            .map { $0.markets.first }
            .eraseToAnyPublisher()
    }
    
    var eventNamePublisher: AnyPublisher<String?, Never> {
        return self.$match
            .map { match in
                return match.venue?.name ?? match.competitionName
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var outrightNamePublisher: AnyPublisher<String?, Never> {
        return self.$match
            .map { match in
                return match.competitionOutright?.name
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var isFavoriteMatchPublisher: AnyPublisher<Bool, Never> {
        return self.$match
            .map { match in
                return Env.favoritesManager.isEventFavorite(eventId: match.id)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var canHaveCashbackPublisher: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest(self.$match, self.$matchWidgetType)
            .map { match, matchWidgetType in
                if RePlayFeatureHelper.shouldShowRePlay(forMatch: match) {
                    return matchWidgetType == .normal || matchWidgetType == .topImage || matchWidgetType == .topImageWithMixMatch
                }
                return false
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var currentCollectionPage: CurrentValueSubject<Int, Never> = .init(0)
    
    
    //
    struct BoostedOutcome {
        var type: String
        var name: String
        var valueAttributedString: NSAttributedString
        
        init(type: String, name: String, valueAttributedString: NSAttributedString) {
            self.type = type
            self.name = name
            self.valueAttributedString = valueAttributedString
        }
        
        init() {
            self.type = "home"
            self.name = ""
            self.valueAttributedString = NSAttributedString(string: "-")
        }
    }
    
    @Published private(set) var oldBoostedOddOutcome: BoostedOutcome? = nil
    
    @Published private(set) var matchWidgetStatus: MatchWidgetStatus = .unknown
    @Published private(set) var matchWidgetType: MatchWidgetType = .normal
        
    private var liveMatchDetailsSubscription: ServicesProvider.Subscription?

    private var cancellables: Set<AnyCancellable> = []
    
    init(match: Match, matchWidgetType: MatchWidgetType = .normal, matchWidgetStatus: MatchWidgetStatus = .unknown) {
                      
        self.match = match
        
        // let viewModelDesc = "[\(match.id) \(match.homeParticipant.name) vs \(match.awayParticipant.name)]"
        // print("BlinkDebug: CellVM init \(viewModelDesc) \(matchWidgetType) \(matchWidgetStatus)")
        
        switch matchWidgetStatus {
        case .live, .preLive:
            self.matchWidgetStatus = matchWidgetStatus
        case .unknown:
            if match.status.isLive || match.status.isPostLive {
                self.matchWidgetStatus = .live
            }
            else {
                self.matchWidgetStatus = .preLive
            }
        }
        
        self.matchWidgetType = matchWidgetType
        
        self.matchMarketsSubject = .init(match)
        self.matchLiveDataSubject = .init(nil)
        
        var shouldRequestLiveDataFallback = false
        switch matchWidgetStatus {
        case .live:
            shouldRequestLiveDataFallback = true
        case .preLive, .unknown:
            shouldRequestLiveDataFallback = false
        }
        
        // Our match published property is the result of joining
        // the match markets and infos in the matchMarketsSubject
        // with the match Live Data details
        Publishers.CombineLatest(self.matchMarketsSubject, self.matchLiveDataSubject)
            .map { match, matchLiveData -> Match in
                
                var matchValue = match
                
                guard
                    let matchLiveDataValue = matchLiveData
                else {
                    return matchValue
                }
                                      
                if let newStatus = matchLiveDataValue.status {
                    matchValue.status = newStatus
                }
                if let newHomeScore = matchLiveDataValue.homeScore {
                    matchValue.homeParticipantScore = newHomeScore
                }
                if let newAwayScore = matchLiveDataValue.awayScore {
                    matchValue.awayParticipantScore = newAwayScore
                }
                
                if let newMatchTime = matchLiveDataValue.matchTime {
                    matchValue.matchTime = newMatchTime
                }
                if let newDetailedScores = matchLiveDataValue.detailedScores {
                    matchValue.detailedScores = newDetailedScores
                }
                
                matchValue.activePlayerServe = matchLiveDataValue.activePlayerServing
                
                return matchValue
            }
            .sink { [weak self] updatedMatch in
                self?.match = updatedMatch
            }
            .store(in: &self.cancellables)
        
        // TODO:
        // Keep our matchWidgetStatus updated with the match
        // mainly from notStarted -> live
        
        // Request the updated content
        self.subscribeMatchLiveData(withId: match.id, shouldRequestLiveDataFallback: shouldRequestLiveDataFallback)
        self.loadBoostedOddOldValueIfNeeded()
    }
    
    deinit {
        
    }

    func updateWithMatch(_ match: Match) {
        self.matchMarketsSubject.send(match)
    }
    
}

//
// Load Live data updates
extension MatchWidgetCellViewModel {
    
    private func subscribeMatchLiveData(withId matchId: String, shouldRequestLiveDataFallback fallback: Bool) {
        self.subscribeMatchLiveDataOnLists(withId: matchId, shouldRequestLiveDataFallback: fallback)
    }
    
    private func subscribeMatchLiveDataOnLists(withId matchId: String, shouldRequestLiveDataFallback: Bool) {
        
        Env.servicesProvider.subscribeToEventOnListsLiveDataUpdates(withId: matchId)
            .compactMap({ $0 })
            .map(ServiceProviderModelMapper.matchLiveData(fromServiceProviderEvent:))
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    print("MatchWidgetCellViewModel subscribeMatchLiveDataOnLists finished")
                case .failure(let error):
                    switch error {
                    case .resourceNotFound:
                        print("MatchWidgetCellViewModel subscribeMatchLiveDataOnLists resourceNotFound should fallback: \(shouldRequestLiveDataFallback)")
                        if shouldRequestLiveDataFallback {
                            self?.subscribeMatchLiveDataUpdates(withId: matchId)
                        }
                    default:
                        print("MatchWidgetCellViewModel subscribeMatchLiveDataOnLists Error retrieving data! \(error)")
                    }
                }
            }, receiveValue: { [weak self] matchLiveData in
                self?.matchLiveDataSubject.send(matchLiveData)
            })
            .store(in: &self.cancellables)
    }
    
    private func subscribeMatchLiveDataUpdates(withId matchId: String) {
        Env.servicesProvider.subscribeToLiveDataUpdates(forEventWithId: matchId)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    print("MatchWidgetCellViewModel subscribeMatchLiveDataUpdates finished")
                case .failure(let error):
                    print("MatchWidgetCellViewModel subscribeMatchLiveDataUpdates error \(error)")
                }
                self?.liveMatchDetailsSubscription = nil
            }, receiveValue: { [weak self] (eventSubscribableContent: SubscribableContent<ServicesProvider.EventLiveData>) in
                switch eventSubscribableContent {
                case .connected(let subscription):
                    self?.liveMatchDetailsSubscription = subscription
                case .contentUpdate(let eventLiveData):
                    let matchLiveData = ServiceProviderModelMapper.matchLiveData(fromServiceProviderEventLiveData: eventLiveData)
                    self?.matchLiveDataSubject.send(matchLiveData)
                case .disconnected:
                    break
                }
            })
            .store(in: &self.cancellables)
    
    }
}

// Load Boosted Odds old value
extension MatchWidgetCellViewModel {
    
    private func loadBoostedOddOldValueIfNeeded() {
        
        guard
            self.matchWidgetType == .boosted,
            let originalMarketId = self.match.oldMainMarketId
        else {
            return
        }
        
        Publishers.CombineLatest(
            Env.servicesProvider.getMarketInfo(marketId: originalMarketId)
                .map(ServiceProviderModelMapper.market(fromServiceProviderMarket:)),
            self.$match
                .compactMap({ $0 })
                .setFailureType(to: ServicesProvider.ServiceProviderError.self)
        )
        .sink { _ in
            print("Env.servicesProvider.getMarketInfo(marketId: old boosted market completed")
        } receiveValue: { [weak self] market, match in

            if let firstCurrentOutcomeName = match.markets.first?.outcomes[safe: 0]?.typeName.lowercased(),
               let outcome = market.outcomes.first(where: { outcome in outcome.typeName.lowercased() == firstCurrentOutcomeName }) 
            {
                let oddValue = OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd)
                let attributes = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
                let attributedString = NSAttributedString(string: oddValue, attributes: attributes)
                self?.oldBoostedOddOutcome = BoostedOutcome(type: "home", name: firstCurrentOutcomeName, valueAttributedString: attributedString)
            }
            else if let secondCurrentOutcomeName = match.markets.first?.outcomes[safe: 1]?.typeName.lowercased(),
               let outcome = market.outcomes.first(where: { outcome in outcome.typeName.lowercased() == secondCurrentOutcomeName })
            {
                let oddValue = OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd)
                let attributes = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
                let attributedString = NSAttributedString(string: oddValue, attributes: attributes)
                self?.oldBoostedOddOutcome = BoostedOutcome(type: "draw", name: secondCurrentOutcomeName, valueAttributedString: attributedString)
            }
            else if let thirdCurrentOutcomeName = match.markets.first?.outcomes[safe: 2]?.typeName.lowercased(),
               let outcome = market.outcomes.first(where: { outcome in outcome.typeName.lowercased() == thirdCurrentOutcomeName }) 
            {
                let oddValue = OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd)
                let attributes = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
                let attributedString = NSAttributedString(string: oddValue, attributes: attributes)
                self?.oldBoostedOddOutcome = BoostedOutcome(type: "away", name: thirdCurrentOutcomeName, valueAttributedString: attributedString)
            }
            else {
                self?.oldBoostedOddOutcome = BoostedOutcome()
            }
        }
        .store(in: &self.cancellables)
    }
}

//
extension MatchWidgetCellViewModel {
    
    static var hourDateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter
    }()
    
    static var dayDateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .short
        return dateFormatter
    }()
    
    static var normalDateFormatter: DateFormatter = {
        var dateFormatter = Date.buildFormatter(locale: Env.locale)
        return dateFormatter
    }()
    
    static var relativeDateFormatter: DateFormatter = {
        var dateFormatter = Date.buildFormatter(locale: Env.locale, hasRelativeDate: true)
        return dateFormatter
    }()
    
    static func startDateString(fromDate date: Date) -> String {
        let relativeFormatter = MatchWidgetCellViewModel.relativeDateFormatter
        let relativeDateString = relativeFormatter.string(from: date)
        // "Jan 18, 2018"
        
        let nonRelativeFormatter = MatchWidgetCellViewModel.normalDateFormatter
        let normalDateString = nonRelativeFormatter.string(from: date)
        // "Jan 18, 2018"
        
        if relativeDateString == normalDateString {
            let customFormatter = Date.buildFormatter(locale: Env.locale, dateFormat: "dd MMM")
            return customFormatter.string(from: date)
        }
        else {
            return relativeDateString // Today, Yesterday
        }
    }
}
