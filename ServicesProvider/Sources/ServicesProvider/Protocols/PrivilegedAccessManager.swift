//
//  PrivilegedAccessManager.swift
//  
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine
import SharedModels

enum UserSessionStatus {
    case anonymous
    case logged
}

protocol PrivilegedAccessManager {
    
    var userSessionStatePublisher: AnyPublisher<UserSessionStatus, Error> { get }
    var userProfilePublisher: AnyPublisher<UserProfile?, Error> { get }
    
    var hasSecurityQuestions: Bool { get }
    
    func login(username: String, password: String) -> AnyPublisher<UserProfile, ServiceProviderError>
    
    func getUserProfile(withKycExpire: String?) -> AnyPublisher<UserProfile, ServiceProviderError>
    func updateUserProfile(form: UpdateUserProfileForm) -> AnyPublisher<Bool, ServiceProviderError>
    
    func checkEmailRegistered(_ email: String) -> AnyPublisher<Bool, ServiceProviderError>

    func validateUsername(_ username: String) -> AnyPublisher<UsernameValidation, ServiceProviderError>

    func simpleSignUp(form: SimpleSignUpForm) -> AnyPublisher<Bool, ServiceProviderError>
    func signUp(form: SignUpForm) -> AnyPublisher<SignUpResponse, ServiceProviderError>
    func updateExtraInfo(placeOfBirth: String?, address2: String?) -> AnyPublisher<BasicResponse, ServiceProviderError>
    func updateDeviceIdentifier(deviceIdentifier: String, appVersion: String) -> AnyPublisher<BasicResponse, ServiceProviderError>
    
    func getAllCountries() -> AnyPublisher<[Country], ServiceProviderError>
    func getCountries() -> AnyPublisher<[Country], ServiceProviderError>
    func getCurrentCountry() -> AnyPublisher<Country?, ServiceProviderError>
        
    func signupConfirmation(_ email: String, confirmationCode: String) -> AnyPublisher<Bool, ServiceProviderError>

    func forgotPassword(email: String, secretQuestion: String?, secretAnswer: String?) -> AnyPublisher<Bool, ServiceProviderError>
    func updatePassword(oldPassword: String, newPassword: String) -> AnyPublisher<Bool, ServiceProviderError>
    func getPasswordPolicy() -> AnyPublisher<PasswordPolicy, ServiceProviderError>

    func updateWeeklyDepositLimits(newLimit: Double) -> AnyPublisher<Bool, ServiceProviderError>
    func updateWeeklyBettingLimits(newLimit: Double) -> AnyPublisher<Bool, ServiceProviderError>
    func updateResponsibleGamingLimits(newLimit: Double, limitType: String, hasRollingWeeklyLimits: Bool) -> AnyPublisher<Bool, ServiceProviderError>
    func getPersonalDepositLimits() -> AnyPublisher<PersonalDepositLimitResponse, ServiceProviderError>
    func getLimits() -> AnyPublisher<LimitsResponse, ServiceProviderError>
    func getResponsibleGamingLimits(periodTypes: String?, limitTypes: String?) -> AnyPublisher<ResponsibleGamingLimitsResponse, ServiceProviderError>
    func lockPlayer(isPermanent: Bool?, lockPeriodUnit: String?, lockPeriod: String?) -> AnyPublisher<BasicResponse, ServiceProviderError>

    func getUserBalance() -> AnyPublisher<UserWallet, ServiceProviderError>
    func getUserCashbackBalance() -> AnyPublisher<CashbackBalance, ServiceProviderError>

    func signUpCompletion(form: ServicesProvider.UpdateUserProfileForm)  -> AnyPublisher<Bool, ServiceProviderError>

    func getDocumentTypes() -> AnyPublisher<DocumentTypesResponse, ServiceProviderError>
    func getUserDocuments() -> AnyPublisher<UserDocumentsResponse, ServiceProviderError>
    func uploadUserDocument(documentType: String, file: Data, fileName: String) -> AnyPublisher<UploadDocumentResponse, ServiceProviderError>
    func uploadMultipleUserDocuments(documentType: String, files: [String: Data]) -> AnyPublisher<UploadDocumentResponse, ServiceProviderError>

