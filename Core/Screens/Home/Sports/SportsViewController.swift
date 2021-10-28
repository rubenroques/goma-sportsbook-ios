//
//  SportsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/09/2021.
//

import UIKit
import Combine
import OrderedCollections
import SwiftUI

class SportsViewController: UIViewController {

    @IBOutlet private weak var filtersBarBaseView: UIView!
    @IBOutlet private weak var filtersCollectionView: UICollectionView!
    @IBOutlet private weak var filtersSeparatorLineView: UIView!
    @IBOutlet private weak var tableView: UITableView!

    @IBOutlet private weak var sportTypeIconImageView: UIImageView!
    @IBOutlet private weak var leftGradientBaseView: UIView!
    @IBOutlet private weak var sportsSelectorButtonView: UIView!

    @IBOutlet private weak var rightGradientBaseView: UIView!
    @IBOutlet private weak var filtersButtonView: UIView!

    @IBOutlet weak var loadingBaseView: UIView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!

    @IBOutlet private weak var openedCompetitionsFiltersConstraint: NSLayoutConstraint!
    @IBOutlet private weak var competitionsFiltersBaseView: UIView!
    @IBOutlet private weak var competitionsFiltersDarkBackgroundView: UIView!
    private var competitionsFiltersView: CompetitionsFiltersView?

    var cancellables = Set<AnyCancellable>()

    var viewModel: SportsViewModel

    var filterSelectedOption: Int = 0
    var sportSelected: String = "1"

    private var lastContentOffset: CGFloat = 0
    private var shouldDetectScrollMovement = false

    init() {
        self.viewModel = SportsViewModel()
        super.init(nibName: "SportsViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.bringSubviewToFront(self.loadingBaseView)
        
        self.commonInit()
        self.setupWithTheme()
        self.connectPublishers()
        self.viewModel.fetchData()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func commonInit() {

        self.sportTypeIconImageView.image = UIImage(named: "sport_type_icon_1")
        let color = UIColor.App.contentBackground
        
        leftGradientBaseView.backgroundColor = color
        let leftGradientMaskLayer = CAGradientLayer()
        leftGradientMaskLayer.frame = leftGradientBaseView.bounds
        leftGradientMaskLayer.colors = [UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        leftGradientMaskLayer.locations = [0, 0.55, 1]
        leftGradientMaskLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        leftGradientMaskLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        leftGradientBaseView.layer.mask = leftGradientMaskLayer

        //
        rightGradientBaseView.backgroundColor = color
        let rightGradientMaskLayer = CAGradientLayer()
        rightGradientMaskLayer.frame = rightGradientBaseView.bounds
        rightGradientMaskLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor]
        rightGradientMaskLayer.locations = [0, 0.45, 1]
        rightGradientMaskLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        rightGradientMaskLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        rightGradientBaseView.layer.mask = rightGradientMaskLayer

        filtersBarBaseView.backgroundColor = UIColor.App.contentBackground
        filtersCollectionView.backgroundColor = .clear

        sportsSelectorButtonView.backgroundColor = UIColor.App.mainTint
        sportsSelectorButtonView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]

        filtersButtonView.backgroundColor = UIColor.App.secondaryBackground
        filtersButtonView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]


        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.scrollDirection = .horizontal
        filtersCollectionView.collectionViewLayout = flowLayout
        filtersCollectionView.contentInset = UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 54)
        filtersCollectionView.showsVerticalScrollIndicator = false
        filtersCollectionView.showsHorizontalScrollIndicator = false
        filtersCollectionView.register(ListTypeCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)
        filtersCollectionView.delegate = self
        filtersCollectionView.dataSource = self

        tableView.backgroundColor = .clear
        tableView.backgroundView?.backgroundColor = .clear
        
