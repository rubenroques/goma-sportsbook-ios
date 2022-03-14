//
//  PreSubmissionBetslipViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 10/03/2022.
//

import Foundation
import Combine

class PreSubmissionBetslipViewModel: NSObject {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var bonusBetslipArrayPublisher: CurrentValueSubject<[BonusBetslip], Never> = .init([])

    override init() {
        super.init()

        self.getGrantedBonus()
    }

    private func getGrantedBonus() {

        Env.everyMatrixClient.getGrantedBonus()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("GRANTED BONUS ERROR: \(error)")
                case .finished:
                    ()                }
            }, receiveValue: { [weak self] bonusResponse in

                if let bonuses = bonusResponse.bonuses {
                    self?.processGrantedBonus(bonuses: bonuses)
                }

            })
            .store(in: &cancellables)
    }

    private func processGrantedBonus(bonuses: [EveryMatrix.GrantedBonus]) {

        var bonusArray: [BonusBetslip] = []

        for bonus in bonuses {
            if bonus.status == "active" {
                var bonusType: GrantedBonusType?

                if let bonusTypeString = bonus.type {
                    if bonusTypeString == GrantedBonusType.freeBet.identifier {
                        bonusType = GrantedBonusType.freeBet
                    }
                    else if bonusTypeString == GrantedBonusType.oddsBoost.identifier {
                        bonusType = GrantedBonusType.oddsBoost
                    }
                    else {
                        bonusType = GrantedBonusType.standard
                    }
                }
                let bonusBetslip = BonusBetslip(bonus: bonus, bonusType: bonusType ?? .standard)
                bonusArray.append(bonusBetslip)
            }
        }

        self.bonusBetslipArrayPublisher.value = bonusArray
    }

}

struct BonusBetslip {
    let bonus: EveryMatrix.GrantedBonus
    let bonusType: GrantedBonusType
}
