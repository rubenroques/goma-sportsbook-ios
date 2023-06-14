//
//  MyFavoriteMatchesDataSource.swift
//  Sportsbook
//
//  Created by André Lascas on 10/02/2022.
//

import Foundation
import UIKit
import Combine

class MyFavoriteMatchesDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var userFavoriteMatches: [Match] = []

    var userFavoritesBySportsArray: [FavoriteSportMatches] = []
    var matchesBySportList: [String: [Match]] = [:]

    var didSelectMatchAction: ((Match) -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var matchWentLiveAction: (() -> Void)?

    var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?

    var collapsedSportSections: Set<Int> = []

    init(userFavoriteMatches: [Match]) {
        self.userFavoriteMatches = userFavoriteMatches
        super.init()
    }

    func setupMatchesBySport(favoriteMatches: [Match]) {

        self.matchesBySportList = [:]
        self.userFavoritesBySportsArray = []

        for match in favoriteMatches {
            if self.matchesBySportList[match.sport.name] != nil {
                self.matchesBySportList[match.sport.name]?.append(match)
            }
            else {
                self.matchesBySportList[match.sport.name] = [match]
            }
        }

        for (key, matches) in matchesBySportList {
                let favoriteSportMatch = FavoriteSportMatches(sportType: key, matches: matches)
            self.userFavoritesBySportsArray.append(favoriteSportMatch)
        }

        // Sort by sportId
        self.userFavoritesBySportsArray.sort {
            $0.sportType < $1.sportType
        }

    }

    func needReloadSection(_ section: Int, tableView: UITableView) {

        guard let sportsSection = self.userFavoritesBySportsArray[safe: section] else { return }

        let rows = (0 ..< sportsSection.matches.count).map({ IndexPath(row: $0, section: section) }) // all section rows

        tableView.beginUpdates()
        tableView.reloadRows(at: rows, with: .automatic)
        tableView.endUpdates()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if self.userFavoritesBySportsArray.isEmpty {
            return 1
        }
        else {
            return self.userFavoritesBySportsArray.count
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let userFavorites = self.userFavoritesBySportsArray[safe: section] {
            return userFavorites.matches.count
        }
        else {
            return 1
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if !self.userFavoritesBySportsArray.isEmpty {
            if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
               let match = self.userFavoritesBySportsArray[safe: indexPath.section]?.matches[indexPath.row] {

                if let matchStatsViewModel = self.matchStatsViewModelForMatch?(match) {
                    cell.matchStatsViewModel = matchStatsViewModel
                }

                cell.setupWithMatch(match)
                cell.tappedMatchLineAction = { [weak self] match in
                    self?.didSelectMatchAction?(match)
                }
                cell.matchWentLive = { [weak self] in
                    self?.matchWentLiveAction?()
                }

//                cell.didTapFavoriteMatchAction = { [weak self] match in
//                    self?.didTapFavoriteMatchAction?(match)
//                }
                
                return cell
            }
        }
        else {
            return UITableViewCell()
        }

        fatalError()

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if !self.userFavoritesBySportsArray.isEmpty {
            guard
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SportSectionHeaderView.identifier) as? SportSectionHeaderView
            else {
                fatalError()
            }

            if let favoriteMatch = self.userFavoritesBySportsArray[section].matches.first {

                let sportName = favoriteMatch.sport.name
                let sportTypeId = favoriteMatch.sport.name

                headerView.configureHeader(title: sportName, sportTypeId: sportTypeId)

                headerView.sectionIndex = section

                headerView.didToggleHeaderViewAction = { [weak self, weak tableView] section in
                    guard
                        let weakSelf = self,
                        let weakTableView = tableView
                    else { return }

                    if weakSelf.collapsedSportSections.contains(section) {
                        weakSelf.collapsedSportSections.remove(section)
                    }
                    else {
                        weakSelf.collapsedSportSections.insert(section)
                    }
                    weakSelf.needReloadSection(section, tableView: weakTableView)

                    if weakSelf.collapsedSportSections.contains(section) {
                        headerView.setCollapseImage(isCollapsed: true)
                    }
                    else {
                        headerView.setCollapseImage(isCollapsed: false)
                    }

                }
                if self.collapsedSportSections.contains(section) {
                    headerView.setCollapseImage(isCollapsed: true)
                }
                else {
                    headerView.setCollapseImage(isCollapsed: false)
                }

            }

            return headerView
        }
        else {
            return UIView()
        }

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !self.userFavoritesBySportsArray.isEmpty {
            return 50
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if !self.userFavoritesBySportsArray.isEmpty {
            return 50
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.collapsedSportSections.contains(indexPath.section) {
            return 0
        }
        if self.userFavoritesBySportsArray.isEmpty {
            return 600
        }
        else {
            return UITableView.automaticDimension
        }

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.collapsedSportSections.contains(indexPath.section) {
            return 0
        }
        if self.userFavoritesBySportsArray.isEmpty {
            return 600
        }
        else {
            return StyleHelper.cardsStyleHeight() + 20
        }

    }

}

struct FavoriteSportMatches {
    var sportType: String
    var matches: [Match]
}
