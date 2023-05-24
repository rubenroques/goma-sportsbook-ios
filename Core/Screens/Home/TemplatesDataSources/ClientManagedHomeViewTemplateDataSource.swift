//
//  ClientManagedHomeViewTemplateDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/05/2023.
//

import Foundation
import Combine
import ServicesProvider

class ClientManagedHomeViewTemplateDataSource {

    private var refreshPublisher = PassthroughSubject<Void, Never>.init()

    private var homeFeedTemplate: HomeFeedTemplate

    init(homeFeedTemplate: HomeFeedTemplate) {
        self.homeFeedTemplate = homeFeedTemplate
    }

}

extension ClientManagedHomeViewTemplateDataSource: HomeViewTemplateDataSource {

    var refreshRequestedPublisher: AnyPublisher<Void, Never> {
        return self.refreshPublisher.eraseToAnyPublisher()
    }

    func refresh() {
        // The Controller requested a refresh

    }

    func numberOfSections() -> Int {
        return 0
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {
        return 0
    }

    func title(forSection section: Int) -> String? {
        return "Title"
    }

    func iconName(forSection section: Int) -> String? {
        return ""
    }

    func shouldShowTitle(forSection section: Int) -> Bool {
        return false
    }

    func shouldShowFooter(forSection section: Int) -> Bool {
        return false
    }

    // Detail each content type for the section
    func contentType(forSection section: Int) -> HomeViewModel.Content? {
        return nil
    }

    // Content type ViewModels methods
    func alertsArrayViewModel() -> [ActivationAlert] {
        return []
    }

    func bannerLineViewModel() -> BannerLineCellViewModel? {
        return nil
    }

    func sportGroupViewModel(forSection section: Int) -> SportGroupViewModel? {
        return nil
    }

    func favoriteMatch(forIndex index: Int) -> Match? {
        return nil
    }

    func featuredTipLineViewModel() -> FeaturedTipLineViewModel? {
        return nil
    }

    func suggestedBetLineViewModel() -> SuggestedBetLineViewModel? {
        return nil
    }

    func matchStatsViewModel(forMatch match: Match) -> MatchStatsViewModel? {
        return nil
    }

}
