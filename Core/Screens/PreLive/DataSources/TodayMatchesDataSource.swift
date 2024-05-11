//
//  TodayMatchesDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 18/01/2022.
//

import UIKit
import Combine
import ServicesProvider

class TodayMatchesDataSource: NSObject {

    struct DaysRange: Equatable {
        let startDay: Int
        let endDay: Int

        init?(startDay: Int, endDay: Int) {
            guard startDay >= 0, endDay <= 90, startDay <= endDay else {
                return nil
            }

            self.startDay = startDay
            self.endDay = endDay
        }
    }
    
    var allMatches: [Match] {
        return self.allMatchesSubject.value
    }
    var filteredMatches: [Match] {
        return self.filteredMatchesSubject.value
    }

    var outrightCompetitions: CurrentValueSubject<[Competition]?, Never> = .init(nil)

    var mainMarketsPublisher: AnyPublisher<[Market], Never> {
        return self.filteredMatchesSubject
            .map { $0.flatMap(\.markets) }
            .eraseToAnyPublisher()
    }

    var isLoadingInitialDataPublisher: AnyPublisher<Bool, Never> {
        return self.isLoadingCurrentValueSubject.eraseToAnyPublisher()
    }

    var dataChangedPublisher: AnyPublisher<Void, Never> {
        let matchesChangedArrayPublisher = self.filteredMatchesSubject
            .removeDuplicates()
            .map { _ in }
            .eraseToAnyPublisher()

        let outrightsChangedArrayPublisher = self.outrightCompetitions
            .removeDuplicates()
            .map { _ in }
            .eraseToAnyPublisher()

        return Publishers.Merge3(outrightsChangedArrayPublisher, matchesChangedArrayPublisher, self.forcedRefreshPassthroughSubject)
            .map({ _ in })
            .print("TodayMatchesDataSource dataChangedPublisher send")
            .eraseToAnyPublisher()
    }

    private(set) var filtersOptions: HomeFilterOptions?

    var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?
    var matchLineTableCellViewModelCache: [String: MatchLineTableCellViewModel] = [:]

    var didSelectMatchAction: ((Match) -> Void)?
    var didSelectCompetitionAction: ((Competition) -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var didLongPressOdd: ((BettingTicket) -> Void)?
    var shouldShowSearch: (() -> Void)?

    private var mainMarketsSubject: CurrentValueSubject<[Market], Never> = .init([])

    private var allMatchesSubject: CurrentValueSubject<[Match], Never> = .init([])
    private var filteredMatchesSubject: CurrentValueSubject<[Match], Never> = .init([])

    private var sport: Sport
    private var lastRequestedDaysRange: DaysRange?

    private var isLoadingCurrentValueSubject: CurrentValueSubject<Bool, Never> = .init(false)

    private var hasNextPage = true

    private var todaySubscription: ServicesProvider.Subscription?
    private var todayMatchesPublisher: AnyCancellable?

    private var forcedRefreshPassthroughSubject: PassthroughSubject<Void, Never> = .init()

    private var cancellables = Set<AnyCancellable>()

    init(sport: Sport) {
        self.sport = sport

        super.init()

        self.allMatchesSubject
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.applyFilters(filtersOptions: self.filtersOptions)
            }
            .store(in: &self.cancellables)

        self.requestData(forSport: self.sport)
    }

    func fetchData(forSport sport: Sport, forceRefresh: Bool = false) {
        if !forceRefresh && self.sport == sport {
            return
        }

        if self.sport != sport {
            self.allMatchesSubject.send([])
            self.filteredMatchesSubject.send([])

            self.outrightCompetitions.send(nil)
        }

        self.requestData(forSport: sport)
    }

    private func requestData(forSport sport: Sport) {
        self.sport = sport

        self.hasNextPage = true

        self.fetchTodayMatches()
    }

}

extension TodayMatchesDataSource {

    private func fetchTodayMatchesNextPage() {

        var timeRange = ""
        if let daysRange = self.lastRequestedDaysRange {
            timeRange = "\(daysRange.startDay)-\(daysRange.endDay)"
        }

        let datesFilter = Env.servicesProvider.getDatesFilter(timeRange: timeRange)

        let sportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.sport)

