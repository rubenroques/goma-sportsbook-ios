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

    @IBOutlet private weak var searchBarBaseView: UIView!
    @IBOutlet private weak var searchBarView: UISearchBar!

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var smallTitleLabel: UILabel!

    @IBOutlet private weak var buttonBaseVIew: UIView!
    @IBOutlet private weak var buttonSeparatorBaseVIew: UIView!
    @IBOutlet private weak var applyButton: UIButton!

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!

    var applyFiltersAction: (([String]) -> Void)?
    var tapHeaderViewAction: (() -> Void)?

    private var cancellables: Set<AnyCancellable> = []

    var selectedIds: CurrentValueSubject<Set<String>, Never> = .init([])
    var expandedCellsDictionary: [String: Bool] = [:]

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
            self.expandedCellsDictionary = [:]
            self.competitions.forEach({ competition in self.expandedCellsDictionary[competition.id] = false })
            self.searchBarView.text = nil
            self.filteredCompetitions = competitions
        }
    }
    var filteredCompetitions: [CompetitionFilterSectionViewModel] = [] {
        didSet {
            let selectedCells = tableView.indexPathsForSelectedRows ?? []
            self.tableView.reloadData()
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
                UIView.animate(withDuration: 0.4) {
                    self.titleLabel.alpha = 1.0
                    self.smallTitleLabel.alpha = 0.0
                }
            case .bar:
                UIView.animate(withDuration: 0.4) {
                    self.titleLabel.alpha = 1.0
                    self.smallTitleLabel.alpha = 0.0
                }
            case .line:
                UIView.animate(withDuration: 0.4) {
                    self.titleLabel.alpha = 0.0
                    self.smallTitleLabel.alpha = 1.0
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
        self.tableView.allowsSelection = true
        self.tableView.register(CompetitionFilterTableViewCell.self, forCellReuseIdentifier: CompetitionFilterTableViewCell.identifier)
        self.tableView.register(CompetitionFilterHeaderView.self, forHeaderFooterViewReuseIdentifier: CompetitionFilterHeaderView.identifier)
        self.tableView.contentInset = UIEdgeInsets(top: 2, left: 0, bottom: 16, right: 0)
        self.applyButton.backgroundColor = .clear
        self.applyButton.layer.cornerRadius = CornerRadius.button
        self.applyButton.layer.masksToBounds = true

        self.searchBarBaseView.backgroundColor = .clear

        self.searchBarView.searchBarStyle = UISearchBar.Style.prominent
        self.searchBarView.sizeToFit()
        self.searchBarView.isTranslucent = false
        self.searchBarView.backgroundImage = UIImage()
        self.searchBarView.tintColor = .white
        self.searchBarView.barTintColor = .white
        self.searchBarView.backgroundImage = UIColor.App.mainBackground.image()
        // self.searchBarView.placeholder = localized("string_search")

        self.searchBarView.delegate = self

        if let textfield = searchBarView.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.App.secondaryBackground
            textfield.textColor = .white
            textfield.tintColor = .white
            textfield.font = AppFont.with(type: .semibold, size: 15)
            textfield.attributedPlaceholder = NSAttributedString(string: localized("string_search_field_competitions"),
                                                            attributes: [
                    .foregroundColor: UIColor.App.fadeOutHeading,
                    .font: AppFont.with(type: .semibold, size: 15)
                ])

            if let glassIconView = textfield.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = UIColor.App.fadeOutHeading
            }
        }

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

        self.selectedIds
            .map(\.isNotEmpty)
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: applyButton)
            .store(in: &cancellables)

        self.selectedIds
            .map(\.count)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { count in
                // swiftlint:disable empty_count
                if count == 0 {
                    self.titleLabel.text = "Choose competitions"
                    self.smallTitleLabel.text = "Choose competitions"
                }
                else {
                    self.titleLabel.text = "Choose competitions (\(count))"
                    self.smallTitleLabel.text = "Choose competitions (\(count))"
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

        self.buttonSeparatorBaseVIew.backgroundColor = UIColor.App.separatorLine
        self.buttonSeparatorBaseVIew.alpha = 0.5

        self.headerBaseView.backgroundColor = UIColor.App.mainBackground
        self.searchBarBaseView.backgroundColor = UIColor.App.mainBackground

        self.titleLabel.textColor = UIColor.App.headingMain
        self.smallTitleLabel.textColor = UIColor.App.headingMain

        self.tableView.backgroundView?.backgroundColor = UIColor.App.mainBackground
        self.tableView.backgroundColor = UIColor.App.mainBackground
        self.buttonBaseVIew.backgroundColor = UIColor.App.mainBackground

        self.applyButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        self.applyButton.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .highlighted)
        self.applyButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)

        self.applyButton.setBackgroundColor(UIColor.App.primaryButtonNormal, for: .normal)
        self.applyButton.setBackgroundColor(UIColor.App.primaryButtonPressed, for: .highlighted)

        self.searchBarView.backgroundImage = UIColor.App.mainBackground.image()
        if let textfield = searchBarView.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.App.secondaryBackground
            textfield.textColor = .white
            textfield.tintColor = .white
            textfield.attributedPlaceholder = NSAttributedString(string: localized("string_search_field"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor:
                                                                                UIColor.App.fadeOutHeading])

            if let glassIconView = textfield.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = UIColor.App.fadeOutHeading
            }
        }
    }

    @IBAction func didTapApplyButton() {
        self.applyFiltersAction?(Array(self.selectedIds.value))
    }

    @objc func didTapHeaderView() {
        self.tapHeaderViewAction?()
    }

    @objc func didTapBackground() {
        self.searchBarView.resignFirstResponder()
    }

    func resetSelection() {
        self.selectedIds.send([])
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
            let viewModel = filteredCompetitions[safe: indexPath.section]?.cells[safe: indexPath.row]
        else {
            fatalError()
        }

        let isLastCell = tableView.numberOfRows(inSection: indexPath.section) == indexPath.row + 1
        if isLastCell {
            cell.configureAsLastCell()
        }
        else {
            cell.configureAsNormalCell()
        }

        cell.titleLabel.text = viewModel.name
        cell.selectionStyle = .none
        
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

        return headerView
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let typedCell = cell as? CompetitionFilterTableViewCell,
           let viewModelForIndex = filteredCompetitions[safe: indexPath.section]?.cells[safe: indexPath.row] {
            if self.selectedIds.value.contains(viewModelForIndex.id) {
                typedCell.setSelected(true, animated: false)
            }
            else {
                typedCell.setSelected(false, animated: false)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewModelForIndex = filteredCompetitions[safe: indexPath.section]?.cells[safe: indexPath.row] {
            var selectedIdsCopy = selectedIds.value
            selectedIdsCopy.insert(viewModelForIndex.id)
            self.selectedIds.send(selectedIdsCopy)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let viewModelForIndex = filteredCompetitions[safe: indexPath.section]?.cells[safe: indexPath.row] {
            var selectedIdsCopy = selectedIds.value
            selectedIdsCopy.remove(viewModelForIndex.id)
            self.selectedIds.send(selectedIdsCopy)
        }
    }

}

extension CompetitionsFiltersView: CollapsibleTableViewHeaderDelegate {

    func didToogleSection(sectionIdentifier: String) {

        if expandedCellsDictionary[sectionIdentifier] ?? false {
            expandedCellsDictionary[sectionIdentifier] = false
        }
        else {
            expandedCellsDictionary[sectionIdentifier] = true
        }

        self.redrawForSection(sectionIdentifier)
    }

    func redrawForSection(_ sectionIdentifier: String) {

        var selectedSection: Int?
        for (i, section) in self.filteredCompetitions.enumerated() {
            if section.id == sectionIdentifier {
                selectedSection = i
                break
            }
        }

        guard
            let section = selectedSection,
            let viewModelForSection = filteredCompetitions[safe: section]
        else {
            return
        }

        let rows = (0 ..< viewModelForSection.cells.count).map({ IndexPath(row: $0, section: section) }) // all section rows

        let selectedCells = tableView.indexPathsForSelectedRows ?? []

        tableView.beginUpdates()
        tableView.reloadRows(at: rows, with: .automatic)
        tableView.endUpdates()

        for selectedCellIndexPath in selectedCells {
            tableView.selectRow(at: selectedCellIndexPath, animated: false, scrollPosition: .none)
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

            var filteredCompetitions = [CompetitionFilterRowViewModel]()
            for competition in competitionGroup.cells {
                if competition.name.lowercased().contains(searchText) {
                    filteredCompetitions.append(competition)
                }
            }

            newCompetitionGroup.cells = filteredCompetitions

            if newCompetitionGroup.name.lowercased().contains(searchText) || filteredCompetitions.isNotEmpty {
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
