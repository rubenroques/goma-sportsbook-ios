//
//  HomeFilterViewController.swift
//  ShowcaseProd
//
//  Created by André Lascas on 13/10/2021.
//

import UIKit
import OrderedCollections

//
protocol HomeFilterOptionsViewDelegate: AnyObject {
    var turnTimeRangeOn: Bool { get set }
    var isLiveEventsMarkets: Bool { get set }
    func setHomeFilters(homeFilters: HomeFilterOptions?)

}

//
class HomeFilterViewController: UIViewController {
    @IBOutlet private var topView: UIView!
    @IBOutlet private var navigationView: UIView!
    @IBOutlet private var navigationLabel: UILabel!
    @IBOutlet private var navigationCancelButton: UIButton!
    @IBOutlet private var navigationResetButton: UIButton!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var stackContainerView: UIView!
    @IBOutlet private var stackView: UIStackView!

    @IBOutlet private var sportView: UIView!
    @IBOutlet private var sportTitleLabel: UILabel!
    @IBOutlet private var sportIconImageView: UIImageView!
    @IBOutlet private var sportNameLabel: UILabel!

    @IBOutlet private var sortByFilterCollapseView: FilterCollapseView!
    @IBOutlet private var timeRangeCollapseView: FilterSliderCollapseView!
    @IBOutlet private var availableMarketsCollapseView: FilterCollapseView!
    @IBOutlet private var cardSltyleCollapseView: FilterCollapseView!
    @IBOutlet private var oddsCollapseView: FilterCollapseView!
    @IBOutlet private var bottomButtonView: UIView!
    @IBOutlet private var applyButton: UIButton!

    var timeRangeMultiSlider: MultiSlider?
    var oddRangeMultiSlider: MultiSlider?

    var smallCardStyleOption = FilterRowView()
    var normalCardStyleOption = FilterRowView()

    // Variables
    // var timeSliderValues: [CGFloat] = []
    var lowerBoundTimeRange: CGFloat = 0.0
    var highBoundTimeRange: CGFloat = 6.0
    var lowerBoundOddsRange: CGFloat = 1.0
    var highBoundOddsRange: CGFloat = 300.0

    var initialLowerBoundTimeRange: CGFloat = 0.0
    var initialHighBoundTimeRange: CGFloat = 6.0
    var initialLowerBoundOddsRange: CGFloat = 1.0
    var initialHighBoundOddsRange: CGFloat = 300.0

    var countFilters: Int = 0

    var oddsValueViews: [FilterRowView] = []

    //var defaultMarket: MainMarketType = .homeDrawAway
    var defaultMarket: MainMarketType?
    var marketViews: [FilterRowView] = []
    var filterValues: HomeFilterOptions?
    var mainMarkets: OrderedDictionary<String, Market> = [:]

    var sportsModel: PreLiveEventsViewModel
    var liveEventsViewModel: LiveEventsViewModel

    var delegate: HomeFilterOptionsViewDelegate?

