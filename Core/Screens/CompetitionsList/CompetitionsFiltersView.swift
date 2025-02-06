//
//  CompetitionsFiltersView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/10/2021.
//

import UIKit
import Combine
import OrderedCollections
import SwiftUI

class CompetitionsFiltersView: UIView {

    // MARK: - Views
    private lazy var headerStackView: UIStackView = Self.createHeaderStackView()
    private lazy var headerBaseView: UIView = Self.createHeaderBaseView()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var clearButton: UIButton = Self.createClearButton()
    private lazy var searchBarBaseView: UIView = Self.createSearchBarBaseView()
    private lazy var searchBarView: UISearchBar = Self.createSearchBarView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var smallTitleLabel: UILabel = Self.createSmallTitleLabel()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var loadingView: UIActivityIndicatorView = Self.createLoadingView()

    // MARK: - Properties
    var applyFiltersAction: (([String]) -> Void)?
    var tapHeaderViewAction: (() -> Void)?

    var didTapCompetitionNavigationAction: (String) -> Void = { _ in }

    private var competitionSelectedIds: [String: Set<String>] = [:]
    private var initialSelectedIds: Set<String> = []

    private var cancellables: Set<AnyCancellable> = []

    var selectedIds: CurrentValueSubject<Set<String>, Never> = .init([])
    var expandedCellsDictionary: [String: Bool] = [:]
    var loadedExpandedCells: [String] = []

