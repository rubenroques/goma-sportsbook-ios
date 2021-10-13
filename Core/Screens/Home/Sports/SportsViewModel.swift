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

    var matchListType: MatchListType = .myGames
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

    var isLoadingPopularList: CurrentValueSubject<Bool, Never> = .init(false)
    var isLoadingTodayList: CurrentValueSubject<Bool, Never> = .init(false)
    var isLoadingMyGamesList: CurrentValueSubject<Bool, Never> = .init(false)

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

    private var cancellables = Set<AnyCancellable>()

    init() {
        isLoading = Publishers.CombineLatest3(isLoadingTodayList, isLoadingPopularList, isLoadingMyGamesList)
            .map({ (isLoadingTodayList, isLoadingPopularList, isLoadingMyGamesList) in
                let isLoading = isLoadingTodayList || isLoadingPopularList || isLoadingMyGamesList
                print("Publishers isLoading? [\(isLoading)] (isLoadingToday:\(isLoadingTodayList), isLoadingPopular:\(isLoadingPopularList), isLoadingMyGames:\(isLoadingMyGamesList))")
                return isLoading
            })
            .eraseToAnyPublisher()
    }



    func fetchData() {
        self.isLoadingPopularList.send(true)
        self.isLoadingTodayList.send(true)
        self.isLoadingMyGamesList.send(true)

        self.fetchBanners()

        self.fetchPopularMatches()
        self.fetchTodayMatches()
        self.fetchCompetitionsMatches()

        self.isLoadingMyGamesList.send(false)
    }

    func setMatchListType(_ matchListType: MatchListType) {
        self.matchListType = matchListType
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

        switch matchListType {
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

    private func setupCompetitionsAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processAggregator(aggregator, withListType: .competitions,
                                                 shouldClear: didChangeSportType)

        let appMatches = Env.everyMatrixStorage.matchesForListType(.competitions)

        self.competitionsMatches = appMatches

        self.isLoadingTodayList.send(false)

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

    func fetchCompetitionsMatches() {
        let eventsList = ["140103443573428224"]
        let endpoint = TSRouter.competitionsMatchesPublisher(operatorId: Env.appSession.operatorId, language: "en", sportId: "\(self.selectedSportId)", events: eventsList)

        TSManager.shared
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")

                case .finished:
                    print("Data retrieved!")
                }
                self.isLoadingPopularList.send(false)
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

    var numberOfSections: Int {
        return 4
    }

    func itemsForSection(_ section: Int) -> Int {
        switch section {
        case 0:
            return banners.isEmpty ? 0 : 1
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
        switch (section, matchListType) {
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
        switch (section, matchListType) {
        case (2, .myGames):
            return 54
        case (2, .today):
            return 54
        default:
            return 0.001
        }
    }


    func selectedFilterMatches() -> [Match] {
        if case .myGames = matchListType {
            return self.popularMatches
        }
        else if case .today = matchListType {
            return self.todayMatches
        }
        else if case .competitions = matchListType {
            return self.competitionsMatches
        }
        return []
    }

    func matchViewModel(forIndex index: Int) -> MatchLineCellViewModel? {
        guard
            let matchAtIndex = self.selectedFilterMatches()[safe: index]
        else {
            return nil
        }

        let matchViewModel = MatchWidgetCellViewModel(match: matchAtIndex)
        let marketsIdsForMatch = Env.everyMatrixStorage.marketsForMatch[matchAtIndex.id] ?? []
        return MatchLineCellViewModel(matchWidgetCellViewModel: matchViewModel, marketsIds: marketsIdsForMatch)
    }



    func createBannersViewModel() -> BannerLineCellViewModel {
        var cells = [BannerCellViewModel]()
        for banner in self.banners {
            cells.append(BannerCellViewModel(matchId: banner.matchID, imageURL: banner.imageURL ?? ""))
        }
        return BannerLineCellViewModel(banners: cells)
    }
}


