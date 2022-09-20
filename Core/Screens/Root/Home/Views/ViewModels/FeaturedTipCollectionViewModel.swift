//
//  FeaturedTipCollectionViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 01/09/2022.
//

import Foundation
import Combine

class FeaturedTipCollectionViewModel {

    var featuredTip: FeaturedTip
    var cancellables = Set<AnyCancellable>()

    var shouldShowBetslip: (() -> Void)?

    enum SizeType {
        case small
        case fullscreen
    }
    
    var sizeType: SizeType

    init(featuredTip: FeaturedTip, sizeType: SizeType) {
        self.featuredTip = featuredTip
        self.sizeType = sizeType
    }

    var shouldCropList: Bool {
        return self.sizeType == .small
    }
    
    func getUsername() -> String {
        return self.featuredTip.username
    }

    func getTotalOdds() -> String {
        if let oddsDouble = Double(self.featuredTip.totalOdds) {
            let oddFormatted = OddFormatter.formatOdd(withValue: oddsDouble)
            return "\(oddFormatted)"
        }
        return ""
    }

    func getNumberSelections() -> String {
        if let numberSelections = self.featuredTip.selections?.count {
            return "\(numberSelections)"
        }

        return ""
    }

    func getUserId() -> String {
        return self.featuredTip.userId
    }

    func createBetslipTicket() {

        guard let selections = self.featuredTip.selections else {return}

        for selection in selections {
            let bettingOfferId = "\(selection.extraSelectionInfo.bettingOfferId)"
            let ticket = BettingTicket(id: bettingOfferId,
                                       outcomeId: selection.outcomeId,
                                       marketId: selection.bettingTypeId,
                                       matchId: selection.eventId,
                                       value: Double(selection.odds) ?? 0.0,
                                       isAvailable: true,
                                       statusId: "\(selection.extraSelectionInfo.outcomeEntity.statusId)",
                                       matchDescription: selection.eventName,
                                       marketDescription: selection.extraSelectionInfo.marketName,
                                       outcomeDescription: selection.betName)

            if !Env.betslipManager.hasBettingTicket(withId: "\(selection.extraSelectionInfo.bettingOfferId)") {

                Env.betslipManager.addBettingTicket(ticket)

                self.shouldShowBetslip?()
            }

        }
    }

    func followUser(userId: String) {

        Env.gomaNetworkClient.followUser(deviceId: Env.deviceId, userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("FOLLOW USER ERROR: \(error)")
                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] response in
                print("FOLLOW USER RESPONSE: \(response)")
                Env.gomaSocialClient.getFollowingUsers()
            })
            .store(in: &cancellables)
    }
}
