//
//  TopCompetitionsDataSource.swift
//  Sportsbook
//
//  Created by André Lascas on 06/07/2023.
//

import Foundation
import UIKit
import Combine
import ServicesProvider

class TopCompetitionsDataSource: NSObject {

    var allCompetitions: [Competition] {
        return self.allCompetitionsSubject.value
    }
    var filteredCompetitions: [Competition] {
        return self.filteredCompetitionsSubject.value
    }

    var allCompetitionsSubject: CurrentValueSubject<[Competition], Never> = .init([])
    var filteredCompetitionsSubject: CurrentValueSubject<[Competition], Never> = .init([])

    var hasTopCompetitionsPublisher: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest(self.sportSubject.removeDuplicates(),
                                        self.topCompetitionsIdentifiersSubject.removeDuplicates())
            .map { currentSport, topCompetitionsIdentifiers -> Bool in
                let currentSportName = currentSport.name.lowercased().replacingOccurrences(of: " ", with: "-")
                let contains = topCompetitionsIdentifiers.contains(where: { $0.key == currentSportName })
                return contains
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var isLoadingInitialDataPublisher: AnyPublisher<Bool, Never> {
        return self.isLoadingCurrentValueSubject.eraseToAnyPublisher()
    }

    var dataChangedPublisher: AnyPublisher<Void, Never> {
        let changedArrayPublisher = self.filteredCompetitionsSubject
            .removeDuplicates()
            .map { _ in }
            .eraseToAnyPublisher()

        return Publishers.Merge(changedArrayPublisher, self.forcedRefreshPassthroughSubject)
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .map({ _ in })
            .eraseToAnyPublisher()
    }

    var mainMarketsPublisher: AnyPublisher<[Market], Never> {
        return self.filteredCompetitionsSubject
            .map { $0.flatMap(\.matches).flatMap(\.markets) }
            .eraseToAnyPublisher()
    }

    private(set) var filtersOptions: HomeFilterOptions?

    var didSelectMatchAction: ((Match) -> Void)?
    var didSelectCompetitionAction: ((Competition) -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?

    var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?

    private var sportSubject: CurrentValueSubject<Sport, Never>

    private var topCompetitionsIdentifiersSubject: CurrentValueSubject<[String: [String]], Never> = .init([:])
    private var collapsedCompetitionsSections: Set<Int> = []

    private var hasTopCompetitionsSubject: CurrentValueSubject<Bool, Never> = .init(false)
    private var isLoadingCurrentValueSubject: CurrentValueSubject<Bool, Never> = .init(false)
    private var activeNetworkRequestCount = 0 {
        didSet {
            print("TopCompetitionsDataSource activeNetworkRequestCount: \(self.activeNetworkRequestCount)")
            self.isLoadingCurrentValueSubject.send(activeNetworkRequestCount > 0)
        }
    }

    private var forcedRefreshPassthroughSubject: PassthroughSubject<Void, Never> = .init()

    private var competitionsMatchesSubscriptions: [String: ServicesProvider.Subscription] = [:]
    private var sportFromLastRequestedData: Sport?

    private var cancellables = Set<AnyCancellable>()

    init(sport: Sport) {
        self.sportSubject = .init(sport)
        super.init()

        self.allCompetitionsSubject
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.collapsedCompetitionsSections = []
                self.applyFilters(filtersOptions: self.filtersOptions)
            }
            .store(in: &self.cancellables)

        self.fetchTopCompetitionsIdentifiers()
    }

    func setSport(_ sport: Sport) {
        self.sportSubject.send(sport)
        self.sportFromLastRequestedData = nil
    }

    func fetchData(forSport sport: Sport, forceRefresh: Bool = false) {
        if !forceRefresh && self.sportFromLastRequestedData == sport && self.filteredCompetitions.isNotEmpty {
            return
        }
        self.requestData(forSport: sport)
    }

    private func requestData(forSport sport: Sport) {

        print("TopCompetitionsDataSource requestData for:\(sport.name)")

        self.sportSubject.send(sport)
        self.sportFromLastRequestedData = sport

        self.competitionsMatchesSubscriptions = [:]

        self.allCompetitionsSubject.send([])
        self.filteredCompetitionsSubject.send([])

        self.fetchTopCompetitionsMatches()
    }

}

//
// Fetch if we have any top competitions for the current sport
extension TopCompetitionsDataSource {

