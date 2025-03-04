# Swift Types Analysis Report

## Summary

- **Total Swift Files**: 1648
- **Total Types**: 2322
  - Classes: 905
  - Structs: 1014
  - Enums: 403
- **Files with Multiple Declarations**: 379

## Files with Multiple Declarations

| File | Types | Classes | Structs | Enums | Line Count |
|------|-------|---------|---------|-------|------------|
| Scripts/APIDocAnalyzer/manual_missing_models.swift | 52 | 2 | 41 | 9 | 970 |
| ServicesProvider/Sources/ServicesProvider/Models/User/User.swift | 48 | 1 | 40 | 7 | 900 |
| ServicesProvider/Sources/ServicesProvider/Models/Events/Events.swift | 40 | 8 | 25 | 7 | 970 |
| ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/SportRadarModels+User.swift | 35 | 0 | 35 | 0 | 777 |
| Core/Models/GGAPI/SocialModels.swift | 32 | 1 | 28 | 3 | 523 |
| ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/SportRadarModels+Events.swift | 26 | 0 | 24 | 2 | 884 |
| Core/Models/Shared/UserRegisterForm.swift | 24 | 0 | 22 | 2 | 387 |
| Extensions/.build/arm64-apple-macosx/debug/ExtensionsPackageTests.derived/runner.swift | 22 | 2 | 17 | 3 | 547 |
| ServicesProvider/.build/arm64-apple-macosx/debug/ServicesProviderPackageTests.derived/runner.swift | 22 | 2 | 17 | 3 | 547 |
| ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/GomaModels+Events.swift | 19 | 0 | 17 | 2 | 864 |
| ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/GomaModels+Social.swift | 19 | 0 | 18 | 1 | 251 |
| Core/Models/App/AppModels.swift | 18 | 0 | 12 | 6 | 496 |
| ServicesProvider/Sources/ServicesProvider/Models/Betting/Betting.swift | 18 | 0 | 13 | 5 | 443 |
| ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/SportRadarModels+Betting.swift | 17 | 0 | 15 | 2 | 605 |
| Scripts/APIDocAnalyzer/Sources/DocGenerator/DocGenerator.swift | 15 | 1 | 13 | 1 | 417 |
| ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/GomaModels+Promotions.swift | 11 | 0 | 11 | 0 | 341 |
| Core/Models/EveryMatrixAPI/Betting/BetslipSelectionState.swift | 10 | 0 | 10 | 0 | 285 |
| ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/GomaModels.swift | 10 | 0 | 8 | 2 | 151 |
| Core/Models/EveryMatrixAPI/Bonus/Bonus.swift | 9 | 0 | 8 | 1 | 143 |
| ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/GomaModels+Tickets.swift | 9 | 0 | 7 | 2 | 410 |
| Core/Tools/Extensions/Date+Extension.swift | 8 | 1 | 0 | 7 | 895 |
| Core/Models/Shared/UserSettingsGoma.swift | 8 | 0 | 6 | 2 | 484 |
| Core/Screens/MatchDetails/MarketGroupOrganizer.swift | 8 | 0 | 8 | 0 | 522 |
| Core/Constants/UserSettings.swift | 7 | 0 | 0 | 7 | 357 |
| Core/Models/URLEndpoints.swift | 7 | 0 | 6 | 1 | 190 |
| ServicesProvider/.build/checkouts/swift-collections/Tests/_CollectionsTestSupport/MinimalTypes/MinimalEncoder.swift | 7 | 5 | 1 | 1 | 717 |
| Core/Tools/ExternalLibs/SwiftyJSON/SwiftyJSON.swift | 6 | 0 | 1 | 5 | 1402 |
| Core/Tools/ExternalLibs/ShiftAnimations/Animations.swift | 6 | 1 | 3 | 2 | 317 |
| Core/Constants/Constants.swift | 6 | 0 | 0 | 6 | 107 |
| Core/Models/App/Match.swift | 6 | 0 | 3 | 3 | 499 |
| Core/Models/App/BetBuilder.swift | 6 | 2 | 1 | 3 | 430 |
| Core/Models/Shared/UploadDocuments.swift | 6 | 0 | 2 | 4 | 235 |
| Core/Models/EveryMatrixAPI/Aggregator.swift | 6 | 0 | 1 | 5 | 339 |
| Core/Models/EveryMatrixAPI/Disciplines/SportsAggregator.swift | 6 | 0 | 1 | 5 | 200 |
| Core/Models/EveryMatrixAPI/Cashouts/CashoutAggregator.swift | 6 | 0 | 1 | 5 | 193 |
| Core/Screens/CompetitionsList/CompetitionsFiltersViewSwiftUI.swift | 6 | 1 | 3 | 2 | 452 |
| Core/Services/UserSessionStore.swift | 6 | 1 | 1 | 4 | 816 |
| ServicesProvider/.build/checkouts/Starscream/Sources/Framer/Framer.swift | 6 | 1 | 1 | 4 | 366 |
| ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/SportRadarModels+PromotedBetslips.swift | 6 | 0 | 6 | 0 | 202 |
| ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/Documents/SportRadarModels+ApplicantDataResponse.swift | 6 | 0 | 6 | 0 | 87 |
| ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/GomaModels+Betting.swift | 6 | 0 | 5 | 1 | 279 |
| ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/GomaModels+FeaturedTips.swift | 6 | 0 | 6 | 0 | 348 |
| ServicesProvider/Sources/ServicesProvider/Models/Payments/TransactionsHistoryResponse.swift | 6 | 0 | 5 | 1 | 128 |
| Core/Tools/ExternalLibs/ShiftAnimations/ShiftViewOptions.swift | 5 | 0 | 1 | 4 | 108 |
| Core/Models/EveryMatrixAPI/Betting/BetslipHistory.swift | 5 | 0 | 3 | 2 | 228 |
| Core/Models/EveryMatrixAPI/Limits/LimitsResponse.swift | 5 | 0 | 4 | 1 | 86 |
| Core/Screens/Home/Views/ViewModels/FeaturedTipCollectionViewModel.swift | 5 | 2 | 0 | 3 | 407 |
| Core/Screens/Social/AddFriend/ViewModels/AddContactViewModel.swift | 5 | 1 | 2 | 2 | 385 |
| Core/Screens/Betslip/PreSubmission/PreSubmissionBetslipViewController.swift | 5 | 1 | 3 | 1 | 2948 |
| Core/Screens/Account/Profile/BettingPractices/BettingPracticesQuestionnaireViewModel.swift | 5 | 1 | 3 | 1 | 181 |
| ServicesProvider/.build/checkouts/swift-collections/Tests/_CollectionsTestSupport/MinimalTypes/MinimalDecoder.swift | 5 | 5 | 0 | 0 | 757 |
| ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/SportRadarModels+Sports.swift | 5 | 0 | 5 | 0 | 139 |
| ServicesProvider/Sources/ServicesProvider/Providers/Goma/APIs/GomaAPISchema.swift | 5 | 0 | 3 | 2 | 1185 |
| ServicesProvider/Sources/ServicesProvider/Models/Content/Promotions/HomeTemplate.swift | 5 | 0 | 2 | 3 | 164 |
| ServicesProvider/Sources/ServicesProvider/Models/User/Documents/ApplicantDataResponse.swift | 5 | 0 | 5 | 0 | 70 |
| ServicesProvider/Sources/ServicesProvider/Models/Common/Subscription.swift | 5 | 2 | 1 | 2 | 365 |
| ServicesProvider/Sources/ServicesProvider/Models/Common/Filters.swift | 5 | 0 | 5 | 0 | 100 |
| EveryMatrixClient/TSLibrary/WAMP/SSWampSession.swift | 4 | 4 | 0 | 0 | 576 |
| Core/Tools/ExternalLibs/ShiftAnimations/DefaultShiftAnimation.swift | 4 | 0 | 2 | 2 | 45 |
| Core/App/Router.swift | 4 | 1 | 0 | 3 | 1018 |
| Core/Models/App/BetslipModels.swift | 4 | 0 | 3 | 1 | 46 |
| Core/Models/EveryMatrixAPI/Transactions/TransactionHistory.swift | 4 | 0 | 4 | 0 | 75 |
| Core/Models/EveryMatrixAPI/Account/UserBalance.swift | 4 | 0 | 4 | 0 | 71 |
| Core/Screens/LiveEvents/LiveEventsViewModel.swift | 4 | 2 | 0 | 2 | 826 |
| Core/Screens/Home/ViewModels/SportMatchLineViewModel.swift | 4 | 1 | 0 | 3 | 441 |
| Core/Screens/PreLive_backup/ViewModels/MatchWidgetCellViewModel.swift | 4 | 1 | 1 | 2 | 563 |
| Core/Screens/PreLive_backup/Cells/MatchLineTableViewCell.swift | 4 | 2 | 1 | 1 | 869 |
| Core/Screens/MatchDetails/MatchDetailsViewController.swift | 4 | 1 | 2 | 1 | 2818 |
| Core/Screens/PreLiveEvents/ViewModels/Match/MatchWidgetCellViewModel.swift | 4 | 1 | 1 | 2 | 563 |
| Core/Screens/PreLiveEvents/Views/Cells/Match/MatchLine/MatchLineTableViewCell.swift | 4 | 2 | 1 | 1 | 869 |
| Core/Screens/Social/Settings/ChatSettingsViewModel.swift | 4 | 1 | 1 | 2 | 123 |
| Core/Screens/Social/AddFriend/AddFriendViewModel.swift | 4 | 1 | 2 | 1 | 268 |
| Core/Screens/Account/Documents/ManualUploadDocumentsViewController.swift | 4 | 1 | 2 | 1 | 1325 |
| Core/Screens/Tips&Rankings/Rankings/ViewModels/RankingsListViewModel.swift | 4 | 1 | 0 | 3 | 253 |
| Core/Views/Chat/ToastCustom.swift | 4 | 3 | 1 | 0 | 194 |
| AdresseFrancaise/Sources/AdresseFrancaise/AdresseFrancaiseClient.swift | 4 | 0 | 3 | 1 | 150 |
| RegisterFlow/Sources/RegisterFlow/Betsson/AdditionalRegisterSteps/LimitsOnRegisterViewController.swift | 4 | 2 | 0 | 2 | 829 |
| RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/ConfirmationCodeFormStepView.swift | 4 | 2 | 1 | 1 | 490 |
| ServicesProvider/.build/checkouts/swift-collections/Tests/HashTreeCollectionsTests/TreeDictionary Tests.swift | 4 | 1 | 3 | 0 | 2622 |
| ServicesProvider/.build/checkouts/swift-collections/Tests/RopeModuleTests/TestRope.swift | 4 | 1 | 3 | 0 | 703 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/InternalCollectionsUtilities/UnsafeBitSet/autogenerated/_UnsafeBitSet.swift | 4 | 0 | 4 | 0 | 969 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/BigString/Basics/BigString+Metrics.swift | 4 | 0 | 4 | 0 | 210 |
| ServicesProvider/.build/checkouts/Starscream/Sources/Framer/HTTPHandler.swift | 4 | 0 | 2 | 2 | 151 |
| ServicesProvider/.build/checkouts/Starscream/Sources/Starscream/WebSocket.swift | 4 | 1 | 1 | 2 | 175 |
| ServicesProvider/Tests/ServicesProviderTests/Providers/Goma/Integration/Helpers/TestConfiguration.swift | 4 | 0 | 4 | 0 | 45 |
| ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/SportRadarConfiguration.swift | 4 | 0 | 2 | 2 | 252 |
| ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/HomeWidgets/PromotedSports.swift | 4 | 0 | 4 | 0 | 117 |
| ServicesProvider/Sources/ServicesProvider/Models/Events/TopCompetitionsResponse.swift | 4 | 0 | 4 | 0 | 64 |
| EveryMatrixClient/AggregatorsRepository.swift | 3 | 1 | 1 | 1 | 522 |
| EveryMatrixClient/EveryMatrixServiceClient.swift | 3 | 1 | 0 | 2 | 349 |
| Core/Tools/Extensions/UIImageView+Extensions.swift | 3 | 0 | 2 | 1 | 378 |
| Core/Tools/ExternalLibs/ShiftAnimations/Animator.swift | 3 | 2 | 0 | 1 | 393 |
| Core/Tools/ExternalLibs/KDCircularProgress/KDCircularProgress.swift | 3 | 2 | 0 | 1 | 557 |
| Core/Models/Shared/DocumentLevelStatus.swift | 3 | 0 | 1 | 2 | 68 |
| Core/Models/GGAPI/SharedBetTicket.swift | 3 | 0 | 3 | 0 | 301 |
| Core/Models/EveryMatrixAPI/MatchOddsContent.swift | 3 | 0 | 1 | 2 | 99 |
| Core/Models/EveryMatrixAPI/Betting/SharedBetData.swift | 3 | 0 | 3 | 0 | 75 |
| Core/Models/EveryMatrixAPI/Search/SearchV2Response.swift | 3 | 0 | 1 | 2 | 107 |
| Core/Models/EveryMatrixAPI/Account/LoginAccount.swift | 3 | 0 | 3 | 0 | 75 |
| Core/Screens/LiveEvents/LiveEventsViewController.swift | 3 | 1 | 2 | 0 | 1052 |
| Core/Screens/Home/HomeViewModel.swift | 3 | 1 | 0 | 2 | 215 |
| Core/Screens/Home/Views/StoriesFullScreenItemView.swift | 3 | 2 | 0 | 1 | 637 |
| Core/Screens/Home/Views/FeaturedTipLineTableViewCell.swift | 3 | 2 | 0 | 1 | 295 |
| Core/Screens/BetslipProxyWebViewController/BetslipProxyWebViewController.swift | 3 | 1 | 2 | 0 | 319 |
| Core/Screens/CompetitionsList/CompetitionFilterCell.swift | 3 | 1 | 2 | 0 | 276 |
| Core/Screens/CompetitionsList/CompetitionSectionHeader.swift | 3 | 1 | 2 | 0 | 213 |
| Core/Screens/CompetitionsList/CompetitionFilterTableViewCell.swift | 3 | 2 | 0 | 1 | 290 |
| Core/Screens/PreLive_backup/ViewModels/PreLiveEventsViewModel.swift | 3 | 1 | 0 | 2 | 837 |
| Core/Screens/PreLive_backup/Cells/LoadingMoreTableViewCell.swift | 3 | 2 | 1 | 0 | 138 |
| Core/Screens/PreLive_backup/Cells/SeeMoreMarketsCollectionViewCell.swift | 3 | 2 | 1 | 0 | 361 |
| Core/Screens/PreLive_backup/Cells/Banner/ViewModel/BannerCellViewModel.swift | 3 | 2 | 0 | 1 | 188 |
| Core/Screens/PreLiveEvents/ViewModels/PreLiveEventsViewModel.swift | 3 | 1 | 0 | 2 | 837 |
| Core/Screens/PreLiveEvents/ViewModels/Banner/BannerCellViewModel.swift | 3 | 2 | 0 | 1 | 188 |
| Core/Screens/PreLiveEvents/Views/Cells/Utility/SeeMoreMarkets/SeeMoreMarketsCollectionViewCell.swift | 3 | 2 | 1 | 0 | 361 |
| Core/Screens/PreLiveEvents/Views/Cells/Utility/LoadingMore/LoadingMoreTableViewCell.swift | 3 | 2 | 1 | 0 | 138 |
| Core/Screens/Social/SocialViewController.swift | 3 | 2 | 0 | 1 | 336 |
| Core/Screens/Social/Conversations/ConversationList/ConversationsViewController.swift | 3 | 1 | 1 | 1 | 521 |
| Core/Screens/Root/RootViewController.swift | 3 | 1 | 0 | 2 | 2239 |
| Core/Screens/Account/Bonus/DataSources/BonusAvailableDataSource.swift | 3 | 1 | 1 | 1 | 113 |
| Core/Screens/Account/Profile/ProfileViewController.swift | 3 | 2 | 0 | 1 | 1142 |
| Core/Screens/Account/Profile/History/BettingHistoryViewModel.swift | 3 | 1 | 0 | 2 | 596 |
| Core/Screens/Account/Profile/History/TransactionsHistoryViewModel.swift | 3 | 1 | 0 | 2 | 684 |
| Core/Screens/Account/Documents/Cells/UploadDocumentTableViewCell.swift | 3 | 2 | 0 | 1 | 326 |
| Core/Screens/MyTickets/ViewModel/MyTicketsViewModel.swift | 3 | 1 | 0 | 2 | 671 |
| Core/Screens/Share/ShareTicketChoiceViewController.swift | 3 | 1 | 2 | 0 | 742 |
| Core/Views/ScoreView.swift | 3 | 2 | 0 | 1 | 494 |
| Core/Views/BonusViews/BonusProgressView.swift | 3 | 1 | 0 | 2 | 235 |
| Core/Views/EditAlertView/EditAlertView.swift | 3 | 1 | 1 | 1 | 126 |
| Core/Views/FlipperView/FlipNumberView.swift | 3 | 3 | 0 | 0 | 413 |
| Core/Views/PictureInPictureView/PictureInPictureView.swift | 3 | 3 | 0 | 0 | 544 |
| Core/Protocols/ClientsProtocols/SportsbookTarget.swift | 3 | 0 | 0 | 3 | 147 |
| Core/Services/FavoritesManager.swift | 3 | 1 | 0 | 2 | 467 |
| Scripts/APIDocAnalyzer/Sources/ModelParser/swift_parser.swift | 3 | 1 | 2 | 0 | 276 |
| RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/AgeCountryFormStepView.swift | 3 | 2 | 0 | 1 | 545 |
| RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/GenderFormStepView.swift | 3 | 2 | 0 | 1 | 303 |
| RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/PasswordFormStepView.swift | 3 | 2 | 0 | 1 | 420 |
| RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/NicknameFormStepView.swift | 3 | 2 | 0 | 1 | 450 |
| RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/AddressFormStepView.swift | 3 | 2 | 1 | 0 | 577 |
| RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Goma/MultibetPasswordFormStepView.swift | 3 | 2 | 0 | 1 | 421 |
| HeaderTextField/Sources/HeaderTextField/HeaderTextFieldView.swift | 3 | 1 | 0 | 2 | 721 |
| ServicesProvider/.build/checkouts/Starscream/Sources/Compression/WSCompression.swift | 3 | 3 | 0 | 0 | 257 |
| ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/SportRadarModels+SocketContent.swift | 3 | 0 | 1 | 2 | 81 |
| ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/HomeWidgets/PromotionalBanners.swift | 3 | 0 | 2 | 1 | 58 |
| ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/Competitions/SportRadarModels+TopCompetitionsResponse.swift | 3 | 0 | 3 | 0 | 44 |
| ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/UserConsents/SportRadarModels+UserConsentsResponse.swift | 3 | 0 | 3 | 0 | 52 |
| ServicesProvider/Sources/ServicesProvider/Providers/Goma/GomaConnector.swift | 3 | 1 | 2 | 0 | 196 |
| ServicesProvider/Sources/ServicesProvider/Providers/Goma/APIs/GomaAPIPromotionsClient.swift | 3 | 2 | 1 | 0 | 230 |
| ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/GomaModels+InitialDump.swift | 3 | 0 | 3 | 0 | 76 |
| ServicesProvider/Sources/ServicesProvider/Models/Betting/PromotedBetslips.swift | 3 | 0 | 3 | 0 | 91 |
| ServicesProvider/Sources/ServicesProvider/Models/Content/CMSInitialDump.swift | 3 | 0 | 3 | 0 | 89 |
| ServicesProvider/Sources/ServicesProvider/Models/Content/HomeWidgets/PromotionalBanner.swift | 3 | 0 | 2 | 1 | 33 |
| ServicesProvider/Sources/ServicesProvider/Models/Social/UserProfileInfo.swift | 3 | 0 | 3 | 0 | 54 |
| ServicesProvider/Sources/ServicesProvider/Models/Events/FeaturedTip.swift | 3 | 0 | 3 | 0 | 67 |
| EveryMatrixClient/TSLibrary/TSManager.swift | 2 | 1 | 0 | 1 | 480 |
| EveryMatrixClient/TSLibrary/WAMP/Transport/WebSocketSSWampTransport.swift | 2 | 1 | 0 | 1 | 133 |
| GomaAssets/Sources/FontRegistration.swift | 2 | 0 | 0 | 2 | 74 |
| GomaAssets/Sources/AppFont.swift | 2 | 0 | 1 | 1 | 36 |
| Core/Tools/ExternalLibs/KeychainExtras/KeychainInterface.swift | 2 | 1 | 0 | 1 | 163 |
| Core/Tools/ExternalLibs/Tabular/TabularBarView.swift | 2 | 1 | 0 | 1 | 272 |
| Core/Tools/ExternalLibs/ShiftAnimations/ViewContext.swift | 2 | 1 | 0 | 1 | 287 |
| Core/Tools/MiscHelpers/RunningPlatform.swift | 2 | 0 | 1 | 1 | 250 |
| Core/Tools/MiscHelpers/Internationalization.swift | 2 | 0 | 1 | 1 | 67 |
| Core/Tools/MiscHelpers/CollectionViewFlowLayouts/CenterCellCollectionViewFlowLayout.swift | 2 | 2 | 0 | 0 | 72 |
| Core/Tools/SwiftUI/XcodePreviewViewController.swift | 2 | 0 | 2 | 0 | 42 |
| Core/Constants/Fonts.swift | 2 | 0 | 1 | 1 | 66 |
| Core/Models/App/SecundaryMarketDetails.swift | 2 | 2 | 0 | 0 | 63 |
| Core/Models/App/PromotedBetslip.swift | 2 | 0 | 2 | 0 | 72 |
| Core/Models/Shared/FirebaseClientSettings.swift | 2 | 0 | 2 | 0 | 180 |
| Core/Models/Shared/Referrals.swift | 2 | 0 | 2 | 0 | 23 |
| Core/Models/Shared/ActivationAlert.swift | 2 | 0 | 1 | 1 | 22 |
| Core/Models/Shared/SuggestedBetSummary.swift | 2 | 0 | 2 | 0 | 171 |
| Core/Models/Shared/PaymentStatus.swift | 2 | 0 | 0 | 2 | 23 |
| Core/Models/EveryMatrixAPI/EveryMatrixModel.swift | 2 | 0 | 1 | 1 | 33 |
| Core/Models/EveryMatrixAPI/Betting/SystemBetResponse.swift | 2 | 0 | 2 | 0 | 30 |
| Core/Models/EveryMatrixAPI/Betting/SharedBetToken.swift | 2 | 0 | 2 | 0 | 32 |
| Core/Models/EveryMatrixAPI/Locations/Location.swift | 2 | 0 | 2 | 0 | 46 |
| Core/Models/EveryMatrixAPI/Odds/Odd.swift | 2 | 0 | 0 | 2 | 64 |
| Core/Models/EveryMatrixAPI/Events/Event.swift | 2 | 0 | 0 | 2 | 54 |
| Core/Screens/TopCompetitionDetails/TopCompetitionDetailsViewModel.swift | 2 | 1 | 0 | 1 | 310 |
| Core/Screens/Filters/CollapsibleView.swift | 2 | 0 | 2 | 0 | 111 |
| Core/Screens/Filters/FilterLineView.swift | 2 | 0 | 2 | 0 | 63 |
| Core/Screens/Filters/CollapsibleGroupView.swift | 2 | 0 | 2 | 0 | 24 |
| Core/Screens/Home/TemplatesDataSources/ClientManagedHomeViewTemplateDataSource.swift | 2 | 1 | 0 | 1 | 1172 |
| Core/Screens/Home/TemplatesDataSources/CMSManagedHomeViewTemplateDataSource.swift | 2 | 1 | 0 | 1 | 1241 |
| Core/Screens/Home/TemplatesDataSources/DummyWidgetShowcaseHomeViewTemplateDataSource.swift | 2 | 1 | 0 | 1 | 1202 |
| Core/Screens/Home/Views/StoriesFullScreenViewController.swift | 2 | 1 | 1 | 0 | 379 |
| Core/Screens/Home/Views/TopCompetitionsLineTableViewCell.swift | 2 | 2 | 0 | 0 | 145 |
| Core/Screens/Home/Views/CompetitionWidgetCollectionViewCell.swift | 2 | 2 | 0 | 0 | 292 |
| Core/Screens/Home/Views/TopCompetitionItemCollectionViewCell.swift | 2 | 1 | 1 | 0 | 193 |
| Core/Screens/Home/Views/StoriesLineTableViewCell.swift | 2 | 2 | 0 | 0 | 132 |
| Core/Screens/Home/Views/VideoPreviewCollectionViewCell.swift | 2 | 2 | 0 | 0 | 206 |
| Core/Screens/Home/Views/VideoPreviewLineTableViewCell.swift | 2 | 2 | 0 | 0 | 229 |
| Core/Screens/Home/Views/StoriesItemCollectionViewCell.swift | 2 | 1 | 1 | 0 | 248 |
| Core/Screens/Home/Views/QuickSwipeStackTableViewCell.swift | 2 | 2 | 0 | 0 | 281 |
| Core/Screens/Home/Views/Cells/FeaturedTipCollectionViewCell.swift | 2 | 1 | 1 | 0 | 678 |
| Core/Screens/RecruitFriend/RecruitAFriendViewController.swift | 2 | 2 | 0 | 0 | 1636 |
| Core/Screens/MyFavorites/MyFavoritesViewController.swift | 2 | 1 | 0 | 1 | 917 |
| Core/Screens/MyFavorites/DataSources/MyFavoriteMatchesDataSource.swift | 2 | 1 | 1 | 0 | 227 |
| Core/Screens/MyFavorites/ViewModels/MyFavoritesViewModel.swift | 2 | 1 | 0 | 1 | 322 |
| Core/Screens/MyFavorites/ViewModels/MyGamesViewModel.swift | 2 | 1 | 0 | 1 | 362 |
| Core/Screens/CompetitionsList/CompetitionFilterHeaderView.swift | 2 | 2 | 0 | 0 | 279 |
| Core/Screens/CompetitionsList/CompetitionsFiltersView.swift | 2 | 1 | 0 | 1 | 780 |
| Core/Screens/AnonymousSideMenu/AnonymousSideMenuViewController.swift | 2 | 1 | 1 | 0 | 566 |
| Core/Screens/PreLive_backup/DataSources/PopularMatchesDataSource.swift | 2 | 1 | 0 | 1 | 455 |
| Core/Screens/PreLive_backup/DataSources/TodayMatchesDataSource.swift | 2 | 1 | 1 | 0 | 497 |
| Core/Screens/PreLive_backup/ViewModels/MatchStatsViewModel.swift | 2 | 1 | 0 | 1 | 56 |
| Core/Screens/PreLive_backup/Cells/ActivationAlertCollectionViewCell.swift | 2 | 1 | 0 | 1 | 205 |
| Core/Screens/PreLive_backup/Cells/MatchWidgetContainerTableViewCell.swift | 2 | 2 | 0 | 0 | 343 |
| Core/Screens/PreLive_backup/Cells/OddCell/OddDoubleCollectionViewCell.swift | 2 | 2 | 0 | 0 | 1052 |
| Core/Screens/PreLive_backup/Cells/OutrightTournaments/OutrightCompetitionLineTableViewCell.swift | 2 | 2 | 0 | 0 | 287 |
| Core/Screens/PreLive_backup/Cells/OutrightTournaments/OutrightCompetitionWidgetCollectionViewCell.swift | 2 | 2 | 0 | 0 | 221 |
| Core/Screens/PreLive_backup/Cells/LargeOutrightTournaments/OutrightCompetitionLargeLineTableViewCell.swift | 2 | 2 | 0 | 0 | 296 |
| Core/Screens/PreLive_backup/Cells/LargeOutrightTournaments/OutrightCompetitionLargeWidgetCollectionViewCell.swift | 2 | 2 | 0 | 0 | 426 |
| Core/Screens/UserTracking/UserTrackingViewController.swift | 2 | 1 | 1 | 0 | 295 |
| Core/Screens/UserTracking/UserTrackingSettingsViewController.swift | 2 | 1 | 1 | 0 | 385 |
| Core/Screens/DebugHelper/DebugUserDefaults.swift | 2 | 0 | 1 | 1 | 42 |
| Core/Screens/MatchDetails/ViewModels/MatchDetailsViewModel.swift | 2 | 1 | 0 | 1 | 546 |
| Core/Screens/MatchDetails/Cells/SimpleListMarketDetailTableViewCell.swift | 2 | 1 | 0 | 1 | 269 |
| Core/Screens/PreLiveEvents/DataSources/Matches/PopularMatchesDataSource.swift | 2 | 1 | 0 | 1 | 455 |
| Core/Screens/PreLiveEvents/DataSources/Matches/TodayMatchesDataSource.swift | 2 | 1 | 1 | 0 | 497 |
| Core/Screens/PreLiveEvents/ViewModels/Match/MatchStatsViewModel.swift | 2 | 1 | 0 | 1 | 56 |
| Core/Screens/PreLiveEvents/Views/Cells/Outright/Large/OutrightCompetitionLargeLineTableViewCell.swift | 2 | 2 | 0 | 0 | 296 |
| Core/Screens/PreLiveEvents/Views/Cells/Outright/Large/OutrightCompetitionLargeWidgetCollectionViewCell.swift | 2 | 2 | 0 | 0 | 426 |
| Core/Screens/PreLiveEvents/Views/Cells/Outright/Standard/OutrightCompetitionLineTableViewCell.swift | 2 | 2 | 0 | 0 | 287 |
| Core/Screens/PreLiveEvents/Views/Cells/Outright/Standard/OutrightCompetitionWidgetCollectionViewCell.swift | 2 | 2 | 0 | 0 | 221 |
| Core/Screens/PreLiveEvents/Views/Cells/Match/MatchWidget/MatchWidgetContainerTableViewCell.swift | 2 | 2 | 0 | 0 | 343 |
| Core/Screens/PreLiveEvents/Views/Cells/Match/Odds/OddDoubleCollectionViewCell.swift | 2 | 2 | 0 | 0 | 1052 |
| Core/Screens/PreLiveEvents/Views/Cells/Activation/ActivationAlertCell/ActivationAlertCollectionViewCell.swift | 2 | 1 | 0 | 1 | 205 |
| Core/Screens/Search/SearchViewModel.swift | 2 | 1 | 1 | 0 | 308 |
| Core/Screens/Social/Conversations/BetTicketShare/Cells/BetSelectionStateTableViewCell.swift | 2 | 1 | 0 | 1 | 481 |
| Core/Screens/Social/Conversations/ConversationList/ViewModels/ConversationsViewModel.swift | 2 | 1 | 0 | 1 | 357 |
| Core/Screens/Social/Notifications/Cells/UserNotificationTableViewCell.swift | 2 | 2 | 0 | 0 | 224 |
| Core/Screens/Social/Notifications/Cells/UserNotificationInviteTableViewCell.swift | 2 | 2 | 0 | 0 | 299 |
| Core/Screens/Social/Edits/ViewModels/EditGroupViewModel.swift | 2 | 1 | 1 | 0 | 204 |
| Core/Screens/Quickbet/QuickBetViewController.swift | 2 | 1 | 0 | 1 | 1069 |
| Core/Screens/SimpleCompetitionDetails/SimpleCompetitionDetailsViewModel.swift | 2 | 1 | 0 | 1 | 228 |
| Core/Screens/UserProfile/UserProfileViewController.swift | 2 | 1 | 0 | 1 | 676 |
| Core/Screens/Betslip/BetslipViewController.swift | 2 | 1 | 0 | 1 | 266 |
| Core/Screens/Betslip/PreSubmission/PreSubmissionBetslipViewModel.swift | 2 | 1 | 1 | 0 | 225 |
| Core/Screens/Betslip/SuggestedBets/SuggestedBetsListViewController.swift | 2 | 2 | 0 | 0 | 323 |
| Core/Screens/Betslip/SuggestedBets/SuggestedBetTableViewCell.swift | 2 | 2 | 0 | 0 | 344 |
| Core/Screens/Account/Bonus/BonusViewModel.swift | 2 | 1 | 0 | 1 | 243 |
| Core/Screens/Account/Bonus/BonusRootViewController.swift | 2 | 2 | 0 | 0 | 651 |
| Core/Screens/Account/Payments/PaymentsViewController.swift | 2 | 2 | 0 | 0 | 369 |
| Core/Screens/Account/Messages/PromotionsWebViewController.swift | 2 | 2 | 0 | 0 | 325 |
| Core/Screens/Account/Messages/MessageDetailWebViewController.swift | 2 | 2 | 0 | 0 | 280 |
| Core/Screens/Account/Messages/Cells/InAppMessageTableViewCell.swift | 2 | 1 | 0 | 1 | 409 |
| Core/Screens/Account/VerificationCode/EmailVerificationCodeViewController.swift | 2 | 2 | 0 | 0 | 453 |
| Core/Screens/Account/VerificationCode/CodeVerificationViewController.swift | 2 | 2 | 0 | 0 | 475 |
| Core/Screens/Account/Register/SimpleRegister/SimpleRegisterEmailCheckViewModel.swift | 2 | 1 | 0 | 1 | 115 |
| Core/Screens/Account/Profile/CloseAccount/CloseAccountViewController.swift | 2 | 2 | 0 | 0 | 335 |
| Core/Screens/Account/Profile/History/FilterHistoryViewModel.swift | 2 | 1 | 0 | 1 | 86 |
| Core/Screens/Account/Profile/History/TransactionsHistoryRootViewController.swift | 2 | 2 | 0 | 0 | 605 |
| Core/Screens/Account/Profile/History/BettingHistoryRootViewController.swift | 2 | 2 | 0 | 0 | 553 |
| Core/Screens/Account/Profile/PasswordUpdate/PasswordUpdateViewModel.swift | 2 | 1 | 0 | 1 | 150 |
| Core/Screens/Account/Profile/LimitsManagement/ProfileLimitsManagementViewModel.swift | 2 | 1 | 0 | 1 | 671 |
| Core/Screens/Account/Profile/LimitsManagement/ProfileLimitsManagementViewController.swift | 2 | 1 | 0 | 1 | 911 |
| Core/Screens/Account/AppSettings/Tips/TipsSettingsViewController.swift | 2 | 2 | 0 | 0 | 258 |
| Core/Screens/Account/AppSettings/Notifications/ViewModels/BettingNotificationViewModel.swift | 2 | 1 | 0 | 1 | 89 |
| Core/Screens/Account/AppSettings/Notifications/ViewModels/GamesNotificationViewModel.swift | 2 | 1 | 0 | 1 | 130 |
| Core/Screens/MyTickets/MyTicketsRootViewController.swift | 2 | 2 | 0 | 0 | 450 |
| Core/Screens/MyTickets/ViewModel/MyTicketCellViewModel.swift | 2 | 1 | 0 | 1 | 268 |
| Core/Screens/CompetitionDetails/CompetitionDetailsViewModel.swift | 2 | 1 | 0 | 1 | 128 |
| Core/Screens/Tips&Rankings/ViewModels/TipsSliderViewModel.swift | 2 | 1 | 0 | 1 | 98 |
| Core/Screens/Tips&Rankings/Rankings/Cells/ViewModels/RankingCellViewModel.swift | 2 | 1 | 1 | 0 | 44 |
| Core/Screens/Tips&Rankings/Tips/ViewModels/TipsListViewModel.swift | 2 | 1 | 0 | 1 | 352 |
| Core/Screens/Share/Cells/SocialAppItemCollectionViewCell.swift | 2 | 1 | 1 | 0 | 213 |
| Core/Screens/Share/Cells/SelectChatroomTableViewCell.swift | 2 | 2 | 0 | 0 | 484 |
| Core/Screens/Share/Cells/SocialItemCollectionViewCell.swift | 2 | 1 | 1 | 0 | 299 |
| Core/Views/SmoothProgressBarView.swift | 2 | 2 | 0 | 0 | 218 |
| Core/Views/BoostedArrowView.swift | 2 | 2 | 0 | 0 | 126 |
| Core/Views/ContainerViewController.swift | 2 | 1 | 0 | 1 | 56 |
| Core/Views/HeaderTextFieldView/HeaderTextFieldView.swift | 2 | 1 | 0 | 1 | 658 |
| Core/Views/BetslipErrorView/BetslipErrorView.swift | 2 | 1 | 0 | 1 | 92 |
| Core/Views/SmallToolTipView/SmallToolTipViewModel.swift | 2 | 1 | 0 | 1 | 23 |
| Core/Views/ChipsTypeView/ChipsTypeViewModel.swift | 2 | 1 | 0 | 1 | 76 |
| Core/Views/UserInfo/UserInfoSimpleCardView.swift | 2 | 1 | 0 | 1 | 154 |
| Core/Views/DropDownSelectionView/HeaderDropDownSelectionView.swift | 2 | 1 | 0 | 1 | 496 |
| Core/Views/DropDownSelectionView/DropDownSelectionView.swift | 2 | 1 | 0 | 1 | 400 |
| Core/Views/UploadDocuments/DocumentView.swift | 2 | 1 | 0 | 1 | 649 |
| Core/Views/FilterRowView/FilterRowView.swift | 2 | 1 | 0 | 1 | 152 |
| Core/Views/Questions/TripleAnswerQuestionView.swift | 2 | 1 | 0 | 1 | 346 |
| Core/Services/_SportTypeStore.swift | 2 | 1 | 1 | 0 | 200 |
| Core/Services/AppSession.swift | 2 | 1 | 1 | 0 | 71 |
| Core/Services/GeoLocationManager.swift | 2 | 1 | 0 | 1 | 169 |
| Core/Services/RealtimeSocketClient.swift | 2 | 1 | 0 | 1 | 114 |
| Core/Services/Networking/Definitions/NetworkModels.swift | 2 | 0 | 2 | 0 | 37 |
| Core/Services/Networking/Definitions/Authenticator.swift | 2 | 1 | 0 | 1 | 169 |
| Core/Services/Networking/Definitions/NetworkError.swift | 2 | 0 | 1 | 1 | 22 |
| Core/Services/Networking/Definitions/Endpoint.swift | 2 | 0 | 1 | 1 | 68 |
| Core/Services/Networking/Goma/GomaGamingSocialServiceClient.swift | 2 | 1 | 0 | 1 | 754 |
| Core/Services/Helpers/Logger.swift | 2 | 1 | 0 | 1 | 141 |
| Core/Services/Helpers/AnalyticsClient.swift | 2 | 0 | 1 | 1 | 155 |
| Core/Services/Helpers/CurrencyHelper.swift | 2 | 0 | 1 | 1 | 122 |
| Core/Services/Helpers/OddFormatter.swift | 2 | 0 | 1 | 1 | 105 |
| Theming/Sources/AppFont.swift | 2 | 0 | 1 | 1 | 48 |
| RegisterFlow/Sources/RegisterFlow/RegisterFlow.swift | 2 | 0 | 1 | 1 | 9 |
| RegisterFlow/Sources/RegisterFlow/Shared/RegisterStepView.swift | 2 | 1 | 1 | 0 | 197 |
| RegisterFlow/Sources/RegisterFlow/Shared/AvatarAssets.swift | 2 | 0 | 0 | 2 | 53 |
| RegisterFlow/Sources/RegisterFlow/Betsson/UserRegisterEnvelop.swift | 2 | 0 | 1 | 1 | 407 |
| RegisterFlow/Sources/RegisterFlow/Betsson/SteppedRegistrationViewController.swift | 2 | 2 | 0 | 0 | 1085 |
| RegisterFlow/Sources/RegisterFlow/Betsson/AdditionalRegisterSteps/RegisterFeedbackViewController.swift | 2 | 1 | 1 | 0 | 198 |
| RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/PromoCodeFormStepView.swift | 2 | 2 | 0 | 0 | 171 |
| RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/TermsCondFormStepView.swift | 2 | 2 | 0 | 0 | 256 |
| RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/NamesFormStepView.swift | 2 | 1 | 1 | 0 | 338 |
| RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/AvatarFormStepView.swift | 2 | 2 | 0 | 0 | 397 |
| RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/ContactsFormStepView.swift | 2 | 2 | 0 | 0 | 571 |
| RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Goma/MultibetPersonalInfoFormStepView.swift | 2 | 2 | 0 | 0 | 411 |
| RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Goma/MultibetAvatarFormStepView.swift | 2 | 2 | 0 | 0 | 401 |
| HeaderTextField/Sources/CurrencyFormater.swift | 2 | 0 | 1 | 1 | 96 |
| ServicesProvider/.build/checkouts/swift-collections/Package.swift | 2 | 0 | 1 | 1 | 311 |
| ServicesProvider/.build/checkouts/swift-collections/Tests/HashTreeCollectionsTests/Utilities.swift | 2 | 0 | 2 | 0 | 234 |
| ServicesProvider/.build/checkouts/swift-collections/Tests/HashTreeCollectionsTests/Colliders.swift | 2 | 0 | 2 | 0 | 99 |
| ServicesProvider/.build/checkouts/swift-collections/Tests/HashTreeCollectionsTests/TreeHashedCollections Fixtures.swift | 2 | 0 | 1 | 1 | 472 |
| ServicesProvider/.build/checkouts/swift-collections/Tests/OrderedCollectionsTests/OrderedDictionary/OrderedDictionary Tests.swift | 2 | 1 | 1 | 0 | 1367 |
| ServicesProvider/.build/checkouts/swift-collections/Tests/OrderedCollectionsTests/OrderedSet/OrderedSet Diffing Tests.swift | 2 | 2 | 0 | 0 | 148 |
| ServicesProvider/.build/checkouts/swift-collections/Tests/OrderedCollectionsTests/OrderedSet/OrderedSetTests.swift | 2 | 1 | 1 | 0 | 1568 |
| ServicesProvider/.build/checkouts/swift-collections/Tests/HeapTests/HeapTests.swift | 2 | 1 | 1 | 0 | 591 |
| ServicesProvider/.build/checkouts/swift-collections/Tests/_CollectionsTestSupport/AssertionContexts/TestContext.swift | 2 | 1 | 1 | 0 | 260 |
| ServicesProvider/.build/checkouts/swift-collections/Tests/_CollectionsTestSupport/Utilities/IndexRangeCollection.swift | 2 | 0 | 2 | 0 | 91 |
| ServicesProvider/.build/checkouts/swift-collections/Tests/_CollectionsTestSupport/MinimalTypes/_CollectionState.swift | 2 | 1 | 0 | 1 | 242 |
| ServicesProvider/.build/checkouts/swift-collections/Tests/_CollectionsTestSupport/MinimalTypes/MinimalSequence.swift | 2 | 0 | 1 | 1 | 97 |
| ServicesProvider/.build/checkouts/swift-collections/Tests/_CollectionsTestSupport/MinimalTypes/MinimalIterator.swift | 2 | 1 | 1 | 0 | 55 |
| ServicesProvider/.build/checkouts/swift-collections/Tests/DequeTests/DequeTests.swift | 2 | 1 | 1 | 0 | 378 |
| ServicesProvider/.build/checkouts/swift-collections/Benchmarks/Sources/Benchmarks/CustomGenerators.swift | 2 | 1 | 1 | 0 | 71 |
| ServicesProvider/.build/checkouts/swift-collections/Benchmarks/Sources/Benchmarks/BigStringBenchmarks.swift | 2 | 0 | 2 | 0 | 109 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/OrderedCollections/OrderedDictionary/OrderedDictionary+Elements.SubSequence.swift | 2 | 0 | 2 | 0 | 356 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/OrderedCollections/HashTable/_HashTable.swift | 2 | 1 | 1 | 0 | 203 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/InternalCollectionsUtilities/UnsafeBitSet/autogenerated/_UnsafeBitSet+Index.swift | 2 | 0 | 2 | 0 | 185 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/InternalCollectionsUtilities/UnsafeBitSet/autogenerated/_UnsafeBitSet+_Word.swift | 2 | 0 | 2 | 0 | 644 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/DequeModule/_UnsafeWrappedBuffer.swift | 2 | 0 | 2 | 0 | 240 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/BigString/Basics/BigString.swift | 2 | 0 | 2 | 0 | 34 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/BigString/Views/BigString+UnicodeScalarView.swift | 2 | 0 | 2 | 0 | 399 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/BigString/Views/BigString+UTF8View.swift | 2 | 0 | 2 | 0 | 189 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/BigString/Views/BigSubstring+UnicodeScalarView.swift | 2 | 0 | 2 | 0 | 325 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/BigString/Views/BigSubstring.swift | 2 | 0 | 2 | 0 | 373 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/BigString/Views/BigSubstring+UTF16View.swift | 2 | 0 | 2 | 0 | 204 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/BigString/Views/BigString+UTF16View.swift | 2 | 0 | 2 | 0 | 153 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/BigString/Views/BigSubstring+UTF8View.swift | 2 | 0 | 2 | 0 | 178 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/Rope/Basics/Rope+_Storage.swift | 2 | 1 | 1 | 0 | 59 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/Rope/Basics/Rope+_Node.swift | 2 | 0 | 2 | 0 | 619 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/BitCollections/BitArray/BitArray+ChunkedBitsIterators.swift | 2 | 0 | 2 | 0 | 101 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/HashTreeCollections/HashNode/_HashTreeIterator.swift | 2 | 0 | 2 | 0 | 132 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/HashTreeCollections/HashNode/_HashNode+Builder.swift | 2 | 0 | 1 | 1 | 361 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/HashTreeCollections/HashNode/_Bitmap.swift | 2 | 0 | 2 | 0 | 222 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/HashTreeCollections/HashNode/_HashNode+Subtree Modify.swift | 2 | 0 | 2 | 0 | 273 |
| ServicesProvider/.build/checkouts/swift-collections/Sources/HashTreeCollections/TreeDictionary/TreeDictionary+Values.swift | 2 | 0 | 2 | 0 | 165 |
| ServicesProvider/.build/checkouts/Starscream/Tests/MockTransport.swift | 2 | 2 | 0 | 0 | 80 |
| ServicesProvider/.build/checkouts/Starscream/Tests/MockServer.swift | 2 | 2 | 0 | 0 | 145 |
| ServicesProvider/.build/checkouts/Starscream/Sources/Transport/FoundationTransport.swift | 2 | 1 | 0 | 1 | 219 |
| ServicesProvider/.build/checkouts/Starscream/Sources/Transport/TCPTransport.swift | 2 | 1 | 0 | 1 | 172 |
| ServicesProvider/.build/checkouts/Starscream/Sources/Security/Security.swift | 2 | 0 | 0 | 2 | 46 |
| ServicesProvider/.build/checkouts/Starscream/Sources/Security/FoundationSecurity.swift | 2 | 1 | 0 | 1 | 100 |
| ServicesProvider/.build/checkouts/Starscream/Sources/Server/Server.swift | 2 | 0 | 0 | 2 | 57 |
| ServicesProvider/.build/checkouts/Starscream/Sources/Server/WebSocketServer.swift | 2 | 2 | 0 | 0 | 199 |
| ServicesProvider/.build/checkouts/Starscream/Sources/Framer/FrameCollector.swift | 2 | 1 | 0 | 1 | 108 |
| ServicesProvider/Tests/ServicesProviderTests/Providers/Sportsradar/APIs/Events-Poseidon/SportsMergerTests.swift | 2 | 2 | 0 | 0 | 383 |
| ServicesProvider/Tests/ServicesProviderTests/Providers/Goma/Integration/Helpers/JSONLoader.swift | 2 | 1 | 0 | 1 | 98 |
| ServicesProvider/Sources/ServicesProvider/ServiceProviderClient.swift | 2 | 1 | 0 | 1 | 1928 |
| ServicesProvider/Sources/ServicesProvider/ServicesProviderConfiguration.swift | 2 | 0 | 1 | 1 | 27 |
| ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/SportRadarSessionCoordinator.swift | 2 | 1 | 0 | 1 | 71 |
| ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/APIs/PAM-Omega/OmegaSession.swift | 2 | 0 | 2 | 0 | 20 |
| ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/SportRadarModels+Scores.swift | 2 | 0 | 0 | 2 | 177 |
| ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/SportRadarModels+Transactions.swift | 2 | 0 | 2 | 0 | 101 |
| ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/HomeWidgets/HeadlineResponse.swift | 2 | 0 | 2 | 0 | 84 |
| ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/Limits/SportRadarModels+ResponsibleGamingLimitsResponse.swift | 2 | 0 | 2 | 0 | 42 |
| ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/PromotionStories/SportRadarModels+PromotionalStoriesResponse.swift | 2 | 0 | 2 | 0 | 46 |
| ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/Withdrawals/SportRadarModels+ProcessWithdrawalResponse.swift | 2 | 0 | 2 | 0 | 39 |
| ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/GomaModels+Users.swift | 2 | 0 | 2 | 0 | 195 |
| ServicesProvider/Sources/ServicesProvider/Network/HTTPTypes.swift | 2 | 0 | 1 | 1 | 35 |
| ServicesProvider/Sources/ServicesProvider/Network/WebSocketClientStream.swift | 2 | 1 | 0 | 1 | 123 |
| ServicesProvider/Sources/ServicesProvider/Models/Payments/Transactions/TransactionTypes.swift | 2 | 0 | 0 | 2 | 95 |
| ServicesProvider/Sources/ServicesProvider/Models/Payments/Withdrawals/ProcessWithdrawalResponse.swift | 2 | 0 | 2 | 0 | 35 |
| ServicesProvider/Sources/ServicesProvider/Models/Content/HomeWidgets/PromotedSport.swift | 2 | 0 | 2 | 0 | 50 |
| ServicesProvider/Sources/ServicesProvider/Models/Content/Promotions/ProChoice.swift | 2 | 0 | 2 | 0 | 68 |
| ServicesProvider/Sources/ServicesProvider/Models/Content/PromotionStories/PromotionalStoriesResponse.swift | 2 | 0 | 2 | 0 | 37 |
| ServicesProvider/Sources/ServicesProvider/Models/User/UserConsents/UserConsentInfo.swift | 2 | 0 | 2 | 0 | 32 |
| ServicesProvider/Sources/ServicesProvider/Models/Common/ResponsibleGamingLimitsResponse.swift | 2 | 0 | 2 | 0 | 39 |
| ServicesProvider/Sources/ServicesProvider/Models/Events/SportType.swift | 2 | 0 | 1 | 1 | 1044 |

