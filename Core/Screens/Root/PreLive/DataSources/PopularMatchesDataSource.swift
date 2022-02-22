//
//  PopularMatchesDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 18/01/2022.
//

import UIKit

class PopularMatchesDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var outrightCompetitions: [Competition] = []
    var matches: [Match] = []

    var alertsArray: [ActivationAlert] = []

    var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?

    var canRequestNextPageAction: (() -> Bool)?
    var requestNextPageAction: (() -> Void)?
    var didSelectActivationAlertAction: ((ActivationAlertType) -> Void)?
    var didSelectMatchAction: ((Match, UIImage?) -> Void)?
    var didSelectCompetitionAction: ((Competition) -> Void)?

    init(matches: [Match], outrightCompetitions: [Competition]) {
        self.matches = matches
        self.outrightCompetitions = outrightCompetitions

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

    func shouldShowOutrightMarkets() -> Bool {
        return self.matches.isEmpty
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
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
            return self.shouldShowOutrightMarkets() ? self.outrightCompetitions.count : 0
        case 2:
            return self.matches.count
        case 3:
            if self.canRequestNextPageAction?() ?? true {
                return 1
            }
            else {
                return 0
            }
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
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: OutrightCompetitionLineTableViewCell.identifier) as? OutrightCompetitionLineTableViewCell,
                let competition = self.outrightCompetitions[safe: indexPath.row]
            else {
                fatalError()
            }
            cell.configure(withViewModel: OutrightCompetitionLineViewModel(competition: competition))
            cell.didSelectCompetitionAction = { [weak self] competition in
                self?.didSelectCompetitionAction?(competition)
            }
            return cell

        case 2:
            if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
               let match = self.matches[safe: indexPath.row] {

                if let matchStatsViewModel = self.matchStatsViewModelForMatch?(match) {
                    cell.matchStatsViewModel = matchStatsViewModel
                }
                let store = Env.everyMatrixStorage as AggregatorStore

                cell.setupWithMatch(match, store: store)

                cell.tappedMatchLineAction = { image in
                    self.didSelectMatchAction?(match, image)
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

        if self.matches.isEmpty {
            return nil
        }

        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier) as? TitleTableViewHeader
        else {
            fatalError()
        }
        headerView.configureWithTitle(localized("popular_games"))
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if self.matches.isEmpty {
            return .leastNonzeroMagnitude
        }

        if section == 2 {
            return 54
        }
        return .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if self.matches.isEmpty {
            return .leastNonzeroMagnitude
        }

        if section == 2 {
            return 54
        }
        return .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 132 // Banner
        case 1:
            return 140
        case 3:
            return 70 // Loading cell
        default:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 140 // Banner
        case 1:
            return 130
        case 3:
            return 70 // Loading cell
        default:
            return MatchWidgetCollectionViewCell.cellHeight + 20
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
