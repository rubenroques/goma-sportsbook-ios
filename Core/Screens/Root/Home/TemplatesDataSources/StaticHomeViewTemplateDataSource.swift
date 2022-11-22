//
//  StaticHomeViewTemplateDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 04/05/2022.
//

import Foundation
import ServiceProvider
import Combine

class StaticHomeViewTemplateDataSource {

    /*
    userMessage
    bannerLine
    userProfile
    userFavorites
    sport(Sport at index 0 - Football )
    suggestedBets
    sport(Sport at index 1)
    sport(Sport at index 2)
     ....
     */

    var refreshPublisher = PassthroughSubject<Void, Never>.init()

    // Updatable Storage
    var store: HomeStore

    private let itemsBeforeSports = 7
    private var userMessages: [String] = []

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

    //
    private var banners: [BannerInfo] = [] {
        didSet {
            var bannerCellViewModels: [BannerCellViewModel] = []

            for banner in self.banners {
                if let bannerViewModel = self.bannersLineViewModelCache[banner.id] {
                    bannerCellViewModels.append(bannerViewModel)
                }
                else {
                    let bannerViewModel = BannerCellViewModel(id: banner.id,
                                                              matchId: banner.matchId,
                                                              imageURL: banner.imageURL ?? "")
                    bannerCellViewModels.append(bannerViewModel)
                    self.bannersLineViewModelCache[banner.id] = bannerViewModel
                }
            }

            self.bannersLineViewModel = BannerLineCellViewModel(banners: bannerCellViewModels)
        }
    }
    private var bannersLineViewModelCache: [String: BannerCellViewModel] = [:]
    private var bannersLineViewModel: BannerLineCellViewModel? {
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
    private var sportsToFetch: [Sport] = []
    private var sportsLineViewModelsCache: [String: SportMatchLineViewModel] = [:]
    private var sportGroupViewModelCache: [String: SportGroupViewModel] = [:]

    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    //
    var alertsArray: [ActivationAlert] = []

    //
    // EM Registers
    private var bannersInfoRegister: EndpointPublisherIdentifiable?
    private var favoriteMatchesRegister: EndpointPublisherIdentifiable?

    // Combine Publishers
    private var bannersInfoPublisher: AnyCancellable?
    private var favoriteMatchesPublisher: AnyCancellable?

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Life Cycle
    init(store: HomeStore) {
        self.store = store

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

        Env.userSessionStore.isUserProfileComplete
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
        self.cachedFeaturedTipLineViewModel = nil

        self.requestSports()
        self.fetchBanners()
        self.fetchFavoriteMatches()
        self.fetchTips()
        self.fetchSuggestedBets()
        self.fetchAlerts()
        
//        self.fetchLocations()
//            .sink { [weak self] locations in
//                self?.store.storeLocations(locations: locations)
//
//                self?.requestSports()
//                self?.fetchBanners()
//                self?.fetchFavoriteMatches()
//                self?.fetchTips()
//                self?.fetchSuggestedBets()
//                self?.fetchAlerts()
//            }
//            .store(in: &cancellables)

    }

    func requestSports() {

        Env.serviceProvider.allSportTypes()
            .sink { (completion: Subscribers.Completion<ServiceProviderError>) in
                
            } receiveValue: { (subscribableContent: SubscribableContent<[SportType]>) in
                switch subscribableContent {
                case .connected:
                    ()
                case .content(let sportsList):
                    self.sportsToFetch = Array(sportsList.map(Sport.init(serviceProviderSportType:)).prefix(10))
                    self.refreshPublisher.send()
                case .disconnected:
                    ()
                }
            }
            .store(in: &cancellables)

//        let language = "en"
//        Env.everyMatrixClient.getDisciplines(language: language)
//            .map(\.records)
//            .compactMap({ $0 })
//            .sink(receiveCompletion: { _ in
//
//            }, receiveValue: { response in
//                self.sportsToFetch = Array(response.map(Sport.init(discipline:)).prefix(10))
//                self.refreshPublisher.send()
//            })
//            .store(in: &cancellables)
    }

    func fetchLocations() -> AnyPublisher<[EveryMatrix.Location], Never> {

        let router = TSRouter.getLocations(language: "en", sortByPopularity: false)
        return Env.everyMatrixClient.manager.getModel(router: router, decodingType: EveryMatrixSocketResponse<EveryMatrix.Location>.self)
            .map(\.records)
            .compactMap({$0})
            .replaceError(with: [EveryMatrix.Location]())
            .eraseToAnyPublisher()
    }

    // Banners
    func stopBannerUpdates() {
        if let bannersInfoRegister = bannersInfoRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: bannersInfoRegister)
        }

