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
    var hasTicketSelectedPublisher: CurrentValueSubject<Bool, Never> = .init(true)
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

    func sendMessage(message: String) {

        var selectedBetSelectionCellViewModel: BetSelectionCellViewModel? = nil

//        for cellViewModel in self.cachedCellViewModels.values {
//            if cellViewModel.isCheckboxSelectedPublisher.value {
//                selectedBetSelectionCellViewModel = cellViewModel
//
//            }
//        }

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
            let viewModelValue = selectedBetSelectionCellViewModel
        else {
            return
        }

//        self.isLoadingSharedBetPublisher.send(true)
//
//        let betTokenRoute = em .getSharedBetTokens(betId: viewModelValue.id)
//
//        Env. em .manager.getModel(router: betTokenRoute, decodingType: SharedBetToken.self)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure:
//                    ()
//                    self?.isLoadingSharedBetPublisher.send(false)
//                case .finished:
//                    ()
//                }
//            },
//            receiveValue: { [weak self] betToken in
//                guard let self = self else { return }
//
//                let attachment = self.generateAttachmentString(viewModel: viewModelValue,
//                                                               withToken: betToken.sharedBetTokens.betTokenWithAllInfo)
//
//                Env.gomaSocialClient.sendMessage(chatroomId: self.conversationData.id,
//                                                 message: message,
//                                                 attachment: attachment)
//
//                self.isLoadingSharedBetPublisher.send(false)
//                self.messageSentAction?()
//            })
//            .store(in: &cancellables)

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

}
