//
//  MyGamesViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 04/08/2023.
//

import Foundation
import Combine
import ServicesProvider

class MyGamesViewModel {

    // MARK: Private Properties
    private var favoriteEventsIds: [String] = []

    private var cancellables = Set<AnyCancellable>()
    private var subscriptions = Set<ServicesProvider.Subscription>()

    // MARK: Public Properties
    var userFavoriteMatches: [Match] = []
    var userFavoritesBySportsArray: [FavoriteSportMatches] = []
    var matchesBySportList: [String: [Match]] = [:]

    var fetchedMatchesWithMarketsPublisher: CurrentValueSubject<[Match], Never> = .init([])

    var favoriteMatchesDataPublisher: CurrentValueSubject<[Match], Never> = .init([])
    var fetchedEventSummaryPublisher: CurrentValueSubject<[String], Never> = .init([])
    var dataChangedPublisher = PassthroughSubject<Void, Never>.init()
    var emptyStateStatusPublisher: CurrentValueSubject<EmptyStateType, Never> = .init(.none)
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    var initialLoading: Bool = true

    // Callbacks
    var didSelectMatchAction: ((Match) -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var matchWentLiveAction: (() -> Void)?
    var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?

    var collapsedSportSections: Set<Int> = []

    var myGamesTypeList: MyGamesTypeList
    var filterApplied: FilterFavoritesValue

    // MARK: Caches
    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    enum MyGamesFilterType {
        case time
        case highOdds
    }

    init(myGamesTypeList: MyGamesTypeList, myGamesFilterType: FilterFavoritesValue = .time) {

        self.myGamesTypeList = myGamesTypeList

        self.filterApplied = myGamesFilterType
  
        Env.favoritesManager.favoriteMatchesIdPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] favoriteEvents in
                if Env.userSessionStore.isUserLogged() {
                    
                    if self?.initialLoading == true {
                        self?.isLoadingPublisher.send(true)
                        self?.initialLoading = false
                    }
                    
                    if favoriteEvents.isNotEmpty {
                        self?.favoriteEventsIds = favoriteEvents
                        self?.fetchFavoriteMatches()
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

                    self?.userFavoriteMatches = self?.favoriteMatchesDataPublisher.value ?? []

                    self?.filterMatchesByTypeList(matches: self?.userFavoriteMatches ?? [])

                }
            })
            .store(in: &cancellables)

        self.fetchedMatchesWithMarketsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] fetchedMatches in
                guard let self = self else { return }
                if fetchedMatches.count == self.userFavoriteMatches.count && self.userFavoriteMatches.isNotEmpty {

                    self.userFavoriteMatches = fetchedMatches
                    self.refreshContent()
                }
            })
            .store(in: &cancellables)
    }

    func filterMatchesByTypeList(matches: [Match]) {

        var listMatches = [Match]()

        switch self.myGamesTypeList {
        case .all:
            listMatches = matches
        case .live:
            let filteredMatches = matches.filter({
                self.isDateLive($0.date ?? Date())
            })

            listMatches = filteredMatches
        case .today:
            let filteredMatches = matches.filter({
                self.isDateToday($0.date ?? Date())
            })

            listMatches = filteredMatches
        case .tomorrow:
            let filteredMatches = matches.filter({
                self.isDateTomorrow($0.date ?? Date())
            })

            listMatches = filteredMatches
        case .thisWeek:
            let filteredMatches = matches.filter({
                self.isDateInThisWeek($0.date ?? Date())
            })

            listMatches = filteredMatches
        case .nextWeek:
            let filteredMatches = matches.filter({
                self.isDateInNextWeek($0.date ?? Date())
            })

            listMatches = filteredMatches
        }

        self.userFavoriteMatches = listMatches

        self.setupMatchesBySport(favoriteMatches: listMatches)
        self.updateContentList()

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

                            // Env.favoritesManager.removeFavorite(eventId: eventId, favoriteType: .match)
                        }

                        self?.fetchedEventSummaryPublisher.value.append(eventId)

                    }, receiveValue: { [weak self] eventSummary in
                        guard let self = self else { return }

                        if (eventSummary.homeTeamName != "" || eventSummary.awayTeamName != ""),
                           let match = ServiceProviderModelMapper.match(fromEvent: eventSummary)
                        {
                            self.favoriteMatchesDataPublisher.value.append(match)
                        }

                    })
                    .store(in: &cancellables)
            }

        }
    }

    private func updateContentList() {

        if Env.userSessionStore.isUserLogged() {
            if self.userFavoritesBySportsArray.isEmpty {

                self.emptyStateStatusPublisher.send(.noGames)
            }
            else if self.userFavoritesBySportsArray.isNotEmpty {
                self.emptyStateStatusPublisher.send(.none)
            }

        }
        else {
            self.emptyStateStatusPublisher.send(.noLogin)
        }

        self.isLoadingPublisher.send(false)
        self.dataChangedPublisher.send()

    }

    func setupMatchesBySport(favoriteMatches: [Match]) {

        self.matchesBySportList = [:]
        self.userFavoritesBySportsArray = []

        for match in favoriteMatches {
            if self.matchesBySportList[match.sport.name] != nil {
                self.matchesBySportList[match.sport.name]?.append(match)
            }
            else {
                self.matchesBySportList[match.sport.name] = [match]
            }
        }

        for (key, matches) in matchesBySportList {
                let favoriteSportMatch = FavoriteSportMatches(sportType: key, matches: matches)
            self.userFavoritesBySportsArray.append(favoriteSportMatch)
        }

        // Sort by sportId
        self.userFavoritesBySportsArray.sort {
            $0.sportType < $1.sportType
        }

        // Sort filter applied
        switch self.filterApplied {
        case .time:
            for index in 0..<self.userFavoritesBySportsArray.count {
                self.userFavoritesBySportsArray[index].matches.sort {
                    $0.date ?? Date() < $1.date ?? Date()
                }
            }
        case .higherOdds:
            for index in 0..<self.userFavoritesBySportsArray.count {

                let sortingClosure: (Match, Match) -> Bool = { match1, match2 in
                    // Find the highest decimal odd for each match
                    let highestOdd1 = match1.markets.flatMap { $0.outcomes }.map { $0.bettingOffer.decimalOdd }.max() ?? 0.0
                    let highestOdd2 = match2.markets.flatMap { $0.outcomes }.map { $0.bettingOffer.decimalOdd }.max() ?? 0.0

                    // Compare the highest decimal odds for sorting
                    return highestOdd1 > highestOdd2
                }

                let sortedFavorites = self.userFavoritesBySportsArray[index].matches.sorted(by: sortingClosure)

                self.userFavoritesBySportsArray[index].matches = sortedFavorites
            }
        }
    }

    func refreshContent(withUserWalletRefresh: Bool = false) {

        if withUserWalletRefresh {
            Env.userSessionStore.refreshUserWallet()
        }

        self.filterMatchesByTypeList(matches: self.userFavoriteMatches)
    }

    private func clearData() {

        self.userFavoriteMatches = []
        self.userFavoritesBySportsArray = []

        self.favoriteMatchesDataPublisher.value = []

        self.fetchedEventSummaryPublisher.value = []
        self.fetchedMatchesWithMarketsPublisher.value = []

        self.updateContentList()

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
