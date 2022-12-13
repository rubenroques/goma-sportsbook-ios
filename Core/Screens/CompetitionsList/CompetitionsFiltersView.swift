//
//  CompetitionsFiltersView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/10/2021.
//

import UIKit
import Combine
import OrderedCollections

class CompetitionsFiltersView: UIView, NibLoadable {

    @IBOutlet private weak var headerBaseView: UIView!

    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var clearButton: UIButton!

    @IBOutlet private weak var searchBarBaseView: UIView!
    @IBOutlet private weak var searchBarView: UISearchBar!

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var smallTitleLabel: UILabel!

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!

    var applyFiltersAction: (([String]) -> Void)?
    var tapHeaderViewAction: (() -> Void)?

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
//                        if let expandCompetitionLoaded = self.expandCompetitionLoaded,
//                           competition.id == expandCompetitionLoaded {
//                            self.expandedCellsDictionary[competition.id] = true
//
//                        }
//                        else {
//                            self.expandedCellsDictionary[competition.id] = false
//
//                        }
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

                self.initialSelectedIds = self.selectedIds.value
                self.closeButton.setTitle(localized("close"), for: .normal)

                UIView.animate(withDuration: 0.4) {
                    self.titleLabel.alpha = 1.0
                    self.smallTitleLabel.alpha = 0.0
                    self.closeButton.alpha = 1.0
                    self.clearButton.alpha = 1.0
                }
            case .bar:
                self.headerBaseView.backgroundColor = UIColor.App.backgroundBorder
                UIView.animate(withDuration: 0.4) {
                    self.titleLabel.alpha = 1.0
                    self.smallTitleLabel.alpha = 0.0
                    self.closeButton.alpha = 0.0
                    self.clearButton.alpha = 0.0
                }
            case .line:
                self.headerBaseView.backgroundColor = UIColor.App.backgroundBorder
                UIView.animate(withDuration: 0.4) {
                    self.titleLabel.alpha = 0.0
                    self.smallTitleLabel.alpha = 1.0
                    self.closeButton.alpha = 0.0
                    self.clearButton.alpha = 0.0
                }
            }

        }
    }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        loadFromNib()
        commonInit()
        setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        loadFromNib()
        commonInit()
        setupWithTheme()
    }

    func commonInit() {

        self.translatesAutoresizingMaskIntoConstraints = false

        self.loadingView.hidesWhenStopped = true
        self.loadingView.stopAnimating()

        self.tableView.backgroundView?.backgroundColor = .clear
        self.tableView.backgroundColor = .clear
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
        self.tableView.register(CompetitionFilterTableViewCell.self, forCellReuseIdentifier: CompetitionFilterTableViewCell.identifier)
        self.tableView.register(CompetitionFilterHeaderView.self, forHeaderFooterViewReuseIdentifier: CompetitionFilterHeaderView.identifier)
        self.tableView.contentInset = UIEdgeInsets(top: 2, left: 0, bottom: 16, right: 0)

        self.searchBarBaseView.backgroundColor = .clear

        self.searchBarView.returnKeyType = .done
        self.searchBarView.searchBarStyle = UISearchBar.Style.prominent
        self.searchBarView.sizeToFit()
        self.searchBarView.isTranslucent = false
        self.searchBarView.backgroundImage = UIImage()
        self.searchBarView.delegate = self

        self.smallTitleLabel.alpha = 0.0

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        headerBaseView.addGestureRecognizer(backgroundTapGesture)

        let headerTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapHeaderView))
        headerBaseView.addGestureRecognizer(headerTapGesture)

        let swipeHeaderTapGesture = UISwipeGestureRecognizer(target: self, action: #selector(didTapHeaderView))
        swipeHeaderTapGesture.direction = .up
        headerBaseView.addGestureRecognizer(swipeHeaderTapGesture)

//        self.headerBaseView.layer.borderColor = UIColor.black.cgColor
//        self.headerBaseView.layer.borderWidth = 2

        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipeDownToClose))
        swipeGestureRecognizer.direction = .down
        self.addGestureRecognizer(swipeGestureRecognizer)

        self.selectedIds
            .map(\.isNotEmpty)
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: clearButton)
            .store(in: &cancellables)

        self.selectedIds
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] currentSelection in
                if (self?.initialSelectedIds ?? []) == currentSelection {
                    self?.closeButton.setTitle(localized("close"), for: .normal)
                }
                else {
                    self?.closeButton.setTitle(localized("apply"), for: .normal)
                }
            })
            .store(in: &cancellables)

        self.selectedIds
            .map(\.count)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { count in
                // swiftlint:disable empty_count
                if count == 0 {
                    self.titleLabel.text = localized("choose_competitions")
                    self.smallTitleLabel.text = localized("choose_competitions")
                }
                else {
                    self.titleLabel.text = localized("choose_competitions")+" (\(count))"
                    self.smallTitleLabel.text = localized("choose_competitions")+" (\(count))"
                }
            })
            .store(in: &cancellables)

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
        case .bar:
            self.headerBaseView.backgroundColor = UIColor.App.backgroundBorder
        case .line:
            self.headerBaseView.backgroundColor = UIColor.App.backgroundBorder
        }

        self.searchBarBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.titleLabel.textColor = UIColor.App.textPrimary
        self.smallTitleLabel.textColor = UIColor.App.textPrimary

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

        cell.configure(withViewModel: CompetitionFilterCellViewModel(competition: viewModel.competition,
                                                                     locationId: groupViewModel.id,
                                                                     isSelected: isSelected,
                                                                     isLastCell: isLastCell))

        cell.didTapCellAction = { [weak self] viewModel in

            guard let self = self else { return }

            if viewModel.isSelected {
                var selectedIdsCopy = self.selectedIds.value
                selectedIdsCopy.insert(viewModel.id)
                self.selectedIds.send(selectedIdsCopy)

                self.insertCompetition(withId: viewModel.id, countryGroupId: viewModel.locationId)
            }
            else {
                var selectedIdsCopy = self.selectedIds.value
                selectedIdsCopy.remove(viewModel.id)
                self.selectedIds.send(selectedIdsCopy)

                self.removeCompetition(withId: viewModel.id, countryGroupId: viewModel.locationId)
            }

            self.reloadTableView()
        }

        // cell.titleLabel.text = viewModel.name
        // cell.selectionStyle = .none
        
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
        headerView.titleLabel.text = viewModelForSection.name

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
        }
        else {
            expandedCellsDictionary[sectionIdentifier] = true
        }

        if !self.loadedExpandedCells.contains(sectionIdentifier) {
            self.loadedExpandedCells.append(sectionIdentifier)
            self.shouldLoadCompetitions?(sectionIdentifier)
            //self.expandCompetitionLoaded = sectionIdentifier
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
        self.searchBarView.text = localized("empty_value")
        self.applyFilters()
    }
}
