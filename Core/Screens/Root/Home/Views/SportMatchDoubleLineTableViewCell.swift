//
//  SportMatchDoubleLineTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/02/2022.
//

import UIKit
import Combine

class SportMatchDoubleLineTableViewCell: UITableViewCell {

    var didSelectSeeAllPopular: ((Sport) -> Void)?
    var didSelectSeeAllLive: ((Sport) -> Void)?

    var didSelectSeeAllCompetitionAction: ((Competition) -> Void)?

    var tappedMatchLineAction: ((Match) -> Void)?
    var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?

    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var linesStackView: UIStackView = Self.createLinesStackView()
    private lazy var topCollectionView: UICollectionView = Self.createTopCollectionView()
    private lazy var bottomCollectionView: UICollectionView = Self.createBottomCollectionView()
    private lazy var seeAllBaseView: UIView = Self.createSeeAllBaseView()
    private lazy var seeAllView: UIView = Self.createSeeAllView()
    private lazy var seeAllLabel: UILabel = Self.createSeeAllLabel()

    private var showingBackSliderView: Bool = false

    private var viewModel: SportMatchLineViewModel?
    private var cancellables: Set<AnyCancellable> = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapSeeAllView))
        self.seeAllBaseView.addGestureRecognizer(tapGestureRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.viewModel = nil

        self.reloadCollections()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.linesStackView.backgroundColor = UIColor.App.backgroundPrimary

        self.topCollectionView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        self.topCollectionView.backgroundColor = UIColor.App.backgroundPrimary

        self.bottomCollectionView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        self.bottomCollectionView.backgroundColor = UIColor.App.backgroundPrimary

        self.seeAllView.backgroundColor = UIColor.App.backgroundTertiary
        self.seeAllView.layer.borderColor = UIColor.App.separatorLine.cgColor
        self.seeAllLabel.textColor = UIColor.App.textPrimary
    }

    func configure(withViewModel viewModel: SportMatchLineViewModel) {

        self.viewModel = viewModel

        self.viewModel?.titlePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.titleLabel.text = $0
            })
            .store(in: &cancellables)

        self.viewModel?.refreshPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.reloadCollections()
            })
            .store(in: &cancellables)

        self.seeAllLabel.text = "Go to Popular"
        if self.viewModel?.isMatchLineLive() ?? false {
            self.seeAllLabel.text = "Go to Live"
        }

        self.reloadCollections()
    }

    func reloadCollections() {
        self.topCollectionView.reloadData()
        self.bottomCollectionView.reloadData()
    }

    @objc func didTapSeeAllView() {

        guard let viewModel = self.viewModel else { return }

        if viewModel.isMatchLineLive() {
            self.didSelectSeeAllLive?(viewModel.sport)
        }
        else {
            self.didSelectSeeAllPopular?(viewModel.sport)
        }

    }
}

extension SportMatchDoubleLineTableViewCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView == self.topCollectionView, let firstMatch = self.viewModel?.match(forLine: 0) {
            let screenWidth = UIScreen.main.bounds.size.width
            if scrollView.isTracking && scrollView.contentSize.width > screenWidth {
                if scrollView.contentOffset.x + scrollView.frame.width > scrollView.contentSize.width + 100 {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.prepare()
                    generator.impactOccurred()
                    self.tappedMatchLineAction?(firstMatch)
                    return
                }
            }
        }
        else if scrollView == self.bottomCollectionView, let secondMatch = self.viewModel?.match(forLine: 1) {
            let screenWidth = UIScreen.main.bounds.size.width
            if scrollView.isTracking && scrollView.contentSize.width > screenWidth {
                if scrollView.contentOffset.x + scrollView.frame.width > scrollView.contentSize.width + 100 {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.prepare()
                    generator.impactOccurred()
                    self.tappedMatchLineAction?(secondMatch)
                    return
                }
            }
        }

    }
    
}

extension SportMatchDoubleLineTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {

        guard let viewModel = self.viewModel else { return 0 }

