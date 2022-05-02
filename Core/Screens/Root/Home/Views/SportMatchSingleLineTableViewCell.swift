//
//  SportMatchSingleLineTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/02/2022.
//

import UIKit
import Combine

class SportMatchSingleLineTableViewCell: UITableViewCell {

    var didSelectSeeAllPopular: ((Sport) -> Void)?
    var didSelectSeeAllLive: ((Sport) -> Void)?

    var didSelectSeeAllCompetitionAction: ((Competition) -> Void)?

    var tappedMatchLineAction: ((Match) -> Void)?
    var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?
    
    var didTapFavoriteMatchAction: ((Match) -> Void)?

    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var linesStackView: UIStackView = Self.createLinesStackView()
    private lazy var collectionView: UICollectionView = Self.createCollectionView()
    private lazy var seeAllView: UIView = Self.createSeeAllView()
    private lazy var seeAllLabel: UILabel = Self.createSeeAllLabel()
    private lazy var backView: UIView = Self.createBackView()
    private lazy var backImage: UIImageView = Self.createBackImage()
    
    private var showingBackSliderView: Bool = false

    private var viewModel: SportMatchLineViewModel?
    private var cancellables: Set<AnyCancellable> = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapSeeAllView))
        self.seeAllView.addGestureRecognizer(tapGestureRecognizer)
        
        self.backView.layer.cornerRadius = 6
        self.backView.alpha = 0.0
        
        let backFirstSliderTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackSliderButton))
        self.backView.addGestureRecognizer(backFirstSliderTapGesture)

        self.contentView.bringSubviewToFront(self.backView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.viewModel = nil

        self.collectionView.setContentOffset(CGPoint(x: -8, y: 0), animated: false)

        self.showingBackSliderView = false
        self.backView.alpha = 0.0

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

        self.collectionView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        self.collectionView.backgroundColor = UIColor.App.backgroundPrimary

        self.backView.backgroundColor = UIColor.App.buttonBackgroundSecondary

        self.seeAllView.backgroundColor = UIColor.App.backgroundPrimary
        self.seeAllLabel.textColor = UIColor.App.highlightPrimary

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

        self.seeAllLabel.text = "See All"

        self.reloadCollections()
    }

    func reloadCollections() {
        self.collectionView.reloadData()

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
    
    @objc func didTapBackSliderButton() {
        let resetPoint = CGPoint(x: -self.collectionView.contentInset.left, y: 0)
        self.collectionView.setContentOffset(resetPoint, animated: true)
    }
}

extension SportMatchSingleLineTableViewCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView == self.collectionView, let firstMatch = self.viewModel?.match(forLine: 0) {
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
       
            let width = screenWidth*0.6

            if scrollView.contentOffset.x > width {
                if !self.showingBackSliderView {
                    self.showingBackSliderView = true
                    UIView.animate(withDuration: 0.2) {
                        self.backView.alpha = 1.0
                    }
                }
            }
            else {
                if self.showingBackSliderView {
                    self.showingBackSliderView = false
                    UIView.animate(withDuration: 0.2) {
                        self.backView.alpha = 0.0
                    }
                }
            }
        
        }

//        let width = screenWidth*0.6
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
    }
    
}

