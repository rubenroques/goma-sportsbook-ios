//
//  SearchViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 20/01/2022.
//

import UIKit
import Combine

class SearchViewController: UIViewController {

    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var searchView: UIView!
    @IBOutlet private weak var searchBarView: UISearchBar!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptySearchView: UIView!
    @IBOutlet private weak var emptySearchLabel: UILabel!
    @IBOutlet private weak var noResultsView: UIView!
    @IBOutlet private weak var noResultsImageView: UIImageView!
    @IBOutlet private weak var noResultsLabel: UILabel!
    @IBOutlet private weak var activityIndicatorBaseView: UIView!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!

    // Variables
    var viewModel: SearchViewModel
    var cancellables = Set<AnyCancellable>()

    var didSelectMatchAction: ((Match) -> Void)?
    var didSelectCompetitionAction: ((String) -> Void)?

    var showSearchResultsTableView: Bool = false {
        didSet {
            if showSearchResultsTableView {
                self.tableView.isHidden = false
                self.emptySearchView.isHidden = true
            }
            else {
                self.tableView.isHidden = true
                self.emptySearchView.isHidden = false
            }
            self.noResultsView.isHidden = true
        }
    }

    var showNoResultsView: Bool = false {
        didSet {
            if showNoResultsView {
                self.tableView.isHidden = true
                self.noResultsView.isHidden = false
            }
            else {
                self.tableView.isHidden = false
                self.noResultsView.isHidden = true
            }
            self.emptySearchView.isHidden = true
        }
    }

    var searchTextPublisher: CurrentValueSubject<String, Never> = .init("")

