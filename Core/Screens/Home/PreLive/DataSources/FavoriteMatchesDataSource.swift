//
//  FavoriteMatchesDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 18/01/2022.
//

import UIKit

class FavoriteMatchesDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var userFavoriteMatches: [Match] = []

    var requestNextPage: (() -> Void)?
    var didSelectMatchAction: ((Match) -> Void)?
    var matchDataSourceWentLive: (() -> Void)?

    init(userFavoriteMatches: [Match]) {
        self.userFavoriteMatches = userFavoriteMatches

        super.init()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if self.userFavoriteMatches.isEmpty {
                return 1
            }
            return self.userFavoriteMatches.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            if !self.userFavoriteMatches.isEmpty {
                if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
                   let match = self.userFavoriteMatches[safe: indexPath.row] {

                    if Env.everyMatrixStorage.matchesInfoForMatchPublisher.value.contains(match.id) {

                        cell.setupWithMatch(match, liveMatch: true)
                    }
                    else {
                        cell.setupWithMatch(match)

                    }
                    cell.setupFavoriteMatchInfoPublisher(match: match)

                    cell.tappedMatchLineAction = {
                        self.didSelectMatchAction?(match)
                    }

                    cell.matchWentLive = {
                        DispatchQueue.main.async {
                            self.matchDataSourceWentLive?()
                        }
                    }

                    return cell
                }
            }
            else {
                if let cell = tableView.dequeueCellType(EmptyCardTableViewCell.self) {
                    cell.setDescription(primaryText: localized("empty_my_games"),
                                        secondaryText: localized("second_string_empty_my_games"),
                                        userIsLoggedIn: UserSessionStore.isUserLogged() )
                    return cell
                }

            }
        default:
            ()
        }
        fatalError()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier)
            as? TitleTableViewHeader {
            headerView.configureWithTitle(localized("my_games"))
            return headerView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 54
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 54
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            // Loading cell
            return 70
        case 0:
            if self.userFavoriteMatches.isEmpty {
                return 600
            }
            else {
                return 155
            }
        default:
            return 155
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            // Loading cell
            return 70
        default:
            return 155
        }
    }

}
