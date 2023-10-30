//
//  MatchLineTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 30/09/2021.
//

import UIKit
import Combine
import ServicesProvider

class MatchLineTableCellViewModel {

    var match: Match? {
        return self.matchCurrentValueSubject.value
    }
    var matchPublisher: AnyPublisher<Match?, Never> {
        return self.matchCurrentValueSubject.eraseToAnyPublisher()
    }

    private let matchCurrentValueSubject = CurrentValueSubject<Match?, Never>.init(nil)

    private var subscription: ServicesProvider.Subscription?
    private var cancellables: Set<AnyCancellable> = []

    //
    init(matchId: String) {
        self.loadEventDetails(fromId: matchId)
    }

    init(match: Match, withFullMarkets fullMarkets: Bool = false) {
        if !fullMarkets {
            self.loadEventDetails(fromId: match.id)
            self.matchCurrentValueSubject.send(match)
        }
        else {
            self.matchCurrentValueSubject.send(match)
        }

    }

    deinit {
        print("MatchLineTableCellViewModel.deinit")
    }

    //
    //
    private func loadEventDetails(fromId id: String) {

        Env.servicesProvider.getEventDetails(eventId: id)
            .filter { eventSummary in
                return eventSummary.type == .match
            }
            .map(ServiceProviderModelMapper.match(fromEvent:))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    break
                }
            } receiveValue: { [weak self] updatedMatch in

                var knownMarketGroups: Set<String> = []
                var filteredMarkets = [Market]()

                for market in updatedMatch.markets.filter({ $0.outcomes.count == 3 || $0.outcomes.count == 2 }) {
                    if let marketTypeId = market.marketTypeId, !knownMarketGroups.contains(marketTypeId) {
                        knownMarketGroups.insert(marketTypeId)
                        filteredMarkets.append(market)
                    }

                    if knownMarketGroups.count >= 5 {
                        break
                    }
                }
                var sortedMarkets = filteredMarkets.sorted { leftMarket, rightMarket  in
                    return (leftMarket.marketTypeId ?? "") < (rightMarket.marketTypeId ?? "")
                }.prefix(5)
                
                if var oldMatch = self?.matchCurrentValueSubject.value {
                    // We already have a match we only update/replace the markets
                    
                    if let firstMarket = oldMatch.markets.first { // Kepp the first market if it exists
                        sortedMarkets.removeAll { $0.id == firstMarket.id }
                        var concatenatedMarkets = [firstMarket]
                        concatenatedMarkets.append(contentsOf: sortedMarkets)
                        
                        oldMatch.markets = concatenatedMarkets
                        self?.matchCurrentValueSubject.send(oldMatch)
                    } else {
                        oldMatch.markets = Array(sortedMarkets)
                        self?.matchCurrentValueSubject.send(oldMatch)
                    }
                    
                }
                else {
                    // We don't have a match yet, we need to use this one
                    var newUpdatedMatch = updatedMatch
                    newUpdatedMatch.markets = Array(sortedMarkets)
                    self?.matchCurrentValueSubject.send(newUpdatedMatch)
                }

            }
            .store(in: &self.cancellables)

    }

}

class MatchLineTableViewCell: UITableViewCell {

    var viewModel: MatchLineTableCellViewModel? {
        didSet {
            if let viewModel = self.viewModel {
                self.configureWithViewModel(viewModel)
            }
        }
    }

    var matchStatsViewModel: MatchStatsViewModel?

    @IBOutlet private var debugLabel: UILabel!
    @IBOutlet private var backSliderView: UIView!

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

    private var liveMatch: Bool = false

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

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.selectionStyle = .none

        self.viewModel = nil

        self.loadingView.hidesWhenStopped = true
        self.loadingView.stopAnimating()

        self.shouldShowCountryFlag = true
        self.liveMatch = false

        self.backSliderView.alpha = 0.0

        self.collectionView.layoutSubviews()
        self.collectionView.setContentOffset(CGPoint(x: -self.collectionView.contentInset.left, y: 1), animated: false)

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

    private func configureWithViewModel(_ viewModel: MatchLineTableCellViewModel) {

        if let match = viewModel.match {
            self.setupWithMatch(match)
        }

        viewModel.matchPublisher
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
            .store(in: &self.cancellables)

    }

    func setupWithTheme() {

        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear

        self.collectionBaseView.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear
        self.collectionView.backgroundView?.backgroundColor = UIColor.App.backgroundCards

        self.backSliderView.backgroundColor = UIColor.App.buttonBackgroundSecondary
    }

    private func setupWithMatch(_ match: Match, liveMatch: Bool = false) {
        
        self.match = match
        self.liveMatch = liveMatch

        self.collectionView.reloadData()
        
//        UIView.performWithoutAnimation {
//            if self.collectionView.numberOfSections == 3 {
//                 self.collectionView.reloadSections(IndexSet(integer: 1))
//             }
//        }
    }

    func shouldShowCountryFlag(_ show: Bool) {
        self.shouldShowCountryFlag = show
    }

    @objc func didTapBackSliderButton() {
        self.collectionView.setContentOffset(CGPoint(x: -self.collectionView.contentInset.left, y: 1), animated: true)
    }

    func tappedMatchLine() {
        if let match = self.match {
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

        guard
            let match = self.match
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

            if match.id == "3234891.1" {
                print("TapBug stop 2 \(match.markets.map({ return "\($0.name) "}) ) ")
            }
            
            let cellViewModel = MatchWidgetCellViewModel(match: match)
            cell.configure(withViewModel: cellViewModel)

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

                let teamsText = "\(match.homeParticipant.name) - \(match.awayParticipant.name)"
                let countryIso = match.venue?.isoCode ?? ""

                if market.outcomes.count == 2 {
                    if let cell = collectionView.dequeueCellType(OddDoubleCollectionViewCell.self, indexPath: indexPath) {
                        cell.matchStatsViewModel = self.matchStatsViewModel
                        cell.setupWithMarket(market, match: match, teamsText: teamsText, countryIso: countryIso)
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
                        cell.setupWithMarket(market, match: match, teamsText: teamsText, countryIso: countryIso)
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
