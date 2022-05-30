//
//  ConversationBetSelectionViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 23/05/2022.
//

import Foundation
import Combine

class ConversationBetSelectionViewModel {

    // MARK: Public Properties
    var cachedCellViewModels: [String: BetSelectionCellViewModel] = [:]
    var isChatOnline: Bool = false
    var isChatGroup: Bool = false

    var titlePublisher: CurrentValueSubject<String, Never> = .init("")
    var usersPublisher: CurrentValueSubject<String, Never> = .init("")
    var groupInitialsPublisher: CurrentValueSubject<String, Never> = .init("")
    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()

    var hasTicketSelectedPublisher: CurrentValueSubject<Bool, Never> = .init(true)

    var isLoadingOpened: CurrentValueSubject<Bool, Never> = .init(true)
    var openedTicketsPublisher: CurrentValueSubject<[BetHistoryEntry], Never> = .init([])

    var isLoadingSharedBetPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    var messageSentAction: (() -> Void)?

    // MARK: Private Properties
    private var conversationData: ConversationData
    private var cancellables = Set<AnyCancellable>()

    private let recordsPerPage = 30
    private var openedTicketsPage = 0

    // MARK: Lifetime and Cycle
    init(conversationData: ConversationData) {
        self.conversationData = conversationData

        self.setupConversationInfo()

        self.loadOpenedTickets(page: 0)
    }

    // MARK: Functions
    private func setupConversationInfo() {

        self.titlePublisher.value = self.conversationData.name

        if self.conversationData.conversationType == .user {
            self.usersPublisher.value = "\(self.conversationData.name.lowercased())"
            self.isChatGroup = false
        }
        else if let groupUsers = self.conversationData.groupUsers {

            let numberUsers = groupUsers.count
            let onlineUsers = 0
            var userDetailsString = ""

            let chatGroupDetailString = localized("chat_group_users_details")

            userDetailsString = chatGroupDetailString.replacingFirstOccurrence(of: "%s", with: "\(onlineUsers)")
            userDetailsString = userDetailsString.replacingOccurrences(of: "%s", with: "\(numberUsers)")

            self.usersPublisher.value = userDetailsString

            self.groupInitialsPublisher.value = self.getGroupInitials(text: self.conversationData.name)

            self.isChatGroup = true
        }
    }

    func clearData() {
        self.openedTicketsPublisher.value = []
        self.reloadData()
    }

    func reloadData() {
        self.dataNeedsReload.send()
    }

    func requestTicketsNextPage() {
        self.openedTicketsPage += 1
        self.loadOpenedTickets(page: openedTicketsPage)
    }

    func refresh() {
        self.openedTicketsPage = 0
        self.loadOpenedTickets(page: 0)
    }

