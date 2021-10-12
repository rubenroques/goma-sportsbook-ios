//
//  SportsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/09/2021.
//

import UIKit
import Combine
import OrderedCollections

struct BannerCellViewModel {

}

struct UserInfoCellViewModel {

}

struct MatchLineCellViewModel {

}

struct MatchWidgetCellViewModel {

}

class SportsViewController: UIViewController {

    @IBOutlet private weak var filtersBarBaseView: UIView!
    @IBOutlet private weak var filtersCollectionView: UICollectionView!
    @IBOutlet private weak var filtersSeparatorLineView: UIView!
    @IBOutlet private weak var tableView: UITableView!

    @IBOutlet private weak var leftGradientBaseView: UIView!
    @IBOutlet private weak var sportsSelectorButtonView: UIView!

    @IBOutlet private weak var rightGradientBaseView: UIView!
    @IBOutlet private weak var filtersButtonView: UIView!

    @IBOutlet weak var loadingBaseView: UIView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!

    var cancellables = Set<AnyCancellable>()

    var viewModel: SportsViewModel

    var filterSelectedOption: Int = 0
    var sportSelected: String = "1"

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

        commonInit()
        setupWithTheme()

        self.viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                self.loadingBaseView.isHidden = !isLoading
            }
            .store(in: &cancellables)

        self.viewModel.contentList
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
                self.tableView.setContentOffset(.zero, animated: true)
            }
            .store(in: &cancellables)

        self.viewModel.fetchData()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    private func commonInit() {

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
        tableView.delegate = self
        tableView.dataSource = self

        tableView.estimatedRowHeight = 155
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0

        let didTapSportsSelection = UITapGestureRecognizer(target: self, action: #selector(self.handleSportsSelectionTap(_:)))
        sportsSelectorButtonView.addGestureRecognizer(didTapSportsSelection)

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
        self.filtersSeparatorLineView.alpha = 0.25
        
        self.tableView.backgroundColor = UIColor.App.contentBackground
        self.tableView.backgroundView?.backgroundColor = UIColor.App.contentBackground
    }

}

extension SportsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.itemsForSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard
            let cell = tableView.dequeueCellType(MatchLineTableViewCell.self)
        else {
            fatalError()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
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
            cell.setSelected(true)
        }
        else {
            cell.setSelected(false)
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
        default:
            ()
        }

        self.filtersCollectionView.reloadData()
        self.filtersCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }


}

protocol SportsViewDelegate: AnyObject {
    func setSport(sport: String)
}

extension SportsViewController: SportsViewDelegate {
    func setSport(sport: String) {
        self.sportSelected = sport
    }
}
