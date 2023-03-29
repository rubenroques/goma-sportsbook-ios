//
//  PreSubmissionBetslipViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 10/03/2022.
//

import Foundation
import Combine

class PreSubmissionBetslipViewModel {

    // MARK: Public Properties
    var bonusBetslipArrayPublisher: CurrentValueSubject<[BonusBetslip], Never> = .init([])
    var sharedBetsPublisher: CurrentValueSubject<LoadableContent<[BettingTicket]>, Never> = .init(LoadableContent.idle)
    var isPartialBetSelection: CurrentValueSubject<Bool, Never> = .init(false)
    var isUnavailableBetSelection: CurrentValueSubject<Bool, Never> = .init(false)

    // MARK: Private Properties
    private var sharedBetToken: String?

    private var cancellables = Set<AnyCancellable>()

    init(sharedBetToken: String? = nil) {

        self.sharedBetToken = sharedBetToken

        // Get shared bet details
    }

}

struct BonusBetslip {
    let bonus: EveryMatrix.GrantedBonus
    let bonusType: GrantedBonusType
}
