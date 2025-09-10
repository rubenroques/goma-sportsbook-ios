//
//  GomaProvider.swift
//
//
//  Created by Ruben Roques on 12/12/2023.
//

import Foundation
import Combine
import SharedModels

class GomaProvider {

    var connector: GomaConnector

    private let sessionStateSubject: CurrentValueSubject<UserSessionStatus, Error> = .init(.anonymous)
    private let userProfileSubject: CurrentValueSubject<UserProfile?, Error> = .init(nil)

    //Paginators cache
    private var paginatorsCache: [String: GomaEventPaginator<GomaModels.Event>] = [:]

    private var cancellables: Set<AnyCancellable> = []

    convenience init(deviceIdentifier: String) {
        self.init(connector: GomaConnector(deviceIdentifier: deviceIdentifier))
    }
    
    init(connector: GomaConnector) {
        self.connector = connector
    }

}

extension GomaProvider: PrivilegedAccessManagerProvider {

    var sessionStatePublisher: AnyPublisher<UserSessionStatus, Error> {
        return self.sessionStateSubject.eraseToAnyPublisher()
    }

    var userProfilePublisher: AnyPublisher<UserProfile?, Error> {
        return self.userProfileSubject.eraseToAnyPublisher()
    }
    
    var accessToken: String? {
        return self.connector.authenticator.getToken()
    }

    var hasSecurityQuestions: Bool {
        return false
    }
    
    func login(username: String, password: String) -> AnyPublisher<UserProfile, ServiceProviderError> {
        let endpoint = GomaAPISchema.login(username: username,
                                           password: password,
                                           pushToken: self.connector.getPushNotificationToken())

        let publisher: AnyPublisher<GomaModels.LoginResponse, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .handleEvents(receiveOutput: { [weak self] response in
                self?.connector.updateToken(newToken: response.data.token)
            })
            .map({ loginResponse in
            let mappedLoginResponse = GomaModelMapper.loginResponse(fromInternalLoginResponse: loginResponse)
            return mappedLoginResponse.userProfile
        }).eraseToAnyPublisher()
    }
    
    func updateUserProfile(form: UpdateUserProfileForm) -> AnyPublisher<Bool, ServiceProviderError> {

        let endpoint = GomaAPISchema.updatePersonalInfo(fullname: form.firstName ?? "", avatar: form.avatar ?? "")

        let publisher: AnyPublisher<String, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ statusResponse -> AnyPublisher<Bool, ServiceProviderError> in

            return Just(true).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()

//        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func checkEmailRegistered(_ email: String) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func validateUsername(_ username: String) -> AnyPublisher<UsernameValidation, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func signUp(with formType: SignUpFormType) -> AnyPublisher<SignUpResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func updateExtraInfo(placeOfBirth: String?, address2: String?) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func updateDeviceIdentifier(deviceIdentifier: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        self.connector.updatePushNotificationToken(newToken: deviceIdentifier)
        return Just(BasicResponse(status: "ok")).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
    }

    func getAllCountries() -> AnyPublisher<[SharedModels.Country], ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func getCountries() -> AnyPublisher<[SharedModels.Country], ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func getCurrentCountry() -> AnyPublisher<SharedModels.Country?, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func signupConfirmation(_ email: String, confirmationCode: String) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func forgotPassword(email: String, secretQuestion: String?, secretAnswer: String?) -> AnyPublisher<Bool, ServiceProviderError> {
        let endpoint: GomaAPISchema = GomaAPISchema.requestPasswordResetEmail(email: email)
        let publisher: AnyPublisher<BasicMessageResponse, ServiceProviderError> = self.connector.request(endpoint)
        return publisher.map({ basicMessageResponse -> Bool in
            return basicMessageResponse.message.lowercased().contains("reset link sent")
        }).eraseToAnyPublisher()
    }

