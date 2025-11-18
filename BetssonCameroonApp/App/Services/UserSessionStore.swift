//
//  UserSessionStore.swift
//  Sportsbook
//
//  Created by Ruben Roques on 15/09/2021.
//

import Foundation
import Combine
import AppTrackingTransparency
import AdSupport
import ServicesProvider
import XPush

enum UserProfileStatus {
    case anonymous
    case logged
}

enum SessionExpirationReason {
    case sessionExpired(reason: String)  // "Expired", "Kicked", etc.
    case sessionTerminated
}

class UserSessionStore {

    var isLoadingUserSessionPublisher = CurrentValueSubject<Bool, Never>(true)

    var userProfilePublisher = CurrentValueSubject<UserProfile?, Never>(nil)

    var userSessionPublisher = CurrentValueSubject<UserSession?, Never>(nil)

    var userProfileStatusPublisher: AnyPublisher<UserProfileStatus, Never> {
        return self.userProfilePublisher
            .map { profile in
                if profile != nil {
                    return UserProfileStatus.logged
                }
                else {
                    return UserProfileStatus.anonymous
                }
            }
            .eraseToAnyPublisher()
    }

    var userWalletPublisher = CurrentValueSubject<UserWallet?, Never>(nil)
    var userCashbackBalance = CurrentValueSubject<Double?, Never>(nil)

    var loggedUserProfile: UserProfile? {
        return self.userProfilePublisher.value
    }

    private var storedUserPassword: String? {
        if let storedUserSession = self.storedUserSession,
           let passwordData = try? KeychainInterface.readPassword(service: Env.bundleId, account: storedUserSession.userId),
           let password = String(data: passwordData, encoding: .utf8) {
            return password
        }
        else if let userSession = self.storedUserSession {
            return userSession.password
        }
        return nil
    }

    private var isRefreshingUserWallet: Bool = false
    private var storedUserSession: UserSession? {
        // There is a cached session user
        return UserDefaults.standard.userSession
    }

    var loginFlowSuccess: CurrentValueSubject<Bool, Never> = .init(false)
    var passwordChanged: PassthroughSubject<Void, Never> = .init()

    /// Session expiration event publisher
    /// Emits when session expires from SSE to trigger UI alert
    var sessionExpirationPublisher = PassthroughSubject<SessionExpirationReason, Never>()

    var shouldAuthenticateUser = true
    var shouldRecordUserSession = true

    private var cancellables = Set<AnyCancellable>()

    // SSE User Info Stream Management
    private var userInfoStreamCancellable: AnyCancellable?
    private var isWalletSubscriptionActive: Bool = false

    init() {
        self.userSessionPublisher
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userSession in
                self?.saveUserSession(userSession)
            }
            .store(in: &self.cancellables)