    var shouldLoadCompetitions: ((String) -> Void)?
    var expandCompetitionLoaded: [String] = []

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.loadingView.startAnimating()
            }
            else {
                self.loadingView.stopAnimating()
            }
        }
    }

    var competitions: [CompetitionFilterSectionViewModel] = [] {
        didSet {
            if self.loadedExpandedCells.isEmpty {
                self.expandedCellsDictionary = [:]
                self.competitions.forEach({ competition in
                    //self.expandedCellsDictionary[competition.id] = (competition.id == "0") // Only popular competition will be true, to appear opened by default
                    self.expandedCellsDictionary[competition.id] = (competition.id == self.competitions.first?.id)

                    if self.expandedCellsDictionary[competition.id] == true {
                        self.loadedExpandedCells.append(competition.id)
                        self.expandCompetitionLoaded.append(competition.id)
                    }
                })

                self.searchBarView.text = nil
            }
            else {
                self.competitions.forEach({ competition in
                    if self.expandedCellsDictionary[competition.id] == nil {
                        self.expandedCellsDictionary[competition.id] = true
                        self.loadedExpandedCells.append(competition.id)
                    }
                    else {

                        if self.expandCompetitionLoaded.isNotEmpty,
                           self.expandCompetitionLoaded.contains(competition.id) {
                            self.expandedCellsDictionary[competition.id] = true

                        }
                        else {
                            self.expandedCellsDictionary[competition.id] = false

                        }

                    }

                })

            }
            if self.searchBarView.text != "" {
                self.applyFilters()
            }
            else {
                self.filteredCompetitions = competitions
            }
        }
    }
    var filteredCompetitions: [CompetitionFilterSectionViewModel] = [] {
        didSet {
            let selectedCells = tableView.indexPathsForSelectedRows ?? []

            self.reloadTableView()

            for selectedCellIndexPath in selectedCells {
                tableView.selectRow(at: selectedCellIndexPath, animated: false, scrollPosition: .none)
            }
        }
    }

    enum SizeState {
        case opened
        case bar
        case line
    }

    var state: SizeState = .opened {
        didSet {
            switch self.state {
            case .opened:
                self.headerBaseView.backgroundColor = UIColor.App.backgroundSecondary
                self.titleLabel.textColor = UIColor.App.textPrimary
                self.smallTitleLabel.textColor = UIColor.App.textPrimary

                self.initialSelectedIds = self.selectedIds.value
                self.closeButton.setTitle(localized("close"), for: .normal)

                UIView.animate(withDuration: 0.4) {
                    self.titleLabel.alpha = 1.0
                    self.smallTitleLabel.alpha = 0.0
                    self.closeButton.alpha = 1.0
                    self.clearButton.alpha = 1.0
                }
            case .bar:
                self.headerBaseView.backgroundColor = UIColor.App.highlightSecondary
                self.titleLabel.textColor = UIColor.App.buttonTextPrimary
                self.smallTitleLabel.textColor = UIColor.App.buttonTextPrimary

                UIView.animate(withDuration: 0.4) {
                    self.titleLabel.alpha = 1.0
                    self.smallTitleLabel.alpha = 0.0
                    self.closeButton.alpha = 0.0
                    self.clearButton.alpha = 0.0
                }
            case .line:
                self.headerBaseView.backgroundColor = UIColor.App.highlightSecondary
                self.titleLabel.textColor = UIColor.App.buttonTextPrimary
                self.smallTitleLabel.textColor = UIColor.App.buttonTextPrimary

                UIView.animate(withDuration: 0.4) {
                    self.titleLabel.alpha = 0.0
                    self.smallTitleLabel.alpha = 1.0
                    self.closeButton.alpha = 0.0
                    self.clearButton.alpha = 0.0
                }
            }

        }
    }

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupWithTheme()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
        setupWithTheme()
    }

    // MARK: - View Setup Methods
    private func setupSubviews() {
        addSubview(headerStackView)
        headerStackView.addArrangedSubview(headerBaseView)
        headerStackView.addArrangedSubview(searchBarBaseView)

        headerBaseView.addSubview(titleLabel)
        headerBaseView.addSubview(smallTitleLabel)
        headerBaseView.addSubview(closeButton)
        headerBaseView.addSubview(clearButton)

        searchBarBaseView.addSubview(searchBarView)

        addSubview(tableView)
        addSubview(loadingView)
    }

    private func commonInit() {
        setupSubviews()
        initConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.headerBaseView.roundCorners(corners: [.topRight, .topLeft], radius: 20)

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        switch self.state {
        case .opened:
            self.headerBaseView.backgroundColor = UIColor.App.backgroundSecondary
            self.titleLabel.textColor = UIColor.App.textPrimary
            self.smallTitleLabel.textColor = UIColor.App.textPrimary
        case .bar:
            self.headerBaseView.backgroundColor = UIColor.App.highlightSecondary
            self.titleLabel.textColor = UIColor.App.buttonTextPrimary
            self.smallTitleLabel.textColor = UIColor.App.buttonTextPrimary
        case .line:
            self.headerBaseView.backgroundColor = UIColor.App.highlightSecondary
            self.titleLabel.textColor = UIColor.App.buttonTextPrimary
            self.smallTitleLabel.textColor = UIColor.App.buttonTextPrimary
        }

        self.searchBarBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.tableView.backgroundView?.backgroundColor = UIColor.App.backgroundSecondary
        self.tableView.backgroundColor = UIColor.App.backgroundSecondary

        self.closeButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        self.closeButton.setTitleColor(UIColor.App.highlightPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.closeButton.setTitleColor(UIColor.App.highlightPrimary.withAlphaComponent(0.4), for: .disabled)

        self.clearButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        self.clearButton.setTitleColor(UIColor.App.highlightPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.clearButton.setTitleColor(UIColor.App.highlightPrimary.withAlphaComponent(0.4), for: .disabled)

        self.searchBarView.tintColor = .white
        self.searchBarView.barTintColor = .white
        self.searchBarView.backgroundImage = UIColor.App.backgroundSecondary.image()

        if let textfield = searchBarView.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.App.backgroundPrimary
            textfield.textColor = UIColor.App.textSecondary
            textfield.tintColor = .white
            textfield.attributedPlaceholder = NSAttributedString(string: localized("search_field_competitions"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor:
                                                                                UIColor.App.textSecondary])

            if let glassIconView = textfield.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = UIColor.App.backgroundSecondary
            }
        }
    }

    func selectIds(_ ids: [String]) {
        self.selectedIds.send(Set.init(ids))
    }

    private func insertCompetition(withId id: String, countryGroupId: String) {

        for sectionGroup in self.filteredCompetitions {
            if sectionGroup.cells.map(\.id).contains(where: { $0 == id }) {

                if var competitions = self.competitionSelectedIds[sectionGroup.id] {
                    competitions.insert(id)
                    self.competitionSelectedIds[sectionGroup.id] = competitions
                }
                else {
                    self.competitionSelectedIds[sectionGroup.id] = [id]
                }
            }
        }

    }

    private func removeCompetition(withId id: String, countryGroupId: String) {

        for sectionGroup in self.filteredCompetitions {
            if sectionGroup.cells.map(\.id).contains(where: { $0 == id }) {

                if var competitions = self.competitionSelectedIds[sectionGroup.id] {
                    competitions.remove(id)
                    self.competitionSelectedIds[sectionGroup.id] = competitions
                }
                else {
                    self.competitionSelectedIds[sectionGroup.id] = []
                }

            }
        }

    }

    @IBAction private func didTapApplyButton() {
        self.applyFiltersAction?(Array(self.selectedIds.value))
    }

    @IBAction private func didTapClearButton() {
        self.resetSelection()
    }

    @objc func didSwipeDownToClose() {
        self.didTapApplyButton()
    }

    @objc func didTapHeaderView() {
        self.tapHeaderViewAction?()
    }

    @objc func didTapBackground() {
        self.searchBarView.resignFirstResponder()
    }

    func resetSelection() {
        self.selectedIds.send([])
        self.competitionSelectedIds = [:]
        self.loadedExpandedCells = []
        self.expandCompetitionLoaded = []

        self.reloadTableView()
    }

    func reloadTableView() {
        self.tableView.reloadData()

        self.layoutIfNeeded()
        self.layoutSubviews()
    }

    func updateSelectedIds(filteredIds: [String], removedCompetition: Competition) {

        // Update selected ids
        self.selectedIds.value = Set(filteredIds)

        // Update competitions selected ids
        for sectionGroup in self.filteredCompetitions {
            if sectionGroup.cells.map(\.id).contains(where: { $0 == removedCompetition.id }) {

                if var competitions = self.competitionSelectedIds[sectionGroup.id] {
                    competitions.remove(removedCompetition.id)
                    self.competitionSelectedIds[sectionGroup.id] = competitions
                }
                else {
                    self.competitionSelectedIds[sectionGroup.id] = []
                }

            }
        }

        self.tableView.reloadData()
    }
}

