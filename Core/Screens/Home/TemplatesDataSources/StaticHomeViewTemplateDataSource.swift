//
//  StaticHomeViewTemplateDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 04/05/2022.
//

import Foundation
import ServicesProvider
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

    private let itemsBeforeSports = 7
    private var userMessages: [String] = []

    //
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
                                                              imageURL: banner.imageURL ?? "",
                                                              marketId: banner.marketId)
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

    // Combine Publishers
    private var bannersInfoPublisher: AnyCancellable?
    private var favoriteMatchesPublisher: AnyCancellable?

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Life Cycle
    init() {
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
        self.cachedFeaturedTipLineViewModel = nil

        self.requestSports()
        self.fetchBanners()
        self.fetchFavoriteMatches()
        self.fetchTips()
        self.fetchSuggestedBets()
        self.fetchAlerts()
    }

    func requestSports() {
        let allSports = Env.sportsStore.getAvailableSports()
        let prefixSports = allSports.filter({ $0.alphaId != nil }).prefix(10)

        // TODO: REMOVE THIS DEBUG CODE
        // self.sportsToFetch = [] // Array(prefixSports)

        self.sportsToFetch = Array(prefixSports)

        self.refreshPublisher.send()
    }

    func fetchAlerts() {
        self.alertsArray = []
        if let isUserEmailVerified = Env.userSessionStore.isUserEmailVerified.value, !isUserEmailVerified {
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
        if let userKnowYourCustomerStatus = Env.userSessionStore.userKnowYourCustomerStatus,
            userKnowYourCustomerStatus == .request {
            let uploadDocumentsAlertData = ActivationAlert(title: localized("document_validation_required"),
                                                           description: localized("document_validation_required_description"),
                                                           linkLabel: localized("complete_your_verification"),
                                                           alertType: .documents)

            alertsArray.append(uploadDocumentsAlertData)
        }
    }

    func fetchBanners() {
        self.banners = []

        Env.servicesProvider.getHomeSliders()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("BANNERS ERROR: \(error)")
                }
            }, receiveValue: { [weak self] bannersResponse in
                let bannersInfo = bannersResponse
                
                let banners = bannersResponse.bannerItems.map({
                    if let linkUrl = $0.linkUrl,
                       // linkUrl.contains("event"),
                       let matchId = linkUrl.components(separatedBy: "/").last {
                        let bannerInfo = BannerInfo(type: $0.type, id: $0.id, matchId: matchId, imageURL: $0.imageUrl, marketId: $0.marketId)
                        return bannerInfo
                    }

                    let bannerInfo = BannerInfo(type: $0.type, id: $0.id, imageURL: $0.imageUrl)
                    return bannerInfo
                })
                self?.banners = banners
            })
            .store(in: &cancellables)
    }

    // Favorites
    private func fetchFavoriteMatches() {

        self.favoriteMatches = []

        let favoriteEventsId = Env.favoritesManager.favoriteEventsIdPublisher.value

        for eventId in favoriteEventsId {

            Env.servicesProvider.getEventSummary(eventId: eventId)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        ()
                    case .failure(let error):
                        print("EVENT SUMMARY ERROR: \(error)")
                    }
                }, receiveValue: { [weak self] eventSummary in

                    guard let self = self else {return}

                    if eventSummary.homeTeamName != "" || eventSummary.awayTeamName != "" {
                        let match = ServiceProviderModelMapper.match(fromEvent: eventSummary)

                        if !self.favoriteMatches.contains(where: {
                            $0.id == match.id
                        }), self.favoriteMatches.count < 2 {
                            self.favoriteMatches.append(match)
                        }
                    }

                })
                .store(in: &cancellables)
        }

    }

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
        return itemsBeforeSports + sportsToFetch.count - 1 + 1 // minus the first sport
        // return itemsBeforeSports
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {

        if section == self.numberOfSections()-1 {
            return 1
        }

        switch section {
        case 0:
            return 0
        case 1: return self.alertsArray.isEmpty ? 0 : 1
        case 2:
            if let bannersLineViewModel = self.bannersLineViewModel,
               bannersLineViewModel.banners.isNotEmpty {
                return 1
            }
            else {
                return 0
            }
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
            if let sportGroupViewModel = self.sportGroupViewModel(forSection: section) {
                let shouldShowGroup = sportGroupViewModel.shouldShowGroup()
                return shouldShowGroup
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

        if section == self.numberOfSections()-1 {
            return .footerBanner
        }

        switch section {
        case 0: return HomeViewModel.Content.userMessage
        case 1: return HomeViewModel.Content.userProfile
        case 2: return HomeViewModel.Content.bannerLine
        case 3: return HomeViewModel.Content.userFavorites
        // case 4 is the first sport from the sports list
        case 5: return HomeViewModel.Content.featuredTips
        case 6: return HomeViewModel.Content.suggestedBets
        default:
            if let sportForSection = self.sportForSection(section) {
                return HomeViewModel.Content.sportGroup(sportForSection)
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
            let sportGroupViewModel = SportGroupViewModel(sport: sportForSection)
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

    func storyLineViewModel() -> StoriesLineCellViewModel? {
        return nil
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


