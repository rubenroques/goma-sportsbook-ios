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

    enum MarketGroupsState {
        case idle
        case loading
        case loaded([MarketGroup])
        case failed
    }

    var matchId: String
    var homeRedCardsScorePublisher: CurrentValueSubject<String, Never> = .init("0")
    var awayRedCardsScorePublisher: CurrentValueSubject<String, Never> = .init("0")

    var matchModePublisher: CurrentValueSubject<MatchMode, Never> = .init(.preLive)
    var matchPublisher: CurrentValueSubject<LoadableContent<Match>, Never> = .init(.idle)

    var marketGroupsState: CurrentValueSubject<MarketGroupsState, Never> = .init(.idle)
    var selectedMarketTypeIndexPublisher: CurrentValueSubject<Int?, Never> = .init(nil)

    var matchStatsUpdatedPublisher = PassthroughSubject<Void, Never>.init()
 
    private var goalsRegister: EndpointPublisherIdentifiable?
    private var goalsSubscription: AnyCancellable?

    var shouldRenderFieldWidget: CurrentValueSubject<Bool, Never> = .init(false)
    var fieldWidgetRenderDataType: FieldWidgetRenderDataType?

    var match: Match? {
        switch matchPublisher.value {
        case .loaded(let match):
            return match
        default:
            return nil
        }
    }

    var marketFilters: [EventMarket]?
    var availableMarkets: [String: [String]] = [:]
    var marketGroups: [MarketGroup] = []

    var isLiveMatch: Bool {
        if let match = self.match {
            switch match.status {
            case .notStarted, .ended, .unknown:
                return false
            case .inProgress(_):
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
        return [self.match?.matchTime, self.match?.status.description()]
            .compactMap({ $0 })
            .joined(separator: " - ")
    }


    private var statsJSON: JSON?
    let matchStatsViewModel: MatchStatsViewModel

    private var cancellables = Set<AnyCancellable>()
    private var subscription: ServicesProvider.Subscription?

    init(matchMode: MatchMode = .preLive, match: Match) {
        self.matchId = match.id
        self.matchStatsViewModel = MatchStatsViewModel(matchId: match.id)
        self.matchModePublisher.send(matchMode)

        super.init()

        self.connectPublishers()
        self.getMatchDetails()
    }

    init(matchMode: MatchMode = .preLive, matchId: String) {
        self.matchId = matchId
        self.matchStatsViewModel = MatchStatsViewModel(matchId: matchId)
        self.matchModePublisher.send(matchMode)

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
                var index = 0
                var defaultFound = false
                for group in marketGroups {
                    if group.isDefault ?? false {
                        defaultFound = true
                        break
                    }
                    index += 1
                }
                return defaultFound ? index : 0
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

        Env.servicesProvider.subscribeMatchDetails(matchId: self.matchId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                print("Env.servicesProvider.subscribeEventDetails completed \(completion)")
                switch completion {
                case .finished:
                    ()
                case .failure(_):
                    self?.matchPublisher.send(.failed)
                    self?.marketGroupsState.send(.failed)
                }
            }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<ServicesProvider.Event>) in
                switch subscribableContent {
                case .connected(let subscription):
                    self?.subscription = subscription
                case .contentUpdate(let serviceProviderEvent):
                    guard let self = self else { return }

                    let match = ServiceProviderModelMapper.match(fromEvent: serviceProviderEvent)
                    self.matchPublisher.send(.loaded(match))

                    if self.marketGroups.isEmpty {
                        self.getMarketGroups(event: serviceProviderEvent)
                    }
                    else {
                        let marketGroups = self.marketGroups
                        self.marketGroupsState.send(.loaded(marketGroups))
                    }
                    self.getMatchLiveDetails()
                case .disconnected:
                    print("Disconnected from ws")
                }
            })
            .store(in: &cancellables)


    }

    func getMatchLiveDetails() {

        Env.servicesProvider.subscribeToEventUpdates(withId: self.matchId)
            .compactMap({ $0 })
            .map(ServiceProviderModelMapper.match(fromEvent:))
            .sink(receiveCompletion: { completion in
                print("matchSubscriber subscribeToEventUpdates completion: \(completion)")
            }, receiveValue: { [weak self] updatedMatch in
                switch updatedMatch.status {
                case .notStarted, .ended, .unknown:
                    self?.matchModePublisher.send(.preLive)
                case .inProgress(_):
                    self?.matchModePublisher.send(.live)
                }
                self?.matchPublisher.send(.loaded(updatedMatch))
            })
            .store(in: &self.cancellables)
    }

    //
    //
    private func getMarketGroups(event: ServicesProvider.Event) {

        self.marketGroupsState.send(.loading)

        Env.servicesProvider.getMarketsFilters(event: event)
            .map(self.convertMarketGroups(_:))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.marketGroupsState.send(.failed)
                }
            }, receiveValue: { [weak self] marketGroups in
                self?.marketGroups = marketGroups
                self?.marketGroupsState.send(.loaded(marketGroups))
            })
            .store(in: &cancellables)
    }

    private func convertMarketGroups(_ marketGroups: [ServicesProvider.MarketGroup]) -> [MarketGroup] {
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

        cell.setupWithTitle(item.translatedName ?? localized("market"))

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
            self.selectedMarketTypeIndexPublisher.send(indexPath.row)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
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