extension SportMatchSingleLineTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let viewModel = self.viewModel else { return 0 }
        return viewModel.numberOfSections(forLine: 0)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel else { return 0 }
        return viewModel.numberOfItems(forLine: 0, forSection: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let viewModel = self.viewModel else { fatalError() }

        if indexPath.section == 1 {
            guard
                let cell = collectionView.dequeueCellType(SeeMoreMarketsCollectionViewCell.self, indexPath: indexPath)
            else {
                fatalError()
            }
            if let numberTotalOfMarkets = self.viewModel?.numberOfMatchMarket(forLine: 0) {
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

                if self.viewModel?.isOutrightCompetitionLine() ?? false {
                    if let competition = self.viewModel?.outrightCompetition(forLine: 0) {
                        cell.tappedAction = { [weak self] in
                            self?.didSelectSeeAllCompetitionAction?(competition)
                        }
                    }
                } else if let match = viewModel.match() {
                    cell.tappedAction = { [weak self] in
                        self?.tappedMatchLineAction?(match)
                    }
                }
            }

            return cell
        }
        else if self.viewModel?.isOutrightCompetitionLine() ?? false,
                let competition = self.viewModel?.outrightCompetition(forLine: 0),
                let cell = collectionView.dequeueCellType(OutrightCompetitionLargeWidgetCollectionViewCell.self, indexPath: indexPath) {

            let cellViewModel = OutrightCompetitionLargeWidgetViewModel(competition: competition)
            cell.configure(withViewModel: cellViewModel)
            cell.tappedLineAction = { [weak self] competition in
                self?.didSelectSeeAllCompetitionAction?(competition)
            }
            return cell
        }

        else if indexPath.row == 0, let match = viewModel.match() {

            if viewModel.isMatchLineLive() {
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
//                cell.didTapFavoriteMatchAction = { [weak self] match in
//                    self?.didTapFavoriteMatchAction?(match)
//                }
                
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
//                cell.didTapFavoriteMatchAction = { [weak self] match in
//                    self?.didTapFavoriteMatchAction?(match)
//                }
                cell.shouldShowCountryFlag(true)
                return cell
            }
        }
        else {
            if let match = viewModel.match(), let market = match.markets[safe: indexPath.row] {

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
                        cell.tappedMatchWidgetAction = { [weak self] in
                            self?.tappedMatchLineAction?(match)
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
                        cell.tappedMatchWidgetAction = { [weak self] in
                            self?.tappedMatchLineAction?(match)
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

extension SportMatchSingleLineTableViewCell {

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
    
    private static func createBackView() -> UIView {
        let backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        return backView
    }
    
    private static func createBackImage() -> UIImageView {
        let backImage = UIImageView()
        backImage.translatesAutoresizingMaskIntoConstraints = false
        backImage.image = UIImage(named: "arrow_circle_left_icon")
        return backImage
    }

    private static func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        return collectionView
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

        self.linesStackView.addArrangedSubview(self.collectionView)

        self.backView.addSubview(self.backImage)

        self.contentView.addSubview(self.backView)
        self.contentView.addSubview(self.linesStackView)
        self.contentView.addSubview(self.seeAllView)

        self.seeAllView.addSubview(self.seeAllLabel)

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(CompetitionWidgetCollectionViewCell.self, forCellWithReuseIdentifier: CompetitionWidgetCollectionViewCell.identifier)

        self.collectionView.register(OutrightCompetitionLargeWidgetCollectionViewCell.self,
                                           forCellWithReuseIdentifier: OutrightCompetitionLargeWidgetCollectionViewCell.identifier)

        self.collectionView.register(MatchWidgetCollectionViewCell.nib, forCellWithReuseIdentifier: MatchWidgetCollectionViewCell.identifier)
        self.collectionView.register(LiveMatchWidgetCollectionViewCell.nib, forCellWithReuseIdentifier: LiveMatchWidgetCollectionViewCell.identifier)
        self.collectionView.register(OddDoubleCollectionViewCell.nib, forCellWithReuseIdentifier: OddDoubleCollectionViewCell.identifier)
        self.collectionView.register(OddTripleCollectionViewCell.nib, forCellWithReuseIdentifier: OddTripleCollectionViewCell.identifier)
        self.collectionView.register(SeeMoreMarketsCollectionViewCell.nib, forCellWithReuseIdentifier: SeeMoreMarketsCollectionViewCell.identifier)
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.identifier)

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

            self.collectionView.heightAnchor.constraint(equalToConstant: 160),

            self.seeAllLabel.centerXAnchor.constraint(equalTo: self.seeAllView.centerXAnchor),
            self.seeAllLabel.centerYAnchor.constraint(equalTo: self.seeAllView.centerYAnchor),
            self.seeAllLabel.trailingAnchor.constraint(equalTo: self.seeAllView.trailingAnchor),

            self.seeAllView.heightAnchor.constraint(equalToConstant: 34),
            self.seeAllView.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
            self.seeAllView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -22),

            self.backView.centerYAnchor.constraint(equalTo: self.collectionView.centerYAnchor),
            self.backView.leadingAnchor.constraint(equalTo: self.collectionView.leadingAnchor, constant: -36),
            self.backView.heightAnchor.constraint(equalToConstant: 38),
            self.backView.widthAnchor.constraint(equalToConstant: 78),
            
            self.backImage.centerYAnchor.constraint(equalTo: self.backView.centerYAnchor),
            self.backImage.trailingAnchor.constraint(equalTo: self.backView.trailingAnchor, constant: -7),
            self.backImage.heightAnchor.constraint(equalToConstant: 24),
            self.backImage.widthAnchor.constraint(equalToConstant: 24),

        ])
    }
}
