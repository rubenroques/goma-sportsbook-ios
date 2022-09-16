//
//  RankingsListViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 15/09/2022.
//

import Foundation
import Combine

class RankingsListViewModel {

    enum RankingsType: Int {
        case all = 0
        case topTipsters = 1
        case friends = 2
        case followers = 3
    }

    enum SortType: CaseIterable {
        case accumulatedWinning
        case consecutiveWins
        case highestOdd

        var title: String {
            switch self {
            case .accumulatedWinning: return "Accumulated Winning"
            case .consecutiveWins: return "Consecutive Wins"
            case .highestOdd: return "Highest Odd"
            }
        }
    }

    enum ScreenState {
        case loading
        case loaded
        case empty
        case failed
    }

    var rankingsType: RankingsType = .all
    var rankingsPublisher: CurrentValueSubject<[Ranking], Never> = .init([])
    var rankingsCacheCellViewModel: [Int: RankingCellViewModel] = [:]

    var sortTypePublisher: CurrentValueSubject<SortType, Never> = .init(.accumulatedWinning)

    var statePublisher: CurrentValueSubject<ScreenState, Never> = .init(.empty)

    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var hasFriendsPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    private var cancellables = Set<AnyCancellable>()

    init(rankingsType: RankingsType) {
        self.rankingsType = rankingsType

        self.loadInitialRankings()
    }

    func loadInitialRankings() {

        self.isLoadingPublisher.send(true)

        self.rankingsPublisher.value = []
        self.rankingsCacheCellViewModel = [:]

        switch self.rankingsType {
        case .all:
            self.loadAllRankings()
        case .topTipsters:
            self.loadTopTipstersRankings()
        case .friends:
            self.getFriends()
        case .followers:
            self.loadFollowersRankings()
        }
    }

    private func loadAllRankings() {

        var rankings: [Ranking] = []

        for i in 1...50 {
            let ranking = Ranking(id: i, ranking: i, username: "Username_\(i)", score: Double(100-i))

            rankings.append(ranking)

        }

        self.rankingsPublisher.value = rankings

        self.isLoadingPublisher.send(false)
    }

    private func loadTopTipstersRankings() {
        self.isLoadingPublisher.send(false)

    }

    private func loadFriendsRankings() {
        var rankings: [Ranking] = []

        for i in 1...50 {
            let ranking = Ranking(id: i, ranking: i, username: "Friend_Username_\(i)", score: Double(100-i))

            rankings.append(ranking)

        }

        self.rankingsPublisher.value = rankings

        self.isLoadingPublisher.send(false)

    }

    private func loadFollowersRankings() {
        self.isLoadingPublisher.send(false)

    }

    private func getFriends() {

        Env.gomaNetworkClient.requestFriends(deviceId: Env.deviceId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("FRIENDS ERROR: \(error)")
                    self?.isLoadingPublisher.send(false)
                case .finished:
                    print("FRIENDS FINISHED")
                }

            }, receiveValue: { [weak self] response in
                if let friends = response.data {
                    if friends.isEmpty {
                        self?.isLoadingPublisher.send(false)
                        self?.hasFriendsPublisher.send(false)
                    }
                    else {
                        self?.hasFriendsPublisher.send(true)
                        self?.loadFriendsRankings()
                    }
                }
            })
            .store(in: &cancellables)

    }

    func selectSortTypeForIndex(_ index: Int) {
        self.sortTypePublisher.send(SortType.allCases[index])
    }

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows() -> Int {
        return self.rankingsPublisher.value.count
    }

    func viewModel(forIndex index: Int) -> RankingCellViewModel? {
        guard
            let ranking = self.rankingsPublisher.value[safe: index]
        else {
            return nil
        }

        let rankingId = ranking.id

        if let rankingsCellViewModel = rankingsCacheCellViewModel[rankingId] {
            return rankingsCellViewModel
        }
        else {
            let rankingsCellViewModel = RankingCellViewModel(ranking: ranking)
            self.rankingsCacheCellViewModel[rankingId] = rankingsCellViewModel
            return rankingsCellViewModel
        }
    }

}
