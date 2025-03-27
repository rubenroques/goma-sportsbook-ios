//
//  File.swift
//  Sportsbook
//
//  Created by André Lascas on 18/04/2022.
//

import Foundation
import Combine

class AddFriendCellViewModel {

    private var cancellables = Set<AnyCancellable>()

    var userContact: UserContact
    var username: String
    var phones: [String]
    var isCheckboxSelected: Bool
    var isOnlinePublisher: CurrentValueSubject<Bool, Never> = .init(false)
    
    var didAddFriend: ((FriendAlertType) -> Void)?

    init(userContact: UserContact) {
        self.userContact = userContact
        
        self.username = userContact.username

        self.phones = userContact.phones

        self.isCheckboxSelected = false

        self.setupPublishers()
    }

    private func setupPublishers() {
        if let onlineUsersPublisher = Env.gomaSocialClient.onlineUsersPublisher() {

            onlineUsersPublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] onlineUsersResponse in
                    guard let self = self else {return}

                    let isUserOnline = onlineUsersResponse.values.contains { value -> Bool in

                        if value.users.contains(self.userContact.id) {
                            return true
                        }

                        return false
                    }

                    if isUserOnline {

                        self.isOnlinePublisher.send(true)

                    }
                    else {
                        self.isOnlinePublisher.send(false)
                    }

                })
                .store(in: &cancellables)
        }
    }
    
    func addFriendFromId(id: String) {
        
        Env.servicesProvider.addFriends(userIds: [id])
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("ADD FRIEND ERROR: \(error)")
                    self?.didAddFriend?(.error)
                case .finished:
                    print("ADD FRIEND FINISHED")
                }

            }, receiveValue: { [weak self] addFriendResponse in
                print("ADD FRIEND GOMA: \(addFriendResponse)")
                
                self?.didAddFriend?(.success)
            })
            .store(in: &cancellables)
    
    }
}
