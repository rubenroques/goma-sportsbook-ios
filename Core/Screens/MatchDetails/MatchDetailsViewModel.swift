//
//  MatchDetailsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 26/11/2021.
//

import Foundation
import UIKit
import Combine
import ServicesProvider

class MatchDetailsViewModel: NSObject {

    enum MatchMode {
        case preLive
        case live
    }

    var matchId: String
    var homeRedCardsScorePublisher: CurrentValueSubject<String, Never> = .init("0")
    var awayRedCardsScorePublisher: CurrentValueSubject<String, Never> = .init("0")

    var matchPublisher: AnyPublisher<LoadableContent<Match>, Never> {
        return self.matchCurrentValueSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private var matchCurrentValueSubject: CurrentValueSubject<LoadableContent<Match>, Never> = .init(.idle)

    var marketGroupsState: CurrentValueSubject<LoadableContent<[MarketGroup]>, Never> = .init(.idle)
    var selectedMarketTypeIndexPublisher: CurrentValueSubject<Int?, Never> = .init(nil)

    var matchStatsUpdatedPublisher = PassthroughSubject<Void, Never>.init()

    var shouldRenderFieldWidget: CurrentValueSubject<Bool, Never> = .init(false)
    var fieldWidgetRenderDataType: FieldWidgetRenderDataType?

    var match: Match? {
        switch matchCurrentValueSubject.value {
        case .loaded(let match):
            return match
        default:
            return nil
        }
    }

    var marketFilters: [EventMarket]?
    var availableMarkets: [String: [String]] = [:]

    var isLiveMatch: Bool {
        if let match = self.match {
            switch match.status {
            case .notStarted, .ended, .unknown:
                return false
            case .inProgress:
                return true
            }
        }
        return false
    }

    var inProgressStatusString: String? {
        if let match = self.match {
            switch match.status {
            case .ended, .notStarted, .unknown:
                return nil
            case .inProgress(let progress):
                return progress
            }
        }
        return nil
    }

    var matchScore: String {
        var homeScore = "0"
        var awayScore = "0"
        if let match = self.match, let homeScoreInt = match.homeParticipantScore {
            homeScore = "\(homeScoreInt)"
        }
        if let match = self.match, let awayScoreInt = match.awayParticipantScore {
            awayScore = "\(awayScoreInt)"
        }
        return "\(homeScore) - \(awayScore)"
    }

    var matchTimeDetails: String? {
        let details = [self.match?.matchTime, self.match?.detailedStatus]
        return details.compactMap({ $0 }).joined(separator: " - ")
    }
    
    var matchDetailedScores: CurrentValueSubject<[String: [String: Score]], Never> = .init([:])
    
    var activePlayerServePublisher: CurrentValueSubject<Match.ActivePlayerServe?, Never> = .init(nil)
    
    private var statsJSON: JSON?
    let matchStatsViewModel: MatchStatsViewModel

    private var serviceProviderStateCancellable: AnyCancellable?
    private var matchDetailsCancellable: AnyCancellable?
    private var matchGroupsCancellable: AnyCancellable?
    private var liveMatchDataCancellable: AnyCancellable?
    
    private var cancellables = Set<AnyCancellable>()
    private var matchDetailsSubscription: ServicesProvider.Subscription?

    private var liveDataSubscription: ServicesProvider.Subscription?
    
    var isFromLiveCard: Bool = false

    var scrollToTopAction: ((Int) -> Void)?
    var shouldShowTabTooltip: (() -> Void)?
    
    var showMixMatchDefault: Bool = false

    init(matchMode: MatchMode = .preLive, match: Match) {
        self.matchId = match.id
        self.matchStatsViewModel = MatchStatsViewModel(matchId: match.id)
        
        self.isFromLiveCard = match.status == .notStarted ? false : true

        super.init()

        self.connectPublishers()
        self.getMatchDetails()
    }

    init(matchMode: MatchMode = .preLive, matchId: String) {
        self.matchId = matchId
        self.matchStatsViewModel = MatchStatsViewModel(matchId: matchId)

        super.init()

        self.connectPublishers()
        self.getMatchDetails()
    }
    
    func forceRefreshData() {
        self.serviceProviderStateCancellable = Env.servicesProvider.eventsConnectionStatePublisher
            .sink(receiveCompletion: { completion in
                
            }, receiveValue: { state in
                switch state {
                case .connected:
                    print("MatchDetailsViewModel forceRefreshData eventsConnectionStatePublisher connected")
                    self.getMatchDetails()
                case .disconnected:
                    print("MatchDetailsViewModel forceRefreshData eventsConnectionStatePublisher disconnected")
                }
            })
    }
 
    private func connectPublishers() {

        self.marketGroupsState
            .receive(on: DispatchQueue.main)
            .map({ marketGroupsState -> [MarketGroup] in
                switch marketGroupsState {
                case .idle, .loading, .failed:
                    return []
                case .loaded(let marketGroups):
                    return marketGroups
                }
            })
            .map { marketGroups -> Int in
                return marketGroups.firstIndex(where: { $0.isDefault ?? false }) ?? 0
            }
            .sink { [weak self] defaultSelectedIndex in
                if let showMixMatchDefault = self?.showMixMatchDefault,
                showMixMatchDefault {
                    self?.selectedMarketTypeIndexPublisher.send(1)
                }
                else {
                    self?.selectedMarketTypeIndexPublisher.send(defaultSelectedIndex)
                }
            }
            .store(in: &self.cancellables)

        self.matchStatsViewModel.statsTypePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] statsJSON in
                self?.statsJSON = statsJSON
                self?.matchStatsUpdatedPublisher.send()
            }
            .store(in: &self.cancellables)

    }

    private func getMatchDetails() {
        print("MatchDetailsViewModel forceRefreshData")
        
        self.matchDetailsSubscription = nil
        self.liveDataSubscription = nil
        
        self.matchDetailsCancellable?.cancel()
        self.matchDetailsCancellable = nil
        
        self.matchGroupsCancellable?.cancel()
        self.matchGroupsCancellable = nil
        
        self.liveMatchDataCancellable?.cancel()
        self.liveMatchDataCancellable = nil
        
        let eventDetailsPublisher = Env.servicesProvider.subscribeEventDetails(eventId: self.matchId)

        // Subscribe to the content of the event details
        self.matchDetailsCancellable = eventDetailsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    switch error {
                    case .resourceUnavailableOrDeleted: // This match is no longer available
                        self?.matchCurrentValueSubject.send(.failed)
                        self?.marketGroupsState.send(.failed)

                    default:
                        print("MatchDetailsViewModel getMatchDetails Error retrieving data! \(error)")
                        self?.matchCurrentValueSubject.send(.failed)
                        self?.marketGroupsState.send(.failed)
                    }
                }
            }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<ServicesProvider.Event>) in
                switch subscribableContent {
                case .connected(let subscription):
                    self?.matchDetailsSubscription = subscription
                case .contentUpdate(let serviceProviderEvent):
                    guard
                        let self = self,
                        let match = ServiceProviderModelMapper.match(fromEvent: serviceProviderEvent)
                    else {
                        return
                    }
                    self.matchCurrentValueSubject.send(.loaded(match))
                    
                case .disconnected:
                    print("MatchDetailsViewModel getMatchDetails subscribeEventDetails disconnected")
                }
            })

        // The first published value of the full
        // match should trigger the match market groups flow
        let matchDetailsReceivedPublisher = eventDetailsPublisher
            .replaceError(with: .disconnected)
            .filter { (subscribableContent: SubscribableContent<ServicesProvider.Event>) -> Bool in
                if case .contentUpdate = subscribableContent {
                    return true
                }
                return false
            }
            .first()
            .map({ subscribableContent -> ServicesProvider.Event? in
                if case .contentUpdate(let event) = subscribableContent {
                    return event
                }
                return nil
            })
            .compactMap({ $0 })
            .eraseToAnyPublisher()
        
        // Show marketGroups loading
        matchDetailsReceivedPublisher.map({ _ in
            return ()
        })
        .sink { [weak self] in
            self?.marketGroupsState.send(.loading)
        }
        .store(in: &self.cancellables)

        //
        // Request the remaining marketGroups details
        self.matchGroupsCancellable = matchDetailsReceivedPublisher
            .flatMap({ (event: ServicesProvider.Event) -> AnyPublisher<[MarketGroup], Never> in
                return Env.servicesProvider.getMarketGroups(forEvent: event)
                        .map(Self.convertMarketGroups(_:))
                        .eraseToAnyPublisher()
            })
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.marketGroupsState.send(.failed)
                }
            } receiveValue: { [weak self] marketGroups in
                self?.marketGroupsState.send(.loaded(marketGroups))
            }

        //
        //
        self.liveMatchDataCancellable = self.matchCurrentValueSubject.compactMap { loadableContent -> Match? in
            switch loadableContent {
            case .idle, .loading, .failed:
                return nil
            case .loaded(let match):
                return match
            }
        }
        .first()
        .sink { [weak self] match in
            self?.subscribeMatchLiveDataOnLists(withId: match.id, sportAlphaCode: match.sport.alphaId ?? "")
        }

    }


    private func subscribeMatchLiveDataOnLists(withId matchId: String, sportAlphaCode: String) {
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
                        self?.subscribeMatchLiveDataUpdates(withId: matchId, sportAlphaCode: sportAlphaCode)
                    default:
                        print("MatchDetailsViewModel getMatchDetails Error retrieving data! \(error)")
                    }
                }
            }, receiveValue: { [weak self] matchLiveData in
                if let detailedScoresValue = matchLiveData.detailedScores {
                    var matchDetailedScoresForSport = [sportAlphaCode: detailedScoresValue]
                    self?.matchDetailedScores.send(matchDetailedScoresForSport)
                }

                self?.activePlayerServePublisher.send(matchLiveData.activePlayerServing)
            })
            .store(in: &self.cancellables)
    }
    
    private func subscribeMatchLiveDataUpdates(withId matchId: String, sportAlphaCode: String) {
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
                self?.liveDataSubscription = nil
            }, receiveValue: { [weak self] (eventSubscribableContent: SubscribableContent<ServicesProvider.EventLiveData>) in
            
                switch eventSubscribableContent {
                case .connected(let subscription):
                    self?.liveDataSubscription = subscription
                case .contentUpdate(let eventLiveData):
                    let matchLiveData = ServiceProviderModelMapper.matchLiveData(fromServiceProviderEventLiveData: eventLiveData)
                    if let detailedScores = matchLiveData.detailedScores {
                        var updatedMatchDetailedScores = [sportAlphaCode: detailedScores]
                        self?.matchDetailedScores.send(updatedMatchDetailedScores)
                    }
                    self?.activePlayerServePublisher.send(matchLiveData.activePlayerServing)
                case .disconnected:
                    break
                }
            })
            .store(in: &self.cancellables)
    
    }
    
    func getFieldWidget(isDarkTheme: Bool) {

        Env.servicesProvider.getFieldWidget(eventId: self.matchId, isDarkTheme: isDarkTheme)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("FIELD WIDGET RENDER DATA ERROR: \(error)")

                }
            }, receiveValue: { [weak self] fieldWidgetType in
                self?.fieldWidgetRenderDataType = fieldWidgetType
                self?.shouldRenderFieldWidget.send(true)
            })
            .store(in: &cancellables)
    }

    func selectMarketType(atIndex index: Int) {
        self.selectedMarketTypeIndexPublisher.send(index)
    }

    func numberOfMarketGroups() -> Int {
        switch self.marketGroupsState.value {
        case let .loaded(marketGroups):
            return marketGroups.count
        default:
            return 0
        }
    }

    func marketGroup(forIndex index: Int) -> MarketGroup? {
        switch self.marketGroupsState.value {
        case let .loaded(marketGroups):
            return marketGroups[safe: index]
        default:
            return nil
        }
    }
    
}

