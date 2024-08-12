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

    // Define the array mapping sections to content types
    private let contentTypes: [HomeViewModel.Content] = [
        .userProfile,
        .bannerLine,
        .heroCard,
        .quickSwipeStack,
        .promotionalStories,
        .makeOwnBetCallToAction,
        .highlightedMatches,
        .highlightedLiveMatches,
        .topCompetitionsShortcuts,
        .featuredTips,
    ]
    
    private var fixedSections: Int {
        return self.contentTypes.count
    }
    
    private var refreshPublisher = PassthroughSubject<Void, Never>.init()

    // User Alert
    private var alertsArray: [ActivationAlert] = []

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

    var matchWidgetCellViewModelCache: [String: MatchWidgetCellViewModel] = [:]
    var matchLineTableCellViewModelCache: [String: MatchLineTableCellViewModel] = [:]
    var heroCardWidgetCellViewModelCache: [String: MatchWidgetCellViewModel] = [:]

    var highlightedLiveMatchLineTableCellViewModelCache: [String: MatchLineTableCellViewModel] = [:]
    
    private var topCompetitionsLineCellViewModel: TopCompetitionsLineCellViewModel = TopCompetitionsLineCellViewModel(topCompetitions: [])
    
    private var highlightedLiveMatches: [Match] = []
    
    //
    private var pendingUserTrackRequest: AnyCancellable?
    private var cancellables: Set<AnyCancellable> = []

    init() {
        self.refreshData()
        
        // Banners are associated with profile publisher
        Env.userSessionStore.userProfilePublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchBanners()
            }
            .store(in: &cancellables)
        
        // Alerts are associated with KYC publisher
        self.fetchAlerts()
    }

    func refreshData() {
        
        self.matchWidgetCellViewModelCache = [:]
        self.matchLineTableCellViewModelCache = [:]
        self.matchLineTableCellViewModelCache = [:]
        
        self.suggestedBetslips = []
        self.cachedFeaturedTipLineViewModel = nil
        
        self.highlightedLiveMatchLineTableCellViewModelCache = [:]
        
        self.fetchQuickSwipeMatches()
        self.fetchHighlightMatches()
        self.fetchPromotedSports()
        self.fetchPromotedBetslips()
        self.fetchPromotionalStories()
        self.fetchTopCompetitions()
        self.fetchHighlightedLiveMatches()
        
        self.fetchHeroMatches()

    }

    // User alerts
    func fetchAlerts() {

        Env.userSessionStore.userKnowYourCustomerStatusPublisher
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
            .store(in: &cancellables)

    }

    // User alerts
    func fetchBanners() {

//        if Env.userSessionStore.isUserLogged() {
//            // Logged user has no banners
//            self.banners = []
//            self.refreshPublisher.send()
//            return
//        }

        Env.servicesProvider.getPromotionalTopBanners()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("ClientManagedHomeTemplate getPromotionalTopBanners completion \(completion)")
            } receiveValue: { [weak self] (promotionalBanners: [PromotionalBanner]) in
                var displayBanners = promotionalBanners
                
                if Env.userSessionStore.isUserLogged() {
                    let filteredBanners = displayBanners.filter({
                        $0.bannerDisplay == "LOGGEDIN"
                    })
                    
                    displayBanners = filteredBanners
                }
                else {
                    let filteredBanners = displayBanners.filter({
                        $0.bannerDisplay == "LOGGEDOFF"
                    })
                    
                    displayBanners = filteredBanners
                }
                
                print("DISPLAY BANNERS: \(displayBanners)")
                
                self?.banners = displayBanners.map({ promotionalBanner in
                    return BannerInfo(type: "",
                                      id: promotionalBanner.id,
                                      matchId: nil,
                                      imageURL: promotionalBanner.imageURL,
                                      priorityOrder: nil,
                                      marketId: nil,
                                      location: promotionalBanner.location,
                                      specialAction: promotionalBanner.specialAction)
                })
                self?.refreshPublisher.send()
            }
            .store(in: &self.cancellables)

    }

    func fetchPromotionalStories() {

        Env.servicesProvider.getPromotionalTopStories()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("ClientManagedHomeTemplate getPromotionalTopStories Promotional stories completion \(completion)")
            } receiveValue: { [weak self] promotionalStories in
                let mappedPromotionalStories = promotionalStories.map({ promotionalStory in
                    let promotionalStory = ServiceProviderModelMapper.promotionalStory(fromPromotionalStory: promotionalStory)
                    return promotionalStory
                })
                self?.promotionalStories = mappedPromotionalStories
                self?.refreshPublisher.send()
            }
            .store(in: &self.cancellables)
    }

    func fetchQuickSwipeMatches() {
        Env.servicesProvider.getPromotionalSlidingTopEvents()
            .map(ServiceProviderModelMapper.matches(fromEvents:))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print("ClientManagedHomeTemplate getPromotionalSlidingTopEvents completion \(completion)")
            }, receiveValue: { [weak self] matches in
                self?.quickSwipeStackMatches = matches
                self?.refreshPublisher.send()
            })
            .store(in: &self.cancellables)
    }

    func fetchHighlightMatches() {

        let imageMatches = Env.servicesProvider.getHighlightedVisualImageEvents()
            .receive(on: DispatchQueue.main)
            .map(ServiceProviderModelMapper.matches(fromEvents:))
            .replaceError(with: [])
        
        let boostedMatches = Env.servicesProvider.getHighlightedBoostedEvents()
            .receive(on: DispatchQueue.main)
            .map(ServiceProviderModelMapper.matches(fromEvents:))
            .replaceError(with: [])

        Publishers.CombineLatest(imageMatches, boostedMatches)
        .map { highlightedVisualImageEvents, highlightedBoostedEvents -> [HighlightedMatchType] in
            var events: [HighlightedMatchType] = highlightedVisualImageEvents.map({ HighlightedMatchType.visualImageMatch($0) })
            events.append(contentsOf: highlightedBoostedEvents.map({ HighlightedMatchType.boostedOddsMatch($0) }))
            return events
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            print("ClientManagedHomeTemplate fetchHighlightMatches completion \(completion)")
        }, receiveValue: { [weak self] highlightedMatchTypes in
            var imageMatches: [Match] = [ ]
            var boostedMatches: [Match] = []
            for highlightedMatchType in highlightedMatchTypes {
                switch highlightedMatchType {
                case .visualImageMatch(let match):
                    imageMatches.append(match)
                case .boostedOddsMatch(let match):
                    boostedMatches.append(match)
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
        .store(in: &self.cancellables)

    }
    
    func fetchHeroMatches() {
        
        Env.servicesProvider.getHeroGameEvent()
            .receive(on: DispatchQueue.main)
            .map(ServiceProviderModelMapper.match(fromEvent:))
            .sink(receiveCompletion: { completion in
                    print("ClientManagedHomeTemplate getHeroGameEvent completion \(completion)")
            }, receiveValue: { [weak self] heroMatch in
                var heroMatches: [Match] = []
                
                if let heroMatch {
                    heroMatches.append(heroMatch)
                }
                
                self?.heroMatches = heroMatches
                
                self?.refreshPublisher.send()
            })
            .store(in: &cancellables)

//        let imageMatches = Env.servicesProvider.getHighlightedVisualImageEvents()
//            .receive(on: DispatchQueue.main)
//            .map(ServiceProviderModelMapper.matches(fromEvents:))
//            .replaceError(with: [])
//        
//
//        imageMatches.map { heroEvents -> [HighlightedMatchType] in
//            var events: [HighlightedMatchType] = heroEvents.map({ HighlightedMatchType.visualImageMatch($0) })
//            return events
//        }
//        .receive(on: DispatchQueue.main)
//        .sink(receiveCompletion: { completion in
//            print("ClientManagedHomeTemplate fetchHeroMatches completion \(completion)")
//        }, receiveValue: { [weak self] highlightedMatchTypes in
//            var imageMatches: [Match] = []
//            var boostedMatches: [Match] = []
//            for highlightedMatchType in highlightedMatchTypes {
//                switch highlightedMatchType {
//                case .visualImageMatch(let match):
//                    imageMatches.append(match)
//                case .boostedOddsMatch(let match):
//                    boostedMatches.append(match)
//                }
//            }
//            
//            var testMatches: [Match] = []
//            
//            for match in imageMatches {
//                var markets = match.markets
//                let newMarkets = markets.flatMap { [$0, $0] }
//                var newMatch = match
//                newMatch.markets = newMarkets
//                testMatches.append(newMatch)
//            }
//
//            self?.heroMatches = testMatches.filter({
//                $0.homeParticipant.name != "" && $0.awayParticipant.name != ""
//            })
//
//            self?.refreshPublisher.send()
//        })
//        .store(in: &self.cancellables)

    }

    func fetchPromotedSports() {

        Env.servicesProvider.getPromotedSports()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("ClientManagedHomeTemplate getPromotedSports completion \(completion)")
            } receiveValue: { [weak self] promotedSports in
                self?.promotedSports = promotedSports
                self?.refreshPublisher.send()
            }
            .store(in: &self.cancellables)

    }

    func fetchMatchesForPromotedSport(_ promotedSport: PromotedSport) {

        let publishers = promotedSport.marketGroups.map({ Env.servicesProvider.getEventsForEventGroup(withId: $0.id) })

        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("ClientManagedHomeTemplate fetchMatchesForPromotedSport completion \(completion)")
            } receiveValue: { [weak self] eventGroups in
                let matches = eventGroups.flatMap(\.events).prefix(20).map(ServiceProviderModelMapper.match(fromEvent:)).compactMap({ $0 })
                self?.promotedSportsMatches[promotedSport.id] = matches
                self?.refreshPublisher.send()
            }
            .store(in: &self.cancellables)

    }

    private func fetchTopCompetitions() {

        Env.servicesProvider.getTopCompetitions()
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
            .store(in: &cancellables)

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
        
        var userId: String? = nil
        
        if let loggedUserId = Env.userSessionStore.userProfilePublisher.value?.userIdentifier {
            userId = loggedUserId
        }
        
        Env.servicesProvider.getHighlightedLiveEvents(eventCount: homeLiveEventsCount, userId: userId)
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
            .store(in: &self.cancellables)

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
                print("trackEvent impressionsEvents called ok")
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
        
        Env.servicesProvider.getPromotedBetslips(userId: userIdentifier)
            .map(ServiceProviderModelMapper.suggestedBetslips(fromPromotedBetslips:))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("ClientManagedHomeTemplate getPromotedSports completion \(completion)")
            } receiveValue: { [weak self] suggestedBetslips in
                
                #if DEBUG
                self?.suggestedBetslips = suggestedBetslips + suggestedBetslips
                #else
                self?.suggestedBetslips = suggestedBetslips
                #endif
                
                self?.refreshPublisher.send()
            }
            .store(in: &self.cancellables)
    }
    
}