        if collectionView == self.topCollectionView {
            return viewModel.numberOfSections(forLine: 0)
        }
        else if collectionView == self.bottomCollectionView {
            return viewModel.numberOfSections(forLine: 1)
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        guard let viewModel = self.viewModel else { return 0 }

        if collectionView == self.topCollectionView {
            return viewModel.numberOfItems(forLine: 0, forSection: section)
        }
        else if collectionView == self.bottomCollectionView {
            return viewModel.numberOfItems(forLine: 1, forSection: section)
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        var collectionLineIndex: Int?
        if collectionView == self.topCollectionView {
            collectionLineIndex = 0
        }
        else if collectionView == self.bottomCollectionView {
            collectionLineIndex = 1
        }

        guard let collectionLineIndex = collectionLineIndex else {
            fatalError()
        }

        guard let viewModel = self.viewModel else {
            fatalError()
        }

        if indexPath.section == 1 {
            guard
                let cell = collectionView.dequeueCellType(SeeMoreMarketsCollectionViewCell.self, indexPath: indexPath)
            else {
                fatalError()
            }

            if let numberTotalOfMarkets = self.viewModel?.numberOfMatchMarket(forLine: collectionLineIndex) {
                let marketsRawString = localized("number_of_markets")
                let singularMarketRawString = localized("number_of_market_singular")
                var marketString = ""
                if numberTotalOfMarkets > 1 {
                    marketString = marketsRawString.replacingOccurrences(of: "%s", with: "\(numberTotalOfMarkets)")
                }
                else {
                    marketString = singularMarketRawString.replacingOccurrences(of: "%s", with: "\(numberTotalOfMarkets)")
                }
                cell.configureWithSubtitleString(marketString)

                if numberTotalOfMarkets == 0 {
                    cell.hideSubtitle()
                }

                if let match = viewModel.match() {
                    cell.tappedAction = { [weak self] in
                        self?.tappedMatchLineAction?(match)
                    }
                }
            }
            return cell
        }
        else if self.viewModel?.isOutrightCompetitionLine() ?? false,
                let competition = self.viewModel?.outrightCompetition(forLine: collectionLineIndex),
                let cell = collectionView.dequeueCellType(OutrightCompetitionWidgetCollectionViewCell.self, indexPath: indexPath) {

            let cellViewModel = OutrightCompetitionWidgetViewModel(competition: competition)
            cell.configure(withViewModel: cellViewModel)
            cell.tappedLineAction = { [weak self] competition in
                self?.didSelectSeeAllCompetitionAction?(competition)
            }
            return cell
        }
        else if indexPath.row == 0, let match = self.viewModel?.match(forLine: collectionLineIndex) {

            if self.viewModel?.isMatchLineLive() ?? false {
                guard
                    let cell = collectionView.dequeueCellType(LiveMatchWidgetCollectionViewCell.self, indexPath: indexPath)
                else {
                    fatalError()
                }

                let cellViewModel = MatchWidgetCellViewModel(match: match, store: viewModel.store)

                cell.configure(withViewModel: cellViewModel)
                cell.tappedMatchWidgetAction = { [weak self] in
                    self?.tappedMatchLineAction?(match)
                }
                cell.shouldShowCountryFlag(true)
                return cell

            }
            else {
                guard
                    let cell = collectionView.dequeueCellType(MatchWidgetCollectionViewCell.self, indexPath: indexPath)
                else {
                    fatalError()
                }

                let cellViewModel = MatchWidgetCellViewModel(match: match, store: viewModel.store)

                cell.configure(withViewModel: cellViewModel)
                cell.tappedMatchWidgetAction = { [weak self] in
                    self?.tappedMatchLineAction?(match)
                }
                cell.shouldShowCountryFlag(true)
                return cell
            }
        }
        else {
            if let match = viewModel.match(forLine: collectionLineIndex), let market = match.markets[safe: indexPath.row] {

                let teamsText = "\(match.homeParticipant.name) - \(match.awayParticipant.name)"
                let countryIso = match.venue?.isoCode ?? ""

                if market.outcomes.count == 2 {
                    if let cell = collectionView.dequeueCellType(OddDoubleCollectionViewCell.self, indexPath: indexPath) {

                        if let matchStatsViewModel = self.matchStatsViewModelForMatch?(match) {
                            cell.matchStatsViewModel = matchStatsViewModel
                        }
                        cell.setupWithMarket(market, match: match,
                                             teamsText: teamsText,
                                             countryIso: countryIso,
                                             store: viewModel.store)
                        cell.tappedMatchWidgetAction = {
                            self.tappedMatchLineAction?(match)
                        }
                        return cell
                    }
                }
                else {
                    if let cell = collectionView.dequeueCellType(OddTripleCollectionViewCell.self, indexPath: indexPath) {

                        if let matchStatsViewModel = self.matchStatsViewModelForMatch?(match) {
                            cell.matchStatsViewModel = matchStatsViewModel
                        }
                        cell.setupWithMarket(market, match: match,
                                             teamsText: teamsText,
                                             countryIso: countryIso,
                                             store: viewModel.store)
                        cell.tappedMatchWidgetAction = {
                            self.tappedMatchLineAction?(match)
                        }
                        return cell
                    }
                }
            }
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.identifier, for: indexPath)
        cell.backgroundView?.backgroundColor = UIColor.App.backgroundCards
        cell.backgroundColor = UIColor.App.backgroundCards
        cell.layer.cornerRadius = 9
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellHeight = MatchWidgetCollectionViewCell.cellHeight
        if indexPath.section == 1 {
            return CGSize(width: 99, height: cellHeight)
        }
        else {
            let screenWidth = UIScreen.main.bounds.size.width
            var width = screenWidth*0.87
            if width > 390 {
                width = 390
            }
            return CGSize(width: width, height: cellHeight)
        }
    }
}

extension SportMatchDoubleLineTableViewCell {

    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.text = ""
        titleLabel.font = AppFont.with(type: .semibold, size: 13)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }

    private static func createLinesStackView() -> UIStackView {
        let linesStackView = UIStackView()
        linesStackView.axis = .vertical
        linesStackView.alignment = .fill
        linesStackView.distribution = .fill
        linesStackView.spacing = 8
        linesStackView.translatesAutoresizingMaskIntoConstraints = false
        return linesStackView
    }

    private static func createTopCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let topCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        topCollectionView.translatesAutoresizingMaskIntoConstraints = false
        topCollectionView.showsVerticalScrollIndicator = false
        topCollectionView.showsHorizontalScrollIndicator = false
        topCollectionView.alwaysBounceHorizontal = true
        topCollectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        return topCollectionView
    }

    private static func createBottomCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let bottomCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        bottomCollectionView.translatesAutoresizingMaskIntoConstraints = false
        bottomCollectionView.showsVerticalScrollIndicator = false
        bottomCollectionView.showsHorizontalScrollIndicator = false
        bottomCollectionView.alwaysBounceHorizontal = true
        bottomCollectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        return bottomCollectionView
    }

    private static func createSeeAllBaseView() -> UIView {
        let seeAllView = UIView()
        seeAllView.translatesAutoresizingMaskIntoConstraints = false
        return seeAllView
    }

    private static func createSeeAllView() -> UIView {
        let seeAllView = UIView()
        seeAllView.layer.borderColor = UIColor.gray.cgColor
        seeAllView.layer.borderWidth = 0
        seeAllView.layer.cornerRadius = 6
        seeAllView.translatesAutoresizingMaskIntoConstraints = false
        return seeAllView
    }

    private static func createSeeAllLabel() -> UILabel {
        let seeAllLabel = UILabel()
        seeAllLabel.numberOfLines = 1
        seeAllLabel.text = "See All"
        seeAllLabel.font = AppFont.with(type: .semibold, size: 12)
        seeAllLabel.textAlignment = .center
        seeAllLabel.translatesAutoresizingMaskIntoConstraints = false
        return seeAllLabel
    }

    private func setupSubviews() {
        // Add subviews to self.view or each other
        self.contentView.addSubview(self.titleLabel)
        self.contentView.clipsToBounds = true
        
        self.linesStackView.addArrangedSubview(self.topCollectionView)
        self.linesStackView.addArrangedSubview(self.bottomCollectionView)
        self.linesStackView.addArrangedSubview(self.seeAllBaseView)

        self.contentView.addSubview(self.linesStackView)

        self.seeAllBaseView.addSubview(self.seeAllView)
        self.seeAllView.addSubview(self.seeAllLabel)

        self.topCollectionView.delegate = self
        self.topCollectionView.dataSource = self

        self.bottomCollectionView.delegate = self
        self.bottomCollectionView.dataSource = self

        self.topCollectionView.register(CompetitionWidgetCollectionViewCell.self, forCellWithReuseIdentifier: CompetitionWidgetCollectionViewCell.identifier)

        self.topCollectionView.register(OutrightCompetitionWidgetCollectionViewCell.self,
                                        forCellWithReuseIdentifier: OutrightCompetitionWidgetCollectionViewCell.identifier)
        self.topCollectionView.register(MatchWidgetCollectionViewCell.nib, forCellWithReuseIdentifier: MatchWidgetCollectionViewCell.identifier)
        self.topCollectionView.register(LiveMatchWidgetCollectionViewCell.nib, forCellWithReuseIdentifier: LiveMatchWidgetCollectionViewCell.identifier)
        self.topCollectionView.register(OddDoubleCollectionViewCell.nib, forCellWithReuseIdentifier: OddDoubleCollectionViewCell.identifier)
        self.topCollectionView.register(OddTripleCollectionViewCell.nib, forCellWithReuseIdentifier: OddTripleCollectionViewCell.identifier)
        self.topCollectionView.register(SeeMoreMarketsCollectionViewCell.nib, forCellWithReuseIdentifier: SeeMoreMarketsCollectionViewCell.identifier)
        self.topCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.identifier)

        self.bottomCollectionView.register(OutrightCompetitionWidgetCollectionViewCell.self,
                                           forCellWithReuseIdentifier: OutrightCompetitionWidgetCollectionViewCell.identifier)
        self.bottomCollectionView.register(MatchWidgetCollectionViewCell.nib, forCellWithReuseIdentifier: MatchWidgetCollectionViewCell.identifier)
        self.bottomCollectionView.register(LiveMatchWidgetCollectionViewCell.nib, forCellWithReuseIdentifier: LiveMatchWidgetCollectionViewCell.identifier)
        self.bottomCollectionView.register(OddDoubleCollectionViewCell.nib, forCellWithReuseIdentifier: OddDoubleCollectionViewCell.identifier)
        self.bottomCollectionView.register(OddTripleCollectionViewCell.nib, forCellWithReuseIdentifier: OddTripleCollectionViewCell.identifier)
        self.bottomCollectionView.register(SeeMoreMarketsCollectionViewCell.nib, forCellWithReuseIdentifier: SeeMoreMarketsCollectionViewCell.identifier)
        self.bottomCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.identifier)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([            
            self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 24),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            self.titleLabel.heightAnchor.constraint(equalToConstant: 19),

            self.linesStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.linesStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.linesStackView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 16),
            self.linesStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16),

            self.topCollectionView.heightAnchor.constraint(equalToConstant: 160),
            self.bottomCollectionView.heightAnchor.constraint(equalToConstant: 160),

            self.seeAllLabel.centerXAnchor.constraint(equalTo: self.seeAllView.centerXAnchor),
            self.seeAllLabel.centerYAnchor.constraint(equalTo: self.seeAllView.centerYAnchor),
            self.seeAllLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.seeAllView.trailingAnchor, constant: 8),

            self.seeAllView.heightAnchor.constraint(equalToConstant: 34),

            self.seeAllBaseView.leadingAnchor.constraint(equalTo: self.seeAllView.leadingAnchor, constant: -16),
            self.seeAllBaseView.trailingAnchor.constraint(equalTo: self.seeAllView.trailingAnchor, constant: 16),

            self.seeAllBaseView.topAnchor.constraint(equalTo: self.seeAllView.topAnchor),
            self.seeAllBaseView.bottomAnchor.constraint(equalTo: self.seeAllView.bottomAnchor),
     ])
    }
}