## Detailed Breakdown of Files with Multiple Declarations

### Scripts/APIDocAnalyzer/manual_missing_models.swift

**Classes:**

- `SignUpForm` (line 302, public)
- `HighlightMarket` (line 869, public)

**Structs:**

- `UsernameValidation` (line 2, public)
- `DocumentTypesResponse` (line 9, public)
- `UserWallet` (line 19, public)
- `UserOverview` (line 108, public)
- `UserProfile` (line 146, public)
- `SimpleSignUpForm` (line 279, public)
- `SignUpResponse` (line 384, public)
- `SignUpError` (line 386, public)
- `UpdateUserProfileForm` (line 401, public)
- `UserWallet` (line 446, public)
- `UsernameValidation` (line 501, public)
- `DocumentTypesResponse` (line 508, public)
- `DocumentType` (line 518, public)
- `UserDocumentsResponse` (line 559, public)
- `UserDocument` (line 569, public)
- `UserDocumentFile` (line 585, public)
- `UploadDocumentResponse` (line 593, public)
- `PaymentsResponse` (line 603, public)
- `DepositMethod` (line 613, public)
- `PaymentMethod` (line 625, public)
- `SimplePaymentMethodsResponse` (line 637, public)
- `SimplePaymentMethod` (line 643, public)
- `ProcessDepositResponse` (line 653, public)
- `UpdatePaymentResponse` (line 673, public)
- `UpdatePaymentAction` (line 683, public)
- `PersonalDepositLimitResponse` (line 697, public)
- `LimitsResponse` (line 720, public)
- `LimitPending` (line 737, public)
- `Limit` (line 749, public)
- `LimitInfo` (line 761, public)
- `BasicResponse` (line 775, public)
- `MobileVerifyResponse` (line 785, public)
- `PaymentStatusResponse` (line 798, public)
- `SupportResponse` (line 812, public)
- `SupportRequest` (line 824, public)
- `PasswordPolicy` (line 834, public)
- `ConsentInfo` (line 845, public)
- `UserConsentInfo` (line 858, public)
- `Country` (line 891, public)
- `ConsentInfo` (line 917, public)
- `HeroGameEvent` (line 966, public)

