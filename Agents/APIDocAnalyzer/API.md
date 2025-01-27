# API Documentation

This documentation provides a comprehensive overview of our API services, including available endpoints and data models.

## Table of Contents
1. [REST Services](#rest-services)
2. [Real-time Services](#real-time-services)
3. [Data Models](#data-models)

# REST Services

## referral

### getReferralLink

_Retrieves the user's referral link_

**Required Information:**

### getReferees

_Retrieves the list of users referred by the current user_

**Required Information:**

## events

### getSearchEvents

_Searches for events based on a query string with pagination support_

**Required Information:**
- query (String): Search query string to find events
- page (String): Page number for paginated results
- resultLimit (String): Maximum number of results to return per page
- isLive (Bool): Filter for live events only

### getHeroGameEvent

_Retrieves the hero game event_

**Required Information:**

### getMarketInfo

_Retrieves detailed information about a specific market_

**Required Information:**
- marketId (String): Unique identifier of the market to retrieve

### getAvailableSportTypes

_Retrieves a list of available sport types within an optional date range_

**Required Information:**
- endDate (Date?): Optional end date to filter sports availability
- initialDate (Date?): Optional start date to filter sports availability

### getHighlightedLiveEventsIds

_Retrieves IDs of highlighted live events, optionally filtered by user_

**Required Information:**
- eventCount (Int): Maximum number of event IDs to retrieve
- userId (String?): Optional user ID for personalized highlights

### getHighlightedMarkets

_Retrieves highlighted markets_

**Required Information:**

### getEventsForEventGroup

_Retrieves events associated with a specific event group_

**Required Information:**
- withId (String): Unique identifier of the event group

### getCompetitionMarketGroups

_Retrieves information about market groups available for a specific competition_

**Required Information:**
- competitionId (String): Unique identifier of the competition to get market groups for

### getTopCompetitionsPointers

_Retrieves pointers to top competitions_

**Required Information:**

### getEventLiveData

_Retrieves live data and statistics for a specific event_

**Required Information:**
- eventId (String): Unique identifier of the event

### getEventForMarketGroup

_Retrieves an event associated with a specific market group_

**Required Information:**
- withId (String): Unique identifier of the market group

### getEventSummary

_Retrieves a summary of a specific event using its event ID_

**Required Information:**
- eventId (String): Unique identifier of the event to retrieve

### getCashbackSuccessBanner

_Retrieves the cashback success banner_

**Required Information:**

### getPromotionalTopStories

_Retrieves promotional top stories_

**Required Information:**

### getEventSecundaryMarkets

_Retrieves secondary markets information for a specific event_

**Required Information:**
- eventId (String): Unique identifier of the event

### getEventDetails

_Retrieves detailed information about a specific event_

**Required Information:**
- eventId (String): Unique identifier of the event

### getEventSummaryByMarket

_Retrieves a summary of an event using a market ID associated with the event_

**Required Information:**
- forMarketId (String): Market ID associated with the event to retrieve

### getRegionCompetitions

_Retrieves information about competitions available in a specific region_

**Required Information:**
- regionId (String): Unique identifier of the region to get competitions for

### getHomeSliders

_Retrieves the home page slider banners_

**Required Information:**

### getTopCompetitions

_Retrieves the list of top competitions_

**Required Information:**

### getHighlightedBoostedEvents

_Retrieves events with boosted odds that are highlighted_

**Required Information:**

### getPromotionalSlidingTopEvents

_Retrieves promotional sliding events for the top section_

**Required Information:**

### getPromotionalTopBanners

_Retrieves promotional banners for the top section_

**Required Information:**

### getPromotedSports

_Retrieves the list of promoted sports_

**Required Information:**

### getHighlightedVisualImageEvents

_Retrieves events with visual images that are highlighted_

**Required Information:**

### getSportRegions

_Retrieves information about regions available for a specific sport_

**Required Information:**
- sportId (String): Unique identifier of the sport to get regions for

### getHighlightedLiveEvents

_Retrieves detailed information about highlighted live events, optionally filtered by user_

**Required Information:**
- userId (String?): Optional user ID for personalized highlights
- eventCount (Int): Maximum number of events to retrieve

## registration

### simpleSignUp

_Registers a new user with basic information_

**Required Information:**
- form (SimpleSignUpForm): No description available

### checkEmailRegistered

_Checks if an email is already registered in the system_

**Required Information:**
- email (String): Email address to check

### validateUsername

_Validates a username and provides suggestions if unavailable_

**Required Information:**
- username (String): Username to validate

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

## wallet

### getUserBalance

_Retrieves the user's wallet balance information_

**Required Information:**

### getUserCashbackBalance

_Retrieves the user's cashback balance information_

**Required Information:**

## bonuses

### redeemBonus

_Redeems a bonus using a bonus code_

**Required Information:**
- code (String): The bonus code to redeem

### optOutBonus

_Opts out from a specific bonus_

**Required Information:**
- partyId (String): User's party identifier
- code (String): The bonus code to opt out from

### getGrantedBonuses

_Retrieves the list of bonuses that have been granted to the user_

**Required Information:**

### getAvailableBonuses

_Retrieves the list of bonuses available for the user to claim_

**Required Information:**

### cancelBonus

_Cancels an active bonus_

**Required Information:**
- bonusId (String): ID of the bonus to cancel

### redeemAvailableBonus

_Claims an available bonus for a specific user_

**Required Information:**
- partyId (String): User's party identifier
- code (String): The bonus code to redeem

## documents

### uploadMultipleUserDocuments

_Uploads multiple user verification documents_

**Required Information:**
- documentType (String): Type of documents being uploaded
- files ([String: Data]): Dictionary of filename to file data pairs

### getUserDocuments

_Retrieves user's uploaded documents_

**Required Information:**

### getDocumentTypes

_Retrieves available document types for verification_

**Required Information:**

### uploadUserDocument

_Uploads a single user verification document_

**Required Information:**
- fileName (String): Name of the file being uploaded
- documentType (String): Type of document being uploaded
- file (Data): Document file data

## responsible_gaming

### updateResponsibleGamingLimits

_Updates the user's responsible gaming limits_

**Required Information:**
- hasRollingWeeklyLimits (Bool): Whether to use rolling weekly limits instead of calendar weekly limits
- newLimit (Double): New limit amount
- limitType (String): Type of limit (deposit, betting, or autoPayout)

### getPersonalDepositLimits

_Retrieves the user's personal deposit limits_

**Required Information:**

### updateWeeklyBettingLimits

_Updates the user's weekly betting limits_

**Required Information:**
- newLimit (Double): New weekly betting limit amount

### updateWeeklyDepositLimits

_Updates the user's weekly deposit limits_

**Required Information:**
- newLimit (Double): New weekly deposit limit amount

### getLimits

_Retrieves all user limits information_

**Required Information:**

### getResponsibleGamingLimits

_Retrieves responsible gaming limits for specified period and limit types_

**Required Information:**
- periodTypes (String?): Comma-separated list of period types (e.g., 'RollingWeekly,Permanent')
- limitTypes (String?): Comma-separated list of limit types (e.g., 'DEPOSIT_LIMIT,WAGER_LIMIT,BALANCE_LIMIT')

## authentication

### logout

_Logs out the current user and invalidates their session_

**Required Information:**

### login

_Authenticates a user with username and password_

**Required Information:**
- username (String): User's login username
- password (String): User's login password

### getPasswordPolicy

_Retrieves the password policy requirements_

**Required Information:**

## profile

### getUserProfile

_Retrieves the user's profile information_

**Required Information:**
- kycExpire (String?): Optional KYC expiration date

## support

### contactUs

_Sends a contact request to customer support_

**Required Information:**
- firstName (String): User's first name
- subject (String): Subject of the contact request
- message (String): Message content
- lastName (String): User's last name
- email (String): User's email address

### contactSupport

_Sends a detailed support request with user information_

**Required Information:**
- message (String): Detailed message content
- subject (String): Subject of the support request
- email (String): User's email address
- isLogged (Bool): Whether the user is currently logged in
- userIdentifier (String): User's unique identifier
- subjectType (String): Category or type of the support request
- firstName (String): User's first name
- lastName (String): User's last name

## payments

### cancelWithdrawal

_Cancels a pending withdrawal transaction_

**Required Information:**
- paymentId (Int): ID of the withdrawal payment to cancel

### checkPaymentStatus

_Checks the status of a payment transaction_

**Required Information:**
- paymentId (String): ID of the payment to check
- paymentMethod (String): Payment method used for the transaction

### getPendingWithdrawals

_Retrieves list of pending withdrawal transactions_

**Required Information:**

### getPayments

_Retrieves available payment methods for deposits_

**Required Information:**

### processDeposit

_Processes a deposit request_

**Required Information:**
- amount (Double): Deposit amount
- option (String): Payment option details
- paymentMethod (String): Selected payment method

### addPaymentInformation

_Adds new payment information for the user_

**Required Information:**
- type (String): Type of payment information
- fields (String): Payment information fields in string format

### processWithdrawal

_Processes a withdrawal request_

**Required Information:**
- conversionId (String?): Optional conversion ID for currency conversion
- paymentMethod (String): Selected withdrawal method
- amount (Double): Withdrawal amount

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

### cancelDeposit

_Cancels a pending deposit transaction_

**Required Information:**
- paymentId (String): ID of the deposit payment to cancel

### getTransactionsHistory

_Retrieves transaction history for a specified date range_

**Required Information:**
- pageNumber (Int?): Optional page number for pagination
- endDate (String): End date for transaction history
- startDate (String): Start date for transaction history
- transactionTypes ([TransactionType]?): Optional array of transaction types to filter

### updatePayment

_Updates payment information for an existing payment_

**Required Information:**
- type (String): Payment type
- paymentId (String): ID of the payment to update
- amount (Double): Payment amount
- encryptedExpiryYear (String?): Encrypted card expiry year
- nameOnCard (String?): Name as it appears on the card
- returnUrl (String?): URL to return to after payment processing
- encryptedExpiryMonth (String?): Encrypted card expiry month
- encryptedCardNumber (String?): Encrypted card number
- encryptedSecurityCode (String?): Encrypted card security code

## account_management

### updateExtraInfo

_Updates additional user information_

**Required Information:**
- placeOfBirth (String?): User's place of birth
- address2 (String?): Secondary address

### verifyMobileCode

_Verifies a mobile verification code_

**Required Information:**
- requestId (String): ID of the verification request
- code (String): Verification code received by user

### updatePassword

_Updates the user's password_

**Required Information:**
- newPassword (String): New password to set
- oldPassword (String): Current password for verification

### updateUserProfile

_Updates the user's profile information_

**Required Information:**
- form (UpdateUserProfileForm): No description available

### updateDeviceIdentifier

_Updates the device identifier and app version for the user_

**Required Information:**
- appVersion (String): Current app version
- deviceIdentifier (String): Unique device identifier

### lockPlayer

_Locks a player's account with specified duration_

**Required Information:**
- lockPeriodUnit (String?): Unit of time for the lock period
- lockPeriod (String?): Duration of the lock period
- isPermanent (Bool?): Whether the lock is permanent

### forgotPassword

_Initiates the password recovery process_

**Required Information:**
- secretQuestion (String?): Optional security question
- email (String): Email address for password recovery
- secretAnswer (String?): Optional answer to security question

### getMobileVerificationCode

_Requests a verification code for a mobile number_

**Required Information:**
- mobileNumber (String): Mobile number to verify

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

### getBetDetails

_Retrieves detailed information about a specific bet_

**Required Information:**
- identifier (String): Unique identifier of the bet to retrieve

### calculateCashout

_Calculates the cashout value for a specific bet_

**Required Information:**
- betId (String): ID of the bet to calculate cashout for
- stakeValue (String?): Optional stake value for partial cashout

### rejectBoostedBet

_Rejects a boosted bet offer_

**Required Information:**
- identifier (String): Unique identifier of the boosted bet to reject

### getResolvedBetsHistory

_Retrieves history of resolved bets with optional date filtering_

**Required Information:**
- pageIndex (Int): Page number for pagination
- startDate (String?): Optional start date for filtering bets
- endDate (String?): Optional end date for filtering bets

### placeBetBuilderBet

_Places a bet builder bet with calculated odds_

**Required Information:**
- calculatedOdd (Double): Pre-calculated odds for the bet builder
- betTicket (BetTicket): The bet builder ticket to place

### getTicketSelection

_Retrieves a specific ticket selection by its ID_

**Required Information:**
- ticketSelectionId (String): ID of the ticket selection to retrieve

### getBetHistory

_Retrieves betting history with pagination_

**Required Information:**
- pageIndex (Int): Page number for pagination

### allowedCashoutBetIds

_Retrieves IDs of bets that are eligible for cashout_

**Required Information:**

### getWonBetsHistory

_Retrieves history of won bets with optional date filtering_

**Required Information:**
- startDate (String?): Optional start date for filtering bets
- pageIndex (Int): Page number for pagination
- endDate (String?): Optional end date for filtering bets

### getOpenBetsHistory

_Retrieves history of open bets with optional date filtering_

**Required Information:**
- startDate (String?): Optional start date for filtering bets
- endDate (String?): Optional end date for filtering bets
- pageIndex (Int): Page number for pagination

### cashoutBet

_Performs a cashout operation on a specific bet_

**Required Information:**
- betId (String): ID of the bet to cash out
- stakeValue (Double?): Optional stake value for partial cashout
- cashoutValue (Double): Value to cash out

### placeBets

_Places one or more bets using the provided bet tickets_

**Required Information:**
- betTickets ([BetTicket]): Array of bet tickets to place
- useFreebetBalance (Bool): Whether to use freebet balance for placing bets

### confirmBoostedBet

_Confirms a boosted bet offer_

**Required Information:**
- identifier (String): Unique identifier of the boosted bet to confirm

### getAllowedBetTypes

_Retrieves allowed bet types for given selections_

**Required Information:**
- betTicketSelections ([BetTicketSelection]): Array of bet ticket selections to check allowed types for

### calculateBetBuilderPotentialReturn

_Calculates potential return for a bet builder ticket_

**Required Information:**
- betTicket (BetTicket): The bet builder ticket to calculate potential returns for

### updateBetslipSettings

_Updates the user's betslip settings_

**Required Information:**
- betslipSettings (BetslipSettings): New betslip settings to apply

### getSharedTicket

_Retrieves a shared bet ticket by its ID_

**Required Information:**
- betslipId (String): ID of the shared bet ticket to retrieve

### calculatePotentialReturn

_Calculates potential return for a bet ticket before placing the bet_

**Required Information:**
- betTicket (BetTicket): The bet ticket to calculate potential returns for

### getFreebet

_Retrieves information about available freebets for the user_

**Required Information:**

### calculateCashback

_Calculates potential cashback for a bet ticket_

**Required Information:**
- betTicket (BetTicket): The bet ticket to calculate cashback for

### getBetslipSettings

_Retrieves the current betslip settings for the user_

**Required Information:**

## favorites

### deleteFavoriteFromList

_Deletes a favorite event from a list_

**Required Information:**
- eventId (Int): ID of the event to delete from favorites

### deleteFavoritesList

_Deletes a favorites list with the specified ID_

**Required Information:**
- listId (Int): ID of the favorites list to delete

### getPromotedBetslips

_Retrieves promoted betslips, optionally filtered by user_

**Required Information:**
- userId (String?): Optional user ID for personalized betslips

### getFavoritesList

_Retrieves all favorite lists for the current user_

**Required Information:**

### addFavoritesList

_Creates a new favorites list with the specified name_

**Required Information:**
- name (String): Name of the new favorites list

### addFavoriteToList

_Adds an event to a specified favorites list_

**Required Information:**
- listId (Int): ID of the favorites list to add the event to
- eventId (String): ID of the event to add to favorites

### getFavoritesFromList

_Retrieves all favorite events from a specified list_

**Required Information:**
- listId (Int): ID of the favorites list to get events from

## location

### getAllCountries

_Retrieves all available countries_

**Required Information:**

### getCountries

_Retrieves list of available countries_

**Required Information:**

### getCurrentCountry

_Retrieves the current country information_

**Required Information:**

## identity_verification

### generateDocumentTypeToken

_Generates a token for uploading a specific type of document_

**Required Information:**
- docType (String): Type of document to generate token for

### getSumsubApplicantData

_Retrieves applicant verification data from Sumsub_

**Required Information:**
- userId (String): User's unique identifier

### checkDocumentationData

_Checks the status of user's submitted documentation_

**Required Information:**

### getSumsubAccessToken

_Retrieves an access token for Sumsub identity verification service_

**Required Information:**
- userId (String): User's unique identifier
- levelName (String): Verification level name


# Real-time Services

_These services provide real-time updates through WebSocket connections._

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

### subscribeToMarketDetails

_Subscribes to real-time updates for a specific market within an event_

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

### subscribeToLiveDataUpdates

_Subscribes to real-time live data updates for a specific event, including detailed statistics and play-by-play information_

**Update Information:**
- Frequency: real-time

### subscribeLiveSportTypes

_Subscribes to updates for currently live sport types and their active events_

**Update Information:**
- Frequency: real-time

### subscribeCompetitionMatches

_Subscribes to matches updates for a specific competition identified by its market group ID_

**Update Information:**
- Frequency: real-time

### subscribeOutrightMarkets

_Subscribes to outright market updates for a specific market group (e.g., tournament winner, top scorer)_

**Update Information:**
- Frequency: on-change

### subscribeEventMarkets

_Subscribes to all markets associated with a specific event, including odds updates and market status changes_

**Update Information:**
- Frequency: real-time

### subscribeAllSportTypes

_Subscribes to updates for all available sport types, including both live and pre-live sports_

**Update Information:**
- Frequency: on-change

### subscribePreLiveSportTypes

_Subscribes to updates for available pre-live sport types within a specified date range_

**Update Information:**
- Frequency: on-change


# Data Models

_This section describes the data structures used in the API._

### AccessTokenResponse

**Properties:**

| Name | Type |
|------|------|
| token | String? |
| userId | String? |
| description | String? |
| code | Int? |

### ActivePlayerServe

**Properties:**

| Name | Type |
|------|------|
| home | ActivePlayerServe |
| away | ActivePlayerServe |

**Related Models:**
- [ActivePlayerServe](#activeplayerserve)
- [ActivePlayerServe](#activeplayerserve)

### AddPaymentInformationResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| message | String? |

### ApplicantDataInfo

**Properties:**

| Name | Type |
|------|------|
| applicantDocs | [ApplicantDoc]? |

**Related Models:**
- [ApplicantDoc](#applicantdoc)

### ApplicantDataResponse

**Properties:**

| Name | Type |
|------|------|
| externalUserId | String? |
| info | ApplicantDataInfo? |
| reviewData | ApplicantReviewData? |
| description | String? |

**Related Models:**
- [ApplicantDataInfo](#applicantdatainfo)
- [ApplicantReviewData](#applicantreviewdata)

### ApplicantDoc

**Properties:**

| Name | Type |
|------|------|
| docType | String |

### ApplicantReviewData

**Properties:**

| Name | Type |
|------|------|
| attemptCount | Int |
| createDate | String |
| reviewDate | String? |
| reviewResult | ApplicantReviewResult? |
| reviewStatus | String |
| levelName | String |

**Related Models:**
- [ApplicantReviewResult](#applicantreviewresult)

### ApplicantReviewResult

**Properties:**

| Name | Type |
|------|------|
| reviewAnswer | String |
| reviewRejectType | String? |
| moderationComment | String? |

### ApplicantRootResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| message | String? |
| data | ApplicantDataResponse |

**Related Models:**
- [ApplicantDataResponse](#applicantdataresponse)

### AvailableBonus

**Properties:**

| Name | Type |
|------|------|
| id | String |
| bonusPlanId | Int |
| name | String |
| description | String? |
| type | String |
| amount | Double |
| triggerDate | String |
| expiryDate | String |
| wagerRequirement | Double? |
| imageUrl | String? |

### AvailableBonusResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| bonuses | [AvailableBonus] |

**Related Models:**
- [AvailableBonus](#availablebonus)

### BalanceResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| message | String? |
| currency | String? |
| loyaltyPoint | Int? |
| vipStatus | String? |
| totalBalance | String? |
| totalBalanceNumber | Double? |
| withdrawableBalance | String? |
| withdrawableBalanceNumber | Double? |
| bonusBalance | String? |
| bonusBalanceNumber | Double? |
| pendingBonusBalance | String? |
| pendingBonusBalanceNumber | Double? |
| casinoPlayableBonusBalance | String? |
| casinoPlayableBonusBalanceNumber | Double? |
| sportsbookPlayableBonusBalance | String? |
| sportsbookPlayableBonusBalanceNumber | Double? |
| withdrawableEscrowBalance | String? |
| withdrawableEscrowBalanceNumber | Double? |
| totalWithdrawableBalance | String? |
| totalWithdrawableBalanceNumber | Double? |
| withdrawRestrictionAmount | String? |
| withdrawRestrictionAmountNumber | Double? |
| totalEscrowBalance | String? |
| totalEscrowBalanceNumber | Double? |

### BankPaymentDetail

**Properties:**

| Name | Type |
|------|------|
| id | Int |
| paymentInfoId | Int |
| key | String |
| value | String |

### BankPaymentInfo

**Properties:**

| Name | Type |
|------|------|
| id | Int |
| partyId | Int |
| type | String |
| description | String? |
| priority | Int? |
| details | [BankPaymentDetail] |

**Related Models:**
- [BankPaymentDetail](#bankpaymentdetail)

### Banner

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |
| title | String |
| imageUrl | String |
| bodyText | String? |
| type | String |
| linkUrl | String? |
| marketId | String? |

### BannerResponse

**Properties:**

| Name | Type |
|------|------|
| bannerItems | [Banner] |

**Related Models:**
- [Banner](#banner)

### BannerSpecialAction

**Properties:**

| Name | Type |
|------|------|
| register | BannerSpecialAction |
| none | BannerSpecialAction |

**Related Models:**
- [BannerSpecialAction](#bannerspecialaction)
- [BannerSpecialAction](#bannerspecialaction)

### BasicResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| message | String? |

### Bet

**Properties:**

| Name | Type |
|------|------|
| identifier | String |
| eventName | String |
| homeTeamName | String? |
| awayTeamName | String? |
| sportTypeName | String |
| type | String |
| state | BetState |
| result | BetResult |
| globalState | BetState |
| marketName | String |
| outcomeName | String |
| eventResult | String? |
| potentialReturn | Double? |
| totalReturn | Double? |
| totalOdd | Double |
| totalStake | Double |
| attemptedDate | Date |
| oddNumerator | Double |
| oddDenominator | Double |
| order | Int |
| eventId | Double |
| eventDate | Date? |
| tournamentCountryName | String? |
| tournamentName | String? |
| freeBet | Bool |
| partialCashoutReturn | Double? |
| partialCashoutStake | Double? |
| betslipId | Int? |
| cashbackReturn | Double? |
| freebetReturn | Double? |
| potentialCashbackReturn | Double? |
| potentialFreebetReturn | Double? |
| dateFormatter | DateFormatter |
| fallbackDateFormatter | DateFormatter |

**Related Models:**
- [BetState](#betstate)
- [BetResult](#betresult)
- [BetState](#betstate)

### BetBuilderPotentialReturn

**Properties:**

| Name | Type |
|------|------|
| potentialReturn | Double |
| calculatedOdds | Double |

### BetResult

**Properties:**

| Name | Type |
|------|------|
| won | BetResult |
| lost | BetResult |
| drawn | BetResult |
| open | BetResult |
| void | BetResult |
| pending | BetResult |
| notSpecified | BetResult |

**Related Models:**
- [BetResult](#betresult)
- [BetResult](#betresult)
- [BetResult](#betresult)
- [BetResult](#betresult)
- [BetResult](#betresult)
- [BetResult](#betresult)
- [BetResult](#betresult)

### BetSlip

**Properties:**

| Name | Type |
|------|------|
| tickets | [BetTicket] |

**Related Models:**
- [BetTicket](#betticket)

### BetSlipStateResponse

**Properties:**

| Name | Type |
|------|------|
| tickets | [BetTicket] |

**Related Models:**
- [BetTicket](#betticket)

### BetState

**Properties:**

| Name | Type |
|------|------|
| attempted | BetState |
| opened | BetState |
| closed | BetState |
| settled | BetState |
| cancelled | BetState |
| allStates | BetState |
| won | BetState |
| lost | BetState |
| cashedOut | BetState |
| void | BetState |
| undefined | BetState |

**Related Models:**
- [BetState](#betstate)
- [BetState](#betstate)
- [BetState](#betstate)
- [BetState](#betstate)
- [BetState](#betstate)
- [BetState](#betstate)
- [BetState](#betstate)
- [BetState](#betstate)
- [BetState](#betstate)
- [BetState](#betstate)
- [BetState](#betstate)

### BetTicket

**Properties:**

| Name | Type |
|------|------|
| selections | [BetTicketSelection] |
| betTypeCode | String |
| winStake | String |
| potentialReturn | Double? |
| pool | Bool |

**Related Models:**
- [BetTicketSelection](#betticketselection)

### BetTicketSelection

**Properties:**

| Name | Type |
|------|------|
| identifier | String |
| eachWayReduction | String |
| eachWayPlaceTerms | String |
| idFOPriceType | String |
| isTrap | String |
| priceUp | String |
| priceDown | String |

### BetType

**Properties:**

| Name | Type |
|------|------|
| typeCode | String |
| typeName | String |
| potencialReturn | Double |
| totalStake | Double |
| numberOfIndividualBets | Int |

### BetslipPotentialReturnResponse

**Properties:**

| Name | Type |
|------|------|
| potentialReturn | Double |
| totalStake | Double |
| numberOfBets | Int |
| totalOdd | Double? |

### BetslipSettings

**Properties:**

| Name | Type |
|------|------|
| oddChangeLegacy | BetslipOddChangeSetting? |
| oddChangeRunningOrPreMatch | BetslipOddChangeSetting? |

**Related Models:**

### BettingHistory

**Properties:**

| Name | Type |
|------|------|
| bets | [Bet] |

**Related Models:**
- [Bet](#bet)

### CancelWithdrawalResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| amount | String |
| currency | String |

### CashbackBalance

**Properties:**

| Name | Type |
|------|------|
| status | String |
| balance | String? |
| message | String? |

### CashbackResult

**Properties:**

| Name | Type |
|------|------|
| id | Double |
| amount | Double? |
| amountFree | Double? |

### Cashout

**Properties:**

| Name | Type |
|------|------|
| cashoutValue | Double |
| partialCashoutAvailable | Bool? |

### CashoutResult

**Properties:**

| Name | Type |
|------|------|
| cashoutResult | Int? |
| cashoutReoffer | Double? |
| message | String? |

### CheckCredentialResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| exists | String |
| fieldExist | Bool |

### CheckUsernameResponse

**Properties:**

| Name | Type |
|------|------|
| errors | [CheckUsernameError]? |
| status | String |
| message | String? |
| additionalInfos | [CheckUsernameAdditionalInfo]? |

**Related Models:**

### CompetitionMarketGroup

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |
| events | [Event] |

**Related Models:**
- [Event](#event)

### CompetitionParentNode

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |
| categoryName | String |

### ConfirmBetPlaceResponse

**Properties:**

| Name | Type |
|------|------|
| state | Int |
| detailedState | Int |
| statusCode | String? |
| statusText | String? |

### Consent

**Properties:**

| Name | Type |
|------|------|
| id | Int |
| key | String |
| name | String |
| consentVersionId | Int |
| status | String? |
| isMandatory | Bool? |

### ConsentsResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| consents | [Consent] |

**Related Models:**
- [Consent](#consent)

### ContentContainer

**Properties:**

| Name | Type |
|------|------|
| liveEvents | ContentContainer |
| preLiveEvents | ContentContainer |
| liveSports | ContentContainer |
| preLiveSports | ContentContainer |
| allSports | ContentContainer |
| eventDetails | ContentContainer |
| eventDetailsLiveData | ContentContainer |
| eventGroup | ContentContainer |
| outrightEventGroup | ContentContainer |
| eventSummary | ContentContainer |
| marketDetails | ContentContainer |
| updateEventSecundaryMarkets | ContentContainer |
| updateEventMainMarket | ContentContainer |
| addEvent | ContentContainer |
| addMarket | ContentContainer |
| addSelection | ContentContainer |
| addSport | ContentContainer |
| removeEvent | ContentContainer |
| removeMarket | ContentContainer |
| removeSelection | ContentContainer |
| removeSport | ContentContainer |
| enableMarket | ContentContainer |
| updateEventLiveDataExtended | ContentContainer |
| updateAllSportsLiveCount | ContentContainer |
| updateAllSportsEventCount | ContentContainer |
| updateEventState | ContentContainer |
| updateEventTime | ContentContainer |
| updateEventScore | ContentContainer |
| updateActivePlayer | ContentContainer |
| updateEventDetailedScore | ContentContainer |
| updateMarketTradability | ContentContainer |
| updateEventMarketCount | ContentContainer |
| updateOutcomeOdd | ContentContainer |
| updateOutcomeTradability | ContentContainer |
| unknown | ContentContainer |
| contentIdentifier | ContentIdentifier? |

**Related Models:**
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)
- [ContentContainer](#contentcontainer)

### CountryInfo

**Properties:**

| Name | Type |
|------|------|
| name | String |
| iso2Code | String |
| phonePrefix | String |

### DepositMethod

**Properties:**

| Name | Type |
|------|------|
| code | String |
| paymentMethod | String |
| methods | [PaymentMethod]? |

**Related Models:**
- [PaymentMethod](#paymentmethod)

### DocumentType

**Properties:**

| Name | Type |
|------|------|
| documentType | String |
| issueDateRequired | Bool? |
| expiryDateRequired | Bool? |
| documentNumberRequired | Bool? |
| multipleFileRequired | Bool? |

### DocumentTypesResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| documentTypes | [DocumentType] |

**Related Models:**
- [DocumentType](#documenttype)

### Event

**Properties:**

| Name | Type |
|------|------|
| id | String |
| homeName | String? |
| awayName | String? |
| sportTypeName | String? |
| sportTypeCode | String? |
| sportIdCode | String? |
| competitionId | String? |
| competitionName | String? |
| startDate | Date? |
| markets | [Market] |
| tournamentCountryName | String? |
| numberMarkets | Int? |
| name | String? |
| homeScore | Int |
| awayScore | Int |
| matchTime | String? |
| status | EventStatus |
| scores | [String: Score] |
| activePlayerServing | ActivePlayerServe? |
| trackableReference | String? |
| dateFormatter | DateFormatter |
| fallbackDateFormatter | DateFormatter |

**Related Models:**
- [Market](#market)
- [EventStatus](#eventstatus)
- [Score](#score)
- [ActivePlayerServe](#activeplayerserve)

### EventLiveDataExtended

**Properties:**

| Name | Type |
|------|------|
| id | String |
| homeScore | Int? |
| awayScore | Int? |
| matchTime | String? |
| status | EventStatus? |
| scores | [String: Score] |
| activePlayerServing | ActivePlayerServe? |

**Related Models:**
- [EventStatus](#eventstatus)
- [Score](#score)
- [ActivePlayerServe](#activeplayerserve)

### EventStatus

**Properties:**

| Name | Type |
|------|------|
| unknown | EventStatus |
| notStarted | EventStatus |
| inProgress | EventStatus |
| ended | EventStatus |
| stringValue | String |

**Related Models:**
- [EventStatus](#eventstatus)
- [EventStatus](#eventstatus)
- [EventStatus](#eventstatus)
- [EventStatus](#eventstatus)

### EventsGroup

**Properties:**

| Name | Type |
|------|------|
| events | [Event] |
| marketGroupId | String? |

**Related Models:**
- [Event](#event)

### FavoriteAddResponse

**Properties:**

| Name | Type |
|------|------|
| displayOrder | Int? |
| idAccountFavorite | Int? |

### FavoriteEvent

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |
| favoriteListId | Int |
| accountFavoriteId | Int |

### FavoriteEventResponse

**Properties:**

| Name | Type |
|------|------|
| favoriteEvents | [FavoriteEvent] |

**Related Models:**
- [FavoriteEvent](#favoriteevent)

### FavoriteList

**Properties:**

| Name | Type |
|------|------|
| id | Int |
| name | String |
| customerId | Int |

### FavoritesListAddResponse

**Properties:**

| Name | Type |
|------|------|
| listId | Int |

### FavoritesListDeleteResponse

**Properties:**

| Name | Type |
|------|------|
| listId | String? |

### FavoritesListResponse

**Properties:**

| Name | Type |
|------|------|
| favoritesList | [FavoriteList] |

**Related Models:**
- [FavoriteList](#favoritelist)

### FieldError

**Properties:**

| Name | Type |
|------|------|
| field | String |
| error | String |

### FreebetResponse

**Properties:**

| Name | Type |
|------|------|
| balance | Double |

### GetCountriesResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| countries | [String] |

### GetCountryInfoResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| countryInfo | CountryInfo |

**Related Models:**
- [CountryInfo](#countryinfo)

### GrantedBonus

**Properties:**

| Name | Type |
|------|------|
| id | Int |
| name | String |
| status | String |
| amount | String |
| triggerDate | String |
| expiryDate | String |
| wagerRequirement | String? |
| amountWagered | String? |

### GrantedBonusResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| bonuses | [GrantedBonus] |

**Related Models:**
- [GrantedBonus](#grantedbonus)

### HeadlineItem

**Properties:**

| Name | Type |
|------|------|
| idfwheadline | String? |
| marketGroupId | String? |
| marketId | String? |
| name | String? |
| title | String? |
| tsactivefrom | String? |
| tsactiveto | String? |
| idfwheadlinetype | String? |
| headlinemediatype | String? |
| categoryName | String? |
| numofselections | String? |
| imageURL | String? |
| linkURL | String? |
| oldMarketId | String? |
| tournamentCountryName | String? |

### HeadlineResponse

**Properties:**

| Name | Type |
|------|------|
| headlineItems | [HeadlineItem]? |

**Related Models:**
- [HeadlineItem](#headlineitem)

### HighlightedEventPointer

**Properties:**

| Name | Type |
|------|------|
| status | String |
| sportId | String |
| eventId | String |
| eventType | String? |
| countryId | String |

### KYCStatusDetail

**Properties:**

| Name | Type |
|------|------|
| expiryDate | String? |

### LimitPending

**Properties:**

| Name | Type |
|------|------|
| effectiveDate | String |
| limit | String |
| limitNumber | Double |

### LimitsResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| wagerLimit | String? |
| lossLimit | String? |
| currency | String |
| pendingWagerLimit | LimitPending? |

**Related Models:**
- [LimitPending](#limitpending)

### LoginResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| partyId | String? |
| username | String? |
| language | String? |
| currency | String? |
| email | String? |
| sessionKey | String? |
| parentId | String? |
| level | String? |
| userType | String? |
| isFirstLogin | String? |
| registrationStatus | String? |
| pendingLimitConfirmation | String? |
| country | String? |
| kycStatus | String? |
| lockStatus | String? |
| securityVerificationRequiredFields | [String]? |
| message | String? |
| lockUntilDateFormatted | String? |
| kycStatusDetails | KYCStatusDetail? |

**Related Models:**
- [KYCStatusDetail](#kycstatusdetail)

### Market

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |
| outcomes | [Outcome] |
| marketTypeId | String? |
| eventMarketTypeId | String? |
| marketTypeCategoryId | String? |
| eventName | String? |
| isMainOutright | Bool? |
| eventMarketCount | Int? |
| isTradable | Bool |
| startDate | Date? |
| homeParticipant | String? |
| awayParticipant | String? |
| eventId | String? |
| isOverUnder | Bool |
| marketDigitLine | String? |
| outcomesOrder | OutcomesOrder |
| competitionId | String? |
| competitionName | String? |
| sportTypeName | String? |
| sportTypeCode | String? |
| sportIdCode | String? |
| tournamentCountryName | String? |
| customBetAvailable | Bool? |
| isMainMarket | Bool |

**Related Models:**
- [Outcome](#outcome)

### MarketGroup

**Properties:**

| Name | Type |
|------|------|
| markets | [Market] |
| marketGroupId | String? |

**Related Models:**
- [Market](#market)

### MarketGroupPromotedSport

**Properties:**

| Name | Type |
|------|------|
| id | String |
| typeId | String? |
| name | String? |

### MobileVerifyResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| message | String? |
| requestId | Int? |

### NotificationType

**Properties:**

| Name | Type |
|------|------|
| listeningStarted | NotificationType |
| contentChanges | NotificationType |
| subscriberIdNotFoundError | NotificationType |
| genericError | NotificationType |
| unknown | NotificationType |

**Related Models:**
- [NotificationType](#notificationtype)
- [NotificationType](#notificationtype)
- [NotificationType](#notificationtype)
- [NotificationType](#notificationtype)
- [NotificationType](#notificationtype)

### OpenSessionResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| launchToken | String |

### Outcome

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |
| hashCode | String |
| marketId | String? |
| orderValue | String? |
| externalReference | String? |
| odd | OddFormat |
| priceNumerator | String? |
| priceDenominator | String? |
| isTradable | Bool? |
| isTerminated | Bool? |
| isOverUnder | Bool |
| customBetAvailableMarket | Bool? |

**Related Models:**

### PaymentInformation

**Properties:**

| Name | Type |
|------|------|
| status | String |
| data | [BankPaymentInfo] |

**Related Models:**
- [BankPaymentInfo](#bankpaymentinfo)

### PaymentMethod

**Properties:**

| Name | Type |
|------|------|
| name | String |
| type | String |
| brands | [String]? |

### PaymentStatusResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| paymentId | String? |
| paymentStatus | String? |
| message | String? |

### PaymentsResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| depositMethods | [DepositMethod] |

**Related Models:**
- [DepositMethod](#depositmethod)

### PendingWithdrawal

**Properties:**

| Name | Type |
|------|------|
| status | String |
| paymentId | Int |
| amount | String |

### PendingWithdrawalResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| pendingWithdrawals | [PendingWithdrawal] |

**Related Models:**
- [PendingWithdrawal](#pendingwithdrawal)

### PersonalDepositLimitResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| dailyLimit | String? |
| weeklyLimit | String? |
| monthlyLimit | String? |
| currency | String |
| hasPendingWeeklyLimit | String? |
| pendingWeeklyLimit | String? |
| pendingWeeklyLimitEffectiveDate | String? |

### PlacedBetEntry

**Properties:**

| Name | Type |
|------|------|
| identifier | String |
| potentialReturn | Double |
| totalAvailableStake | Double |
| betLegs | [PlacedBetLeg] |
| type | String? |

**Related Models:**
- [PlacedBetLeg](#placedbetleg)

### PlacedBetLeg

**Properties:**

| Name | Type |
|------|------|
| identifier | String |
| priceType | String |
| odd | Double |
| priceNumerator | Int |
| priceDenominator | Int |

### PlacedBetsResponse

**Properties:**

| Name | Type |
|------|------|
| identifier | String |
| responseCode | String |
| detailedResponseCode | String? |
| errorMessage | String? |
| totalStake | Double |
| bets | [PlacedBetEntry] |

**Related Models:**
- [PlacedBetEntry](#placedbetentry)

### PlayerInfoResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| partyId | String |
| userId | String |
| email | String |
| firstName | String? |
| lastName | String? |
| middleName | String? |
| nickname | String? |
| language | String? |
| phone | String? |
| phoneCountryCode | String? |
| phoneLocalNumber | String? |
| phoneNeedsReview | Bool? |
| birthDate | String? |
| birthDateFormatted | Date |
| regDate | String? |
| regDateFormatted | Date? |
| mobilePhone | String? |
| mobileCountryCode | String? |
| mobileLocalNumber | String? |
| mobileNeedsReview | Bool? |
| currency | String? |
| lastLogin | String? |
| lastLoginFormatted | Date? |
| level | Int? |
| parentID | String? |
| userType | Int? |
| isAutopay | Bool? |
| registrationStatus | String? |
| sessionKey | String? |
| vipStatus | String? |
| kycStatus | String? |
| emailVerificationStatus | String |
| verificationStatus | String? |
| lockedStatus | String? |
| gender | String? |
| contactPreference | String? |
| verificationMethod | String? |
| docNumber | String? |
| readonlyFields | String? |
| accountNumber | String? |
| idCardNumber | String? |
| madeDeposit | Bool? |
| testPlayer | Bool? |
| address | String? |
| city | String? |
| province | String? |
| postalCode | String? |
| country | String? |
| nationality | String? |
| municipality | String? |
| streetNumber | String? |
| building | String? |
| unit | String? |
| floorNumber | String? |
| birthDepartment | String? |
| birthCity | String? |
| birthCoutryCode | String? |
| extraInfos | [ExtraInfo]? |

**Related Models:**

### PrepareWithdrawalResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| conversionId | String? |
| message | String? |

### ProcessDepositResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| paymentId | String? |
| continueUrl | String? |
| clientKey | String? |
| sessionId | String? |
| sessionData | String? |
| message | String? |

### ProcessWithdrawalResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| paymentId | String? |
| message | String? |

### PromotedBetslip

**Properties:**

| Name | Type |
|------|------|
| selections | [PromotedBetslipSelection] |
| betslipCount | Int |

**Related Models:**
- [PromotedBetslipSelection](#promotedbetslipselection)

### PromotedBetslipSelection

**Properties:**

| Name | Type |
|------|------|
| id | String? |
| beginDate | String? |
| betOfferId | Int? |
| country | String? |
| countryId | String? |
| eventId | String? |
| eventType | String? |
| league | String? |
| leagueId | String? |
| market | String? |
| marketId | Int? |
| marketType | String? |
| marketTypeId | Int? |
| orakoEventId | String |
| orakoMarketId | String |
| orakoSelectionId | String |
| outcomeType | String? |
| outcomeId | Int? |
| participantIds | [String]? |
| participants | [String]? |
| period | String? |
| periodId | Int? |
| quote | Double? |
| quoteGroup | String? |
| sport | String? |
| sportId | String? |
| status | String? |

### PromotedBetslipsBatchResponse

**Properties:**

| Name | Type |
|------|------|
| promotedBetslips | [PromotedBetslip] |
| status | String |

**Related Models:**
- [PromotedBetslip](#promotedbetslip)

### PromotedBetslipsInternalRequest

**Properties:**

| Name | Type |
|------|------|
| body | VaixBatchBody |
| name | String |
| statusCode | Int |

**Related Models:**
- [VaixBatchBody](#vaixbatchbody)

### PromotedSport

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |
| marketGroups | [MarketGroupPromotedSport] |

**Related Models:**
- [MarketGroupPromotedSport](#marketgrouppromotedsport)

### PromotedSportsNodeResponse

**Properties:**

| Name | Type |
|------|------|
| promotedSports | [PromotedSport] |

**Related Models:**
- [PromotedSport](#promotedsport)

### PromotedSportsResponse

**Properties:**

| Name | Type |
|------|------|
| promotedSports | [PromotedSport] |

**Related Models:**
- [PromotedSport](#promotedsport)

### PromotionalBanner

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String? |
| bannerType | String? |
| imageURL | String? |
| bannerDisplay | String? |
| linkType | String? |
| location | String? |
| bannerContents | [String]? |

### PromotionalBannersResponse

**Properties:**

| Name | Type |
|------|------|
| promotionalBannerItems | [PromotionalBanner] |

**Related Models:**
- [PromotionalBanner](#promotionalbanner)

### PromotionalStoriesResponse

**Properties:**

| Name | Type |
|------|------|
| promotionalStories | [PromotionalStory] |

**Related Models:**
- [PromotionalStory](#promotionalstory)

### PromotionalStory

**Properties:**

| Name | Type |
|------|------|
| id | String |
| title | String |
| imageUrl | String |
| linkUrl | String |
| bodyText | String |

### RedeemBonus

**Properties:**

| Name | Type |
|------|------|
| id | Int |
| name | String |
| status | String |
| triggerDate | String |
| expiryDate | String |
| amount | String |
| wagerRequired | String |
| amountWagered | String |

### RedeemBonusResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| message | String? |
| bonus | RedeemBonus? |

**Related Models:**
- [RedeemBonus](#redeembonus)

### Referee

**Properties:**

| Name | Type |
|------|------|
| id | Int |
| username | String |
| registeredAt | String |
| kycStatus | String |
| depositPassed | Bool |

### RefereesResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| referees | [Referee] |

**Related Models:**
- [Referee](#referee)

### ReferralLink

**Properties:**

| Name | Type |
|------|------|
| code | String |
| link | String |

### ReferralResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| referralLinks | [ReferralLink] |

**Related Models:**
- [ReferralLink](#referrallink)

### ResponsibleGamingLimit

**Properties:**

| Name | Type |
|------|------|
| id | Int |
| partyId | Int |
| limitType | String |
| periodType | String |
| effectiveDate | String |
| expiryDate | String |
| limit | Double |

### ResponsibleGamingLimitsResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| limits | [ResponsibleGamingLimit] |

**Related Models:**
- [ResponsibleGamingLimit](#responsiblegaminglimit)

### ScheduledSport

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |

### Score

**Properties:**

| Name | Type |
|------|------|
| set | Score |
| gamePart | Score |
| matchFull | Score |
| sortValue | Int |
| key | String |

**Related Models:**
- [Score](#score)
- [Score](#score)
- [Score](#score)

### ScoreCodingKeys

**Properties:**

| Name | Type |
|------|------|
| gameScore | ScoreCodingKeys |
| currentScore | ScoreCodingKeys |
| matchScore | ScoreCodingKeys |
| periodScore | ScoreCodingKeys |
| setScore | ScoreCodingKeys |
| frameScore | ScoreCodingKeys |
| stringValue | String |
| intValue | Int? |

**Related Models:**
- [ScoreCodingKeys](#scorecodingkeys)
- [ScoreCodingKeys](#scorecodingkeys)
- [ScoreCodingKeys](#scorecodingkeys)
- [ScoreCodingKeys](#scorecodingkeys)
- [ScoreCodingKeys](#scorecodingkeys)
- [ScoreCodingKeys](#scorecodingkeys)

### SharedBet

**Properties:**

| Name | Type |
|------|------|
| betSelections | [SharedBetSelection] |
| winStake | Double |
| potentialReturn | Double |
| totalStake | Double |

**Related Models:**
- [SharedBetSelection](#sharedbetselection)

### SharedBetSelection

**Properties:**

| Name | Type |
|------|------|
| id | Double |
| priceDenominator | Int |
| priceNumerator | Int |
| priceType | String |

### SharedTicketResponse

**Properties:**

| Name | Type |
|------|------|
| bets | [SharedBet] |
| totalStake | Double |
| betId | Double |

**Related Models:**
- [SharedBet](#sharedbet)

### SportCompetition

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |
| numberEvents | String |
| numberOutrightEvents | String |

### SportCompetitionInfo

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |
| marketGroups | [SportCompetitionMarketGroup] |
| numberOutrightEvents | String |
| numberOutrightMarkets | String |
| parentId | String? |

**Related Models:**
- [SportCompetitionMarketGroup](#sportcompetitionmarketgroup)

### SportCompetitionMarketGroup

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |

### SportNode

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |
| numberEvents | Int |
| numberOutrightEvents | Int |
| numberOutrightMarkets | Int |
| numberLiveEvents | Int |
| alphaCode | String |

### SportNodeInfo

**Properties:**

| Name | Type |
|------|------|
| id | String |
| regionNodes | [SportRegion] |
| navigationTypes | [String]? |
| name | String? |
| defaultOrder | Int? |
| numMarkets | String? |
| numEvents | String? |
| numOutrightMarkets | String? |
| numOutrightEvents | String? |

**Related Models:**
- [SportRegion](#sportregion)

### SportRadarError

**Properties:**

| Name | Type |
|------|------|
| unkownSportId | SportRadarError |
| unkownContentId | SportRadarError |
| ignoredContentInitialData | SportRadarError |
| ignoredContentUpdate | SportRadarError |

**Related Models:**
- [SportRadarError](#sportradarerror)
- [SportRadarError](#sportradarerror)
- [SportRadarError](#sportradarerror)
- [SportRadarError](#sportradarerror)

### SportRegion

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String? |
| numberEvents | String |
| numberOutrightEvents | String |

### SportRegionInfo

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |
| competitionNodes | [SportCompetition] |

**Related Models:**
- [SportCompetition](#sportcompetition)

### SportType

**Properties:**

| Name | Type |
|------|------|
| name | String |
| numericId | String? |
| alphaId | String? |
| numberEvents | Int |
| numberOutrightEvents | Int |
| numberOutrightMarkets | Int |
| numberLiveEvents | Int |

### SportTypeDetails

**Properties:**

| Name | Type |
|------|------|
| sportType | SportType |
| eventsCount | Int |
| sportName | String |

**Related Models:**
- [SportType](#sporttype)

### SportsList

**Properties:**

| Name | Type |
|------|------|
| sportNodes | [SportNode]? |

**Related Models:**
- [SportNode](#sportnode)

### StatusResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| errors | [FieldError]? |
| message | String? |

**Related Models:**
- [FieldError](#fielderror)

### SupportRequest

**Properties:**

| Name | Type |
|------|------|
| id | Int |
| status | String |

### SupportResponse

**Properties:**

| Name | Type |
|------|------|
| request | SupportRequest? |
| error | String? |
| description | String? |

**Related Models:**
- [SupportRequest](#supportrequest)

### TicketSelection

**Properties:**

| Name | Type |
|------|------|
| id | String |
| marketId | String |
| name | String |
| priceDenominator | String |
| priceNumerator | String |
| odd | Double |

### TicketSelectionResponse

**Properties:**

| Name | Type |
|------|------|
| data | TicketSelection? |
| errorType | String? |

**Related Models:**
- [TicketSelection](#ticketselection)

### TopCompetitionData

**Properties:**

| Name | Type |
|------|------|
| title | String |
| competitions | [TopCompetitionPointer] |

**Related Models:**
- [TopCompetitionPointer](#topcompetitionpointer)

### TopCompetitionPointer

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |
| competitionId | String |

### TopCompetitionsResponse

**Properties:**

| Name | Type |
|------|------|
| data | [TopCompetitionData] |

**Related Models:**
- [TopCompetitionData](#topcompetitiondata)

### TransactionDetail

**Properties:**

| Name | Type |
|------|------|
| id | Int |
| dateTime | String |
| type | String |
| amount | Double |
| postBalance | Double |
| amountBonus | Double |
| postBalanceBonus | Double |
| currency | String |
| paymentId | Int? |
| gameTranId | String? |
| reference | String? |
| escrowTranType | String? |
| escrowTranSubType | String? |
| escrowType | String? |

### TransactionsHistoryResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| transactions | [TransactionDetail]? |

**Related Models:**
- [TransactionDetail](#transactiondetail)

### UpdatePaymentAction

**Properties:**

| Name | Type |
|------|------|
| paymentMethodType | String |
| url | String |
| method | String |
| type | String |

### UpdatePaymentResponse

**Properties:**

| Name | Type |
|------|------|
| resultCode | String |
| action | UpdatePaymentAction? |

**Related Models:**
- [UpdatePaymentAction](#updatepaymentaction)

### UploadDocumentResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| message | String? |

### UserConsent

**Properties:**

| Name | Type |
|------|------|
| consentInfo | UserConsentInfo |
| consentStatus | String |

**Related Models:**
- [UserConsentInfo](#userconsentinfo)

### UserConsentInfo

**Properties:**

| Name | Type |
|------|------|
| id | Int |
| key | String |
| name | String |
| consentVersionId | Int |
| isMandatory | Bool? |

### UserConsentsResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| message | String? |
| userConsents | [UserConsent] |

**Related Models:**
- [UserConsent](#userconsent)

### UserDocument

**Properties:**

| Name | Type |
|------|------|
| documentType | String |
| fileName | String? |
| status | String |
| uploadDate | String |
| userDocumentFiles | [UserDocumentFile]? |

**Related Models:**
- [UserDocumentFile](#userdocumentfile)

### UserDocumentFile

**Properties:**

| Name | Type |
|------|------|
| fileName | String |

### UserDocumentsResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| userDocuments | [UserDocument] |

**Related Models:**
- [UserDocument](#userdocument)

### VaixBatchBody

**Properties:**

| Name | Type |
|------|------|
| data | VaixBatchData |
| status | String |

**Related Models:**
- [VaixBatchData](#vaixbatchdata)

### VaixBatchData

**Properties:**

| Name | Type |
|------|------|
| promotedBetslips | [PromotedBetslip] |
| count | Int |

**Related Models:**
- [PromotedBetslip](#promotedbetslip)

### WithdrawalMethod

**Properties:**

| Name | Type |
|------|------|
| code | String |
| paymentMethod | String |
| minimumWithdrawal | String |
| maximumWithdrawal | String |
| conversionRequired | Bool |

### WithdrawalMethodsResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| withdrawalMethods | [WithdrawalMethod] |

**Related Models:**
- [WithdrawalMethod](#withdrawalmethod)

