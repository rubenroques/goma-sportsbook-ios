//
//  SelfExclusionViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 02/03/2023.
//

import Foundation
import Combine

class SelfExclusionViewModel {

    // MARK: Public Properties
    var isLockedPlayer: CurrentValueSubject<Bool, Never> = .init(false)

    // MARK: Cycles
    init() {
    }

    // MARK: Functions
    func lockPlayer(isPermanent: Bool, lockPeriodUnit: String, lockPeriod: String) {

        var lockPeriodUnitCode = ""

        if lockPeriodUnit == localized("days") {
            lockPeriodUnitCode = "DAY"
        }
        else if lockPeriodUnit == localized("weeks") {
            lockPeriodUnitCode = "WEEK"

        }
        else if lockPeriodUnit == localized("months") {
            lockPeriodUnitCode = "MONTH"
        }

//        if isPermanent {
//            Env.servicesProvider.lockPlayer(isPermanent: isPermanent)
//                .receive(on: DispatchQueue.main)
//                .sink(receiveCompletion: { [weak self] completion in
//                    switch completion {
//                    case .finished:
//                        ()
//                    case .failure(let error):
//                        print("LOCK PLAYER ERROR: \(error)")
//                    }
//
//                }, receiveValue: { [weak self] lockPlayerResponse in
//
//                    print("LOCK PLAYER RESPONSE: \(lockPlayerResponse)")
//                })
//                .store(in: &cancellables)
//        }
//        else {
//            Env.servicesProvider.lockPlayer(lockPeriodUnit: lockPeriodUnitCode, lockPeriod: lockPeriod)
//                .receive(on: DispatchQueue.main)
//                .sink(receiveCompletion: { [weak self] completion in
//                    switch completion {
//                    case .finished:
//                        ()
//                    case .failure(let error):
//                        print("LOCK PLAYER ERROR: \(error)")
//                    }
//
//                }, receiveValue: { [weak self] lockPlayerResponse in
//
//                    print("LOCK PLAYER RESPONSE: \(lockPlayerResponse)")
//                })
//                .store(in: &cancellables)
//        }

        self.isLockedPlayer.send(true)

    }
}
