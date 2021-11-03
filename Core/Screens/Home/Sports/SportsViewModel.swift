//
//  SportsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 10/10/2021.
//

import Foundation
import UIKit
import Combine

class SportsViewModel {

    private var banners: [EveryMatrix.BannerInfo] = []
    private var bannersViewModel: BannerLineCellViewModel?
    private var userMessages: [String] = []

    private var userFavoriteEvents: EveryMatrix.Matches = []
    private var todayEvents: EveryMatrix.Matches = []
    private var popularEvents: EveryMatrix.Matches = []


    private var userFavoriteMatches: [Match] = []
    private var todayMatches: [Match] = []
    private var popularMatches: [Match] = []
    private var competitionsMatches: [Match] = []

    var competitionGroupsPublisher: CurrentValueSubject<[CompetitionGroup], Never> = .init([])

    var matchListTypePublisher: CurrentValueSubject<MatchListType, Never> = .init(.myGames)
    enum MatchListType {
        case myGames
        case today
        case competitions
    }

    enum CellType {
        case banner(banners: [EveryMatrix.BannerInfo])
        case userMessage(text: String)
        case match(match: Match)
    }

    private var isLoadingPopularList: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingTodayList: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingMyGamesList: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingCompetitions: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingCompetitionGroups: CurrentValueSubject<Bool, Never> = .init(true)

    var isLoading: AnyPublisher<Bool, Never>

    var contentList: CurrentValueSubject<[CellType], Never> = .init([])

    var didChangeSportType = false
    var selectedSportId: Int = 1 {
        willSet {
            if newValue != self.selectedSportId {
                didChangeSportType = true
            }
        }
        didSet {
            self.fetchData()
        }
    }
    var homeFilterOptions: HomeFilterOptions = HomeFilterOptions(timeRange: [0, 24], defaultMarketId: Int((Env.everyMatrixStorage.mainMarkets.values.first?.bettingTypeId ?? "69")) ?? 69, oddsRange: [1.0, 30.0]) {
        didSet {
//            self.fetchData()
        }
    }

    private var cancellables = Set<AnyCancellable>()

    init() {
        isLoading = Publishers.CombineLatest4(isLoadingTodayList, isLoadingPopularList, isLoadingMyGamesList, isLoadingCompetitions)
            .map({ (isLoadingTodayList, isLoadingPopularList, isLoadingMyGamesList, isLoadingCompetitions) in
                let isLoading = isLoadingTodayList || isLoadingPopularList || isLoadingMyGamesList || isLoadingCompetitions
                return isLoading
            })
            .eraseToAnyPublisher()
    }



    func fetchData() {
        self.isLoadingPopularList.send(true)
        self.isLoadingTodayList.send(true)
        self.isLoadingMyGamesList.send(true)
        self.isLoadingCompetitions.send(true)
        self.isLoadingCompetitionGroups.send(true)

        self.competitionsMatches = []
        self.competitionGroupsPublisher.send([])

        self.fetchBanners()

        self.fetchPopularMatches()
        self.fetchTodayMatches()
        self.fetchCompetitionsFilters()

        self.isLoadingCompetitions.send(false)
        self.isLoadingMyGamesList.send(false)
    }

    func setMatchListType(_ matchListType: MatchListType) {
        self.matchListTypePublisher.send(matchListType)
        self.updateContentList()
    }

    private func updateContentList() {

        let contentList = self.generateContentList()

        self.isLoadingMyGamesList.send(false)

        self.contentList.send(contentList)
    }

    private func generateContentList() -> [CellType] {
        var contentList: [CellType] = []

        if self.banners.isNotEmpty {
            contentList.append(CellType.banner(banners: self.banners))
        }

        switch matchListTypePublisher.value {
        case .myGames:
            contentList.append(contentsOf: self.popularMatches.map({ return CellType.match(match: $0) }) )
        case .today:
            contentList.append(contentsOf: self.todayMatches.map({ return CellType.match(match: $0) }) )
        case .competitions:
            contentList.append(contentsOf: self.competitionsMatches.map({ return CellType.match(match: $0) }) )
        }
        return contentList
    }

    private func setupPopularAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processAggregator(aggregator, withListType: .popularEvents,
                                                 shouldClear: didChangeSportType)
        let matches = Env.everyMatrixStorage.rawMatchesForListType(.popularEvents)


        let appMatches = Env.everyMatrixStorage.matchesForListType(.popularEvents)

        self.popularEvents = matches
        self.popularMatches = appMatches

