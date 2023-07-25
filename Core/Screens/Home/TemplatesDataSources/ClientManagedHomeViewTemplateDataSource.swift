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

    private let fixedSection = 6
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
                                                              marketId: banner.marketId)
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
    // Should show instagram like promotional stories
    var shouldShowPromotionalStories: Bool = true
    var promotionalStories: [String] = []
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

    //
    private var cancellables: Set<AnyCancellable> = []

    init() {

        self.refreshData()
//
//        Env.servicesProvider.getPromotionalTopEvents()
//            .receive(on: DispatchQueue.main)
//            .sink { completion in
//                print("")
//            } receiveValue: { (promotionalBannersResponse: BannerResponse) in
//                print("")
//            }
//            .store(in: &self.cancellables)
//
//        Env.servicesProvider.getPromotionalTopStories()
//            .receive(on: DispatchQueue.main)
//            .sink { completion in
//                print("")
//            } receiveValue: { (promotionalBannersResponse: BannerResponse) in
//                print("")
//            }
//            .store(in: &self.cancellables)

    }

    func refreshData() {

        self.fetchAlerts()
        self.fetchQuickSwipeMatches()
        self.fetchBanners()
        self.fetchHighlightMatches()
        self.fetchPromotedSports()
        self.fetchPromotionalStories()
    }

    // User alerts
    func fetchAlerts() {
        self.alertsArray = []

//        if let isUserEmailVerified = Env.userSessionStore.isUserEmailVerified.value, !isUserEmailVerified {
//            let emailActivationAlertData = ActivationAlert(title: localized("verify_email"),
//                                                           description: localized("app_full_potential"),
//                                                           linkLabel: localized("verify_my_account"),
//                                                           alertType: .email)
//
//            alertsArray.append(emailActivationAlertData)
//        }

//        if let isUserProfileComplete = Env.userSessionStore.isUserProfileComplete, !isUserProfileComplete {
//            let completeProfileAlertData = ActivationAlert(title: localized("complete_your_profile"),
//                                                           description: localized("complete_profile_description"),
//                                                           linkLabel: localized("finish_up_profile"),
//                                                           alertType: .profile)
//            alertsArray.append(completeProfileAlertData)
//        }

        Env.userSessionStore.userKnowYourCustomerStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] kycStatus in

                if kycStatus == .request {

                    if let alertsArray = self?.alertsArray,
                       !alertsArray.contains(where: {
                        $0.alertType == .documents
                       }) {
                        let uploadDocumentsAlertData = ActivationAlert(title: localized("document_validation_required"),
                                                                       description: localized("document_validation_required_description"),
                                                                       linkLabel: localized("complete_your_verification"),
                                                                       alertType: .documents)

                        self?.alertsArray.append(uploadDocumentsAlertData)
                    }
                }
                else {
                    self?.alertsArray = []
                }
            })
            .store(in: &cancellables)

//        if let userKnowYourCustomerStatus = Env.userSessionStore.userKnowYourCustomerStatus,
//            userKnowYourCustomerStatus == .request {
//            let uploadDocumentsAlertData = ActivationAlert(title: localized("document_validation_required"),
//                                                           description: localized("document_validation_required_description"),
//                                                           linkLabel: localized("complete_your_verification"),
//                                                           alertType: .documents)
//
//            alertsArray.append(uploadDocumentsAlertData)
//        }
        
    }

    // User alerts
    func fetchBanners() {

        self.banners = []

        if Env.userSessionStore.isUserLogged() {
            return
        }

        Env.servicesProvider.getPromotionalTopBanners()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("completion \(dump(completion))")
            } receiveValue: { [weak self] (promotionalBanners: [PromotionalBanner]) in
                self?.banners = promotionalBanners.map({ promotionalBanner in
                    return BannerInfo(type: "", id: promotionalBanner.id, matchId: nil, imageURL: promotionalBanner.imageURL, priorityOrder: nil, marketId: nil)
                })
            }
            .store(in: &self.cancellables)

    }

    func fetchPromotionalStories() {

        self.promotionalStories = []

        Env.servicesProvider.getPromotionalTopStories()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("Promotional stories completion \(dump(completion))")
                
            } receiveValue: { [weak self] promotionalStories in

                let promotionalStories = promotionalStories

                print("PROMOTIONAL STORIES: \(promotionalStories)")
            }
            .store(in: &self.cancellables)
    }

    func fetchSportsSections() {

    }

    func fetchQuickSwipeMatches() {

        Env.servicesProvider.getPromotionalSlidingTopEvents()
            .map(ServiceProviderModelMapper.matches(fromEvents:))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print("completion \(dump(completion))")
            }, receiveValue: { [weak self] matches in
                self?.quickSwipeStackMatches = matches
                self?.refreshPublisher.send()
            })
            .store(in: &self.cancellables)

    }

    func fetchHighlightMatches() {

        let imageMatches = Env.servicesProvider.getHighlightedVisualImageEvents()
            .map(ServiceProviderModelMapper.matches(fromEvents:))

        let boostedMatches = Env.servicesProvider.getHighlightedBoostedEvents()
            .map(ServiceProviderModelMapper.matches(fromEvents:))

        Publishers.CombineLatest(imageMatches, boostedMatches)
        .map { highlightedVisualImageEvents, highlightedBoostedEvents -> [HighlightedMatchType] in
            var events: [HighlightedMatchType] = highlightedVisualImageEvents.map({ HighlightedMatchType.visualImageMatch($0) })
            events.append(contentsOf: highlightedBoostedEvents.map({ HighlightedMatchType.boostedOddsMatch($0) }))
            return events
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            print("completion \(dump(completion))")
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

            self?.highlightsVisualImageMatches = imageMatches
            self?.highlightsBoostedMatches = boostedMatches

            self?.refreshPublisher.send()
        })
        .store(in: &self.cancellables)

    }

    func fetchPromotedSports() {

        self.promotedSports = []
        self.promotedSportsMatches = [:]

        Env.servicesProvider.getPromotedSports()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("completion \(dump(completion))")
            } receiveValue: { [weak self] promotedSports in
                print("promotedSports \(promotedSports)")
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
                print("completion \(dump(completion))")
            } receiveValue: { [weak self] eventGroups in
                let matches = eventGroups.flatMap(\.events).map(ServiceProviderModelMapper.match(fromEvent:))
                self?.promotedSportsMatches[promotedSport.id] = matches
                self?.refreshPublisher.send()
            }
            .store(in: &self.cancellables)

    }

}

extension ClientManagedHomeViewTemplateDataSource: HomeViewTemplateDataSource {

    var refreshRequestedPublisher: AnyPublisher<Void, Never> {
        return self.refreshPublisher.eraseToAnyPublisher()
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
            return self.shouldShowPromotionalStories ? 1 : 0
        case 4:
            return self.highlightsVisualImageMatches.count + self.highlightsBoostedMatches.count
        case 5:
            return self.shouldShowOwnBetCallToAction ? 1 : 0
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
        case 4:
            return localized("Highlights")
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
        return nil
    }

    func shouldShowTitle(forSection section: Int) -> Bool {
        switch section {
        case 4:
            return true
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
            return .highlightedMatches
        case 5:
            return .makeOwnBetCallToAction
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
        let boostedMatchesIndex = index-self.highlightsVisualImageMatches.count
        if let match = self.highlightsVisualImageMatches[safe: index] {
            return MatchWidgetCellViewModel(match: match, matchWidgetType: .topImage)
        }
        else if let match = self.highlightsBoostedMatches[safe: boostedMatchesIndex] {
            return MatchWidgetCellViewModel(match: match, matchWidgetType: .boosted)
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

}
