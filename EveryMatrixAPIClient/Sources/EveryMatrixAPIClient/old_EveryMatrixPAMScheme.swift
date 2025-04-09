import Foundation

/// Generated API client for accessing endpoints
public enum old_EveryMatrixPAMScheme: Endpoint {
          
    case getPlayersDocuments(playerId: Int64, xSessionID: String, xSessionType: String? = nil)

    case addUserDocuments(playerId: String, xSessionID: String, xSessionType: String? = nil)

    case getPlayerProfile(playerId: String, xSessionID: String, xSessionType: String? = nil)

    case putPlayerProfile(playerId: String, xSessionID: String)

    case postPlayerProfile(playerId: String, xSessionID: String)

    case getPlayersPlaymentLimits(playerId: Int64, pagination: String? = nil, xSessionID: String, xSessionType: String? = nil)

    case getPlayerGmcoreLimits(playerId: String, xSessionID: String, xSessionType: String? = nil)

    case updatePlayerLimitDefinitions(definitionId: String, playerId: String, xSessionID: String, xSessionType: String? = nil)

    case putPlayerSystemWithdraw(playerId: String, xSessionID: String)

    case putPlayerSystemDeposit(playerId: String, xSessionID: String)

    case registerPlayer

    case quickRegisterPlayer

    case getPlayerPaymentTransactionsHistory(playerId: String, xSessionID: String)

    case getPlayerPaymentSession(playerId: String, xSessionID: String, nwaClientIp: String? = nil)

    case getPlayerPaymentPrepare(playerId: String)

    case getPlayerPaymentMethod(playerId: String)

    case getPlayerPaymentInfo(playerId: String, xSessionID: String)

    case getPlayerPaymentConfirm(playerId: String)

    case postPlayerChangePlayerPassword(playerId: String, xSessionID: String)

    case getPlayerLimitDefinitionsPlayerId(playerId: String, xSessionID: String, xSessionType: String? = nil)

    case getPlayersLegislationUserConsents(playerId: String, xSessionID: String, xSessionType: String? = nil)

    case postPlayersLegislationUserConsents(playerId: String, xSessionID: String, xSessionType: String? = nil)

    case getPlayerListUserConsent(playerId: String, xSessionID: String, xSessionType: String? = nil)

    case postPlayersClaimBonus(playerId: String, currency: String? = nil, bonusCode: String? = nil, xSessionID: String, xSessionType: String? = nil)

    case postPlayerUpdatePlayerActiveStatus(playerId: String, newStatus: String, blockType: String? = nil, xSessionID: String, xSessionType: String? = nil)

    case postPlayerSmsTokenGenerate(body: Any)

    case setPlayerConfiguredSessionAmounts(xSessionID: String)

    case getPlayer(email: String, changePasswordUrl: String? = nil, birthDate: String? = nil, recaptchaACSSessionId: String? = nil, gRecaptchaResponse: String? = nil, cfCaptchaResponse: String? = nil, cfCaptchaIsVisible: Bool? = nil)

    case postPlayerLogin(type: String, recaptchaACSSessionId: String? = nil, gRecaptchaResponse: String? = nil, cfCaptchaResponse: String? = nil, cfCaptchaIsVisible: Bool? = nil, nwaClientIp: String? = nil)

    case getPlayerWallet(playerId: String, xSessionID: String)

    case getPlayerPendingWithdrawals(playerId: String, language: String? = nil, xSessionID: String, xSessionType: String? = nil)

    case getPlayersEligibleBonus(playerId: String, bonusType: String? = nil, intention: String? = nil, transactionType: String? = nil, paymentMethodName: String? = nil, terminal: String? = nil, tag: [String]? = nil, currency: String? = nil, verifyPlayerProfile: Bool? = nil, code: String? = nil, language: String? = nil, xSessionID: String, xSessionType: String? = nil)

    case getPlayersBonusWallets(playerId: Int64, excludeByTimeWindow: Bool? = nil, category: String? = nil, fields: String? = nil, filter: String? = nil, pagination: String? = nil, orderBy: String? = nil, language: String? = nil, xSessionID: String, xSessionType: String? = nil)

