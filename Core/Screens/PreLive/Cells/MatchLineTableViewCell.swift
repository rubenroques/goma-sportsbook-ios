//
//  MatchLineTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 30/09/2021.
//

import UIKit
import Combine
import ServicesProvider

class MatchLineTableViewCell: UITableViewCell {

    private var viewModel: MatchLineTableCellViewModel?

    var matchStatsViewModel: MatchStatsViewModel?

    @IBOutlet private var debugLabel: UILabel!
    @IBOutlet private var backSliderView: UIView!
    @IBOutlet private var backSliderIconImageView: UIImageView!
    
    @IBOutlet private var collectionBaseView: UIView!
    @IBOutlet private var collectionView: UICollectionView!

    @IBOutlet private var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var collectionViewTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet private var collectionViewBottomMarginConstraint: NSLayoutConstraint!

    @IBOutlet private var loadingView: UIActivityIndicatorView!

    private var cachedCardsStyle: CardsStyle?

    private var match: Match?

    private var shouldShowCountryFlag: Bool = true
    private var showingBackSliderView: Bool = false

    private var matchInfoPublisher: AnyCancellable?

    var tappedMatchLineAction: ((Match) -> Void)?
    var matchWentLive: (() -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var didLongPressOdd: ((BettingTicket) -> Void)?

    private let cellInternSpace: CGFloat = 2.0

    private var collectionViewHeight: CGFloat {
        let cardHeight = StyleHelper.cardsStyleHeight()
        return cardHeight + cellInternSpace + cellInternSpace
    }
    
    private var selectedSeeMoreMarketsCollectionViewCell: SeeMoreMarketsCollectionViewCell? {
        willSet {
            self.selectedSeeMoreMarketsCollectionViewCell?.transitionId = nil
        }
        didSet {
            self.selectedSeeMoreMarketsCollectionViewCell?.transitionId = "SeeMoreToMatchDetails"
        }
    }

    private var cancellables: Set<AnyCancellable> = []

    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectionStyle = .none

        self.loadingView.hidesWhenStopped = true
        self.loadingView.stopAnimating()

        self.cachedCardsStyle = StyleHelper.cardsStyleActive()
        
        self.debugLabel.isHidden = true

//        #if DEBUG
//        self.debugLabel.isHidden = false
//        #endif

        self.backSliderView.alpha = 0.0

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(MatchWidgetCollectionViewCell.nib, forCellWithReuseIdentifier: MatchWidgetCollectionViewCell.identifier)
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

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.selectionStyle = .none

        self.matchInfoPublisher?.cancel()
        self.matchInfoPublisher = nil
        
        self.viewModel = nil
        self.match = nil

        self.cancellables.removeAll()
        
        self.matchStatsViewModel = nil

        self.loadingView.hidesWhenStopped = true
        self.loadingView.stopAnimating()

        self.shouldShowCountryFlag = true

        self.backSliderView.alpha = 0.0

        self.collectionView.layoutSubviews()
        self.collectionView.setContentOffset(CGPoint(x: -self.collectionView.contentInset.left, y: 1), animated: false)

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

    func configure(withViewModel viewModel: MatchLineTableCellViewModel) {
        self.viewModel = viewModel
        
        self.loadingView.startAnimating()
//  
//        if let match = viewModel.match {
//            self.loadingView.stopAnimating()
//            self.setupWithMatch(match)
//        }
        
        self.matchInfoPublisher?.cancel()
        
        self.matchInfoPublisher = viewModel.$match
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: ()
                case .failure: ()
                }
            } receiveValue: { match in
                if let match = match {
                    self.setupWithMatch(match)
                    self.loadingView.stopAnimating()
                }
                else {
                    self.loadingView.stopAnimating()
                }
            }

    }

    func setupWithTheme() {

        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear

        self.collectionBaseView.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear
        self.collectionView.backgroundView?.backgroundColor = UIColor.App.backgroundCards

        self.backSliderView.backgroundColor = UIColor.App.backgroundOdds
        self.backSliderIconImageView.setTintColor(color: UIColor.App.iconPrimary)
    }

    private func setupWithMatch(_ newMatch: Match) {
        
        guard
            let currentMatch = self.match
        else {
            // If no self.match was found it should refresh all sections
            self.match = newMatch
            self.collectionView.reloadData()
            return
        }

        /*
         
         
        var oldMarketsList = currentMatch.markets
        var newMarketsList = newMatch.markets
        
        var updated: [IndexPath] = []
        var deletions: [IndexPath] = []
        var insertions: [IndexPath] = []
        
        // if default market is different
        if let firstOldMarket = currentMatch.markets.first {
            // Existe um current first market
            if let firstNewMarket = newMatch.markets.first {
                // Existe um new first market
                if firstOldMarket != firstNewMarket {
                    updated.append(IndexPath(item: 0, section: 0))
                }
            }
            else {
                // Não existe um new first market
                deletions.append(IndexPath(item: 0, section: 0))
            }
        }
        else {
            // Não existe um current first market
            if newMatch.markets.first != nil {
                // Existe um new first market
                insertions.append(IndexPath(item: 0, section: 0))
            }
            else {
                // Não existe um new first market
            }
        }
        
        // First market index (section 0) is already processed
        if oldMarketsList.count >= 1 {
            oldMarketsList.removeFirst()
        }
        if newMarketsList.count >= 1 {
            newMarketsList.removeFirst()
        }
        
        let diff = newMarketsList.difference(from: oldMarketsList)

        insertions.append(contentsOf: diff.insertions.compactMap { change in
            switch change {
            case .insert(let offset, _, _):
                return IndexPath(row: offset, section: 1)
            default:
                return nil
            }
        })

        deletions.append(contentsOf: diff.removals.compactMap { change in
            switch change {
            case .remove(let offset, _, _):
                return IndexPath(row: offset, section: 1)
            default:
                return nil
            }
        })
            
        // see all section - 2
        // updated.append(IndexPath(item: 0, section: 2))
        
        self.match = newMatch

        self.collectionView.performBatchUpdates({
            self.collectionView.insertItems(at: insertions)
            self.collectionView.deleteItems(at: deletions)
            self.collectionView.reloadItems(at: updated)
        }, completion: nil)
        */
        
        if currentMatch.id == newMatch.id && currentMatch.markets.first == newMatch.markets.first {
            self.collectionView.reloadSections(IndexSet(integer: 1))
        }
        else {
            // Legacy refresh
            self.match = newMatch
            self.collectionView.reloadData()
        }
        
        // Legacy refresh
//        self.match = newMatch
//        self.collectionView.reloadData()
    }

    func shouldShowCountryFlag(_ show: Bool) {
        self.shouldShowCountryFlag = show
    }

    @objc func didTapBackSliderButton() {
        self.collectionView.setContentOffset(CGPoint(x: -self.collectionView.contentInset.left, y: 1), animated: true)
    }

    func tappedMatchLine() {
        if let match = self.viewModel?.match {
            self.tappedMatchLineAction?(match)
        }
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

                if let match = self.match {
                    self.tappedMatchLineAction?(match)
                }

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
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        guard let match = self.match else { return 0 }

        if section == 0 { // Match section
            return 1
        }

        if section == 2 { // See all section
            return 1
        }

        // Section 1
        if match.markets.isNotEmpty {
            // all the markets except thee first one
            // the first market appears in the match cell
            return match.markets.count - 1
        }

        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let knownStatus = self.viewModel?.status ?? .unknown
        
        guard
            let match = self.viewModel?.match
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
            cell.backgroundView?.backgroundColor = UIColor.App.backgroundCards
            cell.backgroundColor = UIColor.App.backgroundCards
            cell.layer.cornerRadius = 9
            return cell
        }

        switch indexPath.section {
        case 0:
            guard
                let cell = collectionView.dequeueCellType(MatchWidgetCollectionViewCell.self, indexPath: indexPath)
            else {
                fatalError()
            }
            
            if let cellViewModel = self.viewModel?.matchWidgetCellViewModel {
                cell.configure(withViewModel: cellViewModel)
            }
            else {
                let cellViewModel = MatchWidgetCellViewModel(match: match, matchWidgetStatus: knownStatus)
                cell.configure(withViewModel: cellViewModel)
            }

            cell.tappedMatchWidgetAction = { [weak self] _ in
                self?.tappedMatchLine()
            }

            cell.didLongPressOdd = { [weak self] bettingTicket in
                self?.didLongPressOdd?(bettingTicket)
            }
            cell.shouldShowCountryFlag(self.shouldShowCountryFlag)

            return cell
            
        case 1:
            if match.markets.count > 1, let market = match.markets[safe: indexPath.row + 1] {

                let cellViewModel = self.viewModel?.matchWidgetCellViewModel ?? MatchWidgetCellViewModel(match: match, matchWidgetStatus: knownStatus)
                
                let teamsText = "\(match.homeParticipant.name) - \(match.awayParticipant.name)"
                let countryIso = match.venue?.isoCode ?? ""

                if market.outcomes.count == 2 {
                    if let cell = collectionView.dequeueCellType(OddDoubleCollectionViewCell.self, indexPath: indexPath) {
                        cell.matchStatsViewModel = self.matchStatsViewModel
                        cell.setupWithMarket(market, 
                                             match: match,
                                             teamsText: teamsText,
                                             countryIso: countryIso,
                                             isLive: cellViewModel.matchWidgetStatus == .live )
                        
                        cell.tappedMatchWidgetAction = { [weak self] in
                            self?.tappedMatchLine()
                        }

                        cell.didLongPressOdd = { [weak self] bettingTicket in
                            self?.didLongPressOdd?(bettingTicket)
                        }

                        return cell
                    }
                }
                else {
                    if let cell = collectionView.dequeueCellType(OddTripleCollectionViewCell.self, indexPath: indexPath) {
                        cell.matchStatsViewModel = self.matchStatsViewModel
                        cell.setupWithMarket(market,
                                             match: match,
                                             teamsText: teamsText,
                                             countryIso: countryIso,
                                             isLive: cellViewModel.matchWidgetStatus == .live)
                        
                        cell.tappedMatchWidgetAction = {  [weak self] in
                            self?.tappedMatchLine()
                        }

                        cell.didLongPressOdd = { [weak self] bettingTicket in
                            self?.didLongPressOdd?(bettingTicket)
                        }

                        return cell
                    }
                }
            }
        case 2:
            guard
                let cell = collectionView.dequeueCellType(SeeMoreMarketsCollectionViewCell.self, indexPath: indexPath)
            else {
                fatalError()
            }

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

            cell.tappedAction = { [weak self] in
                self?.tappedMatchLine()
            }
            return cell

        default:
            ()
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        cell.backgroundView?.backgroundColor = UIColor.App.backgroundCards
        cell.backgroundColor = UIColor.App.backgroundCards
        cell.layer.cornerRadius = 9
        return cell

    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        if section == 1, (self.match?.markets.count ?? 0) <= 1 {
            return 0
        }
        else {
            return 16
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        if section == 1, (self.match?.markets.count ?? 0) <= 1 {
            return 0
        }
        else {
            return 16
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {

        if section == 1, (self.match?.markets.count ?? 0) <= 1 {
            // We just need insets if we have content
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        else {
            return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        }

    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let height = StyleHelper.cardsStyleHeight()

        if indexPath.section == 2 { // see all section
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
