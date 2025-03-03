//
//  DummyWidgetShowcaseHomeViewTemplateDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/05/2023.
//

import Foundation
import Combine
import ServicesProvider

class DummyWidgetShowcaseHomeViewTemplateDataSource {

    // Define the array mapping sections to content types
    private var contentTypes: [HomeViewModel.Content] {
        switch TargetVariables.homeTemplateBuilder {
        case .backendDynamic, .clientBackendManaged, .cmsManaged:
            return []
        case .dummyWidgetShowcase(widgets: let widgets):
            return widgets
        }
    }

    private var fixedSections: Int {
        return self.contentTypes.count
    }

    private var refreshPublisher = PassthroughSubject<Void, Never>.init()

    // User Alert
    private var alertsArray: [ActivationAlert] = []

    // Video News
    private lazy var videoNewsLineCellViewModel: VideoPreviewLineCellViewModel = {
        // Create mock video content
        let mockVideos: [VideoItemFeedContent] = [
            VideoItemFeedContent(
                title: "Madrid Derby Preview",
                description: "Real Madrid vs Atletico",
                imageURL: "https://img.youtube.com/vi/qmkOkbpxQ7M/maxresdefault.jpg",
                streamURL: "https://www.youtube.com/embed/qmkOkbpxQ7M"
            ),
            VideoItemFeedContent(
                title: "Al-Nassr Match Highlights",
                description: "Saudi Pro League Action",
                imageURL: "https://img.youtube.com/vi/WZ9hhG1Mh_Y/maxresdefault.jpg",
                streamURL: "https://www.youtube.com/embed/WZ9hhG1Mh_Y"
            ),
            VideoItemFeedContent(
                title: "Cholet vs Strasbourg",
                description: "Betclic Elite Basketball",
                imageURL: "https://img.youtube.com/vi/dg9kzzGQusA/maxresdefault.jpg",
                streamURL: "https://www.youtube.com/embed/dg9kzzGQusA"
            ),
            VideoItemFeedContent(
                title: "Joshua vs Povetkin",
                description: "Full Fight Highlights",
                imageURL: "https://img.youtube.com/vi/kykzl5WbZMA/maxresdefault.jpg",
                streamURL: "https://www.youtube.com/embed/kykzl5WbZMA"
            )
        ]

        return VideoPreviewLineCellViewModel(title: "Video Highlights", videoItemFeedContents: mockVideos)
    }()

