//
//  MyFavoritesViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 10/02/2022.
//

import Foundation
import Combine
import OrderedCollections
import ServicesProvider

class MyFavoritesViewModel: NSObject {

    // MARK: Private Properties
    private var favoriteEventsIds: [String] = []

    private var cancellables = Set<AnyCancellable>()
    private var subscriptions = Set<ServicesProvider.Subscription>()

    // MARK: Public Properties
    var favoriteMatchesDataPublisher: CurrentValueSubject<[Match], Never> = .init([])
    var favoriteCompetitionsDataPublisher: CurrentValueSubject<[Competition], Never> = .init([])
    var favoriteOutrightCompetitionsDataPublisher: CurrentValueSubject<[Competition], Never> = .init([])

    var fetchedEventSummaryPublisher: CurrentValueSubject<[String], Never> = .init([])
    var selectedCompetitionsInfoPublisher: CurrentValueSubject<[String: SportCompetitionInfo], Never> = .init([:])
    var expectedCompetitionsPublisher: CurrentValueSubject<Int, Never> = .init(0)

    var dataChangedPublisher = PassthroughSubject<Void, Never>.init()
    var favoriteListTypePublisher: CurrentValueSubject<FavoriteListType, Never> = .init(.favoriteGames)
    var emptyStateStatusPublisher: CurrentValueSubject<EmptyStateType, Never> = .init(.none)
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    var initialLoading: Bool = true

    enum FavoriteListType {
        case favoriteGames
        case favoriteCompetitions
    }

    // MARK: Caches
    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    // MARK: Lifetime and Cycle
    override init() {
        super.init()

        self.initialSetup()
    }

    // MARK: Functions
    private func initialSetup() {
        self.setupPublishers()
    }

    func matchStatsViewModel(forMatch match: Match) -> MatchStatsViewModel {
        if let viewModel = cachedMatchStatsViewModels[match.id] {
            return viewModel
        }
        else {
            let viewModel = MatchStatsViewModel(match: match)
            cachedMatchStatsViewModels[match.id] = viewModel
            return viewModel
        }
    }

    func setFavoriteListType(_ favoriteListType: FavoriteListType) {
        self.favoriteListTypePublisher.send(favoriteListType)
        self.updateContentList()
    }

    func markAsFavorite(match: Match) {

        var isFavorite = false
        for matchId in Env.favoritesManager.favoriteEventsIdPublisher.value where matchId == match.id {
            isFavorite = true
        }

        if isFavorite {
            Env.favoritesManager.removeFavorite(eventId: match.id, favoriteType: .match)
        }
        else {
            Env.favoritesManager.addFavorite(eventId: match.id, favoriteType: .match)
        }
    }
    
    func markCompetitionAsFavorite(competition: Competition) {
        
        var isFavorite = false
        for competitionId in Env.favoritesManager.favoriteEventsIdPublisher.value where competitionId == competition.id {
            isFavorite = true
        }
        
        if isFavorite {
            Env.favoritesManager.removeFavorite(eventId: competition.id, favoriteType: .competition)
        }
        else {
            Env.favoritesManager.addFavorite(eventId: competition.id, favoriteType: .competition)
        }
   
    }

