//
//  CompetitionsDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 18/01/2022.
//

import UIKit
import Combine
import ServicesProvider

class CompetitionsDataSource: NSObject {

    var allCompetitions: [Competition] {
        return self.allCompetitionsSubject.value
    }
    var filteredCompetitions: [Competition] {
        return self.filteredCompetitionsSubject.value
    }

    var allCompetitionsSubject: CurrentValueSubject<[Competition], Never> = .init([])
    var filteredCompetitionsSubject: CurrentValueSubject<[Competition], Never> = .init([])

    var isLoadingInitialDataPublisher: AnyPublisher<Bool, Never> {
        return self.isLoadingCurrentValueSubject.eraseToAnyPublisher()
    }

    var dataChangedPublisher: AnyPublisher<Void, Never> {
        let changedArrayPublisher = self.filteredCompetitionsSubject
            .removeDuplicates()
            .map { _ in }
            .eraseToAnyPublisher()

        return Publishers.Merge(changedArrayPublisher, self.forcedRefreshPassthroughSubject)
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

    private var competitionIdsSubject: CurrentValueSubject<[String], Never> = .init([])

    private var competitionsIdentifiersSubject: CurrentValueSubject<[String: [String]], Never> = .init([:])
    private var collapsedCompetitionsSections: Set<Int> = []

    private var forcedRefreshPassthroughSubject: PassthroughSubject<Void, Never> = .init()
    private var competitionsMatchesSubscriptions: [String: ServicesProvider.Subscription] = [:]

    private var isLoadingCurrentValueSubject: CurrentValueSubject<Bool, Never> = .init(false)
    private var activeNetworkRequestCount = 0 {
        didSet {
            print("CompetitionsDataSource activeNetworkRequestCount: \(self.activeNetworkRequestCount)")
            self.isLoadingCurrentValueSubject.send(activeNetworkRequestCount > 0)
        }
    }

    private var cancellables = Set<AnyCancellable>()

    override init() {

        super.init()

        self.allCompetitionsSubject
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.collapsedCompetitionsSections = []
                self.applyFilters(filtersOptions: self.filtersOptions)
            }
            .store(in: &self.cancellables)
    }

    func fetchData(withCompetitionsIds competitionIds: [String], forceRefresh: Bool = false) {
        if !forceRefresh && self.competitionIdsSubject.value == competitionIds {
            return
        }
        self.requestData(withCompetitionsIds: competitionIds)
    }

    private func requestData(withCompetitionsIds competitionIds: [String]) {

        print("CompetitionsDataSource requestData")
        self.competitionIdsSubject.send(competitionIds)

        if competitionIds.isEmpty {
            self.competitionsMatchesSubscriptions = [:]
            self.allCompetitionsSubject.send([])
            return
        }

        self.fetchCompetitionsMatchesWithIds(competitionIds)
    }

