//
//  PopularMatchesDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 18/01/2022.
//

import UIKit
import Combine
import ServicesProvider

class PopularMatchesDataSource: NSObject {

    //
    // Public Vars
    var allMatches: [Match] {
        return self.allMatchesSubject.value
    }
    var filteredMatches: [Match] {
        return self.filteredMatchesSubject.value
    }

    var isLoadingInitialDataPublisher: AnyPublisher<Bool, Never> {
        return self.isLoadingCurrentValueSubject.eraseToAnyPublisher()
    }

    var dataChangedPublisher: AnyPublisher<Void, Never> {
        let matchesChangedArrayPublisher = self.filteredMatchesSubject
            .removeDuplicates()
            .map { _ in }
            .eraseToAnyPublisher()

        let outrightsChangedArrayPublisher = self.allOutrightCompetitionsSubject
            .removeDuplicates()
            .map { _ in }
            .eraseToAnyPublisher()

        return Publishers.Merge3(outrightsChangedArrayPublisher, matchesChangedArrayPublisher, self.forcedRefreshPassthroughSubject)
            .map({ _ in })
            .print("PopularMatchesDataSource dataChangedPublisher send")
            .eraseToAnyPublisher()
    }

    private(set) var filtersOptions: HomeFilterOptions?

    // Clojures
    var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?
    var matchLineTableCellViewModelCache: [String: MatchLineTableCellViewModel] = [:]

    var didSelectMatchAction: ((Match) -> Void)?
    var didSelectCompetitionAction: ((Competition) -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var didLongPressOdd: ((BettingTicket) -> Void)?
    var shouldShowSearch: (() -> Void)?

    //
    // Private Vars

    private var allMatchesSubject: CurrentValueSubject<[Match], Never> = .init([])
    private var filteredMatchesSubject: CurrentValueSubject<[Match], Never> = .init([])

    var allOutrightCompetitionsSubject: CurrentValueSubject<[Competition]?, Never> = .init(nil)

    private var sport: Sport

    private var popularSubscription: ServicesProvider.Subscription?
    private var popularMatchesPublisher: AnyCancellable?

    private var isLoadingCurrentValueSubject: CurrentValueSubject<Bool, Never> = .init(false)

    private var forcedRefreshPassthroughSubject: PassthroughSubject<Void, Never> = .init()

    private var hasNextPage = true

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
            self.allOutrightCompetitionsSubject.send(nil)
        }

        self.requestData(forSport: sport)
    }

    private func requestData(forSport sport: Sport) {
        self.sport = sport

        self.hasNextPage = true

        self.fetchPopularMatches()
    }

}

extension PopularMatchesDataSource {

    private func fetchPopularMatchesNextPage() {
        let sportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.sport)
        Env.servicesProvider.requestPreLiveMatchesNextPage(forSportType: sportType, sortType: .popular)
            .sink { completion in
                print("PopularMatchesDataSource fetchPopularMatchesNextPage completion \(completion)")
            } receiveValue: { [weak self] hasNextPage in
                self?.hasNextPage = hasNextPage

                if  !hasNextPage {
                    self?.forcedRefreshPassthroughSubject.send()
                }
            }
            .store(in: &cancellables)
    }

    private func fetchPopularMatches() {

        print("PopularMatchesDataSource fetchPopularMatches requested ")

        self.isLoadingCurrentValueSubject.send(true)

        let sportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.sport)

        // We need to clear old subscriptions and publisher cancellables
        self.popularSubscription = nil
        self.popularMatchesPublisher?.cancel()

        self.popularMatchesPublisher = Env.servicesProvider.subscribePreLiveMatches(forSportType: sportType, sortType: .popular)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("PopularMatchesDataSource fetchPopularMatches error: \(error)")
                    self?.allMatchesSubject.send([])
                    self?.isLoadingCurrentValueSubject.send(false)
                }
            }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
                switch subscribableContent {
                case .connected(let subscription):
                    print("PopularMatchesDataSource fetchPopularMatches connected \(subscription)")
                    self?.popularSubscription = subscription
                case .contentUpdate(let eventsGroups):
                    guard let self = self else { return }
                    print("PopularMatchesDataSource fetchPopularMatches recieved data \(eventsGroups.count)")

                    let splittedEventGroups = self.splitEventsGroups(eventsGroups)
                    let mappedOutrights: [Competition]? = ServiceProviderModelMapper.competitions(fromEventsGroups: splittedEventGroups.competitionsEventGroups)
                    self.allOutrightCompetitionsSubject.send(mappedOutrights)

                    let mappedMatches = ServiceProviderModelMapper.matches(fromEventsGroups: splittedEventGroups.matchesEventGroups)
                    self.allMatchesSubject.send(mappedMatches)

                    // TODO: main markets
                    // self.setMainMarkets(matches: popularMatches)

                    self.isLoadingCurrentValueSubject.send(false)
                case .disconnected:
                    print("PopularMatchesDataSource fetchPopularMatches disconnected")
                }
            })
    }
}

