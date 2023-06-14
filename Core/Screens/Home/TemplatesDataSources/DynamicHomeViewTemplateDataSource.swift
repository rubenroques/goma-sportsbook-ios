//
//  DynamicHomeViewTemplateDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 04/05/2022.
//

import Foundation
import Combine
import ServicesProvider

class DynamicHomeViewTemplateDataSource {

    private var refreshPublisher = PassthroughSubject<Void, Never>.init()

    private var alertsArray: [ActivationAlert] = []

    //
    private var bannersLineViewModel: BannerLineCellViewModel?

    //
    private var favoriteMatches: [Match] = [] {
        didSet {
            self.refreshPublisher.send()
        }
    }

    //
    private var featuredTips: [FeaturedTip] = []
    private var cachedFeaturedTipLineViewModel: FeaturedTipLineViewModel? {
        didSet {
            self.refreshPublisher.send()
        }
    }

    //
    private var suggestedBets: [SuggestedBetCardSummary] = []
    private var cachedSuggestedBetLineViewModel: SuggestedBetLineViewModel? {
        didSet {
            self.refreshPublisher.send()
        }
    }

    //
    private var sportGroupViewModelCache: [String: SportGroupViewModel] = [:]

    //
    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    //
    private var homeFeedTemplate: HomeFeedTemplate

    //
    private var cancellables: Set<AnyCancellable> = []

    init(homeFeedTemplate: HomeFeedTemplate) {

        self.homeFeedTemplate = homeFeedTemplate

        var bannerCellViewModels: [BannerCellViewModel] = []
        for content in self.homeFeedTemplate.feedContents {
            switch content {
            case .banners(let items):
                let bannerCellViewModelsGroup = items.map { bannerItemFeedContent -> BannerCellViewModel? in
                    if bannerItemFeedContent.type == "game", let contentId = bannerItemFeedContent.contentId {
                        return BannerCellViewModel(presentationType: .externalMatch(contentId: String(contentId),
                                                                                    imageURLString: bannerItemFeedContent.typeImageURL ?? "",
                                                                                    eventPartId: String(bannerItemFeedContent.eventPartId ?? 0),
                                                                                    betTypeId: String(bannerItemFeedContent.bettingTypeId ?? 0) ))
                    }
                    else if bannerItemFeedContent.type == "stream" {
                        return BannerCellViewModel(presentationType: .externalStream(imageURLString: bannerItemFeedContent.typeImageURL ?? "",
                                                                                     streamURLString: bannerItemFeedContent.streamURL ?? ""))
                    }
                    else if bannerItemFeedContent.type == "external" {
                        return BannerCellViewModel(presentationType: .externalLink(imageURLString: bannerItemFeedContent.typeImageURL ?? "",
                                                                                   linkURLString: bannerItemFeedContent.externalLinkURL ?? ""))
                    }
                    return nil
                }.compactMap({ $0 })

                bannerCellViewModels.append(contentsOf: bannerCellViewModelsGroup)
            default:
                ()
            }
        }

        self.bannersLineViewModel = BannerLineCellViewModel(banners: bannerCellViewModels)

        self.refresh()

        Env.servicesProvider.eventsConnectionStatePublisher
            .filter({ $0 == .connected })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.refresh()
            })
            .store(in: &self.cancellables)

        Env.userSessionStore.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.refresh()
            })
            .store(in: &self.cancellables)

        Env.favoritesManager.favoriteEventsIdPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.fetchFavoriteMatches()
            })
            .store(in: &self.cancellables)

        Env.userSessionStore.isUserProfileCompletePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.fetchAlerts()
                self?.refreshPublisher.send()
            })
            .store(in: &cancellables)

        Env.userSessionStore.isUserEmailVerifiedPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.fetchAlerts()
                self?.refreshPublisher.send()
            })
            .store(in: &cancellables)

        Env.userSessionStore.userKnowYourCustomerStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.fetchAlerts()
                self?.refreshPublisher.send()
            })
            .store(in: &cancellables)
    }

    func refresh() {

        self.cachedMatchStatsViewModels = [:]
        self.cachedSuggestedBetLineViewModel = nil
        self.sportGroupViewModelCache = [:]

        self.fetchFavoriteMatches()
        self.fetchSuggestedBets()
        self.fetchAlerts()

    }

    // User alerts
    func fetchAlerts() {
        self.alertsArray = []
        if let isUserEmailVerified = Env.userSessionStore.isUserEmailVerified, !isUserEmailVerified {
            let emailActivationAlertData = ActivationAlert(title: localized("verify_email"),
                                                           description: localized("app_full_potential"),
                                                           linkLabel: localized("verify_my_account"),
                                                           alertType: .email)

            alertsArray.append(emailActivationAlertData)
        }

        if let isUserProfileComplete = Env.userSessionStore.isUserProfileComplete, !isUserProfileComplete {
            let completeProfileAlertData = ActivationAlert(title: localized("complete_your_profile"),
                                                           description: localized("complete_profile_description"),
                                                           linkLabel: localized("finish_up_profile"),
                                                           alertType: .profile)
            alertsArray.append(completeProfileAlertData)
        }
    }

    // Favorites
    private func fetchFavoriteMatches() {

    }

    // Suggested Bets
    func fetchSuggestedBets() {
        Env.gomaNetworkClient.requestSuggestedBets(deviceId: Env.deviceId)
            .compactMap({$0})
            .map({ betGroupsArray -> [SuggestedBetCardSummary] in
                var cardsSummaryArray: [SuggestedBetCardSummary] = []
                for betGroup in betGroupsArray {
                    cardsSummaryArray.append(SuggestedBetCardSummary.init(bets: betGroup))
                }
                return cardsSummaryArray
            })
            .sink(receiveCompletion: { _ in
            },
            receiveValue: { [weak self] suggestedBets in
                self?.suggestedBets = suggestedBets
                self?.refreshPublisher.send()
            })
            .store(in: &cancellables)
    }

}