**Enums:**

- `KnowYourClientStatus` (line 74, public)
- `UserVerificationStatus` (line 81, public)
- `EmailVerificationStatus` (line 86, public)
- `UserRegistrationStatus` (line 91, public)
- `KnowYourCustomerStatus` (line 97, public)
- `LockedStatus` (line 103, public)
- `DocumentTypeGroup` (line 535, public)
- `Score` (line 930, public)
- `ActivePlayerServe` (line 961, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/User/User.swift

**Classes:**

- `SignUpForm` (line 258, public)

**Structs:**

- `UserOverview` (line 45, public)
- `UserProfile` (line 83, public)
- `LoginResponse` (line 217, public)
- `LogoutResponse` (line 227, public)
- `SimpleSignUpForm` (line 235, public)
- `SignUpResponse` (line 340, public)
- `SignUpError` (line 342, public)
- `DetailedSignUpResponse` (line 357, public)
- `SignUpError` (line 370, public)
- `SignUpUserData` (line 375, public)
- `UpdateUserProfileForm` (line 391, public)
- `UserWallet` (line 441, public)
- `UsernameValidation` (line 496, public)
- `DocumentTypesResponse` (line 503, public)
- `DocumentType` (line 513, public)
- `UserDocumentsResponse` (line 554, public)
- `UserDocument` (line 564, public)
- `UserDocumentFile` (line 580, public)
- `UploadDocumentResponse` (line 588, public)
- `PaymentsResponse` (line 598, public)
- `DepositMethod` (line 608, public)
- `PaymentMethod` (line 620, public)
- `SimplePaymentMethodsResponse` (line 632, public)
- `SimplePaymentMethod` (line 638, public)
- `ProcessDepositResponse` (line 648, public)
- `UpdatePaymentResponse` (line 668, public)
- `UpdatePaymentAction` (line 678, public)
- `PersonalDepositLimitResponse` (line 692, public)
- `LimitsResponse` (line 715, public)
- `LimitPending` (line 732, public)
- `Limit` (line 744, public)
- `LimitInfo` (line 756, public)
- `BasicMessageResponse` (line 771, public)
- `BasicResponse` (line 779, public)
- `MobileVerifyResponse` (line 789, public)
- `PaymentStatusResponse` (line 802, public)
- `SupportResponse` (line 816, public)
- `SupportRequest` (line 828, public)
- `PasswordPolicy` (line 838, public)
- `UserNotificationsSettings` (line 848, public)

**Enums:**

- `KnowYourClientStatus` (line 11, public)
- `UserVerificationStatus` (line 18, public)
- `EmailVerificationStatus` (line 23, public)
- `UserRegistrationStatus` (line 28, public)
- `KnowYourCustomerStatus` (line 34, public)
- `LockedStatus` (line 40, public)
- `DocumentTypeGroup` (line 530, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/Events/Events.swift

**Classes:**

- `EventMetadataPointer` (line 12, public)
- `EventGroupPointer` (line 30, public)
- `EventsGroup` (line 44, public)
- `Event` (line 77, public)
- `HighlightMarket` (line 267, public)
- `ImageHighlightedContent` (line 291, public)
- `Market` (line 320, public)
- `Outcome` (line 481, public)

**Structs:**

- `EventLiveData` (line 574, public)
- `FieldWidget` (line 652, public)
- `MarketGroupPointer` (line 662, public)
- `AvailableMarket` (line 669, public)
- `MarketGroup` (line 676, public)
- `FieldWidgetRenderData` (line 690, public)
- `SportNodeInfo` (line 705, public)
- `SportRegion` (line 729, public)
- `SportRegionInfo` (line 744, public)
- `SportCompetition` (line 756, public)
- `SportCompetitionInfo` (line 770, public)
- `SportCompetitionMarketGroup` (line 787, public)
- `BannerResponse` (line 797, public)
- `EventBanner` (line 806, public)
- `FavoritesListResponse` (line 831, public)
- `FavoriteList` (line 839, public)
- `FavoritesListAddResponse` (line 851, public)
- `FavoritesListDeleteResponse` (line 859, public)
- `FavoriteAddResponse` (line 867, public)
- `FavoriteEventResponse` (line 877, public)
- `FavoriteEvent` (line 885, public)
- `HighlightedEventPointer` (line 900, public)
- `Stats` (line 916, public)
- `ParticipantStats` (line 921, public)
- `HeroGameEvent` (line 966, public)

**Enums:**

- `EventType` (line 56, public)
- `EventStatus` (line 61, public)
- `OutcomesOrder` (line 322, public)
- `FieldWidgetRenderDataType` (line 695, public)
- `StatsWidgetRenderDataType` (line 700, public)
- `Score` (line 930, public)
- `ActivePlayerServe` (line 961, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/SportRadarModels+User.swift

**Structs:**

- `LoginResponse` (line 12, internal)
- `KYCStatusDetail` (line 35, internal)
- `OpenSessionResponse` (line 52, internal)
- `PlayerInfoResponse` (line 57, internal)
- `ExtraInfo` (line 195, internal)
- `CheckCredentialResponse` (line 342, public)
- `GetCountriesResponse` (line 360, internal)
- `GetCountryInfoResponse` (line 370, internal)
- `CountryInfo` (line 381, internal)
- `BalanceResponse` (line 397, internal)
- `StatusResponse` (line 430, internal)
- `FieldError` (line 442, internal)
- `CheckUsernameResponse` (line 452, internal)
- `CheckUsernameAdditionalInfo` (line 466, internal)
- `CheckUsernameError` (line 483, internal)
- `DocumentTypesResponse` (line 518, internal)
- `DocumentType` (line 528, internal)
- `UserDocumentsResponse` (line 544, internal)
- `UserDocument` (line 554, internal)
- `UserDocumentFile` (line 570, internal)
- `UploadDocumentResponse` (line 578, internal)
- `PaymentsResponse` (line 588, internal)
- `DepositMethod` (line 598, internal)
- `PaymentMethod` (line 610, internal)
- `ProcessDepositResponse` (line 621, internal)
- `UpdatePaymentResponse` (line 641, internal)
- `UpdatePaymentAction` (line 651, internal)
- `PersonalDepositLimitResponse` (line 665, internal)
- `LimitsResponse` (line 688, internal)
- `LimitPending` (line 705, internal)
- `BasicResponse` (line 717, internal)
- `MobileVerifyResponse` (line 728, internal)
- `PaymentStatusResponse` (line 740, internal)
- `SupportResponse` (line 754, internal)
- `SupportRequest` (line 766, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/GGAPI/SocialModels.swift

**Classes:**

- `FeaturedTipSelection` (line 327, internal)

**Structs:**

- `GomaFriend` (line 10, internal)
- `ChatroomData` (line 24, internal)
- `Chatroom` (line 34, internal)
- `ChatroomId` (line 48, internal)
- `GomaContact` (line 56, internal)
- `SearchUser` (line 66, internal)
- `MessageData` (line 78, internal)
- `DateMessages` (line 94, internal)
- `ChatMessagesResponse` (line 99, internal)
- `ChatMessage` (line 107, internal)
- `ChatUsersResponse` (line 140, internal)
- `ChatOnlineUsersResponse` (line 150, internal)
- `AddFriendResponse` (line 158, internal)
- `ChatNotification` (line 166, internal)
- `NotificationUser` (line 201, internal)
- `SocialAppInfo` (line 238, internal)
- `InAppMessage` (line 244, internal)
- `FeaturedTip` (line 277, internal)
- `ExtraSelectionInfo` (line 397, internal)
- `OutcomeEntity` (line 410, internal)
- `RankingTip` (line 421, internal)
- `Follower` (line 435, internal)
- `UsersFollowedResponse` (line 452, internal)
- `UserProfileInfo` (line 460, internal)
- `UserProfileRanking` (line 475, internal)
- `UserProfileSportsData` (line 488, internal)
- `FriendRequest` (line 498, internal)
- `UserConnection` (line 510, internal)

**Enums:**

- `CodignKeys` (line 71, internal)
- `MessageType` (line 87, internal)
- `NotificationsType` (line 220, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/SportRadarModels+Events.swift

**Structs:**

- `SportRadarResponse` (line 12, internal)
- `EventsGroup` (line 23, internal)
- `MarketGroup` (line 38, internal)
- `Event` (line 78, internal)
- `Market` (line 294, internal)
- `Outcome` (line 539, internal)
- `SportNodeInfo` (line 618, internal)
- `SportRegion` (line 642, internal)
- `SportRegionInfo` (line 656, internal)
- `SportCompetition` (line 668, internal)
- `SportCompetitionInfo` (line 683, internal)
- `SportCompetitionMarketGroup` (line 712, internal)
- `CompetitionMarketGroup` (line 722, internal)
- `CompetitionParentNode` (line 734, internal)
- `BannerResponse` (line 747, internal)
- `Banner` (line 755, internal)
- `FavoritesListResponse` (line 778, internal)
- `FavoriteList` (line 786, internal)
- `FavoritesListAddResponse` (line 798, internal)
- `FavoritesListDeleteResponse` (line 806, internal)
- `FavoriteAddResponse` (line 814, internal)
- `FavoriteEventResponse` (line 824, internal)
- `FavoriteEvent` (line 832, internal)
- `HighlightedEventPointer` (line 847, internal)

**Enums:**

- `EventStatus` (line 53, internal)
- `OutcomesOrder` (line 296, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/Shared/UserRegisterForm.swift

**Structs:**

- `UserRegisterForm` (line 10, internal)
- `FullRegisterUserForm` (line 20, internal)
- `ServiceProviderSimpleRegisterForm` (line 39, internal)
- `SimpleRegisterForm` (line 53, internal)
- `BetslipTicketSelection` (line 65, internal)
- `CompleteRegisterForm` (line 118, internal)
- `EmailAvailability` (line 122, internal)
- `UsernameAvailability` (line 135, internal)
- `RegistrationResponse` (line 147, internal)
- `CountryListing` (line 159, internal)
- `Country` (line 169, internal)
- `UserProfileField` (line 185, internal)
- `UserProfile` (line 207, internal)
- `ProfileForm` (line 251, internal)
- `ProfileUpdateResponse` (line 272, internal)
- `PasswordPolicy` (line 276, internal)
- `PasswordChange` (line 286, internal)
- `UserMetadata` (line 294, internal)
- `UserMetadataRecords` (line 302, internal)
- `ProfileStatus` (line 312, internal)
- `BetBuilderGrayoutsState` (line 322, internal)
- `BetslipTicketPointer` (line 375, internal)

**Enums:**

- `BetslipSubmitionType` (line 75, internal)
- `MyTicketsType` (line 89, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Extensions/.build/arm64-apple-macosx/debug/ExtensionsPackageTests.derived/runner.swift

**Classes:**

- `SwiftPMXCTestObserver` (line 9, public)
- `FileLock` (line 127, public)

**Structs:**

- `TestEventRecord` (line 229, internal)
- `TestAttachment` (line 254, internal)
- `TestBundleEventRecord` (line 261, internal)
- `TestCaseEventRecord` (line 266, internal)
- `TestCaseFailureRecord` (line 271, internal)
- `TestSuiteEventRecord` (line 281, internal)
- `TestSuiteFailureRecord` (line 286, internal)
- `TestBundle` (line 294, internal)
- `TestCase` (line 299, internal)
- `TestErrorInfo` (line 303, internal)
- `TestIssue` (line 325, internal)
- `TestLocation` (line 344, internal)
- `TestSourceCodeContext` (line 353, internal)
- `TestSourceCodeFrame` (line 362, internal)
- `TestSourceCodeSymbolInfo` (line 368, internal)
- `TestSuiteRecord` (line 374, internal)
- `Runner` (line 509, internal)

**Enums:**

- `TestEvent` (line 308, internal)
- `TestFailureKind` (line 313, internal)
- `TestIssueType` (line 334, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/arm64-apple-macosx/debug/ServicesProviderPackageTests.derived/runner.swift

**Classes:**

- `SwiftPMXCTestObserver` (line 9, public)
- `FileLock` (line 127, public)

**Structs:**

- `TestEventRecord` (line 229, internal)
- `TestAttachment` (line 254, internal)
- `TestBundleEventRecord` (line 261, internal)
- `TestCaseEventRecord` (line 266, internal)
- `TestCaseFailureRecord` (line 271, internal)
- `TestSuiteEventRecord` (line 281, internal)
- `TestSuiteFailureRecord` (line 286, internal)
- `TestBundle` (line 294, internal)
- `TestCase` (line 299, internal)
- `TestErrorInfo` (line 303, internal)
- `TestIssue` (line 325, internal)
- `TestLocation` (line 344, internal)
- `TestSourceCodeContext` (line 353, internal)
- `TestSourceCodeFrame` (line 362, internal)
- `TestSourceCodeSymbolInfo` (line 368, internal)
- `TestSuiteRecord` (line 374, internal)
- `Runner` (line 509, internal)

**Enums:**

- `TestEvent` (line 308, internal)
- `TestFailureKind` (line 313, internal)
- `TestIssueType` (line 334, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/GomaModels+Events.swift

**Structs:**

- `EventMetadataPointer` (line 13, internal)
- `GomaPagedResponse` (line 59, internal)
- `EventsPointerGroup` (line 71, internal)
- `EventsGroup` (line 93, internal)
- `PopularEvent` (line 108, internal)
- `Event` (line 118, internal)
- `Region` (line 422, internal)
- `PlacardInfo` (line 476, internal)
- `Competition` (line 487, internal)
- `Market` (line 578, internal)
- `Outcome` (line 645, internal)
- `MetaDetails` (line 718, internal)
- `Stats` (line 730, internal)
- `StatsDataContainer` (line 761, internal)
- `StatsData` (line 765, internal)
- `ParticipantStats` (line 776, internal)
- `BoostedEvent` (line 844, internal)

**Enums:**

- `MetaKeys` (line 29, internal)
- `EventStatus` (line 548, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/GomaModels+Social.swift

**Structs:**

- `FolloweesResponse` (line 12, internal)
- `FollowersResponse` (line 20, internal)
- `Follower` (line 28, internal)
- `FolloweeActionResponse` (line 38, internal)
- `TotalFolloweesResponse` (line 46, internal)
- `TotalFollowersResponse` (line 54, internal)
- `TipRanking` (line 62, internal)
- `UserProfileInfo` (line 105, internal)
- `UserProfileRanking` (line 123, internal)
- `UserProfileSportsData` (line 136, internal)
- `FriendRequest` (line 148, internal)
- `GomaFriend` (line 160, internal)
- `ChatroomData` (line 189, internal)
- `Chatroom` (line 199, internal)
- `SearchUser` (line 213, internal)
- `AddFriendResponse` (line 225, internal)
- `ChatroomId` (line 233, internal)
- `DeleteGroupResponse` (line 241, internal)

**Enums:**

- `CodignKeys` (line 218, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/App/AppModels.swift

**Structs:**

- `CompetitionGroup` (line 12, internal)
- `Competition` (line 25, internal)
- `Location` (line 50, internal)
- `Participant` (line 56, internal)
- `Market` (line 61, internal)
- `Outcome` (line 166, internal)
- `BettingOffer` (line 284, internal)
- `BannerInfo` (line 345, internal)
- `Country` (line 356, internal)
- `UserProfile` (line 386, internal)
- `UserWallet` (line 479, internal)
- `PromotionalStory` (line 488, internal)

**Enums:**

- `AggregationType` (line 19, internal)
- `OutcomesOrder` (line 63, internal)
- `OddFormat` (line 245, internal)
- `MarketType` (line 337, internal)
- `KnowYourCustomerStatus` (line 366, internal)
- `LockedStatus` (line 381, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/Betting/Betting.swift

**Structs:**

- `BettingHistory` (line 11, public)
- `Bet` (line 17, public)
- `BetSelection` (line 98, public)
- `BetType` (line 235, public)
- `BetslipPotentialReturn` (line 244, public)
- `BetBuilderPotentialReturn` (line 251, public)
- `BetTicket` (line 257, public)
- `BetTicketSelection` (line 304, public)
- `PlacedBetsResponse` (line 349, public)
- `NoReply` (line 374, public)
- `PlacedBetEntry` (line 378, public)
- `PlacedBetLeg` (line 403, public)
- `BetslipSettings` (line 432, public)

**Enums:**

- `BetResult` (line 192, public)
- `BetState` (line 202, public)
- `BetGroupingType` (line 218, public)
- `BetslipOddChangeSetting` (line 269, public)
- `OddFormat` (line 275, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/SportRadarModels+Betting.swift

**Structs:**

- `BettingHistory` (line 61, internal)
- `Bet` (line 65, internal)
- `BetSlip` (line 314, internal)
- `BetTicket` (line 318, internal)
- `BetTicketSelection` (line 334, internal)
- `BetslipPotentialReturnResponse` (line 354, internal)
- `BetBuilderPotentialReturn` (line 370, internal)
- `BetType` (line 383, internal)
- `BetSlipStateResponse` (line 401, internal)
- `ConfirmBetPlaceResponse` (line 405, internal)
- `PlacedBetsResponse` (line 420, internal)
- `PlacedBetEntry` (line 471, internal)
- `PlacedBetLeg` (line 500, internal)
- `BetslipSettings` (line 534, internal)
- `Settings` (line 589, private)

**Enums:**

- `BetResult` (line 12, internal)
- `BetState` (line 22, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Scripts/APIDocAnalyzer/Sources/DocGenerator/DocGenerator.swift

**Classes:**

- `DocumentationGenerator` (line 130, internal)

**Structs:**

- `APIInventory` (line 4, internal)
- `Model` (line 9, internal)
- `Property` (line 16, internal)
- `Relationship` (line 21, internal)
- `Endpoints` (line 26, internal)
- `SportradarDoc` (line 32, internal)
- `EndpointDetails` (line 37, internal)
- `ParameterDetails` (line 79, internal)
- `ReturnDetails` (line 103, internal)
- `SubscriptionDetails` (line 108, internal)
- `EventUpdates` (line 116, internal)
- `MarketTypes` (line 120, internal)
- `ContentIdentifier` (line 124, internal)

**Enums:**

- `Parameters` (line 47, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/GomaModels+Promotions.swift

**Structs:**

- `HomeTemplate` (line 13, internal)
- `HomeWidget` (line 25, internal)
- `AlertBanner` (line 45, internal)
- `Banner` (line 73, internal)
- `BoostedOddsPointer` (line 128, internal)
- `TopImageCardPointer` (line 159, internal)
- `CarouselEvent` (line 172, internal)
- `HeroCardPointer` (line 198, internal)
- `NewsItem` (line 222, internal)
- `ProChoiceCardPointer` (line 255, internal)
- `Story` (line 286, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/EveryMatrixAPI/Betting/BetslipSelectionState.swift

**Structs:**

- `BetslipForbiddenCombinationSelection` (line 10, internal)
- `BetslipForbiddenCombination` (line 25, internal)
- `BetslipWinningsInfo` (line 34, internal)
- `BetslipFreebet` (line 45, internal)
- `BetslipOddsBoost` (line 59, internal)
- `BetslipSelectionState` (line 75, internal)
- `BetslipPlaceBetResponse` (line 116, internal)
- `BetslipPlaceEntry` (line 247, internal)
- `BetBuilder` (line 262, internal)
- `BetBuilderSelection` (line 272, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/GomaModels.swift

**Structs:**

- `GomaResponse` (line 12, internal)
- `BasicRegisterResponse` (line 24, internal)
- `LoginResponse` (line 54, internal)
- `AnonymousLoginResponse` (line 64, internal)
- `LogoutResponse` (line 72, internal)
- `FavoriteItem` (line 80, internal)
- `FavoriteItemAddResponse` (line 135, internal)
- `FavoriteItemDeleteResponse` (line 143, internal)

**Enums:**

- `GomaModels` (line 10, internal)
- `FavorityItemType` (line 110, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/EveryMatrixAPI/Bonus/Bonus.swift

**Structs:**

- `ApplicableBonusResponse` (line 11, internal)
- `ApplicableBonus` (line 27, internal)
- `CurrencyBonus` (line 47, internal)
- `ClaimableBonusResponse` (line 59, internal)
- `ClaimableBonus` (line 63, internal)
- `GrantedBonusResponse` (line 77, internal)
- `GrantedBonus` (line 88, internal)
- `ApplyBonusResponse` (line 122, internal)

**Enums:**

- `GrantedBonusType` (line 127, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/GomaModels+Tickets.swift

**Structs:**

- `MyTicketsResponse` (line 12, internal)
- `MyTicket` (line 22, internal)
- `MyTicketSelection` (line 100, internal)
- `MyTicketOutcome` (line 168, internal)
- `MyTicketMarket` (line 201, internal)
- `MyTicketEvent` (line 213, internal)
- `MyTicketQRCode` (line 398, internal)

**Enums:**

- `MyTicketResult` (line 352, internal)
- `MyTicketStatus` (line 375, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Tools/Extensions/Date+Extension.swift

**Classes:**

- `ConcurrentFormatterCache` (line 561, internal)

**Enums:**

- `DateFormatType` (line 682, internal)
- `TimeZoneType` (line 750, internal)
- `RelativeTimeStringType` (line 767, internal)
- `DateComparisonType` (line 799, internal)
- `DateComponentType` (line 861, internal)
- `DateForType` (line 866, internal)
- `DateStyleType` (line 871, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/Shared/UserSettingsGoma.swift

**Structs:**

- `BettingUserSettings` (line 10, internal)
- `NotificationsUserSettings` (line 48, internal)
- `BusinessInstanceSettingsResponse` (line 299, internal)
- `HomeFeedTemplate` (line 330, internal)
- `VideoItemFeedContent` (line 447, internal)
- `BannerItemFeedContent` (line 464, internal)

**Enums:**

- `HomeFeedContent` (line 344, internal)
- `SportSectionFeedContent` (line 399, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/MatchDetails/MarketGroupOrganizer.swift

**Structs:**

- `MarketGroup` (line 22, internal)
- `ColumnListedMarketGroupOrganizer` (line 32, internal)
- `MarketLinesMarketGroupOrganizer` (line 151, internal)
- `MarketColumnsMarketGroupOrganizer` (line 226, internal)
- `SequentialMarketGroupOrganizer` (line 298, internal)
- `UndefinedGroupMarketGroupOrganizer` (line 350, internal)
- `UnorderedGroupMarketGroupOrganizer` (line 408, internal)
- `SimpleListGroupMarketGroupOrganizer` (line 466, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Constants/UserSettings.swift

**Enums:**

- `UserDefaultsKey` (line 11, internal)
- `CardsStyle` (line 285, internal)
- `CompetitionListStyle` (line 290, internal)
- `BetslipOddChangeSettingMode` (line 295, public)
- `BetslipOddChangeSetting` (line 300, public)
- `BetslipOddValidationType` (line 317, internal)
- `OddsValueType` (line 341, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/URLEndpoints.swift

**Structs:**

- `Links` (line 7, internal)
- `APIs` (line 25, internal)
- `Support` (line 54, internal)
- `ResponsibleGaming` (line 72, internal)
- `SocialMedia` (line 128, internal)
- `LegalAndInfo` (line 149, internal)

**Enums:**

- `URLEndpoint` (line 4, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Tests/_CollectionsTestSupport/MinimalTypes/MinimalEncoder.swift

**Classes:**

- `MinimalEncoder` (line 23, public)
- `Encoder` (line 196, internal)
- `KeyedContainer` (line 252, internal)
- `UnkeyedContainer` (line 430, internal)
- `SingleValueContainer` (line 597, internal)

**Structs:**

- `_Key` (line 62, internal)

**Enums:**

- `Value` (line 24, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Tools/ExternalLibs/SwiftyJSON/SwiftyJSON.swift

**Structs:**

- `JSON` (line 82, public)

**Enums:**

- `SwiftyJSONError` (line 27, public)
- `Type` (line 70, public)
- `Index` (line 278, public)
- `JSONKey` (line 346, public)
- `writingOptionsKeys` (line 1287, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Tools/ExternalLibs/ShiftAnimations/Animations.swift

**Classes:**

- `Animations` (line 13, public)

**Structs:**

- `Condition` (line 16, public)
- `Animation` (line 40, internal)
- `Filter` (line 286, public)

**Enums:**

- `Direction` (line 278, public)
- `Mode` (line 291, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Constants/Constants.swift

**Enums:**

- `CornerRadius` (line 11, internal)
- `TextSpacing` (line 24, internal)
- `Assets` (line 28, internal)
- `CountryFlagHelper` (line 37, internal)
- `UserTitle` (line 80, internal)
- `UserGender` (line 98, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/App/Match.swift

**Structs:**

- `ImageHighlightedContent` (line 10, internal)
- `MatchLiveData` (line 21, internal)
- `Match` (line 42, internal)

**Enums:**

- `HighlightedMatchType` (line 16, internal)
- `Status` (line 96, internal)
- `ActivePlayerServe` (line 144, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/App/BetBuilder.swift

**Classes:**

- `BetBuilderTransformer` (line 73, internal)
- `BetBuilderProcessor` (line 346, internal)

**Structs:**

- `BetBuilderState` (line 31, internal)

**Enums:**

- `BetBuilderCalculateResponse` (line 12, internal)
- `BetBuilderTicketState` (line 17, internal)
- `MessageKey` (line 38, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/Shared/UploadDocuments.swift

**Structs:**

- `DocumentInfo` (line 10, internal)
- `DocumentFileInfo` (line 18, internal)

**Enums:**

- `FileState` (line 47, internal)
- `DocumentTypeCode` (line 92, internal)
- `DocumentUploadState` (line 131, internal)
- `DocumentTypeGroup` (line 139, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/EveryMatrixAPI/Aggregator.swift

**Structs:**

- `Aggregator` (line 17, internal)

**Enums:**

- `AggregatorContentType` (line 12, internal)
- `ContentUpdateError` (line 72, internal)
- `ContentUpdate` (line 77, internal)
- `Content` (line 232, internal)
- `ContentTypeKey` (line 254, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/EveryMatrixAPI/Disciplines/SportsAggregator.swift

**Structs:**

- `SportsAggregator` (line 17, internal)

**Enums:**

- `SportsAggregatorContentType` (line 12, internal)
- `SportsContentUpdateError` (line 67, internal)
- `SportsContentUpdate` (line 72, internal)
- `SportsContent` (line 152, internal)
- `SportsContentTypeKey` (line 161, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/EveryMatrixAPI/Cashouts/CashoutAggregator.swift

**Structs:**

- `CashoutAggregator` (line 17, internal)

**Enums:**

- `CashoutAggregatorContentType` (line 12, internal)
- `CashoutContentUpdateError` (line 67, internal)
- `CashoutContentUpdate` (line 72, internal)
- `CashoutContent` (line 145, internal)
- `CashoutContentTypeKey` (line 154, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/CompetitionsList/CompetitionsFiltersViewSwiftUI.swift

**Classes:**

- `CompetitionsFiltersView2Model` (line 173, internal)

**Structs:**

- `CompetitionsFiltersView2` (line 5, internal)
- `CompetitionsFiltersView2_Previews` (line 321, internal)
- `RoundedCorner` (line 441, internal)

**Enums:**

- `SizeState` (line 166, internal)
- `ViewState` (line 299, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Services/UserSessionStore.swift

**Classes:**

- `UserSessionStore` (line 45, internal)

**Structs:**

- `LimitsValidation` (line 812, internal)

**Enums:**

- `UserSessionError` (line 15, internal)
- `RegisterUserError` (line 24, internal)
- `UserProfileStatus` (line 34, internal)
- `UserTrackingStatus` (line 39, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/Starscream/Sources/Framer/Framer.swift

**Classes:**

- `WSFramer` (line 86, public)

**Structs:**

- `Frame` (line 59, public)

**Enums:**

- `CloseCode` (line 34, public)
- `FrameOpCode` (line 47, public)
- `FrameEvent` (line 69, public)
- `ProcessEvent` (line 105, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/SportRadarModels+PromotedBetslips.swift

**Structs:**

- `PromotedBetslipsBatchResponse` (line 12, internal)
- `PromotedBetslipsInternalRequest` (line 38, private)
- `VaixBatchBody` (line 57, private)
- `VaixBatchData` (line 73, private)
- `PromotedBetslip` (line 89, internal)
- `PromotedBetslipSelection` (line 105, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/Documents/SportRadarModels+ApplicantDataResponse.swift

**Structs:**

- `ApplicantRootResponse` (line 12, internal)
- `ApplicantDataResponse` (line 24, internal)
- `ApplicantDataInfo` (line 38, internal)
- `ApplicantDoc` (line 46, internal)
- `ApplicantReviewData` (line 55, internal)
- `ApplicantReviewResult` (line 73, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/GomaModels+Betting.swift

**Structs:**

- `PlaceBetTicketResponse` (line 13, internal)
- `AllowedBets` (line 109, internal)
- `SystemBetType` (line 188, internal)
- `BetslipPotentialReturn` (line 199, internal)
- `BettingSelection` (line 243, internal)

**Enums:**

- `BetType` (line 160, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/GomaModels+FeaturedTips.swift

**Structs:**

- `FeaturedTipsPagedResponse` (line 12, internal)
- `FeaturedTip` (line 45, internal)
- `FeaturedTipSelection` (line 156, internal)
- `TipOutcome` (line 225, internal)
- `TipMarket` (line 277, internal)
- `TipUser` (line 311, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/Payments/TransactionsHistoryResponse.swift

**Structs:**

- `TransactionsHistoryResponse` (line 10, public)
- `TransactionDetail` (line 26, public)
- `TransactionHistory` (line 61, public)
- `DebitCredit` (line 101, public)
- `Fees` (line 113, public)

**Enums:**

- `TransactionValueType` (line 123, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Tools/ExternalLibs/ShiftAnimations/ShiftViewOptions.swift

**Structs:**

- `ShiftViewOptions` (line 12, public)

**Enums:**

- `Superview` (line 52, public)
- `Position` (line 61, public)
- `ContentSizing` (line 73, public)
- `ContentAnimation` (line 82, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/EveryMatrixAPI/Betting/BetslipHistory.swift

**Structs:**

- `BetHistoryResponse` (line 11, internal)
- `BetHistoryEntry` (line 19, internal)
- `BetHistoryEntrySelection` (line 115, internal)

**Enums:**

- `BetSelectionStatus` (line 92, internal)
- `BetSelectionResult` (line 104, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/EveryMatrixAPI/Limits/LimitsResponse.swift

**Structs:**

- `LimitsResponse` (line 11, internal)
- `Limit` (line 37, internal)
- `LimitInfo` (line 50, internal)
- `LimitSetResponse` (line 64, internal)

**Enums:**

- `LimitType` (line 70, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Home/Views/ViewModels/FeaturedTipCollectionViewModel.swift

**Classes:**

- `FeaturedTipCollectionViewModel` (line 13, internal)
- `FeaturedTipSelectionViewModel` (line 222, internal)

**Enums:**

- `DataType` (line 17, private)
- `SizeType` (line 23, internal)
- `DataType` (line 308, private)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Social/AddFriend/ViewModels/AddContactViewModel.swift

**Classes:**

- `AddContactViewModel` (line 12, internal)

**Structs:**

- `ContactsData` (line 354, internal)
- `UserContactSectionData` (line 362, internal)

**Enums:**

- `UserContactType` (line 367, internal)
- `FriendAlertType` (line 381, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Betslip/PreSubmission/PreSubmissionBetslipViewController.swift

**Classes:**

- `PreSubmissionBetslipViewController` (line 15, internal)

**Structs:**

- `SingleBetslipFreebet` (line 2934, internal)
- `SingleBetslipOddsBoost` (line 2939, internal)
- `BonusMultipleBetslip` (line 2944, internal)

**Enums:**

- `BetslipType` (line 240, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Profile/BettingPractices/BettingPracticesQuestionnaireViewModel.swift

**Classes:**

- `BettingPracticesQuestionnaireViewModel` (line 13, internal)

**Structs:**

- `QuestionnaireStep` (line 162, internal)
- `QuestionnaireResult` (line 170, internal)
- `QuestionData` (line 176, internal)

**Enums:**

- `QuestionFormStep` (line 154, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Tests/_CollectionsTestSupport/MinimalTypes/MinimalDecoder.swift

**Classes:**

- `MinimalDecoder` (line 12, public)
- `Decoder` (line 75, internal)
- `KeyedContainer` (line 134, internal)
- `UnkeyedContainer` (line 359, internal)
- `SingleValueContainer` (line 601, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/SportRadarModels+Sports.swift

**Structs:**

- `SportType` (line 12, internal)
- `LiveSportTypeDetails` (line 39, internal)
- `SportsList` (line 83, internal)
- `SportNode` (line 91, internal)
- `ScheduledSport` (line 122, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Goma/APIs/GomaAPISchema.swift

**Structs:**

- `BetSelection` (line 13, internal)
- `RequestBody` (line 1105, internal)
- `Selection` (line 1153, internal)

**Enums:**

- `ArgumentModels` (line 11, internal)
- `GomaAPISchema` (line 21, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/Content/Promotions/HomeTemplate.swift

**Structs:**

- `HomeTemplate` (line 10, public)
- `WidgetData` (line 87, public)

**Enums:**

- `HomeWidget` (line 23, public)
- `Orientation` (line 95, public)
- `UserState` (line 101, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/User/Documents/ApplicantDataResponse.swift

**Structs:**

- `ApplicantDataResponse` (line 10, public)
- `ApplicantDataInfo` (line 24, public)
- `ApplicantDoc` (line 32, public)
- `ApplicantReviewData` (line 41, public)
- `ApplicantReviewResult` (line 59, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/Common/Subscription.swift

**Classes:**

- `Subscription` (line 28, public)
- `ContentIdentifier` (line 215, public)

**Structs:**

- `ContentDateFormatter` (line 340, internal)

**Enums:**

- `ContentType` (line 81, public)
- `ContentRoute` (line 100, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/Common/Filters.swift

**Structs:**

- `MarketFilter` (line 27, public)
- `MarketInfo` (line 45, public)
- `TranslationInfo` (line 57, public)
- `MarketSportType` (line 70, public)
- `MarketSport` (line 89, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### EveryMatrixClient/TSLibrary/WAMP/SSWampSession.swift

**Classes:**

- `Subscription` (line 39, open)
- `Registration` (line 69, open)
- `SSWampSession` (line 109, open)
- `ThreadSafeDictionary` (line 515, fileprivate)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Tools/ExternalLibs/ShiftAnimations/DefaultShiftAnimation.swift

**Structs:**

- `Fade` (line 17, public)
- `Scale` (line 24, public)

**Enums:**

- `DefaultAnimations` (line 15, public)
- `Direction` (line 27, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/App/Router.swift

**Classes:**

- `Router` (line 34, internal)

**Enums:**

- `Route` (line 13, internal)
- `ScreenBlocker` (line 50, internal)
- `AppSharedState` (line 1014, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/App/BetslipModels.swift

**Structs:**

- `BetslipError` (line 25, internal)
- `BetPlacedDetails` (line 36, internal)
- `BetPotencialReturn` (line 40, internal)

**Enums:**

- `BetslipErrorType` (line 11, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/EveryMatrixAPI/Transactions/TransactionHistory.swift

**Structs:**

- `TransactionsHistoryResponse` (line 12, internal)
- `TransactionHistory` (line 27, internal)
- `DebitCredit` (line 52, internal)
- `Fees` (line 64, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/EveryMatrixAPI/Account/UserBalance.swift

**Structs:**

- `UserBalance` (line 11, internal)
- `UserBalanceWallet` (line 19, internal)
- `AccountBalance` (line 49, internal)
- `AccountBalanceWatcher` (line 68, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/LiveEvents/LiveEventsViewModel.swift

**Classes:**

- `LiveEventsViewModel` (line 13, internal)
- `LiveMatchesViewModelDataSource` (line 572, internal)

**Enums:**

- `ScreenState` (line 15, internal)
- `MatchListType` (line 50, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Home/ViewModels/SportMatchLineViewModel.swift

**Classes:**

- `SportMatchLineViewModel` (line 12, internal)

**Enums:**

- `MatchesType` (line 14, internal)
- `LoadingState` (line 37, internal)
- `LayoutType` (line 43, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLive_backup/ViewModels/MatchWidgetCellViewModel.swift

**Classes:**

- `MatchWidgetCellViewModel` (line 28, internal)

**Structs:**

- `BoostedOutcome` (line 292, internal)

**Enums:**

- `MatchWidgetType` (line 13, internal)
- `MatchWidgetStatus` (line 22, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLive_backup/Cells/MatchLineTableViewCell.swift

**Classes:**

- `MatchLineTableViewCell` (line 12, internal)
- `MatchLinePreviewViewController` (line 728, private)

**Structs:**

- `PreviewContainer` (line 713, private)

**Enums:**

- `PreviewState` (line 732, private)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/MatchDetails/MatchDetailsViewController.swift

**Classes:**

- `MatchDetailsViewController` (line 12, internal)

**Structs:**

- `MatchDetailsViewController_Previews` (line 2780, internal)
- `MatchDetailsViewControllerPreview` (line 2792, internal)

**Enums:**

- `HeaderBarSelection` (line 218, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLiveEvents/ViewModels/Match/MatchWidgetCellViewModel.swift

**Classes:**

- `MatchWidgetCellViewModel` (line 28, internal)

**Structs:**

- `BoostedOutcome` (line 292, internal)

**Enums:**

- `MatchWidgetType` (line 13, internal)
- `MatchWidgetStatus` (line 22, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLiveEvents/Views/Cells/Match/MatchLine/MatchLineTableViewCell.swift

**Classes:**

- `MatchLineTableViewCell` (line 12, internal)
- `MatchLinePreviewViewController` (line 728, private)

**Structs:**

- `PreviewContainer` (line 713, private)

**Enums:**

- `PreviewState` (line 732, private)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Social/Settings/ChatSettingsViewModel.swift

**Classes:**

- `ChatSettingsViewModel` (line 11, internal)

**Structs:**

- `ChatUserSettings` (line 89, internal)

**Enums:**

- `SendMessagesType` (line 94, internal)
- `AddGroupsType` (line 109, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Social/AddFriend/AddFriendViewModel.swift

**Classes:**

- `AddFriendViewModel` (line 11, internal)

**Structs:**

- `UserContact` (line 252, internal)
- `UserContactSection` (line 264, internal)

**Enums:**

- `ContactSectionType` (line 259, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Documents/ManualUploadDocumentsViewController.swift

**Classes:**

- `ManualUploadDocumentsViewController` (line 11, internal)

**Structs:**

- `SelectedDoc` (line 1315, internal)
- `CurrentDoc` (line 1321, internal)

**Enums:**

- `DocSide` (line 1310, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Tips&Rankings/Rankings/ViewModels/RankingsListViewModel.swift

**Classes:**

- `RankingsListViewModel` (line 11, internal)

**Enums:**

- `RankingsType` (line 13, internal)
- `SortType` (line 20, internal)
- `ScreenState` (line 42, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Views/Chat/ToastCustom.swift

**Classes:**

- `ToastCustom` (line 11, public)
- `ToastCustomView` (line 78, public)
- `TextToastCustomView` (line 180, public)

**Structs:**

- `ToastCustomConfiguration` (line 160, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### AdresseFrancaise/Sources/AdresseFrancaise/AdresseFrancaiseClient.swift

**Structs:**

- `AdresseFrancaiseClient` (line 11, public)
- `AddressSearchResponse` (line 85, public)
- `AddressResult` (line 104, public)

**Enums:**

- `AdresseFrancaiseError` (line 4, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/Betsson/AdditionalRegisterSteps/LimitsOnRegisterViewController.swift

**Classes:**

- `LimitsOnRegisterViewModel` (line 17, public)
- `LimitsOnRegisterViewController` (line 138, public)

**Enums:**

- `LimitsOnRegisterError` (line 19, public)
- `SelectedProfile` (line 140, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/ConfirmationCodeFormStepView.swift

**Classes:**

- `ConfirmationCodeFormStepViewModel` (line 16, internal)
- `ConfirmationCodeFormStepView` (line 194, internal)

**Structs:**

- `PhoneVerificationResponse` (line 18, internal)

**Enums:**

- `PhoneVerificationError` (line 27, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Tests/HashTreeCollectionsTests/TreeDictionary Tests.swift

**Classes:**

- `TreeDictionaryTests` (line 21, internal)

**Structs:**

- `FancyDictionaryKey` (line 278, internal)
- `BoringDictionaryKey` (line 293, internal)
- `Empty` (line 533, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Tests/RopeModuleTests/TestRope.swift

**Classes:**

- `TestRope` (line 117, internal)

**Structs:**

- `Chunk` (line 20, internal)
- `Summary` (line 24, internal)
- `Metric` (line 50, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/InternalCollectionsUtilities/UnsafeBitSet/autogenerated/_UnsafeBitSet.swift

**Structs:**

- `_UnsafeBitSet` (line 28, internal)
- `Iterator` (line 267, internal)
- `_UnsafeBitSet` (line 500, public)
- `Iterator` (line 739, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/BigString/Basics/BigString+Metrics.swift

**Structs:**

- `_CharacterMetric` (line 31, internal)
- `_UnicodeScalarMetric` (line 62, internal)
- `_UTF8Metric` (line 106, internal)
- `_UTF16Metric` (line 155, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/Starscream/Sources/Framer/HTTPHandler.swift

**Structs:**

- `HTTPWSHeader` (line 30, public)
- `URLParts` (line 119, public)

**Enums:**

- `HTTPUpgradeError` (line 25, public)
- `HTTPEvent` (line 94, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/Starscream/Sources/Starscream/WebSocket.swift

**Classes:**

- `WebSocket` (line 95, open)

**Structs:**

- `WSError` (line 32, public)

**Enums:**

- `ErrorType` (line 25, public)
- `WebSocketEvent` (line 77, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Tests/ServicesProviderTests/Providers/Goma/Integration/Helpers/TestConfiguration.swift

**Structs:**

- `TestConfiguration` (line 4, internal)
- `EndpointPaths` (line 7, internal)
- `MockResponseDirectories` (line 21, internal)
- `API` (line 35, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/SportRadarConfiguration.swift

**Structs:**

- `GomaAPIClientConfiguration` (line 12, public)
- `SportRadarConfiguration` (line 44, public)

**Enums:**

- `Environment` (line 14, internal)
- `Environment` (line 46, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/HomeWidgets/PromotedSports.swift

**Structs:**

- `PromotedSportsResponse` (line 13, internal)
- `PromotedSportsNodeResponse` (line 48, internal)
- `PromotedSport` (line 79, internal)
- `MarketGroupPromotedSport` (line 99, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/Events/TopCompetitionsResponse.swift

**Structs:**

- `TopCompetitionsResponse` (line 11, public)
- `TopCompetitionData` (line 19, public)
- `TopCompetitionPointer` (line 29, public)
- `TopCompetition` (line 49, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### EveryMatrixClient/AggregatorsRepository.swift

**Classes:**

- `AggregatorsRepository` (line 24, internal)

**Structs:**

- `OddOutcomesSortingHelper` (line 415, internal)

**Enums:**

- `AggregatorListType` (line 12, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### EveryMatrixClient/EveryMatrixServiceClient.swift

**Classes:**

- `EveryMatrixServiceClient` (line 24, internal)

**Enums:**

- `EveryMatrixServiceSocketStatus` (line 5, internal)
- `EveryMatrixServiceUserSessionStatus` (line 19, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Tools/Extensions/UIImageView+Extensions.swift

**Structs:**

- `UIImageColors` (line 60, public)
- `UIImageColorsCounter` (line 81, fileprivate)

**Enums:**

- `UIImageColorsQuality` (line 74, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Tools/ExternalLibs/ShiftAnimations/Animator.swift

**Classes:**

- `Animator` (line 12, public)
- `ShiftViews` (line 303, public)

**Enums:**

- `ViewOrder` (line 290, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Tools/ExternalLibs/KDCircularProgress/KDCircularProgress.swift

**Classes:**

- `KDCircularProgress` (line 16, public)
- `KDCircularProgressViewLayer` (line 267, private)

**Enums:**

- `GlowConstants` (line 297, private)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/Shared/DocumentLevelStatus.swift

**Structs:**

- `CurrentDocumentLevelStatus` (line 10, internal)

**Enums:**

- `DocumentStatus` (line 15, internal)
- `DocumentLevelName` (line 50, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/GGAPI/SharedBetTicket.swift

**Structs:**

- `SharedBetTicketAttachment` (line 10, internal)
- `SharedBetTicket` (line 70, internal)
- `SharedBetTicketSelection` (line 176, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/EveryMatrixAPI/MatchOddsContent.swift

**Structs:**

- `MatchOdds` (line 12, internal)

**Enums:**

- `MatchOddsContent` (line 31, internal)
- `ContentTypeKey` (line 45, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/EveryMatrixAPI/Betting/SharedBetData.swift

**Structs:**

- `SharedBetDataResponse` (line 10, internal)
- `SharedBetData` (line 25, internal)
- `SharedBet` (line 46, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/EveryMatrixAPI/Search/SearchV2Response.swift

**Structs:**

- `SearchV2Response` (line 10, internal)

**Enums:**

- `SearchContent` (line 20, internal)
- `ContentTypeKey` (line 36, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/EveryMatrixAPI/Account/LoginAccount.swift

**Structs:**

- `CMSSession` (line 11, internal)
- `LoginAccount` (line 21, internal)
- `SessionInfo` (line 34, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/LiveEvents/LiveEventsViewController.swift

**Classes:**

- `LiveEventsViewController` (line 13, internal)

**Structs:**

- `LiveEventsViewController_Previews` (line 1010, internal)
- `LiveEventsViewControllerPreview` (line 1022, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Home/HomeViewModel.swift

**Classes:**

- `HomeViewModel` (line 19, internal)

**Enums:**

- `HomeTemplateBuilderType` (line 12, internal)
- `Content` (line 21, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Home/Views/StoriesFullScreenItemView.swift

**Classes:**

- `StoriesFullScreenItemViewModel` (line 14, internal)
- `StoriesFullScreenItemView` (line 66, internal)

**Enums:**

- `ContentType` (line 16, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Home/Views/FeaturedTipLineTableViewCell.swift

**Classes:**

- `FeaturedTipLineViewModel` (line 11, internal)
- `FeaturedTipLineTableViewCell` (line 102, internal)

**Enums:**

- `DataType` (line 15, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/BetslipProxyWebViewController/BetslipProxyWebViewController.swift

**Classes:**

- `BetslipProxyWebViewController` (line 24, internal)

**Structs:**

- `WebMessage` (line 12, internal)
- `BetSwipeData` (line 17, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/CompetitionsList/CompetitionFilterCell.swift

**Classes:**

- `CompetitionFilterCellViewModel2` (line 4, internal)

**Structs:**

- `CompetitionFilterCell` (line 45, internal)
- `CompetitionFilterCell_Previews` (line 157, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/CompetitionsList/CompetitionSectionHeader.swift

**Classes:**

- `CompetitionSectionHeaderViewModel` (line 4, internal)

**Structs:**

- `CompetitionSectionHeader` (line 40, internal)
- `CompetitionSectionHeader_Previews` (line 130, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/CompetitionsList/CompetitionFilterTableViewCell.swift

**Classes:**

- `CompetitionFilterCellViewModel` (line 16, internal)
- `CompetitionFilterTableViewCell` (line 38, internal)

**Enums:**

- `CompetitionFilterCellMode` (line 11, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLive_backup/ViewModels/PreLiveEventsViewModel.swift

**Classes:**

- `PreLiveEventsViewModel` (line 13, internal)

**Enums:**

- `MatchListType` (line 44, internal)
- `ScreenState` (line 70, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLive_backup/Cells/LoadingMoreTableViewCell.swift

**Classes:**

- `LoadingMoreTableViewCell` (line 10, internal)
- `PreviewTableViewController` (line 82, private)

**Structs:**

- `UIKitPreview` (line 117, private)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLive_backup/Cells/SeeMoreMarketsCollectionViewCell.swift

**Classes:**

- `SeeMoreMarketsCollectionViewCell` (line 10, internal)
- `PreviewCellContainer` (line 241, private)

**Structs:**

- `UIViewPreview` (line 230, private)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLive_backup/Cells/Banner/ViewModel/BannerCellViewModel.swift

**Classes:**

- `BannerLineCellViewModel` (line 12, internal)
- `BannerCellViewModel` (line 21, internal)

**Enums:**

- `PresentationType` (line 23, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLiveEvents/ViewModels/PreLiveEventsViewModel.swift

**Classes:**

- `PreLiveEventsViewModel` (line 13, internal)

**Enums:**

- `MatchListType` (line 44, internal)
- `ScreenState` (line 70, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLiveEvents/ViewModels/Banner/BannerCellViewModel.swift

**Classes:**

- `BannerLineCellViewModel` (line 12, internal)
- `BannerCellViewModel` (line 21, internal)

**Enums:**

- `PresentationType` (line 23, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLiveEvents/Views/Cells/Utility/SeeMoreMarkets/SeeMoreMarketsCollectionViewCell.swift

**Classes:**

- `SeeMoreMarketsCollectionViewCell` (line 10, internal)
- `PreviewCellContainer` (line 241, private)

**Structs:**

- `UIViewPreview` (line 230, private)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLiveEvents/Views/Cells/Utility/LoadingMore/LoadingMoreTableViewCell.swift

**Classes:**

- `LoadingMoreTableViewCell` (line 10, internal)
- `PreviewTableViewController` (line 82, private)

**Structs:**

- `UIKitPreview` (line 117, private)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Social/SocialViewController.swift

**Classes:**

- `SocialViewModel` (line 11, internal)
- `SocialViewController` (line 37, internal)

**Enums:**

- `StartScreen` (line 13, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Social/Conversations/ConversationList/ConversationsViewController.swift

**Classes:**

- `ConversationsViewController` (line 11, internal)

**Structs:**

- `ConversationData` (line 505, internal)

**Enums:**

- `ConversationType` (line 517, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Root/RootViewController.swift

**Classes:**

- `RootViewController` (line 19, internal)

**Enums:**

- `TabItem` (line 262, internal)
- `AppMode` (line 298, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Bonus/DataSources/BonusAvailableDataSource.swift

**Classes:**

- `BonusAvailableDataSource` (line 12, internal)

**Structs:**

- `BonusTypeData` (line 104, internal)

**Enums:**

- `BonusType` (line 108, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Profile/ProfileViewController.swift

**Classes:**

- `ProfileViewController` (line 14, internal)
- `ThemeSelectorView` (line 975, internal)

**Enums:**

- `PageMode` (line 106, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Profile/History/BettingHistoryViewModel.swift

**Classes:**

- `BettingHistoryViewModel` (line 12, internal)

**Enums:**

- `BettingTicketsType` (line 14, internal)
- `ListState` (line 21, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Profile/History/TransactionsHistoryViewModel.swift

**Classes:**

- `TransactionsHistoryViewModel` (line 13, internal)

**Enums:**

- `TransactionsType` (line 15, internal)
- `ListState` (line 21, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Documents/Cells/UploadDocumentTableViewCell.swift

**Classes:**

- `UploadDocumentCellViewModel` (line 16, internal)
- `UploadDocumentTableViewCell` (line 50, internal)

**Enums:**

- `DocumentState` (line 11, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/MyTickets/ViewModel/MyTicketsViewModel.swift

**Classes:**

- `MyTicketsViewModel` (line 26, internal)

**Enums:**

- `MyTicketsType` (line 12, internal)
- `ListState` (line 18, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Share/ShareTicketChoiceViewController.swift

**Classes:**

- `ShareTicketChoiceViewController` (line 13, internal)

**Structs:**

- `ClickedShareTicketInfo` (line 727, internal)
- `SocialApp` (line 735, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Views/ScoreView.swift

**Classes:**

- `ScoreView` (line 11, internal)
- `ScoreCellView` (line 316, internal)

**Enums:**

- `Style` (line 348, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Views/BonusViews/BonusProgressView.swift

**Classes:**

- `BonusProgressView` (line 11, internal)

**Enums:**

- `ProgressType` (line 217, internal)
- `CurrencySymbol` (line 222, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Views/EditAlertView/EditAlertView.swift

**Classes:**

- `EditAlertView` (line 10, internal)

**Structs:**

- `AlertInfo` (line 12, internal)

**Enums:**

- `AlertState` (line 26, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Views/FlipperView/FlipNumberView.swift

**Classes:**

- `FlipNumberView` (line 10, internal)
- `FlipNumberStripView` (line 200, internal)
- `FlipNumberStripCellView` (line 361, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Views/PictureInPictureView/PictureInPictureView.swift

**Classes:**

- `BlockingWindow` (line 11, internal)
- `PassthroughWindow` (line 15, internal)
- `PictureInPictureView` (line 22, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Protocols/ClientsProtocols/SportsbookTarget.swift

**Enums:**

- `SportsbookTargetFeatures` (line 49, internal)
- `SportsbookSupportedLanguage` (line 78, internal)
- `KnowYourCustomerLevel` (line 87, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Services/FavoritesManager.swift

**Classes:**

- `FavoritesManager` (line 12, internal)

**Enums:**

- `FavoriteType` (line 449, internal)
- `FavoriteAction` (line 463, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Scripts/APIDocAnalyzer/Sources/ModelParser/swift_parser.swift

**Classes:**

- `TypeVisitor` (line 24, internal)

**Structs:**

- `Property` (line 6, internal)
- `TypeInfo` (line 18, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/AgeCountryFormStepView.swift

**Classes:**

- `AgeCountryFormStepViewModel` (line 18, internal)
- `AgeCountryFormStepView` (line 253, internal)

**Enums:**

- `CountryState` (line 112, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/GenderFormStepView.swift

**Classes:**

- `GenderFormStepViewModel` (line 13, internal)
- `GenderFormStepView` (line 88, internal)

**Enums:**

- `Gender` (line 21, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/PasswordFormStepView.swift

**Classes:**

- `PasswordFormStepViewModel` (line 15, internal)
- `PasswordFormStepView` (line 120, internal)

**Enums:**

- `PasswordState` (line 17, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/NicknameFormStepView.swift

**Classes:**

- `NicknameFormStepViewModel` (line 15, internal)
- `NicknameFormStepView` (line 189, internal)

**Enums:**

- `NicknameState` (line 17, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/AddressFormStepView.swift

**Classes:**

- `AddressFormStepViewModel` (line 23, internal)
- `AddressFormStepView` (line 199, internal)

**Structs:**

- `AddressSearchResult` (line 16, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Goma/MultibetPasswordFormStepView.swift

**Classes:**

- `MultibetPasswordFormStepViewModel` (line 15, internal)
- `MultibetPasswordFormStepView` (line 120, internal)

**Enums:**

- `PasswordState` (line 17, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### HeaderTextField/Sources/HeaderTextField/HeaderTextFieldView.swift

**Classes:**

- `HeaderTextFieldView` (line 6, public)

**Enums:**

- `BorderState` (line 31, private)
- `TipState` (line 137, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/Starscream/Sources/Compression/WSCompression.swift

**Classes:**

- `WSCompression` (line 32, public)
- `Decompressor` (line 104, internal)
- `Compressor` (line 183, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/SportRadarModels+SocketContent.swift

**Structs:**

- `RestResponse` (line 73, internal)

**Enums:**

- `SportRadarModels` (line 10, internal)
- `NotificationType` (line 17, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/HomeWidgets/PromotionalBanners.swift

**Structs:**

- `PromotionalBannersResponse` (line 12, internal)
- `PromotionalBanner` (line 30, internal)

**Enums:**

- `BannerSpecialAction` (line 53, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/Competitions/SportRadarModels+TopCompetitionsResponse.swift

**Structs:**

- `TopCompetitionsResponse` (line 12, internal)
- `TopCompetitionData` (line 21, internal)
- `TopCompetitionPointer` (line 31, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/UserConsents/SportRadarModels+UserConsentsResponse.swift

**Structs:**

- `ConsentsResponse` (line 13, internal)
- `Consent` (line 19, internal)
- `UserConsentsResponse` (line 38, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Goma/GomaConnector.swift

**Classes:**

- `GomaConnector` (line 27, internal)

**Structs:**

- `GomaSessionAccessToken` (line 11, internal)
- `GomaUserCredentials` (line 22, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Goma/APIs/GomaAPIPromotionsClient.swift

**Classes:**

- `GomaAPIPromotionsCache` (line 11, internal)
- `GomaAPIPromotionsClient` (line 69, internal)

**Structs:**

- `CacheEntry` (line 15, private)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/GomaModels+InitialDump.swift

**Structs:**

- `InitialDump` (line 13, internal)
- `PromotionsContent` (line 25, internal)
- `HighlightedEventData` (line 51, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/Betting/PromotedBetslips.swift

**Structs:**

- `PromotedBetslipsBatchResponse` (line 11, public)
- `PromotedBetslip` (line 15, public)
- `PromotedBetslipSelection` (line 27, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/Content/CMSInitialDump.swift

**Structs:**

- `CMSInitialDump` (line 11, public)
- `PromotionsContent` (line 21, public)
- `TopImageCardPointer` (line 73, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/Content/HomeWidgets/PromotionalBanner.swift

**Structs:**

- `PromotionalBannersResponse` (line 10, public)
- `PromotionalBanner` (line 14, public)

**Enums:**

- `BannerSpecialAction` (line 26, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/Social/UserProfileInfo.swift

**Structs:**

- `UserProfileInfo` (line 11, public)
- `UserProfileRanking` (line 30, public)
- `UserProfileSportsData` (line 43, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/Events/FeaturedTip.swift

**Structs:**

- `FeaturedTip` (line 12, public)
- `FeaturedTipSelection` (line 41, public)
- `FeaturedTipUser` (line 53, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### EveryMatrixClient/TSLibrary/TSManager.swift

**Classes:**

- `TSManager` (line 22, internal)

**Enums:**

- `TSSubscriptionContent` (line 15, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### EveryMatrixClient/TSLibrary/WAMP/Transport/WebSocketSSWampTransport.swift

**Classes:**

- `WebSocketSSWampTransport` (line 12, internal)

**Enums:**

- `WebsocketMode` (line 14, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### GomaAssets/Sources/FontRegistration.swift

**Enums:**

- `FontError` (line 12, public)
- `Roboto` (line 24, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### GomaAssets/Sources/AppFont.swift

**Structs:**

- `AppFont` (line 3, public)

**Enums:**

- `Weight` (line 5, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Tools/ExternalLibs/KeychainExtras/KeychainInterface.swift

**Classes:**

- `KeychainInterface` (line 10, internal)

**Enums:**

- `KeychainError` (line 11, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Tools/ExternalLibs/Tabular/TabularBarView.swift

**Classes:**

- `TabularBarView` (line 3, public)

**Enums:**

- `BarDistribution` (line 5, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Tools/ExternalLibs/ShiftAnimations/ViewContext.swift

**Classes:**

- `ViewContext` (line 17, public)

**Enums:**

- `Superview` (line 274, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Tools/MiscHelpers/RunningPlatform.swift

**Structs:**

- `RunningPlatform` (line 12, internal)

**Enums:**

- `Model` (line 24, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Tools/MiscHelpers/Internationalization.swift

**Structs:**

- `Internationalization` (line 10, internal)

**Enums:**

- `Currency` (line 12, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Tools/MiscHelpers/CollectionViewFlowLayouts/CenterCellCollectionViewFlowLayout.swift

**Classes:**

- `SnapCenterLayout` (line 3, internal)
- `CenterCellCollectionViewFlowLayout` (line 29, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Tools/SwiftUI/XcodePreviewViewController.swift

**Structs:**

- `XcodePreviewViewController` (line 11, internal)
- `XcodePreviewView` (line 27, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Constants/Fonts.swift

**Structs:**

- `AppFont` (line 3, internal)

**Enums:**

- `AppFontType` (line 5, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/App/SecundaryMarketDetails.swift

**Classes:**

- `SecundarySportMarket` (line 13, public)
- `MarketSpecs` (line 35, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/App/PromotedBetslip.swift

**Structs:**

- `SuggestedBetslip` (line 10, internal)
- `SuggestedBetslipSelection` (line 26, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/Shared/FirebaseClientSettings.swift

**Structs:**

- `FirebaseClientSettings` (line 10, internal)
- `Locale` (line 35, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/Shared/Referrals.swift

**Structs:**

- `ReferralLink` (line 10, internal)
- `Referee` (line 16, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/Shared/ActivationAlert.swift

**Structs:**

- `ActivationAlert` (line 10, internal)

**Enums:**

- `ActivationAlertType` (line 17, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/Shared/SuggestedBetSummary.swift

**Structs:**

- `SuggestedBetCardSummary` (line 10, internal)
- `SuggestedBetSummary` (line 14, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/Shared/PaymentStatus.swift

**Enums:**

- `PaymentStatus` (line 10, internal)
- `BalanceErrorType` (line 16, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/EveryMatrixAPI/EveryMatrixModel.swift

**Structs:**

- `OperatorInfo` (line 16, internal)

**Enums:**

- `EveryMatrix` (line 10, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/EveryMatrixAPI/Betting/SystemBetResponse.swift

**Structs:**

- `SystemBetResponse` (line 10, internal)
- `SystemBetType` (line 19, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/EveryMatrixAPI/Betting/SharedBetToken.swift

**Structs:**

- `SharedBetToken` (line 10, internal)
- `BetToken` (line 23, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/EveryMatrixAPI/Locations/Location.swift

**Structs:**

- `Location` (line 11, internal)
- `EventCategory` (line 30, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/EveryMatrixAPI/Odds/Odd.swift

**Enums:**

- `Odd` (line 10, internal)
- `OddType` (line 50, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Models/EveryMatrixAPI/Events/Event.swift

**Enums:**

- `Event` (line 12, internal)
- `EventType` (line 43, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/TopCompetitionDetails/TopCompetitionDetailsViewModel.swift

**Classes:**

- `TopCompetitionDetailsViewModel` (line 13, internal)

**Enums:**

- `ContentType` (line 15, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Filters/CollapsibleView.swift

**Structs:**

- `CollapsibleView` (line 11, internal)
- `CollapsibleView_Previews` (line 74, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Filters/FilterLineView.swift

**Structs:**

- `FilterLineView` (line 10, internal)
- `FilterLineView_Previews` (line 53, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Filters/CollapsibleGroupView.swift

**Structs:**

- `CollapsibleGroupView` (line 10, internal)
- `CollapsibleGroupView_Previews` (line 19, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Home/TemplatesDataSources/ClientManagedHomeViewTemplateDataSource.swift

**Classes:**

- `ClientManagedHomeViewTemplateDataSource` (line 12, internal)

**Enums:**

- `HighlightsPresentationMode` (line 133, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Home/TemplatesDataSources/CMSManagedHomeViewTemplateDataSource.swift

**Classes:**

- `CMSManagedHomeViewTemplateDataSource` (line 12, internal)

**Enums:**

- `HighlightsPresentationMode` (line 120, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Home/TemplatesDataSources/DummyWidgetShowcaseHomeViewTemplateDataSource.swift

**Classes:**

- `DummyWidgetShowcaseHomeViewTemplateDataSource` (line 12, internal)

**Enums:**

- `HighlightsPresentationMode` (line 160, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Home/Views/StoriesFullScreenViewController.swift

**Classes:**

- `StoriesFullScreenViewController` (line 29, internal)

**Structs:**

- `StoriesFullScreenViewModel` (line 11, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Home/Views/TopCompetitionsLineTableViewCell.swift

**Classes:**

- `TopCompetitionsLineCellViewModel` (line 13, internal)
- `TopCompetitionsLineTableViewCell` (line 27, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Home/Views/CompetitionWidgetCollectionViewCell.swift

**Classes:**

- `CompetitionWidgetViewModel` (line 11, internal)
- `CompetitionWidgetCollectionViewCell` (line 31, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Home/Views/TopCompetitionItemCollectionViewCell.swift

**Classes:**

- `TopCompetitionItemCollectionViewCell` (line 20, internal)

**Structs:**

- `TopCompetitionItemCellViewModel` (line 11, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Home/Views/StoriesLineTableViewCell.swift

**Classes:**

- `StoriesLineCellViewModel` (line 11, internal)
- `StoriesLineTableViewCell` (line 20, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Home/Views/VideoPreviewCollectionViewCell.swift

**Classes:**

- `VideoPreviewCellViewModel` (line 10, internal)
- `VideoPreviewCollectionViewCell` (line 41, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Home/Views/VideoPreviewLineTableViewCell.swift

**Classes:**

- `VideoPreviewLineCellViewModel` (line 10, internal)
- `VideoPreviewLineTableViewCell` (line 39, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Home/Views/StoriesItemCollectionViewCell.swift

**Classes:**

- `StoriesItemCollectionViewCell` (line 22, internal)

**Structs:**

- `StoriesItemCellViewModel` (line 11, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Home/Views/QuickSwipeStackTableViewCell.swift

**Classes:**

- `QuickSwipeStackCellViewModel` (line 10, internal)
- `QuickSwipeStackTableViewCell` (line 48, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Home/Views/Cells/FeaturedTipCollectionViewCell.swift

**Classes:**

- `FeaturedTipCollectionViewCell` (line 11, internal)

**Structs:**

- `UserBasicInfo` (line 674, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/RecruitFriend/RecruitAFriendViewController.swift

**Classes:**

- `RecruitAFriendViewModel` (line 12, internal)
- `RecruitAFriendViewController` (line 72, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/MyFavorites/MyFavoritesViewController.swift

**Classes:**

- `MyFavoritesViewController` (line 11, internal)

**Enums:**

- `EmptyStateType` (line 910, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/MyFavorites/DataSources/MyFavoriteMatchesDataSource.swift

**Classes:**

- `MyFavoriteMatchesDataSource` (line 12, internal)

**Structs:**

- `FavoriteSportMatches` (line 223, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/MyFavorites/ViewModels/MyFavoritesViewModel.swift

**Classes:**

- `MyFavoritesViewModel` (line 13, internal)

**Enums:**

- `FavoriteListType` (line 37, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/MyFavorites/ViewModels/MyGamesViewModel.swift

**Classes:**

- `MyGamesViewModel` (line 12, internal)

**Enums:**

- `MyGamesFilterType` (line 49, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/CompetitionsList/CompetitionFilterHeaderView.swift

**Classes:**

- `CompetitionFilterHeaderViewModel` (line 10, internal)
- `CompetitionFilterHeaderView` (line 14, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/CompetitionsList/CompetitionsFiltersView.swift

**Classes:**

- `CompetitionsFiltersView` (line 13, internal)

**Enums:**

- `SizeState` (line 115, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/AnonymousSideMenu/AnonymousSideMenuViewController.swift

**Classes:**

- `AnonymousSideMenuViewController` (line 16, internal)

**Structs:**

- `AnonymousSideMenuViewModel` (line 12, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLive_backup/DataSources/PopularMatchesDataSource.swift

**Classes:**

- `PopularMatchesDataSource` (line 18, internal)

**Enums:**

- `PreLiveDataSourceState` (line 12, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLive_backup/DataSources/TodayMatchesDataSource.swift

**Classes:**

- `TodayMatchesDataSource` (line 12, internal)

**Structs:**

- `DaysRange` (line 14, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLive_backup/ViewModels/MatchStatsViewModel.swift

**Classes:**

- `MatchStatsViewModel` (line 17, internal)

**Enums:**

- `MatchStatsType` (line 11, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLive_backup/Cells/ActivationAlertCollectionViewCell.swift

**Classes:**

- `ActivationAlertCollectionViewCell` (line 10, internal)

**Enums:**

- `AlertType` (line 21, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLive_backup/Cells/MatchWidgetContainerTableViewCell.swift

**Classes:**

- `MatchWidgetContainerTableViewModel` (line 11, internal)
- `MatchWidgetContainerTableViewCell` (line 73, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLive_backup/Cells/OddCell/OddDoubleCollectionViewCell.swift

**Classes:**

- `OddDoubleCollectionViewCell` (line 12, internal)
- `StatsWebViewController` (line 904, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLive_backup/Cells/OutrightTournaments/OutrightCompetitionLineTableViewCell.swift

**Classes:**

- `OutrightCompetitionLineViewModel` (line 11, internal)
- `OutrightCompetitionLineTableViewCell` (line 34, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLive_backup/Cells/OutrightTournaments/OutrightCompetitionWidgetCollectionViewCell.swift

**Classes:**

- `OutrightCompetitionWidgetViewModel` (line 11, internal)
- `OutrightCompetitionWidgetCollectionViewCell` (line 23, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLive_backup/Cells/LargeOutrightTournaments/OutrightCompetitionLargeLineTableViewCell.swift

**Classes:**

- `OutrightCompetitionLargeLineViewModel` (line 11, internal)
- `OutrightCompetitionLargeLineTableViewCell` (line 34, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLive_backup/Cells/LargeOutrightTournaments/OutrightCompetitionLargeWidgetCollectionViewCell.swift

**Classes:**

- `OutrightCompetitionLargeWidgetViewModel` (line 11, internal)
- `OutrightCompetitionLargeWidgetCollectionViewCell` (line 35, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/UserTracking/UserTrackingViewController.swift

**Classes:**

- `UserTrackingViewController` (line 16, internal)

**Structs:**

- `UserTrackingViewModel` (line 12, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/UserTracking/UserTrackingSettingsViewController.swift

**Classes:**

- `UserTrackingSettingsViewController` (line 16, internal)

**Structs:**

- `UserTrackingSettingsViewModel` (line 12, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/DebugHelper/DebugUserDefaults.swift

**Structs:**

- `DebugUserDefaults` (line 21, internal)

**Enums:**

- `DebugDefaultsKey` (line 10, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/MatchDetails/ViewModels/MatchDetailsViewModel.swift

**Classes:**

- `MatchDetailsViewModel` (line 13, internal)

**Enums:**

- `MatchMode` (line 15, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/MatchDetails/Cells/SimpleListMarketDetailTableViewCell.swift

**Classes:**

- `SimpleListMarketDetailTableViewCell` (line 10, internal)

**Enums:**

- `ColumnType` (line 27, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLiveEvents/DataSources/Matches/PopularMatchesDataSource.swift

**Classes:**

- `PopularMatchesDataSource` (line 18, internal)

**Enums:**

- `PreLiveDataSourceState` (line 12, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLiveEvents/DataSources/Matches/TodayMatchesDataSource.swift

**Classes:**

- `TodayMatchesDataSource` (line 12, internal)

**Structs:**

- `DaysRange` (line 14, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLiveEvents/ViewModels/Match/MatchStatsViewModel.swift

**Classes:**

- `MatchStatsViewModel` (line 17, internal)

**Enums:**

- `MatchStatsType` (line 11, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLiveEvents/Views/Cells/Outright/Large/OutrightCompetitionLargeLineTableViewCell.swift

**Classes:**

- `OutrightCompetitionLargeLineViewModel` (line 11, internal)
- `OutrightCompetitionLargeLineTableViewCell` (line 34, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLiveEvents/Views/Cells/Outright/Large/OutrightCompetitionLargeWidgetCollectionViewCell.swift

**Classes:**

- `OutrightCompetitionLargeWidgetViewModel` (line 11, internal)
- `OutrightCompetitionLargeWidgetCollectionViewCell` (line 35, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLiveEvents/Views/Cells/Outright/Standard/OutrightCompetitionLineTableViewCell.swift

**Classes:**

- `OutrightCompetitionLineViewModel` (line 11, internal)
- `OutrightCompetitionLineTableViewCell` (line 34, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLiveEvents/Views/Cells/Outright/Standard/OutrightCompetitionWidgetCollectionViewCell.swift

**Classes:**

- `OutrightCompetitionWidgetViewModel` (line 11, internal)
- `OutrightCompetitionWidgetCollectionViewCell` (line 23, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLiveEvents/Views/Cells/Match/MatchWidget/MatchWidgetContainerTableViewCell.swift

**Classes:**

- `MatchWidgetContainerTableViewModel` (line 11, internal)
- `MatchWidgetContainerTableViewCell` (line 73, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLiveEvents/Views/Cells/Match/Odds/OddDoubleCollectionViewCell.swift

**Classes:**

- `OddDoubleCollectionViewCell` (line 12, internal)
- `StatsWebViewController` (line 904, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/PreLiveEvents/Views/Cells/Activation/ActivationAlertCell/ActivationAlertCollectionViewCell.swift

**Classes:**

- `ActivationAlertCollectionViewCell` (line 10, internal)

**Enums:**

- `AlertType` (line 21, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Search/SearchViewModel.swift

**Classes:**

- `SearchViewModel` (line 13, internal)

**Structs:**

- `SportMatches` (line 270, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Social/Conversations/BetTicketShare/Cells/BetSelectionStateTableViewCell.swift

**Classes:**

- `BetSelectionStateTableViewCell` (line 11, internal)

**Enums:**

- `BetState` (line 476, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Social/Conversations/ConversationList/ViewModels/ConversationsViewModel.swift

**Classes:**

- `ConversationsViewModel` (line 11, internal)

**Enums:**

- `ChatroomType` (line 344, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Social/Notifications/Cells/UserNotificationTableViewCell.swift

**Classes:**

- `UserNotificationCellViewModel` (line 10, internal)
- `UserNotificationTableViewCell` (line 31, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Social/Notifications/Cells/UserNotificationInviteTableViewCell.swift

**Classes:**

- `UserNotificationInviteCellViewModel` (line 9, internal)
- `UserNotificationInviteTableViewCell` (line 30, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Social/Edits/ViewModels/EditGroupViewModel.swift

**Classes:**

- `EditGroupViewModel` (line 11, internal)

**Structs:**

- `GroupInfo` (line 200, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Quickbet/QuickBetViewController.swift

**Classes:**

- `QuickBetViewController` (line 11, internal)

**Enums:**

- `OddStatusType` (line 1064, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/SimpleCompetitionDetails/SimpleCompetitionDetailsViewModel.swift

**Classes:**

- `SimpleCompetitionDetailsViewModel` (line 13, internal)

**Enums:**

- `ContentType` (line 15, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/UserProfile/UserProfileViewController.swift

**Classes:**

- `UserProfileViewController` (line 11, internal)

**Enums:**

- `UserProfileState` (line 671, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Betslip/BetslipViewController.swift

**Classes:**

- `BetslipViewController` (line 11, internal)

**Enums:**

- `StartScreen` (line 13, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Betslip/PreSubmission/PreSubmissionBetslipViewModel.swift

**Classes:**

- `PreSubmissionBetslipViewModel` (line 12, internal)

**Structs:**

- `BonusBetslip` (line 221, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Betslip/SuggestedBets/SuggestedBetsListViewController.swift

**Classes:**

- `SuggestedBetsListViewModel` (line 11, internal)
- `SuggestedBetsListViewController` (line 71, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Betslip/SuggestedBets/SuggestedBetTableViewCell.swift

**Classes:**

- `SuggestedBetCellViewModel` (line 11, internal)
- `SuggestedBetTableViewCell` (line 15, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Bonus/BonusViewModel.swift

**Classes:**

- `BonusViewModel` (line 11, internal)

**Enums:**

- `BonusListType` (line 48, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Bonus/BonusRootViewController.swift

**Classes:**

- `BonusRootViewModel` (line 11, internal)
- `BonusRootViewController` (line 28, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Payments/PaymentsViewController.swift

**Classes:**

- `PaymentsViewModel` (line 16, internal)
- `PaymentsViewController` (line 74, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Messages/PromotionsWebViewController.swift

**Classes:**

- `PromotionsWebViewModel` (line 11, internal)
- `PromotionsWebViewController` (line 16, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Messages/MessageDetailWebViewController.swift

**Classes:**

- `MessageDetailWebViewModel` (line 13, internal)
- `MessageDetailWebViewController` (line 42, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Messages/Cells/InAppMessageTableViewCell.swift

**Classes:**

- `InAppMessageTableViewCell` (line 11, internal)

**Enums:**

- `MessageCardType` (line 393, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/VerificationCode/EmailVerificationCodeViewController.swift

**Classes:**

- `EmailVerificationCodeViewModel` (line 11, internal)
- `EmailVerificationCodeViewController` (line 32, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/VerificationCode/CodeVerificationViewController.swift

**Classes:**

- `CodeVerificationViewModel` (line 12, internal)
- `CodeVerificationViewController` (line 29, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Register/SimpleRegister/SimpleRegisterEmailCheckViewModel.swift

**Classes:**

- `SimpleRegisterEmailCheckViewModel` (line 12, internal)

**Enums:**

- `RegisterErrorType` (line 109, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Profile/CloseAccount/CloseAccountViewController.swift

**Classes:**

- `CloseAccountViewModel` (line 11, internal)
- `CloseAccountViewController` (line 49, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Profile/History/FilterHistoryViewModel.swift

**Classes:**

- `FilterHistoryViewModel` (line 10, internal)

**Enums:**

- `FilterValue` (line 14, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Profile/History/TransactionsHistoryRootViewController.swift

**Classes:**

- `TransactionsHistoryRootViewModel` (line 11, internal)
- `TransactionsHistoryRootViewController` (line 49, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Profile/History/BettingHistoryRootViewController.swift

**Classes:**

- `BettingHistoryRootViewModel` (line 11, internal)
- `BettingHistoryRootViewController` (line 52, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Profile/PasswordUpdate/PasswordUpdateViewModel.swift

**Classes:**

- `PasswordUpdateViewModel` (line 12, internal)

**Enums:**

- `PasswordState` (line 14, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Profile/LimitsManagement/ProfileLimitsManagementViewModel.swift

**Classes:**

- `ProfileLimitsManagementViewModel` (line 12, internal)

**Enums:**

- `LimitUpdateStatus` (line 666, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/Profile/LimitsManagement/ProfileLimitsManagementViewController.swift

**Classes:**

- `ProfileLimitsManagementViewController` (line 11, internal)

**Enums:**

- `PeriodValueTypeError` (line 907, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/AppSettings/Tips/TipsSettingsViewController.swift

**Classes:**

- `TipsSettingsViewModel` (line 11, internal)
- `TipsSettingsViewController` (line 55, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/AppSettings/Notifications/ViewModels/BettingNotificationViewModel.swift

**Classes:**

- `BettingNotificationViewModel` (line 11, internal)

**Enums:**

- `UserBettingOption` (line 85, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Account/AppSettings/Notifications/ViewModels/GamesNotificationViewModel.swift

**Classes:**

- `GamesNotificationViewModel` (line 11, internal)

**Enums:**

- `UserSettingOption` (line 120, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/MyTickets/MyTicketsRootViewController.swift

**Classes:**

- `MyTicketsRootViewModel` (line 11, internal)
- `MyTicketsRootViewController` (line 28, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/MyTickets/ViewModel/MyTicketCellViewModel.swift

**Classes:**

- `MyTicketCellViewModel` (line 12, internal)

**Enums:**

- `CashoutButtonState` (line 47, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/CompetitionDetails/CompetitionDetailsViewModel.swift

**Classes:**

- `CompetitionDetailsViewModel` (line 12, internal)

**Enums:**

- `ContentType` (line 14, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Tips&Rankings/ViewModels/TipsSliderViewModel.swift

**Classes:**

- `TipsSliderViewModel` (line 11, internal)

**Enums:**

- `DataType` (line 13, private)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Tips&Rankings/Rankings/Cells/ViewModels/RankingCellViewModel.swift

**Classes:**

- `RankingCellViewModel` (line 10, internal)

**Structs:**

- `Ranking` (line 38, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Tips&Rankings/Tips/ViewModels/TipsListViewModel.swift

**Classes:**

- `TipsListViewModel` (line 11, internal)

**Enums:**

- `TipsType` (line 13, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Share/Cells/SocialAppItemCollectionViewCell.swift

**Classes:**

- `SocialAppItemCollectionViewCell` (line 32, internal)

**Structs:**

- `SocialAppItemCellViewModel` (line 10, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Share/Cells/SelectChatroomTableViewCell.swift

**Classes:**

- `SelectChatroomCellViewModel` (line 11, internal)
- `SelectChatroomTableViewCell` (line 117, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Screens/Share/Cells/SocialItemCollectionViewCell.swift

**Classes:**

- `SocialItemCollectionViewCell` (line 65, internal)

**Structs:**

- `SocialItemCellViewModel` (line 10, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Views/SmoothProgressBarView.swift

**Classes:**

- `SmoothProgressBarView` (line 12, internal)
- `SmoothProgressBarAnimator` (line 125, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Views/BoostedArrowView.swift

**Classes:**

- `BoostedArrowView` (line 11, internal)
- `ArrowBoldCustomView` (line 75, private)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Views/ContainerViewController.swift

**Classes:**

- `ContainerViewController` (line 10, internal)

**Enums:**

- `ContainerType` (line 15, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Views/HeaderTextFieldView/HeaderTextFieldView.swift

**Classes:**

- `HeaderTextFieldView` (line 5, internal)

**Enums:**

- `FieldState` (line 102, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Views/BetslipErrorView/BetslipErrorView.swift

**Classes:**

- `BetslipErrorView` (line 10, internal)

**Enums:**

- `Mode` (line 16, private)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Views/SmallToolTipView/SmallToolTipViewModel.swift

**Classes:**

- `SmallToolTipViewModel` (line 3, internal)

**Enums:**

- `ToolTipType` (line 6, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Views/ChipsTypeView/ChipsTypeViewModel.swift

**Classes:**

- `ChipsTypeViewModel` (line 26, internal)

**Enums:**

- `ChipType` (line 9, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Views/UserInfo/UserInfoSimpleCardView.swift

**Classes:**

- `UserInfoSimpleCardView` (line 10, internal)

**Enums:**

- `UserProfileCardIconType` (line 148, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Views/DropDownSelectionView/HeaderDropDownSelectionView.swift

**Classes:**

- `HeaderDropDownSelectionView` (line 11, internal)

**Enums:**

- `FieldState` (line 68, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Views/DropDownSelectionView/DropDownSelectionView.swift

**Classes:**

- `DropDownSelectionView` (line 11, internal)

**Enums:**

- `FieldState` (line 61, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Views/UploadDocuments/DocumentView.swift

**Classes:**

- `DocumentView` (line 11, internal)

**Enums:**

- `UploadedFileState` (line 631, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Views/FilterRowView/FilterRowView.swift

**Classes:**

- `FilterRowView` (line 10, internal)

**Enums:**

- `ButtonType` (line 17, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Views/Questions/TripleAnswerQuestionView.swift

**Classes:**

- `TripleAnswerQuestionView` (line 12, internal)

**Enums:**

- `MultipleAnswerChoice` (line 340, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Services/_SportTypeStore.swift

**Classes:**

- `LegacySportTypeStore` (line 13, internal)

**Structs:**

- `LiveSport` (line 194, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Services/AppSession.swift

**Classes:**

- `AppSession` (line 11, internal)

**Structs:**

- `BusinessModulesManager` (line 55, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Services/GeoLocationManager.swift

**Classes:**

- `GeoLocationManager` (line 33, internal)

**Enums:**

- `GeoLocationStatus` (line 11, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Services/RealtimeSocketClient.swift

**Classes:**

- `RealtimeSocketClient` (line 13, internal)

**Enums:**

- `MaintenanceModeType` (line 15, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Services/Networking/Definitions/NetworkModels.swift

**Structs:**

- `MessageNetworkResponse` (line 10, internal)
- `NetworkResponse` (line 25, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Services/Networking/Definitions/Authenticator.swift

**Classes:**

- `Authenticator` (line 16, internal)

**Enums:**

- `AuthenticationError` (line 11, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Services/Networking/Definitions/NetworkError.swift

**Structs:**

- `NetworkError` (line 19, internal)

**Enums:**

- `NetworkErrorCode` (line 10, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Services/Networking/Definitions/Endpoint.swift

**Structs:**

- `HTTP` (line 43, internal)

**Enums:**

- `Method` (line 44, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Services/Networking/Goma/GomaGamingSocialServiceClient.swift

**Classes:**

- `GomaGamingSocialServiceClient` (line 13, internal)

**Enums:**

- `SocketError` (line 735, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Services/Helpers/Logger.swift

**Classes:**

- `LoggerService` (line 18, internal)

**Enums:**

- `LogType` (line 20, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Services/Helpers/AnalyticsClient.swift

**Structs:**

- `AnalyticsClient` (line 12, internal)

**Enums:**

- `Event` (line 14, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Services/Helpers/CurrencyHelper.swift

**Structs:**

- `CurrencyFormater` (line 10, internal)

**Enums:**

- `CurrencyType` (line 93, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Core/Services/Helpers/OddFormatter.swift

**Structs:**

- `OddConverter` (line 24, internal)

**Enums:**

- `OddFormatter` (line 10, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### Theming/Sources/AppFont.swift

**Structs:**

- `AppFont` (line 3, public)

**Enums:**

- `AppFontType` (line 5, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/RegisterFlow.swift

**Structs:**

- `RegisterFlow` (line 1, public)

**Enums:**

- `FlowType` (line 3, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/Shared/RegisterStepView.swift

**Classes:**

- `RegisterStepView` (line 25, public)

**Structs:**

- `RegisterStepViewModel` (line 15, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/Shared/AvatarAssets.swift

**Enums:**

- `AvatarBrand` (line 11, public)
- `AvatarAssets` (line 25, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/Betsson/UserRegisterEnvelop.swift

**Structs:**

- `UserRegisterEnvelop` (line 12, public)

**Enums:**

- `Gender` (line 14, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/Betsson/SteppedRegistrationViewController.swift

**Classes:**

- `SteppedRegistrationViewModel` (line 16, public)
- `SteppedRegistrationViewController` (line 291, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/Betsson/AdditionalRegisterSteps/RegisterFeedbackViewController.swift

**Classes:**

- `RegisterFeedbackViewController` (line 21, public)

**Structs:**

- `RegisterFeedbackViewModel` (line 13, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/PromoCodeFormStepView.swift

**Classes:**

- `PromoCodeFormStepViewModel` (line 15, internal)
- `PromoCodeFormStepView` (line 49, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/TermsCondFormStepView.swift

**Classes:**

- `TermsCondFormStepViewModel` (line 14, internal)
- `TermsCondFormStepView` (line 53, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/NamesFormStepView.swift

**Classes:**

- `NamesFormStepView` (line 66, internal)

**Structs:**

- `NamesFormStepViewModel` (line 14, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/AvatarFormStepView.swift

**Classes:**

- `AvatarFormStepViewModel` (line 14, internal)
- `AvatarFormStepView` (line 67, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Betsson/ContactsFormStepView.swift

**Classes:**

- `ContactsFormStepViewModel` (line 19, internal)
- `ContactsFormStepView` (line 256, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Goma/MultibetPersonalInfoFormStepView.swift

**Classes:**

- `MultibetPersonalInfoFormStepViewModel` (line 15, internal)
- `MultibetPersonalInfoFormStepView` (line 174, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### RegisterFlow/Sources/RegisterFlow/Betsson/Forms/Goma/MultibetAvatarFormStepView.swift

**Classes:**

- `MultibetAvatarFormStepViewModel` (line 14, internal)
- `MultibetAvatarFormStepView` (line 67, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### HeaderTextField/Sources/CurrencyFormater.swift

**Structs:**

- `CurrencyFormater` (line 10, internal)

**Enums:**

- `CurrencyType` (line 91, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Package.swift

**Structs:**

- `CustomTarget` (line 57, internal)

**Enums:**

- `Kind` (line 58, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Tests/HashTreeCollectionsTests/Utilities.swift

**Structs:**

- `IntDataGenerator` (line 46, internal)
- `ColliderDataGenerator` (line 65, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Tests/HashTreeCollectionsTests/Colliders.swift

**Structs:**

- `Collider` (line 14, internal)
- `RawCollider` (line 56, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Tests/HashTreeCollectionsTests/TreeHashedCollections Fixtures.swift

**Structs:**

- `Fixture` (line 302, internal)

**Enums:**

- `FixtureFlavor` (line 126, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Tests/OrderedCollectionsTests/OrderedDictionary/OrderedDictionary Tests.swift

**Classes:**

- `OrderedDictionaryTests` (line 22, internal)

**Structs:**

- `StatEvent` (line 141, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Tests/OrderedCollectionsTests/OrderedSet/OrderedSet Diffing Tests.swift

**Classes:**

- `MeasuringHashable` (line 20, internal)
- `OrderedSetDiffingTests` (line 41, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Tests/OrderedCollectionsTests/OrderedSet/OrderedSetTests.swift

**Classes:**

- `OrderedSetTests` (line 22, internal)

**Structs:**

- `SampleRanges` (line 1293, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Tests/HeapTests/HeapTests.swift

**Classes:**

- `HeapTests` (line 43, internal)

**Structs:**

- `Task` (line 95, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Tests/_CollectionsTestSupport/AssertionContexts/TestContext.swift

**Classes:**

- `TestContext` (line 14, public)

**Structs:**

- `Entry` (line 55, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Tests/_CollectionsTestSupport/Utilities/IndexRangeCollection.swift

**Structs:**

- `IndexRangeCollection` (line 12, public)
- `Index` (line 28, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Tests/_CollectionsTestSupport/MinimalTypes/_CollectionState.swift

**Classes:**

- `_CollectionState` (line 15, internal)

**Enums:**

- `IndexInvalidationStrategy` (line 31, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Tests/_CollectionsTestSupport/MinimalTypes/MinimalSequence.swift

**Structs:**

- `MinimalSequence` (line 47, public)

**Enums:**

- `UnderestimatedCountBehavior` (line 15, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Tests/_CollectionsTestSupport/MinimalTypes/MinimalIterator.swift

**Classes:**

- `_MinimalIteratorSharedState` (line 16, internal)

**Structs:**

- `MinimalIterator` (line 36, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Tests/DequeTests/DequeTests.swift

**Classes:**

- `DequeTests` (line 20, internal)

**Structs:**

- `TestError` (line 196, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Benchmarks/Sources/Benchmarks/CustomGenerators.swift

**Classes:**

- `Box` (line 14, internal)

**Structs:**

- `Large` (line 16, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Benchmarks/Sources/Benchmarks/BigStringBenchmarks.swift

**Structs:**

- `NativeStringInput` (line 56, internal)
- `BridgedStringInput` (line 64, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/OrderedCollections/OrderedDictionary/OrderedDictionary+Elements.SubSequence.swift

**Structs:**

- `SubSequence` (line 22, public)
- `Iterator` (line 109, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/OrderedCollections/HashTable/_HashTable.swift

**Classes:**

- `Storage` (line 30, internal)

**Structs:**

- `_HashTable` (line 14, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/InternalCollectionsUtilities/UnsafeBitSet/autogenerated/_UnsafeBitSet+Index.swift

**Structs:**

- `Index` (line 27, internal)
- `Index` (line 107, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/InternalCollectionsUtilities/UnsafeBitSet/autogenerated/_UnsafeBitSet+_Word.swift

**Structs:**

- `_Word` (line 28, internal)
- `_Word` (line 337, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/DequeModule/_UnsafeWrappedBuffer.swift

**Structs:**

- `_UnsafeWrappedBuffer` (line 18, internal)
- `_UnsafeMutableWrappedBuffer` (line 61, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/BigString/Basics/BigString.swift

**Structs:**

- `BigString` (line 16, public)
- `BigString` (line 31, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/BigString/Views/BigString+UnicodeScalarView.swift

**Structs:**

- `UnicodeScalarView` (line 20, public)
- `Iterator` (line 95, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/BigString/Views/BigString+UTF8View.swift

**Structs:**

- `UTF8View` (line 16, public)
- `Iterator` (line 57, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/BigString/Views/BigSubstring+UnicodeScalarView.swift

**Structs:**

- `UnicodeScalarView` (line 16, public)
- `Iterator` (line 113, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/BigString/Views/BigSubstring.swift

**Structs:**

- `BigSubstring` (line 15, public)
- `Iterator` (line 149, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/BigString/Views/BigSubstring+UTF16View.swift

**Structs:**

- `UTF16View` (line 16, public)
- `Iterator` (line 109, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/BigString/Views/BigString+UTF16View.swift

**Structs:**

- `UTF16View` (line 16, public)
- `Iterator` (line 57, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/BigString/Views/BigSubstring+UTF8View.swift

**Structs:**

- `UTF8View` (line 16, public)
- `Iterator` (line 83, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/Rope/Basics/Rope+_Storage.swift

**Classes:**

- `_Storage` (line 38, internal)

**Structs:**

- `_RopeStorageHeader` (line 14, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/RopeModule/Rope/Basics/Rope+_Node.swift

**Structs:**

- `_Node` (line 19, internal)
- `_ModifyState` (line 555, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/BitCollections/BitArray/BitArray+ChunkedBitsIterators.swift

**Structs:**

- `_ChunkedBitsForwardIterator` (line 16, internal)
- `_ChunkedBitsBackwardIterator` (line 51, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/HashTreeCollections/HashNode/_HashTreeIterator.swift

**Structs:**

- `_HashTreeIterator` (line 14, internal)
- `_Opaque` (line 16, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/HashTreeCollections/HashNode/_HashNode+Builder.swift

**Structs:**

- `Builder` (line 15, internal)

**Enums:**

- `Kind` (line 20, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/HashTreeCollections/HashNode/_Bitmap.swift

**Structs:**

- `_Bitmap` (line 19, internal)
- `Iterator` (line 191, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/HashTreeCollections/HashNode/_HashNode+Subtree Modify.swift

**Structs:**

- `ValueUpdateState` (line 31, internal)
- `DefaultedValueUpdateState` (line 163, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/swift-collections/Sources/HashTreeCollections/TreeDictionary/TreeDictionary+Values.swift

**Structs:**

- `Values` (line 19, public)
- `Iterator` (line 67, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/Starscream/Tests/MockTransport.swift

**Classes:**

- `MockTransport` (line 26, public)
- `MockSecurity` (line 70, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/Starscream/Tests/MockServer.swift

**Classes:**

- `MockConnection` (line 26, public)
- `MockServer` (line 110, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/Starscream/Sources/Transport/FoundationTransport.swift

**Classes:**

- `FoundationTransport` (line 31, public)

**Enums:**

- `FoundationTransportError` (line 25, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/Starscream/Sources/Transport/TCPTransport.swift

**Classes:**

- `TCPTransport` (line 32, public)

**Enums:**

- `TCPTransportError` (line 27, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/Starscream/Sources/Security/Security.swift

**Enums:**

- `SecurityErrorCode` (line 25, public)
- `PinningState` (line 30, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/Starscream/Sources/Security/FoundationSecurity.swift

**Classes:**

- `FoundationSecurity` (line 30, public)

**Enums:**

- `FoundationSecurityError` (line 26, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/Starscream/Sources/Server/Server.swift

**Enums:**

- `ConnectionEvent` (line 25, public)
- `ServerEvent` (line 43, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/Starscream/Sources/Server/WebSocketServer.swift

**Classes:**

- `WebSocketServer` (line 30, public)
- `ServerConnection` (line 91, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/.build/checkouts/Starscream/Sources/Framer/FrameCollector.swift

**Classes:**

- `FrameCollector` (line 30, public)

**Enums:**

- `Event` (line 31, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Tests/ServicesProviderTests/Providers/Sportsradar/APIs/Events-Poseidon/SportsMergerTests.swift

**Classes:**

- `URLProtocolMock` (line 14, internal)
- `SportsMergerTests` (line 141, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Tests/ServicesProviderTests/Providers/Goma/Integration/Helpers/JSONLoader.swift

**Classes:**

- `JSONLoader` (line 5, internal)

**Enums:**

- `JSONLoaderError` (line 8, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/ServiceProviderClient.swift

**Classes:**

- `ServicesProviderClient` (line 5, public)

**Enums:**

- `ProviderType` (line 7, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/ServicesProviderConfiguration.swift

**Structs:**

- `ServicesProviderConfiguration` (line 10, public)

**Enums:**

- `Environment` (line 12, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/SportRadarSessionCoordinator.swift

**Classes:**

- `SportRadarSessionCoordinator` (line 21, internal)

**Enums:**

- `SessionCoordinatorKey` (line 15, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/APIs/PAM-Omega/OmegaSession.swift

**Structs:**

- `OmegaSessionAccessToken` (line 11, internal)
- `OmegaSessionCredentials` (line 16, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/SportRadarModels+Scores.swift

**Enums:**

- `Score` (line 12, internal)
- `ActivePlayerServe` (line 172, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/SportRadarModels+Transactions.swift

**Structs:**

- `TransactionsHistoryResponse` (line 12, internal)
- `TransactionDetail` (line 23, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/HomeWidgets/HeadlineResponse.swift

**Structs:**

- `HeadlineResponse` (line 12, internal)
- `HeadlineItem` (line 24, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/Limits/SportRadarModels+ResponsibleGamingLimitsResponse.swift

**Structs:**

- `ResponsibleGamingLimitsResponse` (line 12, internal)
- `ResponsibleGamingLimit` (line 22, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/PromotionStories/SportRadarModels+PromotionalStoriesResponse.swift

**Structs:**

- `PromotionalStoriesResponse` (line 12, internal)
- `PromotionalStory` (line 21, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/Withdrawals/SportRadarModels+ProcessWithdrawalResponse.swift

**Structs:**

- `ProcessWithdrawalResponse` (line 12, internal)
- `PrepareWithdrawalResponse` (line 25, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/GomaModels+Users.swift

**Structs:**

- `UserWallet` (line 12, internal)
- `UserNotificationsSettings` (line 33, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Network/HTTPTypes.swift

**Structs:**

- `HTTP` (line 10, internal)

**Enums:**

- `Method` (line 11, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Network/WebSocketClientStream.swift

**Classes:**

- `WebSocketClientStream` (line 20, public)

**Enums:**

- `WebSocketAsyncEventMessage` (line 11, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/Payments/Transactions/TransactionTypes.swift

**Enums:**

- `TransactionType` (line 10, public)
- `EscrowType` (line 12, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/Payments/Withdrawals/ProcessWithdrawalResponse.swift

**Structs:**

- `ProcessWithdrawalResponse` (line 10, public)
- `PrepareWithdrawalResponse` (line 23, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/Content/HomeWidgets/PromotedSport.swift

**Structs:**

- `PromotedSport` (line 10, public)
- `MarketGroupPromotedSport` (line 30, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/Content/Promotions/ProChoice.swift

**Structs:**

- `ProChoiceCardPointer` (line 13, public)
- `ProChoiceMarketCard` (line 48, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/Content/PromotionStories/PromotionalStoriesResponse.swift

**Structs:**

- `PromotionalStoriesResponse` (line 10, public)
- `PromotionalStory` (line 19, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/User/UserConsents/UserConsentInfo.swift

**Structs:**

- `ConsentInfo` (line 10, public)
- `UserConsentInfo` (line 23, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/Common/ResponsibleGamingLimitsResponse.swift

**Structs:**

- `ResponsibleGamingLimitsResponse` (line 10, public)
- `ResponsibleGamingLimit` (line 20, public)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

### ServicesProvider/Sources/ServicesProvider/Models/Events/SportType.swift

**Structs:**

- `SportType` (line 10, public)

**Enums:**

- `SportTypeInfo` (line 57, internal)

**Recommendation**: Consider splitting these types into separate files for better maintainability.

## All Types Summary

| Type | Count | Percentage |
|------|-------|------------|
| Classes | 905 | 39.0% |
| Structs | 1014 | 43.7% |
| Enums | 403 | 17.4% |
