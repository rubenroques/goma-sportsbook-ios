//
//  ServiceProviderModelMapper+ErrorCode.swift
//  BetssonCameroonApp
//
//  Created by Leonardo Soares on 27/11/2025.
//

import Foundation

enum APIErrorCode: String, Decodable {
    case user4TSCheckExists = "GmErr_USER_4TS_CHECK_EXISTS"
    case usernameAlreadyExists = "GmErr_USERNAME_ALREADY_EXISTS"
    case usernameRequired = "GmErr_USERNAME_REQUIRED"
    case userAccountBlocked = "GmErr_USER_ACCOUNT_BLOCKED"
    case userAuthFailed = "GmErr_USER_AUTH_FAILED"
    case userAuthFailedTooManyAttempts = "GmErr_USER_AUTH_FAILED_TOO_MANY_ATTEMPTS"
    case userEmailNotVerified = "GmErr_USER_EMAIL_NOT_VERIFIED"
    case userNotActivated = "GmErr_USER_NOT_ACTIVATED"
    case userNotVerified = "GmErr_USER_NOT_VERIFIED"
    case expiredToken = "GmErr_EXPIRED_TOKEN"
    case invalidCode = "GmErr_INVALID_CODE"
    case attemptsToValidateCodeExceeded = "GmErr_ATTEMPTS_TO_VALIDATE_CODE_EXCEEDED"
    case attemptsToGenerateCodeExceeded = "GmErr_ATTEMPTS_TO_GENERATE_CODE_EXCEEDED"
    case blockUserIncorrectCode = "GmErr_BLOCK_USER_INCORRECT_CODE"
    case tokenNotFound = "GmErr_TOKEN_NOT_FOUND"
    case codeMissing = "GmErr_CODE_MISSING"
    case unregisteredUser = "GmErr_UNREGISTERED_USER"
    case invalidPhoneNumber = "GmErr_INVALID_PHONE_NUMBER"
    case invalidUserId = "GmErr_INVALID_USER_ID"
    case unexpectedException = "GmErr_UNEXPECTED_EXCEPTION"
    case invalidUserDocument = "GmErr_INVALID_USER_DOCUMENT"
    case registerUnderage = "GmErr_REGISTER_UNDERAGE"
    case loginDenied = "GmErr_LOGIN_DENIED"
    case unauthorized = "Unauthorized"
}

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
    static func mappedErrorKey(from errorCode: String) -> String {
        guard let apiErrorCode = APIErrorCode(rawValue: errorCode) else { return "Server Error" }
        let mappedErrorCode: APIErrorKey = switch apiErrorCode {
        case .user4TSCheckExists:
                .mobileNumberAlreadyInUse
        case .usernameAlreadyExists:
                .usernameAlreadyExists
        case .usernameRequired:
                .usernameRequired
        case .userAccountBlocked:
                .userAccountBlocked
        case .userAuthFailed:
                .userAuthFailed
        case .userAuthFailedTooManyAttempts:
                .userAuthFailedTooManyAttempts
        case .userEmailNotVerified:
                .userEmailNotVerified
        case .userNotActivated:
                .userNotActivated
        case .userNotVerified:
                .userNotVerified
        case .expiredToken:
                .expiredToken
        case .invalidCode:
                .invalidCode
        case .attemptsToValidateCodeExceeded:
                .attemptsToValidateCodeExceeded
        case .attemptsToGenerateCodeExceeded:
                .attemptsToGenerateCodeExceeded
        case .blockUserIncorrectCode:
                .blockUserIncorrectCode
        case .tokenNotFound:
                .tokenNotFound
        case .codeMissing:
                .codeMissing
        case .unregisteredUser:
                .unregisteredUser
        case .invalidPhoneNumber:
                .invalidPhoneNumber
        case .invalidUserId:
                .invalidUserId
        case .unexpectedException:
                .unexpectedException
        case .invalidUserDocument:
                .invalidUserDocument
        case .registerUnderage:
                .registerUnderage
        case .loginDenied:
                .loginDenied
        case .unauthorized:
                .unauthorized
        }
        
        return mappedErrorCode.rawValue
    }
}