        self.bannersInfoPublisher?.cancel()
        self.bannersInfoPublisher = nil
    }

    func fetchAlerts() {
        alertsArray = []

        if let userSession = UserSessionStore.loggedUserSession() {
            if !userSession.isEmailVerified && !Env.userSessionStore.isUserEmailVerified.value {

                let emailActivationAlertData = ActivationAlert(title: localized("verify_email"),
                                                               description: localized("app_full_potential"),
                                                               linkLabel: localized("verify_my_account"), alertType: .email)

                alertsArray.append(emailActivationAlertData)
            }

            if !Env.userSessionStore.isUserProfileComplete.value {
                let completeProfileAlertData = ActivationAlert(title: localized("complete_your_profile"),
                                                               description: localized("complete_profile_description"),
                                                               linkLabel: localized("finish_up_profile"),
                                                               alertType: .profile)

                alertsArray.append(completeProfileAlertData)
            }
        }
    }

    func fetchBanners() {

        self.stopBannerUpdates()

        let endpoint = TSRouter.bannersInfoPublisher(operatorId: Env.appSession.operatorId, language: "en")

        self.bannersInfoPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrixSocketResponse<EveryMatrix.BannerInfo>.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in

            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    self?.bannersInfoRegister = publisherIdentifiable
                case .initialContent(let responde):
                    print("HomeViewModel bannersInfo initialContent")
                    let sortedBanners = (responde.records ?? []).sorted {
                        $0.priorityOrder ?? 0 < $1.priorityOrder ?? 1
                    }
                    self?.banners = sortedBanners.map({
                        BannerInfo(type: $0.type,
                                   id: $0.id,
                                   matchId: $0.matchID,
                                   imageURL: $0.imageURL,
                                   priorityOrder: $0.priorityOrder)
                    })
                    self?.stopBannerUpdates()
                case .updatedContent:
                    ()
                case .disconnect:
                    ()
                }
            })
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

    // Tips TEST
    func fetchTips() {
        // TODO: Usar enum no betType, 
        Env.gomaNetworkClient.requestFeaturedTips(deviceId: Env.deviceId, betType: "MULTIPLE")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("FEATURED TIPS ERROR: \(error)")
                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] response in
                if let featuredTips = response.data {
                    self?.featuredTips = featuredTips
                }
            })
            .store(in: &cancellables)
    }

    // Suggested Bets
    func fetchSuggestedBets() {

        Env.gomaNetworkClient.requestSuggestedBets(deviceId: Env.deviceId)
            .compactMap({$0})
            .map({ betGroupsArray in
                var cardsSummaryArray: [SuggestedBetCardSummary] = []
                for betGroup in betGroupsArray {
                    cardsSummaryArray.append(SuggestedBetCardSummary.init(bets: betGroup))
                }
                return cardsSummaryArray.filter { suggestedBetCardSummary in
                    suggestedBetCardSummary.bets.count > 1
                }
            })
            .sink(receiveCompletion: { _ in
                
            },
            receiveValue: { [weak self] suggestedBets in
                self?.suggestedBets = suggestedBets
            })
            .store(in: &cancellables)
    }

}

extension StaticHomeViewTemplateDataSource: HomeViewTemplateDataSource {

    var refreshRequestedPublisher: AnyPublisher<Void, Never> {
        return self.refreshPublisher.eraseToAnyPublisher()
    }