    init() {
        self.viewModel = SearchViewModel()
        super.init(nibName: "SearchViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        commonInit()
        setupWithTheme()

        setupPublishers()

    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App2.backgroundPrimary

        self.topView.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.contentBackground

        self.searchView.backgroundColor = .clear

        self.cancelButton.backgroundColor = .clear
        self.cancelButton.tintColor = UIColor.App2.textPrimary

        self.emptySearchLabel.textColor = UIColor.App.fadeOutHeading

        self.noResultsView.backgroundColor = .clear
        self.noResultsImageView.backgroundColor = .clear

        self.noResultsLabel.textColor = UIColor.App2.textPrimary

        self.activityIndicatorBaseView.backgroundColor = UIColor.App.contentBackground
    }

    func commonInit() {

        self.searchBarView.searchBarStyle = UISearchBar.Style.prominent
        self.searchBarView.sizeToFit()
        self.searchBarView.isTranslucent = false
        self.searchBarView.backgroundImage = UIImage()
        self.searchBarView.tintColor = .white
        self.searchBarView.barTintColor = .white
        self.searchBarView.backgroundImage = UIColor.App.contentBackground.image()

        if let textfield = searchBarView.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.App2.backgroundSecondary
            textfield.textColor = UIColor.App2.textPrimary
            textfield.tintColor = UIColor.App2.textPrimary
            textfield.font = AppFont.with(type: .semibold, size: 14)
            textfield.attributedPlaceholder = NSAttributedString(string: localized("search_for_teams_competitions"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor:
                                                                                UIColor.App2.inputTextTitle, NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 14)])

            if let glassIconView = textfield.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = UIColor.App2.inputTextTitle
            }
        }

        self.searchBarView.delegate = self

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.containerView.addGestureRecognizer(backgroundTapGesture)

        self.cancelButton.setTitle(localized("cancel"), for: .normal)
        self.cancelButton.titleLabel?.font = AppFont.with(type: .semibold, size: 14)

        // TableView
        self.tableView.backgroundColor = UIColor.App2.backgroundSecondary
        self.tableView.backgroundView?.backgroundColor = .clear

        self.tableView.separatorStyle = .none
        self.tableView.register(MatchLineTableViewCell.nib, forCellReuseIdentifier: MatchLineTableViewCell.identifier)
        self.tableView.register(CompetitionSearchTableViewCell.nib, forCellReuseIdentifier: CompetitionSearchTableViewCell.identifier)
        self.tableView.register(LoadingMoreTableViewCell.nib, forCellReuseIdentifier: LoadingMoreTableViewCell.identifier)
        self.tableView.register(SearchTitleSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: SearchTitleSectionHeaderView.identifier)
        self.tableView.register(RecentSearchHeaderView.nib, forHeaderFooterViewReuseIdentifier: RecentSearchHeaderView.identifier)
        self.tableView.register(RecentSearchTableViewCell.nib, forCellReuseIdentifier: RecentSearchTableViewCell.identifier)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.estimatedRowHeight = 155
        self.tableView.estimatedSectionHeaderHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0

        self.showSearchResultsTableView = false

        // Empty Search View
        self.emptySearchLabel.text = localized("no_recent_searches")
        self.emptySearchLabel.font = AppFont.with(type: .bold, size: 16)

        // No Results View
        self.noResultsView.isHidden = true

        self.noResultsImageView.image = UIImage(named: "no_search_results_icon")
        self.noResultsImageView.layer.cornerRadius = self.noResultsImageView.frame.width/2

        self.noResultsLabel.text = ""
        self.noResultsLabel.font = AppFont.with(type: .bold, size: 22)

        self.activityIndicatorBaseView.isHidden = true
    }

    func setupPublishers() {

        self.viewModel.recentSearchesPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                if !value.isEmpty {
                    self?.showSearchResultsTableView = true
                    self?.tableView.reloadData()
                }
                else {
                    self?.showSearchResultsTableView = false
                }
            })
            .store(in: &cancellables)

        self.viewModel.searchMatchesPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] searchInfo in

                if !searchInfo.isEmpty {
                    self?.activityIndicatorBaseView.isHidden = true
                    self?.showNoResultsView = false
                    self?.showSearchResultsTableView = true
                    self?.tableView.reloadData()
                }
                else if searchInfo.isEmpty && self?.viewModel.hasDoneSearch == true {
                    self?.activityIndicatorBaseView.isHidden = true
                    self?.showSearchResultsTableView = false
                    self?.configureNoResultsViewText()
                    self?.showNoResultsView = true
                }

            })
            .store(in: &cancellables)

        self.didSelectMatchAction = { match in

            if self.viewModel.matchesInfoForMatch[match.id] != nil {
                let matchDetailsViewController = MatchDetailsViewController(matchMode: .live, match: match)

                self.present(matchDetailsViewController, animated: true, completion: nil)
            }
            else {
                let matchDetailsViewController = MatchDetailsViewController(match: match)

                self.present(matchDetailsViewController, animated: true, completion: nil)
            }
        }

        self.searchTextPublisher
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                if value.count > 2 {
                    self?.searchMatches(searchQuery: value)
                }
                else if value.count < 1 {
                    self?.viewModel.clearData()
                    self?.viewModel.isEmptySearch = true
                    self?.showNoResultsView = false
                    if let recentSearchEmpty = self?.viewModel.recentSearchesPublisher.value.isEmpty {
                        if recentSearchEmpty {
                            self?.showSearchResultsTableView = false
                        }
                        else {
                            self?.showSearchResultsTableView = true
                        }
                        self?.tableView.reloadData()
                    }
                }
            })
            .store(in: &cancellables)

    }

    func configureNoResultsViewText() {
        if let searchBarText = self.searchBarView.text {
            let noResultsTextRaw = localized("no_results_for")
            let noResultsText = noResultsTextRaw.replacingOccurrences(of: "%s", with: searchBarText)
            self.noResultsLabel.text = noResultsText

        }
    }

    @IBAction private func didTapCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func didTapBackground() {
        self.searchBarView.resignFirstResponder()
    }

}

extension SearchViewController: UISearchBarDelegate {

