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
    var userChatroomId: Int?

    var showFriendRequestAlert: (() -> Void)?
    var shouldCloseUserProfile: (() -> Void)?

    private var cancellables = Set<AnyCancellable>()

    init(userBasicInfo: UserBasicInfo) {
        self.userBasicInfo = userBasicInfo

        self.setupPublishers()

        self.getUserProfileInfo()

        self.getUserConnections()
        self.checkFriendUser()
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

        if let loggedUserId = Env.userSessionStore.userProfilePublisher.value?.userIdentifier {

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

        Env.servicesProvider.getFriends()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("FRIENDS ERROR: \(error)")
                case .finished:
                    print("FRIENDS FINISHED")
                }
                
            }, receiveValue: { [weak self] friends in
                
                let friendUserId = friends.filter({
                    "\($0.id)" == userId
                })
                
                if friendUserId.isNotEmpty {
                    self?.isFriendUser.send(true)
                }
                else {
                    self?.isFriendUser.send(false)
                }
                
            })
        
            .store(in: &cancellables)

    }

    private func getUserProfileInfo() {
        let userId = self.userBasicInfo.userId
        
        Env.servicesProvider.getUserProfileInfo(userId: userId)
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

                let mappedUserProfileInfo = ServiceProviderModelMapper.userProfileInfo(fromServiceProviderUserProfileInfo: userProfileInfo)
                
                self?.userProfileInfo = mappedUserProfileInfo

                self?.configureUserProfileInfo(userProfileInfo: mappedUserProfileInfo)

                self?.userProfileInfoStatePublisher.send(.loaded)

            })
            .store(in: &cancellables)
    }

    func followUser() {

        let userId = self.userBasicInfo.userId

        Env.servicesProvider.addFollowee(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("FOLLOW USER ERROR: \(error)")
                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] response in
                print("FOLLOW USER RESPONSE: \(response)")
                Env.gomaSocialClient.getFollowingUsers()
            })
            .store(in: &cancellables)
    }

    func unfollowUser() {

        let userId = self.userBasicInfo.userId
        
        Env.servicesProvider.removeFollowee(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("UNFOLLOW USER ERROR: \(error)")
                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] response in
                print("UNFOLLOW USER RESPONSE: \(response)")
                Env.gomaSocialClient.getFollowingUsers()
            })
            .store(in: &cancellables)
    }

    func addFriendRequest() {
        let userId = self.userBasicInfo.userId

        Env.servicesProvider.addFriends(userIds: [userId], request: true)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("ADD FRIEND ERROR: \(error)")
                case .finished:
                    print("ADD FRIEND FINISHED")
                }

            }, receiveValue: { [weak self] addFriendResponse in
                print("ADD FRIEND GOMA: \(addFriendResponse)")
                self?.showFriendRequestAlert?()
                
            })
            .store(in: &cancellables)
        
    }

    func unfriendUser() {
        if let userId = Int(self.userBasicInfo.userId) {

            Env.servicesProvider.removeFriend(userId: userId)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        print("DELETE FRIEND ERROR: \(error)")
                    case .finished:
                        ()
                    }

                }, receiveValue: { [weak self] response in
                    self?.shouldCloseUserProfile?()
                })
                .store(in: &cancellables)
            
//            Env.gomaNetworkClient.deleteFriend(deviceId: Env.deviceId, userId: userId)
//                .receive(on: DispatchQueue.main)
//                .sink(receiveCompletion: { [weak self] completion in
//                    switch completion {
//                    case .failure(let error):
//                        print("DELETE FRIEND ERROR: \(error)")
//                    case .finished:
//                        ()
//                    }
//
//                }, receiveValue: { [weak self] response in
//                    self?.shouldCloseUserProfile?()
//                })
//                .store(in: &cancellables)
        }

    }

    private func getUserConnections() {
        let userId = self.userBasicInfo.userId
        
        Env.servicesProvider.getChatrooms()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("CHATROOMS CONNECTIONS ERROR: \(error)")
                case .finished:
                    ()
                }
                
            }, receiveValue: { [weak self] chatroomsData in
                
                let mappedChatroomsData = chatroomsData.map({
                    return ServiceProviderModelMapper.chatroomData(fromServiceProviderChatroomData: $0)
                })
                
                if let userIdInt = Int(userId) {
                    let userChatId = mappedChatroomsData.filter({
                        $0.chatroom.type == "individual" &&
                        $0.users.contains(where: {
                            $0.id == userIdInt
                        })
                    }).first
                    
                    self?.userChatroomId = userChatId?.chatroom.id
                }
                
            })
            .store(in: &cancellables)
        
        //        Env.gomaNetworkClient.getUserConnections(deviceId: Env.deviceId, userId: userId)
        //            .receive(on: DispatchQueue.main)
        //            .sink(receiveCompletion: { [weak self] completion in
        //                switch completion {
        //                case .failure(let error):
        //                    print("USER CONNECTIONS ERROR: \(error)")
        //                case .finished:
        //                    ()
        //                }
        //
        //            }, receiveValue: { [weak self] response in
        //                if let userConnection = response.data {
        //                    self?.userConnection = userConnection
        //                    self?.configureUserConnections(userConnection: userConnection)
        //                }
        //            })
        //            .store(in: &cancellables)
        
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