        tableView.separatorStyle = .none
        tableView.register(MatchLineTableViewCell.nib, forCellReuseIdentifier: MatchLineTableViewCell.identifier)
        tableView.register(BannerScrollTableViewCell.nib, forCellReuseIdentifier: BannerScrollTableViewCell.identifier)
        tableView.register(TitleTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TitleTableViewHeader.identifier)
        tableView.register(TournamentTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TournamentTableViewHeader.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self

        tableView.estimatedRowHeight = 155
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0

        let didTapSportsSelection = UITapGestureRecognizer(target: self, action: #selector(self.handleSportsSelectionTap(_:)))
        sportsSelectorButtonView.addGestureRecognizer(didTapSportsSelection)

        //
        //
        self.competitionsFiltersView = CompetitionsFiltersView()

        self.competitionsFiltersView?.applyFiltersAction = { [unowned self] selectedCompetitionsIds in
            self.applyCompetitionsFiltersWithIds(selectedCompetitionsIds)
        }
        self.competitionsFiltersView?.tapHeaderViewAction = { [unowned self] in
            self.openCompetitionsFilters()
        }

        self.competitionsFiltersDarkBackgroundView.alpha = 0.4
        self.competitionsFiltersBaseView.backgroundColor = .clear
        self.competitionsFiltersBaseView.addSubview(self.competitionsFiltersView!)

        NSLayoutConstraint.activate([
            self.competitionsFiltersBaseView.leadingAnchor.constraint(equalTo: self.competitionsFiltersView!.leadingAnchor),
            self.competitionsFiltersBaseView.trailingAnchor.constraint(equalTo: self.competitionsFiltersView!.trailingAnchor),
            self.competitionsFiltersBaseView.topAnchor.constraint(equalTo: self.competitionsFiltersView!.topAnchor),
            self.competitionsFiltersBaseView.bottomAnchor.constraint(equalTo: self.competitionsFiltersView!.bottomAnchor),
        ])

    }

    func connectPublishers() {

        self.viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                self.loadingBaseView.isHidden = !isLoading
            }
            .store(in: &cancellables)

        self.viewModel.dataDidChangedAction = { [unowned self] in
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            self.tableView.setContentOffset(.zero, animated: true)
        }

        self.viewModel.matchListTypePublisher
            .map {  $0 == .competitions }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isCompetitionTab in
                self.shouldDetectScrollMovement = isCompetitionTab
                self.competitionsFiltersBaseView.isHidden = !isCompetitionTab
                self.competitionsFiltersDarkBackgroundView.isHidden = !isCompetitionTab
            }
            .store(in: &cancellables)

