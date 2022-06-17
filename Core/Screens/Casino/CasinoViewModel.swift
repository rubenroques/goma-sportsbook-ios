//
//  CasinoViewModel.swift
//  Sportsbook
//
//  Created by Teresa on 13/06/2022.
//

import Foundation
import Combine

class CasinoViewModel: NSObject {

    var isUserLoggedPublisher: CurrentValueSubject<Bool, Never> = .init(true)
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()

        self.setupPublishers()
    }

    func setupPublishers() {

        Env.userSessionStore.userSessionPublisher
            .receive(on: DispatchQueue.main)
            .map({ $0 != nil })
            .sink(receiveValue: { [weak self] isUserLoggedIn in
                self?.isUserLoggedPublisher.send(isUserLoggedIn)
            })
            .store(in: &cancellables)

    }

}
