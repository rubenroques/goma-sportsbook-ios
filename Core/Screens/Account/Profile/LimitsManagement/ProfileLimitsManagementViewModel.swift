//
//  ProfileLimitsManagementViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 22/02/2022.
//

import Foundation
import Combine

class ProfileLimitsManagementViewModel: NSObject {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var depositLimit: EveryMatrix.Limit?
    var wageringLimit: EveryMatrix.Limit?
    var lossLimit: EveryMatrix.Limit?
    var limitsLoadedPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    // MARK: Cycles
    override init() {
        super.init()

        self.getLimits()
    }

    private func getLimits() {
        Env.everyMatrixClient.getLimits()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("LIMITS ERROR: \(error)")
                case .finished:
                    print("LIMITS FINISHED")
                }
            }, receiveValue: { [weak self] limitsResponse in
                print("LIMITS: \(limitsResponse)")
                self?.setLimitsData(limitsResponse: limitsResponse)
            })
            .store(in: &cancellables)
    }

    private func setLimitsData(limitsResponse: EveryMatrix.LimitsResponse) {

        self.depositLimit = limitsResponse.deposit
        self.wageringLimit = limitsResponse.wagering
        self.lossLimit = limitsResponse.loss

        self.limitsLoadedPublisher.send(true)
    }
}