        self.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                if let userProfile = userProfile {
                    print("[SSEDebug] 👤 UserSessionStore: User profile updated - will start SSE stream")
                    print("[SSEDebug]    - Username: \(userProfile.username)")
                    print("[SSEDebug]    - UserID: \(userProfile.userIdentifier)")
                    self?.startUserInfoSSEStream()  // Start SSE stream for real-time wallet + session updates
                    self?.updateDeviceIdentifier()
                }
            }
            .store(in: &self.cancellables)

    }

    func startUserSession() {
        print("[AUTH_DEBUG] 🏁 UserSessionStore: startUserSession() called")
        self.startUserSessionIfNeeded()
    }

    func isUserLogged() -> Bool {
        let isLogged = self.userProfilePublisher.value != nil
        print("[AUTH_DEBUG] 🔍 UserSessionStore: isUserLogged() = \(isLogged)")
        if let profile = self.userProfilePublisher.value {
            print("[AUTH_DEBUG] 🔍 UserSessionStore: User profile exists - username: \(profile.username)")
        } else {
            print("[AUTH_DEBUG] 🔍 UserSessionStore: No user profile found")
        }
        return isLogged
    }

    func saveUserSession(_ userSession: UserSession) {
        if UserDefaults.standard.userSession != nil {
            return
        }
        if let password = userSession.password, let passwordData = password.data(using: .utf8) {
            do {
                try KeychainInterface.save(password: passwordData, service: Env.bundleId, account: userSession.userId)
            }
            catch {
                shouldRecordUserSession = false
            }
        }

        UserDefaults.standard.userSession = userSession.safeUserSession
    }

    func updatePassword(newPassword password: String) {
        guard
            var session = self.storedUserSession
        else {
            return
        }

        session.password = password
        self.saveUserSession(session)
    }

    /// Logout user and cleanup session
    /// - Parameter reason: Optional reason for logout (e.g., "SESSION_EXPIRATION", "MANUAL", "INVALID_CREDENTIALS")
    func logout(reason: String? = nil) {
        let reasonText = reason ?? "MANUAL"
        print("[SSEDebug] 🚪 UserSessionStore: Logout triggered (reason: \(reasonText))")

        Env.userSessionStore.loginFlowSuccess.send(false)

        if !self.isUserLogged() {
            // There is no user logged in
            print("[SSEDebug] ⚠️ UserSessionStore: No user logged in, skipping logout")
            self.isLoadingUserSessionPublisher.send(false)
            return
        }

        if let userSession = self.storedUserSession {
            try? KeychainInterface.deletePassword(service: Env.bundleId, account: userSession.userId)
        }

        UserDefaults.standard.userSession = nil

        Env.favoritesManager.clearCachedFavorites()

        // Stop SSE stream and cleanup
        print("[SSEDebug] 🛑 UserSessionStore: Stopping SSE stream (logout reason: \(reasonText))")
        self.stopUserInfoSSEStream()

        self.userProfilePublisher.send(nil)
        self.userSessionPublisher.send(nil)
        self.userWalletPublisher.send(nil)
        self.userCashbackBalance.send(nil)

        // ⚠️ CRITICAL SECURITY & PRIVACY ISSUE - COMMENTED OUT PER CLIENT REQUEST
        // XtremePush team instructed NOT to unregister users on logout.
        //
        // THIS IS A BAD IDEA FOR MULTIPLE REASONS:
        // 1. PRIVACY VIOLATION: Logged-out users will continue receiving push notifications
        //    for account activities, bets, deposits, etc. that may contain sensitive info
        // 2. WRONG USER NOTIFICATIONS: If another user logs in on the same device,
        //    they will receive notifications intended for the previous user
        // 3. USER EXPERIENCE: Confusing/annoying to receive notifications after logout
        // 4. SECURITY: Push notifications may leak sensitive betting/financial information
        //    to unauthorized users of the device
        //
        // PROPER BEHAVIOR: Should call clearXtremePushUser() here to unlink device from user account
        //
        // TODO: Revisit this decision with XtremePush and client - this WILL cause issues
        // Date commented: 2025-11-06
        // Requested by: XtremePush team (via client)
        //
        // self.clearXtremePushUser()
        //
    }

    func login(withUsername username: String, password: String) -> AnyPublisher<Void, UserSessionError> {
        print("[AUTH_DEBUG] 🔐 UserSessionStore: login() called with username: \(username)")

        let publisher = Env.servicesProvider.loginUser(withUsername: username, andPassword: password)
            .mapError { (error: ServiceProviderError) -> UserSessionError in
                switch error {
                case .invalidEmailPassword:
                    return .invalidEmailPassword
                case .quickSignUpIncomplete:
                    return .quickSignUpIncomplete
                case .errorMessage(let message):
                    return .errorMessage(errorMessage: message)
                case .errorDetailedMessage(_, let message):
                    return .errorMessage(errorMessage: message)
                case .failedTempLock(let date):
                    return .failedTempLock(date: date)
                default:
                    return .serverError
                }
            }
            .map({ (serviceProviderProfile: ServicesProvider.UserProfile) in
                return ServiceProviderModelMapper.userProfile(serviceProviderProfile)
            })
            .map { (userProfile: UserProfile) -> (UserSession, UserProfile) in
                let session = UserSession(username: userProfile.username,
                                          password: password,
                                          email: userProfile.email,
                                          userId: userProfile.userIdentifier,
                                          birthDate: userProfile.birthDate.toString(),
                                          avatarName: userProfile.avatarName)

                return (session, userProfile)
            }
            .handleEvents(receiveOutput: { [weak self] session, profile in
                print("[AUTH_DEBUG] UserSessionStore: Login successful!")
                print("[AUTH_DEBUG] UserSessionStore: Session userId: \(session.userId)")
                print("[AUTH_DEBUG] UserSessionStore: Profile username: \(profile.username)")

                self?.shouldAuthenticateUser = false

                self?.userSessionPublisher.send(session)
                self?.userProfilePublisher.send(profile)

                // Set XtremePush user with phone number
                self?.setXtremePushUser(from: profile)
            })
            .map({ _ in
                return ()
            })
            .eraseToAnyPublisher()
        
        return publisher
    }
    
    func registerUser(form: ServicesProvider.SimpleSignUpForm) -> AnyPublisher<Void, RegisterUserError> {
        return Env.servicesProvider.signUp(with: .simple(form))
            .mapError { (error: ServiceProviderError) -> RegisterUserError in
                switch error {
                case ServiceProviderError.invalidSignUpUsername:
                    return RegisterUserError.usernameInvalid
                case ServiceProviderError.invalidSignUpEmail:
                    return RegisterUserError.emailInvalid
                case ServiceProviderError.invalidSignUpPassword:
                    return RegisterUserError.passwordInvalid
                case ServiceProviderError.invalidResponse:
                    return RegisterUserError.serverError
                default:
                    return RegisterUserError.serverError
                }
            }
            .map { _ in return () }
            .eraseToAnyPublisher()

    }

    func logoutOnPasswordChanged() {
        self.logout()
        self.passwordChanged.send()
    }

}

