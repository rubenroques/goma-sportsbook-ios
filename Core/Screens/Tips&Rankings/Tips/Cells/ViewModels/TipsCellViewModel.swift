//
//  TipsCellViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 09/09/2022.
//

import Foundation
import Combine
class TipsCellViewModel {

    var featuredTip: FeaturedTip
    var cancellables = Set<AnyCancellable>()

    var shouldShowBetslip: (() -> Void)?

    init(featuredTip: FeaturedTip) {
        self.featuredTip = featuredTip

    }

    func getUsername() -> String {
        return self.featuredTip.username
    }

    func getUserId() -> String? {
        return self.featuredTip.userId
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

    func getBetId() -> String {
        return self.featuredTip.betId
    }

    func hasFollowEnabled() -> Bool {

        return false
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

    func unfollowUser(userId: String) {

        Env.gomaNetworkClient.deleteFollowUser(deviceId: Env.deviceId, userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("UNFOLLOW USER ERROR: \(error)")
                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] response in
                print("UNFOLLOW USER RESPONSE: \(response)")
                Env.gomaSocialClient.getFollowingUsers()
            })
            .store(in: &cancellables)
    }
}
