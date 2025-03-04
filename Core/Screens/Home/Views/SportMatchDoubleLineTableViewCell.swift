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

    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var didLongPressOdd: ((BettingTicket) -> Void)?

    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var linesStackView: UIStackView = Self.createLinesStackView()
    private lazy var topCollectionView: UICollectionView = Self.createTopCollectionView()
    private lazy var bottomCollectionView: UICollectionView = Self.createBottomCollectionView()
    private lazy var seeAllView: UIView = Self.createSeeAllView()
    private lazy var seeAllLabel: UILabel = Self.createSeeAllLabel()
    private lazy var firstBackView: UIView = Self.createBackView()
    private lazy var secondBackView: UIView = Self.createBackView()
    private lazy var firstBackImage: UIImageView = Self.createBackImage()
    private lazy var secondBackImage: UIImageView = Self.createBackImage()

    private var topCollectionViewHeightConstraint: NSLayoutConstraint!
    private var bottomCollectionViewHeightConstraint: NSLayoutConstraint!
    private let cellInternSpace: CGFloat = 2.0
    private var cachedCardStyle: CardsStyle?

    private var collectionViewHeight: CGFloat {
        let cardHeight = StyleHelper.cardsStyleHeight()
        return cardHeight + cellInternSpace + cellInternSpace
    }

    private var showingFirstBackSliderView: Bool = false
    private var showingSecondBackSliderView: Bool = false

    private var viewModel: SportMatchLineViewModel?
    private var cancellables: Set<AnyCancellable> = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.cachedCardStyle = StyleHelper.cardsStyleActive()
        
        self.setupSubviews()
        self.setupWithTheme()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapSeeAllView))
        self.seeAllView.addGestureRecognizer(tapGestureRecognizer)
        
        self.firstBackView.layer.cornerRadius = 6
        self.firstBackView.alpha = 0.0
        
        let backFirstSliderTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapFirstBackSliderButton))
        self.firstBackView.addGestureRecognizer(backFirstSliderTapGesture)
        
        self.secondBackView.layer.cornerRadius = 6
        self.secondBackView.alpha = 0.0
        
        let backSecondSliderTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSecondBackSliderButton))
        self.secondBackView.addGestureRecognizer(backSecondSliderTapGesture)

        self.contentView.bringSubviewToFront(self.firstBackView)
        self.contentView.bringSubviewToFront(self.secondBackView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.viewModel = nil

        self.topCollectionView.setContentOffset(CGPoint(x: -8, y: 0), animated: false)
        self.bottomCollectionView.setContentOffset(CGPoint(x: -8, y: 0), animated: false)

        self.showingFirstBackSliderView = false
        self.firstBackView.alpha = 0.0

        self.showingSecondBackSliderView = false
        self.secondBackView.alpha = 0.0

        if self.cachedCardStyle != StyleHelper.cardsStyleActive() {
            self.cachedCardStyle = StyleHelper.cardsStyleActive()
            self.topCollectionViewHeightConstraint.constant = collectionViewHeight
            self.bottomCollectionViewHeightConstraint.constant = collectionViewHeight

            self.setNeedsLayout()
            self.layoutIfNeeded()
        }

        self.reloadCollections()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.linesStackView.backgroundColor = .clear

        self.topCollectionView.backgroundView?.backgroundColor = .clear
        self.topCollectionView.backgroundColor = .clear

        self.bottomCollectionView.backgroundView?.backgroundColor = .clear
        self.bottomCollectionView.backgroundColor = .clear

        self.firstBackView.backgroundColor = UIColor.App.buttonBackgroundSecondary
        self.secondBackView.backgroundColor = UIColor.App.buttonBackgroundSecondary

        self.seeAllView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.seeAllLabel.textColor = UIColor.App.highlightSecondary
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

        self.seeAllLabel.text = localized("see_all")

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
    
    @objc func didTapFirstBackSliderButton() {
        let resetPoint = CGPoint(x: -self.topCollectionView.contentInset.left, y: 1)
        self.topCollectionView.setContentOffset(resetPoint, animated: true)

    }
    @objc func didTapSecondBackSliderButton() {
        let resetPoint = CGPoint(x: -self.bottomCollectionView.contentInset.left, y: 1)
        self.bottomCollectionView.setContentOffset(resetPoint, animated: true)
    }
}

extension SportMatchDoubleLineTableViewCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let screenWidth = UIScreen.main.bounds.size.width
        let width = screenWidth*0.6
        
        let pushScreenMargin = 100.0
        let bounceXPosition = ( (scrollView.contentOffset.x - scrollView.contentInset.left) + scrollView.frame.width) - scrollView.contentSize.width
        
        if scrollView == self.topCollectionView {
            
            if bounceXPosition >= 0 {
                for cell in self.topCollectionView.visibleCells {
                    if let seeMoreCell = cell as? SeeMoreMarketsCollectionViewCell {
                        seeMoreCell.setAnimationPercentage(bounceXPosition / Double(pushScreenMargin * 0.98))
                    }
                }
            }
            
            if scrollView.isTracking && scrollView.contentSize.width > screenWidth {
                if scrollView.contentOffset.x + scrollView.frame.width > scrollView.contentSize.width + pushScreenMargin {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.prepare()
                    generator.impactOccurred()

                    if self.viewModel?.isOutrightCompetitionLine() ?? false, let competition = self.viewModel?.outrightCompetition(forLine: 0) {
                        self.didSelectSeeAllCompetitionAction?(competition)
                    }
                    else if let firstMatch = self.viewModel?.match(forLine: 0) {
                        self.tappedMatchLineAction?(firstMatch)
                    }

                    return
                }
            }

            if scrollView.contentOffset.x > width {
                if !self.showingFirstBackSliderView {
                    self.showingFirstBackSliderView = true
                    UIView.animate(withDuration: 0.2) {
                        self.firstBackView.alpha = 1.0
                    }
                }
            }
            else {
                if self.showingFirstBackSliderView {
                    self.showingFirstBackSliderView = false
                    UIView.animate(withDuration: 0.2) {
                        self.firstBackView.alpha = 0.0
                    }
                }
            }
        }
        else if scrollView == self.bottomCollectionView {

            if bounceXPosition >= 0 {
                for cell in self.bottomCollectionView.visibleCells {
                    if let seeMoreCell = cell as? SeeMoreMarketsCollectionViewCell {
                        seeMoreCell.setAnimationPercentage(bounceXPosition / Double(pushScreenMargin * 0.98))
                    }
                }
            }
            
            if scrollView.isTracking && scrollView.contentSize.width > screenWidth {
                if scrollView.contentOffset.x + scrollView.frame.width > scrollView.contentSize.width + pushScreenMargin {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.prepare()
                    generator.impactOccurred()

                    if self.viewModel?.isOutrightCompetitionLine() ?? false, let competition = self.viewModel?.outrightCompetition(forLine: 1) {
                        self.didSelectSeeAllCompetitionAction?(competition)
                    }
                    else if let firstMatch = self.viewModel?.match(forLine: 1) {
                        self.tappedMatchLineAction?(firstMatch)
                    }

                    return
                }
            }

            if scrollView.contentOffset.x > width {
                if !self.showingSecondBackSliderView {
                    self.showingSecondBackSliderView = true
                    UIView.animate(withDuration: 0.2) {
                        self.secondBackView.alpha = 1.0

                    }
                }
            }
            else {
                if self.showingSecondBackSliderView {
                    self.showingSecondBackSliderView = false
                    UIView.animate(withDuration: 0.2) {
                        self.secondBackView.alpha = 0.0
                    }
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
                    marketString = marketsRawString.replacingOccurrences(of: "{num_markets}", with: "\(numberTotalOfMarkets)")
                }
                else {
                    marketString = singularMarketRawString.replacingOccurrences(of: "{num_markets}", with: "\(numberTotalOfMarkets)")
                }
                cell.configureWithSubtitleString(marketString)

                if numberTotalOfMarkets == 0 {
                    cell.hideSubtitle()
                }

                if self.viewModel?.isOutrightCompetitionLine() ?? false {
                    if let competition = self.viewModel?.outrightCompetition(forLine: collectionLineIndex) {
                        cell.tappedAction = { [weak self] in
                            self?.didSelectSeeAllCompetitionAction?(competition)
                        }
                    }
                }
                else if let match = viewModel.match() {
                    cell.tappedAction = { [weak self] in
                        self?.tappedMatchLineAction?(match)
                    }
                }
            }
            return cell
        }
        else if self.viewModel?.isOutrightCompetitionLine() ?? false,
                let competition = self.viewModel?.outrightCompetition(forLine: collectionLineIndex),
                let cell = collectionView.dequeueCellType(OutrightCompetitionLargeWidgetCollectionViewCell.self, indexPath: indexPath) {

            let cellViewModel = OutrightCompetitionLargeWidgetViewModel(competition: competition)
            cell.configure(withViewModel: cellViewModel)
            cell.tappedLineAction = { [weak self] competition in
                self?.didSelectSeeAllCompetitionAction?(competition)
            }
            return cell
        }
        else if indexPath.row == 0, let match = self.viewModel?.match(forLine: collectionLineIndex) {

            guard
                let cell = collectionView.dequeueCellType(MatchWidgetCollectionViewCell.self, indexPath: indexPath)
            else {
                fatalError()
            }

            let cellViewModel = MatchWidgetCellViewModel(match: match)

            cell.configure(withViewModel: cellViewModel)
            cell.tappedMatchWidgetAction = { [weak self] tappedMatch in
                self?.tappedMatchLineAction?(tappedMatch)
            }
            cell.didLongPressOdd = { bettingTicket in
                self.didLongPressOdd?(bettingTicket)
            }

            cell.shouldShowCountryFlag(true)

            return cell
            
        }
        else {
            if let match = viewModel.match(forLine: collectionLineIndex), let market = match.markets[safe: indexPath.row] {

                let teamsText = "\(match.homeParticipant.name) - \(match.awayParticipant.name)"
                let countryIso = match.venue?.isoCode ?? ""
                
                let cellViewModel = MatchWidgetCellViewModel(match: match)
                
                if market.outcomes.count == 2 {
                    if let cell = collectionView.dequeueCellType(OddDoubleCollectionViewCell.self, indexPath: indexPath) {

                        if let matchStatsViewModel = self.matchStatsViewModelForMatch?(match) {
                            cell.matchStatsViewModel = matchStatsViewModel
                        }
                        cell.setupWithMarket(market, match: match,
                                             teamsText: teamsText,
                                             countryIso: countryIso,
                                             isLive: cellViewModel.matchWidgetStatus == .live)
                        
                        cell.tappedMatchWidgetAction = { [weak self]  in
                            self?.tappedMatchLineAction?(match)
                        }

                        cell.didLongPressOdd = { [weak self] bettingTicket in
                            self?.didLongPressOdd?(bettingTicket)
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
                                             isLive: cellViewModel.matchWidgetStatus == .live)
                        
                        cell.tappedMatchWidgetAction = { [weak self]  in
                            self?.tappedMatchLineAction?(match)
                        }

                        cell.didLongPressOdd = { [weak self] bettingTicket in
                            self?.didLongPressOdd?(bettingTicket)
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

        let cellHeight = StyleHelper.cardsStyleHeight()
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

    private static func createSeeAllLabel() -> UILabel {
        let seeAllLabel = UILabel()
        seeAllLabel.numberOfLines = 1
        seeAllLabel.text = localized("see_all")
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

        self.firstBackView.addSubview(self.firstBackImage)
        self.secondBackView.addSubview(self.secondBackImage)

        self.contentView.addSubview(self.firstBackView)
        self.contentView.addSubview(self.secondBackView)

        self.contentView.addSubview(self.linesStackView)
        self.contentView.addSubview(self.seeAllView)

        self.seeAllView.addSubview(self.seeAllLabel)

        self.topCollectionView.delegate = self
        self.topCollectionView.dataSource = self

        self.bottomCollectionView.delegate = self
        self.bottomCollectionView.dataSource = self

        self.topCollectionView.register(CompetitionWidgetCollectionViewCell.self, forCellWithReuseIdentifier: CompetitionWidgetCollectionViewCell.identifier)

        self.topCollectionView.register(OutrightCompetitionLargeWidgetCollectionViewCell.self,
                                        forCellWithReuseIdentifier: OutrightCompetitionLargeWidgetCollectionViewCell.identifier)
        self.topCollectionView.register(MatchWidgetCollectionViewCell.nib, forCellWithReuseIdentifier: MatchWidgetCollectionViewCell.identifier)
        self.topCollectionView.register(OddDoubleCollectionViewCell.nib, forCellWithReuseIdentifier: OddDoubleCollectionViewCell.identifier)
        self.topCollectionView.register(OddTripleCollectionViewCell.nib, forCellWithReuseIdentifier: OddTripleCollectionViewCell.identifier)
        self.topCollectionView.register(SeeMoreMarketsCollectionViewCell.self, forCellWithReuseIdentifier: SeeMoreMarketsCollectionViewCell.identifier)
        self.topCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.identifier)

        self.bottomCollectionView.register(OutrightCompetitionLargeWidgetCollectionViewCell.self,
                                           forCellWithReuseIdentifier: OutrightCompetitionLargeWidgetCollectionViewCell.identifier)
        self.bottomCollectionView.register(MatchWidgetCollectionViewCell.nib, forCellWithReuseIdentifier: MatchWidgetCollectionViewCell.identifier)
        self.bottomCollectionView.register(OddDoubleCollectionViewCell.nib, forCellWithReuseIdentifier: OddDoubleCollectionViewCell.identifier)
        self.bottomCollectionView.register(OddTripleCollectionViewCell.nib, forCellWithReuseIdentifier: OddTripleCollectionViewCell.identifier)
        self.bottomCollectionView.register(SeeMoreMarketsCollectionViewCell.self, forCellWithReuseIdentifier: SeeMoreMarketsCollectionViewCell.identifier)
        self.bottomCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.identifier)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {

        self.topCollectionViewHeightConstraint = self.topCollectionView.heightAnchor.constraint(equalToConstant: self.collectionViewHeight)
        self.bottomCollectionViewHeightConstraint = self.bottomCollectionView.heightAnchor.constraint(equalToConstant: self.collectionViewHeight)

        NSLayoutConstraint.activate([            
            self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 24),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            self.titleLabel.heightAnchor.constraint(equalToConstant: 19),

            self.linesStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.linesStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.linesStackView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 16),
            self.linesStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16),

            self.topCollectionViewHeightConstraint,
            self.bottomCollectionViewHeightConstraint,

            self.seeAllLabel.centerXAnchor.constraint(equalTo: self.seeAllView.centerXAnchor),
            self.seeAllLabel.centerYAnchor.constraint(equalTo: self.seeAllView.centerYAnchor),
            self.seeAllLabel.trailingAnchor.constraint(equalTo: self.seeAllView.trailingAnchor),

            self.seeAllView.heightAnchor.constraint(equalToConstant: 34),
            self.seeAllView.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
            self.seeAllView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -22),

            self.firstBackView.centerYAnchor.constraint(equalTo: self.topCollectionView.centerYAnchor),
            self.firstBackView.leadingAnchor.constraint(equalTo: self.topCollectionView.leadingAnchor, constant: -36),
            self.firstBackView.heightAnchor.constraint(equalToConstant: 38),
            self.firstBackView.widthAnchor.constraint(equalToConstant: 78),
            
            self.secondBackView.centerYAnchor.constraint(equalTo: self.bottomCollectionView.centerYAnchor),
            self.secondBackView.leadingAnchor.constraint(equalTo: self.bottomCollectionView.leadingAnchor, constant: -36),
            self.secondBackView.heightAnchor.constraint(equalToConstant: 38),
            self.secondBackView.widthAnchor.constraint(equalToConstant: 78),
            
            self.firstBackImage.centerYAnchor.constraint(equalTo: self.firstBackView.centerYAnchor),
            self.firstBackImage.trailingAnchor.constraint(equalTo: self.firstBackView.trailingAnchor, constant: -7),
            self.firstBackImage.heightAnchor.constraint(equalToConstant: 24),
            self.firstBackImage.widthAnchor.constraint(equalToConstant: 24),
            
            self.secondBackImage.centerYAnchor.constraint(equalTo: self.secondBackView.centerYAnchor),
            self.secondBackImage.trailingAnchor.constraint(equalTo: self.secondBackView.trailingAnchor, constant: -7),
            self.secondBackImage.heightAnchor.constraint(equalToConstant: 24),
            self.secondBackImage.widthAnchor.constraint(equalToConstant: 24),

     ])
    }
}