    private func setupPublishers() {

        Env.favoritesManager.favoriteEventsIdPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] favoriteEvents in
                if Env.userSessionStore.isUserLogged() {
                    if self?.initialLoading == true {
                     self?.isLoadingPublisher.send(true)
                        self?.initialLoading = false
                    }
                    self?.favoriteEventsIds = favoriteEvents
                    self?.fetchFavoriteMatches()

                }
                else {
                    self?.isLoadingPublisher.send(false)
                    self?.dataChangedPublisher.send()
                    self?.emptyStateStatusPublisher.send(.noLogin)
                }
            })
            .store(in: &cancellables)

        self.fetchedEventSummaryPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self]  fetchedEventsSummmary in

                print("FETCHED COUNT: \(fetchedEventsSummmary.count)")

                if fetchedEventsSummmary.count == self?.favoriteEventsIds.count && fetchedEventsSummmary.isNotEmpty {
                    self?.updateContentList()
                }
            })
            .store(in: &cancellables)

        Publishers.CombineLatest(self.expectedCompetitionsPublisher, self.selectedCompetitionsInfoPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] expectedCompetitions, selectedCompetitionsInfo in

                if selectedCompetitionsInfo.count == expectedCompetitions {
                    print("ALL COMPETITIONS DATA")
                    self?.processCompetitionsInfo()
                }
            })
            .store(in: &cancellables)
    }

    func processCompetitionsInfo() {

        let competitionInfos = self.selectedCompetitionsInfoPublisher.value.map({$0.value})

        self.favoriteCompetitionsDataPublisher.value = []

        for competitionInfo in competitionInfos {

            if let marketGroup = competitionInfo.marketGroups.filter({
                $0.name.lowercased().contains("main")
            }).first {
                self.subscribeCompetitionMatches(forMarketGroupId: marketGroup.id, competitionInfo: competitionInfo)

            }
            else {
                //self.processCompetitionOutrights(competitionInfo: competitionInfo)
                self.fetchedEventSummaryPublisher.value.append(competitionInfo.id)
            }
            //self.subscribeCompetitionMatches(forMarketGroupId: competitionInfo.id, competitionInfo: competitionInfo)
        }
    }

    func subscribeCompetitionMatches(forMarketGroupId marketGroupId: String, competitionInfo: SportCompetitionInfo) {

        Env.servicesProvider.subscribeCompetitionMatches(forMarketGroupId: marketGroupId)
        .sink { [weak self] (completion: Subscribers.Completion<ServiceProviderError>) in
            switch completion {
            case .finished:
                ()
            case .failure:
                print("SUBSCRIPTION COMPETITION MATCHES ERROR")
            }
        } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
            switch subscribableContent {
            case .connected(let subscription):
                self?.subscriptions.insert(subscription)
            case .contentUpdate(let eventsGroups):
                let matches = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups)
                self?.processCompetitionMatches(matches: matches, competitionInfo: competitionInfo)
            case .disconnected:
                ()
            }
        }
        .store(in: &cancellables)
    }

    private func processCompetitionMatches(matches: [Match], competitionInfo: SportCompetitionInfo) {

        let newCompetition = Competition(id: competitionInfo.id,
                                         name: competitionInfo.name,
                                         matches: matches,
                                         sport: nil,
                                         numberOutrightMarkets: Int(competitionInfo.numberOutrightMarkets) ?? 0,
        competitionInfo: competitionInfo)

        self.favoriteCompetitionsDataPublisher.value.append(newCompetition)

        self.fetchedEventSummaryPublisher.value.append(competitionInfo.id)

    }

    private func fetchFavoriteMatches() {

        if self.favoriteMatchesDataPublisher.value.isNotEmpty {
            self.favoriteMatchesDataPublisher.value = []
            self.fetchedEventSummaryPublisher.value = []
        }

        if self.favoriteEventsIds.isEmpty {
            self.updateContentList()
        }
        else {
            let favoriteMatchesIds = Env.favoritesManager.favoriteMatchesIdPublisher.value

            for eventId in favoriteMatchesIds {

                Env.servicesProvider.getEventSummary(eventId: eventId)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { [weak self] completion in
                        switch completion {
                        case .finished:
                            ()
                        case .failure(let error):
                            print("EVENT SUMMARY FAV ERROR: \(error)")

                            Env.favoritesManager.removeFavorite(eventId: eventId, favoriteType: .match)
                        }

                        self?.fetchedEventSummaryPublisher.value.append(eventId)

                    }, receiveValue: { [weak self] eventSummary in
                        guard let self = self else { return }

                        if eventSummary.homeTeamName != "" || eventSummary.awayTeamName != "" {
                            let match = ServiceProviderModelMapper.match(fromEvent: eventSummary)
                            self.favoriteMatchesDataPublisher.value.append(match)

                        }

                    })
                    .store(in: &cancellables)
            }

            self.fetchFavoriteCompetitionMatches()
        }

    }

    private func fetchFavoriteCompetitionMatches() {
        if self.favoriteCompetitionsDataPublisher.value.isNotEmpty {
            self.favoriteCompetitionsDataPublisher.value = []
        }

        let favoriteCompetitionIds = Env.favoritesManager.favoriteCompetitionsIdPublisher.value

        self.expectedCompetitionsPublisher.value = favoriteCompetitionIds.count

        self.fetchFavoriteCompetitionsMatchesWithIds(favoriteCompetitionIds)
    }

    func fetchFavoriteCompetitionsMatchesWithIds(_ ids: [String]) {

        self.selectedCompetitionsInfoPublisher.value = [:]

        for competitionId in ids {
            Env.servicesProvider.getCompetitionMarketGroups(competitionId: competitionId)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        ()
                    case .failure(let error):
                        print("COMPETITION INFO ERROR: \(error)")
                        self?.selectedCompetitionsInfoPublisher.value[competitionId] = nil
                    }

                }, receiveValue: { [weak self] competitionInfo in

                    self?.selectedCompetitionsInfoPublisher.value[competitionInfo.id] = competitionInfo
                })
                .store(in: &cancellables)
        }

    }

    private func updateContentList() {

        if Env.userSessionStore.isUserLogged() {
            if self.favoriteMatchesDataPublisher.value.isEmpty &&
                self.favoriteCompetitionsDataPublisher.value.isEmpty &&
                self.favoriteOutrightCompetitionsDataPublisher.value.isEmpty {
                
                self.emptyStateStatusPublisher.send(.noFavorites)
            }
            else if self.favoriteMatchesDataPublisher.value.isNotEmpty && self.favoriteCompetitionsDataPublisher.value.isNotEmpty {
                self.emptyStateStatusPublisher.send(.none)
            }
            else {
                if self.favoriteMatchesDataPublisher.value.isEmpty {
                    self.emptyStateStatusPublisher.send(.noGames)
                }
                else if self.favoriteCompetitionsDataPublisher.value.isEmpty &&
                            self.favoriteOutrightCompetitionsDataPublisher.value.isEmpty {
                    self.emptyStateStatusPublisher.send(.noCompetitions)
                }
            }

        }
        else {
            self.emptyStateStatusPublisher.send(.noLogin)
        }

        self.isLoadingPublisher.send(false)
        self.dataChangedPublisher.send()

    }

}
