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

        var urlType: String {
            switch self {
            case .accumulatedWinning: return "accumulated_wins"
            case .consecutiveWins: return "consecutive_wins"
            case .highestOdd: return "highest_odd"
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
    var rankingsPublisher: CurrentValueSubject<[RankingTip], Never> = .init([])
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

        let sortType = self.sortTypePublisher.value.urlType

        Env.gomaNetworkClient.requestRankingsTips(deviceId: Env.deviceId, type: sortType)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("RANKINGS TIPS ERROR: \(error)")
                case .finished:
                    ()
                }

                self?.isLoadingPublisher.send(false)

            }, receiveValue: { [weak self] response in
                print("RANKINGS TIPS RESPONSE: \(response)")

                if let rankingsTips = response.data {
                    self?.rankingsPublisher.value = rankingsTips
                }
            })
            .store(in: &cancellables)
    }

    private func loadTopTipstersRankings() {
        self.isLoadingPublisher.send(false)

    }

    private func loadFriendsRankings() {

        let sortType = self.sortTypePublisher.value.urlType

        Env.gomaNetworkClient.requestRankingsTips(deviceId: Env.deviceId, type: sortType, friends: true)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("RANKINGS TIPS ERROR: \(error)")
                case .finished:
                    ()
                }

                self?.isLoadingPublisher.send(false)

            }, receiveValue: { [weak self] response in
                print("RANKINGS TIPS RESPONSE: \(response)")

                if let rankingsTips = response.data {
                    self?.rankingsPublisher.value = rankingsTips
                }
            })
            .store(in: &cancellables)
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

    func reloadRankings() {
        self.loadInitialRankings()
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

        let rankingUserId = ranking.userId

        if let rankingsCellViewModel = rankingsCacheCellViewModel[rankingUserId] {
            return rankingsCellViewModel
        }
        else {
            let rankingsCellViewModel = RankingCellViewModel(ranking: ranking)
            self.rankingsCacheCellViewModel[rankingUserId] = rankingsCellViewModel
            return rankingsCellViewModel
        }
    }

}
