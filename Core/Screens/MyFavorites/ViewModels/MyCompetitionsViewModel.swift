//
//  MyCompetitionsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 04/08/2023.
//

import Foundation
import Combine
import ServicesProvider

class MyCompetitionsViewModel {

    var competitions: [Competition] = []
    var outrightCompetitions: [Competition] = []
    var collapsedCompetitionsSections: Set<Int> = []
    var cachedMatchWidgetCellViewModels: [String: MatchWidgetCellViewModel] = [:]

    var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?

    var favoriteEventsIds: [String] = []
    var favoriteCompetitionsDataPublisher: CurrentValueSubject<[Competition], Never> = .init([])
    var favoriteOutrightCompetitionsDataPublisher: CurrentValueSubject<[Competition], Never> = .init([])

    var fetchedEventSummaryPublisher: CurrentValueSubject<[String], Never> = .init([])
    var selectedCompetitionsInfoPublisher: CurrentValueSubject<[String: SportCompetitionInfo], Never> = .init([:])
    var expectedCompetitionsPublisher: CurrentValueSubject<Int, Never> = .init(0)

    var dataChangedPublisher = PassthroughSubject<Void, Never>.init()
    var emptyStateStatusPublisher: CurrentValueSubject<EmptyStateType, Never> = .init(.none)

    var initialLoading: Bool = true

    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    private var cancellables = Set<AnyCancellable>()
    private var subscriptions = Set<ServicesProvider.Subscription>()

    // Callbacks
    var didSelectMatchAction: ((Match) -> Void)?
    var didTapFavoriteCompetitionAction: ((Competition) -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var didSelectCompetitionAction: ((Competition) -> Void)?
    var matchWentLiveAction: (() -> Void)?

    init() {

        Env.favoritesManager.favoriteCompetitionsIdPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] favoriteEvents in
                if Env.userSessionStore.isUserLogged() {
                    if self?.initialLoading == true {
                     self?.isLoadingPublisher.send(true)
                        self?.initialLoading = false
                    }

                    if favoriteEvents.isNotEmpty {
                        self?.favoriteEventsIds = favoriteEvents
                        self?.fetchFavoriteCompetitionMatches()
                    }
                    else {
                        self?.clearData()
                    }

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
                self.fetchedEventSummaryPublisher.value.append(competitionInfo.id)
            }
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
                                         venue: matches.first?.venue,
                                         sport: nil,
                                         numberOutrightMarkets: Int(competitionInfo.numberOutrightMarkets) ?? 0,
        competitionInfo: competitionInfo)

        self.favoriteCompetitionsDataPublisher.value.append(newCompetition)

        self.fetchedEventSummaryPublisher.value.append(competitionInfo.id)

    }

    private func updateContentList() {

        if Env.userSessionStore.isUserLogged() {
            if self.favoriteCompetitionsDataPublisher.value.isEmpty &&
                self.favoriteOutrightCompetitionsDataPublisher.value.isEmpty {

                self.emptyStateStatusPublisher.send(.noCompetitions)
            }
            else if self.favoriteCompetitionsDataPublisher.value.isNotEmpty {
                self.emptyStateStatusPublisher.send(.none)
            }

        }
        else {
            self.emptyStateStatusPublisher.send(.noLogin)
        }

        self.competitions = self.favoriteCompetitionsDataPublisher.value

        self.outrightCompetitions = self.favoriteOutrightCompetitionsDataPublisher.value

        self.isLoadingPublisher.send(false)
        self.dataChangedPublisher.send()

    }

    private func clearData() {

        self.competitions = []
        self.outrightCompetitions = []

        self.favoriteCompetitionsDataPublisher.value = []
        self.favoriteOutrightCompetitionsDataPublisher.value = []

        self.updateContentList()

    }
}
