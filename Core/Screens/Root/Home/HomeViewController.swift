//
//  HomeViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/02/2022.
//

import UIKit
import Combine

class HomeViewController: UIViewController {

    // MARK: - Public Properties
    var didTapBetslipButtonAction: (() -> Void)?
    var didSelectMatchAction: ((Match) -> Void)?

    // MARK: - Private Properties
    // Sub Views
    private lazy var topSliderBaseView: UIView = Self.createTopSliderBaseView()
    private lazy var topSliderSeparatorView: UIView = Self.createTopSliderSeparatorView()
    private lazy var topSliderCollectionView: UICollectionView = Self.createTopSliderCollectionView()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var betslipButtonView: UIView = Self.createBetslipButtonView()
    private lazy var betslipCountLabel: UILabel = Self.createBetslipCountLabel()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    // Logic
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: HomeViewModel

    // MARK: - Lifetime and Cycle
    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
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

        // Configure post-loading and self-dependent properties
        self.topSliderCollectionView.delegate = self
        self.topSliderCollectionView.dataSource = self

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.topSliderCollectionView.register(ListTypeCollectionViewCell.nib, forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)

        self.tableView.register(SportLineTableViewCell.self, forCellReuseIdentifier: SportLineTableViewCell.identifier)
        self.tableView.register(BannerScrollTableViewCell.nib, forCellReuseIdentifier: BannerScrollTableViewCell.identifier)
        self.tableView.register(MatchLineTableViewCell.nib, forCellReuseIdentifier: MatchLineTableViewCell.identifier)

        self.loadingBaseView.isHidden = true

        self.betslipCountLabel.isHidden = true

        let tapBetslipView = UITapGestureRecognizer(target: self, action: #selector(didTapBetslipView))
        betslipButtonView.addGestureRecognizer(tapBetslipView)

        self.bind(toViewModel: self.viewModel)
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.betslipButtonView.layer.cornerRadius = self.betslipButtonView.frame.height / 2
        self.betslipCountLabel.layer.cornerRadius = self.betslipCountLabel.frame.height / 2
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary
        self.tableView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary

        self.topSliderBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.topSliderSeparatorView.backgroundColor = UIColor.App.separatorLine

        self.loadingBaseView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.loadingActivityIndicatorView.tintColor = UIColor.gray

        self.topSliderCollectionView.backgroundView?.backgroundColor = .clear
        self.topSliderCollectionView.backgroundColor = .clear

        self.betslipCountLabel.backgroundColor = UIColor.App.alertError
        self.betslipButtonView.backgroundColor = UIColor.App.highlightPrimary
        self.betslipCountLabel.textColor = UIColor.App.buttonTextPrimary
        
    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: HomeViewModel) {

        viewModel.refreshPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.tableView.reloadData()
                self?.topSliderCollectionView.reloadData()
            })
            .store(in: &self.cancellables)

        viewModel.scrollToContentPublisher
            .compactMap({$0})
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newSection in
                self?.tableView.scrollToRow(at: IndexPath(row: 0, section: newSection),
                                            at: UITableView.ScrollPosition.top,
                                            animated: true)
            })
            .store(in: &self.cancellables)

    }

}

//
// MARK: - CollectionView Protocols
//
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.viewModel.numberOfSections()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.numberOfShortcuts(forSection: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(ListTypeCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }
        cell.setupWithTitle( self.viewModel.shortcutTitle(forSection: indexPath.section) ?? "")
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        self.viewModel.didSelectShortcut(atSection: indexPath.section)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
    }

}

