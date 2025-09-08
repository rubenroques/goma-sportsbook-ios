//
//  EveryMatrixPrivilegedAccessManager.swift
//  ServicesProvider
//
//  Created by André Lascas on 09/07/2025.
//

import Foundation
import Combine
import SharedModels

class EveryMatrixPrivilegedAccessManager: PrivilegedAccessManagerProvider {
    
    var connector: EveryMatrixPlayerAPIConnector
    private let sessionCoordinator: EveryMatrixSessionCoordinator

    // Publishers
    var sessionStatePublisher: AnyPublisher<UserSessionStatus, Error> {
        return self.sessionStateSubject.eraseToAnyPublisher()
    }
    var userProfilePublisher: AnyPublisher<UserProfile?, Error> {
        return self.userProfileSubject.eraseToAnyPublisher()
    }
    
    private let sessionStateSubject: CurrentValueSubject<UserSessionStatus, Error> = .init(.anonymous)
    private let userProfileSubject: CurrentValueSubject<UserProfile?, Error> = .init(nil)

    // Internal state
    private var cancellables: Set<AnyCancellable> = []

    init(connector: EveryMatrixPlayerAPIConnector, sessionCoordinator: EveryMatrixSessionCoordinator) {
        self.connector = connector
        self.sessionCoordinator = sessionCoordinator
    }
    