        Env.servicesProvider.requestPreLiveMatchesNextPage(forSportType: sportType,
                                                           initialDate: datesFilter[safe: 0],
                                                           endDate: datesFilter[safe: 1],
                                                           sortType: .date)
            .sink { completion in
                print("requestPreLiveMatchesNextPage completion \(completion)")
            } receiveValue: { [weak self] hasNextPage in
                self?.hasNextPage = hasNextPage
                if !hasNextPage {
                    self?.forcedRefreshPassthroughSubject.send()
                }
            }
            .store(in: &cancellables)
    }

    private func fetchTodayMatches() {

        self.isLoadingCurrentValueSubject.send(true)

        var timeRange = ""
        if let daysRange = self.lastRequestedDaysRange {
            timeRange = "\(daysRange.startDay)-\(daysRange.endDay)"
        }

        let datesFilter = Env.servicesProvider.getDatesFilter(timeRange: timeRange)

        let selectedSportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.sport)

        // We need to clear old subscriptions and publisher cancellables
        self.todaySubscription = nil
        self.todayMatchesPublisher?.cancel()

        self.todayMatchesPublisher = Env.servicesProvider.subscribePreLiveMatches(forSportType: selectedSportType,
                                                                                  initialDate: datesFilter[safe: 0],
                                                                                  endDate: datesFilter[safe: 1],
                                                                                  sortType: .date)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("TodayMatchesDataSource fetchTodayMatches error: \(error)")
                    self?.allMatchesSubject.send([])
                    self?.isLoadingCurrentValueSubject.send(false)
                }
            }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
                switch subscribableContent {
                case .connected(let subscription):
                    self?.todaySubscription = subscription
                case .contentUpdate(let eventsGroups):
                    guard let self = self else { return }

                    let splittedEventGroups = self.splitEventsGroups(eventsGroups)
                    let mappedOutrights: [Competition]? = ServiceProviderModelMapper.competitions(fromEventsGroups: splittedEventGroups.competitionsEventGroups)
                    self.outrightCompetitions.send(mappedOutrights)

                    let mappedMatches = ServiceProviderModelMapper.matches(fromEventsGroups: splittedEventGroups.matchesEventGroups)
                    self.allMatchesSubject.send(mappedMatches)

                    self.isLoadingCurrentValueSubject.send(false)
                case .disconnected:
                    print("TodayMatchesDataSource fetchTodayMatches disconnected")
                }
            })
    }

}

extension TodayMatchesDataSource {

    func clearFilters() {
        self.applyFilters(filtersOptions: nil)
    }

    func applyFilters(filtersOptions: HomeFilterOptions?) {
        self.filtersOptions = filtersOptions

        // Extract the DayRange from publisher
        var daysRange: DaysRange?
        if let filtersOptionsValue = filtersOptions {
            let startDay = filtersOptionsValue.lowerBoundTimeRange
            var endDay = filtersOptionsValue.highBoundTimeRange
            if endDay >= 6 {
                endDay = 90
            }
            daysRange = DaysRange(startDay: startDay, endDay: endDay)
        }

        // Compare with the last one, if any difference request today with new day range
        if self.lastRequestedDaysRange != daysRange {
            self.lastRequestedDaysRange = daysRange
            self.fetchData(forSport: self.sport, forceRefresh: true)
        }

        //
        let filteredMatches = self.filterTodayMatches(with: self.filtersOptions, matches: self.allMatches)
        self.filteredMatchesSubject.send(filteredMatches)
    }

    private func filterTodayMatches(with filtersOptions: HomeFilterOptions?, matches: [Match]) -> [Match] {
        guard let filterOptionsValue = filtersOptions else {
            return matches
        }

        var filteredMatches: [Match] = []

        for match in matches {
            if match.markets.isEmpty {
                continue
            }

            // Check default market order
            var marketSort: [Market] = []
            //            let favoriteMarketIndex = match.markets.firstIndex(where: { $0.typeId == filterOptionsValue.defaultMarket.marketId })
            let favoriteMarketIndex = match.markets.firstIndex(where: { $0.marketTypeId == filterOptionsValue.defaultMarket?.id })

            if let newFirstMarket = match.markets[safe: (favoriteMarketIndex ?? 0)] {
                marketSort.append(newFirstMarket)
            }

            for market in match.markets where market.typeId != marketSort[0].typeId {
                marketSort.append(market)
            }

            // Check odds filter
            let matchOdds = marketSort[0].outcomes
            let oddsRange = filterOptionsValue.lowerBoundOddsRange...filterOptionsValue.highBoundOddsRange
            var oddsInRange = false
            for odd in matchOdds {
                let oddValue = CGFloat(odd.bettingOffer.decimalOdd)
                if oddsRange.contains(oddValue) {
                    oddsInRange = true
                    break
                }
            }

            if oddsInRange {
                var newMatch = match
                newMatch.markets = marketSort

                filteredMatches.append(newMatch)
            }
        }
        return filteredMatches
    }
}

