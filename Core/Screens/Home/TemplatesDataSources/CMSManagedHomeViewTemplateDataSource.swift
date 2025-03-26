//
//  CMSManagedHomeViewTemplateDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/05/2023.
//

import Foundation
import Combine
import ServicesProvider

class CMSManagedHomeViewTemplateDataSource {

    // Dynamic content types array populated from CMS
    private var contentTypes: [HomeViewModel.Content] = []

    private var fixedSections: Int {
        return self.contentTypes.count
    }

    private var refreshPublisher = PassthroughSubject<Void, Never>.init()

    // ALERTS
    // New model
    private var alerts = HomeAlerts()

    // User Alert
    private var alertsArray: [ActivationAlert] = []

    // BANNERS
    // Banners
    private var banners: [BannerInfo] = [] {
        didSet {
            var bannerCellViewModels: [BannerCellViewModel] = []

            for banner in self.banners {
                if let bannerViewModel = self.bannersLineViewModelCache[banner.id] {
                    bannerCellViewModels.append(bannerViewModel)
                }
                else {
                    let bannerViewModel = BannerCellViewModel(bannerInfo: banner)
                    bannerCellViewModels.append(bannerViewModel)
                    self.bannersLineViewModelCache[banner.id] = bannerViewModel
                }
            }

            if bannerCellViewModels.isEmpty {
                self.bannersLineViewModel = nil
            }
            else {
                self.bannersLineViewModel = BannerLineCellViewModel(banners: bannerCellViewModels)
            }
        }
    }
    private var bannersLineViewModelCache: [String: BannerCellViewModel] = [:]
    private var bannersLineViewModel: BannerLineCellViewModel? {
        didSet {
            self.refreshPublisher.send()
        }
    }

    //
    private var suggestedBetslips: [SuggestedBetslip] = []
    private var cachedFeaturedTipLineViewModel: FeaturedTipLineViewModel? {
        didSet {
            self.refreshPublisher.send()
        }
    }

    //
    private var promotionalStories: [PromotionalStory] = [] {
        didSet {
            var storiesViewModels: [StoriesItemCellViewModel] = []
            for promotionalStory in self.promotionalStories {

                if let storyViewModel = self.storiesViewModelsCache[promotionalStory.id] {
                    storiesViewModels.append(storyViewModel)
                }
                else {
                    let readStory = Self.checkStoryInReadInstaStoriesArray(promotionalStory.id)
                    let storyViewModel = StoriesItemCellViewModel(promotionalStory: promotionalStory,
                                                                  isRead: readStory)

                    storiesViewModels.append(storyViewModel)

                    self.storiesViewModelsCache[promotionalStory.id] = storyViewModel
                }
            }

            if storiesViewModels.isEmpty {
                self.storiesLineViewModel = nil
            }
            else {
                self.storiesLineViewModel = StoriesLineCellViewModel(storiesViewModels: storiesViewModels)
            }
        }
    }
    private var storiesViewModelsCache: [String: StoriesItemCellViewModel] = [:]
    private var storiesLineViewModel: StoriesLineCellViewModel? {
        didSet {
            self.refreshPublisher.send()
        }
    }
    //
    // Quick Swipe Stack Matches
    private var quickSwipeStackCellViewModel: QuickSwipeStackCellViewModel?

    private var quickSwipeStackMatches: [Match] = [] {
        didSet {
            self.quickSwipeStackCellViewModel = QuickSwipeStackCellViewModel(title: nil, matches: self.quickSwipeStackMatches)
        }
    }
    //

    //
    // Quick Swipe Stack Matches
    enum HighlightsPresentationMode {
        case onePerLine
        case multiplesPerLineByType
    }
    
    // Dictionary to hold presentation mode for each content type
    private var highlightsPresentationModes: [HomeViewModel.Content: HighlightsPresentationMode] = [
        .highlightedMatches: .multiplesPerLineByType,
        .highlightedBoostedOddsMatches: .multiplesPerLineByType,
        .highlightedMarketProChoices: .multiplesPerLineByType
    ]

    private var highlightsVisualImageMatches: [Match]  = []
    private var highlightsVisualImageOutrights: [Match] = []
    private var highlightsBoostedMatches: [Match] = []

    //
    // Hero card
    private var heroMatches: [Match]  = []

    // Make your own bet call to action
    var shouldShowOwnBetCallToAction: Bool = true

    // PromotedSports
    var promotedSports: [PromotedSport] = [] {
        didSet {
            self.promotedSports.forEach { [weak self] promotedSport in
                self?.fetchMatchesForPromotedSport(promotedSport)
            }
        }
    }
    var promotedSportsMatches: [String: [Match]] = [:]

    //
    // ViewModels Caches
    var matchWidgetContainerTableViewModelCache: [String: MatchWidgetContainerTableViewModel] = [:]
    var matchWidgetCellViewModelCache: [String: MatchWidgetCellViewModel] = [:]
    var matchLineTableCellViewModelCache: [String: MatchLineTableCellViewModel] = [:]
    var heroCardWidgetCellViewModelCache: [String: MatchWidgetCellViewModel] = [:]

    var highlightedLiveMatchLineCellViewModelCache: [String: MatchLineTableCellViewModel] = [:]

    var marketWidgetContainerTableViewModelCache: [String: MarketWidgetContainerTableViewModel] = [:]

