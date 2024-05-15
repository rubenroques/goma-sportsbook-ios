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
    @Published private(set) var match: Match?
    
    private var matchMarketsSubject: CurrentValueSubject<Match?, Never>
    private var matchLiveDataSubject: CurrentValueSubject<MatchLiveData?, Never> = .init(nil)

    //
    //
    var homeTeamNamePublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { $0?.homeParticipant.name ?? ""}
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var awayTeamNamePublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { $0?.awayParticipant.name ?? ""}
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var mainMarketNamePublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { $0?.markets.first?.name ?? ""}
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var countryIdPublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { $0?.venue?.id ?? ""}
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var countryISOCodePublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { $0?.venue?.isoCode ?? ""}
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var countryFlagImagePublisher: AnyPublisher<UIImage, Never> {
        return Publishers.CombineLatest(self.countryISOCodePublisher, self.countryIdPublisher)
            .map({ countryISOCode, countryId in
                let assetName = Assets.flagName(withCountryCode: countryISOCode != "" ? countryISOCode : countryId)
                return UIImage(named: assetName) ?? UIImage()
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var startDateStringPublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { match in
                if let date = match?.date {
                    return Self.startDateString(fromDate: date)
                }
                else {
                    return ""
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var startTimeStringPublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { match in
                if let date = match?.date {
                    return MatchWidgetCellViewModel.hourDateFormatter.string(from: date)
                }
                else {
                    return ""
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var isTodayPublisher: AnyPublisher<Bool, Never> {
        return self.$match
            .map { match in
                if let date = match?.date {
                    return Env.calendar.isDateInToday(date)
                }
                else {
                    return false
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var isLiveCardPublisher: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest(self.$matchWidgetStatus, self.$match)
            .map { matchWidgetStatus, match in
                if matchWidgetStatus == .live {
                    return true
                }
                
                guard let match else { return false }
                
                switch match.status {
                case .notStarted, .unknown:
                    return false
                case .inProgress, .ended:
                    return true
                }
            }
            .eraseToAnyPublisher()
    }
    
    
    var matchScorePublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { match in
                var homeScore = "0"
                var awayScore = "0"
                if let homeScoreInt = match?.homeParticipantScore {
                    homeScore = "\(homeScoreInt)"
                }
                if let awayScoreInt = match?.awayParticipantScore {
                    awayScore = "\(awayScoreInt)"
                }
                return "\(homeScore) - \(awayScore)"
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var detailedScoresPublisher: AnyPublisher<([String: Score], String), Never> {
        return self.$match
            .map { match in
                guard let matchValue = match else { return ([:], "") }
                return (matchValue.detailedScores ?? [:], matchValue.sport.alphaId ?? "")
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var sportIconImagePublisher: AnyPublisher<UIImage, Never> {
        return self.$match
            .map { match in
                if let imageName = match?.sport.id,
                   let sportIconImage = UIImage(named: "sport_type_icon_\(imageName)") {
                    return sportIconImage
                }
                else if let defaultImage = UIImage(named: "sport_type_icon_default") {
                    return defaultImage
                }
                else {
                    return UIImage()
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    
    var matchTimeDetailsPublisher: AnyPublisher<String?, Never> {
        return self.$match.map { match in
            
            guard let match else { return nil }
            
            let details = [match.matchTime, match.detailedStatus]
            return details.compactMap({ $0 }).joined(separator: " - ")
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
        
    }
    
    var competitionNamePublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { $0?.competitionName ?? "" }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var promoImageURLPublisher: AnyPublisher<URL?, Never> {
        return self.$match
            .map { match in
                return URL(string: match?.promoImageURL ?? "")
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var isDefaultMarketAvailablePublisher: AnyPublisher<Bool, Never> {
        return self.defaultMarketPublisher.flatMap { defaultMarket in
            guard
                let defaultMarketId = defaultMarket?.id
            else {
                return Just(false).setFailureType(to: Never.self).eraseToAnyPublisher()
            }
            
            return Env.servicesProvider.subscribeToEventOnListsMarketUpdates(withId: defaultMarketId)
                .compactMap({ $0 })
                .map({ (serviceProviderMarket: ServicesProvider.Market) -> Market in
                    return ServiceProviderModelMapper.market(fromServiceProviderMarket: serviceProviderMarket)
                })
                .map({ marketUpdated in
                    return marketUpdated.isAvailable
                })
                .replaceError(with: false)
                .eraseToAnyPublisher()
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    var defaultMarketPublisher: AnyPublisher<Market?, Never> {
        return self.$match
            // .map { match in return Optional<Market>.none }
            .map { $0?.markets.first }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var eventNamePublisher: AnyPublisher<String?, Never> {
        return self.$match
            .map { match in
                return match?.venue?.name ?? match?.competitionName
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var outrightNamePublisher: AnyPublisher<String?, Never> {
        return self.$match
            .map { match in
                return match?.competitionOutright?.name
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var isFavoriteMatchPublisher: AnyPublisher<Bool, Never> {
        return self.$match
            .map { match in
                if let match {
                    return Env.favoritesManager.isEventFavorite(eventId: match.id)
                }
                else {
                    return false
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var canHaveCashbackPublisher: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest(self.$match, self.$matchWidgetType)
            .map { match, matchWidgetType in
                guard let matchValue = match else { return false }
                
                if RePlayFeatureHelper.shouldShowRePlay(forMatch: matchValue) {
                    return matchWidgetType == .normal || matchWidgetType == .topImage
                }
                return false
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    

    @Published private(set) var homeOldBoostedOddAttributedString: NSAttributedString = NSAttributedString(string: "-")
    @Published private(set) var drawOldBoostedOddAttributedString: NSAttributedString = NSAttributedString(string: "-")
    @Published private(set) var awayOldBoostedOddAttributedString: NSAttributedString = NSAttributedString(string: "-")
    
    @Published private(set) var matchWidgetStatus: MatchWidgetStatus = .unknown
    @Published private(set) var matchWidgetType: MatchWidgetType = .normal
        
    private var liveMatchDetailsSubscription: ServicesProvider.Subscription?

    private var cancellables: Set<AnyCancellable> = []
    
    init(match: Match, matchWidgetType: MatchWidgetType = .normal, matchWidgetStatus: MatchWidgetStatus = .unknown) {
        
        print("DebugPublishers 1 init \(match.id)")
              
        self.matchMarketsSubject = .init(match)
        
        self.matchWidgetStatus = matchWidgetStatus
        self.matchWidgetType = matchWidgetType
        
        var shouldRequestLiveDataFallback = false
        switch matchWidgetStatus {
        case .live:
            shouldRequestLiveDataFallback = true
        case .preLive, .unknown:
            shouldRequestLiveDataFallback = false
        }
        
        self.subscribeMatchLiveData(withId: match.id, shouldRequestLiveDataFallback: shouldRequestLiveDataFallback)
        
        // Our match published property is the result of joining
        // the match markets and infos in the matchMarketsSubject
        // with the match Live Data details
        Publishers.CombineLatest(self.matchMarketsSubject, self.matchLiveDataSubject)
            .map { match, matchLiveData -> Match? in
                print("DebugPublishers 1 updatedMatch: ")

                guard
                    var matchValue = match
                else {
                    return nil
                }

                print("DebugPublishers 2 updatedMatch: \(matchValue.id) \(matchValue.status) ")

                
                guard
                    let matchLiveDataValue = matchLiveData
                else {
                    return matchValue
                }
                
                print("DebugPublishers 3 updatedMatch: \(matchValue.id) \(matchValue.status) -> \(matchLiveDataValue.status)")
                      
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
                
                return matchValue
            }
            .sink { [weak self] (updatedMatch: Match?) in
                print("DebugPublishers 4 updatedMatch: \(updatedMatch?.id) \(updatedMatch?.status)")
                self?.match = updatedMatch
            }
            .store(in: &cancellables)
        
        // Make sure we keep our matchWidgetStatus updated with the match
        self.$match
            .compactMap({ $0?.status })
            .removeDuplicates()
            .sink { [weak self] matchStatus in
                if matchStatus.isLive || matchStatus.isPostLive {
                    self?.matchWidgetStatus = .live
                }
                else if matchStatus.isPreLive {
                    self?.matchWidgetStatus = .preLive
                }
                else {
                    self?.matchWidgetStatus = .unknown
                }
            }
            .store(in: &self.cancellables)
        
        self.loadBoostedOddOldValueIfNeeded()

    }

    func updateWithMatch(_ match: Match) {
        self.matchMarketsSubject.send(match)
    }
    
}


// Load Live data updates
extension MatchWidgetCellViewModel {
    
    private func subscribeMatchLiveData(withId matchId: String, shouldRequestLiveDataFallback fallback: Bool) {
        self.subscribeMatchLiveDataOnLists(withId: matchId, shouldRequestLiveDataFallback: fallback)
    }
    
    private func subscribeMatchLiveDataOnLists(withId matchId: String, shouldRequestLiveDataFallback: Bool) {
        
        Env.servicesProvider.subscribeToEventOnListsLiveDataUpdates(withId: matchId)
            .receive(on: DispatchQueue.main)
            .compactMap({ $0 })
            .map(ServiceProviderModelMapper.matchLiveData(fromServiceProviderEvent:))
            .sink(receiveCompletion: { [weak self] completion in
                print("MatchWidgetCellViewModel subscribeMatchLiveData completion: \(completion)")
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    switch error {
                    case .resourceNotFound:
                        if shouldRequestLiveDataFallback {
                            self?.subscribeMatchLiveDataUpdates(withId: matchId)
                        }
                    default:
                        print("MatchDetailsViewModel getMatchDetails Error retrieving data! \(error)")
                    }
                }
            }, receiveValue: { [weak self] matchLiveData in
                self?.matchLiveDataSubject.send(matchLiveData)
            })
            .store(in: &self.cancellables)
    }
    
    private func subscribeMatchLiveDataUpdates(withId matchId: String) {
        Env.servicesProvider.subscribeToLiveDataUpdates(forEventWithId: matchId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    switch error {
                    case .resourceUnavailableOrDeleted:
                        ()
                    default:
                        print("MatchDetailsViewModel getMatchDetails Error retrieving data! \(error)")
                    }
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
            let originalMarketId = self.match?.oldMainMarketId
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
            
            if let firstCurrentOutcomeName = match.markets.first?.outcomes[safe:0]?.typeName.lowercased(),
               let outcome = market.outcomes.first(where: { outcome in outcome.typeName.lowercased() == firstCurrentOutcomeName }) {
                let oddValue = OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd)
                let attributes = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
                let attributedString = NSAttributedString(string: oddValue, attributes: attributes)
                self?.homeOldBoostedOddAttributedString = attributedString
            }
            else {
                self?.homeOldBoostedOddAttributedString = NSAttributedString(string: "-")
            }
            
            if let secondCurrentOutcomeName = match.markets.first?.outcomes[safe: 1]?.typeName.lowercased(),
               let outcome = market.outcomes.first(where: { outcome in outcome.typeName.lowercased() == secondCurrentOutcomeName }) {
                let oddValue = OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd)
                let attributes = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
                let attributedString = NSAttributedString(string: oddValue, attributes: attributes)
                self?.drawOldBoostedOddAttributedString = attributedString
            }
            else {
                self?.drawOldBoostedOddAttributedString = NSAttributedString(string: "-")
            }
            
            if let thirdCurrentOutcomeName = match.markets.first?.outcomes[safe: 2]?.typeName.lowercased(),
               let outcome = market.outcomes.first(where: { outcome in outcome.typeName.lowercased() == thirdCurrentOutcomeName }) {
                let oddValue = OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd)
                let attributes = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
                let attributedString = NSAttributedString(string: oddValue, attributes: attributes)
                self?.awayOldBoostedOddAttributedString = attributedString
            }
            else {
                self?.awayOldBoostedOddAttributedString = NSAttributedString(string: "-")
            }
        }
        .store(in: &self.cancellables)
    }
}


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
