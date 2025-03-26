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
    case clientBackendManaged
    case dummyWidgetShowcase(widgets: [HomeViewModel.Content] )
    case cmsManaged
}

class HomeViewModel {

    enum Content: Hashable, Codable {
        
        //Updated naming:
        case alertBannersLine
        
        // Legacy
        case userMessage
        case userFavorites
        case bannerLine
        case suggestedBets
        case footerBanner

        case promotedBetslips
        
        case quickSwipeStack
        case makeOwnBetCallToAction

        case topCompetitionsShortcuts

        case highlightedMatches
        case highlightedBoostedOddsMatches

        case highlightedLiveMatches

        case promotionalStories
        case promotedSportSection

        case supplementaryEvents
        case heroCard

        case highlightedMarketProChoices
        case videoNewsLine

        
        var identifier: String {
            switch self {
            case .alertBannersLine: return "userProfile"
                
            //
            case .userMessage: return "userMessage"
            case .userFavorites: return "userFavorites"
            case .bannerLine: return "bannerLine"
            case .suggestedBets: return "suggestedBets"
            
            case .promotedBetslips: return "promotedBetslips"
            case .footerBanner: return "footerBanner"

            case .quickSwipeStack: return "quickSwipeStack"
            case .makeOwnBetCallToAction: return "makeOwnBetCallToAction"
            case .topCompetitionsShortcuts: return "topCompetitionsShortcuts"

            case .highlightedMatches: return "highlightedMatches"
            case .highlightedBoostedOddsMatches: return "highlightedBoostedOddsMatches"

            case .highlightedLiveMatches: return "highlightedLiveMatches"

            case .promotionalStories: return "promotionalStories"
            case .promotedSportSection: return "promotedSportSection"

            case .supplementaryEvents: return "supplementaryEvents"

            case .heroCard: return "heroCard"
            case .highlightedMarketProChoices: return "highlightedMarketProChoices"

            case .videoNewsLine: return "videoNewsLine"
            }
        }
    }

    var refreshPublisher = PassthroughSubject<Void, Never>.init()

    private var homeViewTemplateDataSource: HomeViewTemplateDataSource
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Life Cycle
    init() {
        switch TargetVariables.homeTemplateBuilder {
        case .clientBackendManaged: // Hardcoded
            self.homeViewTemplateDataSource = StaticHomeViewTemplateDataSource()
        case .dummyWidgetShowcase: // Hardcoded with dummy data on some sections
            self.homeViewTemplateDataSource = DummyWidgetShowcaseHomeViewTemplateDataSource()
        case .cmsManaged: // Provided by GOMA CMS
            self.homeViewTemplateDataSource = CMSManagedHomeViewTemplateDataSource()
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

    // MARK: - Basic ViewModels
    
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

    // MARK: - Highlights ViewModels
    
    func highlightedMatchesViewModel(forIndex index: Int) -> MatchWidgetContainerTableViewModel? {
        return self.homeViewTemplateDataSource.highlightedMatchesViewModel(forIndex: index)
    }
    
    func highlightedBoostedMatchesViewModel(forIndex index: Int) -> MatchWidgetContainerTableViewModel? {
        return self.homeViewTemplateDataSource.highlightedBoostedMatchesViewModel(forIndex: index)
    }
    
    func highlightedMarketViewModel(forIndex index: Int) -> MarketWidgetContainerTableViewModel? {
        return self.homeViewTemplateDataSource.highlightedMarketViewModel(forIndex: index)
    }

    // MARK: - Live Matches ViewModels
    
    func highlightedLiveMatchLineTableCellViewModel(forSection section: Int, forIndex index: Int) -> MatchLineTableCellViewModel? {
        return self.homeViewTemplateDataSource.highlightedLiveMatchLineTableCellViewModel(forSection: section, forIndex: index)
    }

    func matchLineTableCellViewModel(forSection section: Int, forIndex index: Int) -> MatchLineTableCellViewModel? {
        return self.homeViewTemplateDataSource.matchLineTableCellViewModel(forSection: section, forIndex: index)
    }

    // MARK: - Other ViewModels
    
    func topCompetitionsLineCellViewModel(forSection section: Int) -> TopCompetitionsLineCellViewModel? {
        return self.homeViewTemplateDataSource.topCompetitionsLineCellViewModel(forSection: section)
    }

    func heroCardMatchViewModel(forIndex index: Int) -> MatchWidgetCellViewModel? {
        return self.homeViewTemplateDataSource.heroCardMatchViewModel(forIndex: index)
    }

    func videoNewsLineViewModel() -> VideoPreviewLineCellViewModel? {
        return self.homeViewTemplateDataSource.videoNewsLineViewModel()
    }
}