    //
    //
    private var topCompetitionsLineCellViewModel: TopCompetitionsLineCellViewModel = TopCompetitionsLineCellViewModel(topCompetitions: [])

    private var highlightedLiveMatches: [Match] = []

    private var highlightedMarkets: [ImageHighlightedContent<Market>] = []

    //
    private var pendingUserTrackRequest: AnyCancellable?

    private let cancellablesLock = NSLock()
    private var cancellables: Set<AnyCancellable> = []

    init() {
        // First, fetch the home template from the CMS
        self.fetchHomeTemplate()

        // Banners are associated with profile publisher
        let profileCancellable = Env.userSessionStore.userProfilePublisher
            .removeDuplicates()
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshData()
            }

        self.addCancellable(profileCancellable)
    }

    // Fetch the home template from the CMS
    private func fetchHomeTemplate() {
        let homeTemplateCancellable = Env.servicesProvider.getHomeTemplate()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    print("Error fetching home template: \(error)")
                    // Use default template as fallback
                    self?.setDefaultContentTypes()
                    self?.refreshData()
                }
            }, receiveValue: { [weak self] homeTemplate in
                self?.processHomeTemplate(homeTemplate)
                self?.refreshData()
            })

        self.addCancellable(homeTemplateCancellable)
    }

    // Process the home template received from the CMS
    private func processHomeTemplate(_ homeTemplate: HomeTemplate) {
        // Sort widgets by sortOrder
        let sortedWidgets = homeTemplate.widgets.sorted { $0.sortOrder < $1.sortOrder }

        // Convert CMS widgets to app content types
        self.contentTypes = sortedWidgets.compactMap { widget in
            return self.mapWidgetToContentType(widget)
        }

        // Trigger a refresh since we've updated the content types
        self.refreshPublisher.send()
    }

    // Map CMS widget types to app content types
    private func mapWidgetToContentType(_ widget: HomeWidget) -> HomeViewModel.Content? {
        switch widget {
        case .alertBanners:
            return .alertBannersLine
        case .banners:
            return .bannerLine
        case .carouselEvents:
            return .quickSwipeStack
        case .stories:
            return .promotionalStories
        case .heroCardEvents:
            return .heroCard
        case .highlightedLiveEvents:
            return .highlightedLiveMatches
        case .betSwipe:
            return .makeOwnBetCallToAction
        case .highlightedEvents:
            return .highlightedMatches
        case .boostedEvents:
            return .highlightedBoostedOddsMatches
        case .proChoices:
            return .highlightedMarketProChoices
        case .topCompetitions:
            return .topCompetitionsShortcuts
        case .suggestedBets:
            return .promotedBetslips
        case .popularEvents:
            return .promotedSportSection
        }
    }

    // Set default content types in case of failure
    private func setDefaultContentTypes() {
        self.contentTypes = [
            .alertBannersLine, // AlertBanners
            .bannerLine, // PromotionBanners
            .quickSwipeStack, // MatchBanners
            .promotionalStories, // PromotionStories - instagram style stories
            .heroCard, // HeroBanner
            .highlightedLiveMatches, // LiveGamesHome
            .makeOwnBetCallToAction, // MakeYourOwnBet
            .highlightedMatches, // Highlights image cards
            .highlightedMarketProChoices, // Pro Choices Markets
            .highlightedBoostedOddsMatches, // Boosted Odds
            .topCompetitionsShortcuts, // TopCompetitionsMobile
            .promotedBetslips, // SuggestedBets
        ]
    }

    func refreshTemplate() {
        // First refresh the home template
        self.fetchHomeTemplate()
    }

    func refreshData() {
        // Clear all caches regardless of which widgets are present
        self.matchWidgetContainerTableViewModelCache = [:]
        self.matchWidgetCellViewModelCache = [:]
        self.matchLineTableCellViewModelCache = [:]
        self.matchLineTableCellViewModelCache = [:]
        self.marketWidgetContainerTableViewModelCache = [:]
        self.heroCardWidgetCellViewModelCache = [:]

        self.suggestedBetslips = []
        self.highlightedMarkets = []

        self.cachedFeaturedTipLineViewModel = nil

        self.highlightedLiveMatchLineCellViewModelCache = [:]

        // Only fetch data for widgets that are present in contentTypes
        if self.contentTypes.contains(.quickSwipeStack) {
            self.fetchCarouselMatches()
        }

        if self.contentTypes.contains(.highlightedMatches) || self.contentTypes.contains(.highlightedBoostedOddsMatches) {
            self.fetchHighlightMatches()
        }

        if self.contentTypes.contains(.highlightedMarketProChoices) {
            self.fetchHighlightMarkets()
        }

        if self.contentTypes.contains(.promotedSportSection) {
            self.fetchPromotedSports()
        }

        if self.contentTypes.contains(.promotedBetslips) {
            self.fetchPromotedBetslips()
        }

        if self.contentTypes.contains(.promotionalStories) {
            self.fetchPromotionalStories()
        }

        if self.contentTypes.contains(.topCompetitionsShortcuts) {
            self.fetchTopCompetitions()                   }

        if self.contentTypes.contains(.highlightedLiveMatches) {
            self.fetchHighlightedLiveMatches()
        }

        if self.contentTypes.contains(.heroCard) {
            self.fetchHeroMatches()
        }

        if self.contentTypes.contains(.alertBannersLine) {
            self.fetchAlerts()
        }

        if self.contentTypes.contains(.bannerLine) {
            self.fetchBanners()
        }
    }
    
    // User alerts
    func fetchAlerts() {
        let kycPublisher = Env.userSessionStore.userKnowYourCustomerStatusPublisher
            .map { kycStatus -> [ActivationAlert] in
                if kycStatus == .request {
                    let uploadDocumentsAlertData = ActivationAlert(
                        title: localized("document_validation_required"),
                        description: localized("document_validation_required_description"),
                        linkLabel: localized("complete_your_verification"),
                        alertType: .documents
                    )
                    return [uploadDocumentsAlertData]
                }
                return []
            }

        let serverAlertsPublisher = Env.servicesProvider.getAlertBanner()
            .map { alertBanner -> [ActivationAlert] in
                guard let alertBanner = alertBanner else { return [] }
                let serverAlert = ServiceProviderModelMapper.activationAlert(fromAlertBanner: alertBanner)
                return [serverAlert]
            }
            .replaceError(with: [])

        let combinedCancellable = Publishers.CombineLatest(kycPublisher, serverAlertsPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] kycAlerts, serverAlerts in
                self?.alertsArray = kycAlerts + serverAlerts
                self?.refreshPublisher.send()
            }

        self.addCancellable(combinedCancellable)
    }

    // User alerts
    func fetchBanners() {
        let cancellable = Env.servicesProvider.getBanners()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                //
            } receiveValue: { [weak self] (banners: [Banner]) in
                guard let self = self else { return }

                // Filter banners based on user login status if needed
                let filteredBanners = banners.filter { banner in
                    if Env.userSessionStore.isUserLogged() {
                        return banner.userType == "all" || banner.userType == "logged_in"
                    }
                    else {
                        return banner.userType == "all" || banner.userType == "logged_out"
                    }
                }

                // Map to BannerInfo using the new mapper
                self.banners = filteredBanners.map(ServiceProviderModelMapper.bannerInfo(fromBanner:))
                self.refreshPublisher.send()
            }

        // Store the cancellable in a thread-safe manner
        self.addCancellable(cancellable)
    }

    func fetchPromotionalStories() {
        let cancellable = Env.servicesProvider.getStories()
            .map(ServiceProviderModelMapper.promotionalStories(fromServiceProviderStories:))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                
            } receiveValue: { [weak self] promotionalStories in
                self?.promotionalStories = promotionalStories
                self?.refreshPublisher.send()
            }

        self.addCancellable(cancellable)
    }

    func fetchCarouselMatches() {
        let cancellable = Env.servicesProvider.getCarouselEvents()
            .map(ServiceProviderModelMapper.matches(fromEvents:))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                //
            }, receiveValue: { [weak self] matches in
                self?.quickSwipeStackMatches = matches
                self?.refreshPublisher.send()
            })

        self.addCancellable(cancellable)
    }

    //
    // Highlights
    func highlightsMatchesNumberOfRows() -> Int {
        guard let mode = highlightsPresentationModes[.highlightedMatches] else { return 0 }
        
        switch mode {
        case .onePerLine:
            return self.highlightsVisualImageMatches.count + self.highlightsVisualImageOutrights.count
        case .multiplesPerLineByType:
            return (self.highlightsVisualImageMatches.isNotEmpty ? 1 : 0) + (self.highlightsVisualImageOutrights.isNotEmpty ? 1 : 0)
        }
    }

    func highlightsBoostedOddsMatchesNumberOfRows() -> Int {
        guard let mode = highlightsPresentationModes[.highlightedBoostedOddsMatches] else { return 0 }
        
        switch mode {
        case .onePerLine:
            return self.highlightsBoostedMatches.count
        case .multiplesPerLineByType:
            return self.highlightsBoostedMatches.isNotEmpty ? 1 : 0
        }
    }

    func highlightedMarketProChoicesNumberOfRows() -> Int {
        guard let mode = highlightsPresentationModes[.highlightedMarketProChoices] else { return 0 }
        
        switch mode {
        case .onePerLine:
            return self.highlightedMarkets.count
        case .multiplesPerLineByType:
            return self.highlightedMarkets.isNotEmpty ? 1 : 0
        }
    }

    func fetchHighlightMatches() {

        let imageMatches = Env.servicesProvider.getTopImageEvents()
            .receive(on: DispatchQueue.main)
            .map(ServiceProviderModelMapper.matches(fromEvents:))
            .replaceError(with: [])

        let boostedMatches = Env.servicesProvider.getBoostedOddsEvents()
            .receive(on: DispatchQueue.main)
            .map({ events in
                return ServiceProviderModelMapper.matches(fromEvents: events)
            })
            // .map(ServiceProviderModelMapper.matches(fromEvents:))
            .replaceError(with: [])

        let combinedCancellable = Publishers.CombineLatest(imageMatches, boostedMatches)
        .map { highlightedVisualImageEvents, highlightedBoostedEvents -> [HighlightedMatchType] in
            var events: [HighlightedMatchType] = highlightedVisualImageEvents.map({ HighlightedMatchType.visualImageMatch($0) })
            events.append(contentsOf: highlightedBoostedEvents.map({ HighlightedMatchType.boostedOddsMatch($0) }))
            return events
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in
            //
        }, receiveValue: { [weak self] highlightedMatchTypes in
            var imageMatches: [Match] = [ ]
            var boostedMatches: [Match] = []
            for highlightedMatchType in highlightedMatchTypes {
                // We can only show 1 match per market
                // So ignore duplicated matches that have the same markets
                switch highlightedMatchType {
                case .visualImageMatch(let match):
                    if !imageMatches.contains(where: { arrayMatch in
                        arrayMatch.id == match.id &&
                        arrayMatch.markets.map(\.id) == match.markets.map(\.id)
                    }) {
                        imageMatches.append(match)
                    }
                case .boostedOddsMatch(let match):
                    if !boostedMatches.contains(where: { arrayMatch in
                        arrayMatch.id == match.id &&
                        arrayMatch.markets.map(\.id) == match.markets.map(\.id)
                    }) {
                        boostedMatches.append(match)
                    }
                }
            }

            self?.highlightsVisualImageMatches = imageMatches.filter({
                $0.homeParticipant.name != "" && $0.awayParticipant.name != ""
            })

            self?.highlightsVisualImageOutrights = imageMatches.filter({
                $0.homeParticipant.name == "" && $0.awayParticipant.name == ""
            })

            self?.highlightsBoostedMatches = boostedMatches

            self?.refreshPublisher.send()
        })

        self.addCancellable(combinedCancellable)
    }

    func fetchHighlightMarkets() {
        let cancellable = Env.servicesProvider.getProChoiceMarketCards()
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { [weak self] highlightMarkets in
                var mappedHighlightMarket: [ImageHighlightedContent<Market>] = []
                for highlightMarket in highlightMarkets {
                    let mappedMarket = ServiceProviderModelMapper.market(fromServiceProviderMarket: highlightMarket.content)

                    mappedHighlightMarket.append(ImageHighlightedContent<Market>(
                        content: mappedMarket,
                        imageURLString: highlightMarket.imageURL,
                        promotedDetailsCount: highlightMarket.promotedChildCount))
                }
                self?.highlightedMarkets = mappedHighlightMarket
                self?.refreshPublisher.send()
            }

        self.addCancellable(cancellable)

    }

    func fetchHeroMatches() {

        let cancellable = Env.servicesProvider.getHeroCardEvents()
            .receive(on: DispatchQueue.main)
            .map(ServiceProviderModelMapper.matches(fromEvents:))
            .compactMap({ $0 })
            .sink(receiveCompletion: { _ in

            }, receiveValue: { [weak self] heroMatches in
                self?.heroMatches = heroMatches
                self?.refreshPublisher.send()
            })

        self.addCancellable(cancellable)

    }

    func fetchPromotedSports() {

        let cancellable = Env.servicesProvider.getPromotedSports()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                //
            } receiveValue: { [weak self] promotedSports in
                self?.promotedSports = promotedSports
                self?.refreshPublisher.send()
            }

        self.addCancellable(cancellable)

    }

    func fetchMatchesForPromotedSport(_ promotedSport: PromotedSport) {

        let publishers = promotedSport.marketGroups.map({ Env.servicesProvider.getEventsForEventGroup(withId: $0.id) })

        let mergeManyCancellable = Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                //
            } receiveValue: { [weak self] eventGroups in
                let matches = eventGroups.flatMap(\.events).prefix(20).map(ServiceProviderModelMapper.match(fromEvent:)).compactMap({ $0 })
                self?.promotedSportsMatches[promotedSport.id] = matches
                self?.refreshPublisher.send()
            }

        self.addCancellable(mergeManyCancellable)

    }

    private func fetchTopCompetitions() {

        let cancellable = Env.servicesProvider.getTopCompetitions()
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("TopCompetitionsLineCellViewModel getTopCompetitionsIdentifier error: \(error)")
                }
            }, receiveValue: { [weak self] topCompetitions in
                let convertedCompetitions = self?.convertTopCompetitions(topCompetitions) ?? []

                let topCompetitionIds = convertedCompetitions.map { $0.id }
                Env.favoritesManager.topCompetitionIds = topCompetitionIds

                if let featuredCompetitionId = Env.businessSettingsSocket.clientSettings.featuredCompetition?.id {

                    if convertedCompetitions.contains(where: {
                        $0.id == featuredCompetitionId
                    }) {
                        let filteredConvertedCOmpetitions = convertedCompetitions.filter( {
                            $0.id != featuredCompetitionId
                        })

                        self?.topCompetitionsLineCellViewModel = TopCompetitionsLineCellViewModel(topCompetitions: filteredConvertedCOmpetitions)
                    }
                    else {
                        self?.topCompetitionsLineCellViewModel = TopCompetitionsLineCellViewModel(topCompetitions: convertedCompetitions)
                    }
                }
                else {
                    self?.topCompetitionsLineCellViewModel = TopCompetitionsLineCellViewModel(topCompetitions: convertedCompetitions)
                }

                self?.refreshPublisher.send()
            })

        self.addCancellable(cancellable)

    }

    private func processTopCompetitions(topCompetitions: [TopCompetitionPointer]) -> [String: [String]] {
        var competitionsIdentifiers: [String: [String]] = [:]
        for topCompetition in topCompetitions {
            let competitionComponents = topCompetition.competitionId.components(separatedBy: "/")
            let competitionName = competitionComponents[competitionComponents.count - 2].lowercased()
            if let competitionId = competitionComponents.last {
                if let topCompetition = competitionsIdentifiers[competitionName] {
                    if !topCompetition.contains(where: {
                        $0 == competitionId
                    }) {
                        competitionsIdentifiers[competitionName]?.append(competitionId)
                    }

                }
                else {
                    competitionsIdentifiers[competitionName] = [competitionId]
                }
            }
        }
        return competitionsIdentifiers
    }

    private func convertTopCompetitions(_ topCompetitions: [TopCompetition]) -> [TopCompetitionItemCellViewModel] {
        return topCompetitions.map { pointer -> TopCompetitionItemCellViewModel? in
            let mappedSport = ServiceProviderModelMapper.sport(fromServiceProviderSportType: pointer.sportType)
            if let pointerCountry = pointer.country {
                let mappedCountry = ServiceProviderModelMapper.country(fromServiceProviderCountry: pointerCountry)
                return TopCompetitionItemCellViewModel(id: pointer.id,
                                                       name: pointer.name,
                                                       sport: mappedSport,
                                                       country: mappedCountry)
            }
            return nil
        }
        .compactMap({ $0 })

    }

    func fetchHighlightedLiveMatches() {

        let homeLiveEventsCount = Env.businessSettingsSocket.clientSettings.homeLiveEventsCount

        self.highlightedLiveMatches = []

        var userId: String?

        if let loggedUserId = Env.userSessionStore.userProfilePublisher.value?.userIdentifier {
            userId = loggedUserId
        }

        let cancellable = Env.servicesProvider.getHighlightedLiveEvents(eventCount: homeLiveEventsCount, userId: userId)
            .map { highlightedLiveEvents in
                return highlightedLiveEvents.compactMap(ServiceProviderModelMapper.match(fromEvent:))
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("fetchHighlightedLiveMatches getHighlightedLiveEvents error: \(error)")
                }
            } receiveValue: { [weak self] liveEvents in
                self?.highlightedLiveMatches = liveEvents
                self?.refreshPublisher.send()

                let eventsIds = liveEvents.compactMap({ return $0.trackableReference })
                self?.waitUserToTrackImpressionForEvents(eventsIds: eventsIds)
            }

        self.addCancellable(cancellable)
    }

    private func waitUserToTrackImpressionForEvents(eventsIds: [String]) {
        self.pendingUserTrackRequest?.cancel()

        self.pendingUserTrackRequest = Env.userSessionStore.userProfilePublisher
            .compactMap({ $0?.userIdentifier })
            .first()
            .sink { [weak self] userIdentifier in
                self?.trackImpressionForEvents(eventsIds: eventsIds, userId: userIdentifier)
            }
    }

    private func trackImpressionForEvents(eventsIds: [String], userId: String) {

        Env.servicesProvider.trackEvent(.impressionsEvents(eventsIds: eventsIds), userIdentifer: userId)
            .sink { _ in
                //
            } receiveValue: {
                //
            }
            .store(in: &self.cancellables)

    }

    private func promotedMatch(forSection section: Int, forIndex index: Int) -> Match? {
        let croppedSection = section - self.fixedSections
        if let promotedSportId = self.promotedSports[safe: croppedSection]?.id,
           let matchesForSport = self.promotedSportsMatches[promotedSportId],
           let match = matchesForSport[safe: index] {
            return match
        }
        return nil
    }

    // ALERT: The data comes from Suggested bets
    // but the UI shown to the user is from old FeaturedTips
    func fetchPromotedBetslips() {
        let userIdentifier = Env.userSessionStore.userProfilePublisher.value?.userIdentifier
        let cancellable = Env.servicesProvider.getPromotedBetslips(userId: userIdentifier)
            .map(ServiceProviderModelMapper.suggestedBetslips(fromPromotedBetslips:))
            .receive(on: DispatchQueue.main)
            .sink { _ in
                //
            } receiveValue: { [weak self] suggestedBetslips in
                self?.suggestedBetslips = suggestedBetslips
                self?.refreshPublisher.send()
            }

        self.addCancellable(cancellable)
    }

}