extension UserSessionStore {
    
    private func updateDeviceIdentifier() {
        
        var versionCode = ""
        if let buildNumber = Bundle.main.buildNumber {
            versionCode = buildNumber
        }
        
        if !Env.deviceFirebaseCloudMessagingToken.isEmpty {
            Env.servicesProvider
                .updateDeviceIdentifier(deviceIdentifier: Env.deviceFirebaseCloudMessagingToken, appVersion: versionCode)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    print("UserSessionStore updateDeviceIdentifier completed: \(completion)")
                } receiveValue: { response in
                    print("UserSessionStore updateDeviceIdentifier response: \(response)")
                }
                .store(in: &self.cancellables)

        }
        
    }
    
}

extension UserSessionStore {

    func refreshUserProfile() {
        self.startUserSessionIfNeeded()
    }

    func refreshProfile() {
        Env.servicesProvider.getProfile()
            .map(ServiceProviderModelMapper.userProfile(_:))
            .sink { completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let serviceProviderError):
                    print("UserSessionStore refreshProfile error: \(serviceProviderError)")
                }
            } receiveValue: { [weak self] userProfile in
                self?.userProfilePublisher.send(userProfile)
            }
            .store(in: &self.cancellables)
    }

    func getProfile() -> AnyPublisher<UserProfile?, Never> {
        return Env.servicesProvider.getProfile()
            .map(ServiceProviderModelMapper.userProfile(_:))
            .handleEvents(receiveOutput: { [weak self] userProfile in
                self?.userProfilePublisher.send(userProfile)
            })
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

}

extension UserSessionStore {

    func refreshUserWalletAfterDelay() {
        executeDelayed(0.3) {
            self.forceRefreshUserWallet()
        }
    }

