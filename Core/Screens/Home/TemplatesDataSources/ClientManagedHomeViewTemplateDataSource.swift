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

    private let fixedSection = 9
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

    var supplementaryEventIds: [String] = []

    var matchLineTableCellViewModelCache: [String: MatchLineTableCellViewModel] = [:]

    private var topCompetitionsLineCellViewModel: TopCompetitionsLineCellViewModel = TopCompetitionsLineCellViewModel(topCompetitions: [])
    
    private var highlightedLiveMatchesIds: [String] = []
    
    //
    private var cancellables: Set<AnyCancellable> = []

    init() {
        self.refreshData()
        
        Env.userSessionStore.userProfilePublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchBanners()
                self?.fetchAlerts()
            }
            .store(in: &cancellables)
    }

    func refreshData() {
        self.matchLineTableCellViewModelCache = [:]
        
        self.fetchAlerts()
        self.fetchQuickSwipeMatches()
        self.fetchBanners()
        self.fetchHighlightMatches()
        self.fetchPromotedSports()
        self.fetchPromotionalStories()
        self.fetchSupplementaryEventsIds()
        self.fetchTopCompetitions()
        self.fetchHighlightedLiveMatches()
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

        if Env.userSessionStore.isUserLogged() {
            // Logged user has no banners
            self.banners = []
            self.refreshPublisher.send()
            return
        }

        Env.servicesProvider.getPromotionalTopBanners()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("ClientManagedHomeTemplate getPromotionalTopBanners completion \(completion)")
            } receiveValue: { [weak self] (promotionalBanners: [PromotionalBanner]) in
                self?.banners = promotionalBanners.map({ promotionalBanner in
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

    func fetchSupplementaryEventsIds() {
        self.supplementaryEventIds = []
        self.refreshPublisher.send()
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
            .map(ServiceProviderModelMapper.matches(fromEvents:))
            .replaceError(with: [])
        
        let boostedMatches = Env.servicesProvider.getHighlightedBoostedEvents()
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

        let publishers = promotedSport.marketGroups.map({ Env.servicesProvider.getEventsForMarketGroup(withId: $0.id) })

        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("ClientManagedHomeTemplate fetchMatchesForPromotedSport completion \(completion)")
            } receiveValue: { [weak self] eventGroups in
                let matches = eventGroups.flatMap(\.events).prefix(20).map(ServiceProviderModelMapper.match(fromEvent:))
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

                self?.topCompetitionsLineCellViewModel = TopCompetitionsLineCellViewModel(topCompetitions: convertedCompetitions)
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
        
        self.highlightedLiveMatchesIds = []
        
        Env.servicesProvider.getHighlightedLiveEvents(eventCount: 4)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("fetchHighlightedLiveMatches getHighlightedLiveEvents error: \(error)")
                }
            } receiveValue: { [weak self] highlightedLiveEventsIds in
                self?.highlightedLiveMatchesIds = highlightedLiveEventsIds
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
        var sections = self.fixedSection
        sections += self.promotedSports.count
        return sections
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {

        switch section {
        case 0:
            return self.alertsArray.isEmpty ? 0 : 1
        case 1:
            return self.bannersLineViewModel == nil ? 0 : 1
        case 2:
            return self.quickSwipeStackMatches.isEmpty ? 0 : 1
        case 3:
            return self.storiesLineViewModel == nil ? 0 : 1
        case 4:
            return self.shouldShowOwnBetCallToAction ? 1 : 0
        case 5:
            return self.highlightsVisualImageMatches.count +
            self.highlightsVisualImageOutrights.count +
            self.highlightsBoostedMatches.count
        case 6:
            return self.highlightedLiveMatchesIds.count
        case 7:
            return !self.topCompetitionsLineCellViewModel.isEmpty ? 1 : 0
        case 8:
            return self.supplementaryEventIds.count
        default:
            ()
        }

        let croppedSection = section - self.fixedSection
        if let promotedSportId = self.promotedSports[safe: croppedSection]?.id, let matchesForSport = self.promotedSportsMatches[promotedSportId] {
            return matchesForSport.count
        }

        return 0
    }

    func title(forSection section: Int) -> String? {
        switch section {
        case 5:
            return localized("highlights")
        case 6:
            return localized("live")
        case 7:
            return localized("top_competitions")
        default:
            ()
        }

        let croppedSection = section - self.fixedSection
        if let promotedSportName = self.promotedSports[safe: croppedSection]?.name {
            return promotedSportName
        }

        return nil
    }

    func iconName(forSection section: Int) -> String? {
        // return nil
        switch section {
        case 5:
            return "pin_icon"
        case 6:
            return "tabbar_live_icon"
        case 7:
            return "trophy_icon"
        default:
            ()
        }

        let activeSports = Env.sportsStore.getActiveSports()

        let croppedSection = section - self.fixedSection

        // NOTE: ID's don't match from regular and promoted same sport
        if let promotedSport = self.promotedSports[safe: croppedSection] {
            let currentSport = activeSports.filter({
                promotedSport.name.contains($0.name)
            }).first
            return currentSport?.id
        }

        return nil
    }

    func shouldShowTitle(forSection section: Int) -> Bool {
        switch section {
        case 5:
            let highlightsTotal = self.highlightsVisualImageMatches.count +
            self.highlightsVisualImageOutrights.count +
            self.highlightsBoostedMatches.count
            return highlightsTotal > 0
        case 6:
            return !self.highlightedLiveMatchesIds.isEmpty
        case 7:
            return !self.topCompetitionsLineCellViewModel.isEmpty
        default:
            ()
        }

        let croppedSection = section - self.fixedSection
        if let promotedSportId = self.promotedSports[safe: croppedSection]?.id, let matchesForSport = self.promotedSportsMatches[promotedSportId] {
            return matchesForSport.isNotEmpty
        }

        return false
    }

    func shouldShowFooter(forSection section: Int) -> Bool {
        return false
    }

    // Detail each content type for the section
    func contentType(forSection section: Int) -> HomeViewModel.Content? {

        switch section {
        case 0:
            return .userProfile
        case 1:
            return .bannerLine
        case 2:
            return .quickSwipeStack
        case 3:
            return .promotionalStories
        case 4:
            return .makeOwnBetCallToAction
        case 5:
            return .highlightedMatches
        case 6:
            return .highlightedLiveMatches
        case 7:
            return .topCompetitionsShortcuts
        case 8:
            return .supplementaryEvents
        default:
            ()
        }

        let croppedSection = section - self.fixedSection
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
        return nil
    }

    func suggestedBetLineViewModel() -> SuggestedBetLineViewModel? {
        return nil
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

    func highlightedMatchViewModel(forIndex index: Int) -> MatchWidgetCellViewModel? {
        
        let boostedMatchesIndex = index-self.highlightsVisualImageMatches.count-self.highlightsVisualImageOutrights.count
        
        let highlightsOutrightsMatchesIndex = index-self.highlightsVisualImageMatches.count
        
        if let match = self.highlightsVisualImageMatches[safe: index] {
            return MatchWidgetCellViewModel(match: match, matchWidgetType: .topImage)
        }
        else if let match = self.highlightsBoostedMatches[safe: boostedMatchesIndex] {
            return MatchWidgetCellViewModel(match: match, matchWidgetType: .boosted)
        }
        else if let match = self.highlightsVisualImageOutrights[safe: highlightsOutrightsMatchesIndex] {
            return MatchWidgetCellViewModel(match: match, matchWidgetType: .topImageOutright)
        }
        return nil
    }

    func promotedMatch(forSection section: Int, forIndex index: Int) -> Match? {
        let croppedSection = section - self.fixedSection
        if let promotedSportId = self.promotedSports[safe: croppedSection]?.id,
           let matchesForSport = self.promotedSportsMatches[promotedSportId],
           let match = matchesForSport[safe: index] {
            return match
        }
        return nil
    }

    func supplementaryEventId(forSection section: Int, forIndex index: Int) -> String? {
        return self.supplementaryEventIds[safe: index]
    }

    func highlightedLiveMatchesId(forSection section: Int, forIndex index: Int) -> String? {
        return self.highlightedLiveMatchesIds[safe: index]
    }
    
    func matchLineTableCellViewModel(forId identifier: String) -> MatchLineTableCellViewModel? {
        
        if let matchLineTableCellViewModel = self.matchLineTableCellViewModelCache[identifier] {
            return matchLineTableCellViewModel
        }
        else {
            let matchLineTableCellViewModel = MatchLineTableCellViewModel(matchId: identifier)
            self.matchLineTableCellViewModelCache[identifier] = matchLineTableCellViewModel
            return matchLineTableCellViewModel
        }

    }
    
    func matchLineTableCellViewModel(forSection section: Int, forIndex index: Int) -> MatchLineTableCellViewModel? {

        guard
            let matchId = self.supplementaryEventId(forSection: section, forIndex: index),
            section == 6
        else {
            return nil
        }

        if let matchLineTableCellViewModel = self.matchLineTableCellViewModelCache[matchId] {
            return matchLineTableCellViewModel
        }
        else {
            let matchLineTableCellViewModel = MatchLineTableCellViewModel(matchId: matchId)
            self.matchLineTableCellViewModelCache[matchId] = matchLineTableCellViewModel
            return matchLineTableCellViewModel
        }

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
