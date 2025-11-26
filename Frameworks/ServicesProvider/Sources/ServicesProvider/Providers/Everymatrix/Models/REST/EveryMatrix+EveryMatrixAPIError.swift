//
//  EveryMatrix+EveryMatrixAPIError.swift
//  ServicesProvider
//
//  Created by André Lascas on 16/07/2025.
//

import Foundation

extension EveryMatrix {
    
    struct EveryMatrixAPIError: Decodable {
        let error: String?
        let success: Bool?
        let errorCode: Int?
        let errorSourceName: String?
        let thirdPartyResponse: ThirdPartyResponse?
        let nwaTraceId: String?
        
        struct ThirdPartyResponse: Decodable {
            let errorCode: String?
            let message: String?
            let correlationId: String?
            let errors: [String: String]?
            
            var mappedErrorCode: String? {
                guard let errorCode else { return nil }
                return ErrorCodeMappingError.apiErrorCodesMatching[errorCode]
            }
        }
    }
    
    struct ErrorCodeMappingError {
        // API Error codes mapping according with Web
        static let apiErrorCodesMatching: [String: String] = [
            "GmErr_USER_4TS_CHECK_EXISTS": "mobile_number_already_in_use",
            "GmErr_USERNAME_ALREADY_EXISTS": "gm_error_username_already_exists",
            "GmErr_USERNAME_REQUIRED": "gm_error_username_required",
            "GmErr_USER_ACCOUNT_BLOCKED": "gm_error_user_account_blocked",
            "GmErr_USER_AUTH_FAILED": "gm_error_user_auth_failed",
            "GmErr_USER_AUTH_FAILED_TOO_MANY_ATTEMPTS": "gm_error_user_auth_failed_too_many_attempts",
            "GmErr_USER_EMAIL_NOT_VERIFIED": "gm_error_user_email_not_verified",
            "GmErr_USER_NOT_ACTIVATED": "gm_error_user_not_activated",
            "GmErr_USER_NOT_VERIFIED": "gm_error_user_not_verified",
            "GmErr_EXPIRED_TOKEN": "gm_error_expired_token",
            "GmErr_INVALID_CODE": "gm_error_invalid_code",
            "GmErr_ATTEMPTS_TO_VALIDATE_CODE_EXCEEDED": "gm_error_attempts_to_validate_code_exceeded",
            "GmErr_ATTEMPTS_TO_GENERATE_CODE_EXCEEDED": "gm_error_attempts_to_generate_code_exceeded",
            "GmErr_BLOCK_USER_INCORRECT_CODE": "gm_error_block_user_incorrect_code",
            "GmErr_TOKEN_NOT_FOUND": "gm_error_token_not_found",
            "GmErr_CODE_MISSING": "gm_error_code_missing",
            "GmErr_UNREGISTERED_USER": "gm_error_unregistered_user",
            "GmErr_INVALID_PHONE_NUMBER": "gm_error_invalid_phone_number",
            "GmErr_INVALID_USER_ID": "gm_error_invalid_user_id",
            "GmErr_UNEXPECTED_EXCEPTION": "gm_error_unexpected_exception",
            "GmErr_INVALID_USER_DOCUMENT": "gm_error_invalid_user_document",
            "GmErr_REGISTER_UNDERAGE": "gm_error_register_underage",
            "GmErr_LOGIN_DENIED": "gm_error_login_denied",
            "Unauthorized": "gm_error_unauthorized"
        ]
    }
}
