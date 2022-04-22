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
    private lazy var betslipButtonView: UIView = Self.createBetslipButtonView()
    private lazy var betslipCountLabel: UILabel = Self.createBetslipCountLabel()

    // Variables
    var viewModel: SearchViewModel
    var cancellables = Set<AnyCancellable>()

    var didSelectMatchAction: ((Match) -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
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

        self.setupSubviews()
        commonInit()
        setupWithTheme()

        setupPublishers()

        self.view.layoutSubviews()

        self.betslipCountLabel.isHidden = true

        let tapBetslipView = UITapGestureRecognizer(target: self, action: #selector(didTapBetslipView))
        betslipButtonView.addGestureRecognizer(tapBetslipView)

        self.searchBarView.becomeFirstResponder()

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.betslipButtonView.layer.cornerRadius = self.betslipButtonView.frame.height / 2
        self.betslipCountLabel.layer.cornerRadius = self.betslipCountLabel.frame.height / 2
    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topView.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundTertiary

        self.searchView.backgroundColor = .clear

        self.cancelButton.backgroundColor = .clear
        self.cancelButton.tintColor = UIColor.App.highlightPrimary
        self.cancelButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.emptySearchLabel.textColor = UIColor.App.textSecondary

        self.noResultsView.backgroundColor = .clear
        self.noResultsImageView.backgroundColor = .clear

        self.noResultsLabel.textColor = UIColor.App.textPrimary

        self.activityIndicatorBaseView.backgroundColor = UIColor.App.backgroundTertiary

        self.betslipCountLabel.backgroundColor = UIColor.App.alertError
        self.betslipCountLabel.textColor = UIColor.App.buttonTextPrimary

        self.betslipButtonView.backgroundColor = UIColor.App.highlightPrimary
    }

    func commonInit() {

        self.searchBarView.searchBarStyle = UISearchBar.Style.prominent
        self.searchBarView.sizeToFit()
        self.searchBarView.isTranslucent = false
        self.searchBarView.backgroundImage = UIImage()
        self.searchBarView.tintColor = .white
        self.searchBarView.barTintColor = .white
        self.searchBarView.backgroundImage = UIColor.App.backgroundTertiary.image()

        if let textfield = searchBarView.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.App.backgroundSecondary
            textfield.textColor = UIColor.App.textPrimary
            textfield.tintColor = UIColor.App.textPrimary
            textfield.font = AppFont.with(type: .semibold, size: 14)
            textfield.attributedPlaceholder = NSAttributedString(string: localized("search_for_teams_competitions"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor:
                                                                                UIColor.App.inputTextTitle, NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 14)])

            if let glassIconView = textfield.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = UIColor.App.inputTextTitle
            }
        }

        self.searchBarView.delegate = self

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.containerView.addGestureRecognizer(backgroundTapGesture)

        self.cancelButton.setTitle(localized("cancel"), for: .normal)
        self.cancelButton.titleLabel?.font = AppFont.with(type: .semibold, size: 14)

        // TableView
        self.tableView.backgroundColor = UIColor.App.backgroundPrimary
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
    func presentLoginViewController() {
      let loginViewController = Router.navigationController(with: LoginViewController())
      self.present(loginViewController, animated: true, completion: nil)
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
            let matchViewModel = MatchDetailsViewModel(match: match)
            let matchDetailsViewController = MatchDetailsViewController(viewModel: matchViewModel)
            self.present(matchDetailsViewController, animated: true, completion: nil)


        }
        
        self.didTapFavoriteMatchAction = { match in
            if !UserSessionStore.isUserLogged() {
                self.presentLoginViewController()
            }
            else {
                self.viewModel.markAsFavorite(match: match)
                self.tableView.reloadData()
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

        Env.betslipManager.bettingTicketsPublisher
            .map(\.count)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] betslipValue in
                if betslipValue == 0 {
                    self?.betslipCountLabel.isHidden = true
                }
                else {
                    self?.betslipCountLabel.text = "\(betslipValue)"
                    self?.betslipCountLabel.isHidden = false
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

    func openBetslipModal() {
        let betslipViewController = BetslipViewController()
        betslipViewController.willDismissAction = { [weak self] in
            self?.tableView.reloadData()
        }

        self.present(Router.navigationController(with: betslipViewController), animated: true, completion: nil)
    }

    private func openMatchDetailsScreen(match: Match) {
        let matchDetailsViewController = MatchDetailsViewController(viewModel: MatchDetailsViewModel(match: match))
        self.navigationController?.pushViewController(matchDetailsViewController, animated: true)
    }

    private func openCompetitionDetailsScreen(competition: EveryMatrix.Tournament) {
        let sport = Sport(id: competition.sportId ?? "")
        let competitionId = competition.id
        let competitionDetailsViewModel = CompetitionDetailsViewModel(competitionsIds: [competitionId], sport: sport, store: AggregatorsRepository())
        let competitionDetailsViewController = CompetitionDetailsViewController(viewModel: competitionDetailsViewModel)
        self.navigationController?.pushViewController(competitionDetailsViewController, animated: true)
    }

    @IBAction private func didTapCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func didTapBackground() {
        self.searchBarView.resignFirstResponder()
    }

    @objc func didTapBetslipView() {
        // self.didTapBetslipButtonAction?()
        self.openBetslipModal()
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

                    let store = self.viewModel as AggregatorStore

                    if store.hasMatchesInfoForMatch(withId: match.id) {
                        cell.setupWithMatch(match, liveMatch: true, store: store)
                    }
                    else {
                        cell.setupWithMatch(match, store: store)
                    }

                    cell.tappedMatchLineAction = {
                        self.openMatchDetailsScreen(match: match)
                    }
                    
                    cell.didTapFavoriteMatchAction = { [weak self] match in
                        self?.didTapFavoriteMatchAction?(match)
                    }
                    cell.matchStatsViewModel = self.viewModel.matchStatsViewModel(forMatch: match)
                    
                    return cell
                }

            case .competition(let competition):
                if let cell = tableView.dequeueCellType(CompetitionSearchTableViewCell.self) {

                    if let cellCompetition = competition.name, let cellVenueId = competition.venueId {
                        // cell.setTitle(title: "\(cellCompetition)")
                        let location = self.viewModel.location(forId: cellVenueId)
                        cell.setCellValues(title: cellCompetition, flagCode: location?.code ?? "", flagId: location?.id ?? "")
                        cell.tappedCompetitionCellAction = {
                            self.openCompetitionDetailsScreen(competition: competition)
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

//
// MARK: Subviews initialization and setup
//
extension SearchViewController {

    private static func createBetslipButtonView() -> UIView {
        let betslipButtonView = UIView()
        betslipButtonView.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(named: "betslip_button_icon")
        betslipButtonView.addSubview(iconImageView)

        NSLayoutConstraint.activate([
            betslipButtonView.widthAnchor.constraint(equalToConstant: 56),
            betslipButtonView.widthAnchor.constraint(equalTo: betslipButtonView.heightAnchor),

            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: betslipButtonView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: betslipButtonView.centerYAnchor),
        ])

        return betslipButtonView
    }

    private static func createBetslipCountLabel() -> UILabel {
        let betslipCountLabel = UILabel()
        betslipCountLabel.translatesAutoresizingMaskIntoConstraints = false
        betslipCountLabel.textColor = UIColor.App.textPrimary
        betslipCountLabel.backgroundColor = UIColor.App.bubblesPrimary
        betslipCountLabel.font = AppFont.with(type: .semibold, size: 10)
        betslipCountLabel.textAlignment = .center
        betslipCountLabel.clipsToBounds = true
        betslipCountLabel.layer.masksToBounds = true
        betslipCountLabel.text = "0"
        return betslipCountLabel
    }

    private func setupSubviews() {

        self.betslipButtonView.addSubview(self.betslipCountLabel)

        self.containerView.addSubview(self.betslipButtonView)

        self.initConstraints()

        self.containerView.layoutSubviews()
    }

    private func initConstraints() {

        // Betslip
        NSLayoutConstraint.activate([
            self.betslipCountLabel.trailingAnchor.constraint(equalTo: self.betslipButtonView.trailingAnchor, constant: 2),
            self.betslipCountLabel.topAnchor.constraint(equalTo: self.betslipButtonView.topAnchor, constant: -3),

            self.betslipButtonView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
            self.betslipButtonView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -40),

            self.betslipCountLabel.widthAnchor.constraint(equalToConstant: 20),
            self.betslipCountLabel.widthAnchor.constraint(equalTo: self.betslipCountLabel.heightAnchor),
        ])
    }

}