    func numberOfSections() -> Int {
//        return itemsBeforeSports + sportsToFetch.count - 1 // minus the fist sport
        return itemsBeforeSports
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {
        switch section {
        case 0:
            return 0
        case 1:
            if let bannersLineViewModel = self.bannersLineViewModel,
               bannersLineViewModel.banners.isNotEmpty {
                return 1
            }
            else {
                return 0
            }
        case 2: return self.alertsArray.isEmpty ? 0 : 1
        case 3: return self.favoriteMatches.count
        // case 4 is the first sport from the sports list
        case 5: return self.featuredTips.isEmpty ? 0 : 1
        case 6: return self.suggestedBets.isEmpty ? 0 : 1
        default:
            if let sportGroupViewModel = self.sportGroupViewModel(forSection: section) {
                return sportGroupViewModel.numberOfRows()
            }
            else {
                return 0
            }
        }
    }

    func title(forSection section: Int) -> String? {
        switch section {
        case 0: return nil
        case 1: return nil
        case 2: return nil
        case 3: return self.favoriteMatches.isNotEmpty ? "My Games" : nil
        // case 4 is the first sport from the sports list
        case 5: return self.featuredTips.isNotEmpty ? "Featured Tips" : nil
        case 6: return self.suggestedBets.isNotEmpty ? "Suggested Bets" : nil
        default:
            if let sportForSection = self.sportForSection(section) {
                return sportForSection.name
            }
            else {
                return nil
            }
        }
    }

    func iconName(forSection section: Int) -> String? {
        switch section {
        case 0, 1, 2, 3, 5, 6: return nil
        default:
            if let sportForSection = self.sportForSection(section) {
                return sportForSection.id
            }
            else {
                return nil
            }
        }
    }

    func shouldShowTitle(forSection section: Int) -> Bool {
        switch section {
        case 0: return false
        case 1: return false
        case 2: return false
        case 3: return self.favoriteMatches.isNotEmpty
        // case 4 is the first sport from the sports list
        case 5: return self.featuredTips.isNotEmpty
        case 6: return self.suggestedBets.isNotEmpty
        default:
            if self.sportForSection(section) != nil {
                return true
            }
            else {
                return false
            }
        }
    }

    func shouldShowFooter(forSection section: Int) -> Bool {
        switch section {
        case 0: return false
        case 1: return false
        case 2: return false
        case 3: return false
        // case 4 is the first sport from the sports list
        case 5: return false
        case 6: return false
        default:
            return false
        }
    }

    func contentType(forSection section: Int) -> HomeViewModel.Content? {
        switch section {
        case 0: return HomeViewModel.Content.userMessage
        case 1: return HomeViewModel.Content.bannerLine
        case 2: return HomeViewModel.Content.userProfile
        case 3: return HomeViewModel.Content.userFavorites
        // case 4 is the first sport from the sports list
        case 5: return HomeViewModel.Content.featuredTips
        case 6: return HomeViewModel.Content.suggestedBets
        default:
            if let sportForSection = self.sportForSection(section) {
                return HomeViewModel.Content.sport(sportForSection)
            }
            else {
                return nil
            }
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
            let sportForSection = self.sportForSection(section)
        else {
            return nil
        }

        if let viewModel = self.sportGroupViewModelCache[sportForSection.id] {
            return viewModel
        }
        else {
            let sportGroupViewModel = SportGroupViewModel(sport: sportForSection, store: self.store)
            sportGroupViewModel.requestRefreshPublisher
                .sink { [weak self] _ in
                    self?.refreshPublisher.send()
                }
                .store(in: &cancellables)

            self.sportGroupViewModelCache[sportForSection.id] = sportGroupViewModel
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

extension StaticHomeViewTemplateDataSource {

    private func sportForSection(_ section: Int) -> Sport? {
        let shiftedSection = self.sportShiftedSection(fromSection: section)
        return self.sportsToFetch[safe: shiftedSection]
    }

    private func sportShiftedSection(fromSection section: Int) -> Int {
        var shiftedSection = section
        if shiftedSection == 4 {
            shiftedSection = 0
        }
        else {
            shiftedSection = section - itemsBeforeSports + 1
        }

        return shiftedSection
    }

}