    /// Force refresh wallet balance via REST (while SSE continues in background)
    /// Use this for pull-to-refresh scenarios or when SSE may be delayed
    func forceRefreshUserWallet() {
        guard self.isUserLogged() else {
            self.isRefreshingUserWallet = false
            return
        }

        if self.isRefreshingUserWallet {
            // a refresh is in progress
            return
        }

        self.refreshCashbackBalance()

        self.isRefreshingUserWallet = true

        print("UserSessionStore - will forceRefreshUserWallet via REST")

        // If SSE is active, use SSE force refresh (keeps stream alive)
        if self.isWalletSubscriptionActive {
            // Env.servicesProvider.refreshUserBalance()
            self.isRefreshingUserWallet = false
            return
        }

        // Fallback: Direct REST call if SSE not active
        Env.servicesProvider.getUserBalance()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.userWalletPublisher.send(nil)
                }
                self?.isRefreshingUserWallet = false
            }, receiveValue: { [weak self] (userWallet: ServicesProvider.UserWallet) in
                guard
                    let currency = userWallet.currency,
                    let withdrawable = userWallet.withdrawable,
                    let bonus = userWallet.bonus

                else {
                    self?.userWalletPublisher.send(nil)
                    return
                }

                let totalBalance = withdrawable + bonus

                let wallet = UserWallet(total: totalBalance,
                                        totalRealAmount: userWallet.totalRealAmount,
                                        bonus: userWallet.bonus,
                                        totalWithdrawable: userWallet.withdrawable,
                                        currency: currency)
                self?.userWalletPublisher.send(wallet)
            })
            .store(in: &self.cancellables)
    }

    /// Backward compatibility alias
    @available(*, deprecated, message: "Use forceRefreshUserWallet() instead - SSE provides automatic updates")
    func refreshUserWallet() {
        forceRefreshUserWallet()
    }

    private func refreshCashbackBalance() {

        Env.servicesProvider.getUserCashbackBalance()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.userCashbackBalance.send(nil)
                }
            }, receiveValue: { [weak self] (cashbackBalance: ServicesProvider.CashbackBalance) in
                guard
                    let balance = cashbackBalance.balance
                else {
                    self?.userCashbackBalance.send(nil)
                    return
                }
                let cashbackBalance = Double(balance)
                self?.userCashbackBalance.send(cashbackBalance)
            })
            .store(in: &self.cancellables)
    }

    // MARK: - SSE User Info Stream Management

    /// Start real-time SSE stream for wallet balance and session updates
    /// Replaces periodic REST polling with continuous SSE updates
    private func startUserInfoSSEStream() {
        guard self.isUserLogged() else {
            print("[SSEDebug] ⚠️ UserSessionStore: Cannot start SSE stream - user not logged in")
            return
        }

        // DEFENSIVE: Stop any existing stream before starting new one
        // This prevents duplicate subscriptions if called multiple times
        if self.isWalletSubscriptionActive || self.userInfoStreamCancellable != nil {
            print("[SSEDebug] ⚠️ UserSessionStore: SSE stream already active - stopping old stream first")
            self.stopUserInfoSSEStream()
        }

        print("[SSEDebug] 🚀 UserSessionStore: Starting UserInfo SSE stream")
        print("[SSEDebug]    - About to call servicesProvider.subscribeUserInfoUpdates()")

        // Also refresh cashback (not part of UserInfo SSE yet)
        self.refreshCashbackBalance()

        self.userInfoStreamCancellable = Env.servicesProvider.subscribeUserInfoUpdates()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    print("[SSEDebug] 🔌 UserSessionStore: SSE stream completed")
                    self?.isWalletSubscriptionActive = false

                    switch completion {
                    case .finished:
                        print("[SSEDebug] ✅ UserSessionStore: SSE stream finished normally")
                    case .failure(let error):
                        print("[SSEDebug] ❌ UserSessionStore: SSE stream error: \(error)")
                    }
                },
                receiveValue: { [weak self] event in
                    guard let self = self else { return }

                    print("[SSEDebug] 📨 UserSessionStore: Received SSE event: \(event)")

                    switch event {
                    case .connected(let subscription):
                        print("[SSEDebug] ✅ UserSessionStore: SSE connected - subscription ID: \(subscription.id)")
                        self.isWalletSubscriptionActive = true

                    case .contentUpdate(let userInfo):
                        // Handle session expiration
                        switch userInfo.sessionState {
                        case .expired(let reason):
                            print("[SSEDebug] ⚠️ UserSessionStore: Session expired from SSE - reason: \(reason ?? "unknown")")
                            print("[SSEDebug] 📢 UserSessionStore: Publishing session expiration event")

                            // Publish session expiration event BEFORE logout
                            self.sessionExpirationPublisher.send(.sessionExpired(reason: reason ?? "unknown"))

                            print("[SSEDebug] 🚪 UserSessionStore: Auto-logout will be triggered by SESSION_EXPIRATION")
                            self.logout(reason: "SESSION_EXPIRATION")
                            return

                        case .terminated:
                            print("[SSEDebug] ⚠️ UserSessionStore: Session terminated from SSE")
                            print("[SSEDebug] 📢 UserSessionStore: Publishing session termination event")

                            // Publish session termination event BEFORE logout
                            self.sessionExpirationPublisher.send(.sessionTerminated)

                            print("[SSEDebug] 🚪 UserSessionStore: Auto-logout will be triggered by SESSION_TERMINATED")
                            self.logout(reason: "SESSION_TERMINATED")
                            return

                        case .active:
                            // Session is active, process wallet update
                            break
                        }

                        // Update wallet balance from SSE event
                        guard let currency = userInfo.wallet.currency else {
                            print("[SSEDebug] ⚠️ UserSessionStore: SSE update missing currency, skipping")
                            return
                        }

                        let totalBalance = (userInfo.wallet.withdrawable ?? 0) + (userInfo.wallet.bonus ?? 0)

                        let wallet = UserWallet(
                            total: totalBalance,
                            totalRealAmount: userInfo.wallet.totalRealAmount,
                            bonus: userInfo.wallet.bonus,
                            totalWithdrawable: userInfo.wallet.withdrawable,
                            currency: currency
                        )

                        print("[SSEDebug] 💰 UserSessionStore: SSE wallet update - total: \(totalBalance) \(currency)")

                        // Publish to all subscribers (21 wallet subscribers get real-time updates!)
                        self.userWalletPublisher.send(wallet)

                    case .disconnected:
                        print("[SSEDebug] 🔌 UserSessionStore: SSE disconnected")
                        self.isWalletSubscriptionActive = false
                    }
                }
            )
    }

    /// Stop SSE stream and cleanup resources
    private func stopUserInfoSSEStream() {
        guard self.isWalletSubscriptionActive || self.userInfoStreamCancellable != nil else {
            return
        }

        print("[SSEDebug] 🛑 UserSessionStore: Stopping UserInfo SSE stream")

        Env.servicesProvider.stopUserInfoStream()
        self.userInfoStreamCancellable?.cancel()
        self.userInfoStreamCancellable = nil
        self.isWalletSubscriptionActive = false
    }

}

