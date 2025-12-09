//
//  ServiceProviderModelMapper+ErrorCode.swift
//  BetssonCameroonApp
//
//  Created by Leonardo Soares on 27/11/2025.
//

import Foundation

/// Phrase keys for EveryMatrix API errors.
/// These keys are fetched from Phrase SDK at runtime for localized translations.
enum APIErrorKey: String {
    case mobileNumberAlreadyInUse = "mobile_number_already_in_use"
    case usernameAlreadyExists = "gm_error_username_already_exists"
    case usernameRequired = "gm_error_username_required"
    case userAccountBlocked = "gm_error_user_account_blocked"
    case userAuthFailed = "gm_error_user_auth_failed"
    case userAuthFailedTooManyAttempts = "gm_error_user_auth_failed_too_many_attempts"
    case userEmailNotVerified = "gm_error_user_email_not_verified"
    case userNotActivated = "gm_error_user_not_activated"
    case userNotVerified = "gm_error_user_not_verified"
    case expiredToken = "gm_error_expired_token"
    case invalidCode = "gm_error_invalid_code"
    case attemptsToValidateCodeExceeded = "gm_error_attempts_to_validate_code_exceeded"
    case attemptsToGenerateCodeExceeded = "gm_error_attempts_to_generate_code_exceeded"
    case blockUserIncorrectCode = "gm_error_block_user_incorrect_code"
    case tokenNotFound = "gm_error_token_not_found"
    case codeMissing = "gm_error_code_missing"
    case unregisteredUser = "gm_error_unregistered_user"
    case invalidPhoneNumber = "gm_error_invalid_phone_number"
    case invalidUserId = "gm_error_invalid_user_id"
    case unexpectedException = "gm_error_unexpected_exception"
    case invalidUserDocument = "gm_error_invalid_user_document"
    case registerUnderage = "gm_error_register_underage"
    case loginDenied = "gm_error_login_denied"
    case unauthorized = "gm_error_unauthorized"
}

extension ServiceProviderModelMapper {

    /// Maps EveryMatrix API error codes to Phrase localization keys.
    ///
    /// EveryMatrix returns error codes in different formats (e.g., `gmerruser4tscheckexists`,
    /// `Forbidden_TooManyAttempts`). This method normalizes the input and maps multiple
    /// error code variants to their corresponding Phrase key.
    ///
    /// - Parameter errorCode: The raw error code from EveryMatrix API response
    /// - Returns: The Phrase key for localized error message, or "server_error_message" as fallback
    static func mappedErrorKey(from errorCode: String) -> String {
        let normalized = errorCode.lowercased().replacingOccurrences(of: "_", with: "")

        switch normalized {
        // MARK: - Too many attempts (multiple EM codes → same Phrase key)
        case "forbiddentoomanyattempts",
             "gmerruserauthfailedtoomanyattempts":
            return APIErrorKey.userAuthFailedTooManyAttempts.rawValue

        // MARK: - Mobile/Username errors
        case "gmerruser4tscheckexists":
            return APIErrorKey.mobileNumberAlreadyInUse.rawValue
        case "gmerrusernamealreadyexists":
            return APIErrorKey.usernameAlreadyExists.rawValue
        case "gmerrusernamerequired":
            return APIErrorKey.usernameRequired.rawValue

        // MARK: - Account status errors
        case "gmerruseraccountblocked":
            return APIErrorKey.userAccountBlocked.rawValue
        case "gmerruserauthfailed":
            return APIErrorKey.userAuthFailed.rawValue
        case "gmerruseremailnotverified":
            return APIErrorKey.userEmailNotVerified.rawValue
        case "gmerrusernotactivated":
            return APIErrorKey.userNotActivated.rawValue
        case "gmerrusernotverified":
            return APIErrorKey.userNotVerified.rawValue

        // MARK: - Token/code errors
        case "gmerrexpiredtoken":
            return APIErrorKey.expiredToken.rawValue
        case "gmerrinvalidcode":
            return APIErrorKey.invalidCode.rawValue
        case "gmerrattemptstovalidatecodeexceeded":
            return APIErrorKey.attemptsToValidateCodeExceeded.rawValue
        case "gmerrattemptstogeneratecodeexceeded":
            return APIErrorKey.attemptsToGenerateCodeExceeded.rawValue
        case "gmerrblockuserincorrectcode":
            return APIErrorKey.blockUserIncorrectCode.rawValue
        case "gmerrtokennotfound":
            return APIErrorKey.tokenNotFound.rawValue
        case "gmerrcodemissing":
            return APIErrorKey.codeMissing.rawValue

        // MARK: - User validation errors
        case "gmerrunregistereduser":
            return APIErrorKey.unregisteredUser.rawValue
        case "gmerrinvalidphonenumber":
            return APIErrorKey.invalidPhoneNumber.rawValue
        case "gmerrinvaliduserid":
            return APIErrorKey.invalidUserId.rawValue
        case "gmerrinvaliduserdocument":
            return APIErrorKey.invalidUserDocument.rawValue
        case "gmerrregisterunderage":
            return APIErrorKey.registerUnderage.rawValue

        // MARK: - General errors
        case "gmerrunexpectedexception":
            return APIErrorKey.unexpectedException.rawValue
        case "gmerrlogindenied":
            return APIErrorKey.loginDenied.rawValue
        case "unauthorized":
            return APIErrorKey.unauthorized.rawValue

        default:
            return "server_error_message"
        }
    }
}