    func searchMatches(searchQuery: String = "") {

        self.activityIndicatorBaseView.isHidden = false

        if searchQuery != "" {
            self.viewModel.fetchSearchInfo(searchQuery: searchQuery)
        }
        else {
            self.showSearchResultsTableView = false
        }

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if let recentSearch = searchBar.text {
            self.searchTextPublisher.send(recentSearch)
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let recentSearch = searchBar.text {

            if recentSearch != "" && recentSearch.count > 2 {
                self.viewModel.addRecentSearch(search: recentSearch)
            }
        }
        self.searchBarView.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarView.text = ""
        self.searchMatches()
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        if !self.viewModel.isEmptySearch {
        return self.viewModel.sportMatchesArrayPublisher.value.count
        }
        else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.viewModel.isEmptySearch {
            return self.viewModel.sportMatchesArrayPublisher.value[section].matches.count
        }
        else {
            return self.viewModel.recentSearchesPublisher.value.count
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if !self.viewModel.isEmptySearch {
            let cellInfo = self.viewModel.sportMatchesArrayPublisher.value[indexPath.section].matches[indexPath.row]

            switch cellInfo {

            case .match(let match):

                if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self) {

                    if self.viewModel.matchesInfoForMatchPublisher.value.contains(match.id) {
                        cell.setupWithMatch(match, liveMatch: true)
                    }
                    else {
                        cell.setupWithMatch(match)
                    }

                    cell.tappedMatchLineAction = {
                        self.didSelectMatchAction?(match)
                    }

                    return cell
                }

            case .competition(let competition):
                if let cell = tableView.dequeueCellType(CompetitionSearchTableViewCell.self) {

                    if let cellCompetition = competition.name, let cellVenueId = competition.venueId {
                        //cell.setTitle(title: "\(cellCompetition)")
                        let location = self.viewModel.location(forId: cellVenueId)
                        cell.setCellValues(title: cellCompetition, flagCode: location?.code ?? "", flagId: location?.id ?? "")
                        cell.tappedCompetitionCellAction = {
                            self.didSelectCompetitionAction?(competition.id)
                        }
                    }
                    return cell
                }
            }
        }
        else {
            if let cell = tableView.dequeueCellType(RecentSearchTableViewCell.self) {

                let recentSearchTitle = self.viewModel.recentSearchesPublisher.value[indexPath.row]

                cell.setTitle(title: recentSearchTitle)

                cell.didTapCellAction = { [weak self] in
                    self?.searchBarView.text = recentSearchTitle
                    self?.searchMatches(searchQuery: recentSearchTitle)
                }

                cell.didTapClearButtonAction = { [weak self] in
                    self?.viewModel.clearRecentSearchByString(search: recentSearchTitle)
                }

                if indexPath.row == self.viewModel.recentSearchesPublisher.value.count - 1 {
                    cell.hideSeparatorLineView()
                }

                return cell
            }

        }
        return UITableViewCell()

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if !self.viewModel.isEmptySearch {
            guard
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SearchTitleSectionHeaderView.identifier) as? SearchTitleSectionHeaderView
            else {
                fatalError()
            }

            let searchEvent = self.viewModel.sportMatchesArrayPublisher.value[section].matches.first

            var eventName = ""
            switch searchEvent {
            case .match(let match):
                if let matchSportName = match.sportName {
                    eventName = "\(matchSportName)"
                }
            case .competition(let competition):
                if let competitionSportName = competition.sportName {
                    eventName = "\(competitionSportName)"
                }
            default:
                ()
            }

            let resultsLabel = self.viewModel.setHeaderSectionTitle(section: section)

            headerView.configureLabels(nameText: "\(eventName) - ", countText: resultsLabel)

            return headerView
        }
        else {
            guard
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: RecentSearchHeaderView.identifier) as? RecentSearchHeaderView
            else {
                fatalError()
            }

            headerView.clearAllAction = {
                self.viewModel.clearRecentSearchData()
            }

            return headerView
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if !self.viewModel.isEmptySearch {
            let cellInfo = self.viewModel.sportMatchesArrayPublisher.value[indexPath.section].matches[indexPath.row]

            switch cellInfo {
            case .match:
                return MatchWidgetCollectionViewCell.cellHeight + 20
            case .competition:
                return UITableView.automaticDimension
            }
        }
        else {
            return 50
        }

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        if !self.viewModel.isEmptySearch {
            let cellInfo = self.viewModel.sportMatchesArrayPublisher.value[indexPath.section].matches[indexPath.row]

            switch cellInfo {
            case .match:
                return MatchWidgetCollectionViewCell.cellHeight + 20
            case .competition:
                return 56
            }
        }
        else {
            return 50
        }

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54

    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 54

    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}
