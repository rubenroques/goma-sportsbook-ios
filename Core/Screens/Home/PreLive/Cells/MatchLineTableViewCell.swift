//
//  MatchLineTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 30/09/2021.
//

import UIKit
import Combine

class MatchLineTableViewCell: UITableViewCell {

    let cellWidth: CGFloat = 331

    @IBOutlet private var debugLabel: UILabel!
    @IBOutlet private var backSliderView: UIView!

    @IBOutlet private var collectionBaseView: UIView!
    @IBOutlet private var collectionView: UICollectionView!

    private var match: Match?

    private var shouldShowCountryFlag: Bool = true
    private var showingBackSliderView: Bool = false

    private var liveMatch: Bool = false

    private var matchInfoPublisher: AnyCancellable?

    var matchStatsViewModel: MatchStatsViewModel?

    var tappedMatchLineAction: (() -> Void)?
    var matchWentLive: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectionStyle = .none

        self.debugLabel.isHidden = true

        #if DEBUG
        self.debugLabel.isHidden = false
        #endif

        self.backSliderView.alpha = 0.0

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(MatchWidgetCollectionViewCell.nib, forCellWithReuseIdentifier: MatchWidgetCollectionViewCell.identifier)
        self.collectionView.register(LiveMatchWidgetCollectionViewCell.nib, forCellWithReuseIdentifier: LiveMatchWidgetCollectionViewCell.identifier)
        self.collectionView.register(OddDoubleCollectionViewCell.nib, forCellWithReuseIdentifier: OddDoubleCollectionViewCell.identifier)
        self.collectionView.register(OddTripleCollectionViewCell.nib, forCellWithReuseIdentifier: OddTripleCollectionViewCell.identifier)
        self.collectionView.register(SeeMoreMarketsCollectionViewCell.nib, forCellWithReuseIdentifier: SeeMoreMarketsCollectionViewCell.identifier)

        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")

        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        
        // let flowLayout = FadeInCenterHorizontalFlowLayout()
        // flowLayout.alpha = 0.38
        // flowLayout.minimumScale = 0.7
        // flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = flowLayout

        // let screenWidth = UIScreen.main.bounds.size.width
        // let inset = (screenWidth - cellWidth) / 2
        // self.collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)

        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

        self.backSliderView.layer.cornerRadius = 6

        let backSliderTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackSliderButton))
        self.backSliderView.addGestureRecognizer(backSliderTapGesture)

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

        self.match = nil
        self.matchStatsViewModel = nil
        self.matchInfoPublisher?.cancel()
        self.matchInfoPublisher = nil

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

    func setupWithMatch(_ match: Match, liveMatch: Bool = false) {
        self.match = match
        self.liveMatch = liveMatch

        UIView.performWithoutAnimation {
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }

        self.debugLabel.text = "\(self.match?.markets.count ?? -1); \(self.debugLabel.text ?? "")"
    }

    func setupFavoriteMatchInfoPublisher(match: Match) {
        if !Env.everyMatrixStorage.matchesInfoForMatchPublisher.value.contains(match.id) {
            self.matchInfoPublisher = Env.everyMatrixStorage.matchesInfoForMatchPublisher
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

        if scrollView.isTracking && scrollView.contentSize.width > screenWidth {
            if scrollView.contentOffset.x + scrollView.frame.width > scrollView.contentSize.width + 100 {

                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.prepare()
                generator.impactOccurred()

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
                    marketString = marketsRawString.replacingOccurrences(of: "%s", with: "\(match.numberTotalOfMarkets)")
                }
                else {
                    marketString = singularMarketRawString.replacingOccurrences(of: "%s", with: "\(match.numberTotalOfMarkets)")
                }

                cell.configureWithSubtitleString(marketString)
            }
            cell.tappedAction = {
                self.tappedMatchLineAction?()
            }
            return cell
        }

        if indexPath.row == 0 {
            if !liveMatch {
                guard
                    let cell = collectionView.dequeueCellType(MatchWidgetCollectionViewCell.self, indexPath: indexPath)

                else {
                    fatalError()
                }
                if let match = self.match {
                    cell.setupWithMatch(match)
                    cell.tappedMatchWidgetAction = {
                        self.tappedMatchLineAction?()
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
                    cell.setupWithMatch(match)
                    cell.tappedMatchWidgetAction = {
                        self.tappedMatchLineAction?()
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
                        cell.setupWithMarket(market, match: match, teamsText: teamsText, countryIso: countryIso)
                        cell.tappedMatchWidgetAction = {
                            self.tappedMatchLineAction?()
                        }
                        return cell
                    }
                }
                else {
                    if let cell = collectionView.dequeueCellType(OddTripleCollectionViewCell.self, indexPath: indexPath) {
                        cell.matchStatsViewModel = self.matchStatsViewModel
                        cell.setupWithMarket(market, match: match, teamsText: teamsText, countryIso: countryIso)
                        cell.tappedMatchWidgetAction = {
                            self.tappedMatchLineAction?()
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
