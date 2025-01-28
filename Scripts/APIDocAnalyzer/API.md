# API Documentation

This documentation provides a comprehensive overview of our API services, including available endpoints and data models.

## Table of Contents
1. [REST Services](#rest-services)
2. [Real-time Services](#real-time-services)
3. [Data Models](#data-models)

# REST Services

## bonuses

### 🔸 getGrantedBonuses

_Retrieves the list of bonuses that have been granted to the user_

**Arguments:**

**Returns:** [GrantedBonus](#grantedbonus), [GrantedBonus]

### 🔸 optOutBonus

_Opts out from a specific bonus_

**Arguments:**
- partyId: String
- code: String

**Returns:** [BasicResponse](#basicresponse)

### 🔸 getAvailableBonuses

_Retrieves the list of bonuses available for the user to claim_

**Arguments:**

**Returns:** [AvailableBonus](#availablebonus), [AvailableBonus]

### 🔸 redeemBonus

_Redeems a bonus using a bonus code_

**Arguments:**
- code: String

**Returns:** [RedeemBonusResponse](#redeembonusresponse)

### 🔸 cancelBonus

_Cancels an active bonus_

**Arguments:**
- bonusId: String

**Returns:** [BasicResponse](#basicresponse)

### 🔸 redeemAvailableBonus

_Claims an available bonus for a specific user_

**Arguments:**
- code: String
- partyId: String

**Returns:** [BasicResponse](#basicresponse)

## registration

### 🔸 signUpCompletion

_Completes the signup process with additional user information_

**Arguments:**
- Form containing additional user information

**Returns:** Bool

### 🔸 simpleSignUp

_Registers a new user with basic information_

**Arguments:**
- form: SimpleSignUpForm

**Returns:** Bool

### 🔸 validateUsername

_Validates a username and provides suggestions if unavailable_

**Arguments:**
- username: String

**Returns:** UsernameValidation

### 🔸 checkEmailRegistered

_Checks if an email is already registered in the system_

**Arguments:**
- email: String

**Returns:** Bool

### 🔸 signUp

_Registers a new user with complete information_

**Arguments:**
- form: SignUpForm

**Returns:** SignUpResponse

### 🔸 signupConfirmation

_Confirms user signup with verification code_

**Arguments:**
- confirmationCode: String
- email: String

**Returns:** Bool

## profile

### 🔸 getUserProfile

_Retrieves the user's profile information_

**Arguments:**
- kycExpire: String?

**Returns:** UserProfile

## support

### 🔸 contactUs

_Sends a contact request to customer support_

**Arguments:**
- message: String
- subject: String
- email: String
- firstName: String
- lastName: String

**Returns:** [BasicResponse](#basicresponse)

### 🔸 contactSupport

_Sends a detailed support request with user information_

**Arguments:**
- lastName: String
- isLogged: Bool
- userIdentifier: String
- firstName: String
- message: String
- subject: String
- email: String
- subjectType: String

**Returns:** [SupportResponse](#supportresponse)

## location

### 🔸 getAllCountries

_Retrieves all available countries_

**Arguments:**

**Returns:** Country, [Country]

### 🔸 getCountries

_Retrieves list of available countries_

**Arguments:**

**Returns:** Country, [Country]

### 🔸 getCurrentCountry

_Retrieves the current country information_

**Arguments:**

**Returns:** Country?

## events

### 🔸 getHighlightedLiveEvents

_Retrieves detailed information about highlighted live events, optionally filtered by user_

**Arguments:**
- eventCount: Int
- userId: String?

**Returns:** [Event](#event), [Event]

### 🔸 getEventSecundaryMarkets

_Retrieves secondary markets information for a specific event_

**Arguments:**
- eventId: String

**Returns:** [Event](#event)

### 🔸 getEventDetails

_Retrieves detailed information about a specific event_

**Arguments:**
- eventId: String

**Returns:** [Event](#event)

### 🔸 getEventsForEventGroup

_Retrieves events associated with a specific event group_

**Arguments:**
- withId: String

**Returns:** [EventsGroup](#eventsgroup)

### 🔸 getHeroGameEvent

_Retrieves the hero game event_

**Arguments:**

**Returns:** [Event](#event), [Event]

### 🔸 getPromotionalSlidingTopEvents

_Retrieves promotional sliding events for the top section_

**Arguments:**

**Returns:** [Event](#event), [Event]

### 🔸 getEventSummaryByMarket

_Retrieves a summary of an event using a market ID associated with the event_

**Arguments:**
- forMarketId: String

**Returns:** [Event](#event)

### 🔸 getHighlightedMarkets

_Retrieves highlighted markets_

**Arguments:**

**Returns:** HighlightMarket, [HighlightMarket]

### 🔸 getSearchEvents

_Searches for events based on a query string with pagination support_

**Arguments:**
- page: String
- resultLimit: String
- query: String
- isLive: Bool

**Returns:** [EventsGroup](#eventsgroup)

### 🔸 getPromotionalTopBanners

_Retrieves promotional banners for the top section_

**Arguments:**

**Returns:** [PromotionalBanner](#promotionalbanner), [PromotionalBanner]

### 🔸 getTopCompetitions

_Retrieves the list of top competitions_

**Arguments:**

**Returns:** TopCompetition, [TopCompetition]

### 🔸 getCashbackSuccessBanner

_Retrieves the cashback success banner_

**Arguments:**

**Returns:** [BannerResponse](#bannerresponse)

### 🔸 getRegionCompetitions

_Retrieves information about competitions available in a specific region_

**Arguments:**
- regionId: String

**Returns:** [SportRegionInfo](#sportregioninfo)

### 🔸 getEventForMarketGroup

_Retrieves an event associated with a specific market group_

**Arguments:**
- withId: String

**Returns:** [Event](#event)

### 🔸 getPromotionalTopStories

_Retrieves promotional top stories_

**Arguments:**

**Returns:** [PromotionalStory](#promotionalstory), [PromotionalStory]

### 🔸 getAvailableSportTypes

_Retrieves a list of available sport types within an optional date range_

**Arguments:**
- endDate: Date?
- initialDate: Date?

**Returns:** [SportType](#sporttype), [SportType]

### 🔸 getHighlightedLiveEventsIds

_Retrieves IDs of highlighted live events, optionally filtered by user_

**Arguments:**
- userId: String?
- eventCount: Int

**Returns:** String, [String]

### 🔸 getHomeSliders

_Retrieves the home page slider banners_

**Arguments:**

**Returns:** [BannerResponse](#bannerresponse)

### 🔸 getCompetitionMarketGroups

_Retrieves information about market groups available for a specific competition_

**Arguments:**
- competitionId: String

**Returns:** [SportCompetitionInfo](#sportcompetitioninfo)

### 🔸 getEventLiveData

_Retrieves live data and statistics for a specific event_

**Arguments:**
- eventId: String

**Returns:** EventLiveData

### 🔸 getPromotedSports

_Retrieves the list of promoted sports_

**Arguments:**

**Returns:** [PromotedSport](#promotedsport), [PromotedSport]

### 🔸 getSportRegions

_Retrieves information about regions available for a specific sport_

**Arguments:**
- sportId: String

**Returns:** [SportNodeInfo](#sportnodeinfo)

### 🔸 getHighlightedBoostedEvents

_Retrieves events with boosted odds that are highlighted_

**Arguments:**

**Returns:** [Event](#event), [Event]

### 🔸 getTopCompetitionsPointers

_Retrieves pointers to top competitions_

**Arguments:**

**Returns:** [TopCompetitionPointer](#topcompetitionpointer), [TopCompetitionPointer]

### 🔸 getEventSummary

_Retrieves a summary of a specific event using its event ID_

**Arguments:**
- eventId: String

**Returns:** [Event](#event)

### 🔸 getMarketInfo

_Retrieves detailed information about a specific market_

**Arguments:**
- marketId: String

**Returns:** [Market](#market)

### 🔸 getHighlightedVisualImageEvents

_Retrieves events with visual images that are highlighted_

**Arguments:**

**Returns:** [Event](#event), [Event]

## betting

### 🔸 getFreebet

_Retrieves information about available freebets for the user_

**Arguments:**

**Returns:** [FreebetResponse](#freebetresponse)

### 🔸 getAllowedBetTypes

_Retrieves allowed bet types for given selections_

**Arguments:**
- betTicketSelections: [BetTicketSelection]

**Returns:** [BetTicketSelection](#betticketselection), [BetType](#bettype), [BetType]

### 🔸 calculatePotentialReturn

_Calculates potential return for a bet ticket before placing the bet_

**Arguments:**
- betTicket: [BetTicket](#betticket)

**Returns:** BetslipPotentialReturn

### 🔸 getWonBetsHistory

_Retrieves history of won bets with optional date filtering_

**Arguments:**
- startDate: String?
- endDate: String?
- pageIndex: Int

**Returns:** [BettingHistory](#bettinghistory)

### 🔸 cashoutBet

_Performs a cashout operation on a specific bet_

**Arguments:**
- cashoutValue: Double
- betId: String
- stakeValue: Double?

**Returns:** [CashoutResult](#cashoutresult)

### 🔸 getTicketSelection

_Retrieves a specific ticket selection by its ID_

**Arguments:**
- ticketSelectionId: String

**Returns:** [TicketSelection](#ticketselection)

### 🔸 getSharedTicket

_Retrieves a shared bet ticket by its ID_

**Arguments:**
- betslipId: String

**Returns:** [SharedTicketResponse](#sharedticketresponse)

### 🔸 getBetHistory

_Retrieves betting history with pagination_

**Arguments:**
- pageIndex: Int

**Returns:** [BettingHistory](#bettinghistory)

### 🔸 calculateBetBuilderPotentialReturn

_Calculates potential return for a bet builder ticket_

**Arguments:**
- betTicket: [BetTicket](#betticket)

**Returns:** [BetBuilderPotentialReturn](#betbuilderpotentialreturn)

### 🔸 updateBetslipSettings

_Updates the user's betslip settings_

**Arguments:**
- betslipSettings: [BetslipSettings](#betslipsettings)

**Returns:** [BetslipSettings](#betslipsettings)

### 🔸 confirmBoostedBet

_Confirms a boosted bet offer_

**Arguments:**
- identifier: String

**Returns:** Bool

### 🔸 rejectBoostedBet

_Rejects a boosted bet offer_

**Arguments:**
- identifier: String

**Returns:** Bool

### 🔸 calculateCashout

_Calculates the cashout value for a specific bet_

**Arguments:**
- betId: String
- stakeValue: String?

**Returns:** [Cashout](#cashout)

### 🔸 calculateCashback

_Calculates potential cashback for a bet ticket_

**Arguments:**
- betTicket: [BetTicket](#betticket)

**Returns:** [CashbackResult](#cashbackresult)

### 🔸 getResolvedBetsHistory

_Retrieves history of resolved bets with optional date filtering_

**Arguments:**
- pageIndex: Int
- startDate: String?
- endDate: String?

**Returns:** [BettingHistory](#bettinghistory)

### 🔸 getOpenBetsHistory

_Retrieves history of open bets with optional date filtering_

**Arguments:**
- startDate: String?
- pageIndex: Int
- endDate: String?

**Returns:** [BettingHistory](#bettinghistory)

### 🔸 allowedCashoutBetIds

_Retrieves IDs of bets that are eligible for cashout_

**Arguments:**

**Returns:** String, [String]

### 🔸 placeBetBuilderBet

_Places a bet builder bet with calculated odds_

**Arguments:**
- betTicket: [BetTicket](#betticket)
- calculatedOdd: Double

**Returns:** [PlacedBetsResponse](#placedbetsresponse)

### 🔸 getBetDetails

_Retrieves detailed information about a specific bet_

**Arguments:**
- identifier: String

**Returns:** [Bet](#bet)

### 🔸 placeBets

_Places one or more bets using the provided bet tickets_

**Arguments:**
- betTickets: [BetTicket]
- useFreebetBalance: Bool

**Returns:** [BetTicket](#betticket), [PlacedBetsResponse](#placedbetsresponse)

### 🔸 getBetslipSettings

_Retrieves the current betslip settings for the user_

**Arguments:**

**Returns:** [BetslipSettings](#betslipsettings)

## identity_verification

### 🔸 getSumsubAccessToken

_Retrieves an access token for Sumsub identity verification service_

**Arguments:**
- levelName: String
- userId: String

**Returns:** [AccessTokenResponse](#accesstokenresponse)

### 🔸 checkDocumentationData

_Checks the status of user's submitted documentation_

**Arguments:**

**Returns:** [ApplicantDataResponse](#applicantdataresponse)

### 🔸 generateDocumentTypeToken

_Generates a token for uploading a specific type of document_

**Arguments:**
- docType: String

**Returns:** [AccessTokenResponse](#accesstokenresponse)

### 🔸 getSumsubApplicantData

_Retrieves applicant verification data from Sumsub_

**Arguments:**
- userId: String

**Returns:** [ApplicantDataResponse](#applicantdataresponse)

## account_management

### 🔸 updatePassword

_Updates the user's password_

**Arguments:**
- newPassword: String
- oldPassword: String

**Returns:** Bool

### 🔸 updateExtraInfo

_Updates additional user information_

**Arguments:**
- address2: String?
- placeOfBirth: String?

**Returns:** [BasicResponse](#basicresponse)

### 🔸 updateDeviceIdentifier

_Updates the device identifier and app version for the user_

**Arguments:**
- deviceIdentifier: String
- appVersion: String

**Returns:** [BasicResponse](#basicresponse)

### 🔸 verifyMobileCode

_Verifies a mobile verification code_

**Arguments:**
- code: String
- requestId: String

**Returns:** [MobileVerifyResponse](#mobileverifyresponse)

### 🔸 getMobileVerificationCode

_Requests a verification code for a mobile number_

**Arguments:**
- mobileNumber: String

**Returns:** [MobileVerifyResponse](#mobileverifyresponse)

### 🔸 forgotPassword

_Initiates the password recovery process_

**Arguments:**
- secretAnswer: String?
- email: String
- secretQuestion: String?

**Returns:** Bool

### 🔸 lockPlayer

_Locks a player's account with specified duration_

**Arguments:**
- lockPeriodUnit: String?
- isPermanent: Bool?
- lockPeriod: String?

**Returns:** [BasicResponse](#basicresponse)

### 🔸 updateUserProfile

_Updates the user's profile information_

**Arguments:**
- form: UpdateUserProfileForm

**Returns:** Bool

## payments

### 🔸 getPayments

_Retrieves available payment methods for deposits_

**Arguments:**

**Returns:** SimplePaymentMethodsResponse

### 🔸 cancelWithdrawal

_Cancels a pending withdrawal transaction_

**Arguments:**
- paymentId: Int

**Returns:** [CancelWithdrawalResponse](#cancelwithdrawalresponse)

### 🔸 cancelDeposit

_Cancels a pending deposit transaction_

**Arguments:**
- paymentId: String

**Returns:** [BasicResponse](#basicresponse)

### 🔸 getPendingWithdrawals

_Retrieves list of pending withdrawal transactions_

**Arguments:**

**Returns:** [PendingWithdrawal](#pendingwithdrawal), [PendingWithdrawal]

### 🔸 prepareWithdrawal

_Prepares a withdrawal request for processing_

**Arguments:**
- paymentMethod: String

**Returns:** [PrepareWithdrawalResponse](#preparewithdrawalresponse)

### 🔸 checkPaymentStatus

_Checks the status of a payment transaction_

**Arguments:**
- paymentId: String
- paymentMethod: String

**Returns:** [PaymentStatusResponse](#paymentstatusresponse)

### 🔸 getWithdrawalMethods

_Retrieves available withdrawal methods_

**Arguments:**

**Returns:** [WithdrawalMethod](#withdrawalmethod), [WithdrawalMethod]

### 🔸 addPaymentInformation

_Adds new payment information for the user_

**Arguments:**
- fields: String
- type: String

**Returns:** [AddPaymentInformationResponse](#addpaymentinformationresponse)

### 🔸 getTransactionsHistory

_Retrieves transaction history for a specified date range_

**Arguments:**
- pageNumber: Int?
- startDate: String
- endDate: String
- transactionTypes: [TransactionType]?

**Returns:** [TransactionDetail](#transactiondetail), TransactionType, [TransactionDetail]

### 🔸 processDeposit

_Processes a deposit request_

**Arguments:**
- amount: Double
- paymentMethod: String
- option: String

**Returns:** [ProcessDepositResponse](#processdepositresponse)

### 🔸 processWithdrawal

_Processes a withdrawal request_

**Arguments:**
- amount: Double
- conversionId: String?
- paymentMethod: String

**Returns:** [ProcessWithdrawalResponse](#processwithdrawalresponse)

### 🔸 updatePayment

_Updates payment information for an existing payment_

**Arguments:**
- encryptedCardNumber: String?
- nameOnCard: String?
- paymentId: String
- encryptedExpiryYear: String?
- returnUrl: String?
- type: String
- encryptedExpiryMonth: String?
- amount: Double
- encryptedSecurityCode: String?

**Returns:** [UpdatePaymentResponse](#updatepaymentresponse)

### 🔸 getPaymentInformation

_Retrieves saved payment information for the user_

**Arguments:**

**Returns:** [PaymentInformation](#paymentinformation)

## wallet

### 🔸 getUserBalance

_Retrieves the user's wallet balance information_

**Arguments:**

**Returns:** UserWallet

### 🔸 getUserCashbackBalance

_Retrieves the user's cashback balance information_

**Arguments:**

**Returns:** [CashbackBalance](#cashbackbalance)

## authentication

### 🔸 logout

_Logs out the current user and invalidates their session_

**Arguments:**

**Returns:** [BasicResponse](#basicresponse)

### 🔸 login

_Authenticates a user with username and password_

**Arguments:**
- username: String
- password: String

**Returns:** UserProfile

### 🔸 getPasswordPolicy

_Retrieves the password policy requirements_

**Arguments:**

**Returns:** PasswordPolicy

## referral

### 🔸 getReferees

_Retrieves the list of users referred by the current user_

**Arguments:**

**Returns:** [Referee](#referee), [Referee]

### 🔸 getReferralLink

_Retrieves the user's referral link_

**Arguments:**

**Returns:** [ReferralLink](#referrallink)

## favorites

### 🔸 getPromotedBetslips

_Retrieves promoted betslips, optionally filtered by user_

**Arguments:**
- userId: String?

**Returns:** [PromotedBetslip](#promotedbetslip), [PromotedBetslip]

### 🔸 getFavoritesList

_Retrieves all favorite lists for the current user_

**Arguments:**

**Returns:** [FavoritesListResponse](#favoriteslistresponse)

### 🔸 addFavoritesList

_Creates a new favorites list with the specified name_

**Arguments:**
- name: String

**Returns:** [FavoritesListAddResponse](#favoriteslistaddresponse)

### 🔸 deleteFavoriteFromList

_Deletes a favorite event from a list_

**Arguments:**
- eventId: Int

**Returns:** [FavoritesListDeleteResponse](#favoriteslistdeleteresponse)

### 🔸 getFavoritesFromList

_Retrieves all favorite events from a specified list_

**Arguments:**
- listId: Int

**Returns:** [FavoriteEventResponse](#favoriteeventresponse)

### 🔸 deleteFavoritesList

_Deletes a favorites list with the specified ID_

**Arguments:**
- listId: Int

**Returns:** [FavoritesListDeleteResponse](#favoriteslistdeleteresponse)

### 🔸 addFavoriteToList

_Adds an event to a specified favorites list_

**Arguments:**
- eventId: String
- listId: Int

**Returns:** [FavoriteAddResponse](#favoriteaddresponse)

## responsible_gaming

### 🔸 updateResponsibleGamingLimits

_Updates the user's responsible gaming limits_

**Arguments:**
- newLimit: Double
- limitType: String
- hasRollingWeeklyLimits: Bool

**Returns:** Bool

### 🔸 getPersonalDepositLimits

_Retrieves the user's personal deposit limits_

**Arguments:**

**Returns:** [PersonalDepositLimitResponse](#personaldepositlimitresponse)

### 🔸 getResponsibleGamingLimits

_Retrieves responsible gaming limits for specified period and limit types_

**Arguments:**
- periodTypes: String?
- limitTypes: String?

**Returns:** [ResponsibleGamingLimitsResponse](#responsiblegaminglimitsresponse)

### 🔸 updateWeeklyDepositLimits

_Updates the user's weekly deposit limits_

**Arguments:**
- newLimit: Double

**Returns:** Bool

### 🔸 updateWeeklyBettingLimits

_Updates the user's weekly betting limits_

**Arguments:**
- newLimit: Double

**Returns:** Bool

### 🔸 getLimits

_Retrieves all user limits information_

**Arguments:**

**Returns:** [LimitsResponse](#limitsresponse)

## documents

### 🔸 getDocumentTypes

_Retrieves available document types for verification_

**Arguments:**

**Returns:** [DocumentTypesResponse](#documenttypesresponse)

### 🔸 getUserDocuments

_Retrieves user's uploaded documents_

**Arguments:**

**Returns:** [UserDocumentsResponse](#userdocumentsresponse)

### 🔸 uploadUserDocument

_Uploads a single user verification document_

**Arguments:**
- documentType: String
- file: Data
- fileName: String

**Returns:** [UploadDocumentResponse](#uploaddocumentresponse)

### 🔸 uploadMultipleUserDocuments

_Uploads multiple user verification documents_

**Arguments:**
- files: [String: Data]
- documentType: String

**Returns:** [UploadDocumentResponse](#uploaddocumentresponse)

## consent_management

### 🔸 getAllConsents

_Retrieves all available consent types and their information_

**Arguments:**

**Returns:** ConsentInfo, [ConsentInfo]

### 🔸 setUserConsents

_Updates user consent statuses for specified consent versions_

**Arguments:**
- unconsenVersionIds: [Int]?
- consentVersionIds: [Int]?

**Returns:** [BasicResponse](#basicresponse), Int

### 🔸 getUserConsents

_Retrieves the user's current consent statuses_

**Arguments:**

**Returns:** [UserConsent](#userconsent), [UserConsent]


# Real-time Services

_These services provide real-time updates through WebSocket connections._

### 🔹 subscribePreLiveMatches

_Subscribes to pre-live (upcoming) matches for a specific sport type with optional date range and sorting parameters_

**Update Information:**
- Frequency: on-change

### 🔹 subscribeLiveMatches

_Subscribes to live matches updates for a specific sport type through WebSocket connection_

**Update Information:**
- Frequency: real-time

### 🔹 subscribeToMarketDetails

_Subscribes to real-time updates for a specific market within an event_

**Update Information:**
- Frequency: real-time

### 🔹 subscribePreLiveSportTypes

_Subscribes to updates for available pre-live sport types within a specified date range_

**Update Information:**
- Frequency: on-change

### 🔹 subscribeAllSportTypes

_Subscribes to updates for all available sport types, including both live and pre-live sports_

**Update Information:**
- Frequency: on-change

### 🔹 subscribeOutrightMarkets

_Subscribes to outright market updates for a specific market group (e.g., tournament winner, top scorer)_

**Update Information:**
- Frequency: on-change

### 🔹 subscribeEventMarkets

_Subscribes to all markets associated with a specific event, including odds updates and market status changes_

**Update Information:**
- Frequency: real-time

### 🔹 subscribeLiveSportTypes

_Subscribes to updates for currently live sport types and their active events_

**Update Information:**
- Frequency: real-time

### 🔹 subscribeToLiveDataUpdates

_Subscribes to real-time live data updates for a specific event, including detailed statistics and play-by-play information_

**Update Information:**
- Frequency: real-time

### 🔹 subscribeEventDetails

_Subscribes to detailed updates for a specific event, including scores, statistics, and market information_

**Update Information:**
- Frequency: real-time
- Includes:
  - score updates
  - match statistics
  - timeline events
  - market information
  - event status changes

### 🔹 subscribeCompetitionMatches

_Subscribes to matches updates for a specific competition identified by its market group ID_

**Update Information:**
- Frequency: real-time


# Data Models

_This section describes the data structures used in the API._

### Ⓜ️ AccessTokenResponse

**Properties:**

| Name | Type |
|------|------|
| token | String? |
| userId | String? |
| description | String? |
| code | Int? |

### Ⓜ️ ActivePlayerServe

**Properties:**

| Name | Type |
|------|------|
| home | ActivePlayerServe |
| away | ActivePlayerServe |

**Related Models:**
- [ActivePlayerServe](#activeplayerserve)

### Ⓜ️ AddPaymentInformationResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| message | String? |

### Ⓜ️ ApplicantDataInfo

**Properties:**

| Name | Type |
|------|------|
| applicantDocs | [ApplicantDoc]? |

**Related Models:**
- [ApplicantDoc](#applicantdoc)

### Ⓜ️ ApplicantDataResponse

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

### Ⓜ️ ApplicantDoc

**Properties:**

| Name | Type |
|------|------|
| docType | String |

### Ⓜ️ ApplicantReviewData

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

### Ⓜ️ ApplicantReviewResult

**Properties:**

| Name | Type |
|------|------|
| reviewAnswer | String |
| reviewRejectType | String? |
| moderationComment | String? |

### Ⓜ️ ApplicantRootResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| message | String? |
| data | ApplicantDataResponse |

**Related Models:**
- [ApplicantDataResponse](#applicantdataresponse)

### Ⓜ️ AvailableBonus

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

### Ⓜ️ AvailableBonusResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| bonuses | [AvailableBonus] |

**Related Models:**
- [AvailableBonus](#availablebonus)

### Ⓜ️ BalanceResponse

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

### Ⓜ️ BankPaymentDetail

**Properties:**

| Name | Type |
|------|------|
| id | Int |
| paymentInfoId | Int |
| key | String |
| value | String |

### Ⓜ️ BankPaymentInfo

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

### Ⓜ️ Banner

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

### Ⓜ️ BannerResponse

**Properties:**

| Name | Type |
|------|------|
| bannerItems | [Banner] |

**Related Models:**
- [Banner](#banner)

### Ⓜ️ BannerSpecialAction

**Properties:**

| Name | Type |
|------|------|
| register | BannerSpecialAction |
| none | BannerSpecialAction |

**Related Models:**
- [BannerSpecialAction](#bannerspecialaction)

### Ⓜ️ BasicResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| message | String? |

### Ⓜ️ Bet

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

### Ⓜ️ BetBuilderPotentialReturn

**Properties:**

| Name | Type |
|------|------|
| potentialReturn | Double |
| calculatedOdds | Double |

### Ⓜ️ BetResult

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

### Ⓜ️ BetSlip

**Properties:**

| Name | Type |
|------|------|
| tickets | [BetTicket] |

**Related Models:**
- [BetTicket](#betticket)

### Ⓜ️ BetSlipStateResponse

**Properties:**

| Name | Type |
|------|------|
| tickets | [BetTicket] |

**Related Models:**
- [BetTicket](#betticket)

### Ⓜ️ BetState

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

### Ⓜ️ BetTicket

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

### Ⓜ️ BetTicketSelection

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

### Ⓜ️ BetType

**Properties:**

| Name | Type |
|------|------|
| typeCode | String |
| typeName | String |
| potencialReturn | Double |
| totalStake | Double |
| numberOfIndividualBets | Int |

### Ⓜ️ BetslipPotentialReturnResponse

**Properties:**

| Name | Type |
|------|------|
| potentialReturn | Double |
| totalStake | Double |
| numberOfBets | Int |
| totalOdd | Double? |

### Ⓜ️ BetslipSettings

**Properties:**

| Name | Type |
|------|------|
| oddChangeLegacy | BetslipOddChangeSetting? |
| oddChangeRunningOrPreMatch | BetslipOddChangeSetting? |

**Related Models:**

### Ⓜ️ BettingHistory

**Properties:**

| Name | Type |
|------|------|
| bets | [Bet] |

**Related Models:**
- [Bet](#bet)

### Ⓜ️ CancelWithdrawalResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| amount | String |
| currency | String |

### Ⓜ️ CashbackBalance

**Properties:**

| Name | Type |
|------|------|
| status | String |
| balance | String? |
| message | String? |

### Ⓜ️ CashbackResult

**Properties:**

| Name | Type |
|------|------|
| id | Double |
| amount | Double? |
| amountFree | Double? |

### Ⓜ️ Cashout

**Properties:**

| Name | Type |
|------|------|
| cashoutValue | Double |
| partialCashoutAvailable | Bool? |

### Ⓜ️ CashoutResult

**Properties:**

| Name | Type |
|------|------|
| cashoutResult | Int? |
| cashoutReoffer | Double? |
| message | String? |

### Ⓜ️ CheckCredentialResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| exists | String |
| fieldExist | Bool |

### Ⓜ️ CheckUsernameResponse

**Properties:**

| Name | Type |
|------|------|
| errors | [CheckUsernameError]? |
| status | String |
| message | String? |
| additionalInfos | [CheckUsernameAdditionalInfo]? |

**Related Models:**

### Ⓜ️ CompetitionMarketGroup

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |
| events | [Event] |

**Related Models:**
- [Event](#event)

### Ⓜ️ CompetitionParentNode

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |
| categoryName | String |

### Ⓜ️ ConfirmBetPlaceResponse

**Properties:**

| Name | Type |
|------|------|
| state | Int |
| detailedState | Int |
| statusCode | String? |
| statusText | String? |

### Ⓜ️ Consent

**Properties:**

| Name | Type |
|------|------|
| id | Int |
| key | String |
| name | String |
| consentVersionId | Int |
| status | String? |
| isMandatory | Bool? |

### Ⓜ️ ConsentsResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| consents | [Consent] |

**Related Models:**
- [Consent](#consent)

### Ⓜ️ ContentContainer

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

### Ⓜ️ CountryInfo

**Properties:**

| Name | Type |
|------|------|
| name | String |
| iso2Code | String |
| phonePrefix | String |

### Ⓜ️ DepositMethod

**Properties:**

| Name | Type |
|------|------|
| code | String |
| paymentMethod | String |
| methods | [PaymentMethod]? |

**Related Models:**
- [PaymentMethod](#paymentmethod)

### Ⓜ️ DocumentType

**Properties:**

| Name | Type |
|------|------|
| documentType | String |
| issueDateRequired | Bool? |
| expiryDateRequired | Bool? |
| documentNumberRequired | Bool? |
| multipleFileRequired | Bool? |

### Ⓜ️ DocumentTypesResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| documentTypes | [DocumentType] |

**Related Models:**
- [DocumentType](#documenttype)

### Ⓜ️ Event

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

### Ⓜ️ EventLiveDataExtended

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

### Ⓜ️ EventStatus

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

### Ⓜ️ EventsGroup

**Properties:**

| Name | Type |
|------|------|
| events | [Event] |
| marketGroupId | String? |

**Related Models:**
- [Event](#event)

### Ⓜ️ FavoriteAddResponse

**Properties:**

| Name | Type |
|------|------|
| displayOrder | Int? |
| idAccountFavorite | Int? |

### Ⓜ️ FavoriteEvent

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |
| favoriteListId | Int |
| accountFavoriteId | Int |

### Ⓜ️ FavoriteEventResponse

**Properties:**

| Name | Type |
|------|------|
| favoriteEvents | [FavoriteEvent] |

**Related Models:**
- [FavoriteEvent](#favoriteevent)

### Ⓜ️ FavoriteList

**Properties:**

| Name | Type |
|------|------|
| id | Int |
| name | String |
| customerId | Int |

### Ⓜ️ FavoritesListAddResponse

**Properties:**

| Name | Type |
|------|------|
| listId | Int |

### Ⓜ️ FavoritesListDeleteResponse

**Properties:**

| Name | Type |
|------|------|
| listId | String? |

### Ⓜ️ FavoritesListResponse

**Properties:**

| Name | Type |
|------|------|
| favoritesList | [FavoriteList] |

**Related Models:**
- [FavoriteList](#favoritelist)

### Ⓜ️ FieldError

**Properties:**

| Name | Type |
|------|------|
| field | String |
| error | String |

### Ⓜ️ FreebetResponse

**Properties:**

| Name | Type |
|------|------|
| balance | Double |

### Ⓜ️ GetCountriesResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| countries | [String] |

### Ⓜ️ GetCountryInfoResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| countryInfo | CountryInfo |

**Related Models:**
- [CountryInfo](#countryinfo)

### Ⓜ️ GrantedBonus

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

### Ⓜ️ GrantedBonusResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| bonuses | [GrantedBonus] |

**Related Models:**
- [GrantedBonus](#grantedbonus)

### Ⓜ️ HeadlineItem

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

### Ⓜ️ HeadlineResponse

**Properties:**

| Name | Type |
|------|------|
| headlineItems | [HeadlineItem]? |

**Related Models:**
- [HeadlineItem](#headlineitem)

### Ⓜ️ HighlightedEventPointer

**Properties:**

| Name | Type |
|------|------|
| status | String |
| sportId | String |
| eventId | String |
| eventType | String? |
| countryId | String |

### Ⓜ️ KYCStatusDetail

**Properties:**

| Name | Type |
|------|------|
| expiryDate | String? |

### Ⓜ️ LimitPending

**Properties:**

| Name | Type |
|------|------|
| effectiveDate | String |
| limit | String |
| limitNumber | Double |

### Ⓜ️ LimitsResponse

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

### Ⓜ️ LoginResponse

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

### Ⓜ️ Market

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

### Ⓜ️ MarketGroup

**Properties:**

| Name | Type |
|------|------|
| markets | [Market] |
| marketGroupId | String? |

**Related Models:**
- [Market](#market)

### Ⓜ️ MarketGroupPromotedSport

**Properties:**

| Name | Type |
|------|------|
| id | String |
| typeId | String? |
| name | String? |

### Ⓜ️ MobileVerifyResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| message | String? |
| requestId | Int? |

### Ⓜ️ NotificationType

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

### Ⓜ️ OpenSessionResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| launchToken | String |

### Ⓜ️ Outcome

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

### Ⓜ️ PaymentInformation

**Properties:**

| Name | Type |
|------|------|
| status | String |
| data | [BankPaymentInfo] |

**Related Models:**
- [BankPaymentInfo](#bankpaymentinfo)

### Ⓜ️ PaymentMethod

**Properties:**

| Name | Type |
|------|------|
| name | String |
| type | String |
| brands | [String]? |

### Ⓜ️ PaymentStatusResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| paymentId | String? |
| paymentStatus | String? |
| message | String? |

### Ⓜ️ PaymentsResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| depositMethods | [DepositMethod] |

**Related Models:**
- [DepositMethod](#depositmethod)

### Ⓜ️ PendingWithdrawal

**Properties:**

| Name | Type |
|------|------|
| status | String |
| paymentId | Int |
| amount | String |

### Ⓜ️ PendingWithdrawalResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| pendingWithdrawals | [PendingWithdrawal] |

**Related Models:**
- [PendingWithdrawal](#pendingwithdrawal)

### Ⓜ️ PersonalDepositLimitResponse

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

### Ⓜ️ PlacedBetEntry

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

### Ⓜ️ PlacedBetLeg

**Properties:**

| Name | Type |
|------|------|
| identifier | String |
| priceType | String |
| odd | Double |
| priceNumerator | Int |
| priceDenominator | Int |

### Ⓜ️ PlacedBetsResponse

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

### Ⓜ️ PlayerInfoResponse

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

### Ⓜ️ PrepareWithdrawalResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| conversionId | String? |
| message | String? |

### Ⓜ️ ProcessDepositResponse

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

### Ⓜ️ ProcessWithdrawalResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| paymentId | String? |
| message | String? |

### Ⓜ️ PromotedBetslip

**Properties:**

| Name | Type |
|------|------|
| selections | [PromotedBetslipSelection] |
| betslipCount | Int |

**Related Models:**
- [PromotedBetslipSelection](#promotedbetslipselection)

### Ⓜ️ PromotedBetslipSelection

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

### Ⓜ️ PromotedBetslipsBatchResponse

**Properties:**

| Name | Type |
|------|------|
| promotedBetslips | [PromotedBetslip] |
| status | String |

**Related Models:**
- [PromotedBetslip](#promotedbetslip)

### Ⓜ️ PromotedBetslipsInternalRequest

**Properties:**

| Name | Type |
|------|------|
| body | VaixBatchBody |
| name | String |
| statusCode | Int |

**Related Models:**
- [VaixBatchBody](#vaixbatchbody)

### Ⓜ️ PromotedSport

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |
| marketGroups | [MarketGroupPromotedSport] |

**Related Models:**
- [MarketGroupPromotedSport](#marketgrouppromotedsport)

### Ⓜ️ PromotedSportsNodeResponse

**Properties:**

| Name | Type |
|------|------|
| promotedSports | [PromotedSport] |

**Related Models:**
- [PromotedSport](#promotedsport)

### Ⓜ️ PromotedSportsResponse

**Properties:**

| Name | Type |
|------|------|
| promotedSports | [PromotedSport] |

**Related Models:**
- [PromotedSport](#promotedsport)

### Ⓜ️ PromotionalBanner

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

### Ⓜ️ PromotionalBannersResponse

**Properties:**

| Name | Type |
|------|------|
| promotionalBannerItems | [PromotionalBanner] |

**Related Models:**
- [PromotionalBanner](#promotionalbanner)

### Ⓜ️ PromotionalStoriesResponse

**Properties:**

| Name | Type |
|------|------|
| promotionalStories | [PromotionalStory] |

**Related Models:**
- [PromotionalStory](#promotionalstory)

### Ⓜ️ PromotionalStory

**Properties:**

| Name | Type |
|------|------|
| id | String |
| title | String |
| imageUrl | String |
| linkUrl | String |
| bodyText | String |

### Ⓜ️ RedeemBonus

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

### Ⓜ️ RedeemBonusResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| message | String? |
| bonus | RedeemBonus? |

**Related Models:**
- [RedeemBonus](#redeembonus)

### Ⓜ️ Referee

**Properties:**

| Name | Type |
|------|------|
| id | Int |
| username | String |
| registeredAt | String |
| kycStatus | String |
| depositPassed | Bool |

### Ⓜ️ RefereesResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| referees | [Referee] |

**Related Models:**
- [Referee](#referee)

### Ⓜ️ ReferralLink

**Properties:**

| Name | Type |
|------|------|
| code | String |
| link | String |

### Ⓜ️ ReferralResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| referralLinks | [ReferralLink] |

**Related Models:**
- [ReferralLink](#referrallink)

### Ⓜ️ ResponsibleGamingLimit

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

### Ⓜ️ ResponsibleGamingLimitsResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| limits | [ResponsibleGamingLimit] |

**Related Models:**
- [ResponsibleGamingLimit](#responsiblegaminglimit)

### Ⓜ️ ScheduledSport

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |

### Ⓜ️ Score

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

### Ⓜ️ ScoreCodingKeys

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

### Ⓜ️ SharedBet

**Properties:**

| Name | Type |
|------|------|
| betSelections | [SharedBetSelection] |
| winStake | Double |
| potentialReturn | Double |
| totalStake | Double |

**Related Models:**
- [SharedBetSelection](#sharedbetselection)

### Ⓜ️ SharedBetSelection

**Properties:**

| Name | Type |
|------|------|
| id | Double |
| priceDenominator | Int |
| priceNumerator | Int |
| priceType | String |

### Ⓜ️ SharedTicketResponse

**Properties:**

| Name | Type |
|------|------|
| bets | [SharedBet] |
| totalStake | Double |
| betId | Double |

**Related Models:**
- [SharedBet](#sharedbet)

### Ⓜ️ SportCompetition

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |
| numberEvents | String |
| numberOutrightEvents | String |

### Ⓜ️ SportCompetitionInfo

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

### Ⓜ️ SportCompetitionMarketGroup

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |

### Ⓜ️ SportNode

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

### Ⓜ️ SportNodeInfo

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

### Ⓜ️ SportRadarError

**Properties:**

| Name | Type |
|------|------|
| unkownSportId | SportRadarError |
| unkownContentId | SportRadarError |
| ignoredContentInitialData | SportRadarError |
| ignoredContentUpdate | SportRadarError |

**Related Models:**
- [SportRadarError](#sportradarerror)

### Ⓜ️ SportRegion

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String? |
| numberEvents | String |
| numberOutrightEvents | String |

### Ⓜ️ SportRegionInfo

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |
| competitionNodes | [SportCompetition] |

**Related Models:**
- [SportCompetition](#sportcompetition)

### Ⓜ️ SportType

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

### Ⓜ️ SportTypeDetails

**Properties:**

| Name | Type |
|------|------|
| sportType | SportType |
| eventsCount | Int |
| sportName | String |

**Related Models:**
- [SportType](#sporttype)

### Ⓜ️ SportsList

**Properties:**

| Name | Type |
|------|------|
| sportNodes | [SportNode]? |

**Related Models:**
- [SportNode](#sportnode)

### Ⓜ️ StatusResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| errors | [FieldError]? |
| message | String? |

**Related Models:**
- [FieldError](#fielderror)

### Ⓜ️ SupportRequest

**Properties:**

| Name | Type |
|------|------|
| id | Int |
| status | String |

### Ⓜ️ SupportResponse

**Properties:**

| Name | Type |
|------|------|
| request | SupportRequest? |
| error | String? |
| description | String? |

**Related Models:**
- [SupportRequest](#supportrequest)

### Ⓜ️ TicketSelection

**Properties:**

| Name | Type |
|------|------|
| id | String |
| marketId | String |
| name | String |
| priceDenominator | String |
| priceNumerator | String |
| odd | Double |

### Ⓜ️ TicketSelectionResponse

**Properties:**

| Name | Type |
|------|------|
| data | TicketSelection? |
| errorType | String? |

**Related Models:**
- [TicketSelection](#ticketselection)

### Ⓜ️ TopCompetitionData

**Properties:**

| Name | Type |
|------|------|
| title | String |
| competitions | [TopCompetitionPointer] |

**Related Models:**
- [TopCompetitionPointer](#topcompetitionpointer)

### Ⓜ️ TopCompetitionPointer

**Properties:**

| Name | Type |
|------|------|
| id | String |
| name | String |
| competitionId | String |

### Ⓜ️ TopCompetitionsResponse

**Properties:**

| Name | Type |
|------|------|
| data | [TopCompetitionData] |

**Related Models:**
- [TopCompetitionData](#topcompetitiondata)

### Ⓜ️ TransactionDetail

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

### Ⓜ️ TransactionsHistoryResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| transactions | [TransactionDetail]? |

**Related Models:**
- [TransactionDetail](#transactiondetail)

### Ⓜ️ UpdatePaymentAction

**Properties:**

| Name | Type |
|------|------|
| paymentMethodType | String |
| url | String |
| method | String |
| type | String |

### Ⓜ️ UpdatePaymentResponse

**Properties:**

| Name | Type |
|------|------|
| resultCode | String |
| action | UpdatePaymentAction? |

**Related Models:**
- [UpdatePaymentAction](#updatepaymentaction)

### Ⓜ️ UploadDocumentResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| message | String? |

### Ⓜ️ UserConsent

**Properties:**

| Name | Type |
|------|------|
| consentInfo | UserConsentInfo |
| consentStatus | String |

**Related Models:**
- [UserConsentInfo](#userconsentinfo)

### Ⓜ️ UserConsentInfo

**Properties:**

| Name | Type |
|------|------|
| id | Int |
| key | String |
| name | String |
| consentVersionId | Int |
| isMandatory | Bool? |

### Ⓜ️ UserConsentsResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| message | String? |
| userConsents | [UserConsent] |

**Related Models:**
- [UserConsent](#userconsent)

### Ⓜ️ UserDocument

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

### Ⓜ️ UserDocumentFile

**Properties:**

| Name | Type |
|------|------|
| fileName | String |

### Ⓜ️ UserDocumentsResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| userDocuments | [UserDocument] |

**Related Models:**
- [UserDocument](#userdocument)

### Ⓜ️ VaixBatchBody

**Properties:**

| Name | Type |
|------|------|
| data | VaixBatchData |
| status | String |

**Related Models:**
- [VaixBatchData](#vaixbatchdata)

### Ⓜ️ VaixBatchData

**Properties:**

| Name | Type |
|------|------|
| promotedBetslips | [PromotedBetslip] |
| count | Int |

**Related Models:**
- [PromotedBetslip](#promotedbetslip)

### Ⓜ️ WithdrawalMethod

**Properties:**

| Name | Type |
|------|------|
| code | String |
| paymentMethod | String |
| minimumWithdrawal | String |
| maximumWithdrawal | String |
| conversionRequired | Bool |

### Ⓜ️ WithdrawalMethodsResponse

**Properties:**

| Name | Type |
|------|------|
| status | String |
| withdrawalMethods | [WithdrawalMethod] |

**Related Models:**
- [WithdrawalMethod](#withdrawalmethod)