        self.isLoadingPopularList.send(false)
        self.updateContentList()
    }

    private func setupTodayAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processAggregator(aggregator, withListType: .todayEvents,
                                                 shouldClear: didChangeSportType)

        let matches = Env.everyMatrixStorage.rawMatchesForListType(.todayEvents)

        let appMatches = Env.everyMatrixStorage.matchesForListType(.todayEvents)

        self.todayEvents = matches
        self.todayMatches = appMatches

        self.isLoadingTodayList.send(false)

        self.updateContentList()
    }

    private func setupCompetitionGroups() {
        var addedCompetitionIds: [String] = []

        var popularCompetitions = [Competition]()
        for popularCompetition in Env.everyMatrixStorage.popularTournaments.values
        where (popularCompetition.sportId ?? "") == String(self.selectedSportId) {

            let competition = Competition(id: popularCompetition.id, name: popularCompetition.name ?? "")
            addedCompetitionIds.append(popularCompetition.id)
            popularCompetitions.append(competition)
        }

        let popularCompetitionGroup = CompetitionGroup(id: "0",
                                                        name: "Popular Competitions",
                                                        aggregationType: CompetitionGroup.AggregationType.popular,
                                                        competitions: popularCompetitions)
        var popularCompetitionGroups = [popularCompetitionGroup]


        var competitionsGroups = [CompetitionGroup]()
        for location in Env.everyMatrixStorage.locations.values {

            var locationCompetitions = [Competition]()

            for rawCompetitionId in (Env.everyMatrixStorage.tournamentsForLocation[location.id] ?? [])  {

                guard
                    let rawCompetition = Env.everyMatrixStorage.tournaments[rawCompetitionId],
                    (rawCompetition.sportId ?? "") == String(self.selectedSportId)
                else {
                    continue
                }

                let competition = Competition(id: rawCompetition.id, name: rawCompetition.name ?? "")
                addedCompetitionIds.append(rawCompetition.id)
                locationCompetitions.append(competition)
            }

            let locationCompetitionGroup = CompetitionGroup(id: location.id,
                                                            name: location.name ?? "",
                                                            aggregationType: CompetitionGroup.AggregationType.region,
                                                            competitions: locationCompetitions)

            if locationCompetitions.isNotEmpty {
                competitionsGroups.append(locationCompetitionGroup)
            }
        }
        
        popularCompetitionGroups.append(contentsOf: competitionsGroups)

        self.competitionGroupsPublisher.send(popularCompetitionGroups)
        self.isLoadingCompetitionGroups.send(false)

        self.updateContentList()
    }

    private func setupCompetitionsAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processAggregator(aggregator, withListType: .competitions,
                                                 shouldClear: true)

        let appMatches = Env.everyMatrixStorage.matchesForListType(.competitions)

        self.competitionsMatches = appMatches

        self.isLoadingCompetitions.send(false)

        self.updateContentList()
    }

    private func fetchPopularMatches() {
        let endpoint = TSRouter.popularMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                        language: "en",
                                                        sportId: "\(self.selectedSportId)")

        TSManager.shared
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
                self.isLoadingTodayList.send(false)
            }, receiveValue: { state in
                debugPrint("SportsViewModel register update")

                switch state {
                case .connect:
                    print("connect")
                case .initialContent(let aggregator):
                    self.setupPopularAggregatorProcessor(aggregator: aggregator)
                case .updatedContent(let aggregator):
                    print("updatedContent \(aggregator)")
                case .disconnect:
                    print("disconnect")
                }

            })
            .store(in: &cancellables)
    }

    private func fetchTodayMatches() {
        let endpoint = TSRouter.todayMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                      language: "en",
                                                      sportId: "\(self.selectedSportId)")

        TSManager.shared
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")

                case .finished:
                    print("Data retrieved!")
                }
                self.isLoadingTodayList.send(false)
            }, receiveValue: { state in
                debugPrint("SportsViewModel todayMatchesPublisher")

                switch state {
                case .connect:
                    ()
                case .initialContent(let aggregator):
                    self.setupTodayAggregatorProcessor(aggregator: aggregator)
                case .updatedContent(let aggregator):
                    print("updatedContent \(aggregator)")
                case .disconnect:
                    print("disconnect")
                }

            })
            .store(in: &cancellables)
    }

    func fetchCompetitionsFilters() {

        let language = "en"
        let sportId = "\(self.selectedSportId)"

        let popularTournamentsPublisher = TSManager.shared
            .getModel(router: TSRouter.getCustomTournaments(language: language, sportId: sportId),
                      decodingType: EveryMatrixSocketResponse<EveryMatrix.Tournament>.self)

        let tournamentsPublisher = TSManager.shared
            .getModel(router: TSRouter.getTournaments(language: language, sportId: sportId),
                      decodingType: EveryMatrixSocketResponse<EveryMatrix.Tournament>.self)

        let locationsPublisher = TSManager.shared
            .getModel(router: TSRouter.getLocations(language: language, sortByPopularity: false),
                      decodingType: EveryMatrixSocketResponse<EveryMatrix.Location>.self)


        Publishers.Zip3(popularTournamentsPublisher, tournamentsPublisher, locationsPublisher)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
                self.isLoadingCompetitionGroups.send(false)
            }, receiveValue: { popularTournaments, tournaments, locations in
                Env.everyMatrixStorage.storePopularTournaments(tournaments: popularTournaments.records ?? [])
                Env.everyMatrixStorage.storeTournaments(tournaments: tournaments.records ?? [])
                Env.everyMatrixStorage.storeLocations(locations: locations.records ?? [])

                self.setupCompetitionGroups()
            })
            .store(in: &cancellables)

        //
        //


    }
    func fetchCompetitionsMatchesWithIds(_ ids: [String]) {

        self.isLoadingCompetitions.send(true)

        let endpoint = TSRouter.competitionsMatchesPublisher(operatorId: Env.appSession.operatorId, language: "en", sportId: "\(self.selectedSportId)", events: ids)

        TSManager.shared
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")

                case .finished:
                    print("Data retrieved!")
                }
                self.isLoadingCompetitions.send(false)
            }, receiveValue: { state in
                debugPrint("SportsViewModel competitionsMatchesPublisher")

                switch state {
                case .connect:
                    ()
                case .initialContent(let aggregator):
                    self.setupCompetitionsAggregatorProcessor(aggregator: aggregator)
                case .updatedContent(let aggregator):
                    print("updatedContent \(aggregator)")
                case .disconnect:
                    print("disconnect")
                }
            })
            .store(in: &cancellables)
    }

    func fetchBanners() {
        let endpoint = TSRouter.bannersInfoPublisher(operatorId: Env.appSession.operatorId, language: "en")
        TSManager.shared
            .registerOnEndpoint(endpoint, decodingType: EveryMatrixSocketResponse<EveryMatrix.BannerInfo>.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")

                case .finished:
                    print("Data retrieved!")
                }

            }, receiveValue: { state in
                debugPrint("SportsViewModel bannersInfoPublisher")

                switch state {
                case .connect:
                    ()
                case .initialContent(let responde):
                    print("initialContent \(responde)")
                    self.banners = responde.records ?? []
                    self.bannersViewModel = self.createBannersViewModel()
                case .updatedContent(let banner):
                    print("updatedContent \(banner)")
                case .disconnect:
                    print("disconnect")
                }

                self.updateContentList()
            })
            .store(in: &cancellables)


    }

}