extension DynamicHomeViewTemplateDataSource: HomeViewTemplateDataSource {

    var refreshRequestedPublisher: AnyPublisher<Void, Never> {
        return self.refreshPublisher.eraseToAnyPublisher()
    }

    func numberOfSections() -> Int {
        return self.homeFeedTemplate.feedContents.count
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {
        guard
            let feedContentType =  self.homeFeedTemplate.feedContents[safe: section]
        else {
            return 0
        }
        switch feedContentType {
        case .banners:
            return self.bannersLineViewModel == nil ? 0 : 1
        case .userMessageAlerts:
            return self.alertsArray.isEmpty ? 0 : 1
        case .favorites:
            return self.favoriteMatches.count
        case .featuredTips:
            return self.featuredTips.isEmpty ? 0 : 1
        case .suggestedBets:
            return self.suggestedBets.isEmpty ? 0 : 1
        case .sport(_, _, let contents):
            return contents.count
        case .promotionStoriesBar:
            return 0
        case .highlightedEvents:
            return 0
        case .swipeBetButton:
            return 0
        case .unknown:
            return 0
        }
    }

    func title(forSection section: Int) -> String? {
        guard
            let feedContentType =  self.homeFeedTemplate.feedContents[safe: section]
        else {
            return nil
        }
        switch feedContentType {
        case .banners:
            return nil
        case .userMessageAlerts:
            return nil
        case .favorites:
            return self.favoriteMatches.isNotEmpty ? localized("my_games") : nil
        case .featuredTips:
            return self.featuredTips.isNotEmpty ? localized("featured_tips") : nil
        case .suggestedBets:
            return self.suggestedBets.isNotEmpty ? localized("suggested_bets") : nil
        case .sport(_, let name, _):
            return name.capitalized
        case .promotionStoriesBar:
            return nil
        case .highlightedEvents:
            return nil
        case .swipeBetButton:
            return nil
        case .unknown:
            return nil
        }
    }

    func iconName(forSection section: Int) -> String? {
        guard
            let feedContentType =  self.homeFeedTemplate.feedContents[safe: section]
        else {
            return nil
        }
        switch feedContentType {
        case .sport(let id, _, _):
            return id
        default:
            return nil
        }
    }

    func shouldShowTitle(forSection section: Int) -> Bool {
        guard
            let feedContentType =  self.homeFeedTemplate.feedContents[safe: section]
        else {
            return false
        }
        switch feedContentType {
        case .banners:
            return false
        case .userMessageAlerts:
            return false
        case .favorites:
            return self.favoriteMatches.isNotEmpty
        case .featuredTips:
            return self.featuredTips.isNotEmpty
        case .suggestedBets:
            return self.suggestedBets.isNotEmpty
        case .sport:
            return true
        case .promotionStoriesBar:
            return false
        case .highlightedEvents:
            return false
        case .swipeBetButton:
            return false
        case .unknown:
            return false
        }
    }

    func shouldShowFooter(forSection section: Int) -> Bool {
        return false
    }

    func contentType(forSection section: Int) -> HomeViewModel.Content? {
        guard
            let feedContentType =  self.homeFeedTemplate.feedContents[safe: section]
        else {
            return nil
        }

        switch feedContentType {
        case .banners:
            return HomeViewModel.Content.bannerLine
        case .userMessageAlerts:
            return HomeViewModel.Content.userProfile
        case .favorites:
            return HomeViewModel.Content.userFavorites
        case .featuredTips:
            return HomeViewModel.Content.featuredTips
        case .suggestedBets:
            return HomeViewModel.Content.suggestedBets
        case .sport(let id, let name, _):
            let sport = Sport(id: id, name: name.capitalized, alphaId: nil, numericId: nil, showEventCategory: false, liveEventsCount: 0)
            return HomeViewModel.Content.sportGroup(sport)
        case .promotionStoriesBar:
            return nil
        case .highlightedEvents:
            return nil
        case .swipeBetButton:
            return nil
        case .unknown:
            return nil
        }
    }

    func alertsArrayViewModel() -> [ActivationAlert] {
        return self.alertsArray
    }

    func bannerLineViewModel() -> BannerLineCellViewModel? {
        return self.bannersLineViewModel
    }

    func sportGroupViewModel(forSection section: Int) -> SportGroupViewModel? {

        guard
            let feedContentType =  self.homeFeedTemplate.feedContents[safe: section],
            case let .sport(sportId, name, contents) = feedContentType
        else {
            return nil
        }

        if let viewModel = self.sportGroupViewModelCache[sportId] {
            return viewModel
        }
        else {
            let sport = Sport(id: sportId, name: name.capitalized, alphaId: nil, numericId: nil, showEventCategory: false, liveEventsCount: 0, eventsCount: 0)
            let sportGroupViewModel = SportGroupViewModel(sport: sport, contents: contents)
            sportGroupViewModel.requestRefreshPublisher
                .sink { [weak self] _ in
                    self?.refreshPublisher.send()
                }
                .store(in: &cancellables)
            self.sportGroupViewModelCache[sportId] = sportGroupViewModel
            return sportGroupViewModel
        }

    }

    func favoriteMatch(forIndex index: Int) -> Match? {
        return self.favoriteMatches[safe: index]
    }

    func featuredTipLineViewModel() -> FeaturedTipLineViewModel? {
        if self.featuredTips.isEmpty {
            return nil
        }

        if let featuredTipLineViewModel = self.cachedFeaturedTipLineViewModel {
            return featuredTipLineViewModel
        }
        else {
            self.cachedFeaturedTipLineViewModel = FeaturedTipLineViewModel(featuredTips: self.featuredTips)
            return self.cachedFeaturedTipLineViewModel
        }

    }

    func suggestedBetLineViewModel() -> SuggestedBetLineViewModel? {
        if self.suggestedBets.isEmpty {
            return nil
        }

        if let suggestedBetLineViewModel = self.cachedSuggestedBetLineViewModel {
            return suggestedBetLineViewModel
        }
        else {
            self.cachedSuggestedBetLineViewModel = SuggestedBetLineViewModel(suggestedBetCardSummaries: self.suggestedBets)
            return self.cachedSuggestedBetLineViewModel
        }
    }

    func matchStatsViewModel(forMatch match: Match) -> MatchStatsViewModel? {
        if let viewModel = cachedMatchStatsViewModels[match.id] {
            return viewModel
        }
        else {
            let viewModel = MatchStatsViewModel(match: match)
            cachedMatchStatsViewModels[match.id] = viewModel
            return viewModel
        }
    }

    func quickSwipeStackViewModel() -> QuickSwipeStackCellViewModel? {
        return nil
    }

    func highlightedMatchViewModel(forIndex index: Int) -> MatchWidgetCellViewModel? {
        return nil
    }

    func promotedMatch(forSection section: Int, forIndex index: Int) -> Match? {
        return nil
    }

}
