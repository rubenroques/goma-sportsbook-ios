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

    // Variables
    var viewModel: SearchViewModel
    var cancellables = Set<AnyCancellable>()

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
        }
    }

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

        self.view.backgroundColor = UIColor.App.mainBackground

        self.topView.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.mainBackground

        self.searchView.backgroundColor = .clear

        self.cancelButton.backgroundColor = .clear
        self.cancelButton.tintColor = UIColor.App.headingMain

        self.emptySearchLabel.textColor = UIColor.App.fadeOutHeading
    }

    func commonInit() {

        self.searchBarView.searchBarStyle = UISearchBar.Style.prominent
        self.searchBarView.sizeToFit()
        self.searchBarView.isTranslucent = false
        self.searchBarView.backgroundImage = UIImage()
        self.searchBarView.tintColor = .white
        self.searchBarView.barTintColor = .white
        self.searchBarView.backgroundImage = UIColor.App.mainBackground.image()

        if let textfield = searchBarView.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.App.secondaryBackground
            textfield.textColor = UIColor.App.headingMain
            textfield.tintColor = UIColor.App.headingMain
            textfield.font = AppFont.with(type: .semibold, size: 14)
            textfield.attributedPlaceholder = NSAttributedString(string: localized("search_for_teams_competitions"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor:
                                                                                UIColor.App.headerTextField, NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 14)])

            if let glassIconView = textfield.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = UIColor.App.headerTextField
            }
        }

        self.searchBarView.delegate = self

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.containerView.addGestureRecognizer(backgroundTapGesture)

        self.cancelButton.setTitle(localized("cancel"), for: .normal)
        self.cancelButton.titleLabel?.font = AppFont.with(type: .semibold, size: 14)

        // TableView
        self.tableView.backgroundColor = .clear
        self.tableView.backgroundView?.backgroundColor = .clear

        self.tableView.separatorStyle = .none
        self.tableView.register(MatchLineTableViewCell.nib, forCellReuseIdentifier: MatchLineTableViewCell.identifier)
        self.tableView.register(BannerScrollTableViewCell.nib, forCellReuseIdentifier: BannerScrollTableViewCell.identifier)
        self.tableView.register(LoadingMoreTableViewCell.nib, forCellReuseIdentifier: LoadingMoreTableViewCell.identifier)
        self.tableView.register(TitleTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TitleTableViewHeader.identifier)
        self.tableView.register(TournamentTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TournamentTableViewHeader.identifier)
        self.tableView.register(ActivationAlertScrollableTableViewCell.nib, forCellReuseIdentifier: ActivationAlertScrollableTableViewCell.identifier)
        self.tableView.register(EmptyCardTableViewCell.nib, forCellReuseIdentifier: EmptyCardTableViewCell.identifier)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.estimatedRowHeight = 155
        self.tableView.estimatedSectionHeaderHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0

        self.showSearchResultsTableView = false

        //Empty Search View
        self.emptySearchLabel.text = localized("no_recent_searches")
        self.emptySearchLabel.font = AppFont.with(type: .bold, size: 16)
    }

    func setupPublishers() {

        self.viewModel.recentSearchesPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                if !value.isEmpty {
                    self?.emptySearchLabel.text = self?.viewModel.recentSearchesPublisher.value[0]
                }
                else {
                    //self?.showSearchResultsTableView = true
                }
            })
            .store(in: &cancellables)

        self.viewModel.searchInfoPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] searchInfo in
                if !searchInfo.isEmpty {
                    self?.showSearchResultsTableView = true
                    self?.tableView.reloadData()
                }
                else {
                    self?.showSearchResultsTableView = false
                }
            })
            .store(in: &cancellables)

    }

    @IBAction private func didTapCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func didTapBackground() {
        self.searchBarView.resignFirstResponder()
    }

}

extension SearchViewController: UISearchBarDelegate {

    func searchMatches(recentSearch: String = "") {

        if recentSearch != "" {
            self.viewModel.addRecentSearch(search: recentSearch)
        }

        self.viewModel.fetchSearchInfo()

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count ?? 0 > 2 {
            self.searchMatches()
        }
        else {
            self.showSearchResultsTableView = false
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let recentSearch = searchBar.text {
            self.searchMatches(recentSearch: recentSearch)
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
        return self.viewModel.searchInfoPublisher.value.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.searchInfoPublisher.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self) {

            return cell
        }
        return UITableViewCell()

    }

//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        return self.viewModel.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
//    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier) as? TitleTableViewHeader
        else {
            fatalError()
        }
        headerView.configureWithTitle("Match")
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155

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