// MARK: - View Setup
private extension CompetitionsFiltersView {
    static func createHeaderStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }

    static func createHeaderBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundSecondary
        return view
    }

    static func createCloseButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = AppFont.with(type: .bold, size: 13)
        button.setTitle(localized("close"), for: .normal)
        return button
    }

    static func createClearButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = AppFont.with(type: .bold, size: 13)
        button.setTitle(localized("clear_all"), for: .normal)
        return button
    }

    static func createSearchBarBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }

    static func createSearchBarView() -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.returnKeyType = .done
        searchBar.searchBarStyle = .prominent
        searchBar.backgroundImage = UIImage()
        searchBar.isTranslucent = false
        return searchBar
    }

    static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    static func createSmallTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 8)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }

    static func createTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        tableView.allowsMultipleSelection = true
        tableView.contentInset = UIEdgeInsets(top: 2, left: 0, bottom: 16, right: 0)
        return tableView
    }

    static func createLoadingView() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }

    func initConstraints() {
        NSLayoutConstraint.activate([
            // Header Stack View
            headerStackView.topAnchor.constraint(equalTo: topAnchor),
            headerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),

            // Header Base View
            headerBaseView.heightAnchor.constraint(equalToConstant: 54),

            // Search Bar Base View
            searchBarBaseView.heightAnchor.constraint(equalToConstant: 70),

            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: headerBaseView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerBaseView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: clearButton.trailingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: 5),

            // Small Title Label
            smallTitleLabel.topAnchor.constraint(equalTo: headerBaseView.topAnchor),
            smallTitleLabel.leadingAnchor.constraint(equalTo: headerBaseView.leadingAnchor, constant: 8),
            smallTitleLabel.trailingAnchor.constraint(equalTo: headerBaseView.trailingAnchor, constant: -8),
            smallTitleLabel.heightAnchor.constraint(equalToConstant: 18),

            // Close Button
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: headerBaseView.trailingAnchor, constant: -16),

            // Clear Button
            clearButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            clearButton.leadingAnchor.constraint(equalTo: headerBaseView.leadingAnchor, constant: 18),

            // Search Bar
            searchBarView.leadingAnchor.constraint(equalTo: searchBarBaseView.leadingAnchor, constant: 18),
            searchBarView.trailingAnchor.constraint(equalTo: searchBarBaseView.trailingAnchor, constant: -18),
            searchBarView.centerYAnchor.constraint(equalTo: searchBarBaseView.centerYAnchor, constant: -5),

            // Table View
            tableView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Loading View
            loadingView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }
}

