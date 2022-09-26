//
//  GomaGamingServiceClient.swift
//  Sportsbook
//
//  Created by Ruben Roques on 27/08/2021.
//

import Foundation
import Combine

class GomaGamingServiceClient {

    private var networkClient: NetworkManager
    
    init(networkClient: NetworkManager = NetworkManager()) {
        self.networkClient = networkClient
    }

    func reconnectSession() {
        self.networkClient = NetworkManager()
    }

    func refreshAuthToken(token: AuthToken) {
        self.networkClient.refreshAuthToken(token: token)
    }

    func getCurrentToken() -> AuthToken? {
        return self.networkClient.getCurrentToken()
    }

    func sendLog(type: String, message: String) -> AnyPublisher<String, NetworkError> {
        let endpoint = GomaGamingService.log(type: type, message: message)
        let requestPublisher: AnyPublisher<String, NetworkError> = networkClient.requestEndpoint(deviceId: "logs", endpoint: endpoint)
        return requestPublisher
    }

    func requestTest(deviceId: String) -> AnyPublisher<ExampleModel?, NetworkError> {
        let endpoint = GomaGamingService.test
        let requestPublisher: AnyPublisher<ExampleModel?, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func requestGeoLocation(deviceId: String, latitude: Double, longitude: Double) -> AnyPublisher<Bool, NetworkError> {
        let accessGrantedMessage = "User Access Granted!".lowercased()
        let endpoint = GomaGamingService.geolocation(latitude: String(latitude), longitude: String(longitude))
        let requestPublisher: AnyPublisher<MessageNetworkResponse, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)

        return requestPublisher
            .catch { (error: NetworkError) -> AnyPublisher<MessageNetworkResponse, NetworkError> in
                if error.errors.contains(.forbidden) {
                    return Just(MessageNetworkResponse.forbiden)
                        .setFailureType(to: NetworkError.self)
                        .eraseToAnyPublisher()
                }
                else {
                    return Fail(outputType: MessageNetworkResponse.self, failure: error)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
            .map { simpleResponse -> Bool in
                return simpleResponse.message.lowercased() == accessGrantedMessage
            }
            .eraseToAnyPublisher()

    }

    func requestSettings(deviceId: String) -> AnyPublisher<[GomaClientSettings]?, NetworkError> {
        let endpoint = GomaGamingService.settings
        let requestPublisher: AnyPublisher<[GomaClientSettings]?, NetworkError> = networkClient.requestEndpointArrayData(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func requestPopUpInfo(deviceId: String) -> AnyPublisher<PopUpDetails?, Never> {
        let endpoint = GomaGamingService.modalPopUpDetails
        let requestPublisher: AnyPublisher<PopUpDetails?, Never> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
            .replaceError(with: nil)
            .eraseToAnyPublisher()
        return requestPublisher
    }

    func requestUserRegister(deviceId: String, userRegisterForm: UserRegisterForm) -> AnyPublisher<MessageNetworkResponse, NetworkError> {
        let endpoint = GomaGamingService.simpleRegister(username: userRegisterForm.username,
                                                        email: userRegisterForm.email,
                                                        phoneCountryCode: userRegisterForm.mobilePrefix,
                                                        phone: userRegisterForm.mobile,
                                                        birthDate: userRegisterForm.birthDate,
                                                        userProviderId: userRegisterForm.userProviderId,
                                                        deviceToken: userRegisterForm.deviceToken)

        let requestPublisher: AnyPublisher<MessageNetworkResponse, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func requestLogin(deviceId: String, loginForm: UserLoginForm) -> AnyPublisher<AuthToken, NetworkError> {
        let endpoint = GomaGamingService.login(username: loginForm.username,
                                               password: loginForm.password,
                                               deviceToken: loginForm.deviceToken)
        let requestPublisher: AnyPublisher<AuthToken, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }
    
    func requestUpdateNameProfile(name: String) -> AnyPublisher<MessageNetworkResponse, NetworkError> {
          let endpoint = GomaGamingService.updateProfile(name: name)

          let requestPublisher: AnyPublisher<MessageNetworkResponse, NetworkError> = networkClient.requestEndpoint(deviceId: name, endpoint: endpoint)
          return requestPublisher
      }

    // TODO: Code Review -
    func requestSuggestedBets(deviceId: String) -> AnyPublisher<[[SuggestedBetSummary]]?, NetworkError> {
        let endpoint = GomaGamingService.suggestedBets
        let requestPublisher: AnyPublisher<[[SuggestedBetSummary]]?, NetworkError> = networkClient.requestEndpointArrayData(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func addFavorites(deviceId: String, favorites: String) -> AnyPublisher<MessageNetworkResponse, NetworkError> {
        let endpoint = GomaGamingService.addFavorites(favorites: favorites)
        let requestPublisher: AnyPublisher<MessageNetworkResponse, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func removeFavorite(deviceId: String, favorite: String) -> AnyPublisher<MessageNetworkResponse, NetworkError> {
        let endpoint = GomaGamingService.removeFavorite(favorite: favorite)
        let requestPublisher: AnyPublisher<MessageNetworkResponse, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func requestMatchStats(deviceId: String, matchId: String) -> AnyPublisher<JSON, NetworkError> {
        let endpoint = GomaGamingService.matchStats(matchId: matchId)
        let requestPublisher: AnyPublisher<JSON, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func requestUserSettings(deviceId: String) -> AnyPublisher<UserSettingsGomaResponse, NetworkError> {
        let endpoint = GomaGamingService.userSettings
        let requestPublisher: AnyPublisher<UserSettingsGomaResponse, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func requestBusinessModules(deviceId: String) -> AnyPublisher<BusinessModules, NetworkError> {
        let endpoint = GomaGamingService.modules
        let requestPublisher: AnyPublisher<BusinessModules, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func requestBusinessInstanceSettings(deviceId: String) -> AnyPublisher<BusinessInstanceSettingsResponse, NetworkError> {
        let endpoint = GomaGamingService.userSettings
        let requestPublisher: AnyPublisher<BusinessInstanceSettingsResponse, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func sendUserSettings(deviceId: String, userSettings: UserSettingsGoma) -> AnyPublisher<JSON, NetworkError> {
        let endpoint = GomaGamingService.sendUserSettings(userSettings: userSettings)
        let requestPublisher: AnyPublisher<JSON, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    // Social
    func addFriends(deviceId: String, userIds: [String]) -> AnyPublisher<NetworkResponse<AddFriendResponse>, NetworkError> {
        let endpoint = GomaGamingService.addFriend(userIds: userIds)
        let requestPublisher: AnyPublisher<NetworkResponse<AddFriendResponse>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func deleteFriend(deviceId: String, userId: Int) -> AnyPublisher<NetworkResponse<[String]>, NetworkError> {
        let endpoint = GomaGamingService.deleteFriend(userId: userId)
        let requestPublisher: AnyPublisher<NetworkResponse<[String]>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func requestFriends(deviceId: String) -> AnyPublisher<NetworkResponse<[GomaFriend]>, NetworkError> {
        let endpoint = GomaGamingService.listFriends
        let requestPublisher: AnyPublisher<NetworkResponse<[GomaFriend]>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func requestChatrooms(deviceId: String, page: Int) -> AnyPublisher<NetworkResponse<[ChatroomData]>, NetworkError> {
        let endpoint = GomaGamingService.chatrooms(page: "\(page)")
        let requestPublisher: AnyPublisher<NetworkResponse<[ChatroomData]>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func addGroup(deviceId: String, userIds: [String], groupName: String) -> AnyPublisher<NetworkResponse<ChatroomId>, NetworkError> {
        let endpoint = GomaGamingService.addGroup(userIds: userIds, groupName: groupName)
        let requestPublisher: AnyPublisher<NetworkResponse<ChatroomId>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func deleteGroup(deviceId: String, chatroomId: Int) -> AnyPublisher<NetworkResponse<[String]>, NetworkError> {
        let endpoint = GomaGamingService.deleteGroup(chatroomId: chatroomId)
        let requestPublisher: AnyPublisher<NetworkResponse<[String]>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func editGroup(deviceId: String, chatroomId: Int, groupName: String) -> AnyPublisher<NetworkResponse<[JSON]>, NetworkError> {
        let endpoint = GomaGamingService.editGroup(chatroomId: chatroomId, groupName: groupName)
        let requestPublisher: AnyPublisher<NetworkResponse<[JSON]>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func leaveGroup(deviceId: String, chatroomId: Int) -> AnyPublisher<NetworkResponse<[String]>, NetworkError> {
        let endpoint = GomaGamingService.leaveGroup(chatroomId: chatroomId)
        let requestPublisher: AnyPublisher<NetworkResponse<[String]>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func lookupPhones(deviceId: String, phones: [String]) -> AnyPublisher<[GomaContact], NetworkError> {
        let endpoint = GomaGamingService.lookupPhone(phones: phones)
        let requestPublisher: AnyPublisher<[GomaContact], NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func inviteFriend(deviceId: String, phone: String) -> AnyPublisher<NetworkResponse<[String]>, NetworkError> {
        let endpoint = GomaGamingService.inviteFriend(phone: phone)
        let requestPublisher: AnyPublisher<NetworkResponse<[String]>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func removeUser(deviceId: String, chatroomId: Int, userId: String) -> AnyPublisher<JSON, NetworkError> {
        let endpoint = GomaGamingService.removeUser(chatroomId: chatroomId, userId: userId)
        let requestPublisher: AnyPublisher<JSON, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func addUserToGroup(deviceId: String, chatroomId: Int, userIds: [String]) -> AnyPublisher<NetworkResponse<[JSON]>, NetworkError> {
        let endpoint = GomaGamingService.addUserToGroup(chatroomId: chatroomId, userIds: userIds)
        let requestPublisher: AnyPublisher<NetworkResponse<[JSON]>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func searchUserCode(deviceId: String, code: String) -> AnyPublisher<SearchUser, NetworkError> {
        let endpoint = GomaGamingService.searchUserCode(code: code)
        let requestPublisher: AnyPublisher<SearchUser, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func requestNotifications(deviceId: String, type: NotificationsType, page: Int) -> AnyPublisher<NetworkResponse<[ChatNotification]>, NetworkError> {
        let endpoint = GomaGamingService.getNotification(type: type.identifier, page: page)
        let requestPublisher: AnyPublisher<NetworkResponse<[ChatNotification]>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func setNotificationRead(deviceId: String, notificationId: String) ->
    AnyPublisher<NetworkResponse<[JSON]>, NetworkError> {
        let endpoint = GomaGamingService.setNotificationRead(id: notificationId)
        let requestPublisher: AnyPublisher<NetworkResponse<[JSON]>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func setAllNotificationRead(deviceId: String, notificationType: NotificationsType) ->
    AnyPublisher<NetworkResponse<[JSON]>, NetworkError> {
        let endpoint = GomaGamingService.setAllNotificationRead(type: notificationType.identifier)
        let requestPublisher: AnyPublisher<NetworkResponse<[JSON]>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func sendSupportTicket(deviceId: String, title: String, message: String) -> AnyPublisher<SupportTicketResponse, NetworkError> {
        let endpoint = GomaGamingService.sendSupportTicket(title: title, message: message)
        let requestPublisher: AnyPublisher<SupportTicketResponse, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func getNotificationCounter(deviceId: String, notificationType: NotificationsType) -> AnyPublisher<NetworkResponse<Int>, NetworkError> {
        let endpoint = GomaGamingService.notificationsCounter(type: notificationType.identifier)
        let requestPublisher: AnyPublisher<NetworkResponse<Int>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func requestNewsNotifications(deviceId: String, page: Int) -> AnyPublisher<NetworkResponse<[InAppMessage]>, NetworkError> {
        let endpoint = GomaGamingService.getNotification(type: NotificationsType.news.identifier, page: page)
        let requestPublisher: AnyPublisher<NetworkResponse<[InAppMessage]>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func requestFeaturedTips(deviceId: String,
                             betType: String? = nil,
                             totalOddsMin: String? = nil,
                             totalOddsMax: String? = nil,
                             friends: Bool? = nil,
                             followers: Bool? = nil,
                             topTips: Bool? = nil,
                             userIds: [String]? = nil) -> AnyPublisher<NetworkResponse<[FeaturedTip]>, NetworkError> {
        let endpoint = GomaGamingService.featuredTips(betType: betType, totalOddsMin: totalOddsMin, totalOddsMax: totalOddsMax,
                                                      friends: friends, followers: followers, topTips: topTips,
                                                      userIds: userIds)
        let requestPublisher: AnyPublisher<NetworkResponse<[FeaturedTip]>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
                
        return requestPublisher
    }

    func requestRankingsTips(deviceId: String,
                             type: String? = nil,
                             friends: Bool? = nil,
                             followers: Bool? = nil) -> AnyPublisher<NetworkResponse<[RankingTip]>, NetworkError> {
        let endpoint = GomaGamingService.rankingsTips(type: type, friends: friends, followers: followers)
        let requestPublisher: AnyPublisher<NetworkResponse<[RankingTip]>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)

        return requestPublisher
    }

    func getFollowers(deviceId: String) -> AnyPublisher<NetworkResponse<[Follower]>, NetworkError> {
        let endpoint = GomaGamingService.getFollowers
        let requestPublisher: AnyPublisher<NetworkResponse<[Follower]>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func getFollowingUsers(deviceId: String) -> AnyPublisher<NetworkResponse<[Follower]>, NetworkError> {
        let endpoint = GomaGamingService.getFollowingUsers
        let requestPublisher: AnyPublisher<NetworkResponse<[Follower]>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func followUser(deviceId: String, userId: String) ->
    AnyPublisher<NetworkResponse<UsersFollowedResponse>, NetworkError> {
        let endpoint = GomaGamingService.followUser(userId: userId)
        let requestPublisher: AnyPublisher<NetworkResponse<UsersFollowedResponse>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func deleteFollowUser(deviceId: String, userId: String) -> AnyPublisher<NetworkResponse<[String]?>, NetworkError> {
        let endpoint = GomaGamingService.deleteFollowUser(userId: userId)
        let requestPublisher: AnyPublisher<NetworkResponse<[String]?>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func getFollowingTotalUsers(deviceId: String) -> AnyPublisher<NetworkResponse<String>, NetworkError> {
        let endpoint = GomaGamingService.getFollowingTotalUsers
        let requestPublisher: AnyPublisher<NetworkResponse<String>, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func getUserProfileInfo(deviceId: String, userId: String) -> AnyPublisher<UserProfileInfo, NetworkError> {
        let endpoint = GomaGamingService.getUserProfileInfo(userId: userId)
        let requestPublisher: AnyPublisher<UserProfileInfo, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }
}
