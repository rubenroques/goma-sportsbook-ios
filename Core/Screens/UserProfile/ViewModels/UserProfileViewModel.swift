//
//  UserProfileViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 28/09/2022.
//

import Foundation
import Combine

class UserProfileViewModel {

    var userBasicInfo: UserBasicInfo
    var isFollowingUser: CurrentValueSubject<Bool, Never> = .init(false)
    var isFriendUser: CurrentValueSubject<Bool, Never> = .init(false)
    var isFriendRequestPending: CurrentValueSubject<Bool, Never> = .init(false)
    var followersCountPublisher: CurrentValueSubject<String, Never> = .init("0")
    var followingCountPublisher: CurrentValueSubject<String, Never> = .init("0")
    var userProfileInfo: UserProfileInfo?
    var userProfileInfoStatePublisher: CurrentValueSubject<UserProfileState, Never> = .init(.loading)
    var userConnection: UserConnection?

    var showFriendRequestAlert: (() -> Void)?
    var shouldCloseUserProfile: (() -> Void)?

    private var cancellables = Set<AnyCancellable>()

    init(userBasicInfo: UserBasicInfo) {
        self.userBasicInfo = userBasicInfo

        self.setupPublishers()

        self.getUserProfileInfo()

        self.getUserConnections()
    }

    private func setupPublishers() {

        Env.gomaSocialClient.followingUsersPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] followingUsers in
                self?.checkFollowingUser(followingUsers: followingUsers)
            })
            .store(in: &cancellables)

    }

    private func checkFollowingUser(followingUsers: [Follower]) {
        let userId = self.userBasicInfo.userId

        let followUserId = followingUsers.filter({
            "\($0.id)" == userId
        })

        if let loggedUserId = Env.gomaNetworkClient.getCurrentToken()?.userId {

            if followUserId.isNotEmpty || userId == "\(loggedUserId)" {
                self.isFollowingUser.send(true)
            }
            else {
                self.isFollowingUser.send(false)
            }
        }
        else {
            self.isFollowingUser.send(false)
        }
    }

    private func checkFriendUser() {
        let userId = self.userBasicInfo.userId

        Env.gomaNetworkClient.requestFriends(deviceId: Env.deviceId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("FRIENDS ERROR: \(error)")
                case .finished:
                    print("FRIENDS FINISHED")
                }

            }, receiveValue: { [weak self] response in

                if let friends = response.data {
                    let friendUserId = friends.filter({
                        "\($0.id)" == userId
                    })

                    if friendUserId.isNotEmpty {
                        self?.isFriendUser.send(true)
                    }
                    else {
                        self?.isFriendUser.send(false)
                    }
                }
            })
            .store(in: &cancellables)

    }

    private func getUserProfileInfo() {
        let userId = self.userBasicInfo.userId

        Env.gomaNetworkClient.getUserProfileInfo(deviceId: Env.deviceId, userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("USER PROFILE ERROR: \(error)")
                    self?.userProfileInfoStatePublisher.send(.failed)
                case .finished:
                    print("USER PROFILE FINISHED")
                }

            }, receiveValue: { [weak self] userProfileInfo in

                self?.userProfileInfo = userProfileInfo

                self?.configureUserProfileInfo(userProfileInfo: userProfileInfo)

                self?.userProfileInfoStatePublisher.send(.loaded)

            })
            .store(in: &cancellables)
    }

    func followUser() {

        let userId = self.userBasicInfo.userId

        Env.gomaNetworkClient.followUser(deviceId: Env.deviceId, userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("FOLLOW USER ERROR: \(error)")
                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] _ in
                Env.gomaSocialClient.getFollowingUsers()
            })
            .store(in: &cancellables)
    }

    func deleteFollowUser() {

        let userId = self.userBasicInfo.userId

        Env.gomaNetworkClient.deleteFollowUser(deviceId: Env.deviceId, userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("DELETE FOLLOW USER ERROR: \(error)")
                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] _ in
                Env.gomaSocialClient.getFollowingUsers()
            })
            .store(in: &cancellables)
    }

    func addFriendRequest() {
        let userId = self.userBasicInfo.userId

        Env.gomaNetworkClient.addFriendRequest(deviceId: Env.deviceId, userIds: [userId], request: true)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("ADD FRIEND REQUEST ERROR: \(error)")
                case .finished:
                    print("ADD FRIEND REQUEST FINISHED")
                }

            }, receiveValue: { [weak self] _ in
                self?.showFriendRequestAlert?()
            })
            .store(in: &cancellables)
    }

    func unfriendUser() {
        if let userId = Int(self.userBasicInfo.userId) {

            Env.gomaNetworkClient.deleteFriend(deviceId: Env.deviceId, userId: userId)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        print("DELETE FRIEND ERROR: \(error)")
                    case .finished:
                        ()
                    }

                }, receiveValue: { [weak self] _ in
                    self?.shouldCloseUserProfile?()
                })
                .store(in: &cancellables)
        }

    }

    private func getUserConnections() {
        let userId = self.userBasicInfo.userId

        Env.gomaNetworkClient.getUserConnections(deviceId: Env.deviceId, userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("USER CONNECTIONS ERROR: \(error)")
                case .finished:
                    ()
                }

            }, receiveValue: { [weak self] response in
                if let userConnection = response.data {
                    self?.userConnection = userConnection
                    self?.configureUserConnections(userConnection: userConnection)
                }
            })
            .store(in: &cancellables)

    }

    private func configureUserProfileInfo(userProfileInfo: UserProfileInfo) {
        let followers = "\(userProfileInfo.followers)"
        let following = "\(userProfileInfo.following)"

        self.followersCountPublisher.send(followers)

        self.followingCountPublisher.send(following)

    }

    private func configureUserConnections(userConnection: UserConnection) {

        let isFriend = userConnection.friends == 1 ? true : false
        self.isFriendUser.send(isFriend)

        let isFriendRequestPending = userConnection.friendRequest == 1 ? true : false
        self.isFriendRequestPending.send(isFriendRequestPending)
    }

    func getUserId() -> String {
        return self.userBasicInfo.userId
    }
}
