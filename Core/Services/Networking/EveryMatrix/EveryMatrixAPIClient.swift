//
//  EveryMatrixAPIClient.swift
//  Sportsbook
//
//  Created by André Lascas on 01/09/2021.
//

import Foundation
import Combine

class EveryMatrixAPIClient: ObservableObject {
    private var cancellable = Set<AnyCancellable>()

    init() {
        //The singleton init below is used to start up TS connection
        _ =  TSManager.shared
        NotificationCenter.default
            .publisher(for: .tsConnected)
            .sink { _ in
                print("Socket connected: \(TSManager.shared.isConnected)")
                //self.getDisciplines()
            }
            .store(in: &cancellable)

        NotificationCenter.default
            .publisher(for: .tsDisconnected)
            .sink { _ in
                self.reconnectTS()
            }
            .store(in: &cancellable)
    }

    private func reconnectTS() {
        debugPrint("***ShouldReconnectTS")
        TSManager.shared.destroySwampSession()
        TSManager.reconnect()
        let _ = TSManager.shared
    }

    func getDisciplines() {
        //Placeholder for fetching data after connecting to TS. e.g.:
        print("Get disciplines")
        TSManager.shared.getModel(router: .disciplines, decodingType: RootData<Discipline>.self)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")

                case .finished:
                    print("Data retrieved!")
                }
                debugPrint("TSRequestCompleted")
            }, receiveValue: { value in
                debugPrint("TSRequest: \(value.records)")
            })
            .store(in: &cancellable)
    }

}
