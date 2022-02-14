//
//  SportLineTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 10/02/2022.
//

import UIKit
import Combine

class SportLineTableViewCell: UITableViewCell {

    var tappedMatchLineAction: (() -> Void)?

    private lazy var titleLabel: UILabel = {
        var titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.text = "Upcoming"
        titleLabel.font = AppFont.with(type: .semibold, size: 13)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    private lazy var linesStackView: UIStackView = {
        var linesStackView = UIStackView()
        linesStackView.axis = .vertical
        linesStackView.alignment = .fill
        linesStackView.distribution = .fill
        linesStackView.spacing = 8
        linesStackView.translatesAutoresizingMaskIntoConstraints = false
        return linesStackView
    }()

    private lazy var topCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        var topCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        topCollectionView.translatesAutoresizingMaskIntoConstraints = false
        topCollectionView.showsVerticalScrollIndicator = false
        topCollectionView.showsHorizontalScrollIndicator = false
        topCollectionView.alwaysBounceHorizontal = true
        topCollectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

        return topCollectionView
    }()

    private lazy var bottomCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        var bottomCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        bottomCollectionView.translatesAutoresizingMaskIntoConstraints = false
        bottomCollectionView.showsVerticalScrollIndicator = false
        bottomCollectionView.showsHorizontalScrollIndicator = false
        bottomCollectionView.alwaysBounceHorizontal = true
        bottomCollectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        return bottomCollectionView
    }()

    private lazy var seeAllView: UIView = {
        var seeAllView = UIView()
        seeAllView.layer.borderColor = UIColor.gray.cgColor
        seeAllView.layer.borderWidth = 2
        seeAllView.layer.cornerRadius = 6
        seeAllView.translatesAutoresizingMaskIntoConstraints = false
        return seeAllView
    }()

    private lazy var seeAllLabel: UILabel = {
        var seeAllLabel = UILabel()
        seeAllLabel.numberOfLines = 1
        seeAllLabel.text = "See All"
        seeAllLabel.font = AppFont.with(type: .semibold, size: 12)
        seeAllLabel.textAlignment = .center
        seeAllLabel.translatesAutoresizingMaskIntoConstraints = false
        return seeAllLabel
    }()

    private var showingBackSliderView: Bool = false

    private var viewModel: SportMatchLineViewModel?
    private var cancellables: Set<AnyCancellable> = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.viewModel = nil

        self.titleLabel.text = ""
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

        self.linesStackView.backgroundColor = .lightGray

        self.topCollectionView.backgroundView?.backgroundColor = .clear
        self.topCollectionView.backgroundColor = .clear

        self.bottomCollectionView.backgroundView?.backgroundColor = .clear
        self.bottomCollectionView.backgroundColor = .clear

        self.seeAllView.layer.borderColor = UIColor.App.separatorLine.cgColor

    }

    func configure(withViewModel viewModel: SportMatchLineViewModel) {

        self.viewModel = viewModel

        self.viewModel?.titlePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in self?.titleLabel.text = $0 })
            .store(in: &cancellables)

        self.viewModel?.refreshPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: reloadCollections)
            .store(in: &cancellables)
        
    }

    func reloadCollections() {
        self.topCollectionView.reloadData()
        self.bottomCollectionView.reloadData()
    }

}

extension SportLineTableViewCell: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        let screenWidth = UIScreen.main.bounds.size.width
//        let width = screenWidth*0.6
//
//        if scrollView.isTracking && scrollView.contentSize.width > screenWidth {
//            if scrollView.contentOffset.x + scrollView.frame.width > scrollView.contentSize.width + 100 {
//
//                let generator = UIImpactFeedbackGenerator(style: .heavy)
//                generator.prepare()
//                generator.impactOccurred()
//
//                self.tappedMatchLineAction?()
//
//                return
//            }
//        }
//
//        if scrollView.contentOffset.x > width {
//            if !self.showingBackSliderView {
//                self.showingBackSliderView = true
//                UIView.animate(withDuration: 0.2) {
//                    self.backSliderView.alpha = 1.0
//                }
//            }
//        }
//        else {
//            if self.showingBackSliderView {
//                self.showingBackSliderView = false
//                UIView.animate(withDuration: 0.2) {
//                    self.backSliderView.alpha = 0.0
//                }
//            }
//        }
//    }
}