    func getPayments() -> AnyPublisher<SimplePaymentMethodsResponse, ServiceProviderError>
    func processDeposit(paymentMethod: String, amount: Double, option: String) -> AnyPublisher<ProcessDepositResponse, ServiceProviderError>
    func updatePayment(amount: Double, paymentId: String, type: String, returnUrl: String?, nameOnCard: String?, encryptedExpiryYear: String?, encryptedExpiryMonth: String?, encryptedSecurityCode: String?, encryptedCardNumber: String?) -> AnyPublisher<UpdatePaymentResponse, ServiceProviderError>
    func cancelDeposit(paymentId: String) -> AnyPublisher<BasicResponse, ServiceProviderError>
    func checkPaymentStatus(paymentMethod: String, paymentId: String) -> AnyPublisher<PaymentStatusResponse, ServiceProviderError>
    
    func getWithdrawalMethods() -> AnyPublisher<[WithdrawalMethod], ServiceProviderError>
    func processWithdrawal(paymentMethod: String, amount: Double, conversionId: String?) -> AnyPublisher<ProcessWithdrawalResponse, ServiceProviderError>
    func prepareWithdrawal(paymentMethod: String) -> AnyPublisher<PrepareWithdrawalResponse, ServiceProviderError>

    func getPendingWithdrawals() -> AnyPublisher<[PendingWithdrawal], ServiceProviderError>
    func cancelWithdrawal(paymentId: Int) -> AnyPublisher<CancelWithdrawalResponse, ServiceProviderError>
    func getPaymentInformation() -> AnyPublisher<PaymentInformation, ServiceProviderError>
    func addPaymentInformation(type: String, fields: String) -> AnyPublisher<AddPaymentInformationResponse, ServiceProviderError>

    func getTransactionsHistory(startDate: String, endDate: String, transactionTypes: [TransactionType]?, pageNumber: Int?) -> AnyPublisher<[TransactionDetail], ServiceProviderError>

    func getGrantedBonuses() -> AnyPublisher<[GrantedBonus], ServiceProviderError>
    func redeemBonus(code: String) -> AnyPublisher<RedeemBonusResponse, ServiceProviderError>
    func getAvailableBonuses() -> AnyPublisher<[AvailableBonus], ServiceProviderError>
    func redeemAvailableBonus(partyId: String, code: String) -> AnyPublisher<BasicResponse, ServiceProviderError>
    func cancelBonus(bonusId: String) -> AnyPublisher<BasicResponse, ServiceProviderError>
    func optOutBonus(partyId: String, code: String) -> AnyPublisher<BasicResponse, ServiceProviderError>

    func contactUs(firstName: String, lastName: String, email: String, subject: String, message: String) -> AnyPublisher<BasicResponse, ServiceProviderError>
    func contactSupport(userIdentifier: String, firstName: String, lastName: String, email: String, subject: String, subjectType: String , message: String, isLogged: Bool) -> AnyPublisher<SupportResponse, ServiceProviderError>

    func getAllConsents() -> AnyPublisher<[ConsentInfo], ServiceProviderError>
    
    func getUserConsents() -> AnyPublisher<[UserConsent], ServiceProviderError>
    
    func setUserConsents(consentVersionIds: [Int]?, unconsenVersionIds: [Int]?) -> AnyPublisher<BasicResponse, ServiceProviderError>

    func getSumsubAccessToken(userId: String, levelName: String) -> AnyPublisher<AccessTokenResponse, ServiceProviderError>

    func getSumsubApplicantData(userId: String) -> AnyPublisher<ApplicantDataResponse, ServiceProviderError>

    func generateDocumentTypeToken(docType: String) -> AnyPublisher<AccessTokenResponse, ServiceProviderError>

    func checkDocumentationData() -> AnyPublisher<ApplicantDataResponse, ServiceProviderError>
    
    func getMobileVerificationCode(forMobileNumber mobileNumber: String) -> AnyPublisher<MobileVerifyResponse, ServiceProviderError>
    func verifyMobileCode(code: String, requestId: String) -> AnyPublisher<MobileVerifyResponse, ServiceProviderError>
    
    func getReferralLink() -> AnyPublisher<ReferralLink, ServiceProviderError>
    func getReferees() -> AnyPublisher<[Referee], ServiceProviderError>
    
    func getWheelEligibility(gameTransId: String) -> AnyPublisher<WheelEligibility, ServiceProviderError>
    
    func wheelOptIn(winBoostId: String, optInOption: String) -> AnyPublisher<WheelOptInData, ServiceProviderError>
    
    func getGrantedWinBoosts(gameTransIds: [String]) -> AnyPublisher<[GrantedWinBoosts], ServiceProviderError>
}
