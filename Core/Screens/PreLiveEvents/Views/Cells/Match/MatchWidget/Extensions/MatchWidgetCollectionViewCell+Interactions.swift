//
//  MatchWidgetCollectionViewCell+Interactions.swift
//  Sportsbook
//
//  Created by Refactoring on 2024.
//

import UIKit
import LinkPresentation

// MARK: - User Interactions
extension MatchWidgetCollectionViewCell {
    
    // MARK: - Setup Gesture Recognizers
    func setupGestureRecognizers() {
        // Odd button tap gestures
        let tapLeftOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapLeftOddButton))
        self.homeBaseView.addGestureRecognizer(tapLeftOddButton)
        
        let tapMiddleOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapMiddleOddButton))
        self.drawBaseView.addGestureRecognizer(tapMiddleOddButton)
        
        let tapRightOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapRightOddButton))
        self.awayBaseView.addGestureRecognizer(tapRightOddButton)
        
        // Odd button long press gestures
        let longPressLeftOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressLeftOddButton))
        self.homeBaseView.addGestureRecognizer(longPressLeftOddButton)
        
        let longPressMiddleOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressMiddleOddButton))
        self.drawBaseView.addGestureRecognizer(longPressMiddleOddButton)
        
        let longPressRightOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressRightOddButton))
        self.awayBaseView.addGestureRecognizer(longPressRightOddButton)
        
        // Match view tap gesture
        let tapMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMatchView))
        self.addGestureRecognizer(tapMatchView)
        
        // Long press gesture for the card
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressCard))
        self.horizontalMatchInfoBaseView.addGestureRecognizer(longPressGestureRecognizer)
        
        // MixMatch tap gesture
        let tapMixMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMixMatch))
        self.mixMatchContainerView.addGestureRecognizer(tapMixMatchView)
    }
    
    // MARK: - Button Selection States
    func selectLeftOddButton() {
        self.setupWithTheme()
    }
    
    func deselectLeftOddButton() {
        self.setupWithTheme()
    }
    
    func selectMiddleOddButton() {
        self.setupWithTheme()
    }
    
    func deselectMiddleOddButton() {
        self.setupWithTheme()
    }
    
    func selectRightOddButton() {
        self.setupWithTheme()
    }
    
    func deselectRightOddButton() {
        self.setupWithTheme()
    }
    
    func selectBoostedOddButton() {
        self.newValueBoostedButtonView.backgroundColor = UIColor.App.highlightPrimary
        self.newValueBoostedButtonView.layer.borderColor = UIColor.App.buttonTextPrimary.cgColor
        self.newTitleBoostedOddLabel.textColor = UIColor.App.buttonTextPrimary
        self.newValueBoostedOddLabel.textColor = UIColor.App.buttonTextPrimary
    }
    
    func deselectBoostedOddButton() {
        self.newValueBoostedButtonView.backgroundColor = UIColor.App.inputBackground
        self.newValueBoostedButtonView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
        self.newTitleBoostedOddLabel.textColor = UIColor.App.textPrimary
        self.newValueBoostedOddLabel.textColor = UIColor.App.textPrimary
    }
    
    // MARK: - Favorite Handling
    func markAsFavorite(match: Match) {
        if self.viewModel?.matchWidgetType == .topImageOutright {
            if Env.favoritesManager.isEventFavorite(eventId: match.id) {
                Env.favoritesManager.removeFavorite(eventId: match.id, favoriteType: .competition)
                self.isFavorite = false
            }
            else {
                Env.favoritesManager.addFavorite(eventId: match.id, favoriteType: .competition)
                self.isFavorite = true
            }
        }
        else {
            if Env.favoritesManager.isEventFavorite(eventId: match.id) {
                Env.favoritesManager.removeFavorite(eventId: match.id, favoriteType: .match)
                self.isFavorite = false
            }
            else {
                Env.favoritesManager.addFavorite(eventId: match.id, favoriteType: .match)
                self.isFavorite = true
            }
        }
    }
    
    // MARK: - Odd Button Interactions
    @IBAction private func didTapFavoritesButton(_ sender: Any) {
        if Env.userSessionStore.isUserLogged() {
            if let match = self.viewModel?.match {
                self.markAsFavorite(match: match)
            }
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.viewController?.present(loginViewController, animated: true, completion: nil)
        }
    }
    
    @objc func didTapLeftOddButton() {
        guard
            let match = self.viewModel?.match,
            let market = match.markets.first,
            let outcome = self.leftOutcome
        else {
            return
        }
        
        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)
        
        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isLeftOutcomeButtonSelected = false
            
            self.unselectedOutcome?(match, market, outcome)
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            self.isLeftOutcomeButtonSelected = true
            
            self.selectedOutcome?(match, market, outcome)
        }
    }
    
    @objc func didLongPressLeftOddButton(_ sender: UILongPressGestureRecognizer) {
        // Triggers function only once instead of rapid fire event
        if sender.state == .began {
            guard
                let match = self.viewModel?.match,
                let market = match.markets.first,
                let outcome = self.leftOutcome
            else {
                return
            }
            let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)
            self.didLongPressOdd?(bettingTicket)
        }
    }
    
    @objc func didTapMiddleOddButton() {
        guard
            let match = self.viewModel?.match,
            let market = match.markets.first,
            let outcome = self.middleOutcome
        else {
            return
        }
        
        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)
        
        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isMiddleOutcomeButtonSelected = false
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            self.isMiddleOutcomeButtonSelected = true
        }
    }
    
    @objc func didLongPressMiddleOddButton(_ sender: UILongPressGestureRecognizer) {
        // Triggers function only once instead of rapid fire event
        if sender.state == .began {
            guard
                let match = self.viewModel?.match,
                let market = match.markets.first,
                let outcome = self.middleOutcome
            else {
                return
            }
            
            let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)
            
            self.didLongPressOdd?(bettingTicket)
        }
    }
    
    @objc func didTapRightOddButton() {
        guard
            let match = self.viewModel?.match,
            let market = match.markets.first,
            let outcome = self.rightOutcome
        else {
            return
        }
        
        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)
        
        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isRightOutcomeButtonSelected = false
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            self.isRightOutcomeButtonSelected = true
        }
    }
    
    @objc func didLongPressRightOddButton(_ sender: UILongPressGestureRecognizer) {
        // Triggers function only once instead of rapid fire event
        if sender.state == .began {
            guard
                let match = self.viewModel?.match,
                let market = match.markets.first,
                let outcome = self.rightOutcome
            else {
                return
            }
            
            let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)
            
            self.didLongPressOdd?(bettingTicket)
        }
    }
    
    @objc func didTapBoostedOddButton() {
        guard
            let match = self.viewModel?.match,
            let market = match.markets.first,
            let outcome = market.outcomes.first
        else {
            return
        }
        
        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)
        
        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isBoostedOutcomeButtonSelected = false
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            self.isBoostedOutcomeButtonSelected = true
        }
    }
    
    // MARK: - Card Interactions
    @objc func didTapMatchView() {
        if let viewModel = self.viewModel {
            let match = viewModel.match
            if viewModel.matchWidgetType == .topImageOutright {
                if let competition = match.competitionOutright {
                    self.tappedMatchOutrightWidgetAction?(competition)
                }
            }
            else {
                self.tappedMatchWidgetAction?(match)
            }
        }
    }
    
    @objc func didTapMixMatch() {
        if let viewModel = self.viewModel {
            let match = viewModel.match
            self.tappedMixMatchAction?(match)
        }
    }
    
    @objc func didLongPressCard() {
        if Env.userSessionStore.isUserLogged() {
            guard
                let parentViewController = self.viewController,
                let match = self.viewModel?.match
            else {
                return
            }
            
            let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            if Env.favoritesManager.isEventFavorite(eventId: match.id) {
                let favoriteAction: UIAlertAction = UIAlertAction(title: "Remove from favorites", style: .default) { _ in
                    Env.favoritesManager.removeFavorite(eventId: match.id, favoriteType: .match)
                }
                actionSheetController.addAction(favoriteAction)
            }
            else {
                let favoriteAction: UIAlertAction = UIAlertAction(title: localized("add_to_favorites"), style: .default) { _ in
                    Env.favoritesManager.addFavorite(eventId: match.id, favoriteType: .match)
                }
                actionSheetController.addAction(favoriteAction)
            }
            
            let shareAction: UIAlertAction = UIAlertAction(title: localized("share_event"), style: .default) { [weak self] _ in
                self?.didTapShareButton()
            }
            actionSheetController.addAction(shareAction)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: localized("cancel"), style: .cancel) { _ in }
            actionSheetController.addAction(cancelAction)
            
            if let popoverController = actionSheetController.popoverPresentationController {
                popoverController.sourceView = parentViewController.view
                popoverController.sourceRect = CGRect(x: parentViewController.view.bounds.midX, y: parentViewController.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            parentViewController.present(actionSheetController, animated: true, completion: nil)
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.viewController?.present(loginViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Sharing
    private func didTapShareButton() {
        guard
            let parentViewController = self.viewController,
            let match = self.viewModel?.match
        else {
            return
        }
        
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        let snapshot = renderer.image { _ in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
        
        let metadata = LPLinkMetadata()
        let urlMobile = TargetVariables.clientBaseUrl
        
        if let matchUrl = URL(string: "\(urlMobile)/gamedetail/\(match.id)") {
            let imageProvider = NSItemProvider(object: snapshot)
            metadata.imageProvider = imageProvider
            metadata.url = matchUrl
            metadata.originalURL = matchUrl
            metadata.title = localized("check_this_game")
        }
        
        let metadataItemSource = LinkPresentationItemSource(metaData: metadata)
        
        let shareActivityViewController = UIActivityViewController(activityItems: [metadataItemSource, snapshot], applicationActivities: nil)
        if let popoverController = shareActivityViewController.popoverPresentationController {
            popoverController.sourceView = parentViewController.view
            popoverController.sourceRect = CGRect(x: parentViewController.view.bounds.midX, y: parentViewController.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        parentViewController.present(shareActivityViewController, animated: true, completion: nil)
    }
} 
