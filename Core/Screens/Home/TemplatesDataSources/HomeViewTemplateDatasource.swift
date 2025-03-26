//
//  HomeViewTemplateDatasource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 04/05/2022.
//

import Foundation
import Combine

protocol HomeViewTemplateDataSource {

    var refreshRequestedPublisher: AnyPublisher<Void, Never> { get }

    func refresh()

    func numberOfSections() -> Int
    func numberOfRows(forSectionIndex section: Int) -> Int

    func title(forSection section: Int) -> String?
    func iconName(forSection section: Int) -> String?

    func shouldShowTitle(forSection section: Int) -> Bool
    func shouldShowFooter(forSection section: Int) -> Bool

    func contentType(forSection section: Int) -> HomeViewModel.Content?

    // Basic ViewModels
    func alertsArrayViewModel() -> [ActivationAlert]
    func bannerLineViewModel() -> BannerLineCellViewModel?
    func storyLineViewModel() -> StoriesLineCellViewModel?
    func sportGroupViewModel(forSection section: Int) -> SportGroupViewModel?
    func favoriteMatch(forIndex index: Int) -> Match?
    func featuredTipLineViewModel() -> FeaturedTipLineViewModel?
    func suggestedBetLineViewModel() -> SuggestedBetLineViewModel?
    func matchStatsViewModel(forMatch match: Match) -> MatchStatsViewModel?
    func quickSwipeStackViewModel() -> QuickSwipeStackCellViewModel?
    
    // Highlights ViewModels
    func highlightedMatchesViewModel(forIndex index: Int) -> MatchWidgetContainerTableViewModel?
    func highlightedBoostedMatchesViewModel(forIndex index: Int) -> MatchWidgetContainerTableViewModel?
    func highlightedMarketViewModel(forIndex index: Int) -> MarketWidgetContainerTableViewModel?

    // Live Matches ViewModels
    func highlightedLiveMatchLineTableCellViewModel(forSection section: Int, forIndex index: Int) -> MatchLineTableCellViewModel?
    func matchLineTableCellViewModel(forSection section: Int, forIndex index: Int) -> MatchLineTableCellViewModel?
    
    // Other ViewModels
    func topCompetitionsLineCellViewModel(forSection section: Int) -> TopCompetitionsLineCellViewModel?
    func setStoryLineViewModel(viewModel: StoriesLineCellViewModel)
    func heroCardMatchViewModel(forIndex index: Int) -> MatchWidgetCellViewModel?
    func videoNewsLineViewModel() -> VideoPreviewLineCellViewModel?
}
