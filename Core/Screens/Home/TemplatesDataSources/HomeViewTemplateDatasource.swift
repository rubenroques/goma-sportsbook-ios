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

    func alertsArrayViewModel() -> [ActivationAlert]
    func bannerLineViewModel() -> BannerLineCellViewModel?
    func sportGroupViewModel(forSection section: Int) -> SportGroupViewModel?
    func favoriteMatch(forIndex index: Int) -> Match?
    func featuredTipLineViewModel() -> FeaturedTipLineViewModel?
    func suggestedBetLineViewModel() -> SuggestedBetLineViewModel?
    func matchStatsViewModel(forMatch match: Match) -> MatchStatsViewModel?

}