// Filters
extension PopularMatchesDataSource {

    func clearFilters() {
        self.applyFilters(filtersOptions: nil)
    }

    func applyFilters(filtersOptions: HomeFilterOptions?) {
        self.filtersOptions = filtersOptions

        let filteredMatches = self.filterPopularMatches(with: self.filtersOptions, matches: self.allMatches)
        self.filteredMatchesSubject.send(filteredMatches)
    }

    private func filterPopularMatches(with filtersOptions: HomeFilterOptions?, matches: [Match]) -> [Match] {

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

            for market in match.markets {
                if market.typeId != marketSort[0].typeId {
                    marketSort.append(market)
                }
            }

            // Check odds filter
            let matchOdds = marketSort[0].outcomes
            let oddsRange = filterOptionsValue.lowerBoundOddsRange...filterOptionsValue.highBoundOddsRange
            for odd in matchOdds {
                let oddValue = CGFloat(odd.bettingOffer.decimalOdd)
                if oddsRange.contains(oddValue) {
                    var newMatch = match
                    newMatch.markets = marketSort

                    filteredMatches.append(newMatch)
                    break
                }
            }

        }
        return filteredMatches
    }


}

extension PopularMatchesDataSource: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if self.shouldShowOutrightMarkets(), let count = self.allOutrightCompetitionsSubject.value?.count {
                return count
            }
            return 0
        case 1:
            return self.filteredMatches.count
        case 2: // LoadingMoreTableViewCell
            if self.hasNextPage {
                return 1
            }
            else {
                return 0
            }
        case 3: // FooterResponsibleGamingViewCell
            return 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: OutrightCompetitionLargeLineTableViewCell.identifier)
                    as? OutrightCompetitionLargeLineTableViewCell,
                let competition = self.allOutrightCompetitionsSubject.value?[safe: indexPath.row]
            else {
                fatalError()
            }
            cell.configure(withViewModel: OutrightCompetitionLargeLineViewModel(competition: competition))
            cell.didSelectCompetitionAction = { [weak self] competition in
                self?.didSelectCompetitionAction?(competition)
            }
            return cell

        case 1:
            if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
               let match = self.filteredMatches[safe: indexPath.row] {

                if let matchStatsViewModel = self.matchStatsViewModelForMatch?(match) {
                    cell.matchStatsViewModel = matchStatsViewModel
                }

                let viewModel = self.matchLineTableCellViewModel(forMatch: match)
                cell.viewModel = viewModel
                
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

        case 3:
            if let cell = tableView.dequeueCellType(FooterResponsibleGamingViewCell.self) {
                return cell
            }
            
        default:
            fatalError()
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if section == 0 && self.allOutrightCompetitionsSubject.value != nil && self.filteredMatches.isNotEmpty {
            return nil
        }
        else if section == 0 && self.allOutrightCompetitionsSubject.value != nil && self.filteredMatches.isEmpty {
            ()
        }
        else if self.filteredMatches.isEmpty {
            return nil
        }

        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier) as? TitleTableViewHeader
        else {
            fatalError()
        }

        headerView.configureWithTitle(localized("popular_games"))

        headerView.setSearchIcon(hasSearch: true)

        headerView.shouldShowSearch = { [weak self] in
            self?.shouldShowSearch?()
        }

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && self.allOutrightCompetitionsSubject.value != nil && self.filteredMatches.isEmpty {
            return 54
        }

        if self.filteredMatches.isEmpty {
            return .leastNonzeroMagnitude
        }

        if section == 1 {
            return 54
        }
        return .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && self.allOutrightCompetitionsSubject.value != nil && self.filteredMatches.isEmpty {
            return 54
        }

        if self.filteredMatches.isEmpty {
            return .leastNonzeroMagnitude
        }

        if section == 1 {
            return 54
        }
        return .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 145 // Outrights
        case 1:
            return UITableView.automaticDimension // Matches
        case 2:
            return 70 // Loading cell
        case 3:
            return UITableView.automaticDimension // Footer
        default:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 145 // Outrights
        case 1:
            return StyleHelper.cardsStyleHeight() + 20 // Matches
        case 2:
            return 70 // Loading cell
        case 3:
            return 120
        default:
            return StyleHelper.cardsStyleHeight() + 20
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 2, self.filteredMatches.isNotEmpty {
            if let loadingMoreTableViewCell = cell as? LoadingMoreTableViewCell {
                loadingMoreTableViewCell.startAnimating()
            }
            self.fetchPopularMatchesNextPage()
        }
    }

}

//
// Helpers
extension PopularMatchesDataSource {

    private func matchLineTableCellViewModel(forMatch match: Match) -> MatchLineTableCellViewModel {
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