extension UserSessionStore {

    func startUserSessionIfNeeded() {
        print("[AUTH_DEBUG] 🚀 UserSessionStore: startUserSessionIfNeeded() called")

        self.isLoadingUserSessionPublisher.send(true)

        guard
            let user = self.storedUserSession,
            let userPassword = self.storedUserPassword
        else {
            print("[AUTH_DEBUG] ❌ UserSessionStore: No stored user session found - user is anonymous")
            self.isLoadingUserSessionPublisher.send(false)
            return
        }

        print("[AUTH_DEBUG] 💾 UserSessionStore: Stored user session found for username: \(user.username)")
        print("[AUTH_DEBUG] 🔄 UserSessionStore: Attempting auto-login with stored credentials")

        // Trigger internal login
        self.login(withUsername: user.username, password: userPassword)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("[AUTH_DEBUG] ❌ UserSessionStore: Auto-login failed with error: \(error)")
                    switch error {
                    case .invalidEmailPassword:
                        print("[AUTH_DEBUG] 🚫 UserSessionStore: Invalid credentials - logging out")
                        self?.logout(reason: "INVALID_CREDENTIALS")
                    case .quickSignUpIncomplete:
                        print("[AUTH_DEBUG] 🚫 UserSessionStore: Incomplete signup - logging out")
                        self?.logout(reason: "INCOMPLETE_SIGNUP")
                    case .restrictedCountry:
                        print("[AUTH_DEBUG] 🌍 UserSessionStore: Restricted country")
                        break
                    case .serverError:
                        print("[AUTH_DEBUG] 🔴 UserSessionStore: Server error")
                        break
                    case .errorMessage(let msg):
                        print("[AUTH_DEBUG] 💬 UserSessionStore: Error message: \(msg)")
                        break
                    case .failedTempLock:
                        print("[AUTH_DEBUG] 🔒 UserSessionStore: Account temporarily locked")
                        break
                    }
                case .finished:
                    print("[AUTH_DEBUG] ✅ UserSessionStore: Auto-login completed successfully")
                }
                self?.isLoadingUserSessionPublisher.send(false)
                Env.userSessionStore.loginFlowSuccess.send(true)
            }, receiveValue: {

            })
            .store(in: &cancellables)
    }

}

