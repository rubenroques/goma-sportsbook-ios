//
//  MatchLineTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 30/09/2021.
//

import UIKit
import Combine

class MatchLineTableViewCell: UITableViewCell {

    @IBOutlet private var debugLabel: UILabel!
    @IBOutlet private var backSliderView: UIView!

    @IBOutlet private var collectionBaseView: UIView!
    @IBOutlet private var collectionView: UICollectionView!

    @IBOutlet private var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var collectionViewTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet private var collectionViewBottomMarginConstraint: NSLayoutConstraint!

    private var cachedCardsStyle: CardsStyle?

    private var match: Match?
    private var store: AggregatorStore?

    private var shouldShowCountryFlag: Bool = true
    private var showingBackSliderView: Bool = false

    private var liveMatch: Bool = false

    private var matchInfoPublisher: AnyCancellable?

    var matchStatsViewModel: MatchStatsViewModel?

    var tappedMatchLineAction: (() -> Void)?
    var matchWentLive: (() -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var didLongPressOdd: ((BettingTicket) -> Void)?

    private let cellInternSpace: CGFloat = 2.0

    private var collectionViewHeight: CGFloat {
        let cardHeight = StyleHelper.cardsStyleHeight()
        return cardHeight + cellInternSpace + cellInternSpace
    }
    
    private var selectedSeeMoreMarketsCollectionViewCell: SeeMoreMarketsCollectionViewCell? = nil {
        willSet {
            self.selectedSeeMoreMarketsCollectionViewCell?.transitionId = nil
        }
        didSet {
            self.selectedSeeMoreMarketsCollectionViewCell?.transitionId = "SeeMoreToMatchDetails"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectionStyle = .none

        self.cachedCardsStyle = StyleHelper.cardsStyleActive()
        
        self.debugLabel.isHidden = true

//        #if DEBUG
//        self.debugLabel.isHidden = false
//        #endif

        self.backSliderView.alpha = 0.0

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(MatchWidgetCollectionViewCell.nib, forCellWithReuseIdentifier: MatchWidgetCollectionViewCell.identifier)
        self.collectionView.register(LiveMatchWidgetCollectionViewCell.nib, forCellWithReuseIdentifier: LiveMatchWidgetCollectionViewCell.identifier)
        self.collectionView.register(OddDoubleCollectionViewCell.nib, forCellWithReuseIdentifier: OddDoubleCollectionViewCell.identifier)
        self.collectionView.register(OddTripleCollectionViewCell.nib, forCellWithReuseIdentifier: OddTripleCollectionViewCell.identifier)
        self.collectionView.register(SeeMoreMarketsCollectionViewCell.nib, forCellWithReuseIdentifier: SeeMoreMarketsCollectionViewCell.identifier)

        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")

        self.collectionView.clipsToBounds = false
        
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = flowLayout

        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

        self.backSliderView.layer.cornerRadius = 6

        let backSliderTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackSliderButton))
        self.backSliderView.addGestureRecognizer(backSliderTapGesture)

        //
        self.collectionViewHeightConstraint.constant = self.collectionViewHeight
        self.collectionViewTopMarginConstraint.constant = StyleHelper.cardsStyleMargin()
        self.collectionViewBottomMarginConstraint.constant = StyleHelper.cardsStyleMargin()

        UIView.performWithoutAnimation {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.selectionStyle = .none

        self.shouldShowCountryFlag = true
        self.liveMatch = false

        self.backSliderView.alpha = 0.0

        self.collectionView.layoutSubviews()
        self.collectionView.setContentOffset(CGPoint(x: -self.collectionView.contentInset.left, y: 1), animated: false)

        self.store = nil
        self.match = nil

        self.matchStatsViewModel = nil

        self.matchInfoPublisher?.cancel()
        self.matchInfoPublisher = nil

        if self.cachedCardsStyle != StyleHelper.cardsStyleActive() {

            self.cachedCardsStyle = StyleHelper.cardsStyleActive()

            self.collectionViewHeightConstraint.constant = self.collectionViewHeight
            self.collectionViewTopMarginConstraint.constant = StyleHelper.cardsStyleMargin()
            self.collectionViewBottomMarginConstraint.constant = StyleHelper.cardsStyleMargin()

            UIView.performWithoutAnimation {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }

        self.collectionView.reloadData()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {

        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear

        self.collectionBaseView.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear
        self.collectionView.backgroundView?.backgroundColor = UIColor.App.backgroundCards

        self.backSliderView.backgroundColor = UIColor.App.buttonBackgroundSecondary
    }

    func setupWithMatch(_ match: Match, liveMatch: Bool = false, store: AggregatorStore) {
        
        self.match = match
        self.liveMatch = liveMatch

        self.store = store

        UIView.performWithoutAnimation {
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }

    func setupFavoriteMatchInfoPublisher(match: Match) {
        if let store = self.store, !store.hasMatchesInfoForMatch(withId: match.id) {
            self.matchInfoPublisher = store.matchesInfoForMatchListPublisher()?
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] value in
                    if value.contains(match.id) {
                        self?.matchInfoPublisher?.cancel()
                        self?.matchInfoPublisher = nil
                        self?.matchWentLive?()
                    }
                })
        }

    }

    func shouldShowCountryFlag(_ show: Bool) {
        self.shouldShowCountryFlag = show
    }

    @objc func didTapBackSliderButton() {
        self.collectionView.setContentOffset(CGPoint(x: -self.collectionView.contentInset.left, y: 1), animated: true)
    }

}

extension MatchLineTableViewCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let screenWidth = UIScreen.main.bounds.size.width
        let width = screenWidth*0.6