    func updatePassword(oldPassword: String, newPassword: String) -> AnyPublisher<Bool, ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.updatePassword(oldPassword: oldPassword, password: newPassword, passwordConfirmation: newPassword)
        let publisher: AnyPublisher<BasicMessageResponse, ServiceProviderError> = self.connector.request(endpoint)
        return publisher.map({ basicMessageResponse -> Bool in
            return basicMessageResponse.message.lowercased().contains("successfully")
        }).eraseToAnyPublisher()

    }

    func getPasswordPolicy() -> AnyPublisher<PasswordPolicy, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func updateWeeklyDepositLimits(newLimit: Double) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func updateWeeklyBettingLimits(newLimit: Double) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func updateResponsibleGamingLimits(newLimit: Double) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func getPersonalDepositLimits() -> AnyPublisher<PersonalDepositLimitResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func getLimits() -> AnyPublisher<LimitsResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func lockPlayer(isPermanent: Bool?, lockPeriodUnit: String?, lockPeriod: String?) -> AnyPublisher<BasicResponse, ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.closeAccount

        let publisher: AnyPublisher<String, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.map({ closeAccountResponse in
            let basicResponse = BasicResponse(status: "success", message: closeAccountResponse)
            return basicResponse
        }).eraseToAnyPublisher()
    }

    func getUserBalance() -> AnyPublisher<UserWallet, ServiceProviderError> {
        let endpoint: GomaAPISchema = GomaAPISchema.getUserWallet
        let publisher: AnyPublisher<GomaModels.UserWallet, ServiceProviderError> = self.connector.request(endpoint)
        return publisher.map({ userWallet in
            let total = userWallet.balance + userWallet.freeBalance
            let wallet = UserWallet(vipStatus: nil,
                                    currency: "EUR",
                                    loyaltyPoint: nil,
                                    totalString: nil,
                                    total: total,
                                    withdrawableString: nil,
                                    withdrawable: userWallet.balance,
                                    bonusString: nil,
                                    bonus: userWallet.freeBalance,
                                    pendingBonusString: nil,
                                    pendingBonus: nil,
                                    casinoPlayableBonusString: nil,
                                    casinoPlayableBonus: nil,
                                    sportsbookPlayableBonusString: nil,
                                    sportsbookPlayableBonus: nil,
                                    withdrawableEscrowString: nil,
                                    withdrawableEscrow: nil,
                                    totalWithdrawableString: nil,
                                    totalWithdrawable: nil,
                                    withdrawRestrictionAmountString: nil,
                                    withdrawRestrictionAmount: nil,
                                    totalEscrowString: nil,
                                    totalEscrow: nil)
            return wallet
        }).eraseToAnyPublisher()
    }

    func getUserCashbackBalance() -> AnyPublisher<CashbackBalance, ServiceProviderError> {
        let endpoint: GomaAPISchema = GomaAPISchema.getUserWallet
        let publisher: AnyPublisher<GomaModels.UserWallet, ServiceProviderError> = self.connector.request(endpoint)
        return publisher.map({ userWallet in
            let wallet = CashbackBalance(status: "", balance: "\(userWallet.cashbackBalance)", message: nil)
            return wallet
        }).eraseToAnyPublisher()
    }

    func depositOnWallet(amount: Double) -> AnyPublisher<Bool, ServiceProviderError> {
        let endpoint: GomaAPISchema = GomaAPISchema.addAmoutToUserWallet(amount: amount)
        let publisher: AnyPublisher<GomaModels.UserWallet, ServiceProviderError> = self.connector.request(endpoint)
        return publisher.map({ wallet in
            return true
        }).eraseToAnyPublisher()
    }

    func signUpCompletion(form: UpdateUserProfileForm) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func getDocumentTypes() -> AnyPublisher<DocumentTypesResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func getUserDocuments() -> AnyPublisher<UserDocumentsResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func uploadUserDocument(documentType: String, file: Data, fileName: String) -> AnyPublisher<UploadDocumentResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func uploadMultipleUserDocuments(documentType: String, files: [String: Data]) -> AnyPublisher<UploadDocumentResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func getPayments() -> AnyPublisher<SimplePaymentMethodsResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func processDeposit(paymentMethod: String, amount: Double, option: String) -> AnyPublisher<ProcessDepositResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func cancelDeposit(paymentId: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func checkPaymentStatus(paymentMethod: String, paymentId: String) -> AnyPublisher<PaymentStatusResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func getWithdrawalMethods() -> AnyPublisher<[WithdrawalMethod], ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func getPendingWithdrawals() -> AnyPublisher<[PendingWithdrawal], ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func cancelWithdrawal(paymentId: Int) -> AnyPublisher<CancelWithdrawalResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func getPaymentInformation() -> AnyPublisher<PaymentInformation, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func addPaymentInformation(type: String, fields: String) -> AnyPublisher<AddPaymentInformationResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func getTransactionsHistory(startDate: String, endDate: String, transactionTypes: [TransactionType]?, pageNumber: Int?) -> AnyPublisher<[TransactionDetail], ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func getGrantedBonuses() -> AnyPublisher<[GrantedBonus], ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func redeemBonus(code: String) -> AnyPublisher<RedeemBonusResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func getAvailableBonuses() -> AnyPublisher<[AvailableBonus], ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func redeemAvailableBonus(partyId: String, code: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func cancelBonus(bonusId: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func optOutBonus(partyId: String, code: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

    func getAllConsents() -> AnyPublisher<[ConsentInfo], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getUserConsents() -> AnyPublisher<[UserConsent], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func setUserConsents(consentVersionIds: [Int]?, unconsenVersionIds: [Int]?) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func generateDocumentTypeToken(docType: String) -> AnyPublisher<AccessTokenResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func checkDocumentationData() -> AnyPublisher<ApplicantDataResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getMobileVerificationCode(forMobileNumber mobileNumber: String) -> AnyPublisher<MobileVerifyResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func verifyMobileCode(code: String, requestId: String) -> AnyPublisher<MobileVerifyResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    //
    //
    func getUserProfile(withKycExpire: String?) -> AnyPublisher<UserProfile, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func updateDeviceIdentifier(deviceIdentifier: String, appVersion: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func updateResponsibleGamingLimits(newLimit: Double, limitType: String, hasRollingWeeklyLimits: Bool) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getResponsibleGamingLimits(periodTypes: String?, limitTypes: String?) -> AnyPublisher<ResponsibleGamingLimitsResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func updatePayment(amount: Double, paymentId: String, type: String, returnUrl: String?, nameOnCard: String?, encryptedExpiryYear: String?, encryptedExpiryMonth: String?, encryptedSecurityCode: String?, encryptedCardNumber: String?) -> AnyPublisher<UpdatePaymentResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func processWithdrawal(paymentMethod: String, amount: Double, conversionId: String?) -> AnyPublisher<ProcessWithdrawalResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func prepareWithdrawal(paymentMethod: String) -> AnyPublisher<PrepareWithdrawalResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getReferralLink() -> AnyPublisher<ReferralLink, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getReferees() -> AnyPublisher<[Referee], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    //
    //
    //
    func getFollowees() -> AnyPublisher<[Follower], ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.getFollowees

        let publisher: AnyPublisher<GomaModels.GomaResponse<GomaModels.FolloweesResponse>, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.map({ followeesResponse in

            let mappedFollowers = followeesResponse.data.followees.map( {

                return GomaModelMapper.follower(fromFollower: $0)
            })

            return mappedFollowers

        }).eraseToAnyPublisher()
    }

    func getTotalFollowees() -> AnyPublisher<Int, ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.getTotalFollowees

        let publisher: AnyPublisher<GomaModels.GomaResponse<GomaModels.TotalFolloweesResponse>, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.map({ totalFolloweesResponse in

            return totalFolloweesResponse.data.count

        }).eraseToAnyPublisher()
    }

    func getFollowers() -> AnyPublisher<[Follower], ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.getFollowers

        let publisher: AnyPublisher<GomaModels.GomaResponse<GomaModels.FollowersResponse>, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.map({ followersResponse in

            let mappedFollowers = followersResponse.data.followers.map( {

                return GomaModelMapper.follower(fromFollower: $0)
            })

            return mappedFollowers

        }).eraseToAnyPublisher()
    }

    func getTotalFollowers() -> AnyPublisher<Int, ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.getTotalFollowers

        let publisher: AnyPublisher<GomaModels.GomaResponse<GomaModels.TotalFollowersResponse>, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.map({ totalFollowersResponse in

            return totalFollowersResponse.data.count

        }).eraseToAnyPublisher()
    }

    func addFollowee(userId: String) -> AnyPublisher<[String], ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.addFollowee(userId: userId)

        let publisher: AnyPublisher<GomaModels.GomaResponse<GomaModels.FolloweeActionResponse>, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.map({ followeeActionResponse in

            let followeeIds = followeeActionResponse.data.followeeIds.map({
                return "\($0)"
            })

            return followeeIds

        }).eraseToAnyPublisher()
    }

    func removeFollowee(userId: String) -> AnyPublisher<[String], ServiceProviderError> {
        let endpoint: GomaAPISchema = GomaAPISchema.removeFollowee(userId: userId)
        let publisher: AnyPublisher<GomaModels.GomaResponse<GomaModels.FolloweeActionResponse>, ServiceProviderError> = self.connector.request(endpoint)
        return publisher.map({ followeeActionResponse in
            let followeeIds = followeeActionResponse.data.followeeIds.map({
                return "\($0)"
            })
            return followeeIds
        }).eraseToAnyPublisher()
    }

    func getTipsRankings(type: String?, followers: Bool?) -> AnyPublisher<[TipRanking], ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.getTipsRankings(type: type, followers: followers)

        let publisher: AnyPublisher<[GomaModels.TipRanking], ServiceProviderError> = self.connector.request(endpoint)

        return publisher.map({ tipsRankings in

            let mappedTipsRankings = tipsRankings.map( {

                return GomaModelMapper.tipRanking(fromTipRanking: $0)
            })

            return mappedTipsRankings

        }).eraseToAnyPublisher()
    }

    func getUserProfileInfo(userId: String) -> AnyPublisher<UserProfileInfo, ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.getUserProfile(userId: userId)

        let publisher: AnyPublisher<GomaModels.UserProfileInfo, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.map({ userProfileInfo in

            let mappedUserProfileInfo = GomaModelMapper.userProfileInfo(fromUserProfileInfo: userProfileInfo)

            return mappedUserProfileInfo

        }).eraseToAnyPublisher()
    }

    func getUserNotifications() -> AnyPublisher<UserNotificationsSettings, ServiceProviderError> {
        let endpoint: GomaAPISchema = GomaAPISchema.getUserNotificationsSettings
        let publisher: AnyPublisher<GomaModels.UserNotificationsSettings, ServiceProviderError> = self.connector.request(endpoint)
        return publisher.map(GomaModelMapper.userNotificationsSettings(fromInternalUserNotificationsSettings:)).eraseToAnyPublisher()
    }

    func updateUserNotifications(settings: UserNotificationsSettings) -> AnyPublisher<Bool, ServiceProviderError> {
        let settings = GomaModelMapper.internalUserNotificationsSettings(fromUserNotificationsSettings: settings)
        let endpoint: GomaAPISchema = GomaAPISchema.updateUserNotificationsSettings(settings: settings)
        let publisher: AnyPublisher<BasicResponse, ServiceProviderError> = self.connector.request(endpoint)
        return publisher.map({ response in
            return response.status.lowercased() == "success"
        }).eraseToAnyPublisher()
    }

    func getFriendRequests() -> AnyPublisher<[FriendRequest], ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.getFriendRequests

        let publisher: AnyPublisher<GomaModels.GomaResponse<[GomaModels.FriendRequest]>, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.map({ response in

            let friendRequests = response.data.map({
                return GomaModelMapper.friendRequest(fromFriendRequest: $0)
            })

            return friendRequests
        }).eraseToAnyPublisher()
    }

    func getFriends() -> AnyPublisher<[UserFriend], ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.getFriends

        let publisher: AnyPublisher<GomaModels.GomaResponse<[GomaModels.UserFriend]>, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.map({ response in

            let userFriends = response.data.map({
                return GomaModelMapper.userFriend(fromUserFriend: $0)
            })

            return userFriends
        }).eraseToAnyPublisher()
    }

    func addFriends(userIds: [String], request: Bool) -> AnyPublisher<AddFriendResponse, ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.addFriends(userIds: userIds, request: request)

        let publisher: AnyPublisher<GomaModels.GomaResponse<GomaModels.AddFriendResponse>, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.map({ response in

            let userFriends = GomaModelMapper.addFriendResponse(fromAddFriendResponse: response.data)

            return userFriends
        }).eraseToAnyPublisher()
    }

    func removeFriend(userId: Int) -> AnyPublisher<String, ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.removeFriend(userId: userId)

        let publisher: AnyPublisher<String, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.eraseToAnyPublisher()
    }

    func getChatrooms() -> AnyPublisher<[ChatroomData], ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.getChatrooms

        let publisher: AnyPublisher<GomaModels.GomaResponse<[GomaModels.ChatroomData]>, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.map({ response in

            let chatroomData = response.data.map({
                return GomaModelMapper.chatroomData(fromChatroomData: $0)
            })

            return chatroomData
        }).eraseToAnyPublisher()
    }

    func addGroup(name: String, userIds: [String]) -> AnyPublisher<ChatroomId, ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.addGroup(name: name, userIds: userIds)

        let publisher: AnyPublisher<GomaModels.GomaResponse<GomaModels.ChatroomId>, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.map({ response in

            let chatroomId = GomaModelMapper.chatroomId(fromChatroomId: response.data)

            return chatroomId
        }).eraseToAnyPublisher()
    }

    func deleteGroup(id: Int) -> AnyPublisher<String, ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.deleteGroup(id: id)

        let publisher: AnyPublisher<GomaModels.DeleteGroupResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.map({ response in

            return response.message ?? ""
        }).eraseToAnyPublisher()
    }

    func editGroup(id: Int, name: String) -> AnyPublisher<String, ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.editGroup(id: id, name: name)

        let publisher: AnyPublisher<String, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.eraseToAnyPublisher()
    }

    func leaveGroup(id: Int) -> AnyPublisher<String, ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.leaveGroup(id: id)

        let publisher: AnyPublisher<String, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.eraseToAnyPublisher()
    }

    func addUsersToGroup(groupId: Int, userIds: [String]) -> AnyPublisher<String, ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.addUsersFromGroup(groupId: groupId, userIds: userIds)

        let publisher: AnyPublisher<String, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.eraseToAnyPublisher()
    }

    func removeUsersToGroup(groupId: Int, userIds: [String]) -> AnyPublisher<String, ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.removeUsersFromGroup(groupId: groupId, userIds: userIds)

        let publisher: AnyPublisher<String, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.eraseToAnyPublisher()
    }

    func searchUserWithCode(code: String) -> AnyPublisher<SearchUser, ServiceProviderError> {

        let endpoint: GomaAPISchema = GomaAPISchema.searchUserWithCode(code: code)

        let publisher: AnyPublisher<GomaModels.SearchUser, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.map({ searchUser in

            let searchUser = GomaModelMapper.searchUser(fromSearchUser: searchUser)

            return searchUser
        }).eraseToAnyPublisher()
    }
    
    func getRegistrationConfig() -> AnyPublisher<RegistrationConfigResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
    }

    func getBankingWebView(parameters: CashierParameters) -> AnyPublisher<CashierWebViewResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
}