    private func fetchTopCompetitionsIdentifiers() {

        Env.servicesProvider.getTopCompetitionsPointers()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("TopCompetitionsDataSource getTopCompetitionsIdentifier error: \(error)")
                }
            }, receiveValue: { [weak self] topCompetitions in
                let topCompetitionsIds = self?.processTopCompetitions(topCompetitions: topCompetitions) ?? [:]
                self?.topCompetitionsIdentifiersSubject.send(topCompetitionsIds)
            })
            .store(in: &cancellables)

    }

    private func processTopCompetitions(topCompetitions: [TopCompetitionPointer]) -> [String: [String]] {
        var competitionsIdentifiers: [String: [String]] = [:]
        for topCompetition in topCompetitions {
            let competitionComponents = topCompetition.competitionId.components(separatedBy: "/")
            let competitionName = competitionComponents[competitionComponents.count - 3].lowercased()
            if let competitionId = competitionComponents.last {
                if let topCompetition = competitionsIdentifiers[competitionName] {
                    if !topCompetition.contains(where: {
                        $0 == competitionId
                    }) {
                        competitionsIdentifiers[competitionName]?.append(competitionId)
                    }

                }
                else {
                    competitionsIdentifiers[competitionName] = [competitionId]
                }
            }
        }
        return competitionsIdentifiers
    }

}

//
// Fetch the topCompetitions for the current
extension TopCompetitionsDataSource {

    private func fetchTopCompetitionsMatches() {

        self.activeNetworkRequestCount += 1

        let currentSportName = self.sportSubject.value.name.lowercased().replacingOccurrences(of: " ", with: "-")
        let competitionIds = self.topCompetitionsIdentifiersSubject.value[currentSportName] ?? []

        let competitionsMatchesPublishers = self.requestForTopCompetitionsMatchesWithIds(competitionIds)
        Publishers.MergeMany(competitionsMatchesPublishers)
            .compactMap({ $0 })
            .collect()
            .map({ competitionInfos in
                return competitionInfos.reduce(into: [String: SportCompetitionInfo](), { result, competitionInfo in
                    result[competitionInfo.id] = competitionInfo
                })
            })
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("TopCompetitionsDataSource fetchTopCompetitionsMatches - Finished all the requests")
                case .failure(let error):
                    print("TopCompetitionsDataSource fetchTopCompetitionsMatches - Finished all the requests with an error \(error)")
                }
                self?.activeNetworkRequestCount -= 1
            } receiveValue: { competitionInfoDictionsary in
                self.processTopCompetitionsInfo(competitionInfoDictionsary)
            }
            .store(in: &self.cancellables)

    }

    private func requestForTopCompetitionsMatchesWithIds(_ competitionIds: [String]) -> [AnyPublisher<SportCompetitionInfo?, Never>] {

        var publishers: [AnyPublisher<SportCompetitionInfo?, Never>] = []
        for competitionId in competitionIds {
            let sportCompetitionInfoPublisher = Env.servicesProvider.getCompetitionMarketGroups(competitionId: competitionId)
                .map({ competitionInfo in return Optional.some(competitionInfo) })
                .replaceError(with: nil)
                .eraseToAnyPublisher()
            publishers.append(sportCompetitionInfoPublisher)
        }
        return publishers

    }

    private func processTopCompetitionsInfo(_ selectedTopCompetitionsInfo: [String: SportCompetitionInfo]) {

        let competitionInfos = selectedTopCompetitionsInfo.map({ $0.value }).filter({
            $0.marketGroups.isNotEmpty
        })

        self.competitionsMatchesSubscriptions = [:]
        self.allCompetitionsSubject.send([])

        for competitionInfo in competitionInfos {
            if let marketGroup = competitionInfo.marketGroups.filter({ $0.name.lowercased().contains("main") }).first {
                self.subscribeTopCompetitionMatches(forMarketGroupId: marketGroup.id, competitionInfo: competitionInfo)
            }
            else if let marketGroup = competitionInfo.marketGroups.filter({ $0.name.lowercased().contains("outright") }).first {
                self.subscribeTopCompetitionOutright(forMarketGroupId: marketGroup.id, competitionInfo: competitionInfo)
            }
        }

    }

    private func subscribeTopCompetitionMatches(forMarketGroupId marketGroupId: String, competitionInfo: SportCompetitionInfo) {

        let competitionId = competitionInfo.id

        self.activeNetworkRequestCount += 1

        Env.servicesProvider.subscribeCompetitionMatches(forMarketGroupId: marketGroupId)
        .sink { [weak self] completion  in
            switch completion {
            case .finished:
                print("TopCompetitionsDataSource subscribeTopCompetitionMatches - completed")
            case .failure(let error):
                print("TopCompetitionsDataSource subscribeTopCompetitionMatches - completed with error \(error)")
            }
            self?.activeNetworkRequestCount -= 1
        } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
            switch subscribableContent {
            case .connected(let subscription):
                self?.competitionsMatchesSubscriptions[competitionId] = subscription
            case .contentUpdate(let eventsGroups):
                let matches = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups)
                self?.processCompetitionMatches(matches: matches, competitionInfo: competitionInfo)
                self?.activeNetworkRequestCount -= 1
            case .disconnected:
                self?.competitionsMatchesSubscriptions[competitionId] = nil
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

        self.allCompetitionsSubject.value.append(newCompetition)

    }

    private func subscribeTopCompetitionOutright(forMarketGroupId marketGroupId: String, competitionInfo: SportCompetitionInfo) {

        self.activeNetworkRequestCount += 1

        let competitionId = competitionInfo.id

        Env.servicesProvider.subscribeCompetitionMatches(forMarketGroupId: marketGroupId)
        .sink { [weak self] completion in
            switch completion {
            case .finished:
                print("TopCompetitionsDataSource subscribeTopCompetitionOutright - completed")
            case .failure(let error):
                print("TopCompetitionsDataSource subscribeTopCompetitionOutright - completed with error \(error)")
            }
            self?.activeNetworkRequestCount -= 1
        } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
            switch subscribableContent {
            case .connected(let subscription):
                self?.competitionsMatchesSubscriptions[competitionId] = subscription
            case .contentUpdate(let eventsGroups):
                if let outrightMatch = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups).first {
                    self?.processTopCompetitionOutrights(outrightMatch: outrightMatch, competitionInfo: competitionInfo)
                }
                self?.activeNetworkRequestCount -= 1
            case .disconnected:
                self?.competitionsMatchesSubscriptions[competitionId] = nil
            }
        }
        .store(in: &cancellables)
    }

    private func processTopCompetitionOutrights(outrightMatch: Match, competitionInfo: SportCompetitionInfo) {

        guard
            !self.allCompetitionsSubject.value.contains(where: { $0.id == competitionInfo.id })
        else {
            return
        }

        let numberOutrightMarkets = competitionInfo.numberOutrightMarkets == "0" ? 1 : Int(competitionInfo.numberOutrightMarkets) ?? 0

        let newCompetition = Competition(id: competitionInfo.id,
                                         name: competitionInfo.name,
                                         matches: [],
                                         venue: outrightMatch.venue,
                                         sport: nil,
                                         numberOutrightMarkets: numberOutrightMarkets,
                                         competitionInfo: competitionInfo)

        self.allCompetitionsSubject.value.append(newCompetition)

    }

}

