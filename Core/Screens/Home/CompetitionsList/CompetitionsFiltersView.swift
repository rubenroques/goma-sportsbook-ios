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

    var applyFiltersAction: (([String]) -> Void)?
    var tapHeaderViewAction: (() -> Void)?

    private var cancellables: Set<AnyCancellable> = []

    var selectedIds: CurrentValueSubject<[String], Never> = .init([])

    var expandedCells: Set<Int> = []

    var competitions: [CompetitionFilterSectionViewModel] = [] {
        didSet {
            self.searchBarView.text = nil
            self.filteredCompetitions = competitions
        }
    }
    var filteredCompetitions: [CompetitionFilterSectionViewModel] = [] {
        didSet {
            self.tableView.reloadData()
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
        self.searchBarView.tintColor = .blue
        self.searchBarView.barTintColor = .red
        self.searchBarView.backgroundImage = UIColor.App.mainBackground.image()
        //self.searchBarView.placeholder = localized("string_search")

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

        self.selectedIds
            .map(\.isNotEmpty)
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: applyButton)
            .store(in: &cancellables)

        self.selectedIds
            .map(\.count)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { count in
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

    func barHeaderViewSize() {
        UIView.animate(withDuration: 0.4) {
            self.titleLabel.alpha = 1.0
            self.smallTitleLabel.alpha = 0.0
        }
    }

    func lineHeaderViewSize() {
        UIView.animate(withDuration: 0.4) {
            self.titleLabel.alpha = 0.0
            self.smallTitleLabel.alpha = 1.0
        }
    }

    @IBAction func didTapApplyButton() {
        self.applyFiltersAction?(self.selectedIds.value)
    }

    @objc func didTapHeaderView() {
        self.tapHeaderViewAction?()
    }

    @objc func didTapBackground() {
        self.searchBarView.resignFirstResponder()
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

        let selected = viewModel.isSelected
        cell.setSelected(selected, animated: true)

        cell.titleLabel.text = viewModel.name

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let sectionViewModel = filteredCompetitions[safe: indexPath.section], expandedCells.contains(indexPath.section) {
            return 52
        }
        return 0
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let sectionViewModel = filteredCompetitions[safe: indexPath.section], expandedCells.contains(indexPath.section) {
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
        headerView.viewModel = viewModelForSection
        
        return headerView
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let typedCell = cell as? CompetitionFilterTableViewCell,
           var viewModelForIndex = filteredCompetitions[safe: indexPath.section]?.cells[safe: indexPath.row]
        {
            if self.selectedIds.value.contains(viewModelForIndex.id) {
                typedCell.setSelected(true, animated: false)
            }
            else {
                typedCell.setSelected(false, animated: false)
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if var viewModelForIndex = filteredCompetitions[safe: indexPath.section]?.cells[safe: indexPath.row] {


            var selectedIdsCopy = selectedIds.value
            selectedIdsCopy.append(viewModelForIndex.id)
            self.selectedIds.send(selectedIdsCopy)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if var viewModelForIndex = filteredCompetitions[safe: indexPath.section]?.cells[safe: indexPath.row] {

            var selectedIdsCopy = selectedIds.value
            selectedIdsCopy.removeAll { element in
                viewModelForIndex.id == element
            }
            self.selectedIds.send(selectedIdsCopy)
        }
    }

}

extension CompetitionsFiltersView: CollapsibleTableViewHeaderDelegate {

    func didCollapseSection(section: Int) {
        //filteredCompetitions[safe: section]?.isExpanded = false
        expandedCells.remove(section)

        self.redrawForSection(section)
    }

    func didExpandSection(section: Int) {
        //filteredCompetitions[safe: section]?.isExpanded = true

        expandedCells.insert(section)

        self.redrawForSection(section)
    }

    func redrawForSection(_ section: Int) {
        guard
            let viewModelForSection = filteredCompetitions[safe: section]
        else {
            return
        }

        let rows = (0 ..< viewModelForSection.cells.count).map({ IndexPath(row: $0, section: section) }) // all section rows

//        let selectedRows = tableView.indexPathsForSelectedRows

        tableView.beginUpdates()
        tableView.reloadRows(at: rows, with: .automatic)
        tableView.endUpdates()

//        if let selectedRow = selectedRows {
//            for indexPath in selectedRow {
//                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
//            }
//        }

    }
}

extension CompetitionsFiltersView: UISearchBarDelegate {

    func applyFilters() {

        if self.searchBarView.text?.isEmpty ?? true {
            self.filteredCompetitions = self.competitions
            return
        }

        self.expandedCells = []

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