extension GomaProvider: EventsProvider {
   
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        return self.connector.connectionStatePublisher.eraseToAnyPublisher()
    }

    func reconnectIfNeeded() {

    }

    func subscribeLiveMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        guard
            let sportId = sportType.numericId
        else {
            return Fail(error: ServiceProviderError.incompletedSportData).eraseToAnyPublisher()
        }

        let paginatorId = "live-\(sportType)"

        if let paginator = self.paginatorsCache[paginatorId] {
            paginator.requestInitialPage()
            return paginator.eventsGroupPublisher.map({ events in
                let mappedEvents = GomaModelMapper.eventsGroup(fromInternalEvents: events)
                return SubscribableContent.contentUpdate(content: [mappedEvents])
            }).eraseToAnyPublisher()
        }
        else {
            let paginator = GomaEventPaginator<GomaModels.Event>(needsRefresh: true) { page in
                let endpoint: GomaAPISchema = GomaAPISchema.getLiveEvents(sportCode: sportId, page: page)
                let publisher: AnyPublisher<[GomaModels.Event], ServiceProviderError> = self.connector.request(endpoint)
                return publisher.eraseToAnyPublisher()
            }

            self.paginatorsCache[paginatorId] = paginator

            paginator.requestInitialPage()

            return paginator.eventsGroupPublisher.map({ events in
                let mappedEvents = GomaModelMapper.eventsGroup(fromInternalEvents: events)
                return SubscribableContent.contentUpdate(content: [mappedEvents])
            }).eraseToAnyPublisher()
        }
    }

    func requestLiveMatchesNextPage(forSportType sportType: SportType) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let sportId = sportType.numericId
        else {
            return Fail(error: ServiceProviderError.incompletedSportData).eraseToAnyPublisher()
        }

        let paginatorId = "live-\(sportType)"

        if let paginator = self.paginatorsCache[paginatorId] {
            paginator.requestNextPage()
            return paginator.hasNextPagePublisher.eraseToAnyPublisher()
        }
        else {
            let paginator = GomaEventPaginator<GomaModels.Event>(needsRefresh: true) { page in
                let endpoint: GomaAPISchema = GomaAPISchema.getLiveEvents(sportCode: sportId, page: page)
                let publisher: AnyPublisher<[GomaModels.Event], ServiceProviderError> = self.connector.request(endpoint)
                return publisher.eraseToAnyPublisher()
            }
            self.paginatorsCache[paginatorId] = paginator
            paginator.requestNextPage()
            return paginator.hasNextPagePublisher.eraseToAnyPublisher()
        }
    }

    func subscribePreLiveMatches(forSportType sportType: SportType, initialDate: Date?, endDate: Date?, eventCount: Int?, sortType: EventListSort) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {

        guard
            let sportId = sportType.numericId
        else {
            return Fail(error: ServiceProviderError.incompletedSportData).eraseToAnyPublisher()
        }

        let paginatorId = "preLive-\(sortType)-\(sportType)"

        if let paginator = self.paginatorsCache[paginatorId] {
            paginator.requestInitialPage()
            return paginator.eventsGroupPublisher.map({ events in
                let mappedEvents = GomaModelMapper.eventsGroup(fromInternalEvents: events)
                return SubscribableContent.contentUpdate(content: [mappedEvents])
            }).eraseToAnyPublisher()
        }
        else {
            let paginator = GomaEventPaginator<GomaModels.Event>(needsRefresh: false) { page in
                var endpoint = GomaAPISchema.getUpcomingEvents(sportCode: sportId, page: page)
                switch sortType {
                case .date:
                    endpoint = GomaAPISchema.getUpcomingEvents(sportCode: sportId, page: page)
                case .popular:
                    endpoint = GomaAPISchema.getTrendingEvents(sportCode: sportId, page: page)
                }

                let publisher: AnyPublisher<GomaModels.GomaPagedResponse<[GomaModels.Event]>, ServiceProviderError> = self.connector.request(endpoint)
                return publisher.map(\.data).eraseToAnyPublisher()
            }

            self.paginatorsCache[paginatorId] = paginator

            paginator.requestInitialPage()

            return paginator.eventsGroupPublisher.map({ events in
                let mappedEvents = GomaModelMapper.eventsGroup(fromInternalEvents: events)
                return SubscribableContent.contentUpdate(content: [mappedEvents])
            }).eraseToAnyPublisher()
        }
    }

    func requestPreLiveMatchesNextPage(forSportType sportType: SportType, initialDate: Date?, endDate: Date?, sortType: EventListSort) -> AnyPublisher<Bool, ServiceProviderError> {

        guard
            let sportId = sportType.numericId
        else {
            return Fail(error: ServiceProviderError.incompletedSportData).eraseToAnyPublisher()
        }

        let paginatorId = "preLive-\(sortType)-\(sportType)"

        if let paginator = self.paginatorsCache[paginatorId] {
            paginator.requestNextPage()
            return paginator.hasNextPagePublisher.eraseToAnyPublisher()
        }
        else {
            let paginator = GomaEventPaginator<GomaModels.Event>(needsRefresh: false) { page in
                var endpoint = GomaAPISchema.getUpcomingEvents(sportCode: sportId, page: page)
                switch sortType {
                case .date:
                    endpoint = GomaAPISchema.getUpcomingEvents(sportCode: sportId, page: page)
                case .popular:
                    endpoint = GomaAPISchema.getTrendingEvents(sportCode: sportId, page: page)
                }

                let publisher: AnyPublisher<GomaModels.GomaPagedResponse<[GomaModels.Event]>, ServiceProviderError> = self.connector.request(endpoint)
                return publisher.map(\.data).eraseToAnyPublisher()
            }
            self.paginatorsCache[paginatorId] = paginator
            paginator.requestNextPage()
            return paginator.hasNextPagePublisher.eraseToAnyPublisher()
        }

    }

    func subscribeEndedMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        guard
            let sportId = sportType.numericId
        else {
            return Fail(error: ServiceProviderError.incompletedSportData).eraseToAnyPublisher()
        }

        let paginatorId = "ended-\(sportType)"

        if let paginator = self.paginatorsCache[paginatorId] {
            paginator.requestInitialPage()
            return paginator.eventsGroupPublisher.map({ events in
                let mappedEvents = GomaModelMapper.eventsGroup(fromInternalEvents: events)
                return SubscribableContent.contentUpdate(content: [mappedEvents])
            }).eraseToAnyPublisher()
        }
        else {
            let paginator = GomaEventPaginator<GomaModels.Event>(needsRefresh: false) { page in
                let endpoint: GomaAPISchema = GomaAPISchema.getEndedEvents(sportCode: sportId, page: page)
                let publisher: AnyPublisher<GomaModels.GomaPagedResponse<[GomaModels.Event]>, ServiceProviderError> = self.connector.request(endpoint)
                return publisher.map(\.data).eraseToAnyPublisher()
            }

            self.paginatorsCache[paginatorId] = paginator

            paginator.requestInitialPage()

            return paginator.eventsGroupPublisher.map({ events in
                let mappedEvents = GomaModelMapper.eventsGroup(fromInternalEvents: events)
                return SubscribableContent.contentUpdate(content: [mappedEvents])
            }).eraseToAnyPublisher()
        }
    }

    func requestEndedMatchesNextPage(forSportType sportType: SportType) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let sportId = sportType.numericId
        else {
            return Fail(error: ServiceProviderError.incompletedSportData).eraseToAnyPublisher()
        }

        let paginatorId = "ended-\(sportType)"

        if let paginator = self.paginatorsCache[paginatorId] {
            paginator.requestNextPage()
            return paginator.hasNextPagePublisher.eraseToAnyPublisher()
        }
        else {
            let paginator = GomaEventPaginator<GomaModels.Event>(needsRefresh: false) { page in
                let endpoint: GomaAPISchema = GomaAPISchema.getLiveEvents(sportCode: sportId, page: page)
                let publisher: AnyPublisher<GomaModels.GomaPagedResponse<[GomaModels.Event]>, ServiceProviderError> = self.connector.request(endpoint)
                return publisher.map(\.data).eraseToAnyPublisher()
            }
            self.paginatorsCache[paginatorId] = paginator
            paginator.requestNextPage()
            return paginator.hasNextPagePublisher.eraseToAnyPublisher()
        }
    }
    
    func subscribeSportTypes() -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError> {
        let endpoint = GomaAPISchema.getSports
        let publisher: AnyPublisher<GomaModels.Sports, ServiceProviderError> = self.connector.request(endpoint)
        return publisher.map({ sports in
            return SubscribableContent.contentUpdate(content: GomaModelMapper.sportsType(fromSports:sports))
        }).eraseToAnyPublisher()
    }
    
    func subscribePopularTournaments(forSportType sportType: SportType, tournamentsCount: Int) -> AnyPublisher<SubscribableContent<[Tournament]>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func subscribeSportTournaments(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[Tournament]>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    // MARK: - Tournament RPC Methods
    
    func getPopularTournaments(forSportType sportType: SportType, tournamentsCount: Int) -> AnyPublisher<[Tournament], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getTournaments(forSportType sportType: SportType) -> AnyPublisher<[Tournament], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getEventGroup(withId eventGroupId: String) -> AnyPublisher<EventsGroup, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getHighlightedLiveEventsPointers(eventCount: Int, userId: String?) -> AnyPublisher<[String], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getPromotedBetslips(userId: String?) -> AnyPublisher<[PromotedBetslip], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    //
    //
    func subscribeOutrightEvent(forMarketGroupId marketGroupId: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func subscribeToEventOnListsLiveDataUpdates(withId id: String) -> AnyPublisher<Event?, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func subscribeToEventOnListsMarketUpdates(withId id: String) -> AnyPublisher<Market?, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func subscribeToEventOnListsOutcomeUpdates(withId id: String) -> AnyPublisher<Outcome?, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
   
    func getEventForMarketGroup(withId marketGroupId: String) -> AnyPublisher<Event, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getEventDetails(eventId: String) -> AnyPublisher<Event, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getEventSecundaryMarkets(eventId: String) -> AnyPublisher<Event, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getEventLiveData(eventId: String) -> AnyPublisher<EventLiveData, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func subscribeEventMarkets(eventId: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func subscribeToEventAndSecondaryMarkets(withId id: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getHighlightedLiveEvents(eventCount: Int, userId: String?) -> AnyPublisher<Events, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    

    //
    //
    //
    func subscribeCompetitionMatches(forMarketGroupId marketGroupId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        let endpoint: GomaAPISchema = GomaAPISchema.getEventsFromCompetition(competitionId: marketGroupId)
        let publisher: AnyPublisher<GomaModels.GomaPagedResponse<[GomaModels.Event]>, ServiceProviderError> = self.connector.request(endpoint)
        return publisher.map({ upcomingEventsResponse in
            let events = upcomingEventsResponse.data
            let liveSports = GomaModelMapper.eventsGroup(fromInternalEvents: events)
            return SubscribableContent.contentUpdate(content: [liveSports] )
        }).eraseToAnyPublisher()
    }

    func subscribeToMarketDetails(withId marketId: String, onEventId eventId: String) -> AnyPublisher<SubscribableContent<Market>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
    }

    func subscribeEventDetails(eventId: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        return self.getEventDetails(eventId: eventId, marketLimit: nil)
            .map { event -> SubscribableContent<Event> in
                return SubscribableContent.contentUpdate(content: event )
            }
            .eraseToAnyPublisher()
    }

    func subscribeEventSummary(eventId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
    }

    func subscribeOutrightMarkets(forMarketGroupId marketGroupId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
    }

    func subscribeToMarketGroups(eventId: String) -> AnyPublisher<SubscribableContent<[MarketGroup]>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
    }
    
    func subscribeToMarketGroupDetails(eventId: String, marketGroupKey: String) -> AnyPublisher<SubscribableContent<[Market]>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
    }
    

    func subscribeToLiveDataUpdates(forEventWithId id: String) -> AnyPublisher<SubscribableContent<EventLiveData>, ServiceProviderError> {
        let endpointDetails = GomaAPISchema.getEventDetails(identifier: id)
        let publisherDetails: AnyPublisher<GomaModels.Event, ServiceProviderError> = self.connector.request(endpointDetails)

        let subscription = Subscription.init(contentType: ContentType.eventDetails,
                                             contentRoute: ContentRoute.eventDetails(eventId: id),
                                             sessionToken: "",
                                             unsubscriber: GomaDummyUnsubscriber())

        return publisherDetails.map({ eventDetails -> SubscribableContent in
            let mappedEventStatus = GomaModelMapper.eventStatus(fromInternalEvent: eventDetails.status)
            let eventLiveData = EventLiveData(id: eventDetails.identifier,
                                              homeScore: eventDetails.homeScore,
                                              awayScore: eventDetails.awayScore,
                                              matchTime: eventDetails.matchTime,
                                              status: mappedEventStatus, detailedScores: [:], activePlayerServing: nil)
            return SubscribableContent.contentUpdate(content: eventLiveData)
        })
        .prepend(SubscribableContent.connected(subscription: subscription))
        .eraseToAnyPublisher()
    }

    func getMarketGroups(
        forEvent event: Event,
        includeMixMatchGroup: Bool,
        includeAllMarketsGroup: Bool
    ) -> AnyPublisher<[MarketGroup], Never> {
        let defaultMarketGroup = [MarketGroup.init(type: "0",
                                                   id: "0",
                                                   groupKey: "All Markets",
                                                   translatedName: "All Markets",
                                                   position: 0,
                                                   isDefault: true,
                                                   numberOfMarkets: nil,
                                                   loaded: true,
                                                   markets: event.markets)]
        return Just(defaultMarketGroup).eraseToAnyPublisher()
    }

    func getFieldWidgetId(eventId: String) -> AnyPublisher<FieldWidget, ServiceProviderError> {
        return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
    }

    func getFieldWidget(eventId: String, isDarkTheme: Bool?) -> AnyPublisher<FieldWidgetRenderDataType, ServiceProviderError> {
        return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
    }

    func getStatsWidget(eventId: String, marketTypeName: String, isDarkTheme: Bool?) -> AnyPublisher<StatsWidgetRenderDataType, ServiceProviderError> {
        return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
    }

    func getSportRegions(sportId: String) -> AnyPublisher<SportNodeInfo, ServiceProviderError> {
        let endpoint = GomaAPISchema.getRegions(sportCode: sportId)
        let publisher: AnyPublisher<[GomaModels.Region], ServiceProviderError> = self.connector.request(endpoint)
        return publisher.map({ regions in
            let convertedRegions = GomaModelMapper.sportRegions(fromRegions: regions)
            let sportNodeInfo = SportNodeInfo(id: sportId, regionNodes: convertedRegions)
            return sportNodeInfo
        }).eraseToAnyPublisher()
    }

    func getRegionCompetitions(regionId: String) -> AnyPublisher<SportRegionInfo, ServiceProviderError> {
        let endpoint = GomaAPISchema.getCompetitions(regionId: regionId)
        let publisher: AnyPublisher<[GomaModels.Competition], ServiceProviderError> = self.connector.request(endpoint)
        return publisher.map({ competitions in
            let convertedCompetitions = GomaModelMapper.sportCompetitions(fromCompetitions: competitions)
            return SportRegionInfo(id: regionId, name: "", competitionNodes: convertedCompetitions)
        }).eraseToAnyPublisher()
    }

    func getCompetitionMarketGroups(competitionId: String) -> AnyPublisher<SportCompetitionInfo, ServiceProviderError> {

        let endpoint = GomaAPISchema.getCompetitionDetails(identifier: competitionId)
        let publisher: AnyPublisher<GomaModels.Competition, ServiceProviderError> = self.connector.request(endpoint)
        return publisher.map({ competition in
            let group = SportCompetitionMarketGroup(id: competitionId, name: "main")
            let sportCompetitionInfo = SportCompetitionInfo(id: competition.identifier,
                                                            name: competition.name,
                                                            marketGroups: [group],
                                                            numberOutrightEvents: "0",
                                                            numberOutrightMarkets: "0")
            return sportCompetitionInfo
        }).eraseToAnyPublisher()

    }

    func getSearchEvents(query: String, resultLimit: String, page: String, isLive: Bool) -> AnyPublisher<EventsGroup, ServiceProviderError> {

        let endpoint = GomaAPISchema.search(query: query)

        let requestPublisher: AnyPublisher<GomaModels.GomaResponse<[GomaModels.Event]>, ServiceProviderError> = self.connector.request(endpoint)

        return requestPublisher.map( { gomaResponse in
            let events = gomaResponse.data

            let mappedEventsGroup = GomaModelMapper.eventsGroup(fromInternalEvents: events)

            return mappedEventsGroup
        })
        .eraseToAnyPublisher()

    }

    func getEventSummary(eventId: String, marketLimit: Int?) -> AnyPublisher<Event, ServiceProviderError> {

        let endpointDetails = GomaAPISchema.getEventDetails(identifier: eventId)
        let publisherDetails: AnyPublisher<GomaModels.Event, ServiceProviderError> = self.connector.request(endpointDetails)

        let endpointMarkets = GomaAPISchema.getEventMarkets(identifier: eventId, limit: marketLimit)
        let publisherMarkets: AnyPublisher<[GomaModels.Market], ServiceProviderError> = self.connector.request(endpointMarkets)

        return Publishers.CombineLatest(publisherDetails, publisherMarkets)
            .map({ eventDetails, markets -> Event in
                var event = eventDetails
                event.markets = markets
                return GomaModelMapper.event(fromInternalEvent: event)
        }).eraseToAnyPublisher()
//        return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
    }

    func getEventSummary(forMarketId marketId: String) -> AnyPublisher<Event, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getMarketInfo(marketId: String) -> AnyPublisher<Market, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getHomeSliders() -> AnyPublisher<BannerResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getNews() -> AnyPublisher<[News], ServiceProviderError> {
        // TODO: SP MErge - it should have been replaced
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
//        let endpoint = GomaAPISchema.getNews
//        let publisher: AnyPublisher<[GomaModels.News], ServiceProviderError> = self.connector.request(endpoint)
//        return publisher.map({ news in
//            let mappedNews = news.map({
//                return GomaModelMapper.news(fromNews: $0)
//            })
//            return mappedNews
//        }).eraseToAnyPublisher()
    }

    func getHighlightedVisualImageEventsPointers() -> AnyPublisher<[EventMetadataPointer], ServiceProviderError> {
        let endpoint = GomaAPISchema.getHighlights
        let publisher: AnyPublisher<[GomaModels.EventMetadataPointer], ServiceProviderError> = self.connector.request(endpoint)
        return publisher.map({ metadataPointers in
            return metadataPointers.map(GomaModelMapper.eventMetadataPointer(fromInternalEventMetadataPointer:))
        }).eraseToAnyPublisher()
    }

    func getPromotedSports() -> AnyPublisher<[PromotedSport], ServiceProviderError> {
        return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
    }

    func getCashbackSuccessBanner() -> AnyPublisher<BannerResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
    }

    func getEventDetails(eventId: String, marketLimit: Int?) -> AnyPublisher<Event, ServiceProviderError> {

        let endpointDetails = GomaAPISchema.getEventDetails(identifier: eventId)
        let publisherDetails: AnyPublisher<GomaModels.Event, ServiceProviderError> = self.connector.request(endpointDetails)

        let endpointMarkets = GomaAPISchema.getEventMarkets(identifier: eventId, limit: marketLimit)
        let publisherMarkets: AnyPublisher<[GomaModels.Market], ServiceProviderError> = self.connector.request(endpointMarkets)

        return Publishers.CombineLatest(publisherDetails, publisherMarkets)
            .map({ eventDetails, markets -> Event in
                var event = eventDetails
                event.markets = markets
                return GomaModelMapper.event(fromInternalEvent: event)
        }).eraseToAnyPublisher()
    }

    func getFavoritesList() -> AnyPublisher<FavoritesListResponse, ServiceProviderError> {

        let endpoint = GomaAPISchema.getFavorites

        let publisher: AnyPublisher<GomaModels.GomaResponse<[GomaModels.FavoriteItem]>, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.map({ favoritesResponse in

            let favoriteItems = favoritesResponse.data

            let favoritesList = favoriteItems.map({ favoriteItem in

                let favoriteList = GomaModelMapper.favoriteList(fromInternalFavoriteItem: favoriteItem)

                return favoriteList
            })

            let favoritesListResponse = FavoritesListResponse(favoritesList: favoritesList)

            return favoritesListResponse
        }).eraseToAnyPublisher()

    }

    func addFavoritesList(name: String) -> AnyPublisher<FavoritesListAddResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
    }

    func deleteFavoritesList(listId: Int) -> AnyPublisher<FavoritesListDeleteResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
    }

    func addFavoriteToList(listId: Int, eventId: String) -> AnyPublisher<FavoriteAddResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
    }

    func getFavoritesFromList(listId: Int) -> AnyPublisher<FavoriteEventResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
    }

    func deleteFavoriteFromList(eventId: Int) -> AnyPublisher<FavoritesListDeleteResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
    }

    func addFavoriteItem(favoriteId: Int, type: String) -> AnyPublisher<BasicMessageResponse, ServiceProviderError> {

        let endpoint = GomaAPISchema.addFavorite(favoriteId: favoriteId, type: type)

        let publisher: AnyPublisher<BasicMessageResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.map({ basicMessageResponse in

            return basicMessageResponse
        }).eraseToAnyPublisher()

    }

    func deleteFavoriteItem(favoriteId: Int, type: String) -> AnyPublisher<BasicMessageResponse, ServiceProviderError> {

        let endpoint = GomaAPISchema.deleteFavorite(favoriteId: favoriteId, type: type)

        let publisher: AnyPublisher<BasicMessageResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.map({ basicMessageResponse in

            return basicMessageResponse
        }).eraseToAnyPublisher()
    }

    func getDatesFilter(timeRange: String) -> [Date] {
        // TODO: Implement this func
        return []
    }

    func getFeaturedTips(page: Int?, limit: Int?, topTips: Bool?, followersTips: Bool?, friendsTips: Bool?, userId: String?, homeTips: Bool?) -> AnyPublisher<FeaturedTips, ServiceProviderError> {
        let endpoint = GomaAPISchema.getFeaturedTips(page: page, limit: limit, topTips: topTips, followersTips: followersTips, friendsTips: friendsTips, userId: userId, homeTips: homeTips)

        let publisher: AnyPublisher<GomaModels.FeaturedTipsPagedResponse, ServiceProviderError> = self.connector.request(endpoint)
        return publisher.map({ featuredTipsResponse in
            return GomaModelMapper.featuredTips(fromInternalFeaturedTips: featuredTipsResponse.featuredTips)
        }).eraseToAnyPublisher()
    }
    
    // MARK: - New Filtered Subscription Methods (Not Supported)
    
    func subscribeToFilteredPreLiveMatches(filters: MatchesFilterOptions) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func subscribeToFilteredLiveMatches(filters: MatchesFilterOptions) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

}

