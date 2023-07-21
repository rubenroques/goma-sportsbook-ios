//
//  FavoriteMatchesDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 18/01/2022.
//

import UIKit

class FavoriteMatchesDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var userFavoriteMatches: [Match] = []

    var didSelectMatchAction: ((Match) -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    
    var matchWentLiveAction: (() -> Void)?

    var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?

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

                    if let matchStatsViewModel = self.matchStatsViewModelForMatch?(match) {
                        cell.matchStatsViewModel = matchStatsViewModel
                    }
                    
                    let viewModel = MatchLineTableCellViewModel(match: match)
                    cell.viewModel = viewModel
                    
                    cell.tappedMatchLineAction = { [weak self] match in
                        self?.didSelectMatchAction?(match)
                    }
                    cell.matchWentLive = { [weak self] in
                        DispatchQueue.main.async {
                            self?.matchWentLiveAction?()
                        }
                    }

                    return cell
                }
            }
            else {
                if let cell = tableView.dequeueCellType(EmptyCardTableViewCell.self) {
                    cell.setDescription(primaryText: localized("empty_my_games"),
                                        secondaryText: localized("go_to_list_to_mark"),
                                        userIsLoggedIn: Env.userSessionStore.isUserLogged() )
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
                return UITableView.automaticDimension
            }
        default:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            // Loading cell
            return 70
        default:
            return StyleHelper.cardsStyleHeight() + 20
        }
    }

}
