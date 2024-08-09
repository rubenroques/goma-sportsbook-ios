//
//  HomeViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 09/02/2022.
//

import Foundation
import Combine
import OrderedCollections

enum HomeTemplateBuilderType {
    case appStatic
    case backendDynamic(clientTemplateKey: String)
    case clientDynamic
}

class HomeViewModel {

    enum Content {
        case userMessage
        case userFavorites
        case bannerLine
        case suggestedBets
        case sportGroup(Sport)

        case userProfile
        case featuredTips
        case footerBanner

        case quickSwipeStack
        case makeOwnBetCallToAction

        case topCompetitionsShortcuts

        case highlightedMatches
        case highlightedLiveMatches

        case promotionalStories
        case promotedSportSection

        case supplementaryEvents
        case heroCard

        var identifier: String {
            switch self {
            case .userMessage: return "userMessage"
            case .userFavorites: return "userFavorites"
            case .bannerLine: return "bannerLine"
            case .suggestedBets: return "suggestedBets"
            case .sportGroup(let sport): return "sport[\(sport)]"
            case .userProfile: return "userProfile"
            case .featuredTips: return "featuredTips"
            case .footerBanner: return "footerBanner"

            case .quickSwipeStack: return "quickSwipeStack"
            case .makeOwnBetCallToAction: return "makeOwnBetCallToAction"
            case .topCompetitionsShortcuts: return "topCompetitionsShortcuts"
            case .highlightedMatches: return "highlightedMatches"
            case .highlightedLiveMatches: return "highlightedLiveMatches"
                
            case .promotionalStories: return "promotionalStories"
            case .promotedSportSection: return "promotedSportSection"

            case .supplementaryEvents: return "supplementaryEvents"
                
            case .heroCard: return "heroCard"
            }
        }
    }

    var refreshPublisher = PassthroughSubject<Void, Never>.init()

    private var homeViewTemplateDataSource: HomeViewTemplateDataSource
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Life Cycle
    init() {

        switch TargetVariables.homeTemplateBuilder {
        case .appStatic: // hardcoded in the app code
            self.homeViewTemplateDataSource = StaticHomeViewTemplateDataSource()
        case .backendDynamic: // provided by our backend
            if let homeFeedTemplate = Env.appSession.homeFeedTemplate {
                self.homeViewTemplateDataSource = DynamicHomeViewTemplateDataSource(homeFeedTemplate: homeFeedTemplate)
            }
            else {
                fatalError("homeFeedTemplate or homeTemplateKey not found for client with homeTemplateBuilder = backendDynamic")
            }
        case .clientDynamic: // provided by the client backend
            self.homeViewTemplateDataSource = ClientManagedHomeViewTemplateDataSource()
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

    func storyLineViewModel() -> StoriesLineCellViewModel? {
        return self.homeViewTemplateDataSource.storyLineViewModel()
    }

    func setStoryLineViewModel(viewModel: StoriesLineCellViewModel) {
        self.homeViewTemplateDataSource.setStoryLineViewModel(viewModel: viewModel)
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

    func matchStatsViewModel(forMatch match: Match) -> MatchStatsViewModel? {
        return self.homeViewTemplateDataSource.matchStatsViewModel(forMatch: match)
    }

    func quickSwipeStackViewModel() -> QuickSwipeStackCellViewModel? {
        return self.homeViewTemplateDataSource.quickSwipeStackViewModel()
    }

    func highlightedMatchViewModel(forIndex index: Int) -> MatchWidgetCellViewModel? {
        return self.homeViewTemplateDataSource.highlightedMatchViewModel(forIndex: index)
    }

    func highlightedLiveMatchLineTableCellViewModel(forSection section: Int, forIndex index: Int) -> MatchLineTableCellViewModel? {
        return self.homeViewTemplateDataSource.highlightedLiveMatchLineTableCellViewModel(forSection: section, forIndex: index)
    }
    
    func matchLineTableCellViewModel(forSection section: Int, forIndex index: Int) -> MatchLineTableCellViewModel? {
        return self.homeViewTemplateDataSource.matchLineTableCellViewModel(forSection: section, forIndex: index)
    }

    func topCompetitionsLineCellViewModel(forSection section: Int) -> TopCompetitionsLineCellViewModel? {
        return self.homeViewTemplateDataSource.topCompetitionsLineCellViewModel(forSection: section)
    }
    
    func heroCardMatchViewModel(forIndex index: Int) -> MatchWidgetCellViewModel? {
        return self.homeViewTemplateDataSource.heroCardMatchViewModel(forIndex: index)
    }
    
}
