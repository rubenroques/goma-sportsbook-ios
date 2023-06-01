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

    //
    private var alertsArray: [ActivationAlert] = []

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
        return 2
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {

        switch section {
        case 0:
            return self.alertsArray.isEmpty ? 0 : 1
        case 1:
            return self.bannersLineViewModel == nil ? 0 : 1
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

}
