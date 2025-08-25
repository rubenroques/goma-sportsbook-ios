//
//  ComponentsTableViewController.swift
//  TestCase
//
//  Created by Ruben Roques on 19/05/2025.
//

import UIKit
import GomaUI

// MARK: - Component Model
struct UIComponent {
    let title: String
    let description: String
    let viewController: UIViewController.Type
    let previewFactory: () -> UIView
}

// MARK: - Table View Controller
class ComponentsTableViewController: UITableViewController {

    // MARK: - Properties
    private let components: [UIComponent] = [
        UIComponent(
            title: "Casino Category Section",
            description: "MVVM-compliant component combining CasinoCategoryBarView with horizontal collection of CasinoGameCardViews, featuring child ViewModel management and reactive updates",
            viewController: CasinoCategorySectionViewController.self,
            previewFactory: {
                let viewModel = MockCasinoCategorySectionViewModel.newGamesSection
                return CasinoCategorySectionView(viewModel: viewModel)
            }
        ),
        UIComponent(
            title: "Recently Played Games",
            description: "Horizontal collection view displaying recently played casino games with PillView header, image loading, and game selection callbacks",
            viewController: RecentlyPlayedGamesViewController.self,
            previewFactory: {
                let viewModel = MockRecentlyPlayedGamesViewModel.defaultRecentlyPlayed
                return RecentlyPlayedGamesView(viewModel: viewModel)
            }
        ),
        UIComponent(
            title: "Casino Category Bar",
            description: "Simple category bar with title label on the left and action button with count and chevron on the right",
            viewController: CasinoCategoryBarViewController.self,
            previewFactory: {
                let viewModel = MockCasinoCategoryBarViewModel.newGames
                return CasinoCategoryBarView(viewModel: viewModel)
            }
        ),
        UIComponent(
            title: "Casino Game Card",
            description: "Casino game card component with optional viewModel initialization, image loading, thunderbolt ratings in capsule, and runtime configuration support",
            viewController: CasinoGameCardViewController.self,
            previewFactory: {
                let viewModel = MockCasinoGameCardViewModel.plinkGoal
                return CasinoGameCardView(viewModel: viewModel)
            }
        ),
        UIComponent(
            title: "Pre-Live Match Card",
            description: "Complete pre-live match card assembling MatchHeader, MatchParticipants, MarketInfoLine and MarketOutcomes components with proper spacing and layout",
            viewController: TallOddsMatchCardViewController.self,
            previewFactory: {
                let viewModel = MockTallOddsMatchCardViewModel.premierLeagueMock
                let matchCardView = TallOddsMatchCardView(viewModel: viewModel)
                matchCardView.backgroundColor = StyleProvider.Color.backgroundColor
                matchCardView.layer.cornerRadius = 8
                return matchCardView
            }
        ),
        UIComponent(
            title: "Single Button Banner",
            description: "Customizable banner with full-width background image, message text, and optional action button for promotional content",
            viewController: SingleButtonBannerViewController.self,
            previewFactory: {
                let viewModel = MockSingleButtonBannerViewModel.defaultMock
                let bannerView = SingleButtonBannerView(viewModel: viewModel)
                bannerView.layer.cornerRadius = 8
                bannerView.clipsToBounds = true
                return bannerView
            }
        ),
        UIComponent(
            title: "Top Banner Slider",
            description: "Horizontal collection view container for TopBannerProtocol items with page indicators, auto-scroll, and smooth transitions",
            viewController: TopBannerSliderViewController.self,
            previewFactory: {
                let viewModel = MockTopBannerSliderViewModel.defaultMock
                let sliderView = TopBannerSliderView(viewModel: viewModel)
                sliderView.layer.cornerRadius = 8
                sliderView.clipsToBounds = true
                return sliderView
            }
        ),
        UIComponent(
            title: "Adaptive Tab Bar",
            description: "Dynamic tab bar with multiple configurations and nested navigation",
            viewController: AdaptiveTabBarViewController.self,
            previewFactory: {
                let viewModel = MockAdaptiveTabBarViewModel.defaultMock
                return AdaptiveTabBarView(viewModel: viewModel)
            }
        ),
        UIComponent(
            title: "Quick Links Bar",
            description: "Simple horizontal bar with tap actions for quick access items",
            viewController: QuickLinksTabBarViewController.self,
            previewFactory: {
                let viewModel = MockQuickLinksTabBarViewModel.gamingMockViewModel
                return QuickLinksTabBarView(viewModel: viewModel)
            }
        ),
        UIComponent(
            title: "Multi Widget Toolbar",
            description: "Highly configurable toolbar with various widgets and dynamic layouts",
            viewController: MultiWidgetToolbarViewController.self,
            previewFactory: {
                let viewModel = MockMultiWidgetToolbarViewModel.defaultMock
                return MultiWidgetToolbarView(viewModel: viewModel)
            }
        ),
        UIComponent(
            title: "Statistics Widget",
            description: "Web-based statistics widget with paginated scroll view, tab navigation, and multiple content types for match statistics",
            viewController: StatisticsWidgetViewController.self,
            previewFactory: {
                let viewModel = MockStatisticsWidgetViewModel.footballMatch
                let statisticsWidget = StatisticsWidgetView(viewModel: viewModel)
                statisticsWidget.backgroundColor = StyleProvider.Color.backgroundTertiary
                statisticsWidget.layer.cornerRadius = 8
                statisticsWidget.clipsToBounds = true
                return statisticsWidget
            }
        ),
        UIComponent(
            title: "Wallet Widget",
            description: "Compact wallet balance display with deposit action button",
            viewController: WalletWidgetViewController.self,
            previewFactory: {
                let viewModel = MockWalletWidgetViewModel.defaultMock
                return WalletWidgetView(viewModel: viewModel)
            }
        ),
        UIComponent(
            title: "Match Header",
            description: "Sports competition header with country flag, sport icon, and favorite toggle functionality",
            viewController: MatchHeaderViewController.self,
            previewFactory: {
                let viewModel = MockMatchHeaderViewModel.premierLeagueHeader
                let headerView = MatchHeaderView(viewModel: viewModel)
                headerView.backgroundColor = StyleProvider.Color.backgroundColor.withAlphaComponent(0.8)
                headerView.layer.cornerRadius = 4
                return headerView
            }
        ),
        UIComponent(
            title: "Score View",
            description: "Flexible sports match score display with multiple cells and visual styles",
            viewController: ScoreViewController.self,
            previewFactory: {
                let viewModel = MockScoreViewModel.tennisMatch
                let scoreView = ScoreView()
                scoreView.configure(with: viewModel)
                scoreView.backgroundColor = StyleProvider.Color.backgroundColor
                scoreView.layer.cornerRadius = 8
                return scoreView
            }
        ),
        UIComponent(
            title: "Pill Selector Bar",
            description: "Horizontal scrollable collection of pills with fade effects and interactive selection",
            viewController: PillSelectorBarViewController.self,
            previewFactory: {
                let viewModel = MockPillSelectorBarViewModel.marketFilters
                let pillSelectorBar = PillSelectorBarView(viewModel: viewModel)
                pillSelectorBar.backgroundColor = StyleProvider.Color.backgroundSecondary
                pillSelectorBar.layer.cornerRadius = 8
                return pillSelectorBar
            }
        ),
        UIComponent(
            title: "Pill View",
            description: "Customizable pill-shaped selector with icon and selection state support",
            viewController: PillItemViewController.self,
            previewFactory: {
                let containerView = UIView()
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.spacing = 8
                stackView.alignment = .center
                stackView.distribution = .fill

                // Create sample pills
                let footballPill = PillItemView(viewModel: MockPillItemViewModel(
                    pillData: PillData(
                        id: "football",
                        title: "Football",
                        leftIconName: "sportscourt.fill",
                        showExpandIcon: true,
                        isSelected: true
                    )
                ))

                let popularPill = PillItemView(viewModel: MockPillItemViewModel(
                    pillData: PillData(
                        id: "popular",
                        title: "Popular",
                        leftIconName: "flame.fill",
                        showExpandIcon: false,
                        isSelected: false
                    )
                ))

                stackView.addArrangedSubview(footballPill)
                stackView.addArrangedSubview(popularPill)

                containerView.addSubview(stackView)
                stackView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                    stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                    stackView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 8),
                    stackView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -8)
                ])

                return containerView
            }
        ),
        UIComponent(
            title: "Capsule View",
            description: "Versatile pill-shaped containers with automatic shape management for badges, status indicators, count labels, and other capsule UI elements",
            viewController: CapsuleViewController.self,
            previewFactory: {
                let containerView = UIView()
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.spacing = 8
                stackView.alignment = .center
                stackView.distribution = .fill

                // Create sample capsules
                let liveCapsule = CapsuleView(viewModel: MockCapsuleViewModel.liveBadge)
                let countCapsule = CapsuleView(viewModel: MockCapsuleViewModel.countBadge)
                let statusCapsule = CapsuleView(viewModel: MockCapsuleViewModel.statusSuccess)

                stackView.addArrangedSubview(liveCapsule)
                stackView.addArrangedSubview(countCapsule)
                stackView.addArrangedSubview(statusCapsule)

                containerView.addSubview(stackView)
                stackView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                    stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                    stackView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 8),
                    stackView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -8)
                ])

                return containerView
            }
        ),
        UIComponent(
            title: "Bordered Text Field",
            description: "Modern text input with floating labels, validation states, and real-time observation",
            viewController: BorderedTextFieldViewController.self,
            previewFactory: {
                let viewModel = MockBorderedTextFieldViewModel.emailField
                return BorderedTextFieldView(viewModel: viewModel)
            }
        ),
        UIComponent(
            title: "Match Date Navigation Bar",
            description: "Navigation bar with match timing information, supporting both pre-match date/time display and live match status with highlighted pills",
            viewController: MatchDateNavigationBarViewController.self,
            previewFactory: {
                let viewModel = MockMatchDateNavigationBarViewModel.liveMock
                return MatchDateNavigationBarView(viewModel: viewModel)
            }
        ),
        UIComponent(
            title: "Match Header Compact",
            description: "Compact header displaying match teams, competition breadcrumb, and optional statistics button with tappable elements",
            viewController: MatchHeaderCompactViewController.self,
            previewFactory: {
                let viewModel = MockMatchHeaderCompactViewModel.default
                return MatchHeaderCompactView(viewModel: viewModel)
            }
        ),
        UIComponent(
            title: "Market Group Selector Tab",
            description: "Horizontal scrollable tab bar for betting market groups with dynamic content and selection coordination",
            viewController: MarketGroupSelectorTabViewController.self,
            previewFactory: {
                let viewModel = MockMarketGroupSelectorTabViewModel.standardSportsMarkets
                return MarketGroupSelectorTabView(viewModel: viewModel)
            }
        ),
        UIComponent(
            title: "Time Slider Filter",
            description: "Interactive time-based filter with slider and tappable labels for discrete time range selection",
            viewController: TimeSliderFilterViewController.self,
            previewFactory: {
//                let viewModel = MockTimeSliderFilterViewModel.eightHoursMock
//                return TimeSliderFilterView(viewModel: viewModel)
                let timeOptions = [
                    TimeOption(title: "All", value: 0),
                    TimeOption(title: "1h", value: 1),
                    TimeOption(title: "8h", value: 2),
                    TimeOption(title: "Today", value: 3),
                    TimeOption(title: "48h", value: 4),
                ]
                
                let viewModel = MockTimeSliderViewModel(title: "Filter by Time", timeOptions: timeOptions)
                
                return TimeSliderView(viewModel: viewModel)
            }
        ),
        UIComponent(
            title: "Custom Slider",
            description: "Highly customizable slider with precise visual control, discrete steps, and smooth animations",
            viewController: CustomSliderViewController.self,
            previewFactory: {
                let viewModel = MockCustomSliderViewModel.midPositionMock
                return CustomSliderView(viewModel: viewModel)
            }
        ),
        UIComponent(
            title: "Market Outcomes Line",
            description: "Flexible betting market outcomes display with selection states, odds changes, and multiple display modes",
            viewController: MarketOutcomesLineViewController.self,
            previewFactory: {
                let viewModel = MockMarketOutcomesLineViewModel.threeWayMarket
                let marketView = MarketOutcomesLineView(viewModel: viewModel)
                marketView.backgroundColor = StyleProvider.Color.backgroundColor
                marketView.layer.cornerRadius = 4.5
                return marketView
            }
        ),
        UIComponent(
            title: "Market Outcomes Multi-Line",
            description: "Multiple betting market outcome lines in vertical layout with 2-column and 3-column support, independent line suspension",
            viewController: MarketOutcomesMultiLineViewController.self,
            previewFactory: {
                let viewModel = MockMarketOutcomesMultiLineViewModel.overUnderMarketGroup
                let multiLineView = MarketOutcomesMultiLineView(viewModel: viewModel)
                multiLineView.backgroundColor = StyleProvider.Color.backgroundColor
                multiLineView.layer.cornerRadius = 4.5
                return multiLineView
            }
        ),
        UIComponent(
            title: "Outcome Item",
            description: "Reusable component for individual betting market outcomes with selection states, odds change animations, and accessibility support",
            viewController: OutcomeItemViewController.self,
            previewFactory: {
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.spacing = 8
                stackView.distribution = .fillEqually

                let homeView = OutcomeItemView(viewModel: MockOutcomeItemViewModel.homeOutcome)
                let drawView = OutcomeItemView(viewModel: MockOutcomeItemViewModel.drawOutcome)
                let awayView = OutcomeItemView(viewModel: MockOutcomeItemViewModel.awayOutcome)

                stackView.addArrangedSubview(homeView)
                stackView.addArrangedSubview(drawView)
                stackView.addArrangedSubview(awayView)

                return stackView
            }
        ),
        UIComponent(
            title: "Main Filter Bar View",
            description: "A simple bar with a main filter view",
            viewController: GeneralFilterViewController.self,
            previewFactory: {
                let mainFilter = MainFilterItem(type: .mainFilter, title: "Filter", icon: "filter_icon", actionIcon: "right_arrow_icon")
                let viewModel = MockMainFilterPillViewModel(mainFilter: mainFilter)
                let mainFilterView = MainFilterPillView(viewModel: viewModel)
                mainFilterView.backgroundColor = StyleProvider.Color.backgroundColor
                mainFilterView.layer.cornerRadius = 4.5
                return mainFilterView
            }
        ),
        UIComponent(
            title: "Floating Overlay",
            description: "Context-aware floating message overlay with smooth animations, auto-dismiss timer, and tap-to-dismiss functionality",
            viewController: FloatingOverlayViewController.self,
            previewFactory: {
                let viewModel = MockFloatingOverlayViewModel.alwaysVisible
                let overlay = FloatingOverlayView(viewModel: viewModel)
                overlay.layer.shadowOpacity = 0.1 // Reduce shadow for preview
                return overlay
            }
        ),
        UIComponent(
            title: "Match Participants Info",
            description: "Flexible match participants display with horizontal/vertical layouts, live scores, serving indicators, and detailed sport-specific scoring",
            viewController: MatchParticipantsInfoViewController.self,
            previewFactory: {
                let viewModel = MockMatchParticipantsInfoViewModel.horizontalLive
                let matchView = MatchParticipantsInfoView(viewModel: viewModel)
                matchView.backgroundColor = StyleProvider.Color.backgroundSecondary
                matchView.layer.cornerRadius = 8
                matchView.layer.borderWidth = 1
                matchView.layer.borderColor = StyleProvider.Color.separatorLine.cgColor
                return matchView
            }
        ),
        UIComponent(
            title: "Market Name Pill Label",
            description: "Pill-shaped label for betting markets with customizable styles, fading line extension, loading states, and interactive capabilities",
            viewController: MarketNamePillLabelViewController.self,
            previewFactory: {
                let viewModel = MockMarketNamePillLabelViewModel.highlightedPill
                let pillView = MarketNamePillLabelView(viewModel: viewModel)
                pillView.backgroundColor = StyleProvider.Color.backgroundSecondary
                pillView.layer.cornerRadius = 4
                return pillView
            }
        ),
        UIComponent(
            title: "Sport Type Selector Item",
            description: "Individual sport item with icon and text layout, designed for use in sport selection interfaces",
            viewController: SportTypeSelectorItemViewController.self,
            previewFactory: {
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.spacing = 8
                stackView.distribution = .fillEqually
                
                let footballItem = SportTypeSelectorItemView(viewModel: MockSportTypeSelectorItemViewModel.footballMock)
                let basketballItem = SportTypeSelectorItemView(viewModel: MockSportTypeSelectorItemViewModel.basketballMock)
                
                footballItem.heightAnchor.constraint(equalToConstant: 56).isActive = true
                basketballItem.heightAnchor.constraint(equalToConstant: 56).isActive = true
                
                stackView.addArrangedSubview(footballItem)
                stackView.addArrangedSubview(basketballItem)
                
                return stackView
            }
        ),
        UIComponent(
            title: "Sport Type Selector",
            description: "Full-screen sport selection with 2-column collection view, modal presentation, and selection callbacks",
            viewController: SportTypeSelectorViewController.self,
            previewFactory: {
                let viewModel = MockSportTypeSelectorViewModel.fewSportsMock
                let selectorView = SportTypeSelectorView(viewModel: viewModel)
                selectorView.backgroundColor = StyleProvider.Color.backgroundSecondary
                selectorView.layer.cornerRadius = 8
                return selectorView
            }
        ),
        UIComponent(
            title: "Sport Games Filter",
            description: "A filter view for selecting sports, using SportGamesFilterView.",
            viewController: SportGamesFilterViewController.self,
            previewFactory: {
                let viewModel = MockSportGamesFilterViewModel(
                    title: "Sports",
                    sportFilters: [
                        SportFilter(id: "1", title: "Football", icon: "sport_icon"),
                        SportFilter(id: "2", title: "Basketball", icon: "sport_icon"),
                        SportFilter(id: "3", title: "Tennis", icon: "sport_icon"),
                        SportFilter(id: "4", title: "Voleyball", icon: "sport_icon")
                    ],
                    selectedId: "1"
                )
                let filterView = SportGamesFilterView(viewModel: viewModel)
                filterView.backgroundColor = StyleProvider.Color.backgroundColor
                filterView.layer.cornerRadius = 8
                return filterView
            }
        ),
        UIComponent(
            title: "Sort Filter View",
            description: "A filter view for sorting options, using SortFilterView.",
            viewController: SortFilterViewController.self,
            previewFactory: {
                let viewModel = MockSortFilterViewModel(
                    title: "Sort By",
                    sortOptions: [
                        SortOption(id: "1", icon: "flame.fill", title: "Popular", count: 25),
                        SortOption(id: "2", icon: "clock.fill", title: "Upcoming", count: 15),
                        SortOption(id: "3", icon: "heart.fill", title: "Favourites", count: 0)
                    ],
                    selectedId: "1"
                )
                let filterView = SortFilterView(viewModel: viewModel)
                filterView.backgroundColor = StyleProvider.Color.backgroundColor
                filterView.layer.cornerRadius = 8
                return filterView
            }
        ),
        UIComponent(
            title: "Country Leagues Filter",
            description: "A filter view for selecting country leagues, using CountryLeaguesFilterView.",
            viewController: CountryLeaguesFilterViewController.self,
            previewFactory: {
                let viewModel = MockCountryLeaguesFilterViewModel(
                    title: "Country Leagues",
                    countryLeagueOptions: [
                        CountryLeagueOptions(
                            id: "us",
                            icon: "us",
                            title: "United States",
                            leagues: [
                                LeagueOption(id: "nba", icon: nil, title: "NBA", count: 30),
                                LeagueOption(id: "wnba", icon: nil, title: "WNBA", count: 12)
                            ],
                            isExpanded: true
                        ),
                        CountryLeagueOptions(
                            id: "es",
                            icon: "es",
                            title: "Spain",
                            leagues: [
                                LeagueOption(id: "acb", icon: nil, title: "ACB", count: 18),
                                LeagueOption(id: "leb", icon: nil, title: "LEB Oro", count: 18)
                            ],
                            isExpanded: false
                        )
                    ],
                    selectedId: "nba"
                )
                let filterView = CountryLeaguesFilterView(viewModel: viewModel)
                filterView.backgroundColor = StyleProvider.Color.backgroundColor
                filterView.layer.cornerRadius = 8
                return filterView
            }
        ),
        UIComponent(
            title: "Promotional Bonus Card",
            description: "A card view for displaying promotional bonuses, using PromotionalBonusCardView.",
            viewController: PromotionalBonusCardViewController.self,
            previewFactory: {
                let viewModel = MockPromotionalBonusCardViewModel.defaultMock
                let cardView = PromotionalBonusCardView(viewModel: viewModel)
                cardView.backgroundColor = StyleProvider.Color.backgroundColor
                cardView.layer.cornerRadius = 12
                return cardView
            }
        ),
        UIComponent(
            title: "Promotional Header",
            description: "A header view for displaying promotional content, using PromotionalHeaderView.",
            viewController: PromotionalHeaderViewController.self,
            previewFactory: {
                let viewModel = MockPromotionalHeaderViewModel.defaultMock
                let headerView = PromotionalHeaderView(viewModel: viewModel)
                headerView.backgroundColor = StyleProvider.Color.backgroundColor
                headerView.layer.cornerRadius = 8
                return headerView
            }
        ),
        UIComponent(
            title: "Button View",
            description: "A customizable button component, using ButtonView.",
            viewController: ButtonViewController.self,
            previewFactory: {
                let viewModel = MockButtonViewModel.solidBackgroundMock
                let buttonView = ButtonView(viewModel: viewModel)
                buttonView.backgroundColor = StyleProvider.Color.backgroundColor
                buttonView.layer.cornerRadius = 8
                return buttonView
            }
        ),
        UIComponent(
            title: "Wallet Status View",
            description: "Displays wallet balance information with deposit/withdraw actions. Designed for overlay dialogs.",
            viewController: WalletStatusViewController.self,
            previewFactory: {
                let viewModel = MockWalletStatusViewModel.defaultMock
                let walletView = WalletStatusView(viewModel: viewModel)
                return walletView
            }
        ),
        UIComponent(
            title: "Custom Navigation View",
            description: "A customizable navigation bar, using CustomNavigationView.",
            viewController: CustomNavigationViewController.self,
            previewFactory: {
                let viewModel = MockCustomNavigationViewModel.defaultMock
                let navView = CustomNavigationView(viewModel: viewModel)
                navView.backgroundColor = StyleProvider.Color.backgroundColor
                navView.layer.cornerRadius = 8
                return navView
            }
        ),
        UIComponent(
            title: "Amount Pills Container",
            description: "A container view for selecting amounts, using AmountPillsView.",
            viewController: AmountPillsContainerViewController.self,
            previewFactory: {
                let viewModel = MockAmountPillsViewModel.defaultMock
                let pillsView = AmountPillsView(viewModel: viewModel)
                pillsView.backgroundColor = StyleProvider.Color.backgroundColor
                pillsView.layer.cornerRadius = 8
                return pillsView
            }
        ),
        UIComponent(
            title: "Deposit Bonus Info",
            description: "A view for displaying deposit bonus information, using DepositBonusInfoView.",
            viewController: DepositBonusInfoViewController.self,
            previewFactory: {
                let viewModel = MockDepositBonusInfoViewModel.defaultMock
                let bonusView = DepositBonusInfoView(viewModel: viewModel)
                bonusView.backgroundColor = StyleProvider.Color.backgroundColor
                bonusView.layer.cornerRadius = 8
                return bonusView
            }
        ),
        UIComponent(
            title: "Info Row View",
            description: "A customizable info row component, using InfoRowView.",
            viewController: InfoRowViewController.self,
            previewFactory: {
                let viewModel = MockInfoRowViewModel.defaultMock
                let infoRowView = InfoRowView(viewModel: viewModel)
                infoRowView.backgroundColor = StyleProvider.Color.backgroundColor
                infoRowView.layer.cornerRadius = 8
                return infoRowView
            }
        ),
        UIComponent(
            title: "Status Notification View",
            description: "A notification banner for status messages, using StatusNotificationView.",
            viewController: StatusNotificationViewController.self,
            previewFactory: {
                let viewModel = MockStatusNotificationViewModel.successMock
                let notificationView = StatusNotificationView(viewModel: viewModel)
                notificationView.backgroundColor = StyleProvider.Color.backgroundColor
                notificationView.layer.cornerRadius = 8
                return notificationView
            }
        ),
        UIComponent(
            title: "Step Instruction View",
            description: "A step-by-step instruction component, using StepInstructionView.",
            viewController: StepInstructionViewController.self,
            previewFactory: {
                let viewModel = MockStepInstructionViewModel.defaultMock
                let stepView = StepInstructionView(viewModel: viewModel)
                stepView.backgroundColor = StyleProvider.Color.backgroundColor
                stepView.layer.cornerRadius = 8
                return stepView
            }
        ),
        UIComponent(
            title: "Terms Acceptance View",
            description: "A component for displaying and accepting terms, using TermsAcceptanceView.",
            viewController: TermsAcceptanceViewController.self,
            previewFactory: {
                let viewModel = MockTermsAcceptanceViewModel.defaultMock
                let termsView = TermsAcceptanceView(viewModel: viewModel)
                termsView.backgroundColor = StyleProvider.Color.backgroundColor
                termsView.layer.cornerRadius = 8
                return termsView
            }
        ),
        UIComponent(
            title: "Pin Digit Entry View",
            description: "A PIN digit entry component, using PinDigitEntryView.",
            viewController: PinDigitEntryViewController.self,
            previewFactory: {
                let viewModel = MockPinDigitEntryViewModel.defaultMock
                let pinView = PinDigitEntryView(viewModel: viewModel)
                pinView.backgroundColor = StyleProvider.Color.backgroundColor
                pinView.layer.cornerRadius = 8
                return pinView
            }
        ),
        UIComponent(
            title: "Transaction Verification View",
            description: "A transaction verification component, using TransactionVerificationView.",
            viewController: TransactionVerificationViewController.self,
            previewFactory: {
                let viewModel = MockTransactionVerificationViewModel.defaultMock
                let verificationView = TransactionVerificationView(viewModel: viewModel)
                verificationView.backgroundColor = StyleProvider.Color.backgroundColor
                verificationView.layer.cornerRadius = 8
                return verificationView
            }
        ),
        UIComponent(
            title: "Resend Code Countdown View",
            description: "A label with a countdown, using ResendCodeCountdownView.",
            viewController: ResendCodeCountdownDemoViewController.self,
            previewFactory: {
                let viewModel = MockResendCodeCountdownViewModel(startSeconds: 60)
                let countdownView = ResendCodeCountdownView(viewModel: viewModel)
                viewModel.startCountdown()
                return countdownView
            }
        ),
        UIComponent(
            title: "Status Info View",
            description: "A status info component, using StatusInfoView.",
            viewController: StatusInfoViewController.self,
            previewFactory: {
                let viewModel = MockStatusInfoViewModel(
                    statusInfo: StatusInfo(
                        icon: "checkmark.circle.fill",
                        title: "Password Changed Successfully",
                        message: "Your password has been updated. You can now log in with your new password."
                    )
                )
                let statusInfoView = StatusInfoView(viewModel: viewModel)
                statusInfoView.backgroundColor = StyleProvider.Color.backgroundColor
                statusInfoView.layer.cornerRadius = 12
                return statusInfoView
            }
        ),
        UIComponent(
            title: "See More Button",
            description: "Reusable button component for 'Load More' functionality with loading states, designed for pagination in collection views and table views",
            viewController: SeeMoreButtonViewController.self,
            previewFactory: {
                let containerView = UIView()
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.spacing = 12
                stackView.alignment = .center
                stackView.distribution = .fillEqually
                
                // Create sample buttons showing different states
                let defaultButton = SeeMoreButtonView(viewModel: MockSeeMoreButtonViewModel.defaultMock)
                let countButton = SeeMoreButtonView(viewModel: MockSeeMoreButtonViewModel.withCountMock)
                
                stackView.addArrangedSubview(defaultButton)
                stackView.addArrangedSubview(countButton)
                
                containerView.addSubview(stackView)
                stackView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                    stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                    stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                    stackView.heightAnchor.constraint(equalToConstant: 44)
                ])
                
                return containerView
            }
        ),
        UIComponent(
            title: "Casino Game Play Mode Selector",
            description: "Sophisticated pre-game component displaying game details with configurable play mode buttons that adapt to different user states (logged out, logged in, insufficient funds)",
            viewController: CasinoGamePlayModeSelectorViewController.self,
            previewFactory: {
                let viewModel = MockCasinoGamePlayModeSelectorViewModel.defaultMock
                let selectorView = CasinoGamePlayModeSelectorView(viewModel: viewModel)
                selectorView.backgroundColor = StyleProvider.Color.backgroundColor
                selectorView.layer.cornerRadius = 12
                selectorView.clipsToBounds = true
                return selectorView
            }
        ),
    ]

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "GomaUI Components"
        setupTableView()
    }

    private func setupTableView() {
        // Register the new preview cell
        tableView.register(ComponentPreviewTableViewCell.self, forCellReuseIdentifier: "ComponentPreviewCell")

        // Update table view styling
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = true

        // Add some top padding
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }

    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return components.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComponentPreviewCell", for: indexPath) as! ComponentPreviewTableViewCell
        let component = components[indexPath.row]

        // Create preview instance
        let previewView = component.previewFactory()
        previewView.isUserInteractionEnabled = false

        // Configure cell with component and preview
        cell.configure(with: component, previewView: previewView)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160 // Estimated height for preview cells
    }

    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let component = components[indexPath.row]
        let viewController = component.viewController.init()
        viewController.title = component.title

        navigationController?.pushViewController(viewController, animated: true)
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
