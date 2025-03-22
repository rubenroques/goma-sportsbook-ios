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
    // @Published private(set) var match: Match // Full match, with markets and live data

    // Replace @Published with a Curren@PubtValueSubject
    private let matchSubject: CurrentValueSubject<Match, Never> // You'll need a default Match for initialization
    var matchPublisher: AnyPublisher<Match, Never> {
        return matchSubject.eraseToAnyPublisher()
    }

    // Add a property to access the current value directly
    private(set) var match: Match {
        get { matchSubject.value }
        set { matchSubject.send(newValue) }
    }
    
    //
    private let matchWidgetStatusSubject = CurrentValueSubject<MatchWidgetStatus, Never>(.unknown)
    var matchWidgetStatusPublisher: AnyPublisher<MatchWidgetStatus, Never> {
        return matchWidgetStatusSubject.eraseToAnyPublisher()
    }
    private(set) var matchWidgetStatus: MatchWidgetStatus {
        get { matchWidgetStatusSubject.value }
        set { matchWidgetStatusSubject.send(newValue) }
    }

    //
    private let matchWidgetTypeSubject = CurrentValueSubject<MatchWidgetType, Never>(.normal)
    var matchWidgetTypePublisher: AnyPublisher<MatchWidgetType, Never> {
        return matchWidgetTypeSubject.eraseToAnyPublisher()
    }
    private(set) var matchWidgetType: MatchWidgetType {
        get { matchWidgetTypeSubject.value }
        set { matchWidgetTypeSubject.send(newValue) }
    }
    
    private var matchMarketsSubject: CurrentValueSubject<Match, Never>
    private var matchLiveDataSubject: CurrentValueSubject<MatchLiveData?, Never>

    //
    //
    var homeTeamNamePublisher: AnyPublisher<String, Never> {
        return self.matchPublisher
            .map { $0.homeParticipant.name }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var awayTeamNamePublisher: AnyPublisher<String, Never> {
        return self.matchPublisher
            .map { $0.awayParticipant.name }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var activePlayerServePublisher: AnyPublisher<Match.ActivePlayerServe?, Never> {
        return self.matchPublisher
            .map { $0.activePlayerServe }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var mainMarketNamePublisher: AnyPublisher<String, Never> {
        return self.matchPublisher
            .map { $0.markets.first?.name ?? ""}
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var countryIdPublisher: AnyPublisher<String, Never> {
        return self.matchPublisher
            .map { $0.venue?.id ?? ""}
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var countryISOCodePublisher: AnyPublisher<String, Never> {
        return self.matchPublisher
            .map { $0.venue?.isoCode ?? ""}
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var countryFlagImageNamePublisher: AnyPublisher<String?, Never> {
        return Publishers.CombineLatest(self.countryISOCodePublisher, self.countryIdPublisher)
            .map({ countryISOCode, countryId in
                let assetName = Assets.flagName(withCountryCode: countryISOCode != "" ? countryISOCode : countryId)
                return assetName
            })
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var startDateStringPublisher: AnyPublisher<String, Never> {
        return self.matchPublisher
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
        return self.matchPublisher
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
        return self.matchPublisher
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
        return Publishers.CombineLatest(self.matchWidgetStatusPublisher, self.matchPublisher)
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
        return self.matchPublisher
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
        return self.matchPublisher
            .map { match in
                return (match.detailedScores ?? [:], match.sport.alphaId ?? "")
            }
            .eraseToAnyPublisher()
    }

    var sportIconImageNamePublisher: AnyPublisher<String?, Never> {
        return self.matchPublisher
            .map { match in
                if UIImage(named: "sport_type_icon_\(match.sport.id)") != nil {
                    return "sport_type_icon_\(match.sport.id)"
                }
                else if UIImage(named: "sport_type_icon_default") != nil {
                    return "sport_type_icon_default"
                }
                else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }

    var matchTimeDetailsPublisher: AnyPublisher<String?, Never> {
        return self.matchPublisher.map { match in
            let details = [match.matchTime, match.detailedStatus]
            return details.compactMap({ $0 }).joined(separator: " - ")
        }
        .removeDuplicates()
        .eraseToAnyPublisher()

    }

    var promoImageURLPublisher: AnyPublisher<URL?, Never> {
        return self.matchPublisher
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
        return self.matchPublisher
            .map { $0.markets.first }
            .eraseToAnyPublisher()
    }

    var competitionNamePublisher: AnyPublisher<String, Never> {
        return self.matchPublisher
            .map { $0.competitionName }
            .prepend(self.match.competitionName)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var eventNamePublisher: AnyPublisher<String?, Never> {
        return self.matchPublisher
            .map { match in
                return match.venue?.name ?? match.competitionName
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var matchHeaderNamePublisher: AnyPublisher<String?, Never> {
        return Publishers.CombineLatest3(self.matchWidgetTypePublisher,
                                  self.eventNamePublisher,
                                  self.competitionNamePublisher)
        .map { matchWidgetType, eventName, competitionName in
            switch matchWidgetType {
            case .topImageOutright:
                return eventName
            default:
                return competitionName
            }
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    var outrightNamePublisher: AnyPublisher<String?, Never> {
        return self.matchPublisher
            .map { match in
                return match.competitionOutright?.name
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private var isFavoriteSubject = CurrentValueSubject<Bool, Never>(false)

    var isFavoriteMatchPublisher: AnyPublisher<Bool, Never> {
        return self.isFavoriteSubject.eraseToAnyPublisher()
    }

    var canHaveCashbackPublisher: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest(self.matchPublisher, self.matchWidgetTypePublisher)
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
    // MatchHeaderViewModel
    let matchHeaderViewModel = MatchHeaderViewModel()

    // MARK: Actions
    var favoriteAction: ((Bool) -> Void) = { _ in } {
        didSet {
            matchHeaderViewModel.favoriteAction = self.favoriteAction
        }
    }

    //
    //

    //
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

    @Published private(set) var oldBoostedOddOutcome: BoostedOutcome?

    
    // HorizontalMatchInfoViewModel publisher
    private let horizontalMatchInfoViewModelSubject = CurrentValueSubject<HorizontalMatchInfoViewModel, Never>(HorizontalMatchInfoViewModel())
    var horizontalMatchInfoViewModelPublisher: AnyPublisher<HorizontalMatchInfoViewModel, Never> {
        return horizontalMatchInfoViewModelSubject.eraseToAnyPublisher()
    }

    private var liveMatchDetailsSubscription: ServicesProvider.Subscription?

    private var cancellables: Set<AnyCancellable> = []

    init(match: Match, matchWidgetType: MatchWidgetType = .normal, matchWidgetStatus: MatchWidgetStatus = .unknown) {

        self.matchSubject = .init(match)
        
        switch matchWidgetStatus {
        case .live, .preLive:
            self.matchWidgetStatusSubject.send(matchWidgetStatus)
        case .unknown:
            if match.status.isLive || match.status.isPostLive {
                self.matchWidgetStatusSubject.send(.live)
            }
            else {
                self.matchWidgetStatusSubject.send(.preLive)
            }
        }

        self.matchWidgetTypeSubject.send(matchWidgetType)

        self.matchMarketsSubject = .init(match)
        self.matchLiveDataSubject = .init(nil)

        // Setup bindings for horizontalMatchInfoViewModel
        self.setupHorizontalMatchInfoViewModelBindings()

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

        //


        //
        self.matchPublisher
            .map { match in
                return Env.favoritesManager.isEventFavorite(eventId: match.id)
            }
            .removeDuplicates()
            .sink { isFavorite in
                self.isFavoriteSubject.send(isFavorite)
            }
            .store(in: &self.cancellables)

        // TODO:
        // Keep our matchWidgetStatus updated with the match
        // mainly from notStarted -> live

        //
        // Subscritions to update the header with the infos from the match
        self.countryFlagImageNamePublisher
            .receive(on: DispatchQueue.main)
            .replaceError(with: nil)
            .sink { countryFlagImageName in
                self.matchHeaderViewModel.setCountryImageName(countryFlagImageName)
            }
            .store(in: &self.cancellables)

        self.sportIconImageNamePublisher
            .receive(on: DispatchQueue.main)
            .replaceError(with: nil)
            .sink { sportIconImageName in
                self.matchHeaderViewModel.setSportImageName(sportIconImageName)
            }
            .store(in: &self.cancellables)

        self.matchHeaderNamePublisher
            .receive(on: DispatchQueue.main)
            .replaceError(with: nil)
            .sink { matchHeaderName in
                self.matchHeaderViewModel.setCompetitionName(matchHeaderName)
            }
            .store(in: &self.cancellables)

        self.isFavoriteMatchPublisher
            .receive(on: DispatchQueue.main)
            .replaceError(with: false)
            .sink { isFavoriteMatch in
                self.matchHeaderViewModel.setIsFavorite(isFavoriteMatch)
            }
            .store(in: &self.cancellables)
        //

        // Request the updated content
        self.subscribeMatchLiveData(withId: match.id, shouldRequestLiveDataFallback: shouldRequestLiveDataFallback)
        self.loadBoostedOddOldValueIfNeeded()
    }

    deinit {

    }

    func updateWithMatch(_ match: Match) {
        self.matchMarketsSubject.send(match)
    }

    // MARK: - HorizontalMatchInfoViewModel

    // Update horizontalMatchInfoViewModel when match data changes
    private func setupHorizontalMatchInfoViewModelBindings() {
        // Use nested CombineLatest calls to combine all the necessary data
        // First combine the team names and score
        Publishers.CombineLatest3(
            self.homeTeamNamePublisher,
            self.awayTeamNamePublisher,
            self.matchScorePublisher
        )
        // Then combine with date and time
        .combineLatest(
            Publishers.CombineLatest(
                self.startDateStringPublisher,
                self.startTimeStringPublisher
            )
        )
        // Finally combine with the match for status
        .combineLatest(self.matchPublisher)
        .map { combinedData, match in
            let ((homeTeamName, awayTeamName, score), (dateString, timeString)) = combinedData

            // Determine the display state based on match status
            let displayState: HorizontalMatchInfoViewModel.DisplayState

            if match.status.isLive {
                // Live match
                displayState = .live(score: score, matchTime: match.matchTime)
            }
            else if match.status.isPostLive {
                // Ended match
                displayState = .ended(score: score)
            }
            else {
                // Pre-live match - use the formatted date and time from publishers
                // If either is empty, we'll still show what we have
                displayState = .preLive(date: dateString, time: timeString)
            }

            // Create and return the view model
            return HorizontalMatchInfoViewModel(
                homeTeamName: homeTeamName,
                awayTeamName: awayTeamName,
                displayState: displayState
            )
        }
        .sink { [weak self] viewModel in
            self?.horizontalMatchInfoViewModelSubject.send(viewModel)
        }
        .store(in: &self.cancellables)
    }

    func toggleFavorite() {
        if self.matchWidgetTypeSubject.value == .topImageOutright {
            if Env.favoritesManager.isEventFavorite(eventId: self.match.id) {
                Env.favoritesManager.removeFavorite(eventId: self.match.id, favoriteType: .competition)
                self.isFavoriteSubject.send(false)
            }
            else {
                Env.favoritesManager.addFavorite(eventId: self.match.id, favoriteType: .competition)
                self.isFavoriteSubject.send(true)
            }
        }
        else {
            if Env.favoritesManager.isEventFavorite(eventId: self.match.id) {
                Env.favoritesManager.removeFavorite(eventId: self.match.id, favoriteType: .match)
                self.isFavoriteSubject.send(false)
            }
            else {
                Env.favoritesManager.addFavorite(eventId: self.match.id, favoriteType: .match)
                self.isFavoriteSubject.send(true)
            }
        }
    }

    func setCountryFlag(hidden: Bool) {
        self.matchHeaderViewModel.setCountryFlag(hidden: hidden)
    }

    func setSportImage(hidden: Bool) {
        self.matchHeaderViewModel.setSportImage(hidden: hidden)
    }

    func setFavoriteIcon(hidden: Bool) {
        self.matchHeaderViewModel.setFavoriteIcon(hidden: hidden)
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
                    break
                case .failure(let error):
                    switch error {
                    case .resourceNotFound:
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
            .sink(receiveCompletion: { [weak self] _ in
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
            self.matchWidgetTypeSubject.value == .boosted,
            let originalMarketId = self.match.oldMainMarketId
        else {
            return
        }

        Publishers.CombineLatest(
            Env.servicesProvider.getMarketInfo(marketId: originalMarketId)
                .map(ServiceProviderModelMapper.market(fromServiceProviderMarket:)),
            self.matchPublisher
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
