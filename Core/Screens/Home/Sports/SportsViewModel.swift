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

    private var banners: [String] = []
    private var userMessages: [String] = []

    private var userFavoriteEvents: EveryMatrix.Matches = []
    private var todayEvents: EveryMatrix.Matches = []
    private var popularEvents: EveryMatrix.Matches = []

    var matchListType: MatchListType = .myGames
    enum MatchListType {
        case myGames
        case today
    }

    enum CellType {
        case banner(text: String)
        case userMessage(text: String)
        case match(match: EveryMatrix.Match)
    }

//    private var matches: CurrentValueSubject<EveryMatrix.Matches, Never> = .init([])

    var isLoadingPopularList: CurrentValueSubject<Bool, Never> = .init(false)
    var isLoadingTodayList: CurrentValueSubject<Bool, Never> = .init(false)
    var isLoadingMyGamesList: CurrentValueSubject<Bool, Never> = .init(false)

    var isLoading: AnyPublisher<Bool, Never>

    var contentList: CurrentValueSubject<[CellType], Never> = .init([])

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

        self.fetchPopularMatches()
        self.fetchTodayMatches()

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
        switch matchListType {
        case .myGames:
            contentList.append(contentsOf: self.popularEvents.map({ return CellType.match(match: $0) }) )
        case .today:
            contentList.append(contentsOf: self.todayEvents.map({ return CellType.match(match: $0) }) )
        }
        return contentList
    }

    private func setupPopularAggregatorProcessor(aggregator: Aggregator) {
        Env.everyMatrixStorage.processAggregator(aggregator, withListType: AggregatorListType.popularEvents)
        let matches = Env.everyMatrixStorage.matchesForListType(AggregatorListType.popularEvents)

        self.popularEvents = matches
        self.isLoadingPopularList.send(false)
        self.updateContentList()
    }

    private func setupTodayAggregatorProcessor(aggregator: Aggregator) {
        Env.everyMatrixStorage.processAggregator(aggregator, withListType: AggregatorListType.todayEvents)

        let matches = Env.everyMatrixStorage.matchesForListType(AggregatorListType.todayEvents)

        self.todayEvents = matches
        self.isLoadingTodayList.send(false)

        self.updateContentList()
    }

    private func fetchPopularMatches() {
        let endpoint = TSRouter.popularMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                        language: "en",
                                                        sportId: "1")

        TSManager.shared
            .registerOnEndpoint(endpoint, decodingType: Aggregator.self)
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
                                                      timezoneOffset: Env.timezoneOffsetInMinutes,
                                                      language: "en",
                                                      sportId: "1")

        TSManager.shared
            .registerOnEndpoint(endpoint, decodingType: Aggregator.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")

                case .finished:
                    print("Data retrieved!")
                }
                self.isLoadingPopularList.send(false)
            }, receiveValue: { state in
                debugPrint("SportsViewModel register update")

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

    var numberOfSections: Int {
        return 4
    }

    func itemsForSection(_ section: Int) -> Int {
        switch section {
        case 0:
            return banners.count
        case 1:
            return userMessages.count
        case 2:
            return self.contentList.value.count
        default:
            return 0
        }
    }

    func cellForRowAt(indexPath: IndexPath, onTableView tableView: UITableView) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueCellType(UITableViewCell.self) {
                return cell
            }
        case 1:
            if let cell = tableView.dequeueCellType(UITableViewCell.self) {
                return cell
            }
        case 2:
            if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self) {
                return cell
            }
        default:
            fatalError()
        }
        return UITableViewCell()
    }
}


