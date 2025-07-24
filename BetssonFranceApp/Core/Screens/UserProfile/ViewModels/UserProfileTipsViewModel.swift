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

        Env.servicesProvider.getFeaturedTips(page: self.page, limit: nil, topTips: nil, followersTips: nil, friendsTips: nil, userId: self.userId, homeTips: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("ALL TIPS ERROR: \(error)")
                case .finished:
                    ()
                }
                
                self?.isLoadingPublisher.send(false)
                
            }, receiveValue: { [weak self] featuredTips in
                let mappedFeaturedTips = ServiceProviderModelMapper.featuredTips(fromServiceProviderFeaturedTips: featuredTips)
                                
                self?.userTipsPublisher.value = mappedFeaturedTips
                
                if mappedFeaturedTips.count < 10 {
                    self?.tipsHasNextPage = false
                }
                else {
                    self?.tipsHasNextPage = true
                }
                
            })
            .store(in: &cancellables)
    }

    private func loadNextUserTips() {

        Env.servicesProvider.getFeaturedTips(page: self.page, limit: nil, topTips: nil, followersTips: nil, friendsTips: nil, userId: self.userId, homeTips: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("NEXT USER TIPS ERROR: \(error)")
                case .finished:
                    ()
                }
                
                self?.isLoadingPublisher.send(false)
                
            }, receiveValue: { [weak self] featuredTips in
                let mappedFeaturedTips = ServiceProviderModelMapper.featuredTips(fromServiceProviderFeaturedTips: featuredTips)
                
                print("NEXT USER TIPS: \(mappedFeaturedTips)")
                
                self?.userTipsPublisher.value.append(contentsOf: mappedFeaturedTips)
                
                if mappedFeaturedTips.count < 10 {
                    self?.tipsHasNextPage = false
                }
                else {
                    self?.tipsHasNextPage = true
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
