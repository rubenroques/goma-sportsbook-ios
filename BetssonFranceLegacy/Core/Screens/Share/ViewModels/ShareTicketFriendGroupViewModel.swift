//
//  ShareTicketFriendGroupViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 21/07/2022.
//

import Foundation
import Combine

class ShareTicketFriendGroupViewModel {
    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var chatroomsPublisher: CurrentValueSubject<[ChatroomData], Never> = .init([])
    var initialChatrooms: [ChatroomData] = []
    var cachedChatroomsCellsViewModels: [Int: SelectChatroomCellViewModel] = [:]
    var selectedChatrooms: [ChatroomData] = []
    var sharedTicketInfo: ClickedShareTicketInfo

    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()
    var canSendToChatroomPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var messageSentAction: (() -> Void)?

    init(sharedTicketInfo: ClickedShareTicketInfo) {
        self.sharedTicketInfo = sharedTicketInfo

        self.getChatrooms()

        self.canSendToChatroomPublisher.send(false)
    }

    func filterSearch(searchQuery: String) {
        var filteredChatrooms: [ChatroomData] = []

        for chatroom in self.initialChatrooms {
            if chatroom.chatroom.type == "individual" {
                if let otherUser = chatroom.users[safe: 1]?.name {
                    if otherUser.localizedCaseInsensitiveContains(searchQuery) {
                        filteredChatrooms.append(chatroom)
                    }
                }
            }
            else {
                if chatroom.chatroom.name.localizedCaseInsensitiveContains(searchQuery) {
                    filteredChatrooms.append(chatroom)
                }
            }
        }

        self.chatroomsPublisher.value = filteredChatrooms

        self.dataNeedsReload.send()

    }

    func resetUsers() {

        self.chatroomsPublisher.value = self.initialChatrooms

        self.dataNeedsReload.send()
    }

    func getChatrooms() {

        self.isLoadingPublisher.send(true)

        Env.gomaNetworkClient.requestChatrooms(deviceId: Env.deviceId, page: 1)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("CHATROOMS ERROR: \(error)")
                    self?.isLoadingPublisher.send(false)
                    self?.dataNeedsReload.send()

                case .finished:
                    ()
                }

                self?.isLoadingPublisher.send(false)
                self?.dataNeedsReload.send()
            }, receiveValue: { [weak self] response in
                if let chatrooms = response.data {
                    self?.initialChatrooms = chatrooms
                    self?.chatroomsPublisher.value = chatrooms
                }
            })
            .store(in: &cancellables)

    }

    func refetchChatrooms() {
        self.initialChatrooms = []
        self.chatroomsPublisher.value = []
        self.cachedChatroomsCellsViewModels = [:]

        self.getChatrooms()
    }

    func checkSelectedChatrooms(cellViewModel: SelectChatroomCellViewModel) {

        if cellViewModel.isCheckboxSelected {
            self.selectedChatrooms.append(cellViewModel.chatroomData)
        }
        else {
            let chatroomsArray = self.selectedChatrooms.filter {$0.chatroom.id != cellViewModel.chatroomData.chatroom.id}
            self.selectedChatrooms = chatroomsArray
        }

        if self.selectedChatrooms.isEmpty {
            self.canSendToChatroomPublisher.send(false)
        }
        else {
            self.canSendToChatroomPublisher.send(true)
        }

    }

    func sendTicketMessage(message: String) {
//
//        if self.selectedChatrooms.isNotEmpty {
//
//            guard
//                let ticket = self.sharedTicketInfo.ticket
//            else {
//                return
//            }
//
//            let betTokenRoute = em .getSharedBetTokens(betId: ticket.betId)
//
//            Env. em .manager.getModel(router: betTokenRoute, decodingType: SharedBetToken.self)
//                .receive(on: DispatchQueue.main)
//                .sink(receiveCompletion: { [weak self] completion in
//                    switch completion {
//                    case .failure:
//                        ()
//                    case .finished:
//                        ()
//                    }
//                },
//                      receiveValue: { [weak self] betToken in
//                    guard let self = self else { return }
//
//                    let attachment = self.generateAttachmentString(ticket: ticket,
//                                                                   withToken: betToken.sharedBetTokens.betTokenWithAllInfo)
//
//                    for chatroomData in self.selectedChatrooms {
//
//                        Env.gomaSocialClient.sendMessage(chatroomId: chatroomData.chatroom.id,
//                                                         message: message,
//                                                         attachment: attachment)
//                    }
//
//                    self.messageSentAction?()
//                })
//                .store(in: &cancellables)
//        }
    }

    func generateAttachmentString(ticket: BetHistoryEntry, withToken betShareToken: String) -> [String: AnyObject]? {

        guard let token = Env.gomaNetworkClient.getCurrentToken() else {
            return nil
        }

        let attachment = SharedBetTicketAttachment(id: ticket.betId,
                                                   type: "bet",
                                                   fromUser: "\(token.userId)",
                                                   content: SharedBetTicket(betHistoryEntry: ticket,
                                                                            betShareToken: betShareToken))

        if let jsonData = try? JSONEncoder().encode(attachment) {
            let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: AnyObject]
            return dictionary
        }
        else {
            return nil
        }
    }
}
