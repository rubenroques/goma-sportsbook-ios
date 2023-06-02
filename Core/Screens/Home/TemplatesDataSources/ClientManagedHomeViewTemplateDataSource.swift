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

            self.bannersLineViewModel = BannerLineCellViewModel(banners: bannerCellViewModels)
        }
    }
    private var bannersLineViewModelCache: [String: BannerCellViewModel] = [:]
    private var bannersLineViewModel: BannerLineCellViewModel? {
        didSet {
            self.refreshPublisher.send()
        }
    }

    // Quick Swipe Stack Matches
    private var quickSwipeStackCellViewModel: QuickSwipeStackCellViewModel?

    private var quickSwipeStackMatches: [Match] {
        return  [
            Match(id: "A1", competitionId: "PL1", competitionName: "Primeira Liga",
                  homeParticipant: Participant(id: "P1", name: "Benfica"),
                  awayParticipant: Participant(id: "P2", name: "Braga"), date: Date(timeIntervalSince1970: 1696620600),
                  sport: Sport.init(id: "1", name: "Football", alphaId: nil, numericId: nil, showEventCategory: false, liveEventsCount: 0),
                  numberTotalOfMarkets: 0,
                  markets: [], rootPartId: "", status: .notStarted),
            Match(id: "A2", competitionId: "PL2", competitionName: "Serie A",
                  homeParticipant: Participant(id: "P3", name: "Juventus"),
                  awayParticipant: Participant(id: "P4", name: "Inter Milan"), date: Date(timeIntervalSince1970: 1696620600),
                  sport: Sport.init(id: "1", name: "Football", alphaId: nil, numericId: nil, showEventCategory: false, liveEventsCount: 0),
                  numberTotalOfMarkets: 0,
                  markets: [], rootPartId: "", status: .notStarted),
            Match(id: "A3", competitionId: "PL3", competitionName: "La Liga",
                  homeParticipant: Participant(id: "P5", name: "Real Madrid"),
                  awayParticipant: Participant(id: "P6", name: "Barcelona"), date: Date(timeIntervalSince1970: 1696620600),
                  sport: Sport.init(id: "1", name: "Football", alphaId: nil, numericId: nil, showEventCategory: false, liveEventsCount: 0),
                  numberTotalOfMarkets: 0,
                  markets: [], rootPartId: "", status: .notStarted),
            Match(id: "A4", competitionId: "PL4", competitionName: "Bundesliga",
                  homeParticipant: Participant(id: "P7", name: "Bayern Munich"),
                  awayParticipant: Participant(id: "P8", name: "Dortmund"), date: Date(timeIntervalSince1970: 1696620600),
                  sport: Sport.init(id: "1", name: "Football", alphaId: nil, numericId: nil, showEventCategory: false, liveEventsCount: 0),
                  numberTotalOfMarkets: 0,
                  markets: [], rootPartId: "", status: .notStarted),
            Match(id: "A5", competitionId: "PL5", competitionName: "Premier League",
                  homeParticipant: Participant(id: "P9", name: "Manchester United"),
                  awayParticipant: Participant(id: "P10", name: "Manchester City"), date: Date(timeIntervalSince1970: 1696620600),
                  sport: Sport.init(id: "1", name: "Football", alphaId: nil, numericId: nil, showEventCategory: false, liveEventsCount: 0),
                  numberTotalOfMarkets: 0,
                  markets: [], rootPartId: "", status: .notStarted)

        ]

    }
    //

    // Make your own bet call to action
    var shouldShowOwnBetCallToAction: Bool = true

    //
    private var cancellables: Set<AnyCancellable> = []

    init() {

        self.fetchAlerts()
        self.fetchBanners()

        Env.servicesProvider.getPromotionalTopEvents()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("")
            } receiveValue: { (promotionalBannersResponse: BannerResponse) in
                print("")
            }
            .store(in: &self.cancellables)

        Env.servicesProvider.getPromotionalTopStories()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("")
            } receiveValue: { (promotionalBannersResponse: BannerResponse) in
                print("")
            }
            .store(in: &self.cancellables)

    }

    // User alerts
    func fetchAlerts() {
        self.alertsArray = []

#if DEBUG
            let emailActivationAlertData = ActivationAlert(title: localized("verify_email"),
                                                           description: localized("app_full_potential"),
                                                           linkLabel: localized("verify_my_account"),
                                                           alertType: .email)

            alertsArray.append(emailActivationAlertData)

            let completeProfileAlertData = ActivationAlert(title: localized("complete_your_profile"),
                                                           description: localized("complete_profile_description"),
                                                           linkLabel: localized("finish_up_profile"),
                                                           alertType: .profile)
            alertsArray.append(completeProfileAlertData)

#else

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
#endif

    }

    // User alerts
    func fetchBanners() {

        Env.servicesProvider.getPromotionalTopBanners()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("")
            } receiveValue: { [weak self] (promotionalBanners: [PromotionalBanner]) in
                print("", promotionalBanners.count)

                self?.banners = promotionalBanners.map({ promotionalBanner in
                    return BannerInfo(type: "", id: promotionalBanner.id, matchId: nil, imageURL: promotionalBanner.imageURL, priorityOrder: nil, marketId: nil)
                })
            }
            .store(in: &self.cancellables)

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
        return 4
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
            return self.shouldShowOwnBetCallToAction ? 1 : 0
        default:
            return 0
        }

    }

    func title(forSection section: Int) -> String? {
        return nil
    }

    func iconName(forSection section: Int) -> String? {
        return nil
    }

    func shouldShowTitle(forSection section: Int) -> Bool {
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
            return .makeOwnBetCallToAction
        default:
            return nil
        }
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

}
