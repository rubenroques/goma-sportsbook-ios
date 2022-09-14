//
//  HomeViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 09/02/2022.
//

import Foundation
import Combine
import OrderedCollections

class HomeViewModel {

    enum Content {
        case userMessage
        case userFavorites
        case bannerLine
        case suggestedBets
        case sport(Sport)
        case userProfile
        case featuredTips

        var identifier: String {
            switch self {
            case .userMessage: return "userMessage"
            case .userFavorites: return "userFavorites"
            case .bannerLine: return "bannerLine"
            case .suggestedBets: return "suggestedBets"
            case .sport(let sport): return "sport[\(sport)]"
            case .userProfile: return "userProfile"
            case .featuredTips: return "featuredTips"
            }
        }
    }

    var refreshPublisher = PassthroughSubject<Void, Never>.init()

    // Updatable Storage
    var store: HomeStore = HomeStore()

    private var homeViewTemplateDataSource: HomeViewTemplateDataSource
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Life Cycle
    init() {
        if let homeFeedTemplate = Env.appSession.homeFeedTemplate {
            self.homeViewTemplateDataSource = DynamicHomeViewTemplateDataSource(store: self.store, homeFeedTemplate: homeFeedTemplate)
        }
        else {
            self.homeViewTemplateDataSource = StaticHomeViewTemplateDataSource(store: self.store)
        }

        self.homeViewTemplateDataSource.refreshRequestedPublisher
            .sink { [weak self] _ in
                self?.refreshPublisher.send()
            }
            .store(in: &cancellables)
    }

    func refresh() {
        self.homeViewTemplateDataSource.refresh()
    }

}

extension HomeViewModel {

    func numberOfSections() -> Int {
        return self.homeViewTemplateDataSource.numberOfSections()
    }
    func numberOfRows(forSectionIndex section: Int) -> Int {
        return self.homeViewTemplateDataSource.numberOfRows(forSectionIndex: section)
    }

    func title(forSection section: Int) -> String? {
        return self.homeViewTemplateDataSource.title(forSection: section)
    }
    func iconName(forSection section: Int) -> String? {
        return self.homeViewTemplateDataSource.iconName(forSection: section)
    }

    func shouldShowTitle(forSection section: Int) -> Bool {
        return self.homeViewTemplateDataSource.shouldShowTitle(forSection: section)
    }
    func shouldShowFooter(forSection section: Int) -> Bool {
        return self.homeViewTemplateDataSource.shouldShowFooter(forSection: section)
    }

    func contentType(forSection section: Int) -> HomeViewModel.Content? {
        return self.homeViewTemplateDataSource.contentType(forSection: section)
    }

    func alertsArrayViewModel() -> [ActivationAlert] {
        return self.homeViewTemplateDataSource.alertsArrayViewModel()
    }
    func bannerLineViewModel() -> BannerLineCellViewModel? {
        return self.homeViewTemplateDataSource.bannerLineViewModel()
    }
    func sportGroupViewModel(forSection section: Int) -> SportGroupViewModel? {
        return self.homeViewTemplateDataSource.sportGroupViewModel(forSection: section)
    }
    func favoriteMatch(forIndex index: Int) -> Match? {
        return self.homeViewTemplateDataSource.favoriteMatch(forIndex: index)
    }

    func featuredTipLineViewModel() -> FeaturedTipLineViewModel? {
        return self.homeViewTemplateDataSource.featuredTipLineViewModel()
    }

    func suggestedBetLineViewModel() -> SuggestedBetLineViewModel? {
        return self.homeViewTemplateDataSource.suggestedBetLineViewModel()
    }

    func matchStatsViewModel(forMatch match: Match) -> MatchStatsViewModel {
        return self.homeViewTemplateDataSource.matchStatsViewModel(forMatch: match)
    }

    func isMatchLive(withMatchId matchId: String) -> Bool {
        return self.homeViewTemplateDataSource.isMatchLive(withMatchId: matchId)
    }

}
