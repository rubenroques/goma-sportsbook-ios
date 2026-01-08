//
//  SelfExclusionViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 02/03/2023.
//

import Foundation
import Combine
import ServicesProvider

class SelfExclusionViewModel {

    // MARK: Private Properties
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Public Properties
    var isLockedPlayer: CurrentValueSubject<Bool, Never> = .init(false)
    var shouldShowAlert: CurrentValueSubject<AlertType, Never> = .init(.success)

    // MARK: Cycles
    init() {
    }

    // MARK: Functions
    func lockPlayer(lockPeriodUnit: String, lockPeriod: String) {

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

        Env.servicesProvider.lockPlayer(lockPeriodUnit: lockPeriodUnitCode, lockPeriod: lockPeriod)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("LOCK PLAYER ERROR: \(error)")
                    self?.shouldShowAlert.send(.error)
                }

            }, receiveValue: { [weak self] lockPlayerResponse in

                self?.shouldShowAlert.send(.success)

            })
            .store(in: &cancellables)

//        if isPermanent {
//            Env.servicesProvider.lockPlayer(isPermanent: isPermanent)
//                .receive(on: DispatchQueue.main)
//                .sink(receiveCompletion: { [weak self] completion in
//                    switch completion {
//                    case .finished:
//                        ()
//                    case .failure(let error):
//                        print("LOCK PLAYER ERROR: \(error)")
//                        self?.shouldShowAlert.send(.error)
//                    }
//
//                }, receiveValue: { [weak self] lockPlayerResponse in
//
//                    self?.shouldShowAlert.send(.success)
//
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
//                        self?.shouldShowAlert.send(.error)
//                    }
//
//                }, receiveValue: { [weak self] lockPlayerResponse in
//
//                    self?.shouldShowAlert.send(.success)
//
//                })
//                .store(in: &cancellables)
//        }

    }
}
