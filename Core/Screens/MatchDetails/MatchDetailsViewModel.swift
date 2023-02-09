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

    enum ScreenState {
        case idle
        case loading
        case loaded
        case failed
    }

    var matchId: String
    var homeRedCardsScorePublisher: CurrentValueSubject<String, Never> = .init("0")
    var awayRedCardsScorePublisher: CurrentValueSubject<String, Never> = .init("0")

    var store: MatchDetailsAggregatorRepository

    var isLoadingMarketGroups: CurrentValueSubject<Bool, Never> = .init(true)

    var matchModePublisher: CurrentValueSubject<MatchMode, Never> = .init(.preLive)
    var matchPublisher: CurrentValueSubject<LoadableContent<Match>, Never> = .init(.idle)

    var marketGroupsPublisher: CurrentValueSubject<[MarketGroup], Never> = .init([])
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

    private var matchMarketGroupsPublisher: AnyCancellable?
    private var matchMarketGroupsRegister: EndpointPublisherIdentifiable?

    private var matchDetailsRegister: EndpointPublisherIdentifiable?
    private var matchDetailsAggregatorPublisher: AnyCancellable?

    private var statsJSON: JSON?
    let matchStatsViewModel: MatchStatsViewModel

    private var cancellables = Set<AnyCancellable>()

    init(matchMode: MatchMode = .preLive, match: Match) {

        self.matchId = match.id

        self.matchStatsViewModel = MatchStatsViewModel(matchId: match.id)

        self.store = MatchDetailsAggregatorRepository(matchId: match.id)

        self.matchModePublisher.send(matchMode)

        super.init()

        self.connectPublishers()
        self.requestRedCards(forMatchWithId: match.id)

        self.getMatchDetails()

    }

    init(matchMode: MatchMode = .preLive, matchId: String) {
        self.matchId = matchId

        self.matchStatsViewModel = MatchStatsViewModel(matchId: matchId)

        self.matchModePublisher.send(matchMode)

        self.store = MatchDetailsAggregatorRepository(matchId: matchId)

        super.init()

        self.connectPublishers()
        
        self.requestRedCards(forMatchWithId: matchId)

        self.getMatchDetails()
        
    }

    deinit {
        if let matchDetailsRegister = matchDetailsRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: matchDetailsRegister)
        }
    }

    func getMatchDetails() {

        Env.servicesProvider.subscribeMatchDetails(matchId: self.matchId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                print("Env.servicesProvider.subscribeEventDetails completed \(completion)")
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("MATCH DETAILS ERROR: \(error)")
                }
            }, receiveValue: { (subscribableContent: SubscribableContent<[EventsGroup]>) in
                print("Env.servicesProvider.subscribeEventDetails value \(subscribableContent)")
                switch subscribableContent {
                case .connected(let subscription):
                    print("Connected to ws")
                case .contentUpdate(let events):
                    self.isLoadingMarketGroups.send(true)
                    if let eventGroup = events[safe: 0],
                       let match = ServiceProviderModelMapper.match(fromEventGroup: eventGroup) {
                        self.matchPublisher.send(.loaded(match))

                        if let eventMapped = ServiceProviderModelMapper.event(fromEventGroup: eventGroup){
                            self.getMarketGroups(event: eventMapped)
                        }
                    }
                    else {
                        self.marketGroupsPublisher.send([])
                        self.isLoadingMarketGroups.send(false)
                    }

                case .disconnected:
                    print("Disconnected from ws")

                }
            })
            .store(in: &cancellables)

    }

    func getMarketGroups(event: ServicesProvider.Event) {

        Env.servicesProvider.getMarketFilters(event: event)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                ()
            }, receiveValue: { [weak self] marketGroup in
                self?.storeMarketGorups(marketGroup)
            })
            .store(in: &cancellables)
    }

    func connectPublishers() {

        self.marketGroupsPublisher
            .receive(on: DispatchQueue.main)
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

        //self.getFieldWidgetId(eventId: matchId)
    }

    func getFieldWidget(isDarkTheme: Bool) {

        Env.servicesProvider.getFieldWidget(eventId: self.matchId, isDarkTheme: isDarkTheme)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("FIELD WIDGET RENDER DATA FINISHED")
                case .failure(let error):
                    print("FIELD WIDGET RENDER DATA ERROR: \(error)")

                }
            }, receiveValue: { [weak self] fieldWidgetType in

                self?.fieldWidgetRenderDataType = fieldWidgetType
                self?.shouldRenderFieldWidget.send(true)

            })
            .store(in: &cancellables)
    }

    //
    //
    private func storeMarketGorups(_ marketGroups: [ServicesProvider.MarketGroup]) {

        let marketGroups = marketGroups.map { rawMarketGroup in
            MarketGroup(id: rawMarketGroup.id,
                        type: rawMarketGroup.type,
                        groupKey: rawMarketGroup.groupKey,
                        translatedName: rawMarketGroup.translatedName,
                        isDefault: rawMarketGroup.isDefault,
                        markets: ServiceProviderModelMapper.optionalMarkets(fromServiceProviderMarkets: rawMarketGroup.markets))

        }

        let sortedMarketGroups = marketGroups.sorted(by: {
            $0.id < $1.id
        })

        self.marketGroupsPublisher.send(sortedMarketGroups)

        self.isLoadingMarketGroups.send(false)
    }

    func storeMarketGroups(fromAggregator aggregator: EveryMatrix.Aggregator) {
        self.store.storeMarketGroups(fromAggregator: aggregator)

        let marketGroups = self.store.marketGroupsArray().map { rawMarketGroup in
            MarketGroup(id: rawMarketGroup.id,
                        type: rawMarketGroup.type,
                        groupKey: rawMarketGroup.groupKey,
                        translatedName: rawMarketGroup.translatedName,
                        isDefault: rawMarketGroup.isDefault,
                        markets: nil)
        }

        self.isLoadingMarketGroups.send(false)

        self.marketGroupsPublisher.send(marketGroups)
    }

    func selectMarketType(atIndex index: Int) {
        self.selectedMarketTypeIndexPublisher.send(index)
    }
    
}

extension MatchDetailsViewModel: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.marketGroupsPublisher.value.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(ListTypeCollectionViewCell.self, indexPath: indexPath),
            let item = self.marketGroupsPublisher.value[safe: indexPath.row]
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
    
    func requestRedCards(forMatchWithId id: String) {
        
        self.goalsSubscription?.cancel()
        self.goalsSubscription = nil

        if let goalsRegister = goalsRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: goalsRegister)
        }
        
        let endpoint = TSRouter.eventPartScoresPublisher(operatorId: Env.appSession.operatorId, language: "en", matchId: id)
        
        self.goalsSubscription = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("%%\(publisherIdentifiable)")
                    self?.goalsRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("MyBets cashoutPublisher initialContent")
                    for content in (aggregator.content ?? []) {
                       switch content {
                        case .eventPartScore(let eventPartScore):
                            if let eventInfoTypeId = eventPartScore.eventInfoTypeID, eventInfoTypeId == "4" {
                                if let homeScore = eventPartScore.homeScore {
                                    self?.homeRedCardsScorePublisher.send(homeScore)
                                    
                                }
                                if let awayscore = eventPartScore.awayScore {
                                    self?.awayRedCardsScorePublisher.send(awayscore)
                                    
                                }
                            }
                        default: ()
                        }
                    }
                case .updatedContent(let aggregatorUpdates):
                    print("MyBets cashoutPublisher updatedContent")
                case .disconnect:
                    print("MyBets cashoutPublisher disconnect")
                }
            })
    }
}
