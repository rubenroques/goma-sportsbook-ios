//
//  UserProfileTipsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 28/09/2022.
//

import Foundation
import Combine

class UserProfileTipsViewModel {

    var userTipsPublisher: CurrentValueSubject<[FeaturedTip], Never> = .init([])
    var userTipsCacheCellViewModel: [String: TipsCellViewModel] = [:]
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var page: Int = 1
    var tipsHasNextPage: Bool = false

    private var userId: String
    private var cancellables = Set<AnyCancellable>()

    init(userId: String) {

        self.userId = userId

        self.loadUserTips()
    }

    private func loadUserTips() {

        self.isLoadingPublisher.send(true)

        Env.gomaNetworkClient.requestFeaturedTips(deviceId: Env.deviceId, userIds: [userId], page: self.page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("USER TIPS ERROR: \(error)")
                case .finished:
                    ()
                }

                self?.isLoadingPublisher.send(false)

            }, receiveValue: { [weak self] response in
                print("USER TIPS RESPONSE: \(response)")

                if let tips = response.data {
                    self?.userTipsPublisher.value = tips

                    if tips.count < 10 {
                        self?.tipsHasNextPage = false
                    }
                    else {
                        self?.tipsHasNextPage = true
                    }
                }
            })
            .store(in: &cancellables)
    }

    private func loadNextUserTips() {

        Env.gomaNetworkClient.requestFeaturedTips(deviceId: Env.deviceId, userIds: [userId], page: self.page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("USER TIPS ERROR: \(error)")
                case .finished:
                    ()
                }

                self?.isLoadingPublisher.send(false)

            }, receiveValue: { [weak self] response in
                print("USER TIPS RESPONSE: \(response)")

                if let tips = response.data {
                    self?.userTipsPublisher.value.append(contentsOf: tips)

                    if tips.count < 10 {
                        self?.tipsHasNextPage = false
                    }
                    else {
                        self?.tipsHasNextPage = true
                    }
                }
            })
            .store(in: &cancellables)

    }

    func requestNextPageTips() {
        if !self.tipsHasNextPage {
            return
        }
        self.page += 1
        self.loadNextUserTips()
    }

    func numberOfSections() -> Int {
        return 2
    }

    func numberOfRows() -> Int {
        return self.userTipsPublisher.value.count
    }

    func viewModel(forIndex index: Int) -> TipsCellViewModel? {
        guard
            let featuredTip = self.userTipsPublisher.value[safe: index]
        else {
            return nil
        }

        let tipId = featuredTip.betId

        if let tipsCellViewModel = userTipsCacheCellViewModel[tipId] {
            return tipsCellViewModel
        }
        else {
            let tipsCellViewModel = TipsCellViewModel(featuredTip: featuredTip)
            self.userTipsCacheCellViewModel[tipId] = tipsCellViewModel
            return tipsCellViewModel
        }
    }
}