    case deletePlayersBonusWallet(playerId: Int64, bonusWalletId: Int64, xSessionID: String, xSessionType: String? = nil)

    case getPlayerValidCountryList

    case postPlayerSmsTokenValidate(id: String, validationCode: String)

    case getPlayerSystemAvailableVendorTypes(gmwiOperationType: String, xSessionID: String)

    case getPlayerConfiguredSessionAmounts(xSessionID: String)

    case getPlayerCountryList


    /// Base URL for the API
    public var url: String {
        return "https://betsson-api.stage.norway.everymatrix.com/"
    }

    /// Path component of the endpoint
    public var endpoint: String {
        switch self {
        case .getPlayersDocuments(let playerId, _, _):
            return "/v1/player/\(playerId)/userDocuments"
        case .addUserDocuments(let playerId, _, _):
            return "/v1/player/\(playerId)/userDocuments"
        case .getPlayerProfile(let playerId, _, _):
            return "/v1/player/\(playerId)/profile"
        case .putPlayerProfile(let playerId, _):
            return "/v1/player/\(playerId)/profile"
        case .postPlayerProfile(let playerId, _):
            return "/v1/player/\(playerId)/profile"
        case .getPlayersPlaymentLimits(let playerId, _, _, _):
            return "/v1/player/\(playerId)/paymentLimits"
        case .getPlayerGmcoreLimits(let playerId, _, _):
            return "/v1/player/\(playerId)/limits/session"
        case .updatePlayerLimitDefinitions(let definitionId, let playerId, _, _):
            return "/v1/player/\(playerId)/limits/monetary/\(definitionId)"
        case .putPlayerSystemWithdraw(let playerId, _):
            return "/v1/player/\(playerId)/gmwi/SystemWithdraw"
        case .putPlayerSystemDeposit(let playerId, _):
            return "/v1/player/\(playerId)/gmwi/SystemDeposit"
        case .registerPlayer:
            return "/v1/player/register"
        case .quickRegisterPlayer:
            return "/v1/player/quickRegister"
        case .getPlayerPaymentTransactionsHistory(let playerId, _):
            return "/v1/player/\(playerId)/payment/GetTransactionsHistory"
        case .getPlayerPaymentSession(let playerId, _, _):
            return "/v1/player/\(playerId)/payment/GetPaymentSession"
        case .getPlayerPaymentPrepare(let playerId):
            return "/v1/player/\(playerId)/payment/GetPaymentPrepare"
        case .getPlayerPaymentMethod(let playerId):
            return "/v1/player/\(playerId)/payment/GetPaymentMethod"
        case .getPlayerPaymentInfo(let playerId, _):
            return "/v1/player/\(playerId)/payment/GetPaymentInfo"
        case .getPlayerPaymentConfirm(let playerId):
            return "/v1/player/\(playerId)/payment/GetPaymentConfirm"
        case .postPlayerChangePlayerPassword(let playerId, _):
            return "/v1/player/\(playerId)/password"
        case .getPlayerLimitDefinitionsPlayerId(let playerId, _, _):
            return "/v1/player/\(playerId)/limits/monetary"
        case .getPlayersLegislationUserConsents(let playerId, _, _):
            return "/v1/player/\(playerId)/legislation/consents"
        case .postPlayersLegislationUserConsents(let playerId, _, _):
            return "/v1/player/\(playerId)/legislation/consents"
        case .getPlayerListUserConsent(let playerId, _, _):
            return "/v1/player/\(playerId)/consent"
        case .postPlayersClaimBonus(let playerId, _, _, _, _):
            return "/v1/player/\(playerId)/claimbonus"
        case .postPlayerUpdatePlayerActiveStatus(let playerId, _, _, _, _):
            return "/v1/player/\(playerId)/activestatus"
        case .postPlayerSmsTokenGenerate(_):
            return "/v1/player/sms/token"
        case .setPlayerConfiguredSessionAmounts(_):
            return "/v1/player/setRgNotificationSettings"
        case .getPlayer(_, _, _, _, _, _, _):
            return "/v1/player/resetpassword"
        case .postPlayerLogin(let type, _, _, _, _, _):
            return "/v1/player/login/\(type)"
        case .getPlayerWallet(let playerId, _):
            return "/v1/player/\(playerId)/wallet"
        case .getPlayerPendingWithdrawals(let playerId, _, _, _):
            return "/v1/player/\(playerId)/hostedcashier/pendingwithdrawals"
        case .getPlayersEligibleBonus(let playerId, _, _, _, _, _, _, _, _, _, _, _, _):
            return "/v1/player/\(playerId)/eligiblebonuses"
        case .getPlayersBonusWallets(let playerId, _, _, _, _, _, _, _, _, _):
            return "/v1/player/\(playerId)/bonusWallet"
        case .deletePlayersBonusWallet(let playerId, _, _, _):
            return "/v1/player/\(playerId)/bonusWallet"
        case .getPlayerValidCountryList:
            return "/v1/player/validCountries"
        case .postPlayerSmsTokenValidate(let id, _):
            return "/v1/player/sms/token/\(id)"
        case .getPlayerSystemAvailableVendorTypes(_, _):
            return "/v1/player/gmwi/availableVendorAccountTypes"
        case .getPlayerConfiguredSessionAmounts(_):
            return "/v1/player/getRgNotificationSettings"
        case .getPlayerCountryList:
            return "/v1/player/countries"
        }
    }