extension CMSManagedHomeViewTemplateDataSource {

    private func addCancellable(_ cancellable: AnyCancellable) {
        self.cancellablesLock.lock()
        self.cancellables.insert(cancellable)
        self.cancellablesLock.unlock()
    }

    private func removeCancellable(_ cancellable: AnyCancellable) {
        self.cancellablesLock.lock()
        self.cancellables.remove(cancellable)
        self.cancellablesLock.unlock()
    }
}

extension CMSManagedHomeViewTemplateDataSource: HomeViewTemplateDataSource {

    var refreshRequestedPublisher: AnyPublisher<Void, Never> {
        return self.refreshPublisher
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func refresh() {
        self.fetchHomeTemplate()
    }

    func numberOfSections() -> Int {
        var sections = self.fixedSections
        sections += self.promotedSports.count
        return sections
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {
        guard let contentType = self.contentType(forSection: section) else {
            return 0
        }

        switch contentType {
        case .alertBannersLine:
            return self.alertsArray.isEmpty ? 0 : 1
        case .bannerLine:
            return self.bannersLineViewModel == nil ? 0 : 1
        case .heroCard:
            return self.heroMatches.count
        case .quickSwipeStack:
            return self.quickSwipeStackMatches.isEmpty ? 0 : 1
        case .promotionalStories:
            return self.storiesLineViewModel == nil ? 0 : 1
        case .makeOwnBetCallToAction:
            return self.shouldShowOwnBetCallToAction ? 1 : 0
        case .highlightedMatches:
            return self.highlightsMatchesNumberOfRows()
        case .highlightedBoostedOddsMatches:
            return self.highlightsBoostedOddsMatchesNumberOfRows()
        case .highlightedLiveMatches:
            return self.highlightedLiveMatches.count
        case .highlightedMarketProChoices:
            return self.highlightedMarketProChoicesNumberOfRows()
        case .promotedBetslips:
            return self.suggestedBetslips.isEmpty ? 0 : 1
        case .topCompetitionsShortcuts:
            if let featuredCompetitionId = Env.businessSettingsSocket.clientSettings.featuredCompetition?.id {
                return !self.topCompetitionsLineCellViewModel.isEmpty ? 2 : 1
            }
            else {
                return !self.topCompetitionsLineCellViewModel.isEmpty ? 1 : 0
            }
        case .promotedSportSection:
            let croppedSection = section - self.fixedSections
            if let promotedSportId = self.promotedSports[safe: croppedSection]?.id,
               let matchesForSport = self.promotedSportsMatches[promotedSportId] {
                return matchesForSport.count
            }
            return 0
        default:
            return 0
        }
    }

    func title(forSection section: Int) -> String? {
        guard let contentType = contentType(forSection: section) else {
            return nil
        }

        switch contentType {
        case .highlightedMatches:
            return localized("highlights")
        case .highlightedBoostedOddsMatches:
            return localized("boosted_section_header")
        case .highlightedLiveMatches:
            return localized("live")
        case .highlightedMarketProChoices:
            return localized("highlights_pro_choices_section_header")
        case .promotedBetslips:
            return self.suggestedBetslips.isNotEmpty ? localized("suggested_bets") : nil
        case .topCompetitionsShortcuts:
            return localized("top_competitions")
        case .promotedSportSection:
            let croppedSection = section - self.fixedSections
            if let promotedSportName = self.promotedSports[safe: croppedSection]?.name {
                return promotedSportName
            }
            return nil
        default:
            return nil
        }
    }

    func iconName(forSection section: Int) -> String? {
        guard let contentType = contentType(forSection: section) else {
            return nil
        }

        switch contentType {
        case .highlightedMatches:
            return "pin_icon"
        case .highlightedBoostedOddsMatches:
            return "boosted_odd_icon"
        case .highlightedLiveMatches:
            return "tabbar_live_icon"
        case .highlightedMarketProChoices:
            return "pro_choices_icon"
        case .topCompetitionsShortcuts:
            return "trophy_icon"
        case .promotedBetslips:
            return "suggested_bet_icon"
        case .promotedSportSection:
            let activeSports = Env.sportsStore.getActiveSports()
            let croppedSection = section - self.fixedSections

            // NOTE: IDs don't match from regular and promoted same sport
            if let promotedSport = self.promotedSports[safe: croppedSection] {
                let currentSport = activeSports.first { promotedSport.name.contains($0.name) }
                return currentSport?.id
            }
            return nil
        default:
            return nil
        }
    }

    func shouldShowTitle(forSection section: Int) -> Bool {
        guard let contentType = contentType(forSection: section) else {
            return false
        }

        switch contentType {
        case .highlightedMatches:
            return self.highlightsMatchesNumberOfRows() > 0
        case .highlightedBoostedOddsMatches:
            return self.highlightsBoostedOddsMatchesNumberOfRows() > 0
        case .highlightedMarketProChoices:
            return self.highlightedMarketProChoicesNumberOfRows() > 0
        case .highlightedLiveMatches:
            return self.highlightedLiveMatches.isNotEmpty
        case .promotedBetslips:
            return self.suggestedBetslips.isNotEmpty
        case .topCompetitionsShortcuts:
            return !self.topCompetitionsLineCellViewModel.isEmpty
        case .promotedSportSection:
            let croppedSection = section - self.fixedSections
            if let promotedSportId = self.promotedSports[safe: croppedSection]?.id,
               let matchesForSport = self.promotedSportsMatches[promotedSportId] {
                return matchesForSport.isNotEmpty
            }
            return false
        default:
            return false
        }
    }

    func shouldShowFooter(forSection section: Int) -> Bool {
        return false
    }

    func contentType(forSection section: Int) -> HomeViewModel.Content? {

        // Check if the section index is within the bounds of the array
        if let sectionType = self.contentTypes[safe: section] {
            return sectionType
        }

        let croppedSection = section - self.fixedSections
        if let promotedSportId = self.promotedSports[safe: croppedSection]?.id,
           let matchesForSport = self.promotedSportsMatches[promotedSportId],
           matchesForSport.isNotEmpty {
            return .promotedSportSection
        }

        return nil
    }

    // Content type ViewModels methods
    func contentViewModel(forSection section: Int, forIndex index: Int) -> Any? {
        guard let contentType = self.contentType(forSection: section) else { return nil }
        
        switch contentType {
        case .highlightedMatches:
            return highlightedMatchesViewModel(forIndex: index)
        case .highlightedBoostedOddsMatches:
            return highlightedBoostedMatchesViewModel(forIndex: index)
        case .highlightedMarketProChoices:
            return highlightedMarketViewModel(forIndex: index)
        default:
            return nil
        }
    }

    func alertsArrayViewModel() -> [ActivationAlert] {
        return self.alertsArray
    }

    func bannerLineViewModel() -> BannerLineCellViewModel? {
        return self.bannersLineViewModel
    }

    func storyLineViewModel() -> StoriesLineCellViewModel? {
        return self.storiesLineViewModel
    }

    func setStoryLineViewModel(viewModel: StoriesLineCellViewModel) {
        self.storiesLineViewModel = viewModel
    }

    func favoriteMatch(forIndex index: Int) -> Match? {
        return nil
    }

    func featuredTipLineViewModel() -> FeaturedTipLineViewModel? {
        if self.suggestedBetslips.isEmpty {
            return nil
        }

        if let featuredTipLineViewModel = self.cachedFeaturedTipLineViewModel {
            return featuredTipLineViewModel
        }
        else {
            self.cachedFeaturedTipLineViewModel = FeaturedTipLineViewModel(suggestedBetslip: self.suggestedBetslips)
            return self.cachedFeaturedTipLineViewModel
        }

    }

    func suggestedBetLineViewModel() -> SuggestedBetLineViewModel? {
        nil
    }

    func matchStatsViewModel(forMatch match: Match) -> MatchStatsViewModel? {
        return nil
    }

    func quickSwipeStackViewModel() -> QuickSwipeStackCellViewModel? {
        if let quickSwipeStackCellViewModel = self.quickSwipeStackCellViewModel {
            return quickSwipeStackCellViewModel
        }
        else {
            let matches = self.quickSwipeStackMatches
            self.quickSwipeStackCellViewModel = QuickSwipeStackCellViewModel(title: nil, matches: matches)
            return self.quickSwipeStackCellViewModel!
        }

    }

    func heroCardMatchViewModel(forIndex index: Int) -> MatchWidgetCellViewModel? {

        if let match = self.heroMatches[safe: index] {
            let id = match.id
            if let matchWidgetCellViewModel = self.heroCardWidgetCellViewModelCache[id] {
                return matchWidgetCellViewModel
            }
            else {
                let matchWidgetCellViewModel = MatchWidgetCellViewModel(match: match, matchWidgetType: .topImage)
                self.heroCardWidgetCellViewModelCache[id] = matchWidgetCellViewModel
                return matchWidgetCellViewModel
            }
        }
        return nil
    }

    // Highlights
    //
    func highlightedMatchViewModel(forSection section: Int, forIndex index: Int) -> MatchWidgetContainerTableViewModel? {
        guard let contentType = self.contentType(forSection: section) else { return nil }
        
        switch contentType {
        case .highlightedMatches:
            return highlightedMatchesViewModel(forIndex: index)
        case .highlightedBoostedOddsMatches:
            return highlightedBoostedMatchesViewModel(forIndex: index)
        default:
            return nil
        }
    }

    func highlightedMarket(forIndex index: Int) -> MarketWidgetContainerTableViewModel? {
        return highlightedMarketViewModel(forIndex: index)
    }

    //
    // Live match
    func highlightedLiveMatchLineTableCellViewModel(forSection section: Int, forIndex index: Int) -> MatchLineTableCellViewModel? {

        guard
            let match = self.highlightedLiveMatches[safe: index]
        else {
            return nil
        }

        if let matchLineTableCellViewModel = self.highlightedLiveMatchLineCellViewModelCache[match.id] {
            return matchLineTableCellViewModel
        }
        else {
            let matchLineTableCellViewModel = MatchLineTableCellViewModel(match: match, status: .live)
            self.highlightedLiveMatchLineCellViewModelCache[match.id] = matchLineTableCellViewModel
            return matchLineTableCellViewModel
        }

    }

    func matchLineTableCellViewModel(forSection section: Int, forIndex index: Int) -> MatchLineTableCellViewModel? {
        var matchId: String?
        var match: Match?

        switch section {
        case 0..<self.fixedSections:
            ()
        default: // The remaining sections, each section for a promoted sport id
            match = self.promotedMatch(forSection: section, forIndex: index)
            matchId = match?.id
        }

        guard
            let matchIdValue = matchId
        else {
            return nil
        }

        if let matchLineTableCellViewModel = self.matchLineTableCellViewModelCache[matchIdValue] {
            return matchLineTableCellViewModel
        }
        else if let matchValue = match {
            let matchLineTableCellViewModel = MatchLineTableCellViewModel(match: matchValue, status: .unknown)
            self.matchLineTableCellViewModelCache[matchIdValue] = matchLineTableCellViewModel
            return matchLineTableCellViewModel
        }
        return nil
    }

    func topCompetitionsLineCellViewModel(forSection section: Int) -> TopCompetitionsLineCellViewModel? {
        return self.topCompetitionsLineCellViewModel
    }

    func videoNewsLineViewModel() -> VideoPreviewLineCellViewModel? {
        return nil
    }

}

extension CMSManagedHomeViewTemplateDataSource {

    static func appendToReadInstaStoriesArray(_ newStory: String) {
        let key = "readInstaStoriesArray"
        var existingStories = UserDefaults.standard.stringArray(forKey: key) ?? []
        existingStories.append(newStory)
        UserDefaults.standard.set(existingStories, forKey: key)
    }

    static func checkStoryInReadInstaStoriesArray(_ storyToCheck: String) -> Bool {
        let key = "readInstaStoriesArray"
        let existingStories = UserDefaults.standard.stringArray(forKey: key) ?? []
        return existingStories.contains(storyToCheck)
    }

}

extension CMSManagedHomeViewTemplateDataSource {
    // MARK: - Presentation Mode Helpers
    private func presentationMode(for contentType: HomeViewModel.Content) -> HighlightsPresentationMode? {
        return highlightsPresentationModes[contentType]
    }
    
    // MARK: - Highlights ViewModels
    func highlightedMatchesViewModel(forIndex index: Int) -> MatchWidgetContainerTableViewModel? {
        guard let mode = highlightsPresentationModes[.highlightedMatches] else { return nil }
        
        switch mode {
        case .onePerLine:
            if let match = highlightsVisualImageMatches[safe: index] {
                return createSingleMatchViewModel(match, withMixMatchCheck: true)
            } else if let match = highlightsVisualImageOutrights[safe: index - highlightsVisualImageMatches.count] {
                return createSingleMatchViewModel(match, type: .topImageOutright)
            }
            return nil
            
        case .multiplesPerLineByType:
            if index == 0 && !highlightsVisualImageMatches.isEmpty {
                return createHorizontalMatchesViewModel(highlightsVisualImageMatches, withMixMatchCheck: true)
            } else if index == 1 && !highlightsVisualImageOutrights.isEmpty {
                return createHorizontalMatchesViewModel(highlightsVisualImageOutrights, type: .topImageOutright)
            }
            return nil
        }
    }
    
    func highlightedBoostedMatchesViewModel(forIndex index: Int) -> MatchWidgetContainerTableViewModel? {
        guard let mode = highlightsPresentationModes[.highlightedBoostedOddsMatches] else { return nil }
        
        switch mode {
        case .onePerLine:
            guard let match = highlightsBoostedMatches[safe: index] else { return nil }
            return createSingleMatchViewModel(match, type: .boosted)
            
        case .multiplesPerLineByType:
            if index == 0 && !highlightsBoostedMatches.isEmpty {
                return createHorizontalMatchesViewModel(highlightsBoostedMatches, type: .boosted)
            }
            return nil
        }
    }
    
    func highlightedMarketViewModel(forIndex index: Int) -> MarketWidgetContainerTableViewModel? {
        guard let mode = highlightsPresentationModes[.highlightedMarketProChoices] else { return nil }
        
        switch mode {
        case .onePerLine:
            guard let market = highlightedMarkets[safe: index] else { return nil }
            return createSingleMarketViewModel(market)
            
        case .multiplesPerLineByType:
            if index == 0 && !highlightedMarkets.isEmpty {
                return createHorizontalMarketsViewModel(highlightedMarkets)
            }
            return nil
        }
    }
    
    // MARK: - ViewModel Creation Helpers
    private func createSingleMatchViewModel(_ match: Match, type: MatchWidgetType? = nil, withMixMatchCheck: Bool = false) -> MatchWidgetContainerTableViewModel {
        var widgetType = type ?? .topImage
        
        if withMixMatchCheck && (match.markets.first?.customBetAvailable ?? false) && TargetVariables.hasFeatureEnabled(feature: .mixMatch) {
            widgetType = .topImageWithMixMatch
        }
        
        let id = match.id + widgetType.rawValue
        
        if let cached = matchWidgetContainerTableViewModelCache[id] {
            return cached
        }
        
        let viewModel = MatchWidgetContainerTableViewModel(
            singleCardsViewModel: MatchWidgetCellViewModel(match: match, matchWidgetType: widgetType)
        )
        matchWidgetContainerTableViewModelCache[id] = viewModel
        return viewModel
    }
    
    private func createHorizontalMatchesViewModel(_ matches: [Match], type: MatchWidgetType? = nil, withMixMatchCheck: Bool = false) -> MatchWidgetContainerTableViewModel {
        let viewModels = matches.map { match -> MatchWidgetCellViewModel in
            var widgetType = type ?? .topImage
            if withMixMatchCheck && (match.markets.first?.customBetAvailable ?? false) && TargetVariables.hasFeatureEnabled(feature: .mixMatch) {
                widgetType = .topImageWithMixMatch
            }
            return MatchWidgetCellViewModel(match: match, matchWidgetType: widgetType)
        }
        
        let ids = matches.map { $0.id + (type?.rawValue ?? "") }.joined(separator: "-")
        
        if let cached = matchWidgetContainerTableViewModelCache[ids] {
            return cached
        }
        
        let viewModel = MatchWidgetContainerTableViewModel(cardsViewModels: viewModels)
        matchWidgetContainerTableViewModelCache[ids] = viewModel
        return viewModel
    }
    
    private func createSingleMarketViewModel(_ market: ImageHighlightedContent<Market>) -> MarketWidgetContainerTableViewModel {
        let id = market.content.id
        
        if let cached = marketWidgetContainerTableViewModelCache[id] {
            return cached
        }
        
        let viewModel = MarketWidgetContainerTableViewModel(
            singleCardsViewModel: MarketWidgetCellViewModel(highlightedMarket: market)
        )
        marketWidgetContainerTableViewModelCache[id] = viewModel
        return viewModel
    }
    
    private func createHorizontalMarketsViewModel(_ markets: [ImageHighlightedContent<Market>]) -> MarketWidgetContainerTableViewModel {
        let ids = markets.map(\.content.id).joined(separator: "-")
        
        if let cached = marketWidgetContainerTableViewModelCache[ids] {
            return cached
        }
        
        let viewModels = markets.map { MarketWidgetCellViewModel(highlightedMarket: $0) }
        let viewModel = MarketWidgetContainerTableViewModel(cardsViewModels: viewModels)
        marketWidgetContainerTableViewModelCache[ids] = viewModel
        return viewModel
    }
}