extension UserSessionStore {

    func setShouldRequestBiometrics(_ newValue: Bool) {
        UserDefaults.standard.biometricAuthenticationEnabled = newValue
    }

    func shouldRequestBiometrics() -> Bool {
        let hasStoredUserSession = self.storedUserSession != nil
        return hasStoredUserSession && UserDefaults.standard.biometricAuthenticationEnabled
    }

}

// MARK: - XtremePush Integration

extension UserSessionStore {

    /// Sets the XtremePush user identifier using phone number (or userIdentifier as fallback)
    private func setXtremePushUser(from profile: UserProfile) {
        let phoneNumber = extractPhoneNumber(from: profile)
        let userIdentifier = phoneNumber.isEmpty ? profile.userIdentifier : phoneNumber

        print("[XTREMEPUSH] 📞 Setting user identifier: \(userIdentifier)")
        print("[XTREMEPUSH] 📊 Username: \(profile.username)")
        print("[XTREMEPUSH] 📊 PhoneNumber field: \(profile.phoneNumber ?? "nil")")
        print("[XTREMEPUSH] 📊 MobileCountryCode: \(profile.mobileCountryCode ?? "nil")")
        print("[XTREMEPUSH] 📊 MobilePhone: \(profile.mobilePhone ?? "nil")")
        print("[XTREMEPUSH] 📊 Extracted: \(phoneNumber)")

        XPush.setUser(userIdentifier)
    }

    /// Clears the XtremePush user identifier on logout
    private func clearXtremePushUser() {
        print("[XTREMEPUSH] 🗑️ Clearing user identifier")
        XPush.setUser(nil)
    }

    /// Extracts phone number from user profile with fallback chain
    /// Priority: username (if starts with +) → mobileCountryCode+mobilePhone → phoneNumber → empty
    private func extractPhoneNumber(from profile: UserProfile) -> String {
        // Priority 1: username (contains full phone number)
        // Example: "+237699198921"
        if profile.username.hasPrefix("+") {
            return profile.username
        }

        // Priority 2: Construct from mobileCountryCode + mobilePhone
        // Example: "+237" + "699198921" = "+237699198921"
        if let countryCode = profile.mobileCountryCode,
           let localNumber = profile.mobilePhone,
           !countryCode.isEmpty, !localNumber.isEmpty {
            return "\(countryCode)\(localNumber)"
        }

        // Priority 3: phoneNumber field (if populated)
        if let phoneNumber = profile.phoneNumber,
           !phoneNumber.isEmpty,
           phoneNumber != "" {
            return phoneNumber
        }

        // Priority 4: mobileCountryCode + mobileLocalNumber
        if let countryCode = profile.mobileCountryCode,
           let localNumber = profile.mobileLocalNumber,
           !countryCode.isEmpty, !localNumber.isEmpty {
            return "\(countryCode)\(localNumber)"
        }

        // No phone number available
        return ""
    }

}