extension TodayMatchesDataSource: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if self.shouldShowOutrightMarkets(), let count = self.outrightCompetitions.value?.count {
                    return count
                }
                return 0
        case 1:
            return self.filteredMatches.count
        case 2:
            if self.hasNextPage {
                return 1
            }
            else {
                return 0
            }
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: OutrightCompetitionLargeLineTableViewCell.identifier)
                as? OutrightCompetitionLargeLineTableViewCell,
               let competition = self.outrightCompetitions.value?[safe: indexPath.row] {

                cell.configure(withViewModel: OutrightCompetitionLargeLineViewModel(competition: competition))
                cell.didSelectCompetitionAction = { [weak self] competition in
                    self?.didSelectCompetitionAction?(competition)
                }
                return cell
            }
        case 1:
            if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
               let match = self.filteredMatches[safe: indexPath.row] {

                if let matchStatsViewModel = self.matchStatsViewModelForMatch?(match) {
                    cell.matchStatsViewModel = matchStatsViewModel
                }
                
                let viewModel = self.matchLineTableCellViewModel(forMatch: match)
                cell.configure(withViewModel: viewModel)
                
                cell.tappedMatchLineAction = { [weak self] match in
                    self?.didSelectMatchAction?(match)
                }

                cell.didLongPressOdd = { [weak self] bettingTicket in
                    self?.didLongPressOdd?(bettingTicket)
                }

                return cell
            }
        case 2:
            if let cell = tableView.dequeueCellType(LoadingMoreTableViewCell.self) {
                return cell
            }
        default:
            ()
        }

        return tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 && self.outrightCompetitions.value != nil && self.filteredMatches.isNotEmpty {
            return nil
        }
        else if section == 0 && self.outrightCompetitions.value != nil && self.filteredMatches.isEmpty {
            ()
        }
        else if self.filteredMatches.isEmpty {
            return nil
        }

        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier)
            as? TitleTableViewHeader {

            headerView.configureWithTitle(localized("upcoming"))

            headerView.setSearchIcon(hasSearch: true)

            headerView.shouldShowSearch = { [weak self] in
                self?.shouldShowSearch?()
            }
            
            return headerView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && self.outrightCompetitions.value != nil && self.filteredMatches.isEmpty {
            return 54
        }

        if self.filteredMatches.isEmpty {
            return .leastNonzeroMagnitude
        }

        if section == 1 {
            return 54
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && self.outrightCompetitions.value != nil && self.filteredMatches.isEmpty {
            return 54
        }

        if self.filteredMatches.isEmpty {
            return .leastNonzeroMagnitude
        }

        if section == 1 {
            return 54
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 145 // Outrights
        case 2:
            return 70 // Loading cell
        default:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 145 // Outrights
        case 2:
            return 70 // Loading cell
        default:
            return StyleHelper.cardsStyleHeight() + 20
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 2, self.filteredMatches.isNotEmpty {
            if let typedCell = cell as? LoadingMoreTableViewCell {
                typedCell.startAnimating()
            }
            self.fetchTodayMatchesNextPage()
        }
    }
}

//
// Helpers
extension TodayMatchesDataSource {

    func matchLineTableCellViewModel(forMatch match: Match) -> MatchLineTableCellViewModel {
        if let matchLineTableCellViewModel = self.matchLineTableCellViewModelCache[match.id] {
            return matchLineTableCellViewModel
        }
        else {
            let matchLineTableCellViewModel = MatchLineTableCellViewModel(match: match, withFullMarkets: false)
            self.matchLineTableCellViewModelCache[match.id] = matchLineTableCellViewModel
            return matchLineTableCellViewModel
        }
    }

    private func splitEventsGroups(_ eventsGroups: [EventsGroup]) -> (matchesEventGroups: [EventsGroup], competitionsEventGroups: [EventsGroup]) {

        var matchEventsGroups: [EventsGroup] = []
        for eventGroup in eventsGroups {
            let matchEvents = eventGroup.events.filter { event in
                event.type == .match
            }
            matchEventsGroups.append(EventsGroup(events: matchEvents, marketGroupId: eventGroup.marketGroupId))
        }

        //
        var competitionEventsGroups: [EventsGroup] = []
        for eventGroup in eventsGroups {
            let competitionEvents = eventGroup.events.filter { event in
                event.type == .competition
            }
            competitionEventsGroups.append(EventsGroup(events: competitionEvents, marketGroupId: eventGroup.marketGroupId))
        }

        return (matchEventsGroups, competitionEventsGroups)
    }

    func shouldShowOutrightMarkets() -> Bool {
        return self.allMatches.isEmpty
    }

}
