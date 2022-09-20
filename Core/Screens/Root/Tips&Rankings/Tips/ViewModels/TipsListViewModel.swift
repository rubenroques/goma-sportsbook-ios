//
//  TipsListViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 09/09/2022.
//

import Foundation
import Combine

class TipsListViewModel {

    enum TipsType: Int {
        case all = 0
        case topTips = 1
        case friends = 2
        case followers = 3
    }

    var tipsPublisher: CurrentValueSubject<[FeaturedTip], Never> = .init([])
    var tipsType: TipsType = .all
    var tipsCacheCellViewModel: [String: TipsCellViewModel] = [:]
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var hasFriendsPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    private var cancellables = Set<AnyCancellable>()

    init(tipsType: TipsType) {
        self.tipsType = tipsType

        self.loadInitialTips()

    }

    func loadInitialTips() {

        self.isLoadingPublisher.send(true)

        self.tipsPublisher.value = []
        self.tipsCacheCellViewModel = [:]

        switch self.tipsType {
        case .all:
            self.loadAllTips()
        case .topTips:
            self.loadTopTips()
        case .friends:
            self.getFriends()
        case .followers:
            self.loadFollowersTips()
        }
    }

    private func loadAllTips() {
        // self.isLoadingPublisher.send(true)

        Env.gomaNetworkClient.requestFeaturedTips(deviceId: Env.deviceId, betType: "MULTIPLE")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("TIPS ERROR: \(error)")
                case .finished:
                    ()
                }

                self?.isLoadingPublisher.send(false)

            }, receiveValue: { [weak self] response in
                print("TIPS RESPONSE: \(response)")

                if let tips = response.data {
                    self?.tipsPublisher.value = tips
                }
            })
            .store(in: &cancellables)

    }

    private func loadTopTips() {

        Env.gomaNetworkClient.requestFeaturedTips(deviceId: Env.deviceId, betType: "MULTIPLE", topTips: true)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("TIPS TOP TIPS ERROR: \(error)")
                case .finished:
                    ()
                }

                self?.isLoadingPublisher.send(false)

            }, receiveValue: { [weak self] response in

                if let tips = response.data {
                    self?.tipsPublisher.value = tips
                }
            })
            .store(in: &cancellables)
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
                        self?.hasFriendsPublisher.send(false)
                    }
                    else {
                        self?.hasFriendsPublisher.send(true)
                        self?.loadFriendsTips()
                    }
                }
            })
            .store(in: &cancellables)

    }

    private func loadFriendsTips() {
        self.hasFriendsPublisher.send(true)

        // self.isLoadingPublisher.send(true)

        Env.gomaNetworkClient.requestFeaturedTips(deviceId: Env.deviceId, betType: "MULTIPLE", friends: true)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("TIPS FRIENDS ERROR: \(error)")
                case .finished:
                    ()
                }

                self?.isLoadingPublisher.send(false)

            }, receiveValue: { [weak self] response in

                if let tips = response.data {
                    self?.tipsPublisher.value = tips
                }
            })
            .store(in: &cancellables)
    }

    private func loadFollowersTips() {

        Env.gomaNetworkClient.requestFeaturedTips(deviceId: Env.deviceId, betType: "MULTIPLE", followers: true)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("TIPS ERROR: \(error)")
                case .finished:
                    ()
                }

                self?.isLoadingPublisher.send(false)

            }, receiveValue: { [weak self] response in

                if let tips = response.data {
                    self?.tipsPublisher.value = tips
                }
            })
            .store(in: &cancellables)

        Env.gomaSocialClient.followingUsersPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.loadInitialTips()
            })
            .store(in: &cancellables)

    }

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows() -> Int {
        return self.tipsPublisher.value.count
    }

    func viewModel(forIndex index: Int) -> TipsCellViewModel? {
        guard
            let featuredTip = self.tipsPublisher.value[safe: index]
        else {
            return nil
        }

        let tipId = featuredTip.betId

        if let tipsCellViewModel = tipsCacheCellViewModel[tipId] {
            return tipsCellViewModel
        }
        else {
            let tipsCellViewModel = TipsCellViewModel(featuredTip: featuredTip)
            self.tipsCacheCellViewModel[tipId] = tipsCellViewModel
            return tipsCellViewModel
        }
    }
}