extension GomaProvider: BettingProvider {

    func getBetHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError> {

        let endpoint = GomaAPISchema.getMyTickets(states: nil, limit: "20", page: "\(pageIndex)")

        let publisher: AnyPublisher<GomaModels.MyTicketsResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher
            .map(GomaModelMapper.bettingHistory(fromMyTicketsResponse:))
            .eraseToAnyPublisher()
    }

    func getBetDetails(identifier: String) -> AnyPublisher<Bet, ServiceProviderError> {
        let endpoint = GomaAPISchema.getTicketDetails(betId: identifier)
        let publisher: AnyPublisher<GomaModels.MyTicket, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map(GomaModelMapper.bet(fromMyTicket:))
            .eraseToAnyPublisher()
    }

    func getOpenBetsHistory(pageIndex: Int, startDate: String?, endDate: String?) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        let endpoint = GomaAPISchema.getMyTickets(states: [GomaModels.MyTicketStatus.pending], limit: "20", page: "\(pageIndex)")
        let publisher: AnyPublisher<GomaModels.MyTicketsResponse, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map(GomaModelMapper.bettingHistory(fromMyTicketsResponse:))
            .eraseToAnyPublisher()
    }

    func getResolvedBetsHistory(pageIndex: Int, startDate: String?, endDate: String?) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        let endpoint = GomaAPISchema.getMyTickets(states: [GomaModels.MyTicketStatus.won, GomaModels.MyTicketStatus.lost, GomaModels.MyTicketStatus.push], limit: "20", page: "\(pageIndex)")
        let publisher: AnyPublisher<GomaModels.MyTicketsResponse, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map(GomaModelMapper.bettingHistory(fromMyTicketsResponse:))
            .eraseToAnyPublisher()
    }

    func getWonBetsHistory(pageIndex: Int, startDate: String?, endDate: String?) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        let endpoint = GomaAPISchema.getMyTickets(states: [GomaModels.MyTicketStatus.won], limit: "20", page: "\(pageIndex)")
        let publisher: AnyPublisher<GomaModels.MyTicketsResponse, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map(GomaModelMapper.bettingHistory(fromMyTicketsResponse:))
            .eraseToAnyPublisher()
    }

    func getAllowedBetTypes(withBetTicketSelections betTicketSelections: [BetTicketSelection]) -> AnyPublisher<[BetType], ServiceProviderError> {
        
        if betTicketSelections.isEmpty {
            return Just([]).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
        }
        
        var argumentSelections: [GomaAPISchema.ArgumentModels.BetSelection] = []
        for betTicketSelection in betTicketSelections {
            if let eventId = betTicketSelection.eventId, let outcomeId = betTicketSelection.outcomeId {
                let betSelection = GomaAPISchema.ArgumentModels.BetSelection(eventId: eventId, outcomeId: outcomeId)
                argumentSelections.append(betSelection)
            }
        }
        let endpoint = GomaAPISchema.getAllowedBetTypes(selections: argumentSelections)
        let publisher: AnyPublisher<GomaModels.AllowedBets, ServiceProviderError> = self.connector.request(endpoint)
        return publisher.map({ allowedBetsResponse in
            return GomaModelMapper.betTypes(fromGomaBetTypes: allowedBetsResponse.allowedTypes)
        }).eraseToAnyPublisher()
    }

    func calculatePotentialReturn(forBetTicket betTicket: BetTicket) -> AnyPublisher<BetslipPotentialReturn, ServiceProviderError> {
        var argumentSelections: [GomaAPISchema.ArgumentModels.BetSelection] = []
        for betTicketSelection in betTicket.tickets {
            if let eventId = betTicketSelection.eventId, let outcomeId = betTicketSelection.outcomeId {
                let betSelection = GomaAPISchema.ArgumentModels.BetSelection(eventId: eventId, outcomeId: outcomeId)
                argumentSelections.append(betSelection)
            }
        }
        let betType = GomaModelMapper.gomaBetType(fromBetGroupingType: betTicket.betGroupingType)

        let endpoint = GomaAPISchema.getCalculatePossibleBetResult(stake: betTicket.globalStake ?? 0.0, type: betType, selections: argumentSelections)
        let publisher: AnyPublisher<GomaModels.BetslipPotentialReturn, ServiceProviderError> = self.connector.request(endpoint)
        return publisher.map({ betslipPotentialReturn in
            let betslipPotentialReturn = BetslipPotentialReturn(potentialReturn: betslipPotentialReturn.possibleWinnings,
                                          totalStake: betslipPotentialReturn.stake,
                                          numberOfBets: betslipPotentialReturn.selections.count,
                                          totalOdd: betslipPotentialReturn.odds)
            return betslipPotentialReturn
        }).eraseToAnyPublisher()
    }

    func placeBets(betTickets: [BetTicket], useFreebetBalance: Bool, currency: String?, username: String?, userId: String?, oddsValidationType: String?) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> {

        let publishers = betTickets.map { betTicket in
            let endpoint = GomaAPISchema.placeBetTicket(betTicket: betTicket, useCashback: useFreebetBalance)
            let publisher: AnyPublisher<GomaModels.PlaceBetTicketResponse, ServiceProviderError> = self.connector.request(endpoint)
            return publisher
                .map { Result<GomaModels.PlaceBetTicketResponse, ServiceProviderError>.success($0) }
                .catch { Just<Result<GomaModels.PlaceBetTicketResponse, ServiceProviderError>>(.failure($0)) }
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }

        return Publishers.MergeMany(publishers)
            .collect()
            .flatMap({ (results: [Result<GomaModels.PlaceBetTicketResponse, ServiceProviderError>])
                -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> in

                var validResults: [GomaModels.PlaceBetTicketResponse] = []
                var errors: [ServiceProviderError] = []

                for result in results {
                    switch result {
                    case .success(let success):
                        validResults.append(success)
                    case .failure(let failure):
                        errors.append(failure)
                    }
                }

                let placeBetResponse = GomaModelMapper.placedBetsResponse(fromPlaceBetTicketsResponses: validResults)

                if validResults.isEmpty {
                    if let firstError = errors.first {
                        return Fail(outputType: PlacedBetsResponse.self, failure: firstError).eraseToAnyPublisher()
                    }
                    else {
                        return Fail(outputType: PlacedBetsResponse.self, failure: ServiceProviderError.unknown).eraseToAnyPublisher()
                    }
                } else {
                    return Just(placeBetResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                }
            })
            .eraseToAnyPublisher()
    }

    func calculateCashout(betId: String, stakeValue: String?) -> AnyPublisher<Cashout, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func cashoutBet(betId: String, cashoutValue: Double, stakeValue: Double?) -> AnyPublisher<CashoutResult, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func calculateCashback(forBetTicket betTicket: BetTicket) -> AnyPublisher<CashbackResult, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getBetslipSettings() -> AnyPublisher<BetslipSettings?, Never> {
        // TODO: Implement this func
        return Just(nil).eraseToAnyPublisher()
    }

    func updateBetslipSettings(_ betslipSettings: BetslipSettings) -> AnyPublisher<Bool, Never> {
        // TODO: Implement this func
        return Just(false).eraseToAnyPublisher()
    }

    func getFreebet() -> AnyPublisher<FreebetBalance, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getSharedTicket(betslipId: String) -> AnyPublisher<SharedTicketResponse, ServiceProviderError> {

        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getTicketSelection(ticketSelectionId: String) -> AnyPublisher<TicketSelection, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func updateTicketOdds(betId: String) -> AnyPublisher<Bet, ServiceProviderError> {
        let endpoint = GomaAPISchema.updateTicketOdds(betId: betId)
        let publisher: AnyPublisher<GomaModels.MyTicket, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map(GomaModelMapper.bet(fromMyTicket:))
            .eraseToAnyPublisher()
    }

    func getTicketQRCode(betId: String) -> AnyPublisher<BetQRCode, ServiceProviderError> {
        let endpoint = GomaAPISchema.getTicketQRCode(betId: betId)
        let publisher: AnyPublisher<GomaModels.MyTicketQRCode, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map(GomaModelMapper.betQRCode(fromMyTicketQRCode:))
            .eraseToAnyPublisher()
    }

    func getSocialSharedTicket(shareId: String) -> AnyPublisher<Bet, ServiceProviderError> {

        let endpoint = GomaAPISchema.getSharedTicket(sharedId: shareId)

        let publisher: AnyPublisher<GomaModels.MyTicket, ServiceProviderError> = self.connector.request(endpoint)
        return publisher.print("getSharedTicket").map({ sharedTicket in

            let mappedBet = GomaModelMapper.bet(fromMyTicket: sharedTicket)

            return mappedBet
        }).eraseToAnyPublisher()
    }

    func deleteTicket(betId: String) -> AnyPublisher<Bool, ServiceProviderError> {
        let endpoint = GomaAPISchema.deleteTicket(betId: betId)
        let publisher: AnyPublisher<Bool, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
    }

    func updateTicket(betId: String, betTicket: BetTicket) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> {
        let endpoint = GomaAPISchema.updateTicket(betId: betId, betTicket: betTicket)
        let publisher: AnyPublisher<GomaModels.MyTicket, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map(GomaModelMapper.placedBetsResponse(fromMyTicket:))
            .eraseToAnyPublisher()
    }
    
    func calculateBetBuilderPotentialReturn(forBetTicket betTicket: BetTicket) -> AnyPublisher<BetBuilderPotentialReturn, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func placeBetBuilderBet(betTicket: BetTicket, calculatedOdd: Double) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func confirmBoostedBet(identifier: String) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func rejectBoostedBet(identifier: String) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func allowedCashoutBetIds() -> AnyPublisher<[String], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
}

extension GomaProvider {
    static func parseGomaDateString(_ dateString: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        
        if let date = dateFormatter.date(from: dateString) {
            return date
        }
        
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return dateFormatter.date(from: dateString)
    }
}