    // Banners
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
                                                              marketId: banner.marketId,
                                                              location: banner.location, specialAction: banner.specialAction)
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
                    var readStory = Self.checkStoryInReadInstaStoriesArray(promotionalStory.id)
                    let storyViewModel = StoriesItemCellViewModel(id: promotionalStory.id,
                                                                  imageName: promotionalStory.imageUrl,
                                                                  title: promotionalStory.title,
                                                                  link: promotionalStory.linkUrl,
                                                                  contentString: promotionalStory.bodyText,
                                                                  read: readStory)

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
    private var highlightsPresentationMode = HighlightsPresentationMode.multiplesPerLineByType

    private var highlightsVisualImageMatches: [Match]  = []
    private var highlightsVisualImageOutrights: [Match] = []
    private var highlightsBoostedMatches: [Match] = []

    //
    //Hero card
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

    var highlightedLiveMatchLineTableCellViewModelCache: [String: MatchLineTableCellViewModel] = [:]

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
        self.refreshData()

        // Banners are associated with profile publisher
        let profileCancellable = Env.userSessionStore.userProfilePublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchBanners()
            }

        self.addCancellable(profileCancellable)

        // Alerts are associated with KYC publisher
        self.fetchAlerts()
    }

    func refreshData() {

        self.matchWidgetContainerTableViewModelCache = [:]
        self.matchWidgetCellViewModelCache = [:]
        self.matchLineTableCellViewModelCache = [:]
        self.matchLineTableCellViewModelCache = [:]
        self.marketWidgetContainerTableViewModelCache = [:]
        self.heroCardWidgetCellViewModelCache = [:]

        self.suggestedBetslips = []
        self.highlightedMarkets = []

        self.cachedFeaturedTipLineViewModel = nil

        self.highlightedLiveMatchLineTableCellViewModelCache = [:]

        self.fetchQuickSwipeMatches()
        self.fetchHighlightMatches()
        self.fetchHighlightMarkets()

        self.fetchPromotedSports()
        self.fetchPromotedBetslips()
        self.fetchPromotionalStories()
        self.fetchTopCompetitions()
        self.fetchHighlightedLiveMatches()

        self.fetchHeroMatches()
    }


    // User alerts
    func fetchAlerts() {

        let alertsCancellable = Env.userSessionStore.userKnowYourCustomerStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] kycStatus in
                if kycStatus == .request {
                    let uploadDocumentsAlertData = ActivationAlert(title: localized("document_validation_required"),
                                                                   description: localized("document_validation_required_description"),
                                                                   linkLabel: localized("complete_your_verification"),
                                                                   alertType: .documents)
                    self?.alertsArray = [uploadDocumentsAlertData]
                }
                else {
                    self?.alertsArray = []
                }
                self?.refreshPublisher.send()
            })

        self.addCancellable(alertsCancellable)

    }

    // User alerts
    func fetchBanners() {
        let cancellable = Env.servicesProvider.getPromotionalTopBanners()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                //
            } receiveValue: { [weak self] (promotionalBanners: [PromotionalBanner]) in
                guard let self = self else { return }

                var displayBanners = promotionalBanners

                if Env.userSessionStore.isUserLogged() {
                    displayBanners = displayBanners.filter { $0.bannerDisplay == "LOGGEDIN" }
                } else {
                    displayBanners = displayBanners.filter { $0.bannerDisplay == "LOGGEDOFF" }
                }
                self.banners = displayBanners.map { promotionalBanner in
                    BannerInfo(
                        type: "",
                        id: promotionalBanner.id,
                        matchId: nil,
                        imageURL: promotionalBanner.imageURL,
                        priorityOrder: nil,
                        marketId: nil,
                        location: promotionalBanner.location,
                        specialAction: promotionalBanner.specialAction
                    )
                }
                self.refreshPublisher.send()
            }

        // Store the cancellable in a thread-safe manner
        self.addCancellable(cancellable)
    }

    func fetchPromotionalStories() {

        let cancellable = Env.servicesProvider.getPromotionalTopStories()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                //
            } receiveValue: { [weak self] promotionalStories in
                let mappedPromotionalStories = promotionalStories.map({ promotionalStory in
                    let promotionalStory = ServiceProviderModelMapper.promotionalStory(fromPromotionalStory: promotionalStory)
                    return promotionalStory
                })
                self?.promotionalStories = mappedPromotionalStories
                self?.refreshPublisher.send()
            }

        self.addCancellable(cancellable)
    }

    func fetchQuickSwipeMatches() {
        let cancellable = Env.servicesProvider.getPromotionalSlidingTopEvents()
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
        switch self.highlightsPresentationMode {
        case .onePerLine:
            return self.highlightsVisualImageMatches.count +
                self.highlightsVisualImageOutrights.count

        case .multiplesPerLineByType:
            return (self.highlightsVisualImageMatches.isNotEmpty ? 1 : 0) +
                (self.highlightsVisualImageOutrights.isNotEmpty ? 1 : 0)
        }
    }

    func highlightsBoostedOddsMatchesNumberOfRows() -> Int {
        switch self.highlightsPresentationMode {
        case .onePerLine:
            return self.highlightsBoostedMatches.count
        case .multiplesPerLineByType:
            return self.highlightsBoostedMatches.isNotEmpty ? 1 : 0
        }
    }

    func highlightedMarketProChoicesNumberOfRows() -> Int {
        switch self.highlightsPresentationMode {
        case .onePerLine:
            return self.highlightedMarkets.count
        case .multiplesPerLineByType:
            return self.highlightedMarkets.isNotEmpty ? 1 : 0
        }
    }

    func fetchHighlightMatches() {

        let imageMatches = Env.servicesProvider.getTopImageCardEvents()
            .receive(on: DispatchQueue.main)
            .map(ServiceProviderModelMapper.matches(fromEvents:))
            .replaceError(with: [])

        let boostedMatches = Env.servicesProvider.getBoostedOddsEvents()
            .receive(on: DispatchQueue.main)
            .map(ServiceProviderModelMapper.matches(fromEvents:))
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
            .sink { completion in

            } receiveValue: { [weak self] highlightMarkets in
                let markets = highlightMarkets.map(\.market)
                let mappedMarkets = ServiceProviderModelMapper.markets(fromServiceProviderMarkets: markets)

                var mappedHighlightMarket: [ImageHighlightedContent<Market>] = []

                for highlightMarket in highlightMarkets {
                    let mappedMarket = ServiceProviderModelMapper.market(fromServiceProviderMarket: highlightMarket.market)

                    mappedHighlightMarket.append(ImageHighlightedContent<Market>(
                        content: mappedMarket,
                        imageURLString: highlightMarket.promotionImageURl,
                        promotedDetailsCount: highlightMarket.enabledSelectionsCount))
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

        var homeLiveEventsCount = Env.businessSettingsSocket.clientSettings.homeLiveEventsCount

        self.highlightedLiveMatches = []

        var userId: String? = nil

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

extension DummyWidgetShowcaseHomeViewTemplateDataSource {

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

extension DummyWidgetShowcaseHomeViewTemplateDataSource: HomeViewTemplateDataSource {

    var refreshRequestedPublisher: AnyPublisher<Void, Never> {
        return self.refreshPublisher
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func refresh() {
        self.refreshData()
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
        case .userProfile:
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
        case .featuredTips:
            return self.suggestedBetslips.isEmpty ? 0 : 1
        case .topCompetitionsShortcuts:
            if let featuredCompetitionId = Env.businessSettingsSocket.clientSettings.featuredCompetition?.id {
                return !self.topCompetitionsLineCellViewModel.isEmpty ? 2 : 1
            } else {
                return !self.topCompetitionsLineCellViewModel.isEmpty ? 1 : 0
            }
        case .videoNewsLine:
            return self.videoNewsLineCellViewModel.numberOfItems() > 0 ? 1 : 0
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
        case .featuredTips:
            return self.suggestedBetslips.isNotEmpty ? localized("suggested_bets") : nil
        case .topCompetitionsShortcuts:
            return localized("top_competitions")
        case .videoNewsLine:
            return self.videoNewsLineCellViewModel.titleSection
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
        case .featuredTips:
            return "suggested_bet_icon"
        case .videoNewsLine:
            return "video_small_icon"
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
        case .featuredTips:
            return self.suggestedBetslips.isNotEmpty
        case .topCompetitionsShortcuts:
            return !self.topCompetitionsLineCellViewModel.isEmpty
        case .videoNewsLine:
            return self.videoNewsLineCellViewModel.numberOfItems() > 0
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

    func sportGroupViewModel(forSection section: Int) -> SportGroupViewModel? {
        return nil
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
        switch self.highlightsPresentationMode {
        case .onePerLine:
            return self.highlightedMatchViewModelVertical(forSection: section, forIndex: index)
        case .multiplesPerLineByType:
            return self.highlightedMatchViewModelHorizontal(forSection: section, forIndex: index)
        }
    }

    private func highlightedMatchViewModelVertical(forSection section: Int, forIndex index: Int) -> MatchWidgetContainerTableViewModel? {
        // Each highlight match has it's own line
        guard
            let contentType = self.contentType(forSection: section)
        else {
            return nil
        }
        let highlightsOutrightsMatchesIndex = index-self.highlightsVisualImageMatches.count

        switch contentType {
        case .highlightedMatches:
            if let match = self.highlightsVisualImageMatches[safe: index] {
                var type = MatchWidgetType.topImage

                if match.markets.first?.customBetAvailable ?? false {
                    type = .topImageWithMixMatch
                }

                let id = match.id + type.rawValue

                if let matchWidgetContainerTableViewModel = self.matchWidgetContainerTableViewModelCache[id] {
                    return matchWidgetContainerTableViewModel
                }
                else {
                    let matchWidgetContainerTableViewModel = MatchWidgetContainerTableViewModel.init(singleCardsViewModel: MatchWidgetCellViewModel(match: match, matchWidgetType: type))
                    self.matchWidgetContainerTableViewModelCache[id] = matchWidgetContainerTableViewModel
                    return matchWidgetContainerTableViewModel
                }
            }
            else if let match = self.highlightsVisualImageOutrights[safe: highlightsOutrightsMatchesIndex] {
                let id = match.id + MatchWidgetType.topImageOutright.rawValue
                if let matchWidgetContainerTableViewModel = self.matchWidgetContainerTableViewModelCache[id] {
                    return matchWidgetContainerTableViewModel
                }
                else {
                    let matchWidgetContainerTableViewModel = MatchWidgetContainerTableViewModel.init(singleCardsViewModel: MatchWidgetCellViewModel(match: match, matchWidgetType: .topImageOutright))
                    self.matchWidgetContainerTableViewModelCache[id] = matchWidgetContainerTableViewModel
                    return matchWidgetContainerTableViewModel
                }
            }

        case .highlightedBoostedOddsMatches:
            if let match = self.highlightsBoostedMatches[safe: index] {
                let id = match.id + MatchWidgetType.boosted.rawValue
                if let matchWidgetContainerTableViewModel = self.matchWidgetContainerTableViewModelCache[id] {
                    return matchWidgetContainerTableViewModel
                }
                else {
                    let matchWidgetContainerTableViewModel = MatchWidgetContainerTableViewModel.init(singleCardsViewModel: MatchWidgetCellViewModel(match: match, matchWidgetType: .boosted))
                    self.matchWidgetContainerTableViewModelCache[id] = matchWidgetContainerTableViewModel
                    return matchWidgetContainerTableViewModel
                }
            }
        default:
            return nil
        }

        return nil
    }

    private func highlightedMatchViewModelHorizontal(forSection section: Int, forIndex index: Int) -> MatchWidgetContainerTableViewModel? {
        // There is a line for each highlight type (image, boosted, outrightImage)
        // Each match card for each type will show as a horizontal scroll
        guard
            let contentType = self.contentType(forSection: section)
        else {
            return nil
        }

        var ids = ""
        var viewModels: [MatchWidgetCellViewModel] = []
        switch (index, contentType) {
        case (0, .highlightedMatches):
            ids = self.highlightsVisualImageMatches.map { match in
                var type = MatchWidgetType.topImage
                if match.markets.first?.customBetAvailable ?? false {
                    type = .topImageWithMixMatch
                }
                return match.id + type.rawValue
            }.joined(separator: "-")

            viewModels = self.highlightsVisualImageMatches.map { match in
                var type = MatchWidgetType.topImage
                if match.markets.first?.customBetAvailable ?? false {
                    type = .topImageWithMixMatch
                }
                return MatchWidgetCellViewModel(match: match, matchWidgetType: type)
            }

        case (1, .highlightedMatches):
            var type = MatchWidgetType.topImageOutright
            ids = self.highlightsVisualImageOutrights.map { $0.id + type.rawValue }.joined(separator: "-")
            viewModels = self.highlightsVisualImageOutrights.map { match in

                return MatchWidgetCellViewModel(match: match, matchWidgetType: type)
            }
        case (0, .highlightedBoostedOddsMatches):
            var type = MatchWidgetType.boosted
            ids = self.highlightsBoostedMatches.map { $0.id + type.rawValue }.joined(separator: "-")
            viewModels = self.highlightsBoostedMatches.map { match in
                return MatchWidgetCellViewModel(match: match, matchWidgetType: type)
            }
        default:
            return nil
        }

        if let matchWidgetContainerTableViewModel = self.matchWidgetContainerTableViewModelCache[ids] {
            return matchWidgetContainerTableViewModel
        }
        else {
            let matchWidgetContainerTableViewModel = MatchWidgetContainerTableViewModel(cardsViewModels: viewModels)
            self.matchWidgetContainerTableViewModelCache[ids] = matchWidgetContainerTableViewModel
            return matchWidgetContainerTableViewModel
        }

    }

    //
    // Highlighted markets (aka Pro choices)
    func highlightedMarket(forIndex index: Int) -> MarketWidgetContainerTableViewModel? {

        switch self.highlightsPresentationMode {
        case .onePerLine:
            // Each highlight market has it's own line
            guard let market = self.highlightedMarkets[safe: index] else { return nil }
            let id = market.content.id
            if let marketWidgetContainerTableViewModel = self.marketWidgetContainerTableViewModelCache[id] {
                return marketWidgetContainerTableViewModel
            }
            else {
                let marketWidgetCellViewModel = MarketWidgetCellViewModel(highlightedMarket: market)
                let marketWidgetContainerTableViewModel = MarketWidgetContainerTableViewModel(singleCardsViewModel: marketWidgetCellViewModel)
                self.marketWidgetContainerTableViewModelCache[id] = marketWidgetContainerTableViewModel
                return marketWidgetContainerTableViewModel
            }

        case .multiplesPerLineByType:
            // There is a line for each highlight type (markets only has one at the moment)
            // Each market card type will show all card of that type in a horizontal scroll
            let ids = self.highlightedMarkets.map(\.content.id).joined(separator: "-")
            let viewModels = self.highlightedMarkets.map({ MarketWidgetCellViewModel(highlightedMarket: $0) })

            if let marketWidgetContainerTableViewModel = self.marketWidgetContainerTableViewModelCache[ids] {
                return marketWidgetContainerTableViewModel
            }
            else {
                let marketWidgetContainerTableViewModel = MarketWidgetContainerTableViewModel(cardsViewModels: viewModels)
                self.marketWidgetContainerTableViewModelCache[ids] = marketWidgetContainerTableViewModel
                return marketWidgetContainerTableViewModel
            }
        }
    }

    //
    // Live match
    func highlightedLiveMatchLineTableCellViewModel(forSection section: Int, forIndex index: Int) -> MatchLineTableCellViewModel? {

        guard
            let match = self.highlightedLiveMatches[safe: index]
        else {
            return nil
        }

        if let matchLineTableCellViewModel = self.highlightedLiveMatchLineTableCellViewModelCache[match.id] {
            return matchLineTableCellViewModel
        }
        else {
            let matchLineTableCellViewModel = MatchLineTableCellViewModel(match: match, status: .live)
            self.highlightedLiveMatchLineTableCellViewModelCache[match.id] = matchLineTableCellViewModel
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
        return self.videoNewsLineCellViewModel
    }

}

extension DummyWidgetShowcaseHomeViewTemplateDataSource {

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