    init(sportsModel: PreLiveEventsViewModel = PreLiveEventsViewModel(selectedSport: Env.sportsStore.defaultSport),
         liveEventsViewModel: LiveEventsViewModel = LiveEventsViewModel(selectedSport: Env.sportsStore.defaultSport)) {
        self.sportsModel = sportsModel
        self.liveEventsViewModel = liveEventsViewModel
        super.init(nibName: "HomeFilterViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        commonInit()
        setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func commonInit() {

        if let delegate = self.delegate {
            if delegate.isLiveEventsMarkets {
                self.mainMarkets = self.liveEventsViewModel.mainMarkets

                let sport = self.liveEventsViewModel.selectedSport
                self.setupSportInfo(sport: sport)
            }
            else {
                self.mainMarkets = self.sportsModel.mainMarkets

                let sport = self.sportsModel.selectedSport
                self.setupSportInfo(sport: sport)
            }
        }

        if sportsModel.homeFilterOptions != nil {
            filterValues = sportsModel.homeFilterOptions
        }
        else if liveEventsViewModel.homeFilterOptions != nil {
            filterValues = liveEventsViewModel.homeFilterOptions
        }
        else {
            if let delegate = self.delegate {
                if delegate.isLiveEventsMarkets {
                    if let firstMarketType = self.liveEventsViewModel.getFirstMarketType() {
                        let defaultMarketType = MainMarketType(id: firstMarketType.marketTypeId ?? "", marketName: firstMarketType.name)
                        filterValues = HomeFilterOptions(defaultMarket: defaultMarketType)
                    }
                    else {
                        filterValues = HomeFilterOptions()
                    }
                }
                else {
                    if let firstMarketType = self.sportsModel.getFirstMarketType() {
                        let defaultMarketType = MainMarketType(id: firstMarketType.marketTypeId ?? "", marketName: firstMarketType.name)
                        filterValues = HomeFilterOptions(defaultMarket: defaultMarketType)
                    }
                    else {
                        filterValues = HomeFilterOptions()
                    }
                }
            }
            else {
                filterValues = HomeFilterOptions()
            }

        }
        
        defaultMarket = filterValues?.defaultMarket

        navigationLabel.text = localized("settings")
        navigationLabel.font = AppFont.with(type: .bold, size: 17)

        navigationResetButton.setTitle(localized("reset"), for: .normal)
        navigationResetButton.titleLabel?.font = AppFont.with(type: .semibold, size: 16)

        navigationCancelButton.setTitle(localized("cancel"), for: .normal)
        navigationCancelButton.titleLabel?.font = AppFont.with(type: .semibold, size: 16)

        sortByFilterCollapseView.isHidden = true
        
        self.setupTimeRangeSection()

//        if let marketId = filterValues?.defaultMarket.marketId {
//            self.setupAvailableMarketsSection(value: marketId)
//        }
        if let marketId = filterValues?.defaultMarket?.id {
            self.setupAvailableMarketsSection(value: marketId)
        }
        else {
            self.availableMarketsCollapseView.setTitle(title: localized("default_market"))
        }

        //self.setupCardSltyleCollapseView()
        self.cardSltyleCollapseView.isHidden = true
        self.setupOddsSection()

        self.applyButton.setTitle(localized("apply"), for: .normal)
        self.applyButton.titleLabel?.font = AppFont.with(type: .bold, size: 18)

        StyleHelper.styleButton(button: self.applyButton)

        self.sportView.layer.cornerRadius = CornerRadius.modal

        self.sportTitleLabel.text = localized("filters_applied_to")
        self.sportTitleLabel.font = AppFont.with(type: .bold, size: 16)

        self.sportNameLabel.font = AppFont.with(type: .bold, size: 16)

    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        topView.backgroundColor = UIColor.App.backgroundPrimary
        navigationView.backgroundColor = UIColor.App.backgroundPrimary
        navigationLabel.textColor = UIColor.App.textPrimary

        navigationResetButton.setTitleColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        navigationCancelButton.setTitleColor(UIColor.App.buttonBackgroundPrimary, for: .normal)

        scrollView.backgroundColor = UIColor.App.backgroundPrimary
        stackContainerView.backgroundColor = UIColor.App.backgroundPrimary

        stackView.backgroundColor = UIColor.App.backgroundPrimary
        bottomButtonView.backgroundColor = UIColor.App.backgroundPrimary

        StyleHelper.styleButton(button: self.applyButton)

        self.sportView.backgroundColor = UIColor.App.backgroundSecondary

        self.sportTitleLabel.textColor = UIColor.App.textPrimary

        self.sportIconImageView.backgroundColor = .clear

        self.sportNameLabel.textColor = UIColor.App.textPrimary
    }

    private func setupSportInfo(sport: Sport) {

        let sportIconId = sport.id

        if let sportIconImage = UIImage(named: "sport_type_icon_\(sportIconId)") {
            self.sportIconImageView.image = sportIconImage
        }
        else {
            self.sportIconImageView.image = UIImage(named: "sport_type_icon_default")
        }

        self.sportIconImageView.setTintColor(color: UIColor.App.textPrimary)

        self.sportNameLabel.text = sport.name

    }

    func setupTimeRangeSection() {
        let minValue: CGFloat = 0
        let maxValue: CGFloat = 6
        let values: [CGFloat]
        if delegate?.turnTimeRangeOn == true {
            timeRangeCollapseView.isUserInteractionEnabled = true
            
             values = [filterValues!.lowerBoundTimeRange, filterValues!.highBoundTimeRange]

            self.timeRangeCollapseView.isHidden = false
        }
        else {
            timeRangeCollapseView.isUserInteractionEnabled = false
            values = [minValue, maxValue]
            timeRangeCollapseView.alpha = 0.3 // para desmaiar as cores

            self.timeRangeCollapseView.isHidden = true

        }

        lowerBoundTimeRange = values[0]
        highBoundTimeRange = values[1]
        timeRangeCollapseView.setTitle(title: localized("time_today_only"))
        timeRangeCollapseView.hasCheckbox = false

        let contentView = timeRangeCollapseView.getContentView()
        self.timeRangeMultiSlider = MultiSlider()
        
        timeRangeMultiSlider?.backgroundColor = UIColor.App.backgroundSecondary
        timeRangeMultiSlider?.orientation = .horizontal
        timeRangeMultiSlider?.minimumTextualValue = localized("now")
        timeRangeMultiSlider?.minimumValue = minValue
        timeRangeMultiSlider?.maximumTextualValue = localized("all")
        timeRangeMultiSlider?.maximumValue = maxValue
        timeRangeMultiSlider?.outerTrackColor = UIColor.App.separatorLine
        timeRangeMultiSlider?.value = values
        timeRangeMultiSlider?.snapStepSize = 1
        timeRangeMultiSlider?.thumbImage = UIImage(named: "slider_thumb_icon")
        timeRangeMultiSlider?.tintColor = UIColor.App.highlightPrimary
        timeRangeMultiSlider?.trackWidth = 6
        timeRangeMultiSlider?.showsThumbImageShadow = false
        // timeRangeMultiSlider?.distanceBetweenThumbs = 1
        timeRangeMultiSlider?.keepsDistanceBetweenThumbs = false
        timeRangeMultiSlider?.addTarget(self, action: #selector(timeSliderChanged), for: .valueChanged)
        timeRangeMultiSlider?.valueLabelPosition = .firstBaseline
        timeRangeMultiSlider?.valueLabelColor = UIColor.App.textPrimary
        timeRangeMultiSlider?.valueLabelFont = AppFont.with(type: .bold, size: 14)

        timeRangeMultiSlider?.extraLabelInfoSingular = localized("day")
        timeRangeMultiSlider?.extraLabelInfoPlural = localized("days")

        if let timeRangeMultiSlider = timeRangeMultiSlider {
            contentView.addConstrainedSubview(timeRangeMultiSlider, constrain: .leftMargin, .rightMargin, .bottomMargin, .topMargin)
            contentView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 16, right: 8)

        }

        timeRangeCollapseView.didToggle = { value in
            if value {
                UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseIn, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                })
            }
        }

    }