extension CompetitionsFiltersView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            self.searchBarView.resignFirstResponder()
        }
    }
}

extension CompetitionsFiltersView: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredCompetitions.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let viewModelForSection = filteredCompetitions[safe: section] {
            return viewModelForSection.cells.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueCellType(CompetitionFilterTableViewCell.self),
            let groupViewModel = filteredCompetitions[safe: indexPath.section],
            let viewModel = groupViewModel.cells[safe: indexPath.row]
        else {
            fatalError()
        }

        let isSelected = self.selectedIds.value.contains(viewModel.id)
        let isLastCell = tableView.numberOfRows(inSection: indexPath.section) == indexPath.row + 1

        let competitionStyles = TargetVariables.competitionListStyle
        let mode: CompetitionFilterCellMode = competitionStyles == .navigateToDetails ? CompetitionFilterCellMode.navigate : CompetitionFilterCellMode.toggle

        cell.configure(withViewModel: CompetitionFilterCellViewModel(competition: viewModel.competition,
                                                                     locationId: groupViewModel.id,
                                                                     isSelected: isSelected,
                                                                     isLastCell: isLastCell,
                                                                     country: groupViewModel.country,
                                                                     mode: mode))

        if mode == .toggle {
            cell.didToggleCellAction = { [weak self] competitionId, locationId in
                guard let self = self else { return }

                if !self.selectedIds.value.contains(competitionId) {
                    var selectedIdsCopy = self.selectedIds.value
                    selectedIdsCopy.insert(competitionId)
                    self.selectedIds.send(selectedIdsCopy)

                    self.insertCompetition(withId: competitionId, countryGroupId: locationId)
                } else {
                    var selectedIdsCopy = self.selectedIds.value
                    selectedIdsCopy.remove(competitionId)
                    self.selectedIds.send(selectedIdsCopy)

                    self.removeCompetition(withId: competitionId, countryGroupId: locationId)
                }

                self.reloadTableView()
            }
        } else if mode == .navigate {
            cell.didTapNavigationAction = { [weak self] competitionId in
                self?.didTapCompetitionNavigationAction(competitionId)
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let viewModelForSection = filteredCompetitions[safe: indexPath.section],
           expandedCellsDictionary[viewModelForSection.id] ?? false {
            // if expandedCells.contains(indexPath.section) {
            return 52
        }
        return 0
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let viewModelForSection = filteredCompetitions[safe: indexPath.section],
           expandedCellsDictionary[viewModelForSection.id] ?? false {
        // if expandedCells.contains(indexPath.section) {
            return 52
        }
        return 0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 20
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CompetitionFilterHeaderView.identifier) as? CompetitionFilterHeaderView,
            let viewModelForSection = filteredCompetitions[safe: section]
        else {
            return nil
        }

        headerView.backgroundView?.backgroundColor = .red
        headerView.backgroundColor = .blue
        headerView.delegate = self

        headerView.section = section
        headerView.isExpanded = expandedCellsDictionary[viewModelForSection.id] ?? false // expandedCells.contains(section)
        headerView.sectionIdentifier = viewModelForSection.id
//        headerView.titleLabel.text = viewModelForSection.name
//
        //headerView.viewModel = viewModelForSection

        headerView.configure(viewModel: viewModelForSection)

        headerView.selectionCount = self.competitionSelectedIds[viewModelForSection.id]?.count ?? 0

        return headerView
    }

//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if let typedCell = cell as? CompetitionFilterTableViewCell,
//           let viewModelForIndex = filteredCompetitions[safe: indexPath.section]?.cells[safe: indexPath.row] {
//            if self.selectedIds.value.contains(viewModelForIndex.id) {
//                typedCell.setSelected(true, animated: false)
//            }
//            else {
//                typedCell.setSelected(false, animated: false)
//            }
//        }
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let viewModelForIndex = filteredCompetitions[safe: indexPath.section]?.cells[safe: indexPath.row] {
//            var selectedIdsCopy = selectedIds.value
//            selectedIdsCopy.insert(viewModelForIndex.id)
//            self.selectedIds.send(selectedIdsCopy)
//        }
//    }
//
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        if let viewModelForIndex = filteredCompetitions[safe: indexPath.section]?.cells[safe: indexPath.row] {
//            var selectedIdsCopy = selectedIds.value
//            selectedIdsCopy.remove(viewModelForIndex.id)
//            self.selectedIds.send(selectedIdsCopy)
//        }
//    }

}

extension CompetitionsFiltersView: CollapsibleTableViewHeaderDelegate {

    func didToogleSection(sectionIdentifier: String) {

        if expandedCellsDictionary[sectionIdentifier] ?? false {
            expandedCellsDictionary[sectionIdentifier] = false
            if self.expandCompetitionLoaded.contains(sectionIdentifier) {

                if let index = self.expandCompetitionLoaded.firstIndex(of: sectionIdentifier) {

                    self.expandCompetitionLoaded.remove(at: index)

                }
            }
        }
        else {
            expandedCellsDictionary[sectionIdentifier] = true

            if self.loadedExpandedCells.contains(sectionIdentifier) {
                self.expandCompetitionLoaded.append(sectionIdentifier)
            }
        }

        if !self.loadedExpandedCells.contains(sectionIdentifier) {
            self.loadedExpandedCells.append(sectionIdentifier)
            self.shouldLoadCompetitions?(sectionIdentifier)
            self.expandCompetitionLoaded.append(sectionIdentifier)
        }

        self.redrawForSection(sectionIdentifier)
    }

    func redrawForSection(_ sectionIdentifier: String) {

        var selectedSection: Int?
        for (i, section) in self.filteredCompetitions.enumerated() where section.id == sectionIdentifier  {
            selectedSection = i
            break
        }

        guard
            let section = selectedSection,
            let viewModelForSection = filteredCompetitions[safe: section]
        else {
            return
        }

        let rows = (0 ..< viewModelForSection.cells.count).map({ IndexPath(row: $0, section: section) }) // all section rows

        let selectedCells = tableView.indexPathsForSelectedRows ?? []

        if rows.isNotEmpty {
            tableView.beginUpdates()
            tableView.reloadRows(at: rows, with: .automatic)
            tableView.endUpdates()

            for selectedCellIndexPath in selectedCells {
                tableView.selectRow(at: selectedCellIndexPath, animated: false, scrollPosition: .none)
            }
        }
    }
}

extension CompetitionsFiltersView: UISearchBarDelegate {

    func applyFilters() {

        if self.searchBarView.text?.isEmpty ?? true {
            self.filteredCompetitions = self.competitions
            return
        }

//        self.expandedCells = []

        let searchText = (self.searchBarView.text ?? "").lowercased()

        var filteredCompetitionGroup = [CompetitionFilterSectionViewModel]()
        for competitionGroup in self.competitions {

            var newCompetitionGroup = competitionGroup

            if newCompetitionGroup.name.lowercased().contains(searchText) {
                filteredCompetitionGroup.append(newCompetitionGroup)
                continue
            }

            var filteredCompetitions = [CompetitionFilterRowViewModel]()
            for competition in competitionGroup.cells {
                if competition.name.lowercased().contains(searchText) {
                    filteredCompetitions.append(competition)
                }
            }

            newCompetitionGroup.cells = filteredCompetitions

            if filteredCompetitions.isNotEmpty {
                filteredCompetitionGroup.append(newCompetitionGroup)
            }

        }

        self.filteredCompetitions = filteredCompetitionGroup
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.applyFilters()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.applyFilters()
        self.searchBarView.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarView.text = ""
        self.applyFilters()
    }
}