    private func fetchCompetitionsMatchesWithIds(_ competitionIds: [String]) {

        self.activeNetworkRequestCount += 1

        let competitionsMatchesPublishers = self.requestForCompetitionsMatchesWithIds(competitionIds)
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
                self.processCompetitionsInfo(competitionInfoDictionsary)
            }
            .store(in: &self.cancellables)

    }

    private func requestForCompetitionsMatchesWithIds(_ competitionIds: [String]) -> [AnyPublisher<SportCompetitionInfo?, Never>] {

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

    private func processCompetitionsInfo(_ selectedCompetitionsInfo: [String: SportCompetitionInfo]) {

        let competitionInfos = selectedCompetitionsInfo.map({ $0.value }).filter({
            $0.marketGroups.isNotEmpty
        })

        self.competitionsMatchesSubscriptions = [:]
        self.allCompetitionsSubject.send([])

        for competitionInfo in competitionInfos {
            if let marketGroup = competitionInfo.marketGroups.filter({ $0.name.lowercased().contains("main") }).first {
                self.subscribeCompetitionMatches(forMarketGroupId: marketGroup.id, competitionInfo: competitionInfo)
            }
            else if let marketGroup = competitionInfo.marketGroups.filter({ $0.name.lowercased().contains("outright") }).first {
                self.subscribeCompetitionOutright(forMarketGroupId: marketGroup.id, competitionInfo: competitionInfo)
            }
        }

    }

    private func subscribeCompetitionMatches(forMarketGroupId marketGroupId: String, competitionInfo: SportCompetitionInfo) {

        let competitionId = competitionInfo.id

        self.activeNetworkRequestCount += 1

        Env.servicesProvider.subscribeCompetitionMatches(forMarketGroupId: marketGroupId)
        .sink { [weak self] completion  in
            switch completion {
            case .finished:
                print("CompetitionsDataSource subscribeCompetitionMatches - completed")
            case .failure(let error):
                print("CompetitionsDataSource subscribeCompetitionMatches - completed with error \(error)")
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

    private func subscribeCompetitionOutright(forMarketGroupId marketGroupId: String, competitionInfo: SportCompetitionInfo) {

        self.activeNetworkRequestCount += 1

        let competitionId = competitionInfo.id

        Env.servicesProvider.subscribeCompetitionMatches(forMarketGroupId: marketGroupId)
        .sink { [weak self] completion in
            switch completion {
            case .finished:
                print("CompetitionsDataSource subscribeCompetitionOutright - completed")
            case .failure(let error):
                print("CompetitionsDataSource subscribeCompetitionOutright - completed with error \(error)")
            }
            self?.activeNetworkRequestCount -= 1
        } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
            switch subscribableContent {
            case .connected(let subscription):
                self?.competitionsMatchesSubscriptions[competitionId] = subscription
            case .contentUpdate(let eventsGroups):
                if let outrightMatch = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups).first {
                    self?.processCompetitionOutrights(outrightMatch: outrightMatch, competitionInfo: competitionInfo)
                }
                self?.activeNetworkRequestCount -= 1
            case .disconnected:
                self?.competitionsMatchesSubscriptions[competitionId] = nil
            }
        }
        .store(in: &cancellables)
    }

    private func processCompetitionOutrights(outrightMatch: Match, competitionInfo: SportCompetitionInfo) {

        guard
            !self.allCompetitions.contains(where: { $0.id == competitionInfo.id })
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

extension CompetitionsDataSource {

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

extension CompetitionsDataSource: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.filteredCompetitions.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let competition = self.filteredCompetitions[safe: section] {
            if competition.numberOutrightMarkets > 0 {
                return competition.matches.count + 1
            }
            else {
                return competition.matches.count
            }
        }
        else if section == self.filteredCompetitions.count {
            return 1
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard
            let competition = self.filteredCompetitions[safe: indexPath.section]
        else {
            return UITableViewCell()
        }

        if competition.numberOutrightMarkets > 0 {
            if indexPath.row == 0 {
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: OutrightCompetitionLineTableViewCell.identifier)
                        as? OutrightCompetitionLineTableViewCell
                else {
                    fatalError()
                }
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
                cell.viewModel = viewModel

                cell.shouldShowCountryFlag(true)
                cell.tappedMatchLineAction = { [weak self] match in
                    self?.didSelectMatchAction?(match)
                }

                return cell
            }
        }
        else if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
                let match = competition.matches[safe: indexPath.row] {

            if let matchStatsViewModel = self.matchStatsViewModelForMatch?(match) {
                cell.matchStatsViewModel = matchStatsViewModel
            }
            
            
            let viewModel = MatchLineTableCellViewModel(match: match)
            cell.viewModel = viewModel

            cell.shouldShowCountryFlag(true)
            cell.tappedMatchLineAction = { [weak self] match in
                self?.didSelectMatchAction?(match)
            }
//            cell.didTapFavoriteMatchAction = { [weak self] match in
//                self?.didTapFavoriteMatchAction?(match)
//            }
            return cell
        }

        return UITableViewCell()
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