    /// HTTP method for the endpoint
    public var method: HTTP.Method {
        switch self {
        case .getPlayersDocuments(_, _, _):
            return .get
        case .addUserDocuments(_, _, _):
            return .put
        case .getPlayerProfile(_, _, _):
            return .get
        case .putPlayerProfile(_, _):
            return .put
        case .postPlayerProfile(_, _):
            return .post
        case .getPlayersPlaymentLimits(_, _, _, _):
            return .get
        case .getPlayerGmcoreLimits(_, _, _):
            return .get
        case .updatePlayerLimitDefinitions(_, _, _, _):
            return .put
        case .putPlayerSystemWithdraw(_, _):
            return .put
        case .putPlayerSystemDeposit(_, _):
            return .put
        case .registerPlayer:
            return .put
        case .quickRegisterPlayer:
            return .put
        case .getPlayerPaymentTransactionsHistory(_, _):
            return .post
        case .getPlayerPaymentSession(_, _, _):
            return .post
        case .getPlayerPaymentPrepare(_):
            return .post
        case .getPlayerPaymentMethod(_):
            return .post
        case .getPlayerPaymentInfo(_, _):
            return .post
        case .getPlayerPaymentConfirm(_):
            return .post
        case .postPlayerChangePlayerPassword(_, _):
            return .post
        case .getPlayerLimitDefinitionsPlayerId(_, _, _):
            return .get
        case .getPlayersLegislationUserConsents(_, _, _):
            return .get
        case .postPlayersLegislationUserConsents(_, _, _):
            return .post
        case .getPlayerListUserConsent(_, _, _):
            return .get
        case .postPlayersClaimBonus(_, _, _, _, _):
            return .post
        case .postPlayerUpdatePlayerActiveStatus(_, _, _, _, _):
            return .post
        case .postPlayerSmsTokenGenerate:
            return .post
        case .setPlayerConfiguredSessionAmounts(_):
            return .post
        case .getPlayer(_, _, _, _, _, _, _):
            return .post
        case .postPlayerLogin(_, _, _, _, _, _):
            return .post
        case .getPlayerWallet(_, _):
            return .get
        case .getPlayerPendingWithdrawals(_, _, _, _):
            return .get
        case .getPlayersEligibleBonus(_, _, _, _, _, _, _, _, _, _, _, _, _):
            return .get
        case .getPlayersBonusWallets(_, _, _, _, _, _, _, _, _, _):
            return .get
        case .deletePlayersBonusWallet(_, _, _, _):
            return .delete
        case .getPlayerValidCountryList:
            return .get
        case .postPlayerSmsTokenValidate(_, _):
            return .get
        case .getPlayerSystemAvailableVendorTypes(_, _):
            return .get
        case .getPlayerConfiguredSessionAmounts(_):
            return .get
        case .getPlayerCountryList:
            return .get
        }
    }