        let pushScreenMargin = 100.0
        let bounceXPosition = ( (scrollView.contentOffset.x - scrollView.contentInset.left) + scrollView.frame.width) - scrollView.contentSize.width
        
        var activeSeeMoreCell: SeeMoreMarketsCollectionViewCell?
        
        if bounceXPosition >= 0 {
            for cell in self.collectionView.visibleCells {
                if let seeMoreCell = cell as? SeeMoreMarketsCollectionViewCell {
                    seeMoreCell.setAnimationPercentage(bounceXPosition / Double(pushScreenMargin * 0.98))
                    
                    activeSeeMoreCell = seeMoreCell
                }
            }
        }
        
        if scrollView.isTracking && scrollView.contentSize.width > screenWidth {
            if scrollView.contentOffset.x + scrollView.frame.width > scrollView.contentSize.width + pushScreenMargin {

                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.prepare()
                generator.impactOccurred()

                self.selectedSeeMoreMarketsCollectionViewCell = activeSeeMoreCell
                
                self.tappedMatchLineAction?()

                return
            }
        }

        if scrollView.contentOffset.x > width {
            if !self.showingBackSliderView {
                self.showingBackSliderView = true
                UIView.animate(withDuration: 0.2) {
                    self.backSliderView.alpha = 1.0
                }
            }
        }
        else {
            if self.showingBackSliderView {
                self.showingBackSliderView = false
                UIView.animate(withDuration: 0.2) {
                    self.backSliderView.alpha = 0.0
                }
            }
        }
    }
}

