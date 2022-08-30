//
//  DynamicHomeViewTemplateDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 04/05/2022.
//

import Foundation
import Combine

class DynamicHomeViewTemplateDataSource {

    private var store: HomeStore

    private var refreshPublisher = PassthroughSubject<Void, Never>.init()

    private var alertsArray: [ActivationAlert] = []

    //
    private var bannersLineViewModel: BannerLineCellViewModel?

    //
    private var favoriteMatchesIds: [String] = [] {
        didSet {
            var matches: [Match] = []
            for matchId in self.favoriteMatchesIds {
                if let match = self.store.matchWithId(id: matchId) {
                    matches.append(match)
                }
            }
            self.favoriteMatches = matches
        }
    }
    private var favoriteMatches: [Match] = [] {
        didSet {
            self.refreshPublisher.send()
        }
    }
    private var favoriteMatchesRegister: EndpointPublisherIdentifiable?
    private var favoriteMatchesPublisher: AnyCancellable?

    //
    private var featuredTips: [String] = []

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

    init(store: HomeStore, homeFeedTemplate: HomeFeedTemplate) {
        self.store = store
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

        Env.everyMatrixClient.serviceStatusPublisher
            .filter(\.isConnected)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.refresh()
            })
            .store(in: &self.cancellables)

        Env.userSessionStore.userSessionPublisher
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

        Env.userSessionStore.isUserProfileIncomplete
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.fetchAlerts()
                self?.refreshPublisher.send()
            })
            .store(in: &cancellables)

        Env.userSessionStore.isUserEmailVerified
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

        self.fetchLocations()
            .sink { [weak self] locations in
                self?.store.storeLocations(locations: locations)

                self?.fetchFavoriteMatches()
                self?.fetchSuggestedBets()
                self?.fetchAlerts()
            }
            .store(in: &cancellables)
    }

    func fetchLocations() -> AnyPublisher<[EveryMatrix.Location], Never> {

        let router = TSRouter.getLocations(language: "en", sortByPopularity: false)
        return Env.everyMatrixClient.manager.getModel(router: router, decodingType: EveryMatrixSocketResponse<EveryMatrix.Location>.self)
            .map(\.records)
            .compactMap({$0})
            .replaceError(with: [EveryMatrix.Location]())
            .eraseToAnyPublisher()
    }

    // User alerts
    func fetchAlerts() {
        alertsArray = []

        if let userSession = UserSessionStore.loggedUserSession() {
            if !userSession.isEmailVerified && !Env.userSessionStore.isUserEmailVerified.value {

                let emailActivationAlertData = ActivationAlert(title: localized("verify_email"),
                                                               description: localized("app_full_potential"),
                                                               linkLabel: localized("verify_my_account"), alertType: .email)

                alertsArray.append(emailActivationAlertData)
            }

            if Env.userSessionStore.isUserProfileIncomplete.value {
                let completeProfileAlertData = ActivationAlert(title: localized("complete_your_profile"),
                                                               description: localized("complete_profile_description"),
                                                               linkLabel: localized("finish_up_profile"),
                                                               alertType: .profile)

                alertsArray.append(completeProfileAlertData)
            }
        }
    }


    // Favorites
    private func fetchFavoriteMatches() {

        if let favoriteMatchesRegister = favoriteMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: favoriteMatchesRegister)
        }

        guard let userId = Env.userSessionStore.userSessionPublisher.value?.userId else { return }

        let endpoint = TSRouter.favoriteMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                      language: "en",
                                                      userId: userId)

        self.favoriteMatchesPublisher?.cancel()
        self.favoriteMatchesPublisher = nil

        self.favoriteMatchesPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving Favorite data!")

                case .finished:
                    print("Favorite Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("PreLiveEventsViewModel favoriteMatchesPublisher connect")
                    self?.favoriteMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("PreLiveEventsViewModel favoriteMatchesPublisher initialContent")
                    self?.setupFavoriteMatchesAggregatorProcessor(aggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    print("PreLiveEventsViewModel favoriteMatchesPublisher updatedContent")
                    self?.updateFavoriteMatchesAggregatorProcessor(aggregator: aggregatorUpdates)
                case .disconnect:
                    print("PreLiveEventsViewModel favoriteMatchesPublisher disconnect")
                }

            })
    }

    private func setupFavoriteMatchesAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        self.store.storeContent(fromAggregator: aggregator)

        var matchesIds: [String] = []
        for content in aggregator.content ?? [] {
            switch content {
            case .match(let matchContent):
                matchesIds.append(matchContent.id)
            default:
                ()
            }
        }

        self.favoriteMatchesIds = Array(matchesIds.prefix(2))
    }

    private func updateFavoriteMatchesAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        self.store.updateContent(fromAggregator: aggregator)
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
            return self.favoriteMatches.isNotEmpty ? "My Games" : nil
        case .featuredTips:
            return self.featuredTips.isNotEmpty ? "Featured Tips" : nil
        case .suggestedBets:
            return self.suggestedBets.isNotEmpty ? "Suggested Bets" : nil
        case .sport(_, let name, _):
            return name.capitalized
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
        case .sport(let id, _, _):
            return HomeViewModel.Content.sport(Sport(id: id))
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
            let sportGroupViewModel = SportGroupViewModel(sport: Sport(id: sportId, name: name.capitalized), contents: contents, store: self.store)
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

    func matchStatsViewModel(forMatch match: Match) -> MatchStatsViewModel {
        if let viewModel = cachedMatchStatsViewModels[match.id] {
            return viewModel
        }
        else {
            let viewModel = MatchStatsViewModel(match: match)
            cachedMatchStatsViewModels[match.id] = viewModel
            return viewModel
        }
    }

    func isMatchLive(withMatchId matchId: String) -> Bool {
        return self.store.hasMatchesInfoForMatch(withId: matchId)
    }

}