extension ClientManagedHomeViewTemplateDataSource: HomeViewTemplateDataSource {

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
        guard let contentType = contentType(forSection: section) else {
            return 0
        }

        switch contentType {
        case .userProfile:
            return self.alertsArray.isEmpty ? 0 : 1
        case .bannerLine:
            return self.bannersLineViewModel == nil ? 0 : 1
        case .heroCard:
            return self.heroMatches.isEmpty ? 0 : 1
        case .quickSwipeStack:
            return self.quickSwipeStackMatches.isEmpty ? 0 : 1
        case .promotionalStories:
            return self.storiesLineViewModel == nil ? 0 : 1
        case .makeOwnBetCallToAction:
            return self.shouldShowOwnBetCallToAction ? 1 : 0
        case .highlightedMatches:
            return self.highlightsVisualImageMatches.count +
                   self.highlightsVisualImageOutrights.count +
                   self.highlightsBoostedMatches.count
        case .highlightedLiveMatches:
            return self.highlightedLiveMatches.count
        case .featuredTips:
            return self.suggestedBetslips.isEmpty ? 0 : 1
        case .topCompetitionsShortcuts:
            if let featuredCompetitionId = Env.businessSettingsSocket.clientSettings.featuredCompetition?.id {
                return !self.topCompetitionsLineCellViewModel.isEmpty ? 2 : 1
            } else {
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
        case .highlightedLiveMatches:
            return localized("live")
        case .featuredTips:
            return self.suggestedBetslips.isNotEmpty ? "Suggested_Bets" : nil
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
        case .highlightedLiveMatches:
            return "tabbar_live_icon"
        case .topCompetitionsShortcuts:
            return "trophy_icon"
        case .featuredTips:
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
            let highlightsTotal = self.highlightsVisualImageMatches.count +
                                  self.highlightsVisualImageOutrights.count +
                                  self.highlightsBoostedMatches.count
            return highlightsTotal > 0
            
        case .highlightedLiveMatches:
            return self.highlightedLiveMatches.isNotEmpty
        case .featuredTips:
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
        if section < self.contentTypes.count {
            return self.contentTypes[section]
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
    
    // TODO: HERO CARD CELL VIEW MODEL
    func heroCardMatchViewModel(forIndex index: Int) -> MatchWidgetCellViewModel? {
                
        if let match = self.heroMatches[safe: index] {
            let id = match.id + MatchWidgetType.topImage.rawValue
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

    func highlightedMatchViewModel(forIndex index: Int) -> MatchWidgetCellViewModel? {
        
        let boostedMatchesIndex = index-self.highlightsVisualImageMatches.count-self.highlightsVisualImageOutrights.count
        let highlightsOutrightsMatchesIndex = index-self.highlightsVisualImageMatches.count
        
        if let match = self.highlightsVisualImageMatches[safe: index] {
            let id = match.id + MatchWidgetType.topImage.rawValue
            if let matchWidgetCellViewModel = self.matchWidgetCellViewModelCache[id] {
                return matchWidgetCellViewModel
            }
            else {
                let matchWidgetCellViewModel = MatchWidgetCellViewModel(match: match, matchWidgetType: .topImage)
                self.matchWidgetCellViewModelCache[id] = matchWidgetCellViewModel
                return matchWidgetCellViewModel
            }
        }
        else if let match = self.highlightsBoostedMatches[safe: boostedMatchesIndex] {
            let id = match.id + MatchWidgetType.boosted.rawValue
            if let matchWidgetCellViewModel = self.matchWidgetCellViewModelCache[id] {
                return matchWidgetCellViewModel
            }
            else {
                let matchWidgetCellViewModel = MatchWidgetCellViewModel(match: match, matchWidgetType: .boosted)
                self.matchWidgetCellViewModelCache[id] = matchWidgetCellViewModel
                return matchWidgetCellViewModel
            }
        }
        else if let match = self.highlightsVisualImageOutrights[safe: highlightsOutrightsMatchesIndex] {
            let id = match.id + MatchWidgetType.topImageOutright.rawValue
            if let matchWidgetCellViewModel = self.matchWidgetCellViewModelCache[id] {
                return matchWidgetCellViewModel
            }
            else {
                let matchWidgetCellViewModel = MatchWidgetCellViewModel(match: match, matchWidgetType: .topImageOutright)
                self.matchWidgetCellViewModelCache[id] = matchWidgetCellViewModel
                return matchWidgetCellViewModel
            }
        }
        return nil
    }
    
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
        case 0...7:
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

}

extension ClientManagedHomeViewTemplateDataSource {
    
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
