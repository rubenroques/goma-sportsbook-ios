//
//  MyTicketsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 17/12/2021.
//

import Foundation
import UIKit
import Combine

class MyTicketsViewModel: NSObject {

    private var selectedMyTicketsTypeIndex: Int = 0
    var myTicketsTypePublisher: CurrentValueSubject<MyTicketsType, Never> = .init(.resolved)
    enum MyTicketsType: Int {
        case resolved = 0
        case opened = 1
        case won = 2
    }

    var reloadTableViewAction: (() -> Void)?

    private var matchDetailsDictionary: [String: Match] = [:]


    private var resolvedMyTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    private var openedMyTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])
    private var wonMyTickets: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])

    private var isLoadingResolved: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingOpened: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingWon: CurrentValueSubject<Bool, Never> = .init(true)

    var isLoading: AnyPublisher<Bool, Never>

    private let recordsPerPage = 1000

    private var resolvedPage = 0
    private var openedPage = 0
    private var wonPage = 0

    private var cancellables = Set<AnyCancellable>()

    override init() {

        isLoading = Publishers.CombineLatest3(isLoadingResolved, isLoadingOpened, isLoadingWon)
            .map({ isLoadingResolved, isLoadingOpened, isLoadingWon in
                return isLoadingResolved || isLoadingOpened || isLoadingWon
            })
            .eraseToAnyPublisher()

        super.init()

        myTicketsTypePublisher.sink { [weak self] myTicketsType in
            self?.selectedMyTicketsTypeIndex =  myTicketsType.rawValue

            self?.reloadTableView()
        }
        .store(in: &cancellables)



        self.initialLoadMyTickets()
    }

    func setMyTicketsType(_ type: MyTicketsType) {
        self.myTicketsTypePublisher.value = type
    }

    func isTicketsTypeSelected(forIndex index: Int) -> Bool {
        return index == selectedMyTicketsTypeIndex
    }

    //
    //
    func initialLoadMyTickets() {

        self.loadResolvedTickets(page: 0)
        self.loadOpenedTickets(page: 0)
        self.loadWonTickets(page: 0)

    }

    func loadResolvedTickets(page: Int) {

        self.isLoadingResolved.send(true)

        let resolvedRoute = TSRouter.getMyTickets(language: "en", ticketsType: EveryMatrix.MyTicketsType.opened, records: recordsPerPage, page: page)
        TSManager.shared.getModel(router: resolvedRoute, decodingType: BetHistoryResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                self.isLoadingResolved.send(false)
            },
            receiveValue: { betHistoryResponse in
                self.resolvedMyTickets.value = betHistoryResponse.betList ?? []

                if case .resolved = self.myTicketsTypePublisher.value {
                    self.reloadTableView()
                }
            })
            .store(in: &cancellables)
    }

    func loadOpenedTickets(page: Int) {

        self.isLoadingOpened.send(true)

        let openedRoute = TSRouter.getMyTickets(language: "en", ticketsType: EveryMatrix.MyTicketsType.resolved, records: recordsPerPage, page: page)
        TSManager.shared.getModel(router: openedRoute, decodingType: BetHistoryResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                self.isLoadingOpened.send(false)
            },
            receiveValue: { betHistoryResponse in
                self.openedMyTickets.value = betHistoryResponse.betList ?? []

                if case .opened = self.myTicketsTypePublisher.value {
                    self.reloadTableView()
                }
            })
            .store(in: &cancellables)

    }

    func loadWonTickets(page: Int) {

        self.isLoadingWon.send(true)

        let wonRoute = TSRouter.getMyTickets(language: "en", ticketsType: EveryMatrix.MyTicketsType.won, records: recordsPerPage, page: page)
        TSManager.shared.getModel(router: wonRoute, decodingType: BetHistoryResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                self.isLoadingWon.send(false)
            },
            receiveValue: { betHistoryResponse in
                self.wonMyTickets.value = betHistoryResponse.betList ?? []

                if case .won = self.myTicketsTypePublisher.value {
                    self.reloadTableView()
                }
            })
            .store(in: &cancellables)

    }

    func requestNextPage() {
        switch myTicketsTypePublisher.value {
        case .resolved:
            resolvedPage += 1
            self.loadResolvedTickets(page: resolvedPage)
        case .opened:
            openedPage += 1
            self.loadOpenedTickets(page: openedPage)
        case .won:
            wonPage += 1
            self.loadWonTickets(page: wonPage)
        }
    }

    func refresh() {
        self.resolvedPage = 0
        self.openedPage = 0
        self.wonPage = 0

        self.initialLoadMyTickets()
    }

    func reloadTableView() {
        self.reloadTableViewAction?()
    }

}

extension MyTicketsViewModel: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch myTicketsTypePublisher.value {
        case .resolved:
            return resolvedMyTickets.value.count
        case .opened:
            return openedMyTickets.value.count
        case .won:
            return wonMyTickets.value.count
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let ticket: BetHistoryEntry?

        switch myTicketsTypePublisher.value {
        case .resolved:
            ticket = resolvedMyTickets.value[safe: indexPath.row] ?? nil
        case .opened:
            ticket =  openedMyTickets.value[safe: indexPath.row] ?? nil
        case .won:
            ticket =  wonMyTickets.value[safe: indexPath.row] ?? nil
        }

        guard
            let cell = tableView.dequeueCellType(MyTicketTableViewCell.self),
            let ticketValue = ticket
        else {
            fatalError("tableView.dequeueCellType(MyTicketTableViewCell.self)")
        }

        cell.configure(withBetHistoryEntry: ticketValue)

        return cell
    }

}
