//
//  EventsStore.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/09/2021.
//

import Foundation
import Combine

class EventsStore: NSObject {

    private var cancellable = Set<AnyCancellable>()

    override init() {

    }

    func getEvents() -> AnyPublisher<Events, Never> {

        let payload = ["": ""]
        return Env.everyMatrixAPIClient.getEvents(payload: payload)
            .map { return ($0.records ?? []) }
            .replaceError(with: [])
            .handleEvents(receiveOutput: { events in
                print("events \(events)")
            })
            .eraseToAnyPublisher()
    }
}