    /// Query parameters for the endpoint
    public var query: [URLQueryItem]? {
        switch self {
        case .getPlayersDocuments(_, _, _):
            return nil
        case .addUserDocuments(_, _, _):
            return nil
        case .getPlayerProfile(_, _, _):
            return nil
        case .putPlayerProfile(_, _):
            return nil
        case .postPlayerProfile(_, _):
            return nil
        case .getPlayersPlaymentLimits(_, let pagination, _, _):
            var queryItems: [URLQueryItem] = []
            if let pagination = pagination {
                queryItems.append(URLQueryItem(name: "pagination", value: String(describing: pagination)))
            }
            return queryItems.isEmpty ? nil : queryItems
        case .getPlayerGmcoreLimits(_, _, _):
            return nil
        case .updatePlayerLimitDefinitions(_, _, _, _):
            return nil
        case .putPlayerSystemWithdraw(_, _):
            return nil
        case .putPlayerSystemDeposit(_, _):
            return nil
        case .registerPlayer:
            return nil
        case .quickRegisterPlayer:
            return nil
        case .getPlayerPaymentTransactionsHistory(_, _):
            return nil
        case .getPlayerPaymentSession(_, _, _):
            return nil
        case .getPlayerPaymentPrepare(_):
            return nil
        case .getPlayerPaymentMethod(_):
            return nil
        case .getPlayerPaymentInfo(_, _):
            return nil
        case .getPlayerPaymentConfirm(_):
            return nil
        case .postPlayerChangePlayerPassword(_, _):
            return nil
        case .getPlayerLimitDefinitionsPlayerId(_, _, _):
            return nil
        case .getPlayersLegislationUserConsents(_, _, _):
            return nil
        case .postPlayersLegislationUserConsents(_, _, _):
            return nil
        case .getPlayerListUserConsent(_, _, _):
            return nil
        case .postPlayersClaimBonus(_, let currency, let bonusCode, _, _):
            var queryItems: [URLQueryItem] = []
            if let currency = currency {
                queryItems.append(URLQueryItem(name: "currency", value: String(describing: currency)))
            }
            if let bonusCode = bonusCode {
                queryItems.append(URLQueryItem(name: "bonusCode", value: String(describing: bonusCode)))
            }
            return queryItems.isEmpty ? nil : queryItems
        case .postPlayerUpdatePlayerActiveStatus(_, let newStatus, let blockType, _, _):
            var queryItems: [URLQueryItem] = []
            queryItems.append(URLQueryItem(name: "NewStatus", value: String(describing: newStatus)))
            if let blockType = blockType {
                queryItems.append(URLQueryItem(name: "BlockType", value: String(describing: blockType)))
            }
            return queryItems.isEmpty ? nil : queryItems
        case .postPlayerSmsTokenGenerate:
            return nil
        case .setPlayerConfiguredSessionAmounts(_):
            return nil
        case .getPlayer(let email, let changePasswordUrl, let birthDate, let recaptchaACSSessionId, _, _, _):
            var queryItems: [URLQueryItem] = []
            queryItems.append(URLQueryItem(name: "email", value: String(describing: email)))
            if let changePasswordUrl = changePasswordUrl {
                queryItems.append(URLQueryItem(name: "changePasswordUrl", value: String(describing: changePasswordUrl)))
            }
            if let birthDate = birthDate {
                queryItems.append(URLQueryItem(name: "birthDate", value: String(describing: birthDate)))
            }
            if let recaptchaACSSessionId = recaptchaACSSessionId {
                queryItems.append(URLQueryItem(name: "recaptchaACSSessionId", value: String(describing: recaptchaACSSessionId)))
            }
            return queryItems.isEmpty ? nil : queryItems
        case .postPlayerLogin(_, let recaptchaACSSessionId, _, _, _, _):
            var queryItems: [URLQueryItem] = []
            if let recaptchaACSSessionId = recaptchaACSSessionId {
                queryItems.append(URLQueryItem(name: "recaptchaACSSessionId", value: String(describing: recaptchaACSSessionId)))
            }
            return queryItems.isEmpty ? nil : queryItems
        case .getPlayerWallet(_, _):
            return nil
        case .getPlayerPendingWithdrawals(_, let language, _, _):
            var queryItems: [URLQueryItem] = []
            if let language = language {
                queryItems.append(URLQueryItem(name: "language", value: String(describing: language)))
            }
            return queryItems.isEmpty ? nil : queryItems
        case .getPlayersEligibleBonus(_, let bonusType, let intention, let transactionType, let paymentMethodName, let terminal, let tag, let currency, let verifyPlayerProfile, let code, let language, _, _):
            var queryItems: [URLQueryItem] = []
            if let bonusType = bonusType {
                queryItems.append(URLQueryItem(name: "bonusType", value: String(describing: bonusType)))
            }
            if let intention = intention {
                queryItems.append(URLQueryItem(name: "intention", value: String(describing: intention)))
            }
            if let transactionType = transactionType {
                queryItems.append(URLQueryItem(name: "transactionType", value: String(describing: transactionType)))
            }
            if let paymentMethodName = paymentMethodName {
                queryItems.append(URLQueryItem(name: "paymentMethodName", value: String(describing: paymentMethodName)))
            }
            if let terminal = terminal {
                queryItems.append(URLQueryItem(name: "terminal", value: String(describing: terminal)))
            }
            if let tag = tag {
                // Handle array serialization
                for item in tag {
                    queryItems.append(URLQueryItem(name: "tag", value: String(describing: item)))
                }
            }
            if let currency = currency {
                queryItems.append(URLQueryItem(name: "currency", value: String(describing: currency)))
            }
            if let verifyPlayerProfile = verifyPlayerProfile {
                queryItems.append(URLQueryItem(name: "verifyPlayerProfile", value: verifyPlayerProfile ? "true" : "false"))
            }
            if let code = code {
                queryItems.append(URLQueryItem(name: "code", value: String(describing: code)))
            }
            if let language = language {
                queryItems.append(URLQueryItem(name: "language", value: String(describing: language)))
            }
            return queryItems.isEmpty ? nil : queryItems
        case .getPlayersBonusWallets(_, let excludeByTimeWindow, let category, let fields, let filter, let pagination, let orderBy, let language, _, _):
            var queryItems: [URLQueryItem] = []
            if let excludeByTimeWindow = excludeByTimeWindow {
                queryItems.append(URLQueryItem(name: "excludeByTimeWindow", value: excludeByTimeWindow ? "true" : "false"))
            }
            if let category = category {
                queryItems.append(URLQueryItem(name: "category", value: String(describing: category)))
            }
            if let fields = fields {
                queryItems.append(URLQueryItem(name: "fields", value: String(describing: fields)))
            }
            if let filter = filter {
                queryItems.append(URLQueryItem(name: "filter", value: String(describing: filter)))
            }
            if let pagination = pagination {
                queryItems.append(URLQueryItem(name: "pagination", value: String(describing: pagination)))
            }
            if let orderBy = orderBy {
                queryItems.append(URLQueryItem(name: "orderBy", value: String(describing: orderBy)))
            }
            if let language = language {
                queryItems.append(URLQueryItem(name: "language", value: String(describing: language)))
            }
            return queryItems.isEmpty ? nil : queryItems
        case .deletePlayersBonusWallet(_, let bonusWalletId, _, _):
            var queryItems: [URLQueryItem] = []
            queryItems.append(URLQueryItem(name: "bonusWalletID", value: String(describing: bonusWalletId)))
            return queryItems.isEmpty ? nil : queryItems
        case .getPlayerValidCountryList:
            return nil
        case .postPlayerSmsTokenValidate(_, let validationCode):
            var queryItems: [URLQueryItem] = []
            queryItems.append(URLQueryItem(name: "validationCode", value: String(describing: validationCode)))
            return queryItems.isEmpty ? nil : queryItems
        case .getPlayerSystemAvailableVendorTypes(let gmwiOperationType, _):
            var queryItems: [URLQueryItem] = []
            queryItems.append(URLQueryItem(name: "gmwiOperationType", value: String(describing: gmwiOperationType)))
            return queryItems.isEmpty ? nil : queryItems
        case .getPlayerConfiguredSessionAmounts(_):
            return nil
        case .getPlayerCountryList:
            return nil
        }
    }