    func setupAvailableMarketsSection(value: String) {
        availableMarketsCollapseView.setTitle(title: localized("default_market"))
        availableMarketsCollapseView.hasCheckbox = false

        var filterMarketsId: [String] = []
        for (index, market) in mainMarkets.enumerated() {
            if !filterMarketsId.contains((market.value.bettingTypeId ?? market.value.marketTypeId) ?? "") {
                let marketView = FilterRowView()
                marketView.buttonType = .radio
                //marketView.setTitle(title: "\(MainMarketType.init(id: market.value.marketTypeId ?? "")?.marketName ?? "")")
                marketView.setTitle(title: market.value.name)
                marketView.viewId = market.value.marketTypeId ?? "0"

                if index == mainMarkets.values.endIndex - 1 {
                    marketView.hasBorderBottom = false
                }

                marketViews.append(marketView)
                filterMarketsId.append((market.value.bettingTypeId ?? market.value.marketTypeId) ?? "")
                availableMarketsCollapseView.addViewtoStack(view: marketView)
            }
        }

        // Set selected view
        let viewInt = value
        for view in marketViews {
            view.didTapView = { [weak self] _ in
                self?.checkMarketRadioOptions(views: self?.marketViews ?? [], viewTapped: view)
            }

            // Default market selected
            if view.viewId == viewInt {
                view.isChecked = true
            }
        }

        availableMarketsCollapseView.didToggle = { [weak self] finished in
            if finished {
                UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseIn, animations: {
                    self?.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }

    func setupCardSltyleCollapseView() {

        cardSltyleCollapseView.setTitle(title: localized("cards_style"))

        self.smallCardStyleOption = FilterRowView()
        smallCardStyleOption.buttonType = .radio
        smallCardStyleOption.isChecked = false
        smallCardStyleOption.setTitle(title: localized("card_style_small"))
        smallCardStyleOption.viewId = "0"

        cardSltyleCollapseView.addViewtoStack(view: smallCardStyleOption)

        self.normalCardStyleOption = FilterRowView()
        self.normalCardStyleOption.buttonType = .radio
        self.normalCardStyleOption.isChecked = false
        self.normalCardStyleOption.setTitle(title: localized("card_style_normal"))
        self.normalCardStyleOption.hasBorderBottom = false
        self.normalCardStyleOption.viewId = "0"

        cardSltyleCollapseView.addViewtoStack(view: normalCardStyleOption)

        switch StyleHelper.cardsStyleActive() {
        case .small:
            self.smallCardStyleOption.isChecked = true
            self.normalCardStyleOption.isChecked = false
        case .normal:
            self.smallCardStyleOption.isChecked = false
            self.normalCardStyleOption.isChecked = true
        }

        smallCardStyleOption.didTapView = { [weak self] _ in
            UserDefaults.standard.cardsStyle = .small

            self?.smallCardStyleOption.isChecked = true
            self?.normalCardStyleOption.isChecked = false

            NotificationCenter.default.post(name: .cardsStyleChanged, object: nil)
        }

        self.normalCardStyleOption.didTapView = { [weak self] _ in
            UserDefaults.standard.cardsStyle = .normal

            self?.smallCardStyleOption.isChecked = false
            self?.normalCardStyleOption.isChecked = true

            NotificationCenter.default.post(name: .cardsStyleChanged, object: nil)
        }

        cardSltyleCollapseView.didToggle = { [weak self] finished in
            if finished {
                UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseIn, animations: {
                    self?.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }

    func checkMarketRadioOptions(views: [FilterRowView], viewTapped: FilterRowView) {
        for view in views {
            view.isChecked = false
        }
        viewTapped.isChecked = true
        
//        if let defaultMarketInit = MainMarketType.init(rawValue: String(viewTapped.viewId)) {
//            defaultMarket = defaultMarketInit
//            oddsCollapseView.setTitleWithBold(title: localized("odds_filter") + " " + String(defaultMarket.marketName), charToSplit: ":")
//        }
        if let delegate = self.delegate {
            if delegate.isLiveEventsMarkets {
                if let defaultMarketInit = self.liveEventsViewModel.getMarketType(marketTypeId: viewTapped.viewId) {
                    defaultMarket = MainMarketType(id: defaultMarketInit.marketTypeId ?? "", marketName: defaultMarketInit.name)
                    oddsCollapseView.setTitleWithBold(title: localized("odds_filter") + " " + String(defaultMarket?.marketName ?? ""), charToSplit: ":")
                }
            }
            else {
                if let defaultMarketInit = self.sportsModel.getMarketType(marketTypeId: viewTapped.viewId) {
                    defaultMarket = MainMarketType(id: defaultMarketInit.marketTypeId ?? "", marketName: defaultMarketInit.name)
                    oddsCollapseView.setTitleWithBold(title: localized("odds_filter") + " " + String(defaultMarket?.marketName ?? ""), charToSplit: ":")
                }
            }
        }

    }

    func checkOddsRadioOptions(views: [FilterRowView], viewTapped: FilterRowView) {
        for view in views {
            view.isChecked = false
        }

        viewTapped.isChecked = true

        if viewTapped.viewId == "1" {
            UserDefaults.standard.oddsValueType = .allOdds

            let oddValueType = UserDefaults.standard.oddsValueType

            self.lowerBoundOddsRange = oddValueType.oddRange[0]
            self.highBoundOddsRange = oddValueType.oddRange[1]

        }
        else if viewTapped.viewId == "2" {
            UserDefaults.standard.oddsValueType = .between2And3

            let oddValueType = UserDefaults.standard.oddsValueType

            self.lowerBoundOddsRange = oddValueType.oddRange[0]
            self.highBoundOddsRange = oddValueType.oddRange[1]
        }
        else if viewTapped.viewId == "3" {
            UserDefaults.standard.oddsValueType = .bigOdds

            let oddValueType = UserDefaults.standard.oddsValueType

            self.lowerBoundOddsRange = oddValueType.oddRange[0]
            self.highBoundOddsRange = oddValueType.oddRange[1]
        }

    }

    func setupOddsSection() {

        oddsCollapseView.setTitleWithBold(title: localized("odds_filter") + " " + String(defaultMarket?.marketName ?? ""), charToSplit: ":")
        oddsCollapseView.hasCheckbox = false

        let allOddsView = FilterRowView()
        allOddsView.buttonType = .radio
        allOddsView.setTitle(title: localized("all_odds"))
        allOddsView.viewId = "1"
        self.oddsValueViews.append(allOddsView)
        oddsCollapseView.addViewtoStack(view: allOddsView)

        let betweenOddsView = FilterRowView()
        betweenOddsView.buttonType = .radio
        betweenOddsView.setTitle(title: localized("between_2_3"))
        betweenOddsView.viewId = "2"
        self.oddsValueViews.append(betweenOddsView)
        oddsCollapseView.addViewtoStack(view: betweenOddsView)

        let bigOddsView = FilterRowView()
        bigOddsView.buttonType = .radio
        bigOddsView.setTitle(title: localized("big_odds"))
        bigOddsView.viewId = "3"
        bigOddsView.hasBorderBottom = false
        self.oddsValueViews.append(bigOddsView)
        oddsCollapseView.addViewtoStack(view: bigOddsView)

        // Set selected view
        let viewInt = UserDefaults.standard.oddsValueType.rawValue
        for view in self.oddsValueViews {
            view.didTapView = { [weak self] _ in
                self?.checkOddsRadioOptions(views: self?.oddsValueViews ?? [], viewTapped: view)
            }

            // Default odds selected
            if view.viewId == "\(viewInt)" {
                self.checkOddsRadioOptions(views: self.oddsValueViews ?? [], viewTapped: view)
            }
        }

        oddsCollapseView.didToggle = { value in
            if value {
                UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseIn, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                })
            }
        }
    }

//    func setupOddsSection() {
//        let minValue: CGFloat = 1.0
//        let maxValue: CGFloat = 30.0
//
//        lowerBoundOddsRange = filterValues!.lowerBoundOddsRange
//        highBoundOddsRange = filterValues!.highBoundOddsRange
//        oddsCollapseView.setTitleWithBold(title: localized("odds_filter") + " " + String(defaultMarket?.marketName ?? ""), charToSplit: ":")
//        oddsCollapseView.hasCheckbox = false
//
//        //oddsCollapseView.backgroundColor = UIColor.App.backgroundPrimary
//        let contentView = oddsCollapseView.getContentView()
//
//        self.oddRangeMultiSlider = MultiSlider()
//
//        oddRangeMultiSlider?.backgroundColor = UIColor.App.backgroundSecondary
//        oddRangeMultiSlider?.orientation = .horizontal
//        oddRangeMultiSlider?.minimumValue = minValue
//        oddRangeMultiSlider?.maximumValue = maxValue
//        oddRangeMultiSlider?.outerTrackColor = UIColor.App.separatorLine
//        oddRangeMultiSlider?.value = [lowerBoundOddsRange, highBoundOddsRange]
//        oddRangeMultiSlider?.snapStepSize = 0.1
//        oddRangeMultiSlider?.thumbImage = UIImage(named: "slider_thumb_icon")
//        oddRangeMultiSlider?.tintColor = UIColor.App.highlightPrimary
//        oddRangeMultiSlider?.trackWidth = 6
//        oddRangeMultiSlider?.showsThumbImageShadow = false
//        oddRangeMultiSlider?.keepsDistanceBetweenThumbs = false
//        oddRangeMultiSlider?.addTarget(self, action: #selector(oddsSliderChanged), for: .valueChanged)
//
//        oddRangeMultiSlider?.valueLabelPosition = .notAnAttribute
//
//        if let oddRangeMultiSlider = oddRangeMultiSlider {
//            contentView.addConstrainedSubview(oddRangeMultiSlider, constrain: .leftMargin, .rightMargin, .bottomMargin, .topMargin)
//            contentView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
//
//        }
//
//        oddsCollapseView.hasSliderInfo = true
//        oddsCollapseView.updateOddsLabels(fromText: "\(lowerBoundOddsRange)", toText: "\(highBoundOddsRange)")
//
//        oddsCollapseView.didToggle = { value in
//            if value {
//                UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseIn, animations: {
//                    self.view.layoutIfNeeded()
//                }, completion: { _ in
//                })
//            }
//        }
//    }

    @objc func timeSliderChanged(_ slider: MultiSlider) {
        // Get time slider values
        if slider.value[0] == slider.maximumValue && slider.value[1] == slider.maximumValue {
            slider.value[0] = slider.maximumValue - 1
            lowerBoundTimeRange = slider.value[0]
            highBoundTimeRange = slider.value[1]
        }
        else {
            lowerBoundTimeRange = slider.value[0]
            highBoundTimeRange = slider.value[1]
        }

    }

//    @objc func oddsSliderChanged(_ slider: MultiSlider) {
//        // Get odds slider values
//        let minValue = String(format: "%.1f", slider.value[0])
//        let maxValue = String(format: "%.1f", slider.value[1])
//        oddsCollapseView.updateOddsLabels(fromText: minValue, toText: maxValue)
//        highBoundOddsRange = slider.value[1].round(to: 1)
//        lowerBoundOddsRange = slider.value[0].round(to: 1)
//
//    }

    @IBAction private func resetAction() {
        var homeFilterOptions = HomeFilterOptions()

        if let delegate = self.delegate {

            if delegate.isLiveEventsMarkets {
                if let firstMarketType = self.liveEventsViewModel.getFirstMarketType() {
                    let defaultMarketType = MainMarketType(id: firstMarketType.marketTypeId ?? "", marketName: firstMarketType.name)
                    homeFilterOptions = HomeFilterOptions(defaultMarket: defaultMarketType)
                }
            }
            else {
                if let firstMarketType = self.sportsModel.getFirstMarketType() {
                    let defaultMarketType = MainMarketType(id: firstMarketType.marketTypeId ?? "", marketName: firstMarketType.name)
                    homeFilterOptions = HomeFilterOptions(defaultMarket: defaultMarketType)
                }
            }
        }

//        lowerBoundTimeRange = homeFilterOptions.lowerBoundTimeRange
//        highBoundTimeRange = homeFilterOptions.highBoundTimeRange
//        timeRangeMultiSlider?.value = [homeFilterOptions.lowerBoundTimeRange, homeFilterOptions.highBoundTimeRange]
//        oddRangeMultiSlider?.value = [homeFilterOptions.lowerBoundOddsRange, homeFilterOptions.highBoundOddsRange]
        lowerBoundTimeRange = initialLowerBoundTimeRange
        highBoundTimeRange = initialHighBoundTimeRange
        timeRangeMultiSlider?.value = [initialLowerBoundTimeRange, initialHighBoundTimeRange]
        oddRangeMultiSlider?.value = [initialLowerBoundOddsRange, initialHighBoundOddsRange]

//        if let oddRangeMultiSlider = oddRangeMultiSlider {
//            lowerBoundOddsRange = oddRangeMultiSlider.value[0].round(to: 1)
//            highBoundOddsRange = oddRangeMultiSlider.value[1].round(to: 1)
//            oddsCollapseView.updateOddsLabels(fromText: "\(lowerBoundOddsRange)", toText: "\(highBoundOddsRange)")
//        }
        
        for view in self.marketViews {
            view.isChecked = false
            // Default market selected
            if view.viewId == homeFilterOptions.defaultMarket?.id {
                view.isChecked = true
                
//                if let defaultMarketInit = MainMarketType.init(rawValue: String(view.viewId)) {
//                    defaultMarket = defaultMarketInit
//                }
                if let delegate = self.delegate {
                    if delegate.isLiveEventsMarkets {
                        if let defaultMarketInit = self.liveEventsViewModel.getMarketType(marketTypeId: view.viewId) {
                            defaultMarket = MainMarketType(id: defaultMarketInit.marketTypeId ?? "", marketName: defaultMarketInit.name)
                        }
                    }
                    else {
                        if let defaultMarketInit = self.sportsModel.getMarketType(marketTypeId: view.viewId) {
                            defaultMarket = MainMarketType(id: defaultMarketInit.marketTypeId ?? "", marketName: defaultMarketInit.name)
                        }
                    }
                }

            }

        }

        for view in self.oddsValueViews {

            if view.viewId == "1" {
                view.isChecked = true
            }
            else {
                view.isChecked = false
            }

        }

        UserDefaults.standard.oddsValueType = .allOdds
        let oddsValueType = UserDefaults.standard.oddsValueType

        self.lowerBoundOddsRange = oddsValueType.oddRange[0]
        self.highBoundOddsRange = oddsValueType.oddRange[1]

        UserDefaults.standard.cardsStyle = .normal
        NotificationCenter.default.post(name: .cardsStyleChanged, object: nil)

        self.smallCardStyleOption.isChecked = false
        self.normalCardStyleOption.isChecked = true

        countFilters = 0
    }

    @IBAction private func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction private func applyFiltersAction() {
        countFilters = 0

        if delegate?.turnTimeRangeOn == true {
            if lowerBoundTimeRange != initialLowerBoundTimeRange || highBoundTimeRange != initialHighBoundTimeRange {
                countFilters += 1
            }
        }
        
        if lowerBoundOddsRange != initialLowerBoundOddsRange || highBoundOddsRange != initialHighBoundOddsRange {
            countFilters += 1
        }
        
//        if defaultMarket.marketId != MainMarketType.homeDrawAway.marketId {
//           countFilters += 1
//        }
        if let delegate = self.delegate {
            if delegate.isLiveEventsMarkets {
                if let defaultMarketId = defaultMarket?.id,
                   let firstMarketTypeId = self.liveEventsViewModel.getFirstMarketType()?.marketTypeId,
                defaultMarketId != firstMarketTypeId {
                   countFilters += 1
                }
            }
            else {
                if let defaultMarketId = defaultMarket?.id,
                   let firstMarketTypeId = self.sportsModel.getFirstMarketType()?.marketTypeId,
                defaultMarketId != firstMarketTypeId {
                   countFilters += 1
                }
            }
        }

        let homeFilterOptions = HomeFilterOptions(lowerBoundTimeRange: lowerBoundTimeRange,
                                                  highBoundTimeRange: highBoundTimeRange,
                                                  defaultMarket: defaultMarket,
                                                  lowerBoundOddsRange: lowerBoundOddsRange,
                                                  highBoundOddsRange: highBoundOddsRange,
                                                  countFilters: countFilters)
        delegate?.setHomeFilters(homeFilters: homeFilterOptions)
        
        self.dismiss(animated: true, completion: nil)
        
    }

}