extension MatchDetailsViewModel {
    
    private static func convertMarketGroups(_ marketGroups: [ServicesProvider.MarketGroup]) -> [MarketGroup] {
        let marketGroups = marketGroups.map { rawMarketGroup in
            MarketGroup(id: rawMarketGroup.id,
                        type: rawMarketGroup.type,
                        groupKey: rawMarketGroup.groupKey,
                        translatedName: rawMarketGroup.translatedName,
                        isDefault: rawMarketGroup.isDefault,
                        markets: ServiceProviderModelMapper.optionalMarkets(fromServiceProviderMarkets: rawMarketGroup.markets),
                        position: rawMarketGroup.position)

        }
        // NOTE: Is already sorted before convertion, so no needed
//        let sortedMarketGroups = marketGroups.sorted(by: {
//            $0.position ?? 0 < $1.position ?? 99
//        })
        return marketGroups
    }

}

extension MatchDetailsViewModel: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfMarketGroups()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let item = self.marketGroup(forIndex: indexPath.row),
           item.id == "99" && item.type == "MixMatch" {
            
            guard
                let cell = collectionView.dequeueCellType(ListBackgroundCollectionViewCell.self, indexPath: indexPath)
            else {
                fatalError()
            }
            
            cell.isCustomDesign = true
            
            let marketTranslatedName = item.translatedName ?? localized("market")
            
            let normalizedTranslatedName = marketTranslatedName.replacingOccurrences(of: "[^a-zA-Z0-9]", with: "_", options: .regularExpression).lowercased()
                        
            let marketName = "\(localized("mix_match_mix_string"))\(localized("mix_match_match_string"))"
            
            cell.setupInfo(title: marketName, iconName: "mix_match_icon", backgroundName: "mix_match_background_pill")
            
            if let index = self.selectedMarketTypeIndexPublisher.value, index == indexPath.row {
                cell.setSelectedType(true)
                self.shouldShowTabTooltip?()
            }
            else {
                cell.setSelectedType(false)
            }
            
            return cell
        }
        else {
            guard
                let cell = collectionView.dequeueCellType(ListTypeCollectionViewCell.self, indexPath: indexPath),
                let item = self.marketGroup(forIndex: indexPath.row)
            else {
                fatalError()
            }
            
            let marketTranslatedName = item.translatedName ?? localized("market")
            
            //let normalizedTranslatedName = marketTranslatedName.replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "/", with: "_").lowercased()
            let normalizedTranslatedName = marketTranslatedName.replacingOccurrences(of: "[^a-zA-Z0-9]", with: "_", options: .regularExpression).lowercased()
            
            let marketKey = "market_group_\(normalizedTranslatedName)"
            
            var marketName = localized(marketKey)
            
            if normalizedTranslatedName == "mixmatch" {
                marketName = "\(localized("mix_match_mix_string"))\(localized("mix_match_match_string"))"
            }
            
            cell.isCustomDesign = true
            
            cell.setupWithTitle(marketName)
            
            if let index = self.selectedMarketTypeIndexPublisher.value, index == indexPath.row {
                cell.setSelectedType(true)
            }
            else {
                cell.setSelectedType(false)
            }
            
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let previousSelectionValue = self.selectedMarketTypeIndexPublisher.value ?? -1

        if indexPath.row != previousSelectionValue {
            self.selectedMarketTypeIndexPublisher.send(indexPath.row)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        else {
            self.scrollToTopAction?(indexPath.row)
        }
    }

}

