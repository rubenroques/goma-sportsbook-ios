//
//  ConversationBetSelectionRootViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 21/07/2022.
//

import Foundation
import Combine

class ConversationBetSelectionRootViewModel {

    var cachedCellViewModels: [String: BetSelectionCellViewModel] = [:]
    var chatTitlePublisher: CurrentValueSubject<String, Never> = .init("")
    var selectedTicketTypeIndexPublisher: CurrentValueSubject<Int?, Never> = .init(nil)
    var hasTicketSelectedPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var openSelectedTicket: BetSelectionCellViewModel?
    var resolvedSelectedTicket: BetSelectionCellViewModel?
    var wonSelectedTicket: BetSelectionCellViewModel?

    var messageSentAction: (() -> Void)?
    var isLoadingSharedBetPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    private var conversationData: ConversationData
    private var startTabIndex: Int
    private var cancellables = Set<AnyCancellable>()

    init(startTabIndex: Int, conversationData: ConversationData) {
        self.conversationData = conversationData

        self.startTabIndex = startTabIndex
        self.selectedTicketTypeIndexPublisher.send(startTabIndex)

        self.setupConversationInfo()

    }

    // MARK: Functions
    func selectTicketType(atIndex index: Int) {
        self.selectedTicketTypeIndexPublisher.send(index)
    }

    private func setupConversationInfo() {

        self.chatTitlePublisher.value = "\(self.conversationData.name)"

    }
    
    func checkTicketSelected() {
        
        if let ticketTypeIndex = self.selectedTicketTypeIndexPublisher.value {
            if ticketTypeIndex == 0 && self.openSelectedTicket != nil {
                self.hasTicketSelectedPublisher.send(true)
            }
            else if ticketTypeIndex == 1 && self.resolvedSelectedTicket != nil {
                self.hasTicketSelectedPublisher.send(true)

            }
            else if ticketTypeIndex == 2 && self.wonSelectedTicket != nil {
                self.hasTicketSelectedPublisher.send(true)
            }
            else {
                self.hasTicketSelectedPublisher.send(false)
            }
        }
    }

    func sendMessage(message: String) {

        var selectedBetSelectionCellViewModel: BetSelectionCellViewModel? = nil

        if let ticketTypeIndex = self.selectedTicketTypeIndexPublisher.value {
            if ticketTypeIndex == 0 && self.openSelectedTicket != nil {
                selectedBetSelectionCellViewModel = self.openSelectedTicket
            }
            else if ticketTypeIndex == 1 && self.resolvedSelectedTicket != nil {
                selectedBetSelectionCellViewModel = self.resolvedSelectedTicket
            }
            else if ticketTypeIndex == 2 && self.wonSelectedTicket != nil {
                selectedBetSelectionCellViewModel = self.wonSelectedTicket
            }
        }

        guard
            let viewModelValue = selectedBetSelectionCellViewModel,
            let betShareToken = viewModelValue.ticket.betShareToken
        else {
            return
        }
        
        let attachment = self.generateAttachmentString(viewModel: viewModelValue,
                                                       withToken: betShareToken)
        
        Env.gomaSocialClient.sendMessage(chatroomId: self.conversationData.id,
                                         message: message,
                                         attachment: attachment)
        
        self.messageSentAction?()
        
    }

    func generateAttachmentString(viewModel: BetSelectionCellViewModel, withToken betShareToken: String) -> [String: AnyObject]? {

        guard let user = Env.userSessionStore.userProfilePublisher.value else {
            return nil
        }

        let attachment = SharedBetTicketAttachment(id: viewModel.id,
                                                   type: "bet",
                                                   fromUser: "\(user.userIdentifier)",
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

}