    /// HTTP headers for the endpoint
    public var headers: HTTP.Headers? {
        // Default headers for all requests
        var headers: HTTP.Headers = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "GOMA/native-apps/iOS",
        ]

        // Add endpoint-specific headers based on the operation
        switch self {
        case .getPlayersDocuments(_, let xSessionid, let xSessionType):
            headers["X-SessionId"] = String(describing: xSessionid)
            if let xSessionType = xSessionType {
                headers["X-Session-Type"] = String(describing: xSessionType)
            }
            break
        case .addUserDocuments(_, let xSessionid, let xSessionType):
            headers["X-SessionId"] = String(describing: xSessionid)
            if let xSessionType = xSessionType {
                headers["X-Session-Type"] = String(describing: xSessionType)
            }
            break
        case .getPlayerProfile(_, let xSessionid, let xSessionType):
            headers["X-SessionId"] = String(describing: xSessionid)
            if let xSessionType = xSessionType {
                headers["X-Session-Type"] = String(describing: xSessionType)
            }
            break
        case .putPlayerProfile(_, let xSessionid):
            headers["X-SessionId"] = String(describing: xSessionid)
            break
        case .postPlayerProfile(_, let xSessionid):
            headers["X-SessionId"] = String(describing: xSessionid)
            break
        case .getPlayersPlaymentLimits(_, _, let xSessionid, let xSessionType):
            headers["X-SessionId"] = String(describing: xSessionid)
            if let xSessionType = xSessionType {
                headers["X-Session-Type"] = String(describing: xSessionType)
            }
            break
        case .getPlayerGmcoreLimits(_, let xSessionid, let xSessionType):
            headers["X-SessionId"] = String(describing: xSessionid)
            if let xSessionType = xSessionType {
                headers["X-Session-Type"] = String(describing: xSessionType)
            }
            break
        case .updatePlayerLimitDefinitions(_, _, let xSessionid, let xSessionType):
            headers["X-SessionId"] = String(describing: xSessionid)
            if let xSessionType = xSessionType {
                headers["X-Session-Type"] = String(describing: xSessionType)
            }
            break
        case .putPlayerSystemWithdraw(_, let xSessionid):
            headers["X-SessionId"] = String(describing: xSessionid)
            break
        case .putPlayerSystemDeposit(_, let xSessionid):
            headers["X-SessionId"] = String(describing: xSessionid)
            break
        case .registerPlayer:
            break
        case .quickRegisterPlayer:
            break
        case .getPlayerPaymentTransactionsHistory(_, let xSessionid):
            headers["X-SessionId"] = String(describing: xSessionid)
            break
        case .getPlayerPaymentSession(_, let xSessionid, let nwaClientIp):
            headers["X-SessionId"] = String(describing: xSessionid)
            if let nwaClientIp = nwaClientIp {
                headers["NWA-Client-Ip"] = String(describing: nwaClientIp)
            }
            break
        case .getPlayerPaymentPrepare(_):
            break
        case .getPlayerPaymentMethod(_):
            break
        case .getPlayerPaymentInfo(_, let xSessionid):
            headers["X-SessionId"] = String(describing: xSessionid)
            break
        case .getPlayerPaymentConfirm(_):
            break
        case .postPlayerChangePlayerPassword(_, let xSessionid):
            headers["X-SessionId"] = String(describing: xSessionid)
            break
        case .getPlayerLimitDefinitionsPlayerId(_, let xSessionid, let xSessionType):
            headers["X-SessionId"] = String(describing: xSessionid)
            if let xSessionType = xSessionType {
                headers["X-Session-Type"] = String(describing: xSessionType)
            }
            break
        case .getPlayersLegislationUserConsents(_, let xSessionid, let xSessionType):
            headers["X-SessionId"] = String(describing: xSessionid)
            if let xSessionType = xSessionType {
                headers["X-Session-Type"] = String(describing: xSessionType)
            }
            break
        case .postPlayersLegislationUserConsents(_, let xSessionid, let xSessionType):
            headers["X-SessionId"] = String(describing: xSessionid)
            if let xSessionType = xSessionType {
                headers["X-Session-Type"] = String(describing: xSessionType)
            }
            break
        case .getPlayerListUserConsent(_, let xSessionid, let xSessionType):
            headers["X-SessionId"] = String(describing: xSessionid)
            if let xSessionType = xSessionType {
                headers["X-Session-Type"] = String(describing: xSessionType)
            }
            break
        case .postPlayersClaimBonus(_, _, _, let xSessionid, let xSessionType):
            headers["X-SessionId"] = String(describing: xSessionid)
            if let xSessionType = xSessionType {
                headers["X-Session-Type"] = String(describing: xSessionType)
            }
            break
        case .postPlayerUpdatePlayerActiveStatus(_, _, _, let xSessionid, let xSessionType):
            headers["X-SessionId"] = String(describing: xSessionid)
            if let xSessionType = xSessionType {
                headers["X-Session-Type"] = String(describing: xSessionType)
            }
            break
        case .postPlayerSmsTokenGenerate:
            break
        case .setPlayerConfiguredSessionAmounts(let xSessionid):
            headers["X-SessionId"] = String(describing: xSessionid)
            break
        case .getPlayer(_, _, _, _, let gRecaptchaResponse, let cfCaptchaResponse, let cfCaptchaIsVisible):
            if let gRecaptchaResponse = gRecaptchaResponse {
                headers["g-recaptcha-response"] = String(describing: gRecaptchaResponse)
            }
            if let cfCaptchaResponse = cfCaptchaResponse {
                headers["cf-captcha-response"] = String(describing: cfCaptchaResponse)
            }
            if let cfCaptchaIsVisible = cfCaptchaIsVisible {
                headers["cfCaptchaIsVisible"] = String(describing: cfCaptchaIsVisible)
            }
            break
        case .postPlayerLogin(_, _, let gRecaptchaResponse, let cfCaptchaResponse, let cfCaptchaIsVisible, let nwaClientIp):
            if let gRecaptchaResponse = gRecaptchaResponse {
                headers["g-recaptcha-response"] = String(describing: gRecaptchaResponse)
            }
            if let cfCaptchaResponse = cfCaptchaResponse {
                headers["cf-captcha-response"] = String(describing: cfCaptchaResponse)
            }
            if let cfCaptchaIsVisible = cfCaptchaIsVisible {
                headers["cfCaptchaIsVisible"] = String(describing: cfCaptchaIsVisible)
            }
            if let nwaClientIp = nwaClientIp {
                headers["NWA-Client-Ip"] = String(describing: nwaClientIp)
            }
            break
        case .getPlayerWallet(_, let xSessionid):
            headers["X-SessionId"] = String(describing: xSessionid)
            break
        case .getPlayerPendingWithdrawals(_, _, let xSessionid, let xSessionType):
            headers["X-SessionId"] = String(describing: xSessionid)
            if let xSessionType = xSessionType {
                headers["X-Session-Type"] = String(describing: xSessionType)
            }
            break
        case .getPlayersEligibleBonus(_, _, _, _, _, _, _, _, _, _, _, let xSessionid, let xSessionType):
            headers["X-SessionId"] = String(describing: xSessionid)
            if let xSessionType = xSessionType {
                headers["X-Session-Type"] = String(describing: xSessionType)
            }
            break
        case .getPlayersBonusWallets(_, _, _, _, _, _, _, _, let xSessionid, let xSessionType):
            headers["X-SessionId"] = String(describing: xSessionid)
            if let xSessionType = xSessionType {
                headers["X-Session-Type"] = String(describing: xSessionType)
            }
            break
        case .deletePlayersBonusWallet(_, _, let xSessionid, let xSessionType):
            headers["X-SessionId"] = String(describing: xSessionid)
            if let xSessionType = xSessionType {
                headers["X-Session-Type"] = String(describing: xSessionType)
            }
            break
        case .getPlayerValidCountryList:
            break
        case .postPlayerSmsTokenValidate(_, _):
            break
        case .getPlayerSystemAvailableVendorTypes(_, let xSessionid):
            headers["X-SessionId"] = String(describing: xSessionid)
            break
        case .getPlayerConfiguredSessionAmounts(let xSessionid):
            headers["X-SessionId"] = String(describing: xSessionid)
            break
        case .getPlayerCountryList:
            break
        }