extension MatchDetailsViewModel {

    func numberOfStatsSections() -> Int {

        guard
            let json = self.statsJSON
        else {
            return 0
        }

        if let eventPartsArray =  json["event_parts"].array {
            return eventPartsArray.count
        }

        return 0
    }

    func numberOfStatsRows(forSection section: Int) -> Int {

        guard
            let json = self.statsJSON
        else {
            return 0
        }

        if let eventPartsArray =  json["event_parts"].array,
           let partDict = eventPartsArray[safe: section],
           let bettintTypesArray = partDict["betting_types"].array {
            return bettintTypesArray.count
        }

        return 0
    }

    func jsonData(forIndexPath indexPath: IndexPath) -> JSON? {

        guard
            let json = self.statsJSON
        else {
            return 0
        }

        if let eventPartsArray =  json["event_parts"].array,
           let partDict = eventPartsArray[safe: indexPath.section],
           let bettintTypesArray = partDict["betting_types"].array,
           let statsJSON = bettintTypesArray[safe: indexPath.row] {
            return JSON(statsJSON)
        }

        return nil
    }

    func marketStatsTitle(forIndexPath indexPath: IndexPath) -> String? {

        guard
            let json = self.statsJSON
        else {
            return nil
        }
        if let eventPartsArray =  json["event_parts"].array,
           let partDict = eventPartsArray[safe: indexPath.section],
           let bettintTypesArray = partDict["betting_types"].array,
           let statsJSON = bettintTypesArray[safe: indexPath.row] {
            return "\(statsJSON["name"].string ?? "") - \(partDict["name"].string ?? "")"
        }

        return nil
    }

}
