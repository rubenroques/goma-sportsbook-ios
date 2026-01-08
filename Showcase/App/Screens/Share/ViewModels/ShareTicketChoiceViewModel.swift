//
//  ShareTicketChoiceViewModel.swift
//  ShowcaseProd
//
//  Created by André Lascas on 21/07/2022.
//

import Foundation
import Combine

class ShareTicketChoiceViewModel {

    var chatrooms: CurrentValueSubject<[ChatroomData], Never> = .init([])
    var shouldReloadData: PassthroughSubject<Void, Never> = .init()
    var clickedShareTicketInfo: ClickedShareTicketInfo?
    var messageSentAction: (() -> Void)?

    private var cancellables = Set<AnyCancellable>()

    init(clickedShareTicketInfo: ClickedShareTicketInfo) {

        self.clickedShareTicketInfo = clickedShareTicketInfo

        self.getChatrooms()

    }

    private func getChatrooms() {

        Env.gomaNetworkClient.requestChatrooms(deviceId: Env.deviceId, page: 1)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    Logger.log("Share ticket chatrooms failure \(error)")
                case .finished:
                    Logger.log("Share ticket chatrooms finished")
                }

                self?.shouldReloadData.send()
            }, receiveValue: { [weak self] response in
                if let chatrooms = response.data {
                    self?.chatrooms.value = chatrooms
                }
            })
            .store(in: &cancellables)
    }

    func sendTicketMessage(chatroomData: ChatroomData) {

        guard
            let ticket = self.clickedShareTicketInfo?.ticket
        else {
            return
        }
//
//        let betTokenRoute = em .getSharedBetTokens(betId: ticket.betId)
//
//        Env. em .manager.getModel(router: betTokenRoute, decodingType: SharedBetToken.self)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure:
//                    ()
//                case .finished:
//                    ()
//                }
//            },
//            receiveValue: { [weak self] betToken in
//                guard let self = self else { return }
//
//                let defaultMessage = localized("check_this_bet_made")
//
//                let attachment = self.generateAttachmentString(ticket: ticket,
//                                                               withToken: betToken.sharedBetTokens.betTokenWithAllInfo)
//
//                Env.gomaSocialClient.sendMessage(chatroomId: chatroomData.chatroom.id,
//                                                 message: defaultMessage,
//                                                 attachment: attachment)
//
//                //self.isLoadingSharedBetPublisher.send(false)
//                self.messageSentAction?()
//            })
//            .store(in: &cancellables)

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