//
//
extension TopCompetitionsDataSource {

    private func topCompetitionMatchesPublisher(forMarketGroupId marketGroupId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        return Env.servicesProvider
            .subscribeCompetitionMatches(forMarketGroupId: marketGroupId)
            .eraseToAnyPublisher()
    }

    func trackLoading<T>(ofSubscribableContentPublisher publisher: AnyPublisher<SubscribableContent<T>, Error>) -> AnyPublisher<Bool, Never> {
        let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)

        publisher
            .handleEvents(receiveSubscription: { _ in
                isLoadingSubject.send(true)
            }, receiveCompletion: { _ in
                isLoadingSubject.send(false)
            })
            .sink(receiveCompletion: { _ in }, receiveValue: { subscribableContent in
                switch subscribableContent {
                case .connected:
                    ()
                case .contentUpdate:
                    isLoadingSubject.send(false)
                case .disconnected:
                     ()
                }
            })
            .store(in: &cancellables)

        return isLoadingSubject.eraseToAnyPublisher()
    }

}

extension TopCompetitionsDataSource {

    func clearFilters() {
        self.applyFilters(filtersOptions: nil)
    }

    func applyFilters(filtersOptions: HomeFilterOptions?) {
        self.filtersOptions = filtersOptions

        let filteredMCompetitions = self.filterCompetitions(with: self.filtersOptions, competitions: self.allCompetitions)
        self.filteredCompetitionsSubject.send(filteredMCompetitions)
    }

    private func filterCompetitions(with filtersOptions: HomeFilterOptions?, competitions: [Competition]) -> [Competition] {

        guard let filterOptionsValue = filtersOptions else {
            return competitions
        }

        var filteredCompetitions: [Competition] = []
        for competition in competitions where competition.matches.isNotEmpty {

            var filteredMatches: [Match] = []

            for match in competition.matches {

                if match.markets.isEmpty {
                    continue
                }

                // Check default market order
                var marketSort: [Market] = []
//                let favoriteMarketIndex = match.markets.firstIndex(where: { $0.typeId == filterOptionsValue.defaultMarket.marketId })
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

            if filteredMatches.isNotEmpty {
                var newCompetition = competition
                newCompetition.matches = filteredMatches
                filteredCompetitions.append(newCompetition)
            }

        }
        return filteredCompetitions
    }

}

//
//
extension TopCompetitionsDataSource: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        print("TopCompetitionsDataSource numberOfSections called")
        return self.filteredCompetitions.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let competition = self.filteredCompetitions[safe: section] {
            if competition.numberOutrightMarkets > 0 {
                print("TopCompetitionsDataSource numberOfRowsInSection \(section) -a- \(competition.matches.count + 1)")
                return competition.matches.count + 1
            }
            else {
                print("TopCompetitionsDataSource numberOfRowsInSection \(section) -b- \(competition.matches.count)")
                return competition.matches.count
            }
        }

