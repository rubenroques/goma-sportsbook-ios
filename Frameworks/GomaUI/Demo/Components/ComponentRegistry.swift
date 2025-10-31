import UIKit
import GomaUI

// MARK: - Component Registry
struct ComponentRegistry {
    
    // MARK: - Public Methods
    static func components(for category: ComponentCategory?) -> [UIComponent] {
        guard let category = category else { return allComponents }
        
        switch category {
        case .bettingSports:
            return bettingSportsComponents
        case .casino:
            return casinoComponents
        case .matchDisplay:
            return matchDisplayComponents
        case .filters:
            return filtersComponents
        case .navigation:
            return navigationComponents
        case .forms:
            return formsComponents
        case .wallet:
            return walletComponents
        case .promotional:
            return promotionalComponents
        case .profile:
            return profileComponents
        case .status:
            return statusComponents
        case .uiElements:
            return uiElementsComponents
        }
    }
    
    static var allComponents: [UIComponent] {
        return ComponentCategory.allCases.flatMap { components(for: $0) }
    }
    
    // MARK: - Betting & Sports Components
    private static let bettingSportsComponents: [UIComponent] = [
        UIComponent(
            title: "Pre-Live Match Card",
            description: "Complete pre-live match card assembling MatchHeader, MatchParticipants, MarketInfoLine and MarketOutcomes components with proper spacing and layout",
            viewController: TallOddsMatchCardViewController.self,
            previewFactory: {
                let viewModel = MockTallOddsMatchCardViewModel.premierLeagueMock
                let matchCardView = TallOddsMatchCardView(viewModel: viewModel)
                matchCardView.backgroundColor = StyleProvider.Color.backgroundPrimary
                matchCardView.layer.cornerRadius = 8
                return matchCardView
            }
        ),
        UIComponent(
            title: "Suggested Bets Expanded",
            description: "Expandable section with horizontal match cards and page indicators",
            viewController: SuggestedBetsExpandedViewController.self,
            previewFactory: {
                let viewModel = MockSuggestedBetsExpandedViewModel.demo
                let view = SuggestedBetsExpandedView(viewModel: viewModel)
                return view
            }
        ),
        UIComponent(
            title: "Market Outcomes Line",
            description: "Flexible betting market outcomes display with selection states, odds changes, and multiple display modes",
            viewController: MarketOutcomesLineViewController.self,
            previewFactory: {
                let viewModel = MockMarketOutcomesLineViewModel.threeWayMarket
                let marketView = MarketOutcomesLineView(viewModel: viewModel)
                marketView.backgroundColor = StyleProvider.Color.backgroundPrimary
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
                multiLineView.backgroundColor = StyleProvider.Color.backgroundPrimary
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
            title: "Market Group Selector Tab",
            description: "Horizontal scrollable tab bar for betting market groups with dynamic content and selection coordination",
            viewController: MarketGroupSelectorTabViewController.self,
            previewFactory: {
                let viewModel = MockMarketGroupSelectorTabViewModel.standardSportsMarkets
                return MarketGroupSelectorTabView(viewModel: viewModel)
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
            title: "Main Filter Bar View",
            description: "A simple bar with a main filter view",
            viewController: GeneralFilterViewController.self,
            previewFactory: {
                let mainFilter = MainFilterItem(type: .mainFilter, title: "Filter", icon: "filter_icon", actionIcon: "right_arrow_icon")
                let viewModel = MockMainFilterPillViewModel(mainFilter: mainFilter)
                let mainFilterView = MainFilterPillView(viewModel: viewModel)
                mainFilterView.backgroundColor = StyleProvider.Color.backgroundPrimary
                mainFilterView.layer.cornerRadius = 4.5
                return mainFilterView
            }
        ),
        UIComponent(
            title: "Ticket Selection View",
            description: "Sports betting ticket component showing match information with dual states: PreLive (date/time) and Live (scores + live indicator)",
            viewController: TicketSelectionViewController.self,
            previewFactory: {
                let viewModel = MockTicketSelectionViewModel.preLiveMock
                let ticketView = TicketSelectionView(viewModel: viewModel)
                ticketView.backgroundColor = StyleProvider.Color.backgroundSecondary
                ticketView.layer.cornerRadius = 8
                return ticketView
            }
        ),
        UIComponent(
            title: "Ticket Bet Info View",
            description: "Comprehensive betting ticket information component with configurable corner radius styles, cashout components, and interactive rebet/cashout actions",
            viewController: TicketBetInfoViewController.self,
            previewFactory: {
                let viewModel = MockTicketBetInfoViewModel.pendingMock()
                let ticketBetInfoView = TicketBetInfoView(viewModel: viewModel, cornerRadiusStyle: .all)
                ticketBetInfoView.backgroundColor = StyleProvider.Color.backgroundSecondary
                ticketBetInfoView.layer.cornerRadius = 8
                return ticketBetInfoView
            }
        ),
        UIComponent(
            title: "Betslip Odds Boost Header",
            description: "Header view displaying odds boost promotion with progress tracking - designed for betslip header positioning",
            viewController: BetslipOddsBoostHeaderViewController.self,
            previewFactory: {
                let viewModel = MockBetslipOddsBoostHeaderViewModel.activeMock(
                    selectionCount: 1,
                    totalEligibleCount: 3,
                    nextTierPercentage: "3%"
                )
                let headerView = BetslipOddsBoostHeaderView(viewModel: viewModel)
                return headerView
            }
        )
    ]
    
    // MARK: - Casino Components
    private static let casinoComponents: [UIComponent] = [
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
            title: "Casino Game Play Mode Selector",
            description: "Sophisticated pre-game component displaying game details with configurable play mode buttons that adapt to different user states (logged out, logged in, insufficient funds)",
            viewController: CasinoGamePlayModeSelectorViewController.self,
            previewFactory: {
                let viewModel = MockCasinoGamePlayModeSelectorViewModel.defaultMock
                let selectorView = CasinoGamePlayModeSelectorView(viewModel: viewModel)
                selectorView.backgroundColor = StyleProvider.Color.backgroundPrimary
                selectorView.layer.cornerRadius = 12
                selectorView.clipsToBounds = true
                return selectorView
            }
        )
    ]
    
    // MARK: - Match & Sports Display Components
    private static let matchDisplayComponents: [UIComponent] = [
        UIComponent(
            title: "Match Header",
            description: "Sports competition header with country flag, sport icon, and favorite toggle functionality",
            viewController: MatchHeaderViewController.self,
            previewFactory: {
                let viewModel = MockMatchHeaderViewModel.premierLeagueHeader
                let headerView = MatchHeaderView(viewModel: viewModel)
                headerView.backgroundColor = StyleProvider.Color.backgroundPrimary.withAlphaComponent(0.8)
                headerView.layer.cornerRadius = 4
                return headerView
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
            title: "Match Date Navigation Bar",
            description: "Navigation bar with match timing information, supporting both pre-match date/time display and live match status with highlighted pills",
            viewController: MatchDateNavigationBarViewController.self,
            previewFactory: {
                let viewModel = MockMatchDateNavigationBarViewModel.liveMock
                return MatchDateNavigationBarView(viewModel: viewModel)
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
            title: "Score View",
            description: "Flexible sports match score display with multiple cells and visual styles",
            viewController: ScoreViewController.self,
            previewFactory: {
                let viewModel = MockScoreViewModel.tennisMatch
                let scoreView = ScoreView()
                scoreView.configure(with: viewModel)
                scoreView.backgroundColor = StyleProvider.Color.backgroundPrimary
                scoreView.layer.cornerRadius = 8
                return scoreView
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
        )
    ]
    
    // MARK: - Filters & Selection Components
    private static let filtersComponents: [UIComponent] = [
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
                filterView.backgroundColor = StyleProvider.Color.backgroundPrimary
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
                filterView.backgroundColor = StyleProvider.Color.backgroundPrimary
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
                filterView.backgroundColor = StyleProvider.Color.backgroundPrimary
                filterView.layer.cornerRadius = 8
                return filterView
            }
        ),
        UIComponent(
            title: "Time Slider Filter",
            description: "Interactive time-based filter with slider and tappable labels for discrete time range selection",
            viewController: TimeSliderFilterViewController.self,
            previewFactory: {
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
        )
    ]
    
    // MARK: - Navigation & Layout Components
    private static let navigationComponents: [UIComponent] = [
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
            title: "Custom Navigation View",
            description: "A customizable navigation bar, using CustomNavigationView.",
            viewController: CustomNavigationViewController.self,
            previewFactory: {
                let viewModel = MockCustomNavigationViewModel.defaultMock
                let navView = CustomNavigationView(viewModel: viewModel)
                navView.backgroundColor = StyleProvider.Color.backgroundPrimary
                navView.layer.cornerRadius = 8
                return navView
            }
        ),
        UIComponent(
            title: "Navigation Action",
            description: "Interactive navigation action button with icons, titles, enabled/disabled states, and tap handling for various navigation flows",
            viewController: NavigationActionViewController.self,
            previewFactory: {
                let viewModel = MockNavigationActionViewModel.openBetslipDetailsMock()
                return NavigationActionView(viewModel: viewModel)
            }
        )
    ]
    
    // MARK: - Forms & Input Components
    private static let formsComponents: [UIComponent] = [
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
            title: "Search View",
            description: "Lightweight search input with icon, placeholder, and clear button",
            viewController: SearchViewController.self,
            previewFactory: {
                let viewModel = MockSearchViewModel.default
                return SearchView(viewModel: viewModel)
            }
        ),
        UIComponent(
            title: "Pin Digit Entry View",
            description: "A PIN digit entry component, using PinDigitEntryView.",
            viewController: PinDigitEntryViewController.self,
            previewFactory: {
                let viewModel = MockPinDigitEntryViewModel.defaultMock
                let pinView = PinDigitEntryView(viewModel: viewModel)
                pinView.backgroundColor = StyleProvider.Color.backgroundPrimary
                pinView.layer.cornerRadius = 8
                return pinView
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
            title: "Code Clipboard",
            description: "Code display component with clipboard functionality, copy actions, success states, and interactive feedback",
            viewController: CodeClipboardViewController.self,
            previewFactory: {
                let viewModel = MockCodeClipboardViewModel.defaultMock()
                return CodeClipboardView(viewModel: viewModel)
            }
        ),
        UIComponent(
            title: "Code Input",
            description: "Code entry component with text input, submit button, error handling, loading states, and validation patterns",
            viewController: CodeInputViewController.self,
            previewFactory: {
                let viewModel = MockCodeInputViewModel.withCodeMock()
                return CodeInputView(viewModel: viewModel)
            }
        )
    ]
    
    // MARK: - Wallet & Financial Components
    private static let walletComponents: [UIComponent] = [
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
            title: "Wallet Detail View",
            description: "Comprehensive wallet detail component with balance information, orange theme design, and integrated action buttons for deposits and withdrawals",
            viewController: WalletDetailViewController.self,
            previewFactory: {
                let viewModel = MockWalletDetailViewModel.defaultMock
                let walletDetailView = WalletDetailView(viewModel: viewModel)
                return walletDetailView
            }
        ),
        UIComponent(
            title: "Amount Pills Container",
            description: "A container view for selecting amounts, using AmountPillsView.",
            viewController: AmountPillsContainerViewController.self,
            previewFactory: {
                let viewModel = MockAmountPillsViewModel.defaultMock
                let pillsView = AmountPillsView(viewModel: viewModel)
                pillsView.backgroundColor = StyleProvider.Color.backgroundPrimary
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
                bonusView.backgroundColor = StyleProvider.Color.backgroundPrimary
                bonusView.layer.cornerRadius = 8
                return bonusView
            }
        ),
        UIComponent(
            title: "Transaction Item View",
            description: "Displays individual transaction details including category, status badge, amount, transaction ID, date and balance. Supports different transaction types (deposits, withdrawals, bets) and corner radius styles.",
            viewController: TransactionItemViewController.self,
            previewFactory: {
                let viewModel = MockTransactionItemViewModel.betWonMock
                return TransactionItemView(viewModel: viewModel)
            }
        )
    ]
    
    // MARK: - Promotional Components
    private static let promotionalComponents: [UIComponent] = [
        UIComponent(
            title: "Promotion Card",
            description: "A comprehensive promotion card with image, tag, title, description, CTA button and read more link. Perfect for promotion listings.",
            viewController: PromotionCardViewController.self,
            previewFactory: {
                let viewModel = MockPromotionCardViewModel.defaultMock
                let cardView = PromotionCardView(viewModel: viewModel)
                cardView.backgroundColor = StyleProvider.Color.backgroundColor
                cardView.layer.cornerRadius = 8
                return cardView
            }
        ),
        UIComponent(
            title: "Bonus Card",
            description: "A bonus offer card with image, tag, title, description, CTA button and terms text. Terms can be clickable when URL is provided.",
            viewController: BonusCardViewController.self,
            previewFactory: {
                let viewModel = MockBonusCardViewModel.defaultMock
                let cardView = BonusCardView(viewModel: viewModel)
                cardView.backgroundColor = StyleProvider.Color.backgroundColor
                cardView.layer.cornerRadius = 8
                return cardView
            }
        ),
        UIComponent(
            title: "Promotion Item",
            description: "A pill-shaped button component for promotion category selection with selection states and animations.",
            viewController: PromotionItemViewController.self,
            previewFactory: {
                let data = PromotionItemData(id: "demo", title: "Welcome", isSelected: true)
                let viewModel = MockPromotionItemViewModel(promotionItemData: data)
                let itemView = PromotionItemView(viewModel: viewModel)
                return itemView
            }
        ),
        UIComponent(
            title: "Promotion Selector Bar",
            description: "A horizontal scrolling container for promotion category selection with fade effects and state management.",
            viewController: PromotionSelectorBarViewController.self,
            previewFactory: {
                let items = [
                    PromotionItemData(id: "1", title: "Welcome", isSelected: true),
                    PromotionItemData(id: "2", title: "Sports", isSelected: false),
                    PromotionItemData(id: "3", title: "Casino", isSelected: false)
                ]
                let barData = PromotionSelectorBarData(id: "demo", promotionItems: items, selectedPromotionId: "1")
                let viewModel = MockPromotionSelectorBarViewModel(barData: barData)
                let selectorBar = PromotionSelectorBarView(viewModel: viewModel)
                return selectorBar
            }
        ),
        UIComponent(
            title: "Promotional Bonus Card",
            description: "A card view for displaying promotional bonuses, using PromotionalBonusCardView.",
            viewController: PromotionalBonusCardViewController.self,
            previewFactory: {
                let viewModel = MockPromotionalBonusCardViewModel.defaultMock
                let cardView = PromotionalBonusCardView(viewModel: viewModel)
                cardView.backgroundColor = StyleProvider.Color.backgroundPrimary
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
                headerView.backgroundColor = StyleProvider.Color.backgroundPrimary
                headerView.layer.cornerRadius = 8
                return headerView
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
            title: "Match Banner",
            description: "Match banner component for displaying live and prelive matches with team info, scores, and betting outcomes in TopBannerSliderView",
            viewController: MatchBannerViewController.self,
            previewFactory: {
                let viewModel = MockMatchBannerViewModel.liveMatch
                let bannerView = MatchBannerView()
                bannerView.configure(with: viewModel)
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
            title: "Action Button Block",
            description: "Promotional action button with customizable title and action handling for promotional campaigns",
            viewController: ActionButtonBlockViewController.self,
            previewFactory: {
                let viewModel = MockActionButtonBlockViewModel.defaultMock
                let buttonView = ActionButtonBlockView(viewModel: viewModel)
                buttonView.backgroundColor = StyleProvider.Color.backgroundColor
                buttonView.layer.cornerRadius = 8
                return buttonView
            }
        ),
        UIComponent(
            title: "Bullet Item Block",
            description: "Bullet point text component with highlighted bullet symbols for promotional feature lists",
            viewController: BulletItemBlockViewController.self,
            previewFactory: {
                let viewModel = MockBulletItemBlockViewModel.defaultMock
                let bulletView = BulletItemBlockView(viewModel: viewModel)
                bulletView.backgroundColor = StyleProvider.Color.backgroundColor
                bulletView.layer.cornerRadius = 8
                return bulletView
            }
        ),
        UIComponent(
            title: "Gradient Header",
            description: "Gradient background header with centered title text for promotional content sections",
            viewController: GradientHeaderViewController.self,
            previewFactory: {
                let viewModel = MockGradientHeaderViewModel.defaultMock
                let headerView = GradientHeaderView(viewModel: viewModel)
                headerView.layer.cornerRadius = 8
                return headerView
            }
        ),
        UIComponent(
            title: "Stack View Block",
            description: "Container component for stacking multiple promotional views vertically with consistent styling",
            viewController: StackViewBlockViewController.self,
            previewFactory: {
                let viewModel = MockStackViewBlockViewModel.defaultMock
                let stackView = StackViewBlockView(viewModel: viewModel)
                stackView.backgroundColor = StyleProvider.Color.backgroundColor
                stackView.layer.cornerRadius = 8
                return stackView
            }
        ),
        UIComponent(
            title: "Title Block",
            description: "Promotional title component with customizable alignment and highlight styling",
            viewController: TitleBlockViewController.self,
            previewFactory: {
                let viewModel = MockTitleBlockViewModel.defaultMock
                let titleView = TitleBlockView(viewModel: viewModel)
                titleView.backgroundColor = StyleProvider.Color.backgroundColor
                titleView.layer.cornerRadius = 8
                return titleView
            }
        ),
        UIComponent(
            title: "Description Block",
            description: "Promotional description text component with multi-line support and consistent typography",
            viewController: DescriptionBlockViewController.self,
            previewFactory: {
                let viewModel = MockDescriptionBlockViewModel.defaultMock
                let descriptionView = DescriptionBlockView(viewModel: viewModel)
                descriptionView.backgroundColor = StyleProvider.Color.backgroundColor
                descriptionView.layer.cornerRadius = 8
                return descriptionView
            }
        ),
        UIComponent(
            title: "Image Block",
            description: "Promotional image component with centered layout and rounded corners for promotional content",
            viewController: ImageBlockViewController.self,
            previewFactory: {
                let viewModel = MockImageBlockViewModel.defaultMock
                let imageView = ImageBlockView(viewModel: viewModel)
                imageView.backgroundColor = StyleProvider.Color.backgroundColor
                imageView.layer.cornerRadius = 8
                return imageView
            }
        ),
        UIComponent(
            title: "Image Section",
            description: "Full-width promotional image section component for banner-style promotional content",
            viewController: ImageSectionViewController.self,
            previewFactory: {
                let viewModel = MockImageSectionViewModel.defaultMock
                let imageView = ImageSectionView(viewModel: viewModel)
                imageView.backgroundColor = StyleProvider.Color.backgroundColor
                imageView.layer.cornerRadius = 8
                return imageView
            }
        ),
        UIComponent(
            title: "List Block",
            description: "Promotional list component with icon support and vertical stacking of promotional items",
            viewController: ListBlockViewController.self,
            previewFactory: {
                let viewModel = MockListBlockViewModel.defaultMock
                let listView = ListBlockView(viewModel: viewModel)
                listView.backgroundColor = StyleProvider.Color.backgroundColor
                listView.layer.cornerRadius = 8
                return listView
            }
        ),
        UIComponent(
            title: "Video Block",
            description: "Promotional video component with play/pause controls and dynamic height adjustment",
            viewController: VideoBlockViewController.self,
            previewFactory: {
                let viewModel = MockVideoBlockViewModel.defaultMock
                let videoView = VideoBlockView(viewModel: viewModel)
                videoView.backgroundColor = StyleProvider.Color.backgroundColor
                videoView.layer.cornerRadius = 8
                return videoView
            }
        ),
        UIComponent(
            title: "Video Section",
            description: "Full-width promotional video section component with fixed height for banner-style video content",
            viewController: VideoSectionViewController.self,
            previewFactory: {
                let viewModel = MockVideoSectionViewModel.defaultMock
                let videoView = VideoSectionView(viewModel: viewModel)
                videoView.backgroundColor = StyleProvider.Color.backgroundColor
                videoView.layer.cornerRadius = 8
                return videoView
            }
        )
    ]
    
    // MARK: - Profile & Settings Components
    private static let profileComponents: [UIComponent] = [
        UIComponent(
            title: "Profile Menu List",
            description: "Interactive profile menu with multiple item types: navigation actions, selections with values, and immediate actions. Configurable via JSON with reactive language updates",
            viewController: ProfileMenuListViewController.self,
            previewFactory: {
                let viewModel = MockProfileMenuListViewModel.defaultMock
                return ProfileMenuListView(viewModel: viewModel)
            }
        ),
        UIComponent(
            title: "Theme Switcher",
            description: "Super simple theme switcher with Light, System, and Dark options. Orange indicator shows selected theme with smooth animations",
            viewController: ThemeSwitcherViewController.self,
            previewFactory: {
                let viewModel = MockThemeSwitcherViewModel.defaultMock
                return ThemeSwitcherView(viewModel: viewModel)
            }
        ),
        UIComponent(
            title: "Language Selector",
            description: "Single-selection language picker with radio buttons and flag icons. Supports emoji flags, customizable language lists, and reactive selection updates",
            viewController: LanguageSelectorViewController.self,
            previewFactory: {
                let viewModel = MockLanguageSelectorViewModel.twoLanguagesMock
                return LanguageSelectorView(viewModel: viewModel)
            }
        ),
        UIComponent(
            title: "Terms Acceptance View",
            description: "A component for displaying and accepting terms, using TermsAcceptanceView.",
            viewController: TermsAcceptanceViewController.self,
            previewFactory: {
                let viewModel = MockTermsAcceptanceViewModel.defaultMock
                let termsView = TermsAcceptanceView(viewModel: viewModel)
                termsView.backgroundColor = StyleProvider.Color.backgroundPrimary
                termsView.layer.cornerRadius = 8
                return termsView
            }
        )
    ]
    
    // MARK: - Status & Notifications Components
    private static let statusComponents: [UIComponent] = [
        UIComponent(
            title: "Status Notification View",
            description: "A notification banner for status messages, using StatusNotificationView.",
            viewController: StatusNotificationViewController.self,
            previewFactory: {
                let viewModel = MockStatusNotificationViewModel.successMock
                let notificationView = StatusNotificationView(viewModel: viewModel)
                notificationView.backgroundColor = StyleProvider.Color.backgroundPrimary
                notificationView.layer.cornerRadius = 8
                return notificationView
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
                statusInfoView.backgroundColor = StyleProvider.Color.backgroundPrimary
                statusInfoView.layer.cornerRadius = 12
                return statusInfoView
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
            title: "Notification List",
            description: "Scrollable notification feed with card-based items, supporting read/unread states, action buttons, timestamp formatting, and empty states",
            viewController: NotificationListViewController.self,
            previewFactory: {
                let viewModel = MockNotificationListViewModel.defaultMock
                return NotificationListView(viewModel: viewModel)
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
            title: "Empty State Action",
            description: "Empty state component with customizable icon, title, message, and action button for handling no-data scenarios with user guidance",
            viewController: EmptyStateActionViewController.self,
            previewFactory: {
                let viewModel = MockEmptyStateActionViewModel.loggedOutMock()
                return EmptyStateActionView(viewModel: viewModel)
            }
        ),
        UIComponent(
            title: "Progress Info Check",
            description: "Progress indicator with check states, step counting, customizable content, and completion tracking for multi-step flows",
            viewController: ProgressInfoCheckViewController.self,
            previewFactory: {
                let viewModel = MockProgressInfoCheckViewModel.winBoostMock()
                return ProgressInfoCheckView(viewModel: viewModel)
            }
        )
    ]
    
    // MARK: - UI Elements Components
    private static let uiElementsComponents: [UIComponent] = [
        UIComponent(
            title: "Button View",
            description: "A customizable button component, using ButtonView.",
            viewController: ButtonViewController.self,
            previewFactory: {
                let viewModel = MockButtonViewModel.solidBackgroundMock
                let buttonView = ButtonView(viewModel: viewModel)
                buttonView.backgroundColor = StyleProvider.Color.backgroundPrimary
                buttonView.layer.cornerRadius = 8
                return buttonView
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
            title: "Step Instruction View",
            description: "A step-by-step instruction component, using StepInstructionView.",
            viewController: StepInstructionViewController.self,
            previewFactory: {
                let viewModel = MockStepInstructionViewModel.defaultMock
                let stepView = StepInstructionView(viewModel: viewModel)
                stepView.backgroundColor = StyleProvider.Color.backgroundPrimary
                stepView.layer.cornerRadius = 8
                return stepView
            }
        ),
        UIComponent(
            title: "Info Row View",
            description: "A customizable info row component, using InfoRowView.",
            viewController: InfoRowViewController.self,
            previewFactory: {
                let viewModel = MockInfoRowViewModel.defaultMock
                let infoRowView = InfoRowView(viewModel: viewModel)
                infoRowView.backgroundColor = StyleProvider.Color.backgroundPrimary
                infoRowView.layer.cornerRadius = 8
                return infoRowView
            }
        ),
        UIComponent(
            title: "Transaction Verification View",
            description: "A transaction verification component, using TransactionVerificationView.",
            viewController: TransactionVerificationViewController.self,
            previewFactory: {
                let viewModel = MockTransactionVerificationViewModel.defaultMock
                let verificationView = TransactionVerificationView(viewModel: viewModel)
                verificationView.backgroundColor = StyleProvider.Color.backgroundPrimary
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
        )
    ]
}