    // New methods
    func getRegistrationConfig() -> AnyPublisher<RegistrationConfigResponse, ServiceProviderError> {

        let endpoint = EveryMatrixPlayerAPI.getRegistrationConfig
        let publisher: AnyPublisher<EveryMatrix.RegistrationConfigResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher.flatMap({ registrationConfigResponse -> AnyPublisher<RegistrationConfigResponse, ServiceProviderError> in
            
            let mappedRegistrationConfigResponse = EveryMatrixModelMapper.registrationConfigResponse(fromInternalResponse: registrationConfigResponse)
            
            return Just(mappedRegistrationConfigResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            
        })
        .eraseToAnyPublisher()
    }

    // Implement all required methods from PrivilegedAccessManagerProvider
    func login(username: String, password: String) -> AnyPublisher<UserProfile, ServiceProviderError> {
        let endpoint = EveryMatrixPlayerAPI.login(username: username, password: password)
        let publisher: AnyPublisher<EveryMatrix.PhoneLoginResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher
            .flatMap { [weak self] phoneLoginResponse -> AnyPublisher<UserProfile, ServiceProviderError> in
                guard let self = self else {
                    return Fail(error: .unknown).eraseToAnyPublisher()
                }
                
                // Store credentials in session coordinator for automatic token refresh
                let credentials = EveryMatrixCredentials(username: username, password: password)
                self.sessionCoordinator.updateCredentials(credentials)
                
                // Update session in session coordinator
                let session = EveryMatrixSessionResponse(
                    sessionId: phoneLoginResponse.sessionId,
                    userId: String(phoneLoginResponse.userId)
                )
                self.sessionCoordinator.updateSession(session)
                
                // Store the session token in the connector (for backward compatibility)
                self.connector.updateSessionToken(sessionId: phoneLoginResponse.sessionId, userId: phoneLoginResponse.userId)
                
                // Save the session token to the session coordinator for other APIs to access
                self.sessionCoordinator.saveToken(phoneLoginResponse.sessionId, withKey: .playerSessionToken)
                
                // Save the user ID to the session coordinator for future use
                self.sessionCoordinator.saveUserId(String(phoneLoginResponse.userId))
                
                let getUserProfileEndpoint = EveryMatrixPlayerAPI.getUserProfile(userId: String(phoneLoginResponse.userId))
                
                return self.connector.request(getUserProfileEndpoint)
                    .map { (playerProfile: EveryMatrix.PlayerProfile) in
                        // Map to your app's UserProfile model if needed
                        let mappedUserProfile = EveryMatrixModelMapper.userProfile(fromInternalPlayerProfile: playerProfile)
                        
                        return mappedUserProfile
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    var accessToken: String?
    
    var hasSecurityQuestions: Bool = false
    
    func getUserProfile(withKycExpire: String?) -> AnyPublisher<UserProfile, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func updateUserProfile(form: UpdateUserProfileForm) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func checkEmailRegistered(_ email: String) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func validateUsername(_ username: String) -> AnyPublisher<UsernameValidation, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func signUp(with formType: SignUpFormType) -> AnyPublisher<SignUpResponse, ServiceProviderError> {
        
        switch formType {
        case .phone(let phoneSignUpForm):
            let registerStepEndpoint = EveryMatrixPlayerAPI.registerStep(
                        phoneText: phoneSignUpForm.phone,
                        password: phoneSignUpForm.password,
                        mobilePrefix: phoneSignUpForm.phonePrefix,
                        registrationId: phoneSignUpForm.registrationId
                    )
            
                    let registerStepPublisher: AnyPublisher<EveryMatrix.RegisterStepResponse, ServiceProviderError> = self.connector.request(registerStepEndpoint)

                    return registerStepPublisher
                        .flatMap { registerStepResponse -> AnyPublisher<EveryMatrix.RegisterResponse, ServiceProviderError> in
                            // Extract registrationId from the first response
                            let registrationId = registerStepResponse.registrationId
                            let registerEndpoint = EveryMatrixPlayerAPI.register(registrationId: registrationId)
                            // Call the second endpoint
                            return self.connector.request(registerEndpoint)
                        }
                        .map { registerResponse in
                            // Map the final response to your SignUpResponse
                            return EveryMatrixModelMapper.signUpResponse(fromInternalRegisterResponse: registerResponse)
                        }
                        .eraseToAnyPublisher()
        default:
            return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()

        }
        
    }
    
    func updateExtraInfo(placeOfBirth: String?, address2: String?) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func updateDeviceIdentifier(deviceIdentifier: String, appVersion: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getAllCountries() -> AnyPublisher<[SharedModels.Country], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getCountries() -> AnyPublisher<[SharedModels.Country], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getCurrentCountry() -> AnyPublisher<SharedModels.Country?, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func signupConfirmation(_ email: String, confirmationCode: String) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func forgotPassword(email: String, secretQuestion: String?, secretAnswer: String?) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func updatePassword(oldPassword: String, newPassword: String) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getPasswordPolicy() -> AnyPublisher<PasswordPolicy, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func updateWeeklyDepositLimits(newLimit: Double) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func updateWeeklyBettingLimits(newLimit: Double) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func updateResponsibleGamingLimits(newLimit: Double, limitType: String, hasRollingWeeklyLimits: Bool) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getPersonalDepositLimits() -> AnyPublisher<PersonalDepositLimitResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getLimits() -> AnyPublisher<LimitsResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getResponsibleGamingLimits(periodTypes: String?, limitTypes: String?) -> AnyPublisher<ResponsibleGamingLimitsResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func lockPlayer(isPermanent: Bool?, lockPeriodUnit: String?, lockPeriod: String?) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getUserBalance() -> AnyPublisher<UserWallet, ServiceProviderError> {
        let currentUserId = sessionCoordinator.currentUserId ?? ""

        let endpoint = EveryMatrixPlayerAPI.getUserBalance(userId: currentUserId)
        let publisher: AnyPublisher<EveryMatrix.WalletBalance, ServiceProviderError> = self.connector.request(endpoint)

        return publisher
            .flatMap { walletResponse -> AnyPublisher<UserWallet, ServiceProviderError> in
                
                let mappedWalletResponse = EveryMatrixModelMapper.userWallet(fromWalletBalance: walletResponse)
                
                return Just(mappedWalletResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                
            }
            .eraseToAnyPublisher()

    }
    
    func getUserCashbackBalance() -> AnyPublisher<CashbackBalance, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func signUpCompletion(form: UpdateUserProfileForm) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getDocumentTypes() -> AnyPublisher<DocumentTypesResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getUserDocuments() -> AnyPublisher<UserDocumentsResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func uploadUserDocument(documentType: String, file: Data, fileName: String) -> AnyPublisher<UploadDocumentResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func uploadMultipleUserDocuments(documentType: String, files: [String : Data]) -> AnyPublisher<UploadDocumentResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getPayments() -> AnyPublisher<SimplePaymentMethodsResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func processDeposit(paymentMethod: String, amount: Double, option: String) -> AnyPublisher<ProcessDepositResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func depositOnWallet(amount: Double) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func updatePayment(amount: Double, paymentId: String, type: String, returnUrl: String?, nameOnCard: String?, encryptedExpiryYear: String?, encryptedExpiryMonth: String?, encryptedSecurityCode: String?, encryptedCardNumber: String?) -> AnyPublisher<UpdatePaymentResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func cancelDeposit(paymentId: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func checkPaymentStatus(paymentMethod: String, paymentId: String) -> AnyPublisher<PaymentStatusResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getWithdrawalMethods() -> AnyPublisher<[WithdrawalMethod], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func processWithdrawal(paymentMethod: String, amount: Double, conversionId: String?) -> AnyPublisher<ProcessWithdrawalResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func prepareWithdrawal(paymentMethod: String) -> AnyPublisher<PrepareWithdrawalResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getPendingWithdrawals() -> AnyPublisher<[PendingWithdrawal], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func cancelWithdrawal(paymentId: Int) -> AnyPublisher<CancelWithdrawalResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getPaymentInformation() -> AnyPublisher<PaymentInformation, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func addPaymentInformation(type: String, fields: String) -> AnyPublisher<AddPaymentInformationResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getTransactionsHistory(startDate: String, endDate: String, transactionTypes: [TransactionType]?, pageNumber: Int?) -> AnyPublisher<[TransactionDetail], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getGrantedBonuses() -> AnyPublisher<[GrantedBonus], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func redeemBonus(code: String) -> AnyPublisher<RedeemBonusResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getAvailableBonuses() -> AnyPublisher<[AvailableBonus], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func redeemAvailableBonus(partyId: String, code: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func cancelBonus(bonusId: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func optOutBonus(partyId: String, code: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
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
    
    func getReferralLink() -> AnyPublisher<ReferralLink, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getReferees() -> AnyPublisher<[Referee], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getFollowees() -> AnyPublisher<[Follower], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getTotalFollowees() -> AnyPublisher<Int, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getFollowers() -> AnyPublisher<[Follower], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getTotalFollowers() -> AnyPublisher<Int, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func addFollowee(userId: String) -> AnyPublisher<[String], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func removeFollowee(userId: String) -> AnyPublisher<[String], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getTipsRankings(type: String?, followers: Bool?) -> AnyPublisher<[TipRanking], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getUserProfileInfo(userId: String) -> AnyPublisher<UserProfileInfo, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getUserNotifications() -> AnyPublisher<UserNotificationsSettings, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func updateUserNotifications(settings: UserNotificationsSettings) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getFriendRequests() -> AnyPublisher<[FriendRequest], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getFriends() -> AnyPublisher<[UserFriend], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func addFriends(userIds: [String], request: Bool) -> AnyPublisher<AddFriendResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func removeFriend(userId: Int) -> AnyPublisher<String, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getChatrooms() -> AnyPublisher<[ChatroomData], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func addGroup(name: String, userIds: [String]) -> AnyPublisher<ChatroomId, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func deleteGroup(id: Int) -> AnyPublisher<String, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func editGroup(id: Int, name: String) -> AnyPublisher<String, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func leaveGroup(id: Int) -> AnyPublisher<String, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func addUsersToGroup(groupId: Int, userIds: [String]) -> AnyPublisher<String, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func removeUsersToGroup(groupId: Int, userIds: [String]) -> AnyPublisher<String, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func searchUserWithCode(code: String) -> AnyPublisher<SearchUser, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
}