        print("TopCompetitionsDataSource numberOfRowsInSection \(section) -d- 0")
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let competition = self.filteredCompetitions[safe: indexPath.section],
            competition.numberOutrightMarkets > 0 {
            if indexPath.row == 0,
                let cell = tableView.dequeueCellType(OutrightCompetitionLineTableViewCell.self) {
                cell.configure(withViewModel: OutrightCompetitionLineViewModel(competition: competition))
                cell.didSelectCompetitionAction = { [weak self] competition in
                    self?.didSelectCompetitionAction?(competition)
                }
                return cell
            }
            else if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
                    let match = competition.matches[safe: indexPath.row - 1] {

                if let matchStatsViewModel = self.matchStatsViewModelForMatch?(match) {
                    cell.matchStatsViewModel = matchStatsViewModel
                }

                let viewModel = MatchLineTableCellViewModel(match: match)
                cell.configure(withViewModel: viewModel)

                cell.shouldShowCountryFlag(true)
                cell.tappedMatchLineAction = { [weak self] match in
                    self?.didSelectMatchAction?(match)
                }
                return cell
            }
        }
        else if let competition = self.filteredCompetitions[safe: indexPath.section],
                let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
                let match = competition.matches[safe: indexPath.row] {

            if let matchStatsViewModel = self.matchStatsViewModelForMatch?(match) {
                cell.matchStatsViewModel = matchStatsViewModel
            }

            let viewModel = MatchLineTableCellViewModel(match: match)
            cell.configure(withViewModel: viewModel)

            cell.shouldShowCountryFlag(true)
            cell.tappedMatchLineAction = { [weak self] match in
                self?.didSelectMatchAction?(match)
            }
            return cell
        }

        return tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TournamentTableViewHeader.identifier)
                as? TournamentTableViewHeader,
            let competition = self.filteredCompetitions[safe: section]
        else {
            return nil
        }

        headerView.nameTitleLabel.text = competition.name
        headerView.countryFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: competition.venue?.isoCode ?? ""))
        headerView.sectionIndex = section
        headerView.competition = competition
        headerView.didToggleHeaderViewAction = { [weak self, weak tableView] section in
            guard
                let weakSelf = self,
                let weakTableView = tableView
            else { return }

            if weakSelf.collapsedCompetitionsSections.contains(section) {
                weakSelf.collapsedCompetitionsSections.remove(section)
            }
            else {
                weakSelf.collapsedCompetitionsSections.insert(section)
            }
            weakSelf.needReloadSection(section, tableView: weakTableView)
        }

        if self.collapsedCompetitionsSections.contains(section) {
            headerView.isCollapsed = true
        }
        else {
            headerView.isCollapsed = false
        }

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == self.filteredCompetitions.count {
            return CGFloat(0.01)
        }
        return 54
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == self.filteredCompetitions.count {
            return CGFloat(0.01)
        }
        return 54
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.collapsedCompetitionsSections.contains(indexPath.section) {
            return .leastNonzeroMagnitude
        }

        if let competition = self.filteredCompetitions[safe: indexPath.section] {
            if competition.numberOutrightMarkets > 0 && indexPath.row == 0 {
                return 105
            }
            else {
                return UITableView.automaticDimension
            }
        }
        return .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.collapsedCompetitionsSections.contains(indexPath.section) {
            return .leastNonzeroMagnitude
        }

        if let competition = self.filteredCompetitions[safe: indexPath.section] {
            if competition.numberOutrightMarkets > 0 && indexPath.row == 0 {
                return 105
            }
            else {
                return StyleHelper.cardsStyleHeight() + 20
            }
        }
        return .leastNonzeroMagnitude
    }

    func needReloadSection(_ section: Int, tableView: UITableView) {

        guard let competition = self.filteredCompetitions[safe: section] else { return }

        let rows = (0 ..< competition.matches.count).map({ IndexPath(row: $0, section: section) }) // all section rows

        tableView.beginUpdates()
        tableView.reloadRows(at: rows, with: .automatic)
        tableView.endUpdates()
    }

}
