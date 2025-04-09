import Foundation
import Combine

/// Concrete client for EveryMatrixPAMAPIClient API
public class EveryMatrixPAMAPIClient {
    /// The network client used for making requests
    private let networkClient: NetworkClient

    /// Initialize a new EveryMatrixPAMAPIClientClient
    /// - Parameter networkClient: NetworkClient to use for API requests (defaults to a new instance)
    public init(networkClient: NetworkClient = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    /// Async/await version
    public func getPlayersDocuments(playerId: Int64, xSessionid: String, xSessionType: String? = nil) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayersDocuments(playerId: playerId, xSessionID: xSessionid, xSessionType)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayersDocumentsPublisher(playerId: Int64, xSessionid: String, xSessionType: String? = nil) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayersDocuments(playerId: playerId, xSessionID: xSessionid, xSessionType)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func addUserDocuments(playerId: String, xSessionid: String, xSessionType: String? = nil, body: Any) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.addUserDocuments(playerId: playerId, xSessionID: xSessionid, xSessionType: xSessionType)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func addUserDocumentsPublisher(playerId: String, xSessionid: String, xSessionType: String? = nil, body: Any) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.addUserDocuments(playerId: playerId, xSessionID: xSessionid, xSessionType: xSessionType)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayerPlayerIdProfile(playerId: String, xSessionid: String, xSessionType: String? = nil) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerPlayerIdProfile(playerId: playerId, xSessionID: xSessionid, xSessionType)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayerPlayerIdProfilePublisher(playerId: String, xSessionid: String, xSessionType: String? = nil) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerPlayerIdProfile(playerId: playerId, xSessionID: xSessionid, xSessionType)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func putPlayerPlayerIdProfile(xSessionid: String, playerId: String, body: Any) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.putPlayerPlayerIdProfile(xSessionID: xSessionid, playerId: playerId)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func putPlayerPlayerIdProfilePublisher(xSessionid: String, playerId: String, body: Any) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.putPlayerPlayerIdProfile(xSessionID: xSessionid, playerId: playerId)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func postPlayerPlayerIdProfile(playerId: String, xSessionid: String, body: Any) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.postPlayerPlayerIdProfile(playerId: playerId, xSessionID: xSessionid)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func postPlayerPlayerIdProfilePublisher(playerId: String, xSessionid: String, body: Any) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.postPlayerPlayerIdProfile(playerId: playerId, xSessionID: xSessionid)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayersPlaymentLimits(playerId: Int64, xSessionid: String, xSessionType: String? = nil, pagination: String? = nil) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayersPlaymentLimits(playerId: playerId, xSessionID: xSessionid, xSessionType: xSessionType, pagination)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayersPlaymentLimitsPublisher(playerId: Int64, xSessionid: String, xSessionType: String? = nil, pagination: String? = nil) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayersPlaymentLimits(playerId: playerId, xSessionID: xSessionid, xSessionType: xSessionType, pagination)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayerGmcoreLimits(playerId: String, xSessionid: String, xSessionType: String? = nil) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerGmcoreLimits(playerId: playerId, xSessionID: xSessionid, xSessionType)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayerGmcoreLimitsPublisher(playerId: String, xSessionid: String, xSessionType: String? = nil) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerGmcoreLimits(playerId: playerId, xSessionID: xSessionid, xSessionType)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func updatePlayerLimitDefinitions(definitionId: String, playerId: String, xSessionid: String, xSessionType: String? = nil, body: Any) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.updatePlayerLimitDefinitions(definitionId: definitionId, playerId: playerId, xSessionID: xSessionid, xSessionType: xSessionType)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func updatePlayerLimitDefinitionsPublisher(definitionId: String, playerId: String, xSessionid: String, xSessionType: String? = nil, body: Any) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.updatePlayerLimitDefinitions(definitionId: definitionId, playerId: playerId, xSessionID: xSessionid, xSessionType: xSessionType)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func putPlayerSystemWithdraw(playerId: String, xSessionid: String, body: Any) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.putPlayerSystemWithdraw(playerId: playerId, xSessionID: xSessionid)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func putPlayerSystemWithdrawPublisher(playerId: String, xSessionid: String, body: Any) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.putPlayerSystemWithdraw(playerId: playerId, xSessionID: xSessionid)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func putPlayerSystemDeposit(playerId: String, xSessionid: String, body: Any) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.putPlayerSystemDeposit(playerId: playerId, xSessionID: xSessionid)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func putPlayerSystemDepositPublisher(playerId: String, xSessionid: String, body: Any) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.putPlayerSystemDeposit(playerId: playerId, xSessionID: xSessionid)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func putPlayerPlayerIdRegisterPlayer(gRecaptchaResponse: String? = nil, cfCaptchaResponse: String? = nil, cfCaptchaIsVisible: Bool? = nil, recaptchaACSSessionId: String? = nil, nwaClientIp: String? = nil, body: Any) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.putPlayerPlayerIdRegisterPlayer(gRecaptchaResponse, cfCaptchaResponse, cfCaptchaIsVisible, recaptchaACSSessionId, nwaClientIp)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func putPlayerPlayerIdRegisterPlayerPublisher(gRecaptchaResponse: String? = nil, cfCaptchaResponse: String? = nil, cfCaptchaIsVisible: Bool? = nil, recaptchaACSSessionId: String? = nil, nwaClientIp: String? = nil, body: Any) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.putPlayerPlayerIdRegisterPlayer(gRecaptchaResponse, cfCaptchaResponse, cfCaptchaIsVisible, recaptchaACSSessionId, nwaClientIp)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func putPlayerPlayerIdQuickRegisterPlayer(gRecaptchaResponse: String? = nil, cfCaptchaResponse: String? = nil, cfCaptchaIsVisible: Bool? = nil, recaptchaACSSessionId: String? = nil, nwaClientIp: String? = nil, body: Any) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.putPlayerPlayerIdQuickRegisterPlayer(gRecaptchaResponse, cfCaptchaResponse, cfCaptchaIsVisible, recaptchaACSSessionId, nwaClientIp)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func putPlayerPlayerIdQuickRegisterPlayerPublisher(gRecaptchaResponse: String? = nil, cfCaptchaResponse: String? = nil, cfCaptchaIsVisible: Bool? = nil, recaptchaACSSessionId: String? = nil, nwaClientIp: String? = nil, body: Any) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.putPlayerPlayerIdQuickRegisterPlayer(gRecaptchaResponse, cfCaptchaResponse, cfCaptchaIsVisible, recaptchaACSSessionId, nwaClientIp)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayerPaymentTransactionsHistory(playerId: String, xSessionid: String, body: Any) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerPaymentTransactionsHistory(playerId: playerId, xSessionID: xSessionid)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayerPaymentTransactionsHistoryPublisher(playerId: String, xSessionid: String, body: Any) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerPaymentTransactionsHistory(playerId: playerId, xSessionID: xSessionid)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayerPaymentSession(playerId: String, xSessionid: String, nwaClientIp: String? = nil, body: Any) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerPaymentSession(playerId: playerId, xSessionID: xSessionid, nwaClientIp)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayerPaymentSessionPublisher(playerId: String, xSessionid: String, nwaClientIp: String? = nil, body: Any) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerPaymentSession(playerId: playerId, xSessionID: xSessionid, nwaClientIp)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayerPaymentPrepare(playerId: String, body: Any) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerPaymentPrepare(playerId: playerId)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayerPaymentPreparePublisher(playerId: String, body: Any) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerPaymentPrepare(playerId: playerId)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayerPaymentMethod(playerId: String, body: Any) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerPaymentMethod(playerId: playerId)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayerPaymentMethodPublisher(playerId: String, body: Any) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerPaymentMethod(playerId: playerId)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayerPaymentInfo(playerId: String, xSessionid: String, body: Any) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerPaymentInfo(playerId: playerId, xSessionID: xSessionid)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayerPaymentInfoPublisher(playerId: String, xSessionid: String, body: Any) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerPaymentInfo(playerId: playerId, xSessionID: xSessionid)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayerPaymentConfirm(playerId: String, body: Any) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerPaymentConfirm(playerId: playerId)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayerPaymentConfirmPublisher(playerId: String, body: Any) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerPaymentConfirm(playerId: playerId)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func postPlayerPlayerIdChangePlayerPassword(xSessionid: String, playerId: String, body: Any) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.postPlayerPlayerIdChangePlayerPassword(xSessionID: xSessionid, playerId: playerId)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func postPlayerPlayerIdChangePlayerPasswordPublisher(xSessionid: String, playerId: String, body: Any) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.postPlayerPlayerIdChangePlayerPassword(xSessionID: xSessionid, playerId: playerId)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayerLimitDefinitionsPlayerId(playerId: String, xSessionid: String, xSessionType: String? = nil) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerLimitDefinitionsPlayerId(playerId: playerId, xSessionID: xSessionid, xSessionType)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayerLimitDefinitionsPlayerIdPublisher(playerId: String, xSessionid: String, xSessionType: String? = nil) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerLimitDefinitionsPlayerId(playerId: playerId, xSessionID: xSessionid, xSessionType)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayersLegislationUserConsents(playerId: String, xSessionid: String, xSessionType: String? = nil) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayersLegislationUserConsents(playerId: playerId, xSessionID: xSessionid, xSessionType)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayersLegislationUserConsentsPublisher(playerId: String, xSessionid: String, xSessionType: String? = nil) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayersLegislationUserConsents(playerId: playerId, xSessionID: xSessionid, xSessionType)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func postPlayersLegislationUserConsents(playerId: String, xSessionid: String, xSessionType: String? = nil, body: Any) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.postPlayersLegislationUserConsents(playerId: playerId, xSessionID: xSessionid, xSessionType: xSessionType)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func postPlayersLegislationUserConsentsPublisher(playerId: String, xSessionid: String, xSessionType: String? = nil, body: Any) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.postPlayersLegislationUserConsents(playerId: playerId, xSessionID: xSessionid, xSessionType: xSessionType)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayerListUserConsent(playerId: String, xSessionid: String, xSessionType: String? = nil) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerListUserConsent(playerId: playerId, xSessionID: xSessionid, xSessionType)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayerListUserConsentPublisher(playerId: String, xSessionid: String, xSessionType: String? = nil) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerListUserConsent(playerId: playerId, xSessionID: xSessionid, xSessionType)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func postPlayersClaimBonus(playerId: String, xSessionid: String, xSessionType: String? = nil, currency: String? = nil, bonusCode: String? = nil) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.postPlayersClaimBonus(playerId: playerId, xSessionID: xSessionid, xSessionType: xSessionType, currency, bonusCode)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func postPlayersClaimBonusPublisher(playerId: String, xSessionid: String, xSessionType: String? = nil, currency: String? = nil, bonusCode: String? = nil) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.postPlayersClaimBonus(playerId: playerId, xSessionID: xSessionid, xSessionType: xSessionType, currency, bonusCode)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func postPlayerUpdatePlayerActiveStatus(playerId: String, xSessionid: String, xSessionType: String? = nil, newStatus: String, blockType: String? = nil) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.postPlayerUpdatePlayerActiveStatus(playerId: playerId, xSessionID: xSessionid, xSessionType: xSessionType, newStatus, blockType)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func postPlayerUpdatePlayerActiveStatusPublisher(playerId: String, xSessionid: String, xSessionType: String? = nil, newStatus: String, blockType: String? = nil) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.postPlayerUpdatePlayerActiveStatus(playerId: playerId, xSessionID: xSessionid, xSessionType: xSessionType, newStatus, blockType)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func postPlayerSmsTokenGenerate(body: Any) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.postPlayerSmsTokenGenerate(body)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func postPlayerSmsTokenGeneratePublisher(body: Any) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.postPlayerSmsTokenGenerate(body)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func setPlayerConfiguredSessionAmounts(xSessionid: String, body: Any) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.setPlayerConfiguredSessionAmounts(xSessionID: xSessionid)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func setPlayerConfiguredSessionAmountsPublisher(xSessionid: String, body: Any) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.setPlayerConfiguredSessionAmounts(xSessionID: xSessionid)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayer(gRecaptchaResponse: String? = nil, cfCaptchaResponse: String? = nil, cfCaptchaIsVisible: Bool? = nil, email: String, changePasswordUrl: String? = nil, birthDate: String? = nil, recaptchaACSSessionId: String? = nil) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayer(gRecaptchaResponse, cfCaptchaResponse, cfCaptchaIsVisible, email, changePasswordUrl, birthDate, recaptchaACSSessionId)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayerPublisher(gRecaptchaResponse: String? = nil, cfCaptchaResponse: String? = nil, cfCaptchaIsVisible: Bool? = nil, email: String, changePasswordUrl: String? = nil, birthDate: String? = nil, recaptchaACSSessionId: String? = nil) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayer(gRecaptchaResponse, cfCaptchaResponse, cfCaptchaIsVisible, email, changePasswordUrl, birthDate, recaptchaACSSessionId)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func postPlayerLogin(type: String, gRecaptchaResponse: String? = nil, cfCaptchaResponse: String? = nil, cfCaptchaIsVisible: Bool? = nil, recaptchaACSSessionId: String? = nil, nwaClientIp: String? = nil, body: Any) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.postPlayerLogin(type, gRecaptchaResponse, cfCaptchaResponse, cfCaptchaIsVisible, recaptchaACSSessionId, nwaClientIp)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func postPlayerLoginPublisher(type: String, gRecaptchaResponse: String? = nil, cfCaptchaResponse: String? = nil, cfCaptchaIsVisible: Bool? = nil, recaptchaACSSessionId: String? = nil, nwaClientIp: String? = nil, body: Any) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.postPlayerLogin(type, gRecaptchaResponse, cfCaptchaResponse, cfCaptchaIsVisible, recaptchaACSSessionId, nwaClientIp)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayerPlayerIdWallet(playerId: String, xSessionid: String) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerPlayerIdWallet(playerId: playerId, xSessionid)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayerPlayerIdWalletPublisher(playerId: String, xSessionid: String) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerPlayerIdWallet(playerId: playerId, xSessionid)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayerPendingWithdrawals(playerId: String, xSessionid: String, xSessionType: String? = nil, language: String? = nil) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerPendingWithdrawals(playerId: playerId, xSessionID: xSessionid, xSessionType: xSessionType, language)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayerPendingWithdrawalsPublisher(playerId: String, xSessionid: String, xSessionType: String? = nil, language: String? = nil) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerPendingWithdrawals(playerId: playerId, xSessionID: xSessionid, xSessionType: xSessionType, language)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayersEligibleBonus(playerId: String, xSessionid: String, xSessionType: String? = nil, bonusType: String? = nil, intention: String? = nil, transactionType: String? = nil, paymentMethodName: String? = nil, terminal: String? = nil, tag: [String]? = nil, currency: String? = nil, verifyPlayerProfile: Bool? = nil, code: String? = nil, language: String? = nil) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayersEligibleBonus(playerId: playerId, xSessionID: xSessionid, xSessionType: xSessionType, bonusType, intention, transactionType, paymentMethodName, terminal, tag, currency, verifyPlayerProfile, code, language)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayersEligibleBonusPublisher(playerId: String, xSessionid: String, xSessionType: String? = nil, bonusType: String? = nil, intention: String? = nil, transactionType: String? = nil, paymentMethodName: String? = nil, terminal: String? = nil, tag: [String]? = nil, currency: String? = nil, verifyPlayerProfile: Bool? = nil, code: String? = nil, language: String? = nil) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayersEligibleBonus(playerId: playerId, xSessionID: xSessionid, xSessionType: xSessionType, bonusType, intention, transactionType, paymentMethodName, terminal, tag, currency, verifyPlayerProfile, code, language)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayersBonusWallets(xSessionid: String, xSessionType: String? = nil, playerId: Int64, excludeByTimeWindow: Bool? = nil, category: String? = nil, fields: String? = nil, filter: String? = nil, pagination: String? = nil, orderBy: String? = nil, language: String? = nil) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayersBonusWallets(xSessionID: xSessionid, xSessionType: xSessionType, playerId: playerId, excludeByTimeWindow, category, fields, filter, pagination, orderBy, language)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayersBonusWalletsPublisher(xSessionid: String, xSessionType: String? = nil, playerId: Int64, excludeByTimeWindow: Bool? = nil, category: String? = nil, fields: String? = nil, filter: String? = nil, pagination: String? = nil, orderBy: String? = nil, language: String? = nil) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayersBonusWallets(xSessionID: xSessionid, xSessionType: xSessionType, playerId: playerId, excludeByTimeWindow, category, fields, filter, pagination, orderBy, language)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func deletePlayersBonusWallet(playerId: Int64, bonusWalletId: Int64, xSessionid: String, xSessionType: String? = nil) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.deletePlayersBonusWallet(playerId: playerId, bonusWalletId, xSessionID: xSessionid, xSessionType)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func deletePlayersBonusWalletPublisher(playerId: Int64, bonusWalletId: Int64, xSessionid: String, xSessionType: String? = nil) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.deletePlayersBonusWallet(playerId: playerId, bonusWalletId, xSessionID: xSessionid, xSessionType)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayerValidCountryList() async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerValidCountryList
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayerValidCountryListPublisher() -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerValidCountryList
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func postPlayerSmsTokenValidate(id: String, validationCode: String) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.postPlayerSmsTokenValidate(id, validationCode)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func postPlayerSmsTokenValidatePublisher(id: String, validationCode: String) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.postPlayerSmsTokenValidate(id, validationCode)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayerSystemAvailableVendorTypes(xSessionid: String, gmwiOperationType: String) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerSystemAvailableVendorTypes(xSessionID: xSessionid, gmwiOperationType)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayerSystemAvailableVendorTypesPublisher(xSessionid: String, gmwiOperationType: String) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerSystemAvailableVendorTypes(xSessionID: xSessionid, gmwiOperationType)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayerConfiguredSessionAmounts(xSessionid: String) async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerConfiguredSessionAmounts(xSessionid)
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayerConfiguredSessionAmountsPublisher(xSessionid: String) -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerConfiguredSessionAmounts(xSessionid)
        return self.networkClient.requestPublisher(endpoint)
    }
    /// Async/await version
    public func getPlayerCountryList() async throws -> String {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerCountryList
        return try await networkClient.request(endpoint)
    }

    /// Combine publisher version
    public func getPlayerCountryListPublisher() -> AnyPublisher<String, Error> {
        let endpoint = old_EveryMatrixPAMScheme.getPlayerCountryList
        return self.networkClient.requestPublisher(endpoint)
    }
}
