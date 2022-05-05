//
//  FriendsListViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 26/04/2022.
//

import Foundation
import Combine

class FriendsListViewModel {
    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var friendsPublisher: CurrentValueSubject<[GomaFriend], Never> = .init([])
    var initialFriends: [GomaFriend] = []

    var cachedFriendCellViewModels: [Int: FriendStatusCellViewModel] = [:]

    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()

    // MARK: Lifetime and cycle
    init() {
        self.getFriends()
    }

    // MARK: Functions
    private func getFriends() {
        self.isLoadingPublisher.send(true)

        Env.gomaNetworkClient.requestFriends(deviceId: Env.deviceId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("LIST FRIEND ERROR: \(error)")
                case .finished:
                    ()
                }

                self?.isLoadingPublisher.send(false)
                self?.dataNeedsReload.send()

            }, receiveValue: { response in
                if let friends = response.data {
                    self.friendsPublisher.value = friends
                    self.initialFriends = friends
                }
            })
            .store(in: &cancellables)
    }

    func filterSearch(searchQuery: String) {

        let filteredUsers = self.friendsPublisher.value.filter({ $0.username.localizedCaseInsensitiveContains(searchQuery)})

        self.friendsPublisher.value = filteredUsers

        self.dataNeedsReload.send()

    }

    func resetUsers() {

        self.friendsPublisher.value = self.initialFriends

        self.dataNeedsReload.send()
    }

    func removeFriend(friendId: Int) {
        print("DELETE FRIEND ID: \(friendId)")

        Env.gomaNetworkClient.deleteFriend(deviceId: Env.deviceId, userId: friendId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("DELETE FRIEND ERROR: \(error)")
                case .finished:
                    ()
                }

            }, receiveValue: { [weak self] response in
                print("DELETE FRIEND GOMA: \(response)")
                self?.getFriends()
            })
            .store(in: &cancellables)
    }
}

extension FriendsListViewModel {

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {
        return self.friendsPublisher.value.count
    }

}
