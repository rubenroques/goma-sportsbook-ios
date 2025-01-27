# API Documentation

This documentation provides a comprehensive overview of our API services, including available endpoints and data models.

## Table of Contents
1. [REST Services](#rest-services)
2. [Real-time Services](#real-time-services)
3. [Data Models](#data-models)

# REST Services

## bonuses

### optOutBonus

_Opts out from a specific bonus_

**Required Information:**
- code (String): The bonus code to opt out from
- partyId (String): User's party identifier

### cancelBonus

_Cancels an active bonus_

**Required Information:**
- bonusId (String): ID of the bonus to cancel

### redeemAvailableBonus

_Claims an available bonus for a specific user_

**Required Information:**
- code (String): The bonus code to redeem
- partyId (String): User's party identifier

### getGrantedBonuses

_Retrieves the list of bonuses that have been granted to the user_

**Required Information:**

### getAvailableBonuses

_Retrieves the list of bonuses available for the user to claim_

**Required Information:**

### redeemBonus

_Redeems a bonus using a bonus code_

**Required Information:**
- code (String): The bonus code to redeem

## responsible_gaming

### getPersonalDepositLimits

_Retrieves the user's personal deposit limits_

**Required Information:**

### updateResponsibleGamingLimits

_Updates the user's responsible gaming limits_

**Required Information:**
- limitType (String): Type of limit (deposit, betting, or autoPayout)
- hasRollingWeeklyLimits (Bool): Whether to use rolling weekly limits instead of calendar weekly limits
- newLimit (Double): New limit amount

### updateWeeklyBettingLimits

_Updates the user's weekly betting limits_

**Required Information:**
- newLimit (Double): New weekly betting limit amount

### getLimits

_Retrieves all user limits information_

**Required Information:**

### getResponsibleGamingLimits

_Retrieves responsible gaming limits for specified period and limit types_

**Required Information:**
- limitTypes (String?): Comma-separated list of limit types (e.g., 'DEPOSIT_LIMIT,WAGER_LIMIT,BALANCE_LIMIT')
- periodTypes (String?): Comma-separated list of period types (e.g., 'RollingWeekly,Permanent')

### updateWeeklyDepositLimits

_Updates the user's weekly deposit limits_

**Required Information:**
- newLimit (Double): New weekly deposit limit amount

## betting

### cashoutBet

_Performs a cashout operation on a specific bet_

**Required Information:**
- betId (String): ID of the bet to cash out
- stakeValue (Double?): Optional stake value for partial cashout
- cashoutValue (Double): Value to cash out

### getWonBetsHistory

_Retrieves history of won bets with optional date filtering_

**Required Information:**
- pageIndex (Int): Page number for pagination
- endDate (String?): Optional end date for filtering bets
- startDate (String?): Optional start date for filtering bets

### updateBetslipSettings

_Updates the user's betslip settings_

**Required Information:**
- betslipSettings (BetslipSettings): New betslip settings to apply

### allowedCashoutBetIds

_Retrieves IDs of bets that are eligible for cashout_

**Required Information:**

### placeBets

_Places one or more bets using the provided bet tickets_

**Required Information:**
- betTickets ([BetTicket]): Array of bet tickets to place
- useFreebetBalance (Bool): Whether to use freebet balance for placing bets

### getTicketSelection

_Retrieves a specific ticket selection by its ID_

**Required Information:**
- ticketSelectionId (String): ID of the ticket selection to retrieve

### getAllowedBetTypes

_Retrieves allowed bet types for given selections_

**Required Information:**
- betTicketSelections ([BetTicketSelection]): Array of bet ticket selections to check allowed types for

### calculateCashout

_Calculates the cashout value for a specific bet_

**Required Information:**
- stakeValue (String?): Optional stake value for partial cashout
- betId (String): ID of the bet to calculate cashout for

### rejectBoostedBet

_Rejects a boosted bet offer_

**Required Information:**
- identifier (String): Unique identifier of the boosted bet to reject

### getFreebet

_Retrieves information about available freebets for the user_

**Required Information:**

### getResolvedBetsHistory

_Retrieves history of resolved bets with optional date filtering_

**Required Information:**
- startDate (String?): Optional start date for filtering bets
- pageIndex (Int): Page number for pagination
- endDate (String?): Optional end date for filtering bets

### getSharedTicket

_Retrieves a shared bet ticket by its ID_

**Required Information:**
- betslipId (String): ID of the shared bet ticket to retrieve

### calculatePotentialReturn

_Calculates potential return for a bet ticket before placing the bet_

**Required Information:**
- betTicket (BetTicket): The bet ticket to calculate potential returns for

### calculateCashback

_Calculates potential cashback for a bet ticket_

**Required Information:**
- betTicket (BetTicket): The bet ticket to calculate cashback for

### placeBetBuilderBet

_Places a bet builder bet with calculated odds_

**Required Information:**
- calculatedOdd (Double): Pre-calculated odds for the bet builder
- betTicket (BetTicket): The bet builder ticket to place

### getBetHistory

_Retrieves betting history with pagination_

**Required Information:**
- pageIndex (Int): Page number for pagination

### getBetslipSettings

_Retrieves the current betslip settings for the user_

**Required Information:**

### getBetDetails

_Retrieves detailed information about a specific bet_

**Required Information:**
- identifier (String): Unique identifier of the bet to retrieve

### calculateBetBuilderPotentialReturn

_Calculates potential return for a bet builder ticket_

**Required Information:**
- betTicket (BetTicket): The bet builder ticket to calculate potential returns for

### getOpenBetsHistory

_Retrieves history of open bets with optional date filtering_

**Required Information:**
- endDate (String?): Optional end date for filtering bets
- pageIndex (Int): Page number for pagination
- startDate (String?): Optional start date for filtering bets

### confirmBoostedBet

_Confirms a boosted bet offer_

**Required Information:**
- identifier (String): Unique identifier of the boosted bet to confirm

## registration

### validateUsername

_Validates a username and provides suggestions if unavailable_

**Required Information:**
- username (String): Username to validate

### signUp

_Registers a new user with complete information_

**Required Information:**
- form (SignUpForm): No description available

### signupConfirmation

_Confirms user signup with verification code_

**Required Information:**
- confirmationCode (String): Verification code received by user
- email (String): Email address used for registration

### signUpCompletion

_Completes the signup process with additional user information_

**Required Information:**
- Form containing additional user information

### checkEmailRegistered

_Checks if an email is already registered in the system_

**Required Information:**
- email (String): Email address to check

### simpleSignUp

_Registers a new user with basic information_

**Required Information:**
- form (SimpleSignUpForm): No description available

## events

### getMarketInfo

_Retrieves detailed information about a specific market_

**Required Information:**
- marketId (String): Unique identifier of the market to retrieve

### getEventForMarketGroup

_Retrieves an event associated with a specific market group_

**Required Information:**
- withId (String): Unique identifier of the market group

### getHeroGameEvent

_Retrieves the hero game event_

**Required Information:**

### getPromotionalTopBanners

_Retrieves promotional banners for the top section_

**Required Information:**

### getEventLiveData

_Retrieves live data and statistics for a specific event_

**Required Information:**
- eventId (String): Unique identifier of the event

### getSportRegions

_Retrieves information about regions available for a specific sport_

**Required Information:**
- sportId (String): Unique identifier of the sport to get regions for

### getEventSummary

_Retrieves a summary of a specific event using its event ID_

**Required Information:**
- eventId (String): Unique identifier of the event to retrieve

### getEventSummaryByMarket

_Retrieves a summary of an event using a market ID associated with the event_

**Required Information:**
- forMarketId (String): Market ID associated with the event to retrieve

### getEventDetails

_Retrieves detailed information about a specific event_

**Required Information:**
- eventId (String): Unique identifier of the event

### getHighlightedVisualImageEvents

_Retrieves events with visual images that are highlighted_

**Required Information:**

### getHighlightedLiveEventsIds

_Retrieves IDs of highlighted live events, optionally filtered by user_

**Required Information:**
- userId (String?): Optional user ID for personalized highlights
- eventCount (Int): Maximum number of event IDs to retrieve

### getHighlightedBoostedEvents

_Retrieves events with boosted odds that are highlighted_

**Required Information:**

### getPromotedSports

_Retrieves the list of promoted sports_

**Required Information:**

### getTopCompetitions

_Retrieves the list of top competitions_

**Required Information:**

### getHomeSliders

_Retrieves the home page slider banners_

**Required Information:**

### getSearchEvents

_Searches for events based on a query string with pagination support_

**Required Information:**
- isLive (Bool): Filter for live events only
- resultLimit (String): Maximum number of results to return per page
- page (String): Page number for paginated results
- query (String): Search query string to find events

### getCashbackSuccessBanner

_Retrieves the cashback success banner_

**Required Information:**

### getEventSecundaryMarkets

_Retrieves secondary markets information for a specific event_

**Required Information:**
- eventId (String): Unique identifier of the event

### getPromotionalSlidingTopEvents

_Retrieves promotional sliding events for the top section_

**Required Information:**

### getAvailableSportTypes

_Retrieves a list of available sport types within an optional date range_

**Required Information:**
- initialDate (Date?): Optional start date to filter sports availability
- endDate (Date?): Optional end date to filter sports availability

### getPromotionalTopStories

_Retrieves promotional top stories_

**Required Information:**

### getEventsForEventGroup

_Retrieves events associated with a specific event group_

**Required Information:**
- withId (String): Unique identifier of the event group

### getHighlightedMarkets

_Retrieves highlighted markets_

**Required Information:**

### getCompetitionMarketGroups

_Retrieves information about market groups available for a specific competition_

**Required Information:**
- competitionId (String): Unique identifier of the competition to get market groups for

### getRegionCompetitions

_Retrieves information about competitions available in a specific region_

**Required Information:**
- regionId (String): Unique identifier of the region to get competitions for

### getTopCompetitionsPointers

_Retrieves pointers to top competitions_

**Required Information:**

### getHighlightedLiveEvents

_Retrieves detailed information about highlighted live events, optionally filtered by user_

**Required Information:**
- eventCount (Int): Maximum number of events to retrieve
- userId (String?): Optional user ID for personalized highlights

## authentication

### login

_Authenticates a user with username and password_

**Required Information:**
- password (String): User's login password
- username (String): User's login username

### logout

_Logs out the current user and invalidates their session_

**Required Information:**

### getPasswordPolicy

_Retrieves the password policy requirements_

**Required Information:**

## identity_verification

### getSumsubAccessToken

_Retrieves an access token for Sumsub identity verification service_

**Required Information:**
- userId (String): User's unique identifier
- levelName (String): Verification level name

### checkDocumentationData

_Checks the status of user's submitted documentation_

**Required Information:**

### getSumsubApplicantData

_Retrieves applicant verification data from Sumsub_

**Required Information:**
- userId (String): User's unique identifier

### generateDocumentTypeToken

_Generates a token for uploading a specific type of document_

**Required Information:**
- docType (String): Type of document to generate token for

## account_management

### forgotPassword

_Initiates the password recovery process_

**Required Information:**
- secretQuestion (String?): Optional security question
- secretAnswer (String?): Optional answer to security question
- email (String): Email address for password recovery

### lockPlayer

_Locks a player's account with specified duration_

**Required Information:**
- lockPeriod (String?): Duration of the lock period
- isPermanent (Bool?): Whether the lock is permanent
- lockPeriodUnit (String?): Unit of time for the lock period

### updateExtraInfo

_Updates additional user information_

**Required Information:**
- placeOfBirth (String?): User's place of birth
- address2 (String?): Secondary address

### getMobileVerificationCode

_Requests a verification code for a mobile number_

**Required Information:**
- mobileNumber (String): Mobile number to verify

### updateUserProfile

_Updates the user's profile information_

**Required Information:**
- form (UpdateUserProfileForm): No description available

### updateDeviceIdentifier

_Updates the device identifier and app version for the user_

**Required Information:**
- deviceIdentifier (String): Unique device identifier
- appVersion (String): Current app version

### verifyMobileCode

_Verifies a mobile verification code_

**Required Information:**
- code (String): Verification code received by user
- requestId (String): ID of the verification request

### updatePassword

_Updates the user's password_

**Required Information:**
- oldPassword (String): Current password for verification
- newPassword (String): New password to set

## wallet

### getUserCashbackBalance

_Retrieves the user's cashback balance information_

**Required Information:**

### getUserBalance

_Retrieves the user's wallet balance information_

**Required Information:**

## profile

### getUserProfile

_Retrieves the user's profile information_

**Required Information:**
- kycExpire (String?): Optional KYC expiration date

## referral

### getReferralLink

_Retrieves the user's referral link_

**Required Information:**

### getReferees

_Retrieves the list of users referred by the current user_

**Required Information:**

## payments

### getWithdrawalMethods

_Retrieves available withdrawal methods_

**Required Information:**

### getPaymentInformation

_Retrieves saved payment information for the user_

**Required Information:**

### prepareWithdrawal

_Prepares a withdrawal request for processing_

**Required Information:**
- paymentMethod (String): Selected withdrawal method

### getTransactionsHistory

_Retrieves transaction history for a specified date range_

**Required Information:**
- pageNumber (Int?): Optional page number for pagination
- startDate (String): Start date for transaction history
- endDate (String): End date for transaction history
- transactionTypes ([TransactionType]?): Optional array of transaction types to filter

### processDeposit

_Processes a deposit request_

**Required Information:**
- amount (Double): Deposit amount
- paymentMethod (String): Selected payment method
- option (String): Payment option details

### checkPaymentStatus

_Checks the status of a payment transaction_

**Required Information:**
- paymentId (String): ID of the payment to check
- paymentMethod (String): Payment method used for the transaction

### getPendingWithdrawals

_Retrieves list of pending withdrawal transactions_

**Required Information:**

### processWithdrawal

_Processes a withdrawal request_

**Required Information:**
- paymentMethod (String): Selected withdrawal method
- conversionId (String?): Optional conversion ID for currency conversion
- amount (Double): Withdrawal amount

### cancelWithdrawal

_Cancels a pending withdrawal transaction_

**Required Information:**
- paymentId (Int): ID of the withdrawal payment to cancel

### addPaymentInformation

_Adds new payment information for the user_

**Required Information:**
- fields (String): Payment information fields in string format
- type (String): Type of payment information

### getPayments

_Retrieves available payment methods for deposits_

**Required Information:**

### cancelDeposit

_Cancels a pending deposit transaction_

**Required Information:**
- paymentId (String): ID of the deposit payment to cancel

### updatePayment

_Updates payment information for an existing payment_

**Required Information:**
- paymentId (String): ID of the payment to update
- amount (Double): Payment amount
- encryptedExpiryMonth (String?): Encrypted card expiry month
- encryptedSecurityCode (String?): Encrypted card security code
- encryptedCardNumber (String?): Encrypted card number
- encryptedExpiryYear (String?): Encrypted card expiry year
- type (String): Payment type
- nameOnCard (String?): Name as it appears on the card
- returnUrl (String?): URL to return to after payment processing

## documents

### getDocumentTypes

_Retrieves available document types for verification_

**Required Information:**

### uploadMultipleUserDocuments

_Uploads multiple user verification documents_

**Required Information:**
- documentType (String): Type of documents being uploaded
- files ([String: Data]): Dictionary of filename to file data pairs

### getUserDocuments

_Retrieves user's uploaded documents_

**Required Information:**

### uploadUserDocument

_Uploads a single user verification document_

**Required Information:**
- documentType (String): Type of document being uploaded
- file (Data): Document file data
- fileName (String): Name of the file being uploaded

## favorites

### addFavoriteToList

_Adds an event to a specified favorites list_

**Required Information:**
- eventId (String): ID of the event to add to favorites
- listId (Int): ID of the favorites list to add the event to

### deleteFavoriteFromList

_Deletes a favorite event from a list_

**Required Information:**
- eventId (Int): ID of the event to delete from favorites

### getFavoritesList

_Retrieves all favorite lists for the current user_

**Required Information:**

### deleteFavoritesList

_Deletes a favorites list with the specified ID_

**Required Information:**
- listId (Int): ID of the favorites list to delete

### getPromotedBetslips

_Retrieves promoted betslips, optionally filtered by user_

**Required Information:**
- userId (String?): Optional user ID for personalized betslips

### getFavoritesFromList

_Retrieves all favorite events from a specified list_

**Required Information:**
- listId (Int): ID of the favorites list to get events from

### addFavoritesList

_Creates a new favorites list with the specified name_

**Required Information:**
- name (String): Name of the new favorites list

## support

### contactSupport

_Sends a detailed support request with user information_

**Required Information:**
- lastName (String): User's last name
- firstName (String): User's first name
- message (String): Detailed message content
- subject (String): Subject of the support request
- email (String): User's email address
- subjectType (String): Category or type of the support request
- userIdentifier (String): User's unique identifier
- isLogged (Bool): Whether the user is currently logged in

### contactUs

_Sends a contact request to customer support_

**Required Information:**
- email (String): User's email address
- firstName (String): User's first name
- lastName (String): User's last name
- message (String): Message content
- subject (String): Subject of the contact request

## location

### getCountries

_Retrieves list of available countries_

**Required Information:**

### getCurrentCountry

_Retrieves the current country information_

**Required Information:**

### getAllCountries

_Retrieves all available countries_

**Required Information:**

## consent_management

### setUserConsents

_Updates user consent statuses for specified consent versions_

**Required Information:**
- consentVersionIds ([Int]?): Array of consent version IDs to consent to
- unconsenVersionIds ([Int]?): Array of consent version IDs to revoke consent from

### getAllConsents

_Retrieves all available consent types and their information_

**Required Information:**

### getUserConsents

_Retrieves the user's current consent statuses_

**Required Information:**


# Real-time Services

_These services provide real-time updates through WebSocket connections._

### subscribeCompetitionMatches

_Subscribes to matches updates for a specific competition identified by its market group ID_

**Update Information:**
- Frequency: real-time

### subscribeToLiveDataUpdates

_Subscribes to real-time live data updates for a specific event, including detailed statistics and play-by-play information_

**Update Information:**
- Frequency: real-time

### subscribeAllSportTypes

_Subscribes to updates for all available sport types, including both live and pre-live sports_

**Update Information:**
- Frequency: on-change

### subscribeEventMarkets

_Subscribes to all markets associated with a specific event, including odds updates and market status changes_

**Update Information:**
- Frequency: real-time

### subscribeLiveSportTypes

_Subscribes to updates for currently live sport types and their active events_

**Update Information:**
- Frequency: real-time

### subscribePreLiveMatches

_Subscribes to pre-live (upcoming) matches for a specific sport type with optional date range and sorting parameters_

**Update Information:**
- Frequency: on-change

### subscribeLiveMatches

_Subscribes to live matches updates for a specific sport type through WebSocket connection_

**Update Information:**
- Frequency: real-time

### subscribeToMarketDetails

_Subscribes to real-time updates for a specific market within an event_

**Update Information:**
- Frequency: real-time

### subscribePreLiveSportTypes

_Subscribes to updates for available pre-live sport types within a specified date range_

**Update Information:**
- Frequency: on-change

### subscribeOutrightMarkets

_Subscribes to outright market updates for a specific market group (e.g., tournament winner, top scorer)_

**Update Information:**
- Frequency: on-change

### subscribeEventDetails

_Subscribes to detailed updates for a specific event, including scores, statistics, and market information_

**Update Information:**
- Frequency: real-time
- Includes:
  - score updates
  - match statistics
  - timeline events
  - market information
  - event status changes


# Data Models

_This section describes the data structures used in the API._

### AccessTokenResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| code | Int? | Optional Int property |
| userId | String? | Optional String property |
| description | String? | Optional String property |
| token | String? | Optional String property |

### AddPaymentInformationResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| message | String? | Optional String property |
| status | String | String property |

### ApplicantDataInfo

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| applicantDocs | ApplicantDoc? | Optional Array of ApplicantDoc property |

**Related Models:**
- [ApplicantDoc](#applicantdoc)

### ApplicantDataResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| reviewData | ApplicantReviewData? | Optional ApplicantReviewData property |
| description | String? | Optional String property |
| externalUserId | String? | Optional String property |
| info | ApplicantDataInfo? | Optional ApplicantDataInfo property |

**Related Models:**
- [ApplicantDataInfo](#applicantdatainfo)
- [ApplicantReviewData](#applicantreviewdata)

### ApplicantDoc

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| docType | String | String property |

### ApplicantReviewData

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| levelName | String | String property |
| reviewDate | String? | Optional String property |
| createDate | String | String property |
| attemptCount | Int | Int property |
| reviewResult | ApplicantReviewResult? | Optional ApplicantReviewResult property |
| reviewStatus | String | String property |

**Related Models:**
- [ApplicantReviewResult](#applicantreviewresult)

### ApplicantReviewResult

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| reviewAnswer | String | String property |
| reviewRejectType | String? | Optional String property |
| moderationComment | String? | Optional String property |

### ApplicantRootResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| data | [ApplicantDataResponse](#applicantdataresponse) | ApplicantDataResponse property |
| status | String | String property |
| message | String? | Optional String property |

**Related Models:**
- [ApplicantDataResponse](#applicantdataresponse)

### AvailableBonusResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | String property |
| bonuses | AvailableBonus | Array of AvailableBonus property |

**Related Models:**

### BalanceResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| bonusBalanceNumber | Double? | Optional Double property |
| loyaltyPoint | Int? | Optional Int property |
| casinoPlayableBonusBalanceNumber | Double? | Optional Double property |
| status | String | String property |
| bonusBalance | String? | Optional String property |
| casinoPlayableBonusBalance | String? | Optional String property |
| totalEscrowBalanceNumber | Double? | Optional Double property |
| withdrawableEscrowBalanceNumber | Double? | Optional Double property |
| withdrawRestrictionAmount | String? | Optional String property |
| sportsbookPlayableBonusBalanceNumber | Double? | Optional Double property |
| message | String? | Optional String property |
| withdrawableBalance | String? | Optional String property |
| sportsbookPlayableBonusBalance | String? | Optional String property |
| totalWithdrawableBalanceNumber | Double? | Optional Double property |
| vipStatus | String? | Optional String property |
| withdrawableEscrowBalance | String? | Optional String property |
| totalBalanceNumber | Double? | Optional Double property |
| pendingBonusBalanceNumber | Double? | Optional Double property |
| currency | String? | Optional String property |
| totalWithdrawableBalance | String? | Optional String property |
| totalBalance | String? | Optional String property |
| withdrawableBalanceNumber | Double? | Optional Double property |
| totalEscrowBalance | String? | Optional String property |
| withdrawRestrictionAmountNumber | Double? | Optional Double property |
| pendingBonusBalance | String? | Optional String property |

### BankPaymentDetail

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| key | String | String property |
| value | String | String property |
| id | Int | Int property |
| paymentInfoId | Int | Int property |

### BankPaymentInfo

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| details | [BankPaymentDetail](#bankpaymentdetail) | Array of BankPaymentDetail property |
| id | Int | Int property |
| description | String? | Optional String property |
| type | String | String property |
| partyId | Int | Int property |
| priority | Int? | Optional Int property |

**Related Models:**
- [BankPaymentDetail](#bankpaymentdetail)

### Banner

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| linkUrl | String? | Optional String property |
| title | String | String property |
| id | String | String property |
| bodyText | String? | Optional String property |
| name | String | String property |
| marketId | String? | Optional String property |
| imageUrl | String | String property |
| type | String | String property |

### BannerResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| bannerItems | [Banner](#banner) | Array of Banner property |

**Related Models:**
- [Banner](#banner)

### BasicResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | String property |
| message | String? | Optional String property |

### Bet

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| state | BetState | BetState property |
| freebetReturn | Double? | Optional Double property |
| attemptedDate | Date | Date property |
| fallbackDateFormatter | DateFormatter | DateFormatter property |
| oddDenominator | Double | Double property |
| potentialReturn | Double? | Optional Double property |
| freeBet | Bool | Bool property |
| totalStake | Double | Double property |
| totalReturn | Double? | Optional Double property |
| order | Int | Int property |
| tournamentName | String? | Optional String property |
| outcomeName | String | String property |
| totalOdd | Double | Double property |
| eventId | Double | Double property |
| homeTeamName | String? | Optional String property |
| identifier | String | String property |
| potentialCashbackReturn | Double? | Optional Double property |
| globalState | BetState | BetState property |
| partialCashoutReturn | Double? | Optional Double property |
| eventName | String | String property |
| eventDate | Date? | Optional Date property |
| potentialFreebetReturn | Double? | Optional Double property |
| result | BetResult | BetResult property |
| eventResult | String? | Optional String property |
| tournamentCountryName | String? | Optional String property |
| type | String | String property |
| cashbackReturn | Double? | Optional Double property |
| awayTeamName | String? | Optional String property |
| oddNumerator | Double | Double property |
| sportTypeName | String | String property |
| partialCashoutStake | Double? | Optional Double property |
| marketName | String | String property |
| dateFormatter | DateFormatter | DateFormatter property |
| betslipId | Int? | Optional Int property |

**Related Models:**

### BetBuilderPotentialReturn

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| calculatedOdds | Double | Double property |
| potentialReturn | Double | Double property |

### BetSlip

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| tickets | [BetTicket](#betticket) | Array of BetTicket property |

**Related Models:**
- [BetTicket](#betticket)

### BetSlipStateResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| tickets | [BetTicket](#betticket) | Array of BetTicket property |

**Related Models:**
- [BetTicket](#betticket)

### BetTicket

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| winStake | String | String property |
| selections | [BetTicketSelection](#betticketselection) | Array of BetTicketSelection property |
| potentialReturn | Double? | Optional Double property |
| betTypeCode | String | String property |
| pool | Bool | Bool property |

**Related Models:**
- [BetTicketSelection](#betticketselection)

### BetTicketSelection

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| eachWayPlaceTerms | String | String property |
| isTrap | String | String property |
| priceUp | String | String property |
| identifier | String | String property |
| priceDown | String | String property |
| eachWayReduction | String | String property |
| idFOPriceType | String | String property |

### BetType

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| numberOfIndividualBets | Int | Int property |
| typeName | String | String property |
| typeCode | String | String property |
| potencialReturn | Double | Double property |
| totalStake | Double | Double property |

### BetslipPotentialReturnResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| totalStake | Double | Double property |
| totalOdd | Double? | Optional Double property |
| numberOfBets | Int | Int property |
| potentialReturn | Double | Double property |

### BetslipSettings

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| oddChangeRunningOrPreMatch | BetslipOddChangeSetting? | Optional BetslipOddChangeSetting property |
| oddChangeLegacy | BetslipOddChangeSetting? | Optional BetslipOddChangeSetting property |

**Related Models:**

### BettingHistory

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| bets | [Bet](#bet) | Array of Bet property |

**Related Models:**
- [Bet](#bet)

### CancelWithdrawalResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | String property |
| currency | String | String property |
| amount | String | String property |

### CashbackBalance

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| balance | String? | Optional String property |
| message | String? | Optional String property |
| status | String | String property |

### CashbackResult

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| amountFree | Double? | Optional Double property |
| id | Double | Double property |
| amount | Double? | Optional Double property |

### Cashout

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| cashoutValue | Double | Double property |
| partialCashoutAvailable | Bool? | Optional Bool property |

### CashoutResult

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| cashoutReoffer | Double? | Optional Double property |
| message | String? | Optional String property |
| cashoutResult | Int? | Optional Int property |

### CheckCredentialResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| fieldExist | Bool | Bool property |
| exists | String | String property |
| status | String | String property |

### CheckUsernameResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| additionalInfos | CheckUsernameAdditionalInfo? | Optional Array of CheckUsernameAdditionalInfo property |
| message | String? | Optional String property |
| errors | CheckUsernameError? | Optional Array of CheckUsernameError property |
| status | String | String property |

**Related Models:**

### CompetitionMarketGroup

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | String property |
| name | String | String property |
| events | Event | Array of Event property |

**Related Models:**

### CompetitionParentNode

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| categoryName | String | String property |
| name | String | String property |
| id | String | String property |

### ConfirmBetPlaceResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| statusText | String? | Optional String property |
| state | Int | Int property |
| statusCode | String? | Optional String property |
| detailedState | Int | Int property |

### Consent

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String? | Optional String property |
| key | String | String property |
| consentVersionId | Int | Int property |
| isMandatory | Bool? | Optional Bool property |
| id | Int | Int property |
| name | String | String property |

### ConsentsResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | String property |
| consents | [Consent](#consent) | Array of Consent property |

**Related Models:**
- [Consent](#consent)

### CountryInfo

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| name | String | String property |
| iso2Code | String | String property |
| phonePrefix | String | String property |

### DepositMethod

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| code | String | String property |
| methods | PaymentMethod? | Optional Array of PaymentMethod property |
| paymentMethod | String | String property |

**Related Models:**
- [PaymentMethod](#paymentmethod)

### DocumentType

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| expiryDateRequired | Bool? | Optional Bool property |
| documentNumberRequired | Bool? | Optional Bool property |
| documentType | String | String property |
| multipleFileRequired | Bool? | Optional Bool property |
| issueDateRequired | Bool? | Optional Bool property |

### DocumentTypesResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| documentTypes | [DocumentType](#documenttype) | Array of DocumentType property |
| status | String | String property |

**Related Models:**
- [DocumentType](#documenttype)

### EventLiveDataExtended

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| matchTime | String? | Optional String property |
| awayScore | Int? | Optional Int property |
| id | String | String property |
| homeScore | Int? | Optional Int property |
| activePlayerServing | ActivePlayerServe? | Optional ActivePlayerServe property |
| scores | String: Score | Array of String: Score property |
| status | EventStatus? | Optional EventStatus property |

**Related Models:**

### EventsGroup

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| marketGroupId | String? | Optional String property |
| events | Event | Array of Event property |

**Related Models:**

### FavoriteAddResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| idAccountFavorite | Int? | Optional Int property |
| displayOrder | Int? | Optional Int property |

### FavoriteEvent

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| favoriteListId | Int | Int property |
| id | String | String property |
| name | String | String property |
| accountFavoriteId | Int | Int property |

### FavoriteEventResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| favoriteEvents | [FavoriteEvent](#favoriteevent) | Array of FavoriteEvent property |

**Related Models:**
- [FavoriteEvent](#favoriteevent)

### FavoriteList

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| name | String | String property |
| customerId | Int | Int property |
| id | Int | Int property |

### FavoritesListAddResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| listId | Int | Int property |

### FavoritesListDeleteResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| listId | String? | Optional String property |

### FavoritesListResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| favoritesList | [FavoriteList](#favoritelist) | Array of FavoriteList property |

**Related Models:**
- [FavoriteList](#favoritelist)

### FieldError

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| field | String | String property |
| error | String | String property |

### FreebetResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| balance | Double | Double property |

### GetCountriesResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | String property |
| countries | String | Array of String property |

### GetCountryInfoResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | String property |
| countryInfo | [CountryInfo](#countryinfo) | CountryInfo property |

**Related Models:**
- [CountryInfo](#countryinfo)

### GrantedBonusResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | String property |
| bonuses | GrantedBonus | Array of GrantedBonus property |

**Related Models:**

### HeadlineItem

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| idfwheadlinetype | String? | Optional String property |
| imageURL | String? | Optional String property |
| linkURL | String? | Optional String property |
| categoryName | String? | Optional String property |
| idfwheadline | String? | Optional String property |
| name | String? | Optional String property |
| marketId | String? | Optional String property |
| tsactivefrom | String? | Optional String property |
| tsactiveto | String? | Optional String property |
| marketGroupId | String? | Optional String property |
| headlinemediatype | String? | Optional String property |
| tournamentCountryName | String? | Optional String property |
| oldMarketId | String? | Optional String property |
| numofselections | String? | Optional String property |
| title | String? | Optional String property |

### HeadlineResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| headlineItems | HeadlineItem? | Optional Array of HeadlineItem property |

**Related Models:**
- [HeadlineItem](#headlineitem)

### HighlightedEventPointer

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| sportId | String | String property |
| countryId | String | String property |
| status | String | String property |
| eventType | String? | Optional String property |
| eventId | String | String property |

### KYCStatusDetail

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| expiryDate | String? | Optional String property |

### LimitPending

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| limitNumber | Double | Double property |
| limit | String | String property |
| effectiveDate | String | String property |

### LimitsResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | String property |
| currency | String | String property |
| wagerLimit | String? | Optional String property |
| lossLimit | String? | Optional String property |
| pendingWagerLimit | LimitPending? | Optional LimitPending property |

**Related Models:**
- [LimitPending](#limitpending)

### LoginResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| currency | String? | Optional String property |
| isFirstLogin | String? | Optional String property |
| status | String | String property |
| sessionKey | String? | Optional String property |
| pendingLimitConfirmation | String? | Optional String property |
| email | String? | Optional String property |
| level | String? | Optional String property |
| userType | String? | Optional String property |
| kycStatus | String? | Optional String property |
| kycStatusDetails | KYCStatusDetail? | Optional KYCStatusDetail property |
| username | String? | Optional String property |
| securityVerificationRequiredFields | String? | Optional Array of String property |
| language | String? | Optional String property |
| message | String? | Optional String property |
| partyId | String? | Optional String property |
| parentId | String? | Optional String property |
| country | String? | Optional String property |
| registrationStatus | String? | Optional String property |
| lockUntilDateFormatted | String? | Optional String property |
| lockStatus | String? | Optional String property |

**Related Models:**
- [KYCStatusDetail](#kycstatusdetail)

### Market

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| isMainMarket | Bool | Bool property |
| competitionId | String? | Optional String property |
| competitionName | String? | Optional String property |
| sportIdCode | String? | Optional String property |
| id | String | String property |
| outcomesOrder | OutcomesOrder | OutcomesOrder property |
| homeParticipant | String? | Optional String property |
| sportTypeName | String? | Optional String property |
| isTradable | Bool | Bool property |
| isOverUnder | Bool | Bool property |
| awayParticipant | String? | Optional String property |
| name | String | String property |
| eventId | String? | Optional String property |
| marketDigitLine | String? | Optional String property |
| marketTypeCategoryId | String? | Optional String property |
| eventMarketTypeId | String? | Optional String property |
| tournamentCountryName | String? | Optional String property |
| eventName | String? | Optional String property |
| marketTypeId | String? | Optional String property |
| sportTypeCode | String? | Optional String property |
| startDate | Date? | Optional Date property |
| isMainOutright | Bool? | Optional Bool property |
| eventMarketCount | Int? | Optional Int property |
| outcomes | [Outcome](#outcome) | Array of Outcome property |
| customBetAvailable | Bool? | Optional Bool property |

**Related Models:**
- [Outcome](#outcome)

### MarketGroup

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| markets | [Market](#market) | Array of Market property |
| marketGroupId | String? | Optional String property |

**Related Models:**
- [Market](#market)

### MarketGroupPromotedSport

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| name | String? | Optional String property |
| id | String | String property |
| typeId | String? | Optional String property |

### MobileVerifyResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| requestId | Int? | Optional Int property |
| message | String? | Optional String property |
| status | String | String property |

### OpenSessionResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| launchToken | String | String property |
| status | String | String property |

### Outcome

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| odd | OddFormat | OddFormat property |
| isTerminated | Bool? | Optional Bool property |
| priceNumerator | String? | Optional String property |
| marketId | String? | Optional String property |
| name | String | String property |
| isOverUnder | Bool | Bool property |
| customBetAvailableMarket | Bool? | Optional Bool property |
| id | String | String property |
| isTradable | Bool? | Optional Bool property |
| hashCode | String | String property |
| externalReference | String? | Optional String property |
| orderValue | String? | Optional String property |
| priceDenominator | String? | Optional String property |

**Related Models:**

### PaymentInformation

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | String property |
| data | [BankPaymentInfo](#bankpaymentinfo) | Array of BankPaymentInfo property |

**Related Models:**
- [BankPaymentInfo](#bankpaymentinfo)

### PaymentMethod

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| name | String | String property |
| brands | String? | Optional Array of String property |
| type | String | String property |

### PaymentStatusResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| paymentId | String? | Optional String property |
| status | String | String property |
| message | String? | Optional String property |
| paymentStatus | String? | Optional String property |

### PaymentsResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| depositMethods | [DepositMethod](#depositmethod) | Array of DepositMethod property |
| status | String | String property |

**Related Models:**
- [DepositMethod](#depositmethod)

### PendingWithdrawal

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| amount | String | String property |
| paymentId | Int | Int property |
| status | String | String property |

### PendingWithdrawalResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | String property |
| pendingWithdrawals | [PendingWithdrawal](#pendingwithdrawal) | Array of PendingWithdrawal property |

**Related Models:**
- [PendingWithdrawal](#pendingwithdrawal)

### PersonalDepositLimitResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| currency | String | String property |
| pendingWeeklyLimit | String? | Optional String property |
| pendingWeeklyLimitEffectiveDate | String? | Optional String property |
| status | String | String property |
| weeklyLimit | String? | Optional String property |
| monthlyLimit | String? | Optional String property |
| hasPendingWeeklyLimit | String? | Optional String property |
| dailyLimit | String? | Optional String property |

### PlacedBetEntry

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| potentialReturn | Double | Double property |
| betLegs | [PlacedBetLeg](#placedbetleg) | Array of PlacedBetLeg property |
| type | String? | Optional String property |
| totalAvailableStake | Double | Double property |
| identifier | String | String property |

**Related Models:**
- [PlacedBetLeg](#placedbetleg)

### PlacedBetLeg

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| odd | Double | Double property |
| identifier | String | String property |
| priceType | String | String property |
| priceNumerator | Int | Int property |
| priceDenominator | Int | Int property |

### PlacedBetsResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| identifier | String | String property |
| errorMessage | String? | Optional String property |
| responseCode | String | String property |
| totalStake | Double | Double property |
| bets | [PlacedBetEntry](#placedbetentry) | Array of PlacedBetEntry property |
| detailedResponseCode | String? | Optional String property |

**Related Models:**
- [PlacedBetEntry](#placedbetentry)

### PlayerInfoResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| mobileNeedsReview | Bool? | Optional Bool property |
| middleName | String? | Optional String property |
| lastLoginFormatted | Date? | Optional Date property |
| birthCity | String? | Optional String property |
| currency | String? | Optional String property |
| registrationStatus | String? | Optional String property |
| mobileLocalNumber | String? | Optional String property |
| partyId | String | String property |
| phoneNeedsReview | Bool? | Optional Bool property |
| isAutopay | Bool? | Optional Bool property |
| regDate | String? | Optional String property |
| mobilePhone | String? | Optional String property |
| accountNumber | String? | Optional String property |
| gender | String? | Optional String property |
| lastName | String? | Optional String property |
| phone | String? | Optional String property |
| sessionKey | String? | Optional String property |
| userId | String | String property |
| country | String? | Optional String property |
| streetNumber | String? | Optional String property |
| testPlayer | Bool? | Optional Bool property |
| idCardNumber | String? | Optional String property |
| language | String? | Optional String property |
| verificationMethod | String? | Optional String property |
| nickname | String? | Optional String property |
| emailVerificationStatus | String | String property |
| province | String? | Optional String property |
| phoneCountryCode | String? | Optional String property |
| level | Int? | Optional Int property |
| birthDate | String? | Optional String property |
| unit | String? | Optional String property |
| nationality | String? | Optional String property |
| firstName | String? | Optional String property |
| mobileCountryCode | String? | Optional String property |
| regDateFormatted | Date? | Optional Date property |
| postalCode | String? | Optional String property |
| contactPreference | String? | Optional String property |
| vipStatus | String? | Optional String property |
| birthDateFormatted | Date | Date property |
| docNumber | String? | Optional String property |
| municipality | String? | Optional String property |
| readonlyFields | String? | Optional String property |
| verificationStatus | String? | Optional String property |
| city | String? | Optional String property |
| birthCoutryCode | String? | Optional String property |
| floorNumber | String? | Optional String property |
| email | String | String property |
| extraInfos | ExtraInfo? | Optional Array of ExtraInfo property |
| userType | Int? | Optional Int property |
| madeDeposit | Bool? | Optional Bool property |
| address | String? | Optional String property |
| phoneLocalNumber | String? | Optional String property |
| parentID | String? | Optional String property |
| birthDepartment | String? | Optional String property |
| lockedStatus | String? | Optional String property |
| kycStatus | String? | Optional String property |
| building | String? | Optional String property |
| lastLogin | String? | Optional String property |
| status | String | String property |

**Related Models:**

### PrepareWithdrawalResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | String property |
| message | String? | Optional String property |
| conversionId | String? | Optional String property |

### ProcessDepositResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| continueUrl | String? | Optional String property |
| sessionId | String? | Optional String property |
| status | String | String property |
| clientKey | String? | Optional String property |
| paymentId | String? | Optional String property |
| sessionData | String? | Optional String property |
| message | String? | Optional String property |

### ProcessWithdrawalResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| message | String? | Optional String property |
| paymentId | String? | Optional String property |
| status | String | String property |

### PromotedBetslip

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| selections | [PromotedBetslipSelection](#promotedbetslipselection) | Array of PromotedBetslipSelection property |
| betslipCount | Int | Int property |

**Related Models:**
- [PromotedBetslipSelection](#promotedbetslipselection)

### PromotedBetslipSelection

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| marketId | Int? | Optional Int property |
| countryId | String? | Optional String property |
| period | String? | Optional String property |
| quoteGroup | String? | Optional String property |
| marketTypeId | Int? | Optional Int property |
| participants | String? | Optional Array of String property |
| sport | String? | Optional String property |
| country | String? | Optional String property |
| participantIds | String? | Optional Array of String property |
| sportId | String? | Optional String property |
| beginDate | String? | Optional String property |
| leagueId | String? | Optional String property |
| orakoMarketId | String | String property |
| periodId | Int? | Optional Int property |
| market | String? | Optional String property |
| marketType | String? | Optional String property |
| eventId | String? | Optional String property |
| orakoEventId | String | String property |
| outcomeType | String? | Optional String property |
| betOfferId | Int? | Optional Int property |
| eventType | String? | Optional String property |
| league | String? | Optional String property |
| status | String? | Optional String property |
| quote | Double? | Optional Double property |
| outcomeId | Int? | Optional Int property |
| id | String? | Optional String property |
| orakoSelectionId | String | String property |

### PromotedBetslipsBatchResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| promotedBetslips | [PromotedBetslip](#promotedbetslip) | Array of PromotedBetslip property |
| status | String | String property |

**Related Models:**
- [PromotedBetslip](#promotedbetslip)

### PromotedBetslipsInternalRequest

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| body | [VaixBatchBody](#vaixbatchbody) | VaixBatchBody property |
| statusCode | Int | Int property |
| name | String | String property |

**Related Models:**
- [VaixBatchBody](#vaixbatchbody)

### PromotedSport

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| marketGroups | [MarketGroupPromotedSport](#marketgrouppromotedsport) | Array of MarketGroupPromotedSport property |
| id | String | String property |
| name | String | String property |

**Related Models:**
- [MarketGroupPromotedSport](#marketgrouppromotedsport)

### PromotedSportsNodeResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| promotedSports | [PromotedSport](#promotedsport) | Array of PromotedSport property |

**Related Models:**
- [PromotedSport](#promotedsport)

### PromotedSportsResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| promotedSports | [PromotedSport](#promotedsport) | Array of PromotedSport property |

**Related Models:**
- [PromotedSport](#promotedsport)

### PromotionalBanner

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | String property |
| bannerDisplay | String? | Optional String property |
| linkType | String? | Optional String property |
| bannerContents | String? | Optional Array of String property |
| bannerType | String? | Optional String property |
| name | String? | Optional String property |
| location | String? | Optional String property |
| imageURL | String? | Optional String property |

### PromotionalBannersResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| promotionalBannerItems | [PromotionalBanner](#promotionalbanner) | Array of PromotionalBanner property |

**Related Models:**
- [PromotionalBanner](#promotionalbanner)

### PromotionalStoriesResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| promotionalStories | [PromotionalStory](#promotionalstory) | Array of PromotionalStory property |

**Related Models:**
- [PromotionalStory](#promotionalstory)

### PromotionalStory

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| linkUrl | String | String property |
| imageUrl | String | String property |
| bodyText | String | String property |
| title | String | String property |
| id | String | String property |

### RedeemBonus

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| amount | String | String property |
| expiryDate | String | String property |
| id | Int | Int property |
| name | String | String property |
| amountWagered | String | String property |
| triggerDate | String | String property |
| status | String | String property |
| wagerRequired | String | String property |

### RedeemBonusResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | String property |
| message | String? | Optional String property |
| bonus | RedeemBonus? | Optional RedeemBonus property |

**Related Models:**
- [RedeemBonus](#redeembonus)

### RefereesResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | String property |
| referees | Referee | Array of Referee property |

**Related Models:**

### ReferralLink

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| code | String | String property |
| link | String | String property |

### ReferralResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| referralLinks | [ReferralLink](#referrallink) | Array of ReferralLink property |
| status | String | String property |

**Related Models:**
- [ReferralLink](#referrallink)

### ResponsibleGamingLimit

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| effectiveDate | String | String property |
| partyId | Int | Int property |
| id | Int | Int property |
| periodType | String | String property |
| limit | Double | Double property |
| limitType | String | String property |
| expiryDate | String | String property |

### ResponsibleGamingLimitsResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| limits | [ResponsibleGamingLimit](#responsiblegaminglimit) | Array of ResponsibleGamingLimit property |
| status | String | String property |

**Related Models:**
- [ResponsibleGamingLimit](#responsiblegaminglimit)

### RestResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| data | T? | Optional T property |

**Related Models:**

### ScheduledSport

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | String property |
| name | String | String property |

### SharedBetSelection

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | Double | Double property |
| priceDenominator | Int | Int property |
| priceNumerator | Int | Int property |
| priceType | String | String property |

### SharedTicketResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| betId | Double | Double property |
| bets | SharedBet | Array of SharedBet property |
| totalStake | Double | Double property |

**Related Models:**

### SportCompetition

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | String property |
| name | String | String property |
| numberEvents | String | String property |
| numberOutrightEvents | String | String property |

### SportCompetitionInfo

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| numberOutrightEvents | String | String property |
| numberOutrightMarkets | String | String property |
| name | String | String property |
| marketGroups | [SportCompetitionMarketGroup](#sportcompetitionmarketgroup) | Array of SportCompetitionMarketGroup property |
| id | String | String property |
| parentId | String? | Optional String property |

**Related Models:**
- [SportCompetitionMarketGroup](#sportcompetitionmarketgroup)

### SportCompetitionMarketGroup

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| name | String | String property |
| id | String | String property |

### SportNode

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| numberOutrightEvents | Int | Int property |
| alphaCode | String | String property |
| numberEvents | Int | Int property |
| name | String | String property |
| numberLiveEvents | Int | Int property |
| numberOutrightMarkets | Int | Int property |
| id | String | String property |

### SportNodeInfo

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| defaultOrder | Int? | Optional Int property |
| name | String? | Optional String property |
| regionNodes | [SportRegion](#sportregion) | Array of SportRegion property |
| numOutrightEvents | String? | Optional String property |
| navigationTypes | String? | Optional Array of String property |
| numEvents | String? | Optional String property |
| numOutrightMarkets | String? | Optional String property |
| id | String | String property |
| numMarkets | String? | Optional String property |

**Related Models:**
- [SportRegion](#sportregion)

### SportRadarResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| data | T | T property |
| version | Int? | Optional Int property |

**Related Models:**

### SportRegion

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| name | String? | Optional String property |
| numberEvents | String | String property |
| numberOutrightEvents | String | String property |
| id | String | String property |

### SportRegionInfo

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| competitionNodes | [SportCompetition](#sportcompetition) | Array of SportCompetition property |
| id | String | String property |
| name | String | String property |

**Related Models:**
- [SportCompetition](#sportcompetition)

### SportType

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| alphaId | String? | Optional String property |
| numericId | String? | Optional String property |
| numberOutrightEvents | Int | Int property |
| numberOutrightMarkets | Int | Int property |
| name | String | String property |
| numberLiveEvents | Int | Int property |
| numberEvents | Int | Int property |

### SportTypeDetails

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| eventsCount | Int | Int property |
| sportType | [SportType](#sporttype) | SportType property |
| sportName | String | String property |

**Related Models:**
- [SportType](#sporttype)

### SportsList

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| sportNodes | SportNode? | Optional Array of SportNode property |

**Related Models:**
- [SportNode](#sportnode)

### StatusResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | String property |
| message | String? | Optional String property |
| errors | FieldError? | Optional Array of FieldError property |

**Related Models:**
- [FieldError](#fielderror)

### SupportRequest

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | Int | Int property |
| status | String | String property |

### SupportResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| error | String? | Optional String property |
| description | String? | Optional String property |
| request | SupportRequest? | Optional SupportRequest property |

**Related Models:**
- [SupportRequest](#supportrequest)

### TicketSelection

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| odd | Double | Double property |
| priceNumerator | String | String property |
| marketId | String | String property |
| name | String | String property |
| id | String | String property |
| priceDenominator | String | String property |

### TicketSelectionResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| data | TicketSelection? | Optional TicketSelection property |
| errorType | String? | Optional String property |

**Related Models:**
- [TicketSelection](#ticketselection)

### TopCompetitionData

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| title | String | String property |
| competitions | [TopCompetitionPointer](#topcompetitionpointer) | Array of TopCompetitionPointer property |

**Related Models:**
- [TopCompetitionPointer](#topcompetitionpointer)

### TopCompetitionPointer

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| name | String | String property |
| competitionId | String | String property |
| id | String | String property |

### TopCompetitionsResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| data | [TopCompetitionData](#topcompetitiondata) | Array of TopCompetitionData property |

**Related Models:**
- [TopCompetitionData](#topcompetitiondata)

### TransactionDetail

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| postBalanceBonus | Double | Double property |
| dateTime | String | String property |
| postBalance | Double | Double property |
| type | String | String property |
| amount | Double | Double property |
| escrowTranSubType | String? | Optional String property |
| id | Int | Int property |
| reference | String? | Optional String property |
| escrowTranType | String? | Optional String property |
| amountBonus | Double | Double property |
| currency | String | String property |
| escrowType | String? | Optional String property |
| gameTranId | String? | Optional String property |
| paymentId | Int? | Optional Int property |

### TransactionsHistoryResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | String property |
| transactions | TransactionDetail? | Optional Array of TransactionDetail property |

**Related Models:**
- [TransactionDetail](#transactiondetail)

### UpdatePaymentAction

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| url | String | String property |
| type | String | String property |
| method | String | String property |
| paymentMethodType | String | String property |

### UpdatePaymentResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| action | UpdatePaymentAction? | Optional UpdatePaymentAction property |
| resultCode | String | String property |

**Related Models:**
- [UpdatePaymentAction](#updatepaymentaction)

### UploadDocumentResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| message | String? | Optional String property |
| status | String | String property |

### UserConsentInfo

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| consentVersionId | Int | Int property |
| isMandatory | Bool? | Optional Bool property |
| key | String | String property |
| name | String | String property |
| id | Int | Int property |

### UserConsentsResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| userConsents | UserConsent | Array of UserConsent property |
| message | String? | Optional String property |
| status | String | String property |

**Related Models:**

### UserDocument

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| userDocumentFiles | UserDocumentFile? | Optional Array of UserDocumentFile property |
| status | String | String property |
| uploadDate | String | String property |
| fileName | String? | Optional String property |
| documentType | String | String property |

**Related Models:**
- [UserDocumentFile](#userdocumentfile)

### UserDocumentFile

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| fileName | String | String property |

### UserDocumentsResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | String property |
| userDocuments | [UserDocument](#userdocument) | Array of UserDocument property |

**Related Models:**
- [UserDocument](#userdocument)

### VaixBatchBody

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| data | [VaixBatchData](#vaixbatchdata) | VaixBatchData property |
| status | String | String property |

**Related Models:**
- [VaixBatchData](#vaixbatchdata)

### VaixBatchData

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| promotedBetslips | [PromotedBetslip](#promotedbetslip) | Array of PromotedBetslip property |
| count | Int | Int property |

**Related Models:**
- [PromotedBetslip](#promotedbetslip)

### WithdrawalMethod

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| minimumWithdrawal | String | String property |
| conversionRequired | Bool | Bool property |
| maximumWithdrawal | String | String property |
| paymentMethod | String | String property |
| code | String | String property |

### WithdrawalMethodsResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| withdrawalMethods | [WithdrawalMethod](#withdrawalmethod) | Array of WithdrawalMethod property |
| status | String | String property |

**Related Models:**
- [WithdrawalMethod](#withdrawalmethod)

