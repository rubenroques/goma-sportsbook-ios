
import Foundation
import Combine
import SharedModels

class EveryMatrixPAMProvider: PrivilegedAccessManagerProvider {

    var restConnector: EveryMatrixRESTConnector
    private let sseConnector: EveryMatrixSSEConnector
    private let sessionCoordinator: EveryMatrixSessionCoordinator

    // User Info Stream Manager
    private var userInfoStreamManager: UserInfoStreamManager?

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

    init(restConnector: EveryMatrixRESTConnector,
         sseConnector: EveryMatrixSSEConnector,
         sessionCoordinator: EveryMatrixSessionCoordinator) {
        self.restConnector = restConnector
        self.sseConnector = sseConnector
        self.sessionCoordinator = sessionCoordinator
    }
    
    // New methods
    func getRegistrationConfig() -> AnyPublisher<RegistrationConfigResponse, ServiceProviderError> {

        let endpoint = EveryMatrixPlayerAPI.getRegistrationConfig
        let publisher: AnyPublisher<EveryMatrix.RegistrationConfigResponse, ServiceProviderError> = self.restConnector.request(endpoint)

        return publisher.flatMap({ registrationConfigResponse -> AnyPublisher<RegistrationConfigResponse, ServiceProviderError> in
            
            let mappedRegistrationConfigResponse = EveryMatrixModelMapper.registrationConfigResponse(fromInternalResponse: registrationConfigResponse)
            
            return Just(mappedRegistrationConfigResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            
        })
        .eraseToAnyPublisher()
    }

    // Implement all required methods from PrivilegedAccessManagerProvider
    func login(username: String, password: String) -> AnyPublisher<UserProfile, ServiceProviderError> {
        let endpoint = EveryMatrixPlayerAPI.login(username: username, password: password)
        let publisher: AnyPublisher<EveryMatrix.PhoneLoginResponse, ServiceProviderError> = self.restConnector.request(endpoint)

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
                
                // Save the session token to the session coordinator for other APIs to access
                self.sessionCoordinator.saveToken(phoneLoginResponse.sessionId, withKey: .playerSessionToken)
                
                // Save the user ID to the session coordinator for future use
                self.sessionCoordinator.saveUserId(String(phoneLoginResponse.userId))
                
                let getUserProfileEndpoint = EveryMatrixPlayerAPI.getUserProfile(userId: String(phoneLoginResponse.userId))
                
                return self.restConnector.request(getUserProfileEndpoint)
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
            let registerStepEndpoint = EveryMatrixPlayerAPI.registerStep(form: phoneSignUpForm)
            
                    let registerStepPublisher: AnyPublisher<EveryMatrix.RegisterStepResponse, ServiceProviderError> = self.restConnector.request(registerStepEndpoint)

                    return registerStepPublisher
                        .flatMap { registerStepResponse -> AnyPublisher<EveryMatrix.RegisterResponse, ServiceProviderError> in
                            // Extract registrationId from the first response
                            let registrationId = registerStepResponse.registrationId
                            let registerEndpoint = EveryMatrixPlayerAPI.register(registrationId: registrationId)
                            // Call the second endpoint
                            return self.restConnector.request(registerEndpoint)
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
    
    func getUserLimits(periodTypes: String? = nil, limitTypes: String? = nil) -> AnyPublisher<UserLimitsResponse, ServiceProviderError> {
        guard let currentUserId = sessionCoordinator.currentUserId else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }
        let endpoint = EveryMatrixPlayerAPI.getUserLimits(userId: currentUserId, periodTypes: periodTypes)
        let publisher: AnyPublisher<EveryMatrix.ResponsibleGamingLimitsResponse, ServiceProviderError> = self.restConnector.request(endpoint)
        return publisher
            .map { response in
                EveryMatrixModelMapper.userLimitsResponse(from: response)
            }
            .eraseToAnyPublisher()
    }
    
    func setUserLimit(period: String, type: String, amount: Double, currency: String, products: [String], walletTypes: [String]) -> AnyPublisher<UserLimit, ServiceProviderError> {
        guard let currentUserId = sessionCoordinator.currentUserId else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }
        let request = UserLimitRequest(
            amount: amount,
            currency: currency,
            period: period,
            type: type,
            products: products,
            walletTypes: walletTypes
        )
        let endpoint = EveryMatrixPlayerAPI.setUserLimit(userId: currentUserId, request: request)
        let publisher: AnyPublisher<EveryMatrix.SetUserLimitResponse, ServiceProviderError> = self.restConnector.request(endpoint)
        return publisher
            .tryMap { response -> UserLimit in
                guard let mapped = EveryMatrixModelMapper.userLimit(from: response.limit) else {
                    throw ServiceProviderError.invalidResponse
                }
                return mapped
            }
            .mapError { error in
                if let serviceError = error as? ServiceProviderError {
                    return serviceError
                }
                return ServiceProviderError.invalidResponse
            }
            .eraseToAnyPublisher()
    }

    func setTimeOut(request: UserTimeoutRequest) -> AnyPublisher<Void, ServiceProviderError> {
        guard let currentUserId = sessionCoordinator.currentUserId else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }
        let endpoint = EveryMatrixPlayerAPI.setTimeOut(userId: currentUserId, request: request)
        let publisher: AnyPublisher<EveryMatrix.EmptyResponse, ServiceProviderError> = self.restConnector.request(endpoint)
        return publisher
            .map { _ in () }
            .catch { error -> AnyPublisher<Void, ServiceProviderError> in
                if case .decodingError = error {
                    return Just(()).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func setSelfExclusion(request: SelfExclusionRequest) -> AnyPublisher<Void, ServiceProviderError> {
        guard let currentUserId = sessionCoordinator.currentUserId else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }
        let endpoint = EveryMatrixPlayerAPI.setSelfExclusion(userId: currentUserId, request: request)
        let publisher: AnyPublisher<EveryMatrix.EmptyResponse, ServiceProviderError> = self.restConnector.request(endpoint)
        return publisher
            .map { _ in () }
            .catch { error -> AnyPublisher<Void, ServiceProviderError> in
                if case .decodingError = error {
                    return Just(()).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func updateUserLimit(limitId: String, request: UpdateUserLimitRequest) -> AnyPublisher<UserLimit, ServiceProviderError> {
        guard let currentUserId = sessionCoordinator.currentUserId else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }
        let endpoint = EveryMatrixPlayerAPI.updateUserLimit(userId: currentUserId, limitId: limitId, request: request)
        let publisher: AnyPublisher<EveryMatrix.SetUserLimitResponse, ServiceProviderError> = self.restConnector.request(endpoint)
        return publisher
            .tryMap { response -> UserLimit in
                guard let mapped = EveryMatrixModelMapper.userLimit(from: response.limit) else {
                    throw ServiceProviderError.invalidResponse
                }
                return mapped
            }
            .mapError { error in
                if let serviceError = error as? ServiceProviderError {
                    return serviceError
                }
                return ServiceProviderError.invalidResponse
            }
            .eraseToAnyPublisher()
    }

    func deleteUserLimit(limitId: String, skipCoolOff: Bool) -> AnyPublisher<Void, ServiceProviderError> {
        guard let currentUserId = sessionCoordinator.currentUserId else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }
        let request = DeleteUserLimitRequest(skipCoolOff: skipCoolOff)
        let endpoint = EveryMatrixPlayerAPI.deleteUserLimit(userId: currentUserId, limitId: limitId, request: request)
        let publisher: AnyPublisher<EveryMatrix.EmptyResponse, ServiceProviderError> = self.restConnector.request(endpoint)
        return publisher
            .map { _ in () }
            .catch { error -> AnyPublisher<Void, ServiceProviderError> in
                if case .decodingError = error {
                    return Just(()).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func lockPlayer(isPermanent: Bool?, lockPeriodUnit: String?, lockPeriod: String?) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getUserBalance() -> AnyPublisher<UserWallet, ServiceProviderError> {
        let currentUserId = sessionCoordinator.currentUserId ?? ""

        let endpoint = EveryMatrixPlayerAPI.getUserBalance(userId: currentUserId)
        let publisher: AnyPublisher<EveryMatrix.WalletBalance, ServiceProviderError> = self.restConnector.request(endpoint)

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
    
    func getBankingWebView(parameters: CashierParameters) -> AnyPublisher<CashierWebViewResponse, ServiceProviderError> {
        let currentUserId = sessionCoordinator.currentUserId ?? ""
        
        // Map domain model to EveryMatrix internal request model
        let request = EveryMatrixModelMapper.getPaymentSessionRequest(from: parameters)
        let endpoint = EveryMatrixPlayerAPI.getBankingWebView(userId: currentUserId, parameters: request)
        
        // Make request and map internal response to domain model
        let publisher: AnyPublisher<EveryMatrix.GetPaymentSessionResponse, ServiceProviderError> = self.restConnector.request(endpoint)
        
        return publisher
            .map { response in
                EveryMatrixModelMapper.cashierWebViewResponse(from: response)
            }
            .eraseToAnyPublisher()
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
    
    func getGrantedBonuses(language: String?) -> AnyPublisher<[GrantedBonus], ServiceProviderError> {
        let endpoint = EveryMatrixPlayerAPI.getGrantedBonus(language: language ?? EveryMatrixUnifiedConfiguration.shared.defaultLanguage)
        let publisher: AnyPublisher<EveryMatrix.GrantedBonusResponse, ServiceProviderError> = self.restConnector.request(endpoint)
        
        return publisher.flatMap { grantedBonusResponse -> AnyPublisher<[GrantedBonus], ServiceProviderError> in
            let mappedBonuses = EveryMatrixModelMapper.grantedBonuses(fromInternalResponse: grantedBonusResponse)
            return Just(mappedBonuses).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    func redeemBonus(code: String) -> AnyPublisher<RedeemBonusResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getAvailableBonuses(language: String?) -> AnyPublisher<[AvailableBonus], ServiceProviderError> {
        let endpoint = EveryMatrixPlayerAPI.getAvailableBonus(language: language ?? EveryMatrixUnifiedConfiguration.shared.defaultLanguage)
        let publisher: AnyPublisher<EveryMatrix.BonusResponse, ServiceProviderError> = self.restConnector.request(endpoint)
        
        return publisher.flatMap { bonusResponse -> AnyPublisher<[AvailableBonus], ServiceProviderError> in
            let mappedBonuses = EveryMatrixModelMapper.availableBonuses(fromInternalResponse: bonusResponse)
            return Just(mappedBonuses).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
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

    // MARK: - Transaction History Methods

    func getBankingTransactionsHistory(startDate: String, endDate: String, pageNumber: Int?, types: String? = nil, states: [String]? = nil) -> AnyPublisher<BankingTransactionsResponse, ServiceProviderError> {
        let currentUserId = sessionCoordinator.currentUserId ?? ""

        let endpoint = EveryMatrixPlayerAPI.getBankingTransactions(userId: currentUserId, startDate: startDate, endDate: endDate, pageNumber: pageNumber, types: types, states: states)
        let publisher: AnyPublisher<EveryMatrix.BankingTransactionsResponse, ServiceProviderError> = self.restConnector.request(endpoint)

        return publisher
            .map { internalResponse in
                EveryMatrixModelMapper.bankingTransactionsResponse(from: internalResponse)
            }
            .eraseToAnyPublisher()
    }

    func getWageringTransactionsHistory(startDate: String, endDate: String, pageNumber: Int?) -> AnyPublisher<WageringTransactionsResponse, ServiceProviderError> {
        let currentUserId = sessionCoordinator.currentUserId ?? ""

        let endpoint = EveryMatrixPlayerAPI.getWageringTransactions(userId: currentUserId, startDate: startDate, endDate: endDate, pageNumber: pageNumber)
        let publisher: AnyPublisher<EveryMatrix.WageringTransactionsResponse, ServiceProviderError> = self.restConnector.request(endpoint)

        return publisher
            .map { internalResponse in
                EveryMatrixModelMapper.wageringTransactionsResponse(from: internalResponse)
            }
            .eraseToAnyPublisher()
    }

    // Helper methods with date filter
    func getBankingTransactionsHistory(filter: TransactionDateFilter, pageNumber: Int?, types: String? = nil, states: [String]? = nil) -> AnyPublisher<BankingTransactionsResponse, ServiceProviderError> {
        let (startDate, endDate) = calculateDates(for: filter)
        return getBankingTransactionsHistory(startDate: startDate, endDate: endDate, pageNumber: pageNumber, types: types, states: states)
    }

    func getWageringTransactionsHistory(filter: TransactionDateFilter, pageNumber: Int?) -> AnyPublisher<WageringTransactionsResponse, ServiceProviderError> {
        let (startDate, endDate) = calculateDates(for: filter)
        return getWageringTransactionsHistory(startDate: startDate, endDate: endDate, pageNumber: pageNumber)
    }

    // MARK: - Private Date Calculation Helper

    private func calculateDates(for filter: TransactionDateFilter) -> (String, String) {
        let calendar = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let endDate = formatter.string(from: now)

        let startDate: String
        switch filter {
        case .all:
            // 179 days back (API limit is 180 days, using 179 to avoid edge cases)
            startDate = formatter.string(from: calendar.date(byAdding: .day, value: -179, to: now) ?? now)
        case .oneDay:
            startDate = formatter.string(from: calendar.date(byAdding: .day, value: -1, to: now) ?? now)
        case .oneWeek:
            startDate = formatter.string(from: calendar.date(byAdding: .day, value: -7, to: now) ?? now)
        case .oneMonth:
            startDate = formatter.string(from: calendar.date(byAdding: .month, value: -1, to: now) ?? now)
        case .threeMonths:
            startDate = formatter.string(from: calendar.date(byAdding: .month, value: -3, to: now) ?? now)
        }

        return (startDate, endDate)
    }

    
    // Games
    func getRecentlyPlayedGames(playerId: String, language: String?, platform: String?, pagination: CasinoPaginationParams) -> AnyPublisher<CasinoGamesResponse, ServiceProviderError> {
        
        guard restConnector.sessionToken != nil else {
            return Just(CasinoGamesResponse(
                count: 0,
                total: 0,
                games: [],
                pagination: nil
            ))
            .setFailureType(to: ServiceProviderError.self)
            .eraseToAnyPublisher()
        }
        
        let endpoint = EveryMatrixPlayerAPI.getRecentlyPlayedGames(
            playerId: playerId,
            language: language ?? EveryMatrixUnifiedConfiguration.shared.defaultLanguage,
            platform: platform ?? "iPhone",
            offset: pagination.offset,
            limit: pagination.limit
        )
        
        let publisher: AnyPublisher<EveryMatrix.CasinoRecentlyPlayedResponse, ServiceProviderError> = self.restConnector.request(endpoint)
        
        return publisher
            .map { response in
                let games = response.items.compactMap(\.content).compactMap { item in
                    item.gameModel?.content.map { EveryMatrixModelMapper.casinoGame(from: $0) }
                }
                
                return CasinoGamesResponse(
                    count: games.count,
                    total: response.total ?? 0,
                    games: games,
                    pagination: response.pages.map { EveryMatrixModelMapper.casinoPaginationInfo(from: $0) }
                )
            }
            .eraseToAnyPublisher()
    }
    
    func getMostPlayedGames(playerId: String, language: String?, platform: String?, pagination: CasinoPaginationParams) -> AnyPublisher<CasinoGamesResponse, ServiceProviderError> {
        
        guard restConnector.sessionToken != nil else {
            return Just(CasinoGamesResponse(
                count: 0,
                total: 0,
                games: [],
                pagination: nil
            ))
            .setFailureType(to: ServiceProviderError.self)
            .eraseToAnyPublisher()
        }
        
        let endpoint = EveryMatrixPlayerAPI.getMostPlayedGames(
            playerId: playerId,
            language: language ?? EveryMatrixUnifiedConfiguration.shared.defaultLanguage,
            platform: platform ?? "iPhone",
            offset: pagination.offset,
            limit: pagination.limit
        )
        
        let publisher: AnyPublisher<EveryMatrix.CasinoRecentlyPlayedResponse, ServiceProviderError> = self.restConnector.request(endpoint)
        
        return publisher
            .map { response in
                let games = response.items.compactMap(\.content).compactMap { item in
                    item.gameModel?.content.map { EveryMatrixModelMapper.casinoGame(from: $0) }
                }
                
                return CasinoGamesResponse(
                    count: games.count,
                    total: response.total ?? 0,
                    games: games,
                    pagination: response.pages.map { EveryMatrixModelMapper.casinoPaginationInfo(from: $0) }
                )
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Betting Offer Booking Methods

    func createBookingCode(bettingOfferIds: [String], originalSelectionsLength: Int) -> AnyPublisher<BookingCodeResponse, ServiceProviderError> {
        let endpoint = EveryMatrixPlayerAPI.createBookingCode(bettingOfferIds: bettingOfferIds, originalSelectionsLength: originalSelectionsLength)

        return restConnector.request(endpoint)
            .map { (response: BookingCodeResponse) -> BookingCodeResponse in
                return response
            }
            .mapError { error in
                print("[EveryMatrixPrivilegedAccessManager] Failed to create booking code: \(error)")
                return ServiceProviderError.errorMessage(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    func getBettingOfferIds(bookingCode: String) -> AnyPublisher<[String], ServiceProviderError> {
        print("[EveryMatrixPrivilegedAccessManager] 🔍 Retrieving betting offers for booking code: \(bookingCode)")

        let endpoint = EveryMatrixPlayerAPI.getFromBookingCode(code: bookingCode)

        return restConnector.request(endpoint)
            .map { (response: BookingRetrievalResponse) -> [String] in
                let bettingOfferIds = response.selections.map { $0.bettingOfferId }
                return bettingOfferIds
            }
            .mapError { error in
                print("[EveryMatrixPrivilegedAccessManager] Failed to retrieve booking code: \(error)")
                return ServiceProviderError.errorMessage(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Odds Boost / Bonus Wallet Methods

    func getOddsBoostStairs(currency: String, stakeAmount: Double?, selections: [OddsBoostStairsSelection])
    -> AnyPublisher<OddsBoostStairsResponse?, ServiceProviderError> {

        // Map selections to EveryMatrix format with all required fields
        let mappedSelections = selections.map { selection -> EveryMatrix.BetSelectionPointer in
            return EveryMatrix.BetSelectionPointer(
                outcomeId: selection.outcomeId,
                eventId: selection.eventId,
                marketId: selection.marketId,
                odds: selection.odds.decimalOdd
            )
        }

        let combination = EveryMatrix.BetCombinationSelections(selection: mappedSelections)
        
        // Build request
        let request = EveryMatrix.OddsBoostWalletRequest(
            stakeCurrency: currency,
            stakeAmount: stakeAmount,
            includeVendorConfiguration: true,
            includePotentialOddsBoostWallet: true,
            terminalType: "MOBILE",
            combination: [combination]
        )

        // Create endpoint
        let endpoint = EveryMatrixPlayerAPI.getSportsBonusWallets(request: request)

        // Make API call
        let publisher: AnyPublisher<EveryMatrix.OddsBoostWalletResponse, ServiceProviderError> = self.restConnector.request(endpoint)

        return publisher
            .map { response -> OddsBoostStairsResponse? in
                
                // Map internal response to domain model
                let domainResponse = EveryMatrixModelMapper.oddsBoostStairsResponse(from: response)
                return domainResponse
            }
            .mapError { error in
                print("[EveryMatrixPrivilegedAccessManager] Failed to fetch odds boost stairs: \(error)")
                return ServiceProviderError.errorMessage(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Password Reset Methods
    func getResetPasswordTokenId(mobileNumber: String, mobilePrefix: String) -> AnyPublisher<ResetPasswordTokenResponse, ServiceProviderError> {
        let endpoint = EveryMatrixPlayerAPI.getResetPasswordTokenId(mobileNumber: mobileNumber, mobilePrefix: mobilePrefix)
        let publisher: AnyPublisher<EveryMatrix.ResetPasswordTokenResponse, ServiceProviderError> = self.restConnector.request(endpoint)
        
        return publisher
            .map { internalResponse in
                EveryMatrixModelMapper.resetPasswordTokenResponse(from: internalResponse)
            }
            .mapError { error in
                ServiceProviderError.errorMessage(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    func validateResetPasswordCode(tokenId: String, validationCode: String) -> AnyPublisher<ValidateResetPasswordCodeResponse, ServiceProviderError> {
        let endpoint = EveryMatrixPlayerAPI.validateResetPasswordCode(tokenId: tokenId, validationCode: validationCode)
        let publisher: AnyPublisher<EveryMatrix.ValidateResetPasswordCodeResponse, ServiceProviderError> = self.restConnector.request(endpoint)
        
        return publisher
            .map { internalResponse in
                EveryMatrixModelMapper.validateResetPasswordCodeResponse(from: internalResponse)
            }
            .mapError { error in
                return error
            }
            .eraseToAnyPublisher()
    }

    func resetPasswordWithHashKey(hashKey: String, plainTextPassword: String, isUserHash: Bool) -> AnyPublisher<ResetPasswordByHashKeyResponse, ServiceProviderError> {
        let endpoint = EveryMatrixPlayerAPI.resetPasswordWithHashKey(hashKey: hashKey, plainTextPassword: plainTextPassword, isUserHash: isUserHash)
        let publisher: AnyPublisher<EveryMatrix.ResetPasswordByHashKeyResponse, ServiceProviderError> = self.restConnector.request(endpoint)

        return publisher
            .map { internalResponse in
                EveryMatrixModelMapper.resetPasswordByHashKeyResponse(from: internalResponse)
            }
            .mapError { error in
                return error
            }
            .eraseToAnyPublisher()
    }

    // MARK: - User Info Stream (Wallet + Session SSE)

    func subscribeUserInfoUpdates() -> AnyPublisher<SubscribableContent<UserInfo>, ServiceProviderError> {
        print("[SSEDebug] 📊 EveryMatrixPAMProvider: subscribeUserInfoUpdates() called")

        // DEFENSIVE: Stop any existing manager before creating new one
        // This prevents multiple UserInfoStreamManager instances if called repeatedly
        if let existingManager = userInfoStreamManager {
            print("[SSEDebug] ⚠️ EveryMatrixPAMProvider: Found existing UserInfoStreamManager - stopping it first")
            existingManager.stop(reason: "REPLACING_WITH_NEW_MANAGER")
            userInfoStreamManager = nil
        }

        // Create fresh manager instance
        print("[SSEDebug] 🆕 EveryMatrixPAMProvider: Creating new UserInfoStreamManager")
        userInfoStreamManager = UserInfoStreamManager(
            restConnector: restConnector,
            sseConnector: sseConnector,
            sessionCoordinator: sessionCoordinator
        )

        return userInfoStreamManager!.start()
    }

    func stopUserInfoStream() {
        print("[SSEDebug] 🛑 EveryMatrixPAMProvider: stopUserInfoStream() called")

        if let manager = userInfoStreamManager {
            print("[SSEDebug] 🛑 EveryMatrixPAMProvider: Stopping existing UserInfoStreamManager")
            manager.stop(reason: "STOP_USER_INFO_STREAM")
        } else {
            print("[SSEDebug] ⚠️ EveryMatrixPAMProvider: No UserInfoStreamManager to stop")
        }

        userInfoStreamManager = nil
        print("[SSEDebug] ✅ EveryMatrixPAMProvider: UserInfoStreamManager deallocated")
    }

    func refreshUserBalance() {
        print("🔄 EveryMatrixPAMProvider: Force refreshing balance")
        userInfoStreamManager?.refreshBalance()
    }

}
