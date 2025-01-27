# API Documentation

This documentation provides a comprehensive overview of our API services, including available endpoints and data models.

## Table of Contents
1. [REST Services](#rest-services)
2. [Real-time Services](#real-time-services)
3. [Data Models](#data-models)

# REST Services

## favorites

### deleteFavoritesList

_Deletes a favorites list with the specified ID_

**Required Information:**
- listId (Int): ID of the favorites list to delete

### addFavoritesList

_Creates a new favorites list with the specified name_

**Required Information:**
- name (String): Name of the new favorites list

### addFavoriteToList

_Adds an event to a specified favorites list_

**Required Information:**
- listId (Int): ID of the favorites list to add the event to
- eventId (String): ID of the event to add to favorites

### getFavoritesList

_Retrieves all favorite lists for the current user_

**Required Information:**

### getFavoritesFromList

_Retrieves all favorite events from a specified list_

**Required Information:**
- listId (Int): ID of the favorites list to get events from

### deleteFavoriteFromList

_Deletes a favorite event from a list_

**Required Information:**
- eventId (Int): ID of the event to delete from favorites

### getPromotedBetslips

_Retrieves promoted betslips, optionally filtered by user_

**Required Information:**
- userId (String?): Optional user ID for personalized betslips

## support

### contactUs

_Sends a contact request to customer support_

**Required Information:**
- subject (String): Subject of the contact request
- lastName (String): User's last name
- message (String): Message content
- email (String): User's email address
- firstName (String): User's first name

### contactSupport

_Sends a detailed support request with user information_

**Required Information:**
- subjectType (String): Category or type of the support request
- firstName (String): User's first name
- isLogged (Bool): Whether the user is currently logged in
- lastName (String): User's last name
- message (String): Detailed message content
- userIdentifier (String): User's unique identifier
- email (String): User's email address
- subject (String): Subject of the support request

## identity_verification

### getSumsubApplicantData

_Retrieves applicant verification data from Sumsub_

**Required Information:**
- userId (String): User's unique identifier

### generateDocumentTypeToken

_Generates a token for uploading a specific type of document_

**Required Information:**
- docType (String): Type of document to generate token for

### checkDocumentationData

_Checks the status of user's submitted documentation_

**Required Information:**

### getSumsubAccessToken

_Retrieves an access token for Sumsub identity verification service_

**Required Information:**
- levelName (String): Verification level name
- userId (String): User's unique identifier

## account_management

### getMobileVerificationCode

_Requests a verification code for a mobile number_

**Required Information:**
- mobileNumber (String): Mobile number to verify

### verifyMobileCode

_Verifies a mobile verification code_

**Required Information:**
- code (String): Verification code received by user
- requestId (String): ID of the verification request

### updateUserProfile

_Updates the user's profile information_

**Required Information:**
- form (UpdateUserProfileForm): No description available

### lockPlayer

_Locks a player's account with specified duration_

**Required Information:**
- isPermanent (Bool?): Whether the lock is permanent
- lockPeriodUnit (String?): Unit of time for the lock period
- lockPeriod (String?): Duration of the lock period

### updateExtraInfo

_Updates additional user information_

**Required Information:**
- address2 (String?): Secondary address
- placeOfBirth (String?): User's place of birth

### updatePassword

_Updates the user's password_

**Required Information:**
- newPassword (String): New password to set
- oldPassword (String): Current password for verification

### forgotPassword

_Initiates the password recovery process_

**Required Information:**
- email (String): Email address for password recovery
- secretAnswer (String?): Optional answer to security question
- secretQuestion (String?): Optional security question

### updateDeviceIdentifier

_Updates the device identifier and app version for the user_

**Required Information:**
- deviceIdentifier (String): Unique device identifier
- appVersion (String): Current app version

## authentication

### login

_Authenticates a user with username and password_

**Required Information:**
- username (String): User's login username
- password (String): User's login password

### logout

_Logs out the current user and invalidates their session_

**Required Information:**

### getPasswordPolicy

_Retrieves the password policy requirements_

**Required Information:**

## payments

### getTransactionsHistory

_Retrieves transaction history for a specified date range_

**Required Information:**
- pageNumber (Int?): Optional page number for pagination
- transactionTypes ([TransactionType]?): Optional array of transaction types to filter
- startDate (String): Start date for transaction history
- endDate (String): End date for transaction history

### getPayments

_Retrieves available payment methods for deposits_

**Required Information:**

### cancelDeposit

_Cancels a pending deposit transaction_

**Required Information:**
- paymentId (String): ID of the deposit payment to cancel

### processDeposit

_Processes a deposit request_

**Required Information:**
- amount (Double): Deposit amount
- option (String): Payment option details
- paymentMethod (String): Selected payment method

### prepareWithdrawal

_Prepares a withdrawal request for processing_

**Required Information:**
- paymentMethod (String): Selected withdrawal method

### getPaymentInformation

_Retrieves saved payment information for the user_

**Required Information:**

### updatePayment

_Updates payment information for an existing payment_

**Required Information:**
- returnUrl (String?): URL to return to after payment processing
- amount (Double): Payment amount
- encryptedExpiryYear (String?): Encrypted card expiry year
- paymentId (String): ID of the payment to update
- type (String): Payment type
- encryptedCardNumber (String?): Encrypted card number
- nameOnCard (String?): Name as it appears on the card
- encryptedSecurityCode (String?): Encrypted card security code
- encryptedExpiryMonth (String?): Encrypted card expiry month

### getPendingWithdrawals

_Retrieves list of pending withdrawal transactions_

**Required Information:**

### addPaymentInformation

_Adds new payment information for the user_

**Required Information:**
- type (String): Type of payment information
- fields (String): Payment information fields in string format

### processWithdrawal

_Processes a withdrawal request_

**Required Information:**
- amount (Double): Withdrawal amount
- paymentMethod (String): Selected withdrawal method
- conversionId (String?): Optional conversion ID for currency conversion

### getWithdrawalMethods

_Retrieves available withdrawal methods_

**Required Information:**

### checkPaymentStatus

_Checks the status of a payment transaction_

**Required Information:**
- paymentId (String): ID of the payment to check
- paymentMethod (String): Payment method used for the transaction

### cancelWithdrawal

_Cancels a pending withdrawal transaction_

**Required Information:**
- paymentId (Int): ID of the withdrawal payment to cancel

## registration

### simpleSignUp

_Registers a new user with basic information_

**Required Information:**
- form (SimpleSignUpForm): No description available

### signupConfirmation

_Confirms user signup with verification code_

**Required Information:**
- email (String): Email address used for registration
- confirmationCode (String): Verification code received by user

### signUpCompletion

_Completes the signup process with additional user information_

**Required Information:**
- Form containing additional user information

### signUp

_Registers a new user with complete information_

**Required Information:**
- form (SignUpForm): No description available

### validateUsername

_Validates a username and provides suggestions if unavailable_

**Required Information:**
- username (String): Username to validate

### checkEmailRegistered

_Checks if an email is already registered in the system_

**Required Information:**
- email (String): Email address to check

## location

### getCurrentCountry

_Retrieves the current country information_

**Required Information:**

### getAllCountries

_Retrieves all available countries_

**Required Information:**

### getCountries

_Retrieves list of available countries_

**Required Information:**

## consent_management

### setUserConsents

_Updates user consent statuses for specified consent versions_

**Required Information:**
- consentVersionIds ([Int]?): Array of consent version IDs to consent to
- unconsenVersionIds ([Int]?): Array of consent version IDs to revoke consent from

### getUserConsents

_Retrieves the user's current consent statuses_

**Required Information:**

### getAllConsents

_Retrieves all available consent types and their information_

**Required Information:**

## betting

### calculatePotentialReturn

_Calculates potential return for a bet ticket before placing the bet_

**Required Information:**
- betTicket (BetTicket): The bet ticket to calculate potential returns for

### getBetHistory

_Retrieves betting history with pagination_

**Required Information:**
- pageIndex (Int): Page number for pagination

### getAllowedBetTypes

_Retrieves allowed bet types for given selections_

**Required Information:**
- betTicketSelections ([BetTicketSelection]): Array of bet ticket selections to check allowed types for

### calculateCashout

_Calculates the cashout value for a specific bet_

**Required Information:**
- stakeValue (String?): Optional stake value for partial cashout
- betId (String): ID of the bet to calculate cashout for

### getBetslipSettings

_Retrieves the current betslip settings for the user_

**Required Information:**

### calculateBetBuilderPotentialReturn

_Calculates potential return for a bet builder ticket_

**Required Information:**
- betTicket (BetTicket): The bet builder ticket to calculate potential returns for

### getSharedTicket

_Retrieves a shared bet ticket by its ID_

**Required Information:**
- betslipId (String): ID of the shared bet ticket to retrieve

### getTicketSelection

_Retrieves a specific ticket selection by its ID_

**Required Information:**
- ticketSelectionId (String): ID of the ticket selection to retrieve

### getOpenBetsHistory

_Retrieves history of open bets with optional date filtering_

**Required Information:**
- endDate (String?): Optional end date for filtering bets
- startDate (String?): Optional start date for filtering bets
- pageIndex (Int): Page number for pagination

### allowedCashoutBetIds

_Retrieves IDs of bets that are eligible for cashout_

**Required Information:**

### getResolvedBetsHistory

_Retrieves history of resolved bets with optional date filtering_

**Required Information:**
- endDate (String?): Optional end date for filtering bets
- pageIndex (Int): Page number for pagination
- startDate (String?): Optional start date for filtering bets

### confirmBoostedBet

_Confirms a boosted bet offer_

**Required Information:**
- identifier (String): Unique identifier of the boosted bet to confirm

### getFreebet

_Retrieves information about available freebets for the user_

**Required Information:**

### rejectBoostedBet

_Rejects a boosted bet offer_

**Required Information:**
- identifier (String): Unique identifier of the boosted bet to reject

### placeBetBuilderBet

_Places a bet builder bet with calculated odds_

**Required Information:**
- calculatedOdd (Double): Pre-calculated odds for the bet builder
- betTicket (BetTicket): The bet builder ticket to place

### updateBetslipSettings

_Updates the user's betslip settings_

**Required Information:**
- betslipSettings (BetslipSettings): New betslip settings to apply

### placeBets

_Places one or more bets using the provided bet tickets_

**Required Information:**
- useFreebetBalance (Bool): Whether to use freebet balance for placing bets
- betTickets ([BetTicket]): Array of bet tickets to place

### getBetDetails

_Retrieves detailed information about a specific bet_

**Required Information:**
- identifier (String): Unique identifier of the bet to retrieve

### calculateCashback

_Calculates potential cashback for a bet ticket_

**Required Information:**
- betTicket (BetTicket): The bet ticket to calculate cashback for

### cashoutBet

_Performs a cashout operation on a specific bet_

**Required Information:**
- stakeValue (Double?): Optional stake value for partial cashout
- betId (String): ID of the bet to cash out
- cashoutValue (Double): Value to cash out

### getWonBetsHistory

_Retrieves history of won bets with optional date filtering_

**Required Information:**
- startDate (String?): Optional start date for filtering bets
- endDate (String?): Optional end date for filtering bets
- pageIndex (Int): Page number for pagination

## documents

### getDocumentTypes

_Retrieves available document types for verification_

**Required Information:**

### getUserDocuments

_Retrieves user's uploaded documents_

**Required Information:**

### uploadMultipleUserDocuments

_Uploads multiple user verification documents_

**Required Information:**
- documentType (String): Type of documents being uploaded
- files ([String: Data]): Dictionary of filename to file data pairs

### uploadUserDocument

_Uploads a single user verification document_

**Required Information:**
- file (Data): Document file data
- documentType (String): Type of document being uploaded
- fileName (String): Name of the file being uploaded

## wallet

### getUserCashbackBalance

_Retrieves the user's cashback balance information_

**Required Information:**

### getUserBalance

_Retrieves the user's wallet balance information_

**Required Information:**

## bonuses

### cancelBonus

_Cancels an active bonus_

**Required Information:**
- bonusId (String): ID of the bonus to cancel

### redeemAvailableBonus

_Claims an available bonus for a specific user_

**Required Information:**
- code (String): The bonus code to redeem
- partyId (String): User's party identifier

### getAvailableBonuses

_Retrieves the list of bonuses available for the user to claim_

**Required Information:**

### getGrantedBonuses

_Retrieves the list of bonuses that have been granted to the user_

**Required Information:**

### redeemBonus

_Redeems a bonus using a bonus code_

**Required Information:**
- code (String): The bonus code to redeem

### optOutBonus

_Opts out from a specific bonus_

**Required Information:**
- partyId (String): User's party identifier
- code (String): The bonus code to opt out from

## events

### getAvailableSportTypes

_Retrieves a list of available sport types within an optional date range_

**Required Information:**
- endDate (Date?): Optional end date to filter sports availability
- initialDate (Date?): Optional start date to filter sports availability

### getHomeSliders

_Retrieves the home page slider banners_

**Required Information:**

### getEventSummaryByMarket

_Retrieves a summary of an event using a market ID associated with the event_

**Required Information:**
- forMarketId (String): Market ID associated with the event to retrieve

### getTopCompetitions

_Retrieves the list of top competitions_

**Required Information:**

### getEventDetails

_Retrieves detailed information about a specific event_

**Required Information:**
- eventId (String): Unique identifier of the event

### getMarketInfo

_Retrieves detailed information about a specific market_

**Required Information:**
- marketId (String): Unique identifier of the market to retrieve

### getPromotionalTopStories

_Retrieves promotional top stories_

**Required Information:**

### getCashbackSuccessBanner

_Retrieves the cashback success banner_

**Required Information:**

### getHighlightedLiveEventsIds

_Retrieves IDs of highlighted live events, optionally filtered by user_

**Required Information:**
- userId (String?): Optional user ID for personalized highlights
- eventCount (Int): Maximum number of event IDs to retrieve

### getPromotionalTopBanners

_Retrieves promotional banners for the top section_

**Required Information:**

### getEventForMarketGroup

_Retrieves an event associated with a specific market group_

**Required Information:**
- withId (String): Unique identifier of the market group

### getPromotionalSlidingTopEvents

_Retrieves promotional sliding events for the top section_

**Required Information:**

### getTopCompetitionsPointers

_Retrieves pointers to top competitions_

**Required Information:**

### getEventsForEventGroup

_Retrieves events associated with a specific event group_

**Required Information:**
- withId (String): Unique identifier of the event group

### getCompetitionMarketGroups

_Retrieves information about market groups available for a specific competition_

**Required Information:**
- competitionId (String): Unique identifier of the competition to get market groups for

### getPromotedSports

_Retrieves the list of promoted sports_

**Required Information:**

### getEventLiveData

_Retrieves live data and statistics for a specific event_

**Required Information:**
- eventId (String): Unique identifier of the event

### getHighlightedMarkets

_Retrieves highlighted markets_

**Required Information:**

### getEventSummary

_Retrieves a summary of a specific event using its event ID_

**Required Information:**
- eventId (String): Unique identifier of the event to retrieve

### getHighlightedBoostedEvents

_Retrieves events with boosted odds that are highlighted_

**Required Information:**

### getHeroGameEvent

_Retrieves the hero game event_

**Required Information:**

### getHighlightedLiveEvents

_Retrieves detailed information about highlighted live events, optionally filtered by user_

**Required Information:**
- eventCount (Int): Maximum number of events to retrieve
- userId (String?): Optional user ID for personalized highlights

### getSportRegions

_Retrieves information about regions available for a specific sport_

**Required Information:**
- sportId (String): Unique identifier of the sport to get regions for

### getSearchEvents

_Searches for events based on a query string with pagination support_

**Required Information:**
- page (String): Page number for paginated results
- resultLimit (String): Maximum number of results to return per page
- query (String): Search query string to find events
- isLive (Bool): Filter for live events only

### getEventSecundaryMarkets

_Retrieves secondary markets information for a specific event_

**Required Information:**
- eventId (String): Unique identifier of the event

### getHighlightedVisualImageEvents

_Retrieves events with visual images that are highlighted_

**Required Information:**

### getRegionCompetitions

_Retrieves information about competitions available in a specific region_

**Required Information:**
- regionId (String): Unique identifier of the region to get competitions for

## profile

### getUserProfile

_Retrieves the user's profile information_

**Required Information:**
- kycExpire (String?): Optional KYC expiration date

## responsible_gaming

### getLimits

_Retrieves all user limits information_

**Required Information:**

### updateResponsibleGamingLimits

_Updates the user's responsible gaming limits_

**Required Information:**
- newLimit (Double): New limit amount
- limitType (String): Type of limit (deposit, betting, or autoPayout)
- hasRollingWeeklyLimits (Bool): Whether to use rolling weekly limits instead of calendar weekly limits

### updateWeeklyBettingLimits

_Updates the user's weekly betting limits_

**Required Information:**
- newLimit (Double): New weekly betting limit amount

### getPersonalDepositLimits

_Retrieves the user's personal deposit limits_

**Required Information:**

### getResponsibleGamingLimits

_Retrieves responsible gaming limits for specified period and limit types_

**Required Information:**
- periodTypes (String?): Comma-separated list of period types (e.g., 'RollingWeekly,Permanent')
- limitTypes (String?): Comma-separated list of limit types (e.g., 'DEPOSIT_LIMIT,WAGER_LIMIT,BALANCE_LIMIT')

### updateWeeklyDepositLimits

_Updates the user's weekly deposit limits_

**Required Information:**
- newLimit (Double): New weekly deposit limit amount

## referral

### getReferralLink

_Retrieves the user's referral link_

**Required Information:**

### getReferees

_Retrieves the list of users referred by the current user_

**Required Information:**


# Real-time Services

_These services provide real-time updates through WebSocket connections._

### subscribeLiveSportTypes

_Subscribes to updates for currently live sport types and their active events_

**Update Information:**
- Frequency: real-time

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

### subscribeOutrightMarkets

_Subscribes to outright market updates for a specific market group (e.g., tournament winner, top scorer)_

**Update Information:**
- Frequency: on-change

### subscribeEventMarkets

_Subscribes to all markets associated with a specific event, including odds updates and market status changes_

**Update Information:**
- Frequency: real-time

### subscribePreLiveSportTypes

_Subscribes to updates for available pre-live sport types within a specified date range_

**Update Information:**
- Frequency: on-change

### subscribeToLiveDataUpdates

_Subscribes to real-time live data updates for a specific event, including detailed statistics and play-by-play information_

**Update Information:**
- Frequency: real-time

### subscribeToMarketDetails

_Subscribes to real-time updates for a specific market within an event_

**Update Information:**
- Frequency: real-time

### subscribeAllSportTypes

_Subscribes to updates for all available sport types, including both live and pre-live sports_

**Update Information:**
- Frequency: on-change

### subscribeLiveMatches

_Subscribes to live matches updates for a specific sport type through WebSocket connection_

**Update Information:**
- Frequency: real-time

### subscribePreLiveMatches

_Subscribes to pre-live (upcoming) matches for a specific sport type with optional date range and sorting parameters_

**Update Information:**
- Frequency: on-change

### subscribeCompetitionMatches

_Subscribes to matches updates for a specific competition identified by its market group ID_

**Update Information:**
- Frequency: real-time


# Data Models

_This section describes the data structures used in the API._

### AccessTokenResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| token | String? | The token of the model |
| userId | String? | The userId of the model |
| description | String? | The description of the model |
| code | Int? | The code of the model |

### AddPaymentInformationResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | The status of the model |
| message | String? | The message of the model |

### ApplicantDataInfo

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| applicantDocs | [ApplicantDoc]? | The applicantDocs of the model |

**Related Models:**
- [ApplicantDoc](#applicantdoc) (via `applicantDocs`)

### ApplicantDataResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| externalUserId | String? | The externalUserId of the model |
| info | ApplicantDataInfo? | The info of the model |
| reviewData | ApplicantReviewData? | The reviewData of the model |
| description | String? | The description of the model |

**Related Models:**
- [ApplicantDataInfo](#applicantdatainfo) (via `info`)
- [ApplicantReviewData](#applicantreviewdata) (via `reviewData`)

### ApplicantDoc

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| docType | String | The docType of the model |

### ApplicantReviewData

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| attemptCount | Int | The attemptCount of the model |
| createDate | String | The createDate of the model |
| reviewDate | String? | The reviewDate of the model |
| reviewResult | ApplicantReviewResult? | The reviewResult of the model |
| reviewStatus | String | The reviewStatus of the model |
| levelName | String | The levelName of the model |

**Related Models:**
- [ApplicantReviewResult](#applicantreviewresult) (via `reviewResult`)

### ApplicantReviewResult

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| reviewAnswer | String | The reviewAnswer of the model |
| reviewRejectType | String? | The reviewRejectType of the model |
| moderationComment | String? | The moderationComment of the model |

### BankPaymentDetail

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | Int | The id of the model |
| paymentInfoId | Int | The paymentInfoId of the model |
| key | String | The key of the model |
| value | String | The value of the model |

### BankPaymentInfo

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | Int | The id of the model |
| partyId | Int | The partyId of the model |
| type | String | The type of the model |
| description | String? | The description of the model |
| priority | Int? | The priority of the model |
| details | [#bankpaymentdetail|BankPaymentDetail] | The details of the model |

**Related Models:**
- [BankPaymentDetail](#bankpaymentdetail) (via `details`)

### Banner

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| name | String | The name of the model |
| title | String | The title of the model |
| imageUrl | String | The imageUrl of the model |
| bodyText | String? | The bodyText of the model |
| type | String | The type of the model |
| linkUrl | String? | The linkUrl of the model |
| marketId | String? | The marketId of the model |

### BannerResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| bannerItems | [#banner|Banner] | The bannerItems of the model |

**Related Models:**
- [Banner](#banner) (via `bannerItems`)

### BasicResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | The status of the model |
| message | String? | The message of the model |

### Bet

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| identifier | String | The identifier of the model |
| eventName | String | The eventName of the model |
| homeTeamName | String? | The homeTeamName of the model |
| awayTeamName | String? | The awayTeamName of the model |
| sportTypeName | String | The sportTypeName of the model |
| type | String | The type of the model |
| state | BetState | The state of the model |
| result | BetResult | The result of the model |
| globalState | BetState | The globalState of the model |
| marketName | String | The marketName of the model |
| outcomeName | String | The outcomeName of the model |
| eventResult | String? | The eventResult of the model |
| potentialReturn | Double? | The potentialReturn of the model |
| totalReturn | Double? | The totalReturn of the model |
| totalOdd | Double | The totalOdd of the model |
| totalStake | Double | The totalStake of the model |
| attemptedDate | Date | The attemptedDate of the model |
| oddNumerator | Double | The oddNumerator of the model |
| oddDenominator | Double | The oddDenominator of the model |
| order | Int | The order of the model |
| eventId | Double | The eventId of the model |
| eventDate | Date? | The eventDate of the model |
| tournamentCountryName | String? | The tournamentCountryName of the model |
| tournamentName | String? | The tournamentName of the model |
| freeBet | Bool | The freeBet of the model |
| partialCashoutReturn | Double? | The partialCashoutReturn of the model |
| partialCashoutStake | Double? | The partialCashoutStake of the model |
| betslipId | Int? | The betslipId of the model |
| cashbackReturn | Double? | The cashbackReturn of the model |
| freebetReturn | Double? | The freebetReturn of the model |
| potentialCashbackReturn | Double? | The potentialCashbackReturn of the model |
| potentialFreebetReturn | Double? | The potentialFreebetReturn of the model |
| dateFormatter | DateFormatter | The dateFormatter of the model |
| fallbackDateFormatter | DateFormatter | The fallbackDateFormatter of the model |

**Related Models:**

### BetBuilderPotentialReturn

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| potentialReturn | Double | The potentialReturn of the model |
| calculatedOdds | Double | The calculatedOdds of the model |

### BetSlip

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| tickets | [#betticket|BetTicket] | The tickets of the model |

**Related Models:**
- [BetTicket](#betticket) (via `tickets`)

### BetTicket

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| selections | [#betticketselection|BetTicketSelection] | The selections of the model |
| betTypeCode | String | The betTypeCode of the model |
| winStake | String | The winStake of the model |
| potentialReturn | Double? | The potentialReturn of the model |
| pool | Bool | The pool of the model |

**Related Models:**
- [BetTicketSelection](#betticketselection) (via `selections`)

### BetTicketSelection

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| identifier | String | The identifier of the model |
| eachWayReduction | String | The eachWayReduction of the model |
| eachWayPlaceTerms | String | The eachWayPlaceTerms of the model |
| idFOPriceType | String | The idFOPriceType of the model |
| isTrap | String | The isTrap of the model |
| priceUp | String | The priceUp of the model |
| priceDown | String | The priceDown of the model |

### BetType

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| typeCode | String | The typeCode of the model |
| typeName | String | The typeName of the model |
| potencialReturn | Double | The potencialReturn of the model |
| totalStake | Double | The totalStake of the model |
| numberOfIndividualBets | Int | The numberOfIndividualBets of the model |

### BetslipSettings

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| oddChangeLegacy | BetslipOddChangeSetting? | The oddChangeLegacy of the model |
| oddChangeRunningOrPreMatch | BetslipOddChangeSetting? | The oddChangeRunningOrPreMatch of the model |

**Related Models:**

### BettingHistory

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| bets | [#bet|Bet] | The bets of the model |

**Related Models:**
- [Bet](#bet) (via `bets`)

### CancelWithdrawalResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | The status of the model |
| amount | String | The amount of the model |
| currency | String | The currency of the model |

### CashbackBalance

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | The status of the model |
| balance | String? | The balance of the model |
| message | String? | The message of the model |

### CashbackResult

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | Double | The id of the model |
| amount | Double? | The amount of the model |
| amountFree | Double? | The amountFree of the model |

### Cashout

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| cashoutValue | Double | The cashoutValue of the model |
| partialCashoutAvailable | Bool? | The partialCashoutAvailable of the model |

### CashoutResult

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| cashoutResult | Int? | The cashoutResult of the model |
| cashoutReoffer | Double? | The cashoutReoffer of the model |
| message | String? | The message of the model |

### CompetitionMarketGroup

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| name | String | The name of the model |
| events | [Event] | The events of the model |

**Related Models:**

### CompetitionParentNode

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| name | String | The name of the model |
| categoryName | String | The categoryName of the model |

### Consent

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | Int | The id of the model |
| key | String | The key of the model |
| name | String | The name of the model |
| consentVersionId | Int | The consentVersionId of the model |
| status | String? | The status of the model |
| isMandatory | Bool? | The isMandatory of the model |

### ConsentInfo

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | Int | The id of the model |
| key | String | The key of the model |
| name | String | The name of the model |
| consentVersionId | Int | The consentVersionId of the model |
| status | String? | The status of the model |
| isMandatory | Bool? | The isMandatory of the model |

### CountryInfo

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| name | String | The name of the model |
| iso2Code | String | The iso2Code of the model |
| phonePrefix | String | The phonePrefix of the model |

### DepositMethod

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| code | String | The code of the model |
| paymentMethod | String | The paymentMethod of the model |
| methods | [PaymentMethod]? | The methods of the model |

**Related Models:**
- [PaymentMethod](#paymentmethod) (via `methods`)

### DocumentType

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| documentType | String | The documentType of the model |
| issueDateRequired | Bool? | The issueDateRequired of the model |
| expiryDateRequired | Bool? | The expiryDateRequired of the model |
| documentNumberRequired | Bool? | The documentNumberRequired of the model |
| multipleFileRequired | Bool? | The multipleFileRequired of the model |

### DocumentTypesResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | The status of the model |
| documentTypes | [#documenttype|DocumentType] | The documentTypes of the model |

**Related Models:**
- [DocumentType](#documenttype) (via `documentTypes`)

### EventLiveDataExtended

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| homeScore | Int? | The homeScore of the model |
| awayScore | Int? | The awayScore of the model |
| matchTime | String? | The matchTime of the model |
| status | EventStatus? | The status of the model |
| scores | [String: Score] | The scores of the model |
| activePlayerServing | ActivePlayerServe? | The activePlayerServing of the model |

**Related Models:**

### EventsGroup

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| events | [Event] | The events of the model |
| marketGroupId | String? | The marketGroupId of the model |

**Related Models:**

### FavoriteAddResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| displayOrder | Int? | The displayOrder of the model |
| idAccountFavorite | Int? | The idAccountFavorite of the model |

### FavoriteEvent

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| name | String | The name of the model |
| favoriteListId | Int | The favoriteListId of the model |
| accountFavoriteId | Int | The accountFavoriteId of the model |

### FavoriteEventResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| favoriteEvents | [#favoriteevent|FavoriteEvent] | The favoriteEvents of the model |

**Related Models:**
- [FavoriteEvent](#favoriteevent) (via `favoriteEvents`)

### FavoriteList

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | Int | The id of the model |
| name | String | The name of the model |
| customerId | Int | The customerId of the model |

### FavoritesListAddResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| listId | Int | The listId of the model |

### FavoritesListDeleteResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| listId | String? | The listId of the model |

### FavoritesListResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| favoritesList | [#favoritelist|FavoriteList] | The favoritesList of the model |

**Related Models:**
- [FavoriteList](#favoritelist) (via `favoritesList`)

### FieldError

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| field | String | The field of the model |
| error | String | The error of the model |

### FreebetResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| balance | Double | The balance of the model |

### HeadlineItem

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| idfwheadline | String? | The idfwheadline of the model |
| marketGroupId | String? | The marketGroupId of the model |
| marketId | String? | The marketId of the model |
| name | String? | The name of the model |
| title | String? | The title of the model |
| tsactivefrom | String? | The tsactivefrom of the model |
| tsactiveto | String? | The tsactiveto of the model |
| idfwheadlinetype | String? | The idfwheadlinetype of the model |
| headlinemediatype | String? | The headlinemediatype of the model |
| categoryName | String? | The categoryName of the model |
| numofselections | String? | The numofselections of the model |
| imageURL | String? | The imageURL of the model |
| linkURL | String? | The linkURL of the model |
| oldMarketId | String? | The oldMarketId of the model |
| tournamentCountryName | String? | The tournamentCountryName of the model |

### HighlightMarket

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| market | [Market](#market) | The market of the model |
| enabledSelectionsCount | Int | The enabledSelectionsCount of the model |
| promotionImageURl | String? | The promotionImageURl of the model |

**Related Models:**
- [Market](#market) (via `market`)

### HighlightedEventPointer

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | The status of the model |
| sportId | String | The sportId of the model |
| eventId | String | The eventId of the model |
| eventType | String? | The eventType of the model |
| countryId | String | The countryId of the model |

### KYCStatusDetail

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| expiryDate | String? | The expiryDate of the model |

### LimitPending

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| effectiveDate | String | The effectiveDate of the model |
| limit | String | The limit of the model |
| limitNumber | Double | The limitNumber of the model |

### LimitsResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | The status of the model |
| wagerLimit | String? | The wagerLimit of the model |
| lossLimit | String? | The lossLimit of the model |
| currency | String | The currency of the model |
| pendingWagerLimit | LimitPending? | The pendingWagerLimit of the model |

**Related Models:**
- [LimitPending](#limitpending) (via `pendingWagerLimit`)

### Market

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| name | String | The name of the model |
| outcomes | [#outcome|Outcome] | The outcomes of the model |
| marketTypeId | String? | The marketTypeId of the model |
| eventMarketTypeId | String? | The eventMarketTypeId of the model |
| marketTypeCategoryId | String? | The marketTypeCategoryId of the model |
| eventName | String? | The eventName of the model |
| isMainOutright | Bool? | The isMainOutright of the model |
| eventMarketCount | Int? | The eventMarketCount of the model |
| isTradable | Bool | The isTradable of the model |
| startDate | Date? | The startDate of the model |
| homeParticipant | String? | The homeParticipant of the model |
| awayParticipant | String? | The awayParticipant of the model |
| eventId | String? | The eventId of the model |
| isOverUnder | Bool | The isOverUnder of the model |
| marketDigitLine | String? | The marketDigitLine of the model |
| outcomesOrder | OutcomesOrder | The outcomesOrder of the model |
| competitionId | String? | The competitionId of the model |
| competitionName | String? | The competitionName of the model |
| sportTypeName | String? | The sportTypeName of the model |
| sportTypeCode | String? | The sportTypeCode of the model |
| sportIdCode | String? | The sportIdCode of the model |
| tournamentCountryName | String? | The tournamentCountryName of the model |
| customBetAvailable | Bool? | The customBetAvailable of the model |
| isMainMarket | Bool | The isMainMarket of the model |

**Related Models:**
- [Outcome](#outcome) (via `outcomes`)

### MarketGroup

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| markets | [#market|Market] | The markets of the model |
| marketGroupId | String? | The marketGroupId of the model |

**Related Models:**
- [Market](#market) (via `markets`)

### MarketGroupPromotedSport

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| typeId | String? | The typeId of the model |
| name | String? | The name of the model |

### MobileVerifyResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | The status of the model |
| message | String? | The message of the model |
| requestId | Int? | The requestId of the model |

### Outcome

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| name | String | The name of the model |
| hashCode | String | The hashCode of the model |
| marketId | String? | The marketId of the model |
| orderValue | String? | The orderValue of the model |
| externalReference | String? | The externalReference of the model |
| odd | OddFormat | The odd of the model |
| priceNumerator | String? | The priceNumerator of the model |
| priceDenominator | String? | The priceDenominator of the model |
| isTradable | Bool? | The isTradable of the model |
| isTerminated | Bool? | The isTerminated of the model |
| isOverUnder | Bool | The isOverUnder of the model |
| customBetAvailableMarket | Bool? | The customBetAvailableMarket of the model |

**Related Models:**

### PasswordPolicy

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| regularExpression | String? | The regularExpression of the model |
| message | String | The message of the model |

### PaymentInformation

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | The status of the model |
| data | [#bankpaymentinfo|BankPaymentInfo] | The data of the model |

**Related Models:**
- [BankPaymentInfo](#bankpaymentinfo) (via `data`)

### PaymentMethod

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| name | String | The name of the model |
| type | String | The type of the model |
| brands | [String]? | The brands of the model |

### PaymentStatusResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | The status of the model |
| paymentId | String? | The paymentId of the model |
| paymentStatus | String? | The paymentStatus of the model |
| message | String? | The message of the model |

### PendingWithdrawal

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | The status of the model |
| paymentId | Int | The paymentId of the model |
| amount | String | The amount of the model |

### PersonalDepositLimitResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | The status of the model |
| dailyLimit | String? | The dailyLimit of the model |
| weeklyLimit | String? | The weeklyLimit of the model |
| monthlyLimit | String? | The monthlyLimit of the model |
| currency | String | The currency of the model |
| hasPendingWeeklyLimit | String? | The hasPendingWeeklyLimit of the model |
| pendingWeeklyLimit | String? | The pendingWeeklyLimit of the model |
| pendingWeeklyLimitEffectiveDate | String? | The pendingWeeklyLimitEffectiveDate of the model |

### PlacedBetEntry

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| identifier | String | The identifier of the model |
| potentialReturn | Double | The potentialReturn of the model |
| totalAvailableStake | Double | The totalAvailableStake of the model |
| betLegs | [#placedbetleg|PlacedBetLeg] | The betLegs of the model |
| type | String? | The type of the model |

**Related Models:**
- [PlacedBetLeg](#placedbetleg) (via `betLegs`)

### PlacedBetLeg

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| identifier | String | The identifier of the model |
| priceType | String | The priceType of the model |
| odd | Double | The odd of the model |
| priceNumerator | Int | The priceNumerator of the model |
| priceDenominator | Int | The priceDenominator of the model |

### PlacedBetsResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| identifier | String | The identifier of the model |
| responseCode | String | The responseCode of the model |
| detailedResponseCode | String? | The detailedResponseCode of the model |
| errorMessage | String? | The errorMessage of the model |
| totalStake | Double | The totalStake of the model |
| bets | [#placedbetentry|PlacedBetEntry] | The bets of the model |

**Related Models:**
- [PlacedBetEntry](#placedbetentry) (via `bets`)

### PrepareWithdrawalResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | The status of the model |
| conversionId | String? | The conversionId of the model |
| message | String? | The message of the model |

### ProcessDepositResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | The status of the model |
| paymentId | String? | The paymentId of the model |
| continueUrl | String? | The continueUrl of the model |
| clientKey | String? | The clientKey of the model |
| sessionId | String? | The sessionId of the model |
| sessionData | String? | The sessionData of the model |
| message | String? | The message of the model |

### ProcessWithdrawalResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | The status of the model |
| paymentId | String? | The paymentId of the model |
| message | String? | The message of the model |

### PromotedBetslip

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| selections | [#promotedbetslipselection|PromotedBetslipSelection] | The selections of the model |
| betslipCount | Int | The betslipCount of the model |

**Related Models:**
- [PromotedBetslipSelection](#promotedbetslipselection) (via `selections`)

### PromotedBetslipSelection

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String? | The id of the model |
| beginDate | String? | The beginDate of the model |
| betOfferId | Int? | The betOfferId of the model |
| country | String? | The country of the model |
| countryId | String? | The countryId of the model |
| eventId | String? | The eventId of the model |
| eventType | String? | The eventType of the model |
| league | String? | The league of the model |
| leagueId | String? | The leagueId of the model |
| market | String? | The market of the model |
| marketId | Int? | The marketId of the model |
| marketType | String? | The marketType of the model |
| marketTypeId | Int? | The marketTypeId of the model |
| orakoEventId | String | The orakoEventId of the model |
| orakoMarketId | String | The orakoMarketId of the model |
| orakoSelectionId | String | The orakoSelectionId of the model |
| outcomeType | String? | The outcomeType of the model |
| outcomeId | Int? | The outcomeId of the model |
| participantIds | [String]? | The participantIds of the model |
| participants | [String]? | The participants of the model |
| period | String? | The period of the model |
| periodId | Int? | The periodId of the model |
| quote | Double? | The quote of the model |
| quoteGroup | String? | The quoteGroup of the model |
| sport | String? | The sport of the model |
| sportId | String? | The sportId of the model |
| status | String? | The status of the model |

### PromotedBetslipsInternalRequest

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| body | [VaixBatchBody](#vaixbatchbody) | The body of the model |
| name | String | The name of the model |
| statusCode | Int | The statusCode of the model |

**Related Models:**
- [VaixBatchBody](#vaixbatchbody) (via `body`)

### PromotedSport

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| name | String | The name of the model |
| marketGroups | [#marketgrouppromotedsport|MarketGroupPromotedSport] | The marketGroups of the model |

**Related Models:**
- [MarketGroupPromotedSport](#marketgrouppromotedsport) (via `marketGroups`)

### PromotionalBanner

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| name | String? | The name of the model |
| bannerType | String? | The bannerType of the model |
| imageURL | String? | The imageURL of the model |
| bannerDisplay | String? | The bannerDisplay of the model |
| linkType | String? | The linkType of the model |
| location | String? | The location of the model |
| bannerContents | [String]? | The bannerContents of the model |

### PromotionalStory

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| title | String | The title of the model |
| imageUrl | String | The imageUrl of the model |
| linkUrl | String | The linkUrl of the model |
| bodyText | String | The bodyText of the model |

### RedeemBonus

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | Int | The id of the model |
| name | String | The name of the model |
| status | String | The status of the model |
| triggerDate | String | The triggerDate of the model |
| expiryDate | String | The expiryDate of the model |
| amount | String | The amount of the model |
| wagerRequired | String | The wagerRequired of the model |
| amountWagered | String | The amountWagered of the model |

### RedeemBonusResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | The status of the model |
| message | String? | The message of the model |
| bonus | RedeemBonus? | The bonus of the model |

**Related Models:**
- [RedeemBonus](#redeembonus) (via `bonus`)

### ReferralLink

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| code | String | The code of the model |
| link | String | The link of the model |

### ResponsibleGamingLimit

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | Int | The id of the model |
| partyId | Int | The partyId of the model |
| limitType | String | The limitType of the model |
| periodType | String | The periodType of the model |
| effectiveDate | String | The effectiveDate of the model |
| expiryDate | String | The expiryDate of the model |
| limit | Double | The limit of the model |

### ResponsibleGamingLimitsResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | The status of the model |
| limits | [#responsiblegaminglimit|ResponsibleGamingLimit] | The limits of the model |

**Related Models:**
- [ResponsibleGamingLimit](#responsiblegaminglimit) (via `limits`)

### ScheduledSport

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| name | String | The name of the model |

### SharedBetSelection

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | Double | The id of the model |
| priceDenominator | Int | The priceDenominator of the model |
| priceNumerator | Int | The priceNumerator of the model |
| priceType | String | The priceType of the model |

### SharedTicketResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| bets | [SharedBet] | The bets of the model |
| totalStake | Double | The totalStake of the model |
| betId | Double | The betId of the model |

**Related Models:**

### SignUpResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| successful | Bool | The successful of the model |
| errors | [SignUpError]? | The errors of the model |

**Related Models:**

### SimplePaymentMethod

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| name | String | The name of the model |
| type | String | The type of the model |
| brands | [String]? | The brands of the model |

### SimplePaymentMethodsResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| paymentMethods | [#simplepaymentmethod|SimplePaymentMethod] | The paymentMethods of the model |

**Related Models:**
- [SimplePaymentMethod](#simplepaymentmethod) (via `paymentMethods`)

### SportCompetition

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| name | String | The name of the model |
| numberEvents | String | The numberEvents of the model |
| numberOutrightEvents | String | The numberOutrightEvents of the model |

### SportCompetitionInfo

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| name | String | The name of the model |
| marketGroups | [#sportcompetitionmarketgroup|SportCompetitionMarketGroup] | The marketGroups of the model |
| numberOutrightEvents | String | The numberOutrightEvents of the model |
| numberOutrightMarkets | String | The numberOutrightMarkets of the model |
| parentId | String? | The parentId of the model |

**Related Models:**
- [SportCompetitionMarketGroup](#sportcompetitionmarketgroup) (via `marketGroups`)

### SportCompetitionMarketGroup

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| name | String | The name of the model |

### SportNode

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| name | String | The name of the model |
| numberEvents | Int | The numberEvents of the model |
| numberOutrightEvents | Int | The numberOutrightEvents of the model |
| numberOutrightMarkets | Int | The numberOutrightMarkets of the model |
| numberLiveEvents | Int | The numberLiveEvents of the model |
| alphaCode | String | The alphaCode of the model |

### SportNodeInfo

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| regionNodes | [#sportregion|SportRegion] | The regionNodes of the model |
| navigationTypes | [String]? | The navigationTypes of the model |
| name | String? | The name of the model |
| defaultOrder | Int? | The defaultOrder of the model |
| numMarkets | String? | The numMarkets of the model |
| numEvents | String? | The numEvents of the model |
| numOutrightMarkets | String? | The numOutrightMarkets of the model |
| numOutrightEvents | String? | The numOutrightEvents of the model |

**Related Models:**
- [SportRegion](#sportregion) (via `regionNodes`)

### SportRegion

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| name | String? | The name of the model |
| numberEvents | String | The numberEvents of the model |
| numberOutrightEvents | String | The numberOutrightEvents of the model |

### SportRegionInfo

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| name | String | The name of the model |
| competitionNodes | [#sportcompetition|SportCompetition] | The competitionNodes of the model |

**Related Models:**
- [SportCompetition](#sportcompetition) (via `competitionNodes`)

### SportType

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| name | String | The name of the model |
| numericId | String? | The numericId of the model |
| alphaId | String? | The alphaId of the model |
| numberEvents | Int | The numberEvents of the model |
| numberOutrightEvents | Int | The numberOutrightEvents of the model |
| numberOutrightMarkets | Int | The numberOutrightMarkets of the model |
| numberLiveEvents | Int | The numberLiveEvents of the model |

### SportTypeDetails

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| sportType | [SportType](#sporttype) | The sportType of the model |
| eventsCount | Int | The eventsCount of the model |
| sportName | String | The sportName of the model |

**Related Models:**
- [SportType](#sporttype) (via `sportType`)

### SportsList

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| sportNodes | [SportNode]? | The sportNodes of the model |

**Related Models:**
- [SportNode](#sportnode) (via `sportNodes`)

### SupportRequest

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | Int | The id of the model |
| status | String | The status of the model |

### SupportResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| request | SupportRequest? | The request of the model |
| error | String? | The error of the model |
| description | String? | The description of the model |

**Related Models:**
- [SupportRequest](#supportrequest) (via `request`)

### TicketSelection

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| marketId | String | The marketId of the model |
| name | String | The name of the model |
| priceDenominator | String | The priceDenominator of the model |
| priceNumerator | String | The priceNumerator of the model |
| odd | Double | The odd of the model |

### TopCompetitionData

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| title | String | The title of the model |
| competitions | [#topcompetitionpointer|TopCompetitionPointer] | The competitions of the model |

**Related Models:**
- [TopCompetitionPointer](#topcompetitionpointer) (via `competitions`)

### TopCompetitionPointer

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | String | The id of the model |
| name | String | The name of the model |
| competitionId | String | The competitionId of the model |

### TransactionDetail

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | Int | The id of the model |
| dateTime | String | The dateTime of the model |
| type | String | The type of the model |
| amount | Double | The amount of the model |
| postBalance | Double | The postBalance of the model |
| amountBonus | Double | The amountBonus of the model |
| postBalanceBonus | Double | The postBalanceBonus of the model |
| currency | String | The currency of the model |
| paymentId | Int? | The paymentId of the model |
| gameTranId | String? | The gameTranId of the model |
| reference | String? | The reference of the model |
| escrowTranType | String? | The escrowTranType of the model |
| escrowTranSubType | String? | The escrowTranSubType of the model |
| escrowType | String? | The escrowType of the model |

### UpdatePaymentAction

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| paymentMethodType | String | The paymentMethodType of the model |
| url | String | The url of the model |
| method | String | The method of the model |
| type | String | The type of the model |

### UpdatePaymentResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| resultCode | String | The resultCode of the model |
| action | UpdatePaymentAction? | The action of the model |

**Related Models:**
- [UpdatePaymentAction](#updatepaymentaction) (via `action`)

### UploadDocumentResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | The status of the model |
| message | String? | The message of the model |

### UserConsentInfo

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| id | Int | The id of the model |
| key | String | The key of the model |
| name | String | The name of the model |
| consentVersionId | Int | The consentVersionId of the model |
| isMandatory | Bool? | The isMandatory of the model |

### UserDocument

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| documentType | String | The documentType of the model |
| fileName | String? | The fileName of the model |
| status | String | The status of the model |
| uploadDate | String | The uploadDate of the model |
| userDocumentFiles | [UserDocumentFile]? | The userDocumentFiles of the model |

**Related Models:**
- [UserDocumentFile](#userdocumentfile) (via `userDocumentFiles`)

### UserDocumentFile

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| fileName | String | The fileName of the model |

### UserDocumentsResponse

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| status | String | The status of the model |
| userDocuments | [#userdocument|UserDocument] | The userDocuments of the model |

**Related Models:**
- [UserDocument](#userdocument) (via `userDocuments`)

### UserProfile

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| userIdentifier | String | The userIdentifier of the model |
| sessionKey | String | The sessionKey of the model |
| username | String | The username of the model |
| email | String | The email of the model |
| firstName | String? | The firstName of the model |
| middleName | String? | The middleName of the model |
| lastName | String? | The lastName of the model |
| birthDate | Date | The birthDate of the model |
| gender | String? | The gender of the model |
| nationalityCode | String? | The nationalityCode of the model |
| countryCode | String? | The countryCode of the model |
| personalIdNumber | String? | The personalIdNumber of the model |
| address | String? | The address of the model |
| province | String? | The province of the model |
| city | String? | The city of the model |
| postalCode | String? | The postalCode of the model |
| birthDepartment | String? | The birthDepartment of the model |
| streetNumber | String? | The streetNumber of the model |
| phoneNumber | String? | The phoneNumber of the model |
| mobilePhone | String? | The mobilePhone of the model |
| mobileCountryCode | String? | The mobileCountryCode of the model |
| mobileLocalNumber | String? | The mobileLocalNumber of the model |
| avatarName | String? | The avatarName of the model |
| godfatherCode | String? | The godfatherCode of the model |
| placeOfBirth | String? | The placeOfBirth of the model |
| additionalStreetLine | String? | The additionalStreetLine of the model |
| emailVerificationStatus | EmailVerificationStatus | The emailVerificationStatus of the model |
| userRegistrationStatus | UserRegistrationStatus | The userRegistrationStatus of the model |
| kycStatus | KnowYourCustomerStatus | The kycStatus of the model |
| lockedStatus | LockedStatus | The lockedStatus of the model |
| hasMadeDeposit | Bool | The hasMadeDeposit of the model |
| kycExpiryDate | String? | The kycExpiryDate of the model |
| currency | String? | The currency of the model |

**Related Models:**

### UserWallet

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| vipStatus | String? | The vipStatus of the model |
| currency | String? | The currency of the model |
| loyaltyPoint | Int? | The loyaltyPoint of the model |
| totalString | String? | The totalString of the model |
| total | Double? | The total of the model |
| withdrawableString | String? | The withdrawableString of the model |
| withdrawable | Double? | The withdrawable of the model |
| bonusString | String? | The bonusString of the model |
| bonus | Double? | The bonus of the model |
| pendingBonusString | String? | The pendingBonusString of the model |
| pendingBonus | Double? | The pendingBonus of the model |
| casinoPlayableBonusString | String? | The casinoPlayableBonusString of the model |
| casinoPlayableBonus | Double? | The casinoPlayableBonus of the model |
| sportsbookPlayableBonusString | String? | The sportsbookPlayableBonusString of the model |
| sportsbookPlayableBonus | Double? | The sportsbookPlayableBonus of the model |
| withdrawableEscrowString | String? | The withdrawableEscrowString of the model |
| withdrawableEscrow | Double? | The withdrawableEscrow of the model |
| totalWithdrawableString | String? | The totalWithdrawableString of the model |
| totalWithdrawable | Double? | The totalWithdrawable of the model |
| withdrawRestrictionAmountString | String? | The withdrawRestrictionAmountString of the model |
| withdrawRestrictionAmount | Double? | The withdrawRestrictionAmount of the model |
| totalEscrowString | String? | The totalEscrowString of the model |
| totalEscrow | Double? | The totalEscrow of the model |

### UsernameValidation

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| username | String | The username of the model |
| isAvailable | Bool | The isAvailable of the model |
| suggestedUsernames | [String]? | The suggestedUsernames of the model |
| hasErrors | Bool | The hasErrors of the model |

### VaixBatchBody

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| data | [VaixBatchData](#vaixbatchdata) | The data of the model |
| status | String | The status of the model |

**Related Models:**
- [VaixBatchData](#vaixbatchdata) (via `data`)

### VaixBatchData

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| promotedBetslips | [#promotedbetslip|PromotedBetslip] | The promotedBetslips of the model |
| count | Int | The count of the model |

**Related Models:**
- [PromotedBetslip](#promotedbetslip) (via `promotedBetslips`)

### WithdrawalMethod

**Properties:**

| Name | Type | Description |
|------|------|-------------|
| code | String | The code of the model |
| paymentMethod | String | The paymentMethod of the model |
| minimumWithdrawal | String | The minimumWithdrawal of the model |
| maximumWithdrawal | String | The maximumWithdrawal of the model |
| conversionRequired | Bool | The conversionRequired of the model |