extension SportsViewModel {

    var numberOfSections: Int {
        return 4
    }

    func itemsForSection(_ section: Int) -> Int {
        switch section {
        case 0:
            if case .myGames = matchListTypePublisher.value {
                return banners.isEmpty ? 0 : 1
            }
            return 0
        case 1:
            return 0
        case 2:
            return self.selectedFilterMatches().count
        default:
            return 0
        }
    }

    func cellForRowAt(indexPath: IndexPath, onTableView tableView: UITableView) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueCellType(BannerScrollTableViewCell.self) {
                if let viewModel = self.bannersViewModel {
                    cell.setupWithViewModel(viewModel)
                }
                cell.backgroundView?.backgroundColor = .clear
                cell.backgroundColor = .clear
                cell.contentView.backgroundColor = .clear
                return cell
            }
        case 1:
            if let cell = tableView.dequeueCellType(UITableViewCell.self) {
                return cell
            }
        case 2:
            if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
               let match = self.selectedFilterMatches()[safe: indexPath.row] {
                cell.setupWithMatch(match)
                return cell
            }
        default:
            fatalError()
        }
        return UITableViewCell()
    }

    func viewForHeaderInSection(_  section: Int, tableView: UITableView) -> UIView? {
        switch (section, matchListTypePublisher.value) {
        case (2, .myGames):
            if  let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier)
                    as? TitleTableViewHeader {
                headerView.sectionTitleLabel.text = "Popular Games"
                return headerView
            }
        case (2, .today):
            if  let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier)
                    as? TitleTableViewHeader {
                headerView.sectionTitleLabel.text = "Today’s Highlights"
                return headerView
            }
        default:
            return nil
        }
        return nil
    }

    func heightForHeaderInSection(section: Int, tableView: UITableView) -> CGFloat {
        switch (section, matchListTypePublisher.value) {
        case (2, .myGames):
            return 54
        case (2, .today):
            return 54
        default:
            return 0.001
        }
    }


    func selectedFilterMatches() -> [Match] {
        if case .myGames = matchListTypePublisher.value {
            return self.popularMatches
        }
        else if case .today = matchListTypePublisher.value {
            return self.todayMatches
        }
        else if case .competitions = matchListTypePublisher.value {
            return self.competitionsMatches
        }
        return []
    }


    func createBannersViewModel() -> BannerLineCellViewModel {
        var cells = [BannerCellViewModel]()
        for banner in self.banners {
            cells.append(BannerCellViewModel(matchId: banner.matchID, imageURL: banner.imageURL ?? ""))
        }
        return BannerLineCellViewModel(banners: cells)
    }
}


