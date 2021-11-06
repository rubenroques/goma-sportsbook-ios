//
//  BetslipManager.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/11/2021.
//

import UIKit
import Combine
import OrderedCollections

class BetslipManager: NSObject {

    private var bettingTicketsDictionaryPublisher: CurrentValueSubject<OrderedDictionary<String, BettingTicket>, Never> = .init([:])
    var bettingTicketsPublisher: CurrentValueSubject<[BettingTicket], Never> = .init([])

    var cancellable: Set<AnyCancellable> = []

    override init() {

        super.init()

        bettingTicketsDictionaryPublisher
            .map({ dictionary -> [BettingTicket] in
                return Array.init(dictionary.values)
            })
            .sink { [weak self] tickets in
                self?.bettingTicketsPublisher.send(tickets)
            }
            .store(in: &cancellable)
        
    }

    func addBettingTicket(_ bettingTicket: BettingTicket) {
//        var currentValue = self.bettingTicketsPublisher.value
//        currentValue.append(bettingTicket)
//        bettingTicketsPublisher.send(currentValue)

        bettingTicketsDictionaryPublisher.value[bettingTicket.id] = bettingTicket
    }

    func removeBettingTicket(_ bettingTicket: BettingTicket) {

        bettingTicketsDictionaryPublisher.value[bettingTicket.id] = nil

//        var currentValue = self.bettingTicketsPublisher.value
//        currentValue.remove(bettingTicket)
//        bettingTicketsPublisher.send(currentValue)
    }

    func removeBettingTicket(withId id: String) {

        bettingTicketsDictionaryPublisher.value[id] = nil

//        var orderedSet: OrderedSet<BettingTicket> = []
//        for ticket in self.bettingTicketsPublisher.value {
//            if ticket.id == id {
//                continue
//            }
//            orderedSet.append(ticket)
//        }
//        bettingTicketsPublisher.send(orderedSet)
    }

    func hasBettingTicket(_ bettingTicket: BettingTicket) -> Bool {
        return bettingTicketsDictionaryPublisher.value[bettingTicket.id] != nil
    }

    func hasBettingTicket(withId id: String) -> Bool {
        return bettingTicketsDictionaryPublisher.value[id] != nil
//        var hasValue = false
//        for ticket in self.bettingTicketsPublisher.value {
//            if ticket.id == id {
//                hasValue = true
//                break
//            }
//        }
//        return hasValue
    }

    func clearAllBettingTickets() {
        self.bettingTicketsDictionaryPublisher.send([:])
    }

}
