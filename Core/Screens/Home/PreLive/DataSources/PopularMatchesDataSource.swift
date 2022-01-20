//
//  PopularMatchesDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 18/01/2022.
//

import UIKit

class PopularMatchesDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var banners: [EveryMatrix.BannerInfo] = [] {
        didSet {
            self.bannersViewModel = self.createBannersViewModel()
        }
    }

    private var bannersViewModel: BannerLineCellViewModel?
    var cachedBannerCellViewModel: [String: BannerCellViewModel] = [:]
    var cachedBannerLineCellViewModel: BannerLineCellViewModel?
    var didCachedBanners: Bool = false

    var matches: [Match] = []

    var alertsArray: [ActivationAlert] = []

    var requestNextPageAction: (() -> Void)?
    var didSelectActivationAlertAction: ((ActivationAlertType) -> Void)?
    var didSelectMatchAction: ((Match) -> Void)?

    init(banners: [EveryMatrix.BannerInfo], matches: [Match]) {
        self.banners = banners
        self.matches = matches

        if let userSession = UserSessionStore.loggedUserSession() {
            if !userSession.isEmailVerified {

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

        super.init()
    }

    func refetchAlerts() {
        alertsArray = []

        if let userSession = UserSessionStore.loggedUserSession() {
            if !userSession.isEmailVerified {

                let emailActivationAlertData = ActivationAlert(title: localized("verify_email"),
                                                               description: localized("app_full_potential"),
                                                               linkLabel: localized("verify_my_account"),
                                                               alertType: .email)

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

    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if UserSessionStore.isUserLogged(), let loggedUser = UserSessionStore.loggedUserSession() {
                if !loggedUser.isEmailVerified {
                    return 1
                }
                else if Env.userSessionStore.isUserProfileIncomplete.value {
                    return 1
                }
            }
            return 0
        case 1:
            return banners.isEmpty ? 0 : 1
        case 2:
            return self.matches.count
        case 3:
            return 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueCellType(ActivationAlertScrollableTableViewCell.self) {
                cell.activationAlertCollectionViewCellLinkLabelAction = { alertType in
                    self.didSelectActivationAlertAction?(alertType)
                }
                cell.setAlertArrayData(arrayData: alertsArray)
                return cell
            }
        case 1:
            if let cell = tableView.dequeueCellType(BannerScrollTableViewCell.self) {
                if !didCachedBanners {
                    if let cachedViewModel = self.cachedBannerLineCellViewModel {
                        cell.setupWithViewModel(cachedViewModel)

                        cell.tappedBannerMatchAction = { match in
                            self.didSelectMatchAction?(match)
                        }
                        didCachedBanners = true
                    }
                }
                return cell
            }
        case 2:
            if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
               let match = self.matches[safe: indexPath.row] {
                cell.setupWithMatch(match)

                cell.tappedMatchLineAction = {
                    self.didSelectMatchAction?(match)
                }
                return cell
            }
        case 3:
            if let cell = tableView.dequeueCellType(LoadingMoreTableViewCell.self) {
                return cell
            }
        default:
            fatalError()
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier) as? TitleTableViewHeader
        else {
            fatalError()
        }
        headerView.configureWithTitle(localized("popular_games"))
        return headerView
    }

    private func createBannersViewModel() -> BannerLineCellViewModel? {
        if self.banners.isEmpty {
            return nil
        }
        var cells = [BannerCellViewModel]()
        for banner in self.banners {
            if let cachedBannerCell = cachedBannerCellViewModel[banner.id] {
                cells.append(cachedBannerCell)
            }
            else {
                let cachedBannerCell = BannerCellViewModel(matchId: banner.matchID, imageURL: banner.imageURL ?? "")
                cachedBannerCellViewModel[banner.id] = cachedBannerCell
                cells.append(cachedBannerCell)
            }
        }
        if let cachedBannerLineCellViewModel = cachedBannerLineCellViewModel {
            return cachedBannerLineCellViewModel
        }
        else {
            cachedBannerLineCellViewModel = BannerLineCellViewModel(banners: cells)
            return cachedBannerLineCellViewModel
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 54
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 54
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 132
        case 3:
            // Loading cell
            return 70
        default:
            return 155
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 130
        case 3:
            // Loading cell
            return 70
        default:
            return 155
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 3, self.matches.isNotEmpty {
            if let typedCell = cell as? LoadingMoreTableViewCell {
                typedCell.startAnimating()
            }
            self.requestNextPageAction?()
        }
    }

}
