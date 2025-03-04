# Sportradar Services Documentation

## Table of Contents
1. [Core Services](#core-services)
   - [Authentication](#authentication)
   - [User Profile Management](#user-profile-management)
   - [Registration](#registration)
   - [Identity Verification](#identity-verification)
   - [Documents](#documents)
   - [Consent Management](#consent-management)
2. [Financial Services](#financial-services)
   - [Wallet Management](#wallet-management)
   - [Deposits](#deposits)
   - [Withdrawals](#withdrawals)
   - [Transaction History](#transaction-history)
3. [Gaming Services](#gaming-services)
   - [Responsible Gaming](#responsible-gaming)
   - [Bonuses & Rewards](#bonuses--rewards)
   - [Support Services](#support-services)
   - [Location Services](#location-services)
   - [Referral Program](#referral-program)

# Core Services

## Authentication

### Login
**Name:** `login`


*Purpose:* Authenticate user and establish session


*Required Information:*
- Username
- Password


*Returns:* `UserProfile` - Complete user profile information including preferences and status

### Logout
**Name:** `logout`

*Purpose:* End user session securely

*Required Information:* None

*Returns:* `BasicResponse` - Simple success/failure response

### Get Password Policy
**Name:** `getPasswordPolicy`

*Purpose:* Retrieve password requirements and rules

*Required Information:* None

*Returns:* `PasswordPolicy` - Password requirements and constraints

## User Profile Management

### Get User Profile
**Name:** `getUserProfile`

*Purpose:* Retrieve current user's profile information

*Required Information:*
- KYC Expiration (optional)


*Returns:* `UserProfile` - User's complete profile information and account status

### Update User Profile
**Name:** `updateUserProfile`

*Purpose:* Modify user's profile information

*Required Information:*
- Username (optional)
- Email (optional)
- First Name (optional)
- Last Name (optional)
- Birth Date (optional)
- Gender (optional)
- Address (optional)
- Province (optional)
- City (optional)
- Postal Code (optional)
- Country (optional)
- Card ID (optional)


*Returns:* `Bool` - Success or failure of the update operation

### Update Extra Info
**Name:** `updateExtraInfo`

*Purpose:* Update additional user information

*Required Information:*
- Place of Birth (optional)
- Secondary Address (optional)


*Returns:* `BasicResponse` - Simple success/failure response

### Update Device Identifier
**Name:** `updateDeviceIdentifier`

*Purpose:* Update device information for the user

*Required Information:*
- Device Identifier
- App Version


*Returns:* `BasicResponse` - Simple success/failure response

### Sign Up Completion
**Name:** `signUpCompletion`

*Purpose:* Completes the signup process with additional user information

*Required Information:*
- Form containing additional user information


*Returns:* `Bool` - Success status of signup completion

### Forgot Password
**Name:** `forgotPassword`

*Purpose:* Initiates the password recovery process

*Required Information:*
- Email
- Secret Question (optional)
- Secret Answer (optional)


*Returns:* `Bool` - Password recovery initiation success status

## Registration

### Check Email Registered
**Name:** `checkEmailRegistered`

*Purpose:* Verify if an email is already in use

*Required Information:*
- Email address


*Returns:* `Bool` - True if email exists, false otherwise

### Validate Username
**Name:** `validateUsername`

*Purpose:* Check username availability and get suggestions

*Required Information:*
- Username


*Returns:* `UsernameValidation` - Username availability status and suggestions if taken

### Simple Sign Up
**Name:** `simpleSignUp`

*Purpose:* Quick registration with basic information

*Required Information:*
- Email
- Username
- Password
- Birth Date
- Mobile Prefix
- Mobile Number
- Country ISO Code
- Currency Code


*Returns:* `Bool` - Registration success status

### Complete Sign Up
**Name:** `signUp`

*Purpose:* Full registration with complete user information

*Required Information:*
- Email
- Username
- Password
- Birth Date
- Mobile Information
- Nationality
- Currency
- Personal Information
- Address Details
- Marketing Preferences
- Consent Information


*Returns:* `SignUpResponse` - Detailed registration response with status and any errors

### Sign Up Confirmation
**Name:** `signupConfirmation`

*Purpose:* Verify email during registration process

*Required Information:*
- Email
- Confirmation Code


*Returns:* `Bool` - Confirmation success status

### Mobile Verification
**Name:** `getMobileVerificationCode`

*Purpose:* Request verification code for mobile number

*Required Information:*
- Mobile Number


*Returns:* `MobileVerifyResponse` - Verification request details and status

### Verify Mobile Code
**Name:** `verifyMobileCode`

*Purpose:* Validate mobile verification code

*Required Information:*
- Verification Code
- Request ID


*Returns:* `MobileVerifyResponse` - Verification success status

# Financial Services

## Wallet Management

### Get User Balance
**Name:** `getUserBalance`

*Purpose:* Retrieve current wallet balance

*Required Information:* None

*Returns:* `UserWallet` - Current balance and wallet status information

### Get User Cashback Balance
**Name:** `getUserCashbackBalance`

*Purpose:* Check available cashback balance

*Required Information:* None

*Returns:* `CashbackBalance` - Available cashback amount and status

## Deposits

### Get Payment Methods
**Name:** `getPayments`

*Purpose:* List available deposit methods

*Required Information:* None

*Returns:* `SimplePaymentMethodsResponse` - List of available payment methods and their details

### Process Deposit
**Name:** `processDeposit`

*Purpose:* Initiate a deposit transaction

*Required Information:*
- Payment Method
- Amount
- Payment Option


*Returns:* `ProcessDepositResponse` - Deposit transaction details and status

### Update Payment
**Name:** `updatePayment`

*Purpose:* Update payment transaction details

*Required Information:*
- Amount
- Payment ID
- Payment Type
- Return URL (optional)
- Card Details (optional)


*Returns:* `UpdatePaymentResponse` - Updated payment transaction status

### Cancel Deposit
**Name:** `cancelDeposit`

*Purpose:* Cancel a pending deposit

*Required Information:*
- Payment ID


*Returns:* `BasicResponse` - Cancellation confirmation

### Check Payment Status
**Name:** `checkPaymentStatus`

*Purpose:* Verify status of a payment

*Required Information:*
- Payment Method
- Payment ID


*Returns:* `PaymentStatusResponse` - Current status of the payment

## Withdrawals

### Get Withdrawal Methods
**Name:** `getWithdrawalMethods`

*Purpose:* List available withdrawal methods

*Required Information:* None

*Returns:* `[WithdrawalMethod]` - List of available withdrawal methods

### Process Withdrawal
**Name:** `processWithdrawal`

*Purpose:* Initiate a withdrawal request

*Required Information:*
- Payment Method
- Amount
- Conversion ID (optional)


*Returns:* `ProcessWithdrawalResponse` - Withdrawal request status and details

### Prepare Withdrawal
**Name:** `prepareWithdrawal`

*Purpose:* Setup withdrawal request

*Required Information:*
- Payment Method


*Returns:* `PrepareWithdrawalResponse` - Withdrawal preparation status

### Get Pending Withdrawals
**Name:** `getPendingWithdrawals`

*Purpose:* List all pending withdrawal requests

*Required Information:* None

*Returns:* `[PendingWithdrawal]` - List of pending withdrawal transactions

### Cancel Withdrawal
**Name:** `cancelWithdrawal`

*Purpose:* Cancel a pending withdrawal

*Required Information:*
- Payment ID


*Returns:* `CancelWithdrawalResponse` - Withdrawal cancellation status

## Transaction History

### Get Transaction History
**Name:** `getTransactionsHistory`

*Purpose:* Retrieve transaction history

*Required Information:*
- Start Date
- End Date
- Transaction Types (optional)
- Page Number (optional)


*Returns:* `[TransactionDetail]` - List of transaction records

### Get Payment Information
**Name:** `getPaymentInformation`

*Purpose:* Retrieve saved payment methods

*Required Information:* None

*Returns:* `PaymentInformation` - Saved payment method details

### Add Payment Information
**Name:** `addPaymentInformation`

*Purpose:* Save new payment method

*Required Information:*
- Payment Type
- Payment Fields


*Returns:* `AddPaymentInformationResponse` - Payment method addition status

# Gaming Services

## Responsible Gaming

### Update Weekly Deposit Limits
**Name:** `updateWeeklyDepositLimits`

*Purpose:* Set deposit limits for responsible gaming

*Required Information:*
- New Limit Amount


*Returns:* `Bool` - Limit update success status

### Update Weekly Betting Limits
**Name:** `updateWeeklyBettingLimits`

*Purpose:* Set betting limits for responsible gaming

*Required Information:*
- New Limit Amount


*Returns:* `Bool` - Limit update success status

### Update Responsible Gaming Limits
**Name:** `updateResponsibleGamingLimits`

*Purpose:* Set comprehensive gaming limits

*Required Information:*
- New Limit Amount
- Limit Type
- Rolling Weekly Limits Flag


*Returns:* `Bool` - Limit update success status

### Get Personal Deposit Limits
**Name:** `getPersonalDepositLimits`

*Purpose:* View current deposit limits

*Required Information:* None

*Returns:* `PersonalDepositLimitResponse` - Current deposit limit settings

### Get All Limits
**Name:** `getLimits`

*Purpose:* View all active gaming limits

*Required Information:* None

*Returns:* `LimitsResponse` - All current limit settings

### Get Responsible Gaming Limits
**Name:** `getResponsibleGamingLimits`

*Purpose:* View responsible gaming limits

*Required Information:*
- Period Types (optional)
- Limit Types (optional)


*Returns:* `ResponsibleGamingLimitsResponse` - Current responsible gaming limits

### Lock Player Account
**Name:** `lockPlayer`

*Purpose:* Self-exclude from gaming activities

*Required Information:*
- Is Permanent (optional)
- Lock Period Unit (optional)
- Lock Period (optional)


*Returns:* `BasicResponse` - Account lock confirmation

## Bonuses & Rewards

### Get Granted Bonuses
**Name:** `getGrantedBonuses`

*Purpose:* View active and historical bonuses

*Required Information:* None

*Returns:* `[GrantedBonus]` - List of granted bonuses

### Redeem Bonus
**Name:** `redeemBonus`

*Purpose:* Activate a bonus code

*Required Information:*
- Bonus Code


*Returns:* `RedeemBonusResponse` - Bonus redemption status

### Get Available Bonuses
**Name:** `getAvailableBonuses`

*Purpose:* View bonuses available to claim

*Required Information:* None

*Returns:* `[AvailableBonus]` - List of available bonuses

### Redeem Available Bonus
**Name:** `redeemAvailableBonus`

*Purpose:* Claim an available bonus

*Required Information:*
- Party ID
- Bonus Code


*Returns:* `BasicResponse` - Bonus claim status

### Cancel Bonus
**Name:** `cancelBonus`

*Purpose:* Cancel an active bonus

*Required Information:*
- Bonus ID


*Returns:* `BasicResponse` - Bonus cancellation status

### Opt Out Bonus
**Name:** `optOutBonus`

*Purpose:* Opt out from bonus programs

*Required Information:*
- Party ID
- Bonus Code


*Returns:* `BasicResponse` - Opt-out confirmation

## Support Services

### Contact Us
**Name:** `contactUs`

*Purpose:* Send general contact request

*Required Information:*
- First Name
- Last Name
- Email
- Subject
- Message


*Returns:* `BasicResponse` - Contact request confirmation

### Contact Support
**Name:** `contactSupport`

*Purpose:* Send detailed support request

*Required Information:*
- User Identifier
- First Name
- Last Name
- Email
- Subject
- Subject Type
- Message
- Login Status


*Returns:* `SupportResponse` - Support request status

## Location Services

### Get All Countries
**Name:** `getAllCountries`

*Purpose:* List all supported countries

*Required Information:* None

*Returns:* `[Country]` - List of all countries

### Get Available Countries
**Name:** `getCountries`

*Purpose:* List countries available for registration

*Required Information:* None

*Returns:* `[Country]` - List of available countries

### Get Current Country
**Name:** `getCurrentCountry`

*Purpose:* Get user's current country

*Required Information:* None

*Returns:* `Country?` - Current country information

## Referral Program

### Get Referral Link
**Name:** `getReferralLink`

*Purpose:* Get user's unique referral link

*Required Information:* None

*Returns:* `ReferralLink` - Referral link information

### Get Referees
**Name:** `getReferees`

*Purpose:* List referred users

*Required Information:* None

*Returns:* `[Referee]` - List of referred users and their status

# Identity Verification

### Get Sumsub Access Token
**Name:** `getSumsubAccessToken`

*Purpose:* Retrieves an access token for Sumsub identity verification service

*Required Information:*
- User ID
- Level Name


*Returns:* `AccessTokenResponse` - Access token for identity verification

### Get Sumsub Applicant Data
**Name:** `getSumsubApplicantData`

*Purpose:* Retrieves applicant verification data from Sumsub

*Required Information:*
- User ID


*Returns:* `ApplicantDataResponse` - Detailed applicant verification data

### Generate Document Type Token
**Name:** `generateDocumentTypeToken`

*Purpose:* Generates a token for uploading a specific type of document

*Required Information:*
- Document Type


*Returns:* `AccessTokenResponse` - Document upload token

### Check Documentation Data
**Name:** `checkDocumentationData`

*Purpose:* Checks the status of user's submitted documentation

*Required Information:* None

*Returns:* `ApplicantDataResponse` - Current status of user's documentation verification

# Documents

### Get Document Types
**Name:** `getDocumentTypes`

*Purpose:* Retrieves available document types for verification

*Required Information:* None

*Returns:* `DocumentTypesResponse` - List of available document types

### Get User Documents
**Name:** `getUserDocuments`

*Purpose:* Retrieves user's uploaded documents

*Required Information:* None

*Returns:* `UserDocumentsResponse` - List of user's uploaded documents

### Upload User Document
**Name:** `uploadUserDocument`

*Purpose:* Uploads a single user verification document

*Required Information:*
- Document Type
- File Data
- File Name


*Returns:* `UploadDocumentResponse` - Upload status

### Upload Multiple User Documents
**Name:** `uploadMultipleUserDocuments`

*Purpose:* Uploads multiple user verification documents

*Required Information:*
- Document Type
- Files (Dictionary of filename to file data pairs)


*Returns:* `UploadDocumentResponse` - Upload status

# Consent Management

### Get All Consents
**Name:** `getAllConsents`

*Purpose:* Retrieves all available consent types and their information

*Required Information:* None

*Returns:* `[ConsentInfo]` - Array of consent information including mandatory and optional consents

### Get User Consents
**Name:** `getUserConsents`

*Purpose:* Retrieves the user's current consent statuses

*Required Information:* None

*Returns:* `[UserConsent]` - Array of user consents with their current status

### Set User Consents
**Name:** `setUserConsents`

*Purpose:* Updates user consent statuses for specified consent versions

*Required Information:*
- Consent Version IDs (optional)
- Unconsent Version IDs (optional)


*Returns:* `BasicResponse` - Consent update status
