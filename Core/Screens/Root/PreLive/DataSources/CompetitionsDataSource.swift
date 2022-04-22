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
    var didSelectCompetitionAction: ((Competition) -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    
    var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?

    init(competitions: [Competition]) {
        self.competitions = competitions
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return competitions.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let competition = competitions[safe: section] {
            if competition.outrightMarkets > 0 {
                return competition.matches.count + 1
            }
            else {
                return competition.matches.count
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let competition = self.competitions[safe: indexPath.section]
        else {
            fatalError()
        }

        if competition.outrightMarkets > 0 {
            if indexPath.row == 0 {
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: OutrightCompetitionLineTableViewCell.identifier)
                        as? OutrightCompetitionLineTableViewCell
                else {
                    fatalError()
                }
                cell.configure(withViewModel: OutrightCompetitionLineViewModel(competition: competition))
                cell.didSelectCompetitionAction = { [weak self] competition in
                    self?.didSelectCompetitionAction?(competition)
                }
                return cell
            }
            else if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
                    let match = competition.matches[safe: indexPath.row - 1] {

                if let matchStatsViewModel = self.matchStatsViewModelForMatch?(match) {
                    cell.matchStatsViewModel = matchStatsViewModel
                }
                let store = Env.everyMatrixStorage as AggregatorStore

                cell.setupWithMatch(match, store: store)
                cell.shouldShowCountryFlag(false)
                cell.tappedMatchLineAction = {
                    self.didSelectMatchAction?(match)
                }
                cell.didTapFavoriteMatchAction = { [weak self] match in
                    self?.didTapFavoriteMatchAction?(match)
                }
                return cell
            }
        }
        else if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
                let match = competition.matches[safe: indexPath.row] {

            if let matchStatsViewModel = self.matchStatsViewModelForMatch?(match) {
                cell.matchStatsViewModel = matchStatsViewModel
            }
            let store = Env.everyMatrixStorage as AggregatorStore

            cell.setupWithMatch(match, store: store)
            cell.shouldShowCountryFlag(false)
            cell.tappedMatchLineAction = {
                self.didSelectMatchAction?(match)
            }
            cell.didTapFavoriteMatchAction = { [weak self] match in
                self?.didTapFavoriteMatchAction?(match)
            }
            return cell
        }
        fatalError()
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
            headerView.isCollapsed = true
        }
        else {
            headerView.isCollapsed = false
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
            return .leastNonzeroMagnitude
        }

        if let competition = competitions[safe: indexPath.section] {
            if competition.outrightMarkets > 0 && indexPath.row == 0 {
                return 105
            }
            else {
                return MatchWidgetCollectionViewCell.cellHeight + 20
            }
        }
        return .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.collapsedCompetitionsSections.contains(indexPath.section) {
            return .leastNonzeroMagnitude
        }

        if let competition = competitions[safe: indexPath.section] {
            if competition.outrightMarkets > 0 && indexPath.row == 0 {
                return 105
            }
            else {
                return MatchWidgetCollectionViewCell.cellHeight + 20
            }
        }
        return .leastNonzeroMagnitude
    }

    func needReloadSection(_ section: Int, tableView: UITableView) {

        guard let competition = self.competitions[safe: section] else { return }

        let rows = (0 ..< competition.matches.count).map({ IndexPath(row: $0, section: section) }) // all section rows

        tableView.beginUpdates()
        tableView.reloadRows(at: rows, with: .automatic)
        tableView.endUpdates()
    }

}

class FilteredOutrightCompetitionsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var outrightCompetitions: [Competition]

    var didSelectCompetitionAction: ((Competition) -> Void)?
    var didTapFavoriteCompetitionAction: ((Competition) -> Void)?

    init(outrightCompetitions: [Competition]) {
        self.outrightCompetitions = outrightCompetitions
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return outrightCompetitions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let competition = self.outrightCompetitions[safe: indexPath.row]
        else {
            fatalError()
        }

        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: OutrightCompetitionLargeLineTableViewCell.identifier)
                as? OutrightCompetitionLargeLineTableViewCell
        else {
            fatalError()
        }
        cell.configure(withViewModel: OutrightCompetitionLargeLineViewModel(competition: competition))
        cell.didSelectCompetitionAction = { [weak self] competition in
            self?.didSelectCompetitionAction?(competition)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

}
