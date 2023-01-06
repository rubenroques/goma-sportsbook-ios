//
//  SportTypeStore.swift
//  Sportsbook
//
//  Created by André Lascas on 23/11/2022.
//

import Foundation
import Combine
import ServicesProvider

class SportTypeStore {

    var isLoadingSportTypesPublisher = CurrentValueSubject<Bool, Never>(true)

    var defaultSport: Sport {
        if let firstSport = self.sports.first {
            return firstSport
        }
        else {
            return Sport(id: "1", name: "Football", alphaId: "FBL", numericId: nil, showEventCategory: false, liveEventsCount: 0)
        }
    }

    private var cancellables = Set<AnyCancellable>()
    private var sports = [Sport]()

    func getSportTypesList() {
        Env.servicesProvider.getAvailableSportTypes()
            .sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished:
                ()
            case .failure(let error):
                print("SPORT LIST ERROR: \(error)")
                // TODO: Retry the request
                self?.isLoadingSportTypesPublisher.send(false)
            }
        }, receiveValue: { [weak self] sportsList in

            self?.sports = sportsList.map(ServiceProviderModelMapper.sport(fromServiceProviderSportType:))
            self?.isLoadingSportTypesPublisher.send(false)

        })
        .store(in: &cancellables)
    }

}
