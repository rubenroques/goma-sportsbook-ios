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

    private var statsJSON: JSON?
    let matchStatsViewModel: MatchStatsViewModel

    private var cancellables = Set<AnyCancellable>()
    private var subscription: ServicesProvider.Subscription?

    private var liveDataSubscription: ServicesProvider.Subscription?

    var scrollToTopAction: ((Int) -> Void)?

    init(matchMode: MatchMode = .preLive, match: Match) {
        self.matchId = match.id
        self.matchStatsViewModel = MatchStatsViewModel(matchId: match.id)

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

    func connectPublishers() {

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
                self?.selectedMarketTypeIndexPublisher.send(defaultSelectedIndex)
            }
            .store(in: &cancellables)

        self.matchStatsViewModel.statsTypePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] statsJSON in
                self?.statsJSON = statsJSON
                self?.matchStatsUpdatedPublisher.send()
            }
            .store(in: &cancellables)

    }

    func getMatchDetails() {
        
        let eventDetailsPublisher = Env.servicesProvider.subscribeEventDetails(eventId: self.matchId)

        // Subscribe to the content of the event details
        eventDetailsPublisher
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
                    self?.subscription = subscription
                case .contentUpdate(let serviceProviderEvent):
                    guard let self = self else { return }
                    let match = ServiceProviderModelMapper.match(fromEvent: serviceProviderEvent)
                    self.matchCurrentValueSubject.send(.loaded(match))
                    
                case .disconnected:
                    print("MatchDetailsViewModel getMatchDetails subscribeEventDetails disconnected")
                }
            })
            .store(in: &self.cancellables)

        // The first published value of the full
        // match should trigger the match market groups flow
        let matchDetailsRecievedPublisher = eventDetailsPublisher
            .replaceError(with: .disconnected)
            .filter { (subscribableContent: SubscribableContent<ServicesProvider.Event>) -> Bool in
                if case .contentUpdate = subscribableContent {
                    return true
                }
                return false
            }
            .first()
            .map({ subscribableContent -> Optional<ServicesProvider.Event> in
                if case .contentUpdate(let event) = subscribableContent {
                    return event
                }
                return nil
            })
            .compactMap({ $0 })
            .eraseToAnyPublisher()
        
        // Show marketGroups loading
        matchDetailsRecievedPublisher.map({ _ in
            return ()
        })
        .sink { [weak self] in
            self?.marketGroupsState.send(.loading)
        }
        .store(in: &self.cancellables)

        // Request the remaining marketGroups details
        matchDetailsRecievedPublisher
            .flatMap({ (event: ServicesProvider.Event) -> AnyPublisher<[MarketGroup], Never> in
                return Env.servicesProvider.getMarketsFilters(event: event)
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
            .store(in: &self.cancellables)
        
        
    }

    //
    //
//    private func getMarketGroups(event: ServicesProvider.Event) {
//
//        self.marketGroupsState.send(.loading)
//
//        Env.servicesProvider.getMarketsFilters(event: event)
//            .map(Self.convertMarketGroups(_:))
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                if case .failure = completion {
//                    self?.marketGroupsState.send(.failed)
//                }
//            }, receiveValue: { [weak self] marketGroups in
//                self?.marketGroupsState.send(.loaded(marketGroups))
//            })
//            .store(in: &cancellables)
//    }

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
        let sortedMarketGroups = marketGroups.sorted(by: {
            $0.position ?? 0 < $1.position ?? 99
        })
        return sortedMarketGroups
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

        let marketName = localized(marketKey)

        cell.setupWithTitle(marketName)

        if let index = self.selectedMarketTypeIndexPublisher.value, index == indexPath.row {
            cell.setSelectedType(true)
        }
        else {
            cell.setSelectedType(false)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let previousSelectionValue = self.selectedMarketTypeIndexPublisher.value ?? -1

        if indexPath.row != previousSelectionValue {
            print("CHANGING TAB!")
            self.selectedMarketTypeIndexPublisher.send(indexPath.row)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        else {
            print("CURRENT TAB!")
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