//
// MARK: - TableView Protocols
//
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows(forSectionIndex: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard
            let contentType = self.viewModel.contentType(forSection: indexPath.section)
        else {
            fatalError()
        }

        switch contentType {
        case .userMessage:
            return UITableViewCell()
        case .bannerLine:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: BannerScrollTableViewCell.identifier) as? BannerScrollTableViewCell,
                let sportMatchLineViewModel = self.viewModel.bannerLineViewModel()
            else {
                fatalError()
            }
            cell.configure(withViewModel: sportMatchLineViewModel)
            return cell
        case .userFavorites:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: MatchLineTableViewCell.identifier) as? MatchLineTableViewCell,
                let match = self.viewModel.favoriteMatch(forIndex: indexPath.row)
            else {
                fatalError()
            }
            cell.setupWithMatch(match)
            cell.setupFavoriteMatchInfoPublisher(match: match)
            cell.tappedMatchLineAction = {
                self.didSelectMatchAction?(match)
            }

            return cell
        case .suggestedBets:
            return UITableViewCell()
        case .sport:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: SportLineTableViewCell.identifier) as? SportLineTableViewCell,
                let sportMatchLineViewModel = self.viewModel.sportMatchLineViewModel(forIndexPath: indexPath)
            else {
                fatalError()
            }
            cell.configure(withViewModel: sportMatchLineViewModel)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard
            let contentType = self.viewModel.contentType(forSection: indexPath.section)
        else {
            return UITableView.automaticDimension
        }

        switch contentType {
        case .userMessage:
            return 40
        case .bannerLine:
            return 174
        case .userFavorites:
            return UITableView.automaticDimension
        case .suggestedBets:
            return UITableView.automaticDimension
        case .sport:
            return UITableView.automaticDimension
        }

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard
            let contentType = self.viewModel.contentType(forSection: indexPath.section)
        else {
            return 356
        }

        switch contentType {
        case .userMessage:
            return 40
        case .bannerLine:
            return 174
        case .userFavorites:
            return MatchWidgetCollectionViewCell.cellHeight + 20
        case .suggestedBets:
            return 40
        case .sport:
            return 356
        }

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let titleView = UIView()
        titleView.backgroundColor = UIColor.App.backgroundSecondary

        let titleStackView = UIStackView()
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.axis = .horizontal
        titleStackView.distribution = .fill
        titleStackView.alignment = .fill
        titleStackView.spacing = 8

        let sportImageView = UIImageView()
        sportImageView.translatesAutoresizingMaskIntoConstraints = false
        sportImageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.with(type: .bold, size: 16)

        titleView.addSubview(titleStackView)
        titleStackView.addArrangedSubview(sportImageView)
        titleStackView.addArrangedSubview(titleLabel)

        NSLayoutConstraint.activate([
            sportImageView.widthAnchor.constraint(equalTo: sportImageView.heightAnchor, multiplier: 1),
            sportImageView.widthAnchor.constraint(equalToConstant: 16),

            titleStackView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 18),
            titleStackView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: 18),

            titleStackView.topAnchor.constraint(equalTo: titleView.topAnchor),
            titleStackView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
        ])

        if let title = self.viewModel.title(forSection: section).0 {
            titleLabel.text = title
        }
        if let imageName = self.viewModel.title(forSection: section).1 {
            sportImageView.image = UIImage(named: "sport_type_icon_\(imageName)")
        }
        else {
            sportImageView.isHidden = true
        }

        return titleView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard
            let contentType = self.viewModel.contentType(forSection: section)
        else {
            return .leastNormalMagnitude
        }

        switch contentType {
        case .userMessage:
            return .leastNormalMagnitude
        case .bannerLine:
            return .leastNormalMagnitude
        case .userFavorites:
            return 40
        case .suggestedBets:
            return .leastNormalMagnitude
        case .sport:
            return 40
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        guard
            let contentType = self.viewModel.contentType(forSection: section)
        else {
            return .leastNormalMagnitude
        }

        switch contentType {
        case .userMessage:
            return .leastNormalMagnitude
        case .bannerLine:
            return .leastNormalMagnitude
        case .userFavorites:
            return 40
        case .suggestedBets:
            return .leastNormalMagnitude
        case .sport:
            return 40
        }
    }
}

//
// MARK: - Actions
//
extension HomeViewController {
    @objc func didTapBetslipView() {
        self.didTapBetslipButtonAction?()
    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension HomeViewController {

    private static func createTopSliderBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTopSliderSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTopSliderCollectionView() -> UICollectionView {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = .horizontal
        collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: collectionLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

        return collectionView
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }

    private static func createBetslipButtonView() -> UIView {
        let betslipButtonView = UIView()
        betslipButtonView.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(named: "betslip_button_icon")
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
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
        NSLayoutConstraint.activate([
            betslipCountLabel.widthAnchor.constraint(equalToConstant: 20),
            betslipCountLabel.widthAnchor.constraint(equalTo: betslipCountLabel.heightAnchor),
        ])
        return betslipCountLabel
    }

    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoadingActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.stopAnimating()
        return activityIndicatorView
    }

    private func setupSubviews() {

        // Add subviews to self.view or each other
        self.view.addSubview(self.topSliderBaseView)
        self.topSliderBaseView.addSubview(self.topSliderCollectionView)
        self.topSliderBaseView.addSubview(self.topSliderSeparatorView)

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.loadingBaseView)
        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.betslipButtonView.addSubview(self.betslipCountLabel)

        self.view.addSubview(self.betslipButtonView)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topSliderBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSliderBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSliderBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSliderBaseView.heightAnchor.constraint(equalToConstant: 70),

            self.topSliderCollectionView.leadingAnchor.constraint(equalTo: self.topSliderBaseView.leadingAnchor),
            self.topSliderCollectionView.trailingAnchor.constraint(equalTo: self.topSliderBaseView.trailingAnchor),
            self.topSliderCollectionView.topAnchor.constraint(equalTo: self.topSliderBaseView.topAnchor),
            self.topSliderCollectionView.bottomAnchor.constraint(equalTo: self.topSliderBaseView.bottomAnchor),

            self.topSliderSeparatorView.leadingAnchor.constraint(equalTo: self.topSliderBaseView.leadingAnchor),
            self.topSliderSeparatorView.trailingAnchor.constraint(equalTo: self.topSliderBaseView.trailingAnchor),
            self.topSliderSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            self.topSliderSeparatorView.bottomAnchor.constraint(equalTo: self.topSliderBaseView.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.topSliderBaseView.bottomAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            self.betslipCountLabel.trailingAnchor.constraint(equalTo: self.betslipButtonView.trailingAnchor, constant: 2),
            self.betslipCountLabel.topAnchor.constraint(equalTo: self.betslipButtonView.topAnchor, constant: -3),

            self.betslipButtonView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
            self.betslipButtonView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -12),
        ])

    }

}