        self.viewModel.competitionGroupsPublisher
            .map {
                $0.enumerated().map {
                    CompetitionFilterSectionViewModel(index: $0.offset, competitionGroup: $0.element)
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] competitions in
                self.competitionsFiltersView?.competitions = competitions
            }
            .store(in: &cancellables)
        // swiftlint:disable empty_count
        self.competitionsFiltersView?.selectedIds
            .compactMap({ $0.count == 0 })
            .sink(receiveValue: { [unowned self] shouldShowOpen in
                if shouldShowOpen {
                    self.openCompetitionsFilters()
                }
            })
            .store(in: &cancellables)

    }

    @objc func handleSportsSelectionTap(_ sender: UITapGestureRecognizer? = nil) {
        let sportSelectionVC = SportSelectionViewController(defaultSport: self.sportSelected)
        sportSelectionVC.delegate = self
        self.present(sportSelectionVC, animated: true, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        filtersButtonView.layer.cornerRadius = filtersButtonView.frame.height / 2
        sportsSelectorButtonView.layer.cornerRadius = sportsSelectorButtonView.frame.height / 2
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainBackground

        self.filtersBarBaseView.backgroundColor = UIColor.App.contentBackground
        self.filtersSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        self.filtersSeparatorLineView.alpha = 0.5
        
        self.tableView.backgroundColor = UIColor.App.contentBackground
        self.tableView.backgroundView?.backgroundColor = UIColor.App.contentBackground
    }

    func applyCompetitionsFiltersWithIds(_ ids: [String]) {
        self.viewModel.fetchCompetitionsMatchesWithIds(ids)
        self.showBottomBarCompetitionsFilters()
    }

    func openCompetitionsFilters() {
        guard
            let competitionsFiltersView = competitionsFiltersView,
            competitionsFiltersView.state != .opened
        else {
            return
        }

        UIView.animate(withDuration: 0.32, delay: 0.0, options: .curveEaseOut, animations: {
            self.competitionsFiltersDarkBackgroundView.alpha = 0.4
            self.openedCompetitionsFiltersConstraint.constant = 0
            self.tableView.contentInset.bottom = 16
            //competitionsFiltersView.openedBarHeaderViewSize()
            competitionsFiltersView.state = .opened
            self.view.layoutIfNeeded()
        }, completion: nil)


    }

    func showBottomBarCompetitionsFilters() {
        guard let competitionsFiltersView = competitionsFiltersView else {
            return
        }

        UIView.animate(withDuration: 0.32, delay: 0.0, options: .curveEaseOut, animations: {
            self.competitionsFiltersDarkBackgroundView.alpha = 0.0
            self.openedCompetitionsFiltersConstraint.constant = -(competitionsFiltersView.frame.size.height - 52)
            self.tableView.contentInset.bottom = 54+16
            //competitionsFiltersView.closedBarHeaderViewSize()
            competitionsFiltersView.state = .bar
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    func showBottomLineCompetitionsFilters() {
        guard let competitionsFiltersView = competitionsFiltersView else {
            return
        }

        UIView.animate(withDuration: 0.32, delay: 0.0, options: .curveEaseOut, animations: {
            self.competitionsFiltersDarkBackgroundView.alpha = 0.0
            self.openedCompetitionsFiltersConstraint.constant = -(competitionsFiltersView.frame.size.height - 18)
            self.tableView.contentInset.bottom = 24
            //competitionsFiltersView.lineHeaderViewSize()
            competitionsFiltersView.state = .line
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

}

extension SportsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if !shouldDetectScrollMovement {
            return
        }
        
        switch scrollView.panGestureRecognizer.state {
        case .began, .changed:
            ()
        default:
            return
        }

        if (self.lastContentOffset > scrollView.contentOffset.y) {
            // moving up
            self.showBottomBarCompetitionsFilters()
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y) {
            // move down
            self.showBottomLineCompetitionsFilters()
        }

        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
    }
}

extension SportsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections(in: tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.tableView(tableView, numberOfRowsInSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.viewModel.tableView(tableView, cellForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.viewModel.tableView(tableView, viewForHeaderInSection: section)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.tableView(tableView, heightForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.tableView(tableView, estimatedHeightForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.viewModel.tableView(tableView, heightForHeaderInSection: section)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.viewModel.tableView(tableView, estimatedHeightForHeaderInSection: section)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}

extension SportsViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(ListTypeCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }

        switch indexPath.row {
        case 0:
            cell.setupWithTitle("My Games")
        case 1:
            cell.setupWithTitle("Today")
        case 2:
            cell.setupWithTitle("Competitions")
        default:
            ()
        }

        if filterSelectedOption == indexPath.row {
            cell.setSelectedType(true)
        }
        else {
            cell.setSelectedType(false)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        self.filterSelectedOption = indexPath.row

        switch indexPath.row {
        case 0:
            self.viewModel.setMatchListType(.myGames)
        case 1:
            self.viewModel.setMatchListType(.today)
        case 2:
            self.viewModel.setMatchListType(.competitions)
        default:
            ()
        }

        self.filtersCollectionView.reloadData()
        self.filtersCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

}

protocol SportTypeSelectionViewDelegate: AnyObject {
    func setSport(sport: String)
}

extension SportsViewController: SportTypeSelectionViewDelegate {
    func setSport(sport: String) {
        self.sportSelected = sport

        self.sportTypeIconImageView.image = UIImage(named: "sport_type_icon_\(sport)")
        
        if let sportId = Int(sport) {
            self.viewModel.selectedSportId = sportId
            self.competitionsFiltersView?.resetSelection()
        }

    }
}
