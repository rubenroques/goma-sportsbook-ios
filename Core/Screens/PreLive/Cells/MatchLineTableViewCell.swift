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
    
    var status: MatchWidgetStatus = .unknown

    private let matchCurrentValueSubject = CurrentValueSubject<Match?, Never>.init(nil)

    private var secundaryMarketsSubscription: ServicesProvider.Subscription?
    private var secundaryMarketsPublisher: AnyCancellable?

    private var cancellables: Set<AnyCancellable> = []

    //
    init(matchId: String, status: MatchWidgetStatus) {
        self.status = status
        self.loadEventDetails(fromId: matchId)
    }

    init(match: Match, withFullMarkets fullMarkets: Bool = false) {
        if !fullMarkets {
            self.matchCurrentValueSubject.send(match)
            self.loadEventDetails(fromId: match.id)
        }
        else {
            self.matchCurrentValueSubject.send(match)
        }

    }

    deinit {
        print("MatchLineTableCellViewModel.deinit")
    }

    private func loadLiveEventDetails(matchId: String) {
        
        self.secundaryMarketsPublisher?.cancel()
        self.secundaryMarketsPublisher = nil
        
        self.secundaryMarketsPublisher = Publishers.CombineLatest(
            Env.servicesProvider.subscribeEventSecundaryMarkets(eventId: matchId),
            SecundaryMarketsService.fetchSecundaryMarkets()
                .mapError { error in ServiceProviderError.errorMessage(message: error.localizedDescription) }
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            print("subscribeEventSecundaryMarkets completion \(completion)")
        } receiveValue: { [weak self] subscribableContentMatch, secundaryMarkets in
            switch subscribableContentMatch {
            case .connected(subscription: let subscription):
                self?.secundaryMarketsSubscription = subscription
            case .contentUpdate(content: let updatedEvent):
                print("subscribeEventSecundaryMarkets match with sec markets: \(updatedEvent)")
                let mappedMatch = ServiceProviderModelMapper.match(fromEvent: updatedEvent)
                
                var statsForMarket: [String: String?] = [:]
                
                if var oldMatch = self?.matchCurrentValueSubject.value {
                    let firstMarket = oldMatch.markets.first // Capture the first market
                    
                    var newMarkets: [Market] = []
                    var mergedMarkets: [Market] = []
                    
                    for market in  mappedMatch.markets {
                        if market.id != firstMarket?.id {
                            newMarkets.append(market)
                        }
                    }
                    
                    if let first = firstMarket {
                        mergedMarkets = [first] + newMarkets
                    }
                    else {
                        mergedMarkets = newMarkets
                    }
                    
                    if let secundaryMarketsForSport = secundaryMarkets.first(where: { secundarySportMarket in
                        if secundarySportMarket.sportId == (mappedMatch.sport.alphaId ?? "") {
                            return true
                        }
                        if secundarySportMarket.sportId == (mappedMatch.sportIdCode ?? "") {
                            return true
                        }
                        return false
                    }) {
                        
                        for secundaryMarket in secundaryMarketsForSport.markets {
                            if var foundMarket = mergedMarkets.first(where: { market in
                                (market.marketTypeId ?? "") == secundaryMarket.typeId
                            }) {
                                foundMarket.statsTypeId = secundaryMarket.statsId
                                statsForMarket[foundMarket.id] = secundaryMarket.statsId
                                
                                print("foundMarket updated \(foundMarket)")
                            }
                            
                        }
                        
                    }
                    
                    var finalMarkets: [Market] = []
                    
                    for market in mergedMarkets {
                        if let statsTypeId = statsForMarket[market.id] {
                            var newMarket = market
                            newMarket.statsTypeId = statsTypeId
                            finalMarkets.append(newMarket)
                        }
                        else {
                            var newMarket = market
                            finalMarkets.append(newMarket)
                        }
                    }
                    
                    oldMatch.markets = finalMarkets
                    self?.matchCurrentValueSubject.send(oldMatch)
                } else {
                    self?.matchCurrentValueSubject.send(mappedMatch)
                }
                
            case .disconnected:
                break
            }
        }
    }
    
    private func loadPreLiveEventDetails(matchId: String) {
        self.secundaryMarketsPublisher = nil
        self.secundaryMarketsSubscription = nil
        
        Publishers.CombineLatest(
            Env.servicesProvider.getEventSecundaryMarkets(eventId: matchId),
            SecundaryMarketsService.fetchSecundaryMarkets()
                .mapError { error in ServiceProviderError.errorMessage(message: error.localizedDescription) }
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            print("getEventSecundaryMarkets completion \(completion)")
        } receiveValue: { [weak self] eventWithSecundaryMarkets, secundaryMarkets in
            var mappedMatch = ServiceProviderModelMapper.match(fromEvent: eventWithSecundaryMarkets)
            
            if var oldMatch = self?.matchCurrentValueSubject.value {
                
                var mergedMarkets: [Market] = mappedMatch.markets
                
                var statsForMarket: [String: String?] = [:]
                
                if let secundaryMarketsForSport = secundaryMarkets.first(where: { secundarySportMarket in
                    if secundarySportMarket.sportId == (mappedMatch.sport.alphaId ?? "") {
                        return true
                    }
                    if secundarySportMarket.sportId == (mappedMatch.sportIdCode ?? "") {
                        return true
                    }
                    return false
                }) {
                    
                    for secundaryMarket in secundaryMarketsForSport.markets {
                        if var foundMarket = mergedMarkets.first(where: { market in
                            (market.marketTypeId ?? "") == secundaryMarket.typeId
                        }) {
                            statsForMarket[foundMarket.id] = secundaryMarket.statsId
                            foundMarket.statsTypeId = secundaryMarket.statsId
                            print("foundMarket updated \(foundMarket)")
                        }
                    }
                }
                
                var finalMarkets: [Market] = []
                
                for market in mergedMarkets {
                    if let statsTypeId = statsForMarket[market.id] {
                        var newMarket = market
                        newMarket.statsTypeId = statsTypeId
                        finalMarkets.append(newMarket)
                    }
                    else {
                        var newMarket = market
                        finalMarkets.append(newMarket)
                    }
                }
                
                oldMatch.markets = finalMarkets
                self?.matchCurrentValueSubject.send(oldMatch)
            }
            else {
                var mergedMarkets: [Market] = mappedMatch.markets
                var statsForMarket: [String: String?] = [:]
                
                if let secundaryMarketsForSport = secundaryMarkets.first(where: { secundarySportMarket in
                    if secundarySportMarket.sportId == (mappedMatch.sport.alphaId ?? "") {
                        return true
                    }
                    if secundarySportMarket.sportId == (mappedMatch.sportIdCode ?? "") {
                        return true
                    }
                    return false
                }) {
                    for secundaryMarket in secundaryMarketsForSport.markets {
                        if var foundMarket = mergedMarkets.first(where: { market in
                            (market.marketTypeId ?? "") == secundaryMarket.typeId
                        }) {
                            foundMarket.statsTypeId = secundaryMarket.statsId
                            statsForMarket[foundMarket.id] = secundaryMarket.statsId
                            print("foundMarket updated \(foundMarket)")
                        }
                    }
                }
                
                var finalMarkets: [Market] = []
                
                for market in mergedMarkets {
                    if let statsTypeId = statsForMarket[market.id] {
                        var newMarket = market
                        newMarket.statsTypeId = statsTypeId
                        finalMarkets.append(newMarket)
                    }
                    else {
                        var newMarket = market
                        finalMarkets.append(newMarket)
                    }
                }
                
                mappedMatch.markets = finalMarkets
                
                self?.matchCurrentValueSubject.send(mappedMatch)
            }
        }
        .store(in: &self.cancellables)
    }
    
    //
    //
    private func loadEventDetails(fromId id: String) {

        if let match = self.match {
            // We already have an event
            if match.status.isLive {
                self.loadLiveEventDetails(matchId: match.id)
            }
            else {
                self.loadPreLiveEventDetails(matchId: match.id)
            }
        }
        else if self.status == .live {
            self.loadLiveEventDetails(matchId: id)
        }
        else {
            // We only have the event Id, we need to check if it's live or prelive
            Env.servicesProvider.getEventLiveData(eventId: id)
                .sink { [weak self] completion in
                    switch completion {
                    case .finished:
                        print("getEventLiveData completed")
                    case .failure(let error):
                        switch error {
                        case .resourceUnavailableOrDeleted:
                            self?.loadPreLiveEventDetails(matchId: id)
                        default:
                            print("getEventLiveData other error:", dump(error))
                        }
                    }
                } receiveValue: { [weak self] eventLiveData in
                    // The event is live
                    self?.loadLiveEventDetails(matchId: id)
                }
                .store(in: &self.cancellables)

        }

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

    private func configureWithViewModel(_ viewModel: MatchLineTableCellViewModel) {

        self.loadingView.startAnimating()
        
        if let match = viewModel.match {
            self.loadingView.stopAnimating()
            self.setupWithMatch(match)
        }

        self.matchInfoPublisher = viewModel.matchPublisher
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

    private func setupWithMatch(_ match: Match) {

        guard 
            let match = self.match
        else {
            self.match = match
            self.collectionView.reloadData()
            return
        }

        var indexPathsToUpdate: [IndexPath] = []

        // if default market is different
        if
            let firstOldMarket = self.match?.markets.first,
            let firstNewMarket = match.markets.first,
            firstOldMarket != firstNewMarket {
            indexPathsToUpdate.append(IndexPath(item: 0, section: 0)) // default market section - 0
        }
            

        // secondary markets section - 1
        for (index, newMarket) in match.markets.enumerated() {
            if index == 0 {
                continue
            }
            if let oldMarket = self.match?.markets[safe: index],
               oldMarket != newMarket {
                indexPathsToUpdate.append(IndexPath(item: index, section: 1))
            }
        }
        
        if !indexPathsToUpdate.isEmpty {
            indexPathsToUpdate.append(IndexPath(item: 0, section: 2)) // see all section - 2
        }
        
        self.match = match

        if !indexPathsToUpdate.isEmpty {
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: indexPathsToUpdate)
            }, completion: nil)
        }
        
        // self.collectionView.reloadData()
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
        
        let knownStatus = self.viewModel?.status ?? .unknown
        
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
            
            let cellViewModel = MatchWidgetCellViewModel(match: match, matchWidgetStatus: knownStatus)
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

                let cellViewModel = MatchWidgetCellViewModel(match: match, matchWidgetStatus: knownStatus)
                
                let teamsText = "\(match.homeParticipant.name) - \(match.awayParticipant.name)"
                let countryIso = match.venue?.isoCode ?? ""

                if market.outcomes.count == 2 {
                    if let cell = collectionView.dequeueCellType(OddDoubleCollectionViewCell.self, indexPath: indexPath) {
                        cell.matchStatsViewModel = self.matchStatsViewModel
                        cell.setupWithMarket(market, match: match,
                                             teamsText: teamsText,
                                             countryIso: countryIso,
                                             isLive: cellViewModel.isLiveCard)
                        
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
                        cell.setupWithMarket(market, match: match,
                                             teamsText: teamsText,
                                             countryIso: countryIso,
                                             isLive: cellViewModel.isLiveCard)
                        
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