extension SportLineTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

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
            }

            return cell
        }

        if indexPath.row == 0, let match = self.viewModel?.match(forLine: collectionLineIndex) {

            if self.viewModel?.isMatchLineLive() ?? false {
                guard
                    let cell = collectionView.dequeueCellType(LiveMatchWidgetCollectionViewCell.self, indexPath: indexPath)
                else {
                    fatalError()
                }
                cell.setupWithMatch(match)
                cell.tappedMatchWidgetAction = {
                    self.tappedMatchLineAction?()
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
                cell.setupWithMatch(match)
                cell.tappedMatchWidgetAction = {
                    self.tappedMatchLineAction?()
                }
                cell.shouldShowCountryFlag(true)
                return cell
            }
//            guard
//                let cell = collectionView.dequeueCellType(MatchWidgetCollectionViewCell.self, indexPath: indexPath)
//
//            else {
//                fatalError()
//            }
//
//                cell.setupWithMatch(match)
//                cell.tappedMatchWidgetAction = {
//                    self.tappedMatchLineAction?()
//                }
//
//            cell.shouldShowCountryFlag(true)
//            return cell
        }
        else {
            if let match = self.viewModel?.match(forLine: collectionLineIndex), let market = match.markets[safe: indexPath.row] {

                let teamsText = "\(match.homeParticipant.name) - \(match.awayParticipant.name)"
                let countryIso = match.venue?.isoCode ?? ""

                if market.outcomes.count == 2 {
                    if let cell = collectionView.dequeueCellType(OddDoubleCollectionViewCell.self, indexPath: indexPath) {
                        // TODO: cell.matchStatsViewModel = self.matchStatsViewModel
                        cell.setupWithMarket(market, match: match, teamsText: teamsText, countryIso: countryIso)
                        cell.tappedMatchWidgetAction = {
                            self.tappedMatchLineAction?()
                        }
                        return cell
                    }
                }
                else {
                    if let cell = collectionView.dequeueCellType(OddTripleCollectionViewCell.self, indexPath: indexPath) {
                        // TODO: cell.matchStatsViewModel = self.matchStatsViewModel
                        cell.setupWithMarket(market, match: match, teamsText: teamsText, countryIso: countryIso)
                        cell.tappedMatchWidgetAction = {
                            self.tappedMatchLineAction?()
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

        if indexPath.section == 1 {
            return CGSize(width: 99, height: MatchWidgetCollectionViewCell.cellHeight)
        }
        else {
            let screenWidth = UIScreen.main.bounds.size.width
            var width = screenWidth*0.87

            if width > 390 {
                width = 390
            }

            return CGSize(width: width, height: MatchWidgetCollectionViewCell.cellHeight) // design width: 331
        }
    }
}


extension SportLineTableViewCell {

    private func setupSubviews() {
        // Add subviews to self.view or each other
        self.contentView.addSubview(self.titleLabel)

        self.linesStackView.addArrangedSubview(self.topCollectionView)
        self.linesStackView.addArrangedSubview(self.bottomCollectionView)

        self.contentView.addSubview(self.linesStackView)

        self.contentView.addSubview(self.seeAllView)
        self.seeAllView.addSubview(self.seeAllLabel)

        self.topCollectionView.delegate = self
        self.topCollectionView.dataSource = self

        self.bottomCollectionView.delegate = self
        self.bottomCollectionView.dataSource = self

        self.topCollectionView.register(MatchWidgetCollectionViewCell.nib, forCellWithReuseIdentifier: MatchWidgetCollectionViewCell.identifier)
        self.topCollectionView.register(LiveMatchWidgetCollectionViewCell.nib, forCellWithReuseIdentifier: LiveMatchWidgetCollectionViewCell.identifier)
        self.topCollectionView.register(OddDoubleCollectionViewCell.nib, forCellWithReuseIdentifier: OddDoubleCollectionViewCell.identifier)
        self.topCollectionView.register(OddTripleCollectionViewCell.nib, forCellWithReuseIdentifier: OddTripleCollectionViewCell.identifier)
        self.topCollectionView.register(SeeMoreMarketsCollectionViewCell.nib, forCellWithReuseIdentifier: SeeMoreMarketsCollectionViewCell.identifier)
        self.topCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.identifier)

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
            self.linesStackView.bottomAnchor.constraint(equalTo: self.seeAllView.topAnchor, constant: -16),

            self.topCollectionView.heightAnchor.constraint(equalToConstant: 160),
            self.bottomCollectionView.heightAnchor.constraint(equalToConstant: 160),

            self.seeAllLabel.centerXAnchor.constraint(equalTo: self.seeAllView.centerXAnchor),
            self.seeAllLabel.centerYAnchor.constraint(equalTo: self.seeAllView.centerYAnchor),
            self.seeAllLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.seeAllView.trailingAnchor, constant: 8),

            self.seeAllView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            self.seeAllView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            self.seeAllView.heightAnchor.constraint(equalToConstant: 34),
            self.seeAllView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16),
     ])
    }
}
