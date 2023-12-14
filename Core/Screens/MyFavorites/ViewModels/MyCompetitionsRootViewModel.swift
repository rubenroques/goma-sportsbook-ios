//
//  File.swift
//  Sportsbook
//
//  Created by André Lascas on 25/08/2023.
//

import Foundation
import Combine
import ServicesProvider

class MyCompetitionsRootViewModel {

    var selectedIndexPublisher: CurrentValueSubject<Int?, Never> = .init(nil)

    private var startTabIndex: Int

    // Data
    var favoriteEventsIds: [String] = []
    var favoriteCompetitionsDataPublisher: CurrentValueSubject<[Competition], Never> = .init([])
    var favoriteOutrightCompetitionsDataPublisher: CurrentValueSubject<[Competition], Never> = .init([])

    var fetchedEventSummaryPublisher: CurrentValueSubject<[String], Never> = .init([])
    var selectedCompetitionsInfoPublisher: CurrentValueSubject<[String: SportCompetitionInfo], Never> = .init([:])
    var expectedCompetitionsPublisher: CurrentValueSubject<Int, Never> = .init(0)

    var shouldUpdateContent: (() -> Void)?
    var sendLoadingStatus: (() -> Void)?

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.sendLoadingStatus?()
            }
        }
    }

    private var cancellables = Set<AnyCancellable>()
    private var subscriptions = Set<ServicesProvider.Subscription>()

    private var timer = Timer()

    init(startTabIndex: Int = 0) {
        self.startTabIndex = startTabIndex
        self.selectedIndexPublisher.send(startTabIndex)

        //self.setupPublishers()
    }

    func selectGamesType(atIndex index: Int) {
        self.selectedIndexPublisher.send(index)
    }

    func numberOfShortcutsSections() -> Int {
        return 1
    }

    func numberOfShortcuts(forSection section: Int) -> Int {
        return 6
    }

    func shortcutTitle(forIndex index: Int) -> String {
        switch index {
        case 0:
            return localized("all")
        case 1:
            return localized("live")
        case 2:
            return localized("today")
        case 3:
            return localized("tomorrow")
        case 4:
            return localized("this_week")
        case 5:
            return localized("next_week")
        default:
            return ""
        }
    }

    func setupPublishers() {

        Env.favoritesManager.favoriteCompetitionsIdPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] favoriteEvents in
                guard let self = self else { return }

                if Env.userSessionStore.isUserLogged() {

                    // Set timer to verify events fetched if subscribed events are failing to fetch
                    self.timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { _ in
                        self.verifyEventsFetchedCompletion()
                    }

                    RunLoop.current.add(self.timer, forMode: .common)

                    if favoriteEvents.isNotEmpty {
                        self.isLoading = true
                        self.favoriteEventsIds = favoriteEvents
                        self.fetchFavoriteCompetitionMatches()
                    }
                    else {
                        //let popularCompetitionIds = ["29494.1", "29519.1", "29531.1", "29534.1"]
                        let popularCompetitionIds = Env.favoritesManager.topCompetitionIds
                        
                        self.isLoading = true
                        self.favoriteEventsIds = popularCompetitionIds
                        self.fetchFavoriteCompetitionMatches(customIds: popularCompetitionIds)
                    }

                }
                else {
                    self.shouldUpdateContent?()
                }
            })
            .store(in: &cancellables)

        self.fetchedEventSummaryPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self]  fetchedEventsSummmary in

                if fetchedEventsSummmary.count == self?.favoriteEventsIds.count && fetchedEventsSummmary.isNotEmpty {
                    
                    if let favoriteCompetitions = self?.favoriteCompetitionsDataPublisher.value,
                       favoriteCompetitions.isEmpty {
                        self?.refetchTopCompetitions()
                    }
                    else {
                        self?.shouldUpdateContent?()
                        self?.fetchedEventSummaryPublisher.value = []
                        self?.isLoading = false
                    }
                }
            })
            .store(in: &cancellables)

        Publishers.CombineLatest(self.expectedCompetitionsPublisher, self.selectedCompetitionsInfoPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] expectedCompetitions, selectedCompetitionsInfo in

                if selectedCompetitionsInfo.count == expectedCompetitions {
                    self?.processCompetitionsInfo()
                }
            })
            .store(in: &cancellables)

    }
    
    private func refetchTopCompetitions() {
        self.clearData()
        
        Env.favoritesManager.showSuggestedCompetitionsPublisher.send(true)
        
        let popularCompetitionIds = Env.favoritesManager.topCompetitionIds
        
        self.isLoading = true
        self.favoriteEventsIds = popularCompetitionIds
        self.fetchFavoriteCompetitionMatches(customIds: popularCompetitionIds)
    }

    private func verifyEventsFetchedCompletion() {

        if self.isLoading {
            self.clearData()
            self.fetchFavoriteCompetitionMatches(customIds: self.favoriteEventsIds)
        }
        else {
            self.timer.invalidate()
        }
    }

    private func fetchFavoriteCompetitionMatches(customIds: [String]? = nil) {
        if self.favoriteCompetitionsDataPublisher.value.isNotEmpty {
            self.favoriteCompetitionsDataPublisher.value = []
            self.subscriptions.removeAll()
        }

        var favoriteCompetitionIds = Env.favoritesManager.favoriteCompetitionsIdPublisher.value

        if let customIds {
            favoriteCompetitionIds = customIds
        }

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
//                if let marketGroup = competitionInfo.marketGroups.filter({
//                    $0.name.lowercased().contains("outright")
//                }).first {
//                    self.subscribeCompetitionMatches(forMarketGroupId: marketGroup.id, competitionInfo: competitionInfo, isOutright: true)
//                }
            }
        }
    }

    func subscribeCompetitionMatches(forMarketGroupId marketGroupId: String, competitionInfo: SportCompetitionInfo, isOutright: Bool = false) {

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
                if !isOutright {
                    self?.processCompetitionMatches(matches: matches, competitionInfo: competitionInfo)
                }
                else {
                    self?.processCompetitionOutrightMatches(matches: matches, competitionInfo: competitionInfo)
                }
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
    
    private func processCompetitionOutrightMatches(matches: [Match], competitionInfo: SportCompetitionInfo) {

        let newCompetition = Competition(id: competitionInfo.id,
                                         name: competitionInfo.name,
                                         matches: matches,
                                         venue: matches.first?.venue,
                                         sport: nil,
                                         numberOutrightMarkets: Int(competitionInfo.numberOutrightMarkets) ?? 0,
        competitionInfo: competitionInfo)

        //self.favoriteCompetitionsDataPublisher.value.append(newCompetition)
        self.favoriteOutrightCompetitionsDataPublisher.value.append(newCompetition)

        self.fetchedEventSummaryPublisher.value.append(competitionInfo.id)

    }

    private func clearData() {
        
        self.favoriteCompetitionsDataPublisher.value = []
        self.favoriteOutrightCompetitionsDataPublisher.value = []
        self.fetchedEventSummaryPublisher.value = []
    }

    // Helpers
    func isDateLive(_ date: Date) -> Bool {
        let currentDate = Date()

        if date < currentDate {
            return true
        }

        return false
    }

    func isDateToday(_ date: Date) -> Bool {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return true
        }

        return false
    }

    func isDateTomorrow(_ date: Date) -> Bool {
        let calendar = Calendar.current
        if calendar.isDateInTomorrow(date) {
            return true
        }

        return false

    }

    func isDateInThisWeek(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let currentDate = Date()

        return calendar.isDate(date, equalTo: currentDate, toGranularity: .weekOfYear)
    }

    func isDateInNextWeek(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let currentDate = Date()

        if let nextSunday = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: (8 - calendar.component(.weekday, from: currentDate)), to: currentDate)!),
            let nextSaturday = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: calendar.date(byAdding: .day, value: 6, to: nextSunday)!) {

            return date >= nextSunday && date <= nextSaturday
        }

        return false
    }
}
