//
//  MyFavoritesViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 10/02/2022.
//

import UIKit
import Combine

class MyFavoritesViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topSliderCollectionView: UICollectionView = Self.createTopSliderCollectionView()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var loadingScreenBaseView: UIView = Self.createLoadingScreenBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var viewModel: MyFavoritesViewModel
    var filterSelectedOption: Int = 0

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.loadingScreenBaseView.isHidden = false
                self.tableView.isHidden = true
            }
            else {
                self.loadingScreenBaseView.isHidden = true
                self.tableView.isHidden = false
            }
        }
    }

    // MARK: Lifetime and Cycle
    init() {
        self.viewModel = MyFavoritesViewModel()
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()
        self.bind(toViewModel: self.viewModel)

        self.isLoading = true

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topView.backgroundColor = UIColor.App.backgroundSecondary

        self.backButton.tintColor = UIColor.App.textHeadlinePrimary

        self.topSliderCollectionView.backgroundColor = UIColor.App.backgroundSecondary

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary

        self.loadingScreenBaseView.backgroundColor = UIColor.App.backgroundPrimary
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: MyFavoritesViewModel) {

        viewModel.dataChangedPublisher
            .receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] in
                self?.tableView.reloadData()
                self?.isLoading = false
            })
            .store(in: &cancellables)

        viewModel.didSelectMatchAction = { match, image in
            if let matchInfo = Env.favoritesStorage.matchesInfoForMatch[match.id] {
                let matchDetailsViewController = MatchDetailsViewController(matchMode: .live, match: match)
                matchDetailsViewController.viewModel.gameSnapshot = image
                // self.navigationController?.pushViewController(matchDetailsViewController, animated: true)
                self.present(matchDetailsViewController, animated: true, completion: nil)
            }
            else {
                let matchDetailsViewController = MatchDetailsViewController(matchMode: .preLive, match: match)
                matchDetailsViewController.viewModel.gameSnapshot = image
                // self.navigationController?.pushViewController(matchDetailsViewController, animated: true)
                self.present(matchDetailsViewController, animated: true, completion: nil)

            }

        }
    }

}

//
// MARK: CollectionView Protocols
extension MyFavoritesViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(ListTypeCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }

        switch indexPath.row {
        case 0:
            cell.setupWithTitle(localized("my_games"))
        case 1:
            cell.setupWithTitle(localized("my_competitions"))
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
            ()
            self.viewModel.setFavoriteListType(.favoriteGames)

        case 1:
            ()
            self.viewModel.setFavoriteListType(.favoriteCompetitions)

        default:
            ()
        }
        self.topSliderCollectionView.reloadData()
        self.topSliderCollectionView.layoutIfNeeded()
        self.topSliderCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

    }

}

//
// MARK: TableView Protocols
extension MyFavoritesViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections(in: tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.tableView(tableView, numberOfRowsInSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.viewModel.tableView(tableView, cellForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        return self.viewModel.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
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

//
// MARK: - Actions
//
extension MyFavoritesViewController {
    @objc private func didTapBackButton() {
        self.viewModel.unregisterEndpoints()
        self.dismiss(animated: true, completion: nil)
    }
}

//
// MARK: Subviews initialization and setup
//
extension MyFavoritesViewController {

    private static func createTopView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        return button
    }

    private static func createTopSliderCollectionView() -> UICollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true

        return collectionView
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never

        return tableView
    }

    private static func createLoadingScreenBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }

    private func setupSubviews() {
        self.view.addSubview(self.topView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topSliderCollectionView)
        self.topView.bringSubviewToFront(self.backButton)

        self.view.addSubview(self.tableView)
        self.view.addSubview(self.loadingScreenBaseView)
        self.loadingScreenBaseView.addSubview(self.activityIndicatorView)
        self.loadingScreenBaseView.bringSubviewToFront(self.activityIndicatorView)

        self.topSliderCollectionView.register(ListTypeCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)
        self.topSliderCollectionView.delegate = self
        self.topSliderCollectionView.dataSource = self

        tableView.register(MatchLineTableViewCell.nib, forCellReuseIdentifier: MatchLineTableViewCell.identifier)
        tableView.register(BannerScrollTableViewCell.nib, forCellReuseIdentifier: BannerScrollTableViewCell.identifier)
        tableView.register(LoadingMoreTableViewCell.nib, forCellReuseIdentifier: LoadingMoreTableViewCell.identifier)
        tableView.register(TitleTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TitleTableViewHeader.identifier)
        tableView.register(TournamentTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TournamentTableViewHeader.identifier)
        tableView.register(ActivationAlertScrollableTableViewCell.nib, forCellReuseIdentifier: ActivationAlertScrollableTableViewCell.identifier)
        tableView.register(EmptyCardTableViewCell.nib, forCellReuseIdentifier: EmptyCardTableViewCell.identifier)

        tableView.register(SportSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SportSectionHeaderView.identifier)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.topView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topView.heightAnchor.constraint(equalToConstant: 70),

            self.backButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 10),
            self.backButton.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 20),
            self.backButton.widthAnchor.constraint(equalToConstant: 15),

            self.topSliderCollectionView.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor),
            self.topSliderCollectionView.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor),
            self.topSliderCollectionView.topAnchor.constraint(equalTo: self.topView.topAnchor),
            self.topSliderCollectionView.bottomAnchor.constraint(equalTo: self.topView.bottomAnchor)

        ])

        // TableView
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.topView.bottomAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        // Loading Screen
        NSLayoutConstraint.activate([
            self.loadingScreenBaseView.topAnchor.constraint(equalTo: self.topView.bottomAnchor),
            self.loadingScreenBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingScreenBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingScreenBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingScreenBaseView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingScreenBaseView.centerYAnchor)
        ])
    }

}