extension MatchLineTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        guard let match = self.match else { return 0 }

        if section == 1 {
            return 1
        }

        if match.markets.isNotEmpty {
            return match.markets.count
        }

        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.section == 1 {
            guard
                let cell = collectionView.dequeueCellType(SeeMoreMarketsCollectionViewCell.self, indexPath: indexPath)
            else {
                fatalError()
            }
            if let match = self.match {
                let marketsRawString = localized("number_of_markets")
                let singularMarketRawString = localized("number_of_market_singular")
                var marketString = ""
                if match.numberTotalOfMarkets > 1 {
                    marketString = marketsRawString.replacingOccurrences(of: "{num_markets}", with: "\(match.numberTotalOfMarkets)")
                }
                else {
                    marketString = singularMarketRawString.replacingOccurrences(of: "{num_markets}", with: "\(match.numberTotalOfMarkets)")
                }

                cell.configureWithSubtitleString(marketString)

                if match.numberTotalOfMarkets == 0 {
                    cell.hideSubtitle()
                }
            }
            cell.tappedAction = {
                self.tappedMatchLineAction?()
            }
            return cell
        }

        if indexPath.row == 0 {

            var store: AggregatorStore = Env.everyMatrixStorage
            if let storeValue = self.store {
                store = storeValue
            }

            if let match = self.match, store.hasMatchesInfoForMatch(withId: match.id) {
                self.liveMatch = true
            }
            else {
                self.liveMatch = false
            }

            if !self.liveMatch {
                guard
                    let cell = collectionView.dequeueCellType(MatchWidgetCollectionViewCell.self, indexPath: indexPath)

                else {
                    fatalError()
                }
                if let match = self.match {

                    let cellViewModel = MatchWidgetCellViewModel(match: match, store: store)
                    cell.configure(withViewModel: cellViewModel)

                    cell.tappedMatchWidgetAction = {
                        self.tappedMatchLineAction?()
                    }

                    cell.didLongPressOdd = { bettingTicket in
                        self.didLongPressOdd?(bettingTicket)
                    }
                }
                cell.shouldShowCountryFlag(self.shouldShowCountryFlag)

                return cell
            }
            else {
                guard
                    let cell = collectionView.dequeueCellType(LiveMatchWidgetCollectionViewCell.self, indexPath: indexPath)
                else {
                    fatalError()
                }

                if let match = self.match {
                    let cellViewModel = MatchWidgetCellViewModel(match: match, store: store)

                    cell.configure(withViewModel: cellViewModel)

                    cell.tappedMatchWidgetAction = {
                        self.tappedMatchLineAction?()
                    }

                    cell.didLongPressOdd = { bettingTicket in
                        self.didLongPressOdd?(bettingTicket)
                    }
                }
                cell.shouldShowCountryFlag(self.shouldShowCountryFlag)
                return cell
            }
        }
        else {
            if let match = self.match, let market = match.markets[safe: indexPath.row] {

                let teamsText = "\(match.homeParticipant.name) - \(match.awayParticipant.name)"
                let countryIso = match.venue?.isoCode ?? ""

                if market.outcomes.count == 2 {
                    if let cell = collectionView.dequeueCellType(OddDoubleCollectionViewCell.self, indexPath: indexPath) {
                        cell.matchStatsViewModel = self.matchStatsViewModel
                        if let store = self.store {
                            cell.setupWithMarket(market, match: match, teamsText: teamsText, countryIso: countryIso, store: store)
                        }
                        cell.tappedMatchWidgetAction = {
                            self.tappedMatchLineAction?()
                        }

                        cell.didLongPressOdd = { bettingTicket in
                            self.didLongPressOdd?(bettingTicket)
                        }

                        return cell
                    }
                }
                else {
                    if let cell = collectionView.dequeueCellType(OddTripleCollectionViewCell.self, indexPath: indexPath) {
                        cell.matchStatsViewModel = self.matchStatsViewModel
                        if let store = self.store {
                            cell.setupWithMarket(market, match: match, teamsText: teamsText, countryIso: countryIso, store: store)
                        }
                        cell.tappedMatchWidgetAction = {
                            self.tappedMatchLineAction?()
                        }

                        cell.didLongPressOdd = { bettingTicket in
                            self.didLongPressOdd?(bettingTicket)
                        }
                        
                        return cell
                    }
                }
            }
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
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

        let height = StyleHelper.cardsStyleHeight()

        if indexPath.section == 1 {
            return CGSize(width: 99, height: height)
        }
        else {
            let screenWidth = UIScreen.main.bounds.size.width
            var width = screenWidth*0.87

            if width > 390 {
                width = 390
            }
            
            return CGSize(width: width, height: height) // design width: 331
        }
    }
}