    func loadOpenedTickets(page: Int) {

        self.isLoadingOpened.send(true)

        let openedRoute = TSRouter.getMyTickets(language: "en", ticketsType: EveryMatrix.MyTicketsType.opened, records: recordsPerPage, page: page)
        Env.everyMatrixClient.manager.getModel(router: openedRoute, decodingType: BetHistoryResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let apiError):
                    switch apiError {
                    case .requestError(let value) where value.lowercased().contains("you must be logged in to perform this action"):
                        self?.clearData()
                    case .notConnected:
                        self?.clearData()
                    default:
                        ()
                    }
                case .finished:
                    ()
                }
                self?.isLoadingOpened.send(false)
            },
            receiveValue: { [weak self] betHistoryResponse in
                self?.openedTicketsPublisher.value = betHistoryResponse.betList ?? []
                self?.reloadData()
            })
            .store(in: &cancellables)
    }

    private func getGroupInitials(text: String) -> String {
        var initials = ""

        for letter in text {
            if letter.isUppercase {
                if initials.count < 2 {
                    initials = "\(initials)\(letter)"
                }
            }
        }

        if initials == "" {
            if let firstChar = text.first {
                initials = "\(firstChar.uppercased())"
            }
        }

        return initials
    }

    func sendMessage(message: String) {

        var selectedBetSelectionCellViewModel: BetSelectionCellViewModel? = nil

        for cellViewModel in self.cachedCellViewModels.values {
            if cellViewModel.isCheckboxSelectedPublisher.value {
                selectedBetSelectionCellViewModel = cellViewModel

            }
        }

        guard
            let viewModelValue = selectedBetSelectionCellViewModel
        else {
            return
        }

        self.isLoadingSharedBetPublisher.send(true)

        let betTokenRoute = TSRouter.getSharedBetTokens(betId: viewModelValue.id)

        Env.everyMatrixClient.manager.getModel(router: betTokenRoute, decodingType: SharedBetToken.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    self?.isLoadingSharedBetPublisher.send(false)
                case .finished:
                    ()
                }
            },
            receiveValue: { [weak self] betToken in
                guard let self = self else { return }

                let attachment = self.generateAttachmentString(viewModel: viewModelValue,
                                                               withToken: betToken.sharedBetTokens.betTokenWithAllInfo)

                Env.gomaSocialClient.sendMessage(chatroomId: self.conversationData.id,
                                                 message: message,
                                                 attachment: attachment)
  
                self.isLoadingSharedBetPublisher.send(false)
                self.messageSentAction?()
            })
            .store(in: &cancellables)

    }

    func generateAttachmentString(viewModel: BetSelectionCellViewModel, withToken betShareToken: String) -> [String: AnyObject]? {

        guard let token = Env.gomaNetworkClient.getCurrentToken() else {
            return nil
        }

        let attachment = SharedBetTicketAttachment(id: viewModel.id,
                                                   type: "bet",
                                                   fromUser: "\(token.userId)",
                                                   content: SharedBetTicket(betHistoryEntry: viewModel.ticket,
                                                                            betShareToken: betShareToken))

        if let jsonData = try? JSONEncoder().encode(attachment) {
            let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: AnyObject]
            return dictionary
        }
        else {
            return nil
        }
    }

    func getDefaultDateFormatted(date: Date) -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd-MM-yyyy HH:mm"
        return dateFormatterPrint.string(from: date)
    }

    func checkSelectedTicket(withId id: String) {
        for cellViewModel in self.cachedCellViewModels.values {
            if cellViewModel.id != id {
                cellViewModel.unselectTicket()
            }
        }

        if let cellViewModel = self.cachedCellViewModels[id] {
            cellViewModel.selectTicket()
        }

        self.updateAnySelected()
    }

    func uncheckSelectedTicket(withId id: String) {
        if let cellViewModel = self.cachedCellViewModels[id] {
            cellViewModel.unselectTicket()
        }

        self.updateAnySelected()
    }

    func updateAnySelected() {
        let anySelected = self.cachedCellViewModels.map { (_, value: BetSelectionCellViewModel) -> Bool in
            return value.isCheckboxSelectedPublisher.value
        }
        .contains(true)
        self.hasTicketSelectedPublisher.send(anySelected)
    }

    func createAttachement() -> [String: AnyObject]? {


        return nil
    }

}

extension ConversationBetSelectionViewModel {

}

extension ConversationBetSelectionViewModel {

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {
        return self.openedTicketsPublisher.value.count
    }

    func sectionTitle(forSectionIndex section: Int) -> String {
        return "Share my tickets"
    }

    func viewModel(forIndex index: Int) -> BetSelectionCellViewModel? {

        if let ticket = self.openedTicketsPublisher.value[safe: index] {
            if let cellViewModel = self.cachedCellViewModels[ticket.betId] {
                return cellViewModel
            }
            else {
                let cellViewModel = BetSelectionCellViewModel(ticket: ticket)
                self.cachedCellViewModels[ticket.betId] = cellViewModel
                return cellViewModel
            }
        }

        return nil
    }

}
