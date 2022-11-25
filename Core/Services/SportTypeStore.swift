//
//  SportTypeStore.swift
//  Sportsbook
//
//  Created by André Lascas on 23/11/2022.
//

import Foundation
import Combine
import ServiceProvider

class SportTypeStore {

    private var cancellables = Set<AnyCancellable>()
    private var sports = [Sport]()
    var isLoadingSportTypesPublisher = CurrentValueSubject<Bool, Never>(true)

    var defaultSport: Sport {
        if let football = self.sports.filter({
            $0.name.lowercased() == "football"
        }).first {
            return football
        }
        else if let firstSport = self.sports.first {
            return firstSport
        }
        else {
            return Sport(id: "1", name: "Football", alphaId: "FBL", numericId: nil, showEventCategory: false, liveEventsCount: 0)
        }
    }

    func getSportTypesList() {

        Env.serviceProvider.getAllSportsList().sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                ()
            case .failure(let error):
                print("SPORT LIST ERROR: \(error)")
            }
        }, receiveValue: { [weak self] sportsList in

            self?.sports = sportsList.map(ServiceProviderModelMapper.sport(fromServiceProviderSportType:))
            self?.isLoadingSportTypesPublisher.send(false)

        })
        .store(in: &cancellables)
    }

}
