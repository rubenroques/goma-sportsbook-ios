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

    func getDisciplines(payload: [String:Any]?) {
        //print("Get disciplines")
        TSManager.shared.getModel(router: .disciplines(payload: payload), decodingType: RootData<Discipline>.self)
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
                debugPrint("TSRequest: \(String(describing: value.records))")
            })
            .store(in: &cancellable)
    }

    func getLocations(payload: [String:Any]?) {
        //print("Get locations")
        TSManager.shared.getModel(router: .locations(payload: payload), decodingType: RootData<Location>.self)
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
                debugPrint("TSRequest: \(String(describing: value.records))")
            })
            .store(in: &cancellable)
    }

    func getTournaments(payload: [String:Any]?) {
        //print("Get tournaments")
        TSManager.shared.getModel(router: .tournaments(payload: payload), decodingType: RootData<Tournament>.self)
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
                debugPrint("TSRequest: \(String(describing: value.records))")
            })
            .store(in: &cancellable)
    }

    func getMatches(payload: [String:Any]?) {
        //print("Get matches")
        TSManager.shared.getModel(router: .matches(payload: payload), decodingType: RootData<Match>.self)
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
                debugPrint("TSRequest: \(String(describing: value.records))")
            })
            .store(in: &cancellable)
    }

}
