//
//  MyFavoriteCompetitionsDataSource.swift
//  Sportsbook
//
//  Created by André Lascas on 11/02/2022.
//

import Foundation
import UIKit

class MyFavoriteCompetitionsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var competitions: [Competition] = [] {
        didSet {
            self.collapsedCompetitionsSections = []
        }
    }
    var collapsedCompetitionsSections: Set<Int> = []

    var didSelectMatchAction: ((Match) -> Void)?
    var didTapFavoriteCompetitionAction: ((Competition) -> Void)?
    var matchWentLiveAction: (() -> Void)?

    var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?

    var store: AggregatorStore

    init(favoriteCompetitions: [Competition], store: AggregatorStore) {
        self.store = store
        self.competitions = favoriteCompetitions
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return competitions.isEmpty ? 1 : competitions.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let competition = competitions[safe: section] {
            return competition.matches.count
        }
        else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !competitions.isEmpty {
            guard
                let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
                let competition = self.competitions[safe: indexPath.section],
                let match = competition.matches[safe: indexPath.row]
            else {
                fatalError()
            }

            if let matchStatsViewModel = self.matchStatsViewModelForMatch?(match) {
                cell.matchStatsViewModel = matchStatsViewModel
            }

            if self.store.hasMatchesInfoForMatch(withId: match.id) {
                cell.setupWithMatch(match, liveMatch: true, store: self.store)
            }
            else {
                cell.setupWithMatch(match, store: self.store)
            }
            
            cell.shouldShowCountryFlag(false)
            cell.tappedMatchLineAction = {
                self.didSelectMatchAction?(match)
            }
            cell.matchWentLive = {
                self.matchWentLiveAction?()
            }
            
            if let competition = self.competitions[safe: indexPath.section] {
                self.didTapFavoriteCompetitionAction?(competition)
            }
            
            return cell
        }
        else {
            guard
                let cell = tableView.dequeueCellType(EmptyCardTableViewCell.self)
                else {
                    fatalError()
                }
            cell.setDescription(primaryText: localized("empty_my_competitions"),
                                secondaryText: localized("empty_my_competitions"),
                                userIsLoggedIn: UserSessionStore.isUserLogged() )

            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TournamentTableViewHeader.identifier)
                as? TournamentTableViewHeader,
            let competition = self.competitions[safe: section]
        else {
            if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier)
                as? TitleTableViewHeader {
                headerView.configureWithTitle(localized("my_competitions"))
                return headerView
            }
            return UIView()
        }

        headerView.nameTitleLabel.text = competition.name
        headerView.countryFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: competition.venue?.isoCode ?? ""))
        headerView.sectionIndex = section
        headerView.competition = competition
        headerView.didToggleHeaderViewAction = { [weak self, weak tableView] section in
            guard
                let weakSelf = self,
                let weakTableView = tableView
            else { return }

            if weakSelf.collapsedCompetitionsSections.contains(section) {
                weakSelf.collapsedCompetitionsSections.remove(section)
            }
            else {
                weakSelf.collapsedCompetitionsSections.insert(section)
            }
            weakSelf.needReloadSection(section, tableView: weakTableView)

            if weakSelf.collapsedCompetitionsSections.contains(section) {
                headerView.collapseImageView.image = UIImage(named: "arrow_down_icon")
            }
            else {
                headerView.collapseImageView.image = UIImage(named: "arrow_up_icon")
            }
        }
        if self.collapsedCompetitionsSections.contains(section) {
            headerView.collapseImageView.image = UIImage(named: "arrow_down_icon")
        }
        else {
            headerView.collapseImageView.image = UIImage(named: "arrow_up_icon")
        }

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.collapsedCompetitionsSections.contains(indexPath.section) {
            return 0
        }
        if competitions.isEmpty {
            return 600
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.collapsedCompetitionsSections.contains(indexPath.section) {
            return 0
        }
        if competitions.isEmpty {
            return 600
        }
        return MatchWidgetCollectionViewCell.cellHeight + 20
    }

    func needReloadSection(_ section: Int, tableView: UITableView) {

        guard let competition = self.competitions[safe: section] else { return }

        let rows = (0 ..< competition.matches.count).map({ IndexPath(row: $0, section: section) }) // all section rows

        tableView.beginUpdates()
        tableView.reloadRows(at: rows, with: .automatic)
        tableView.endUpdates()
    }

}
