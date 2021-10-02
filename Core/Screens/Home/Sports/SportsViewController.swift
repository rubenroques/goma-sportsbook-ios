//
//  SportsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/09/2021.
//

import UIKit
import Combine

class SportsViewController: UIViewController {

    @IBOutlet private weak var filtersBarBaseView: UIView!
    @IBOutlet private weak var filtersCollectionView: UICollectionView!
    @IBOutlet private weak var filtersSeparatorLineView: UIView!
    @IBOutlet private weak var tableView: UITableView!

    @IBOutlet private weak var leftGradientBaseView: UIView!
    @IBOutlet private weak var sportsSelectorButtonView: UIView!

    @IBOutlet private weak var rightGradientBaseView: UIView!
    @IBOutlet private weak var filtersButtonView: UIView!


    var cancellables = Set<AnyCancellable>()
    
    private enum ScreenState {
        case loading
        case error
        case data
    }

    private var listType: ListType = .myGames
    private enum ListType {
        case myGames
        case today
        case competitions
    }

    init() {
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
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    private func commonInit() {

        let color = UIColor.App.contentBackgroundColor
        
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

        filtersBarBaseView.backgroundColor = UIColor.App.contentBackgroundColor
        filtersCollectionView.backgroundColor = .clear

        sportsSelectorButtonView.backgroundColor = UIColor.App.mainTintColor
        sportsSelectorButtonView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]

        filtersButtonView.backgroundColor = UIColor.App.secundaryBackgroundColor
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

        tableView.register(MatchTableViewCell.nib, forCellReuseIdentifier: MatchTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self

        let sportType = SportType.football
//        print("Clock-Go!: \(Date())")
//
//       Env.eventsStore.getMatches(sportType: sportType)
//            .receive(on: DispatchQueue.main)
//            .sink { matches in
//                print("Clock-Done!: \(Date())")
//                //print(matches)
//            }
//            .store(in: &cancellables)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        filtersButtonView.layer.cornerRadius = filtersButtonView.frame.height / 2
        sportsSelectorButtonView.layer.cornerRadius = sportsSelectorButtonView.frame.height / 2
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainBackgroundColor

        self.filtersBarBaseView.backgroundColor = UIColor.App.contentBackgroundColor
        self.filtersSeparatorLineView.backgroundColor = UIColor.App.separatorLineColor
        self.filtersSeparatorLineView.alpha = 0.25
        
        self.tableView.backgroundColor = UIColor.App.contentBackgroundColor
        self.tableView.backgroundView?.backgroundColor = UIColor.App.contentBackgroundColor
    }

}

extension SportsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueCellType(MatchTableViewCell.self)
        else {
            fatalError()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableView.dequeueReusableHeaderFooterView(withIdentifier: "")
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

        switch (self.listType, indexPath.row) {
        case (.myGames, 0):
            cell.setSelected(true)
        case (.today, 1):
            cell.setSelected(true)
        case (.competitions, 2):
            cell.setSelected(true)
        default:
            cell.setSelected(false)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.listType = .myGames
        case 1:
            self.listType = .today
        case 2:
            self.listType = .competitions
        default:
            ()
        }
        self.filtersCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.filtersCollectionView.reloadData()
    }
}
