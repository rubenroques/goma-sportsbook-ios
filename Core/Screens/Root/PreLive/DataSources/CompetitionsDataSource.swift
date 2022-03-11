//
//  CompetitionsDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 18/01/2022.
//

import UIKit

class CompetitionsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var competitions: [Competition] = [] {
        didSet {
            self.collapsedCompetitionsSections = []
        }
    }
    var collapsedCompetitionsSections: Set<Int> = []

    var didSelectMatchAction: ((Match) -> Void)?

    var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?

    init(competitions: [Competition]) {
        self.competitions = competitions
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return competitions.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let competition = competitions[safe: section] {
            return competition.matches.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        let store = Env.everyMatrixStorage as AggregatorStore

        cell.setupWithMatch(match, store: store)
        cell.shouldShowCountryFlag(false)
        cell.tappedMatchLineAction = {
            self.didSelectMatchAction?(match)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TournamentTableViewHeader.identifier)
                as? TournamentTableViewHeader,
            let competition = self.competitions[safe: section]
        else {
            fatalError()
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
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.collapsedCompetitionsSections.contains(indexPath.section) {
            return 0
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