        return headers
    }

    /// Request body for the endpoint
    public var body: Data? {
        switch self {
        case .getPlayersDocuments(_, _, _):
            return nil
        case .addUserDocuments(_, _, _):
            // Check what we need to send in the body
            return nil
        case .getPlayerProfile(_, _, _):
            return nil
        case .putPlayerProfile(_, _):
            // Check what we need to send in the body
            return nil
        case .postPlayerProfile(_, _):
            // Check what we need to send in the body
            return nil
        case .getPlayersPlaymentLimits(_, _, _, _):
            return nil
        case .getPlayerGmcoreLimits(_, _, _):
            return nil
        case .updatePlayerLimitDefinitions(_, _, _, _):
            // Check what we need to send in the body
            return nil
        case .putPlayerSystemWithdraw(_, _):
            // Check what we need to send in the body
            return nil
        case .putPlayerSystemDeposit(_, _):
            // Check what we need to send in the body
            return nil
        case .registerPlayer:
            // Check what we need to send in the body
            return nil
        case .quickRegisterPlayer:
            // Check what we need to send in the body
            return nil
        case .getPlayerPaymentTransactionsHistory(_, _):
            // Check what we need to send in the body
            return nil
        case .getPlayerPaymentSession(_, _, _):
            // Check what we need to send in the body
            return nil
        case .getPlayerPaymentPrepare(_):
            // Check what we need to send in the body
            return nil
        case .getPlayerPaymentMethod(_):
            // Check what we need to send in the body
            return nil
        case .getPlayerPaymentInfo(_, _):
            // Check what we need to send in the body
            return nil
        case .getPlayerPaymentConfirm(_):
            // Check what we need to send in the body
            return nil
        case .postPlayerChangePlayerPassword(_, _):
            // Check what we need to send in the body
            return nil
        case .getPlayerLimitDefinitionsPlayerId(_, _, _):
            return nil
        case .getPlayersLegislationUserConsents(_, _, _):
            return nil
        case .postPlayersLegislationUserConsents(_, _, _):
            // Check what we need to send in the body
            return nil
        case .getPlayerListUserConsent(_, _, _):
            return nil
        case .postPlayersClaimBonus(_, _, _, _, _):
            return nil
        case .postPlayerUpdatePlayerActiveStatus(_, _, _, _, _):
            return nil
        case .postPlayerSmsTokenGenerate(_):
            // Check what we need to send in the body
            return nil
        case .setPlayerConfiguredSessionAmounts(_):
            // Check what we need to send in the body
            return nil
        case .getPlayer(_, _, _, _, _, _, _):
            return nil
        case .postPlayerLogin(_, _, _, _, _, _):
            // Check what we need to send in the body
            return nil
        case .getPlayerWallet(_, _):
            return nil
        case .getPlayerPendingWithdrawals(_, _, _, _):
            return nil
        case .getPlayersEligibleBonus(_, _, _, _, _, _, _, _, _, _, _, _, _):
            return nil
        case .getPlayersBonusWallets(_, _, _, _, _, _, _, _, _, _):
            return nil
        case .deletePlayersBonusWallet(_, _, _, _):
            return nil
        case .getPlayerValidCountryList:
            return nil
        case .postPlayerSmsTokenValidate(_, _):
            return nil
        case .getPlayerSystemAvailableVendorTypes(_, _):
            return nil
        case .getPlayerConfiguredSessionAmounts(_):
            return nil
        case .getPlayerCountryList:
            return nil
        }
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalCacheData
    }

    var timeout: TimeInterval {
         return TimeInterval(10)
    }
    
    var requireSessionKey: Bool {
        return false
    }
    
    var comment: String? {
        return nil
    }
    
}
