//
//  HomeFilterViewController.swift
//  ShowcaseProd
//
//  Created by André Lascas on 13/10/2021.
//

import UIKit

import OrderedCollections

class HomeFilterViewController: UIViewController {
    @IBOutlet private var topView: UIView!
    @IBOutlet private var navigationView: UIView!
    @IBOutlet private var navigationLabel: UILabel!
    @IBOutlet private var navigationCancelButton: UIButton!
    @IBOutlet private var navigationResetButton: UIButton!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var stackContainerView: UIView!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var sortByFilterCollapseView: FilterCollapseView!
    @IBOutlet private var timeRangeCollapseView: FilterSliderCollapseView!
    @IBOutlet private var availableMarketsCollapseView: FilterCollapseView!
    @IBOutlet private var oddsCollapseView: FilterSliderCollapseView!
    @IBOutlet private var bottomButtonView: UIView!
    @IBOutlet private var applyButton: RoundButton!
    var timeRangeMultiSlider: MultiSlider?
    var oddRangeMultiSlider: MultiSlider?
    
    // Variables
    // var timeSliderValues: [CGFloat] = []
    var lowerBoundTimeRange: CGFloat = 0.0
    var highBoundTimeRange: CGFloat = 48.0
    var lowerBoundOddsRange: CGFloat = 1.0
    var highBoundOddsRange: CGFloat = 30.0
    var countFilters: Int = 0

    var defaultMarket: MainMarketType = .homeDrawAway
    var marketViews: [FilterRowView] = []
    var filterValues: HomeFilterOptions?
    var mainMarkets: OrderedDictionary<String, EveryMatrix.Market> = [:]

    var sportsModel: PreLiveEventsViewModel
    var liveEventsViewModel: LiveEventsViewModel

    var delegate: HomeFilterOptionsViewDelegate?

    init(sportsModel: PreLiveEventsViewModel = PreLiveEventsViewModel(selectedSport: Sport.football),
         liveEventsViewModel: LiveEventsViewModel = LiveEventsViewModel(selectedSport: Sport.football)) {
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
        // Test values
        mainMarkets = Env.everyMatrixStorage.mainMarkets
    
        if sportsModel.homeFilterOptions != nil {
            filterValues = sportsModel.homeFilterOptions
        }
        else if liveEventsViewModel.homeFilterOptions != nil {
            filterValues = liveEventsViewModel.homeFilterOptions
        }
        else {
            filterValues = HomeFilterOptions()
        }
        
        defaultMarket = filterValues!.defaultMarket

        navigationLabel.text = localized("filters")
        navigationLabel.font = AppFont.with(type: .bold, size: 17)

        navigationResetButton.setTitle(localized("reset"), for: .normal)
        navigationResetButton.titleLabel?.font = AppFont.with(type: .semibold, size: 16)

        navigationCancelButton.setTitle(localized("cancel"), for: .normal)
        navigationCancelButton.titleLabel?.font = AppFont.with(type: .semibold, size: 16)

        sortByFilterCollapseView.isHidden = true
        
        setupTimeRangeSection()

        if let marketId = filterValues?.defaultMarket.marketId {
            setupAvailableMarketsSection(value: marketId)
        }
        
        setupOddsSection()

        applyButton.setTitle(localized("apply"), for: .normal)
        applyButton.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        applyButton.layer.cornerRadius = CornerRadius.button

    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App2.backgroundPrimary

        topView.backgroundColor = UIColor.App2.backgroundPrimary

        navigationView.backgroundColor = UIColor.App2.backgroundPrimary

        navigationLabel.textColor = UIColor.App2.textPrimary

        navigationResetButton.setTitleColor(UIColor.App2.buttonBackgroundPrimary, for: .normal)

        navigationCancelButton.setTitleColor(UIColor.App2.buttonBackgroundPrimary, for: .normal)

        scrollView.backgroundColor = UIColor.App2.backgroundPrimary

        stackContainerView.backgroundColor = UIColor.App2.backgroundPrimary

        stackView.backgroundColor = UIColor.App2.backgroundPrimary

        bottomButtonView.backgroundColor = UIColor.App2.backgroundPrimary

        applyButton.backgroundColor = UIColor.App2.buttonBackgroundPrimary
        applyButton.setTitleColor(UIColor.App2.buttonTextPrimary, for: .normal)
        
    }

    func setupTimeRangeSection() {
        let minValue: CGFloat = 0
        let maxValue: CGFloat = 48
        let values: [CGFloat]
        if delegate?.turnTimeRangeOn == true {
            timeRangeCollapseView.isUserInteractionEnabled = true
            
             values = [filterValues!.lowerBoundTimeRange, filterValues!.highBoundTimeRange]
        }
        else {
            timeRangeCollapseView.isUserInteractionEnabled = false
            values = [minValue, maxValue]
            timeRangeCollapseView.alpha = 0.3 // para desmaiar as cores
        }
        lowerBoundTimeRange = values[0]
        highBoundTimeRange = values[1]
        timeRangeCollapseView.setTitle(title: localized("time_today_only"))
        timeRangeCollapseView.hasCheckbox = false

        let contentView = timeRangeCollapseView.getContentView()
        self.timeRangeMultiSlider = MultiSlider()
        timeRangeMultiSlider?.backgroundColor = UIColor.App2.backgroundSecondary
        timeRangeMultiSlider?.orientation = .horizontal
        timeRangeMultiSlider?.minimumTextualValue = localized("now")
        timeRangeMultiSlider?.minimumValue = minValue
        timeRangeMultiSlider?.maximumValue = maxValue
        timeRangeMultiSlider?.outerTrackColor = UIColor.App2.separatorLine
        timeRangeMultiSlider?.value = values
        timeRangeMultiSlider?.snapStepSize = 1
        timeRangeMultiSlider?.thumbImage = UIImage(named: "slider_thumb_icon")
        timeRangeMultiSlider?.tintColor = UIColor.App2.highlightPrimary
        timeRangeMultiSlider?.trackWidth = 6
        timeRangeMultiSlider?.showsThumbImageShadow = false
        timeRangeMultiSlider?.keepsDistanceBetweenThumbs = false
        timeRangeMultiSlider?.addTarget(self, action: #selector(timeSliderChanged), for: .valueChanged)
        timeRangeMultiSlider?.valueLabelPosition = .bottom
        timeRangeMultiSlider?.valueLabelColor = UIColor.App2.textPrimary
        timeRangeMultiSlider?.valueLabelFont = AppFont.with(type: .bold, size: 14)

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
        for market in mainMarkets {
            if !filterMarketsId.contains(market.value.bettingTypeId!) {
                let marketView = FilterRowView()
                marketView.buttonType = .radio
                marketView.setTitle(title: "\(market.value.bettingTypeName!)")
                marketView.viewId = Int(market.value.bettingTypeId!)!
                marketViews.append(marketView)
                filterMarketsId.append(market.value.bettingTypeId!)
                availableMarketsCollapseView.addViewtoStack(view: marketView)
            }
        }

        // Set selected view
        let viewInt = Int(value)
        for view in marketViews {
            view.didTapView = { _ in
                self.checkMarketRadioOptions(views: self.marketViews, viewTapped: view)
            }
            // Default market selected
            if view.viewId == viewInt {
                view.isChecked = true
            }
        }

        availableMarketsCollapseView.didToggle = { value in
            if value {
                UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseIn, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                })
            }
        }
    }

    func checkMarketRadioOptions(views: [FilterRowView], viewTapped: FilterRowView) {
        for view in views {
            view.isChecked = false
        }
        viewTapped.isChecked = true
        
        if let defaultMarketInit = MainMarketType.init(rawValue: String(viewTapped.viewId)) {
            defaultMarket = defaultMarketInit
            oddsCollapseView.setTitleWithBold(title: localized("odds_filter") + " " + String(defaultMarket.marketName), charToSplit: ":")
        }
        
    }

    func setupOddsSection() {
        let minValue: CGFloat = 1.0
        let maxValue: CGFloat = 30.0

        lowerBoundOddsRange = filterValues!.lowerBoundOddsRange
        highBoundOddsRange = filterValues!.highBoundOddsRange
        oddsCollapseView.setTitleWithBold(title: localized("odds_filter") + " " + String(defaultMarket.marketName), charToSplit: ":")
        oddsCollapseView.hasCheckbox = false
        
        //oddsCollapseView.backgroundColor = UIColor.App2.backgroundPrimary
        let contentView = oddsCollapseView.getContentView()
        
        self.oddRangeMultiSlider = MultiSlider()
 
        oddRangeMultiSlider?.backgroundColor = UIColor.App2.backgroundSecondary
        oddRangeMultiSlider?.orientation = .horizontal
        oddRangeMultiSlider?.minimumValue = minValue
        oddRangeMultiSlider?.maximumValue = maxValue
        oddRangeMultiSlider?.outerTrackColor = UIColor.App2.highlightPrimary
        oddRangeMultiSlider?.value = [lowerBoundOddsRange, highBoundOddsRange]
        oddRangeMultiSlider?.snapStepSize = 0.1
        oddRangeMultiSlider?.thumbImage = UIImage(named: "slider_thumb_icon")
        oddRangeMultiSlider?.tintColor = UIColor.App2.highlightPrimary
        oddRangeMultiSlider?.trackWidth = 6
        oddRangeMultiSlider?.showsThumbImageShadow = false
        oddRangeMultiSlider?.keepsDistanceBetweenThumbs = false
        oddRangeMultiSlider?.addTarget(self, action: #selector(oddsSliderChanged), for: .valueChanged)
    
        oddRangeMultiSlider?.valueLabelPosition = .notAnAttribute
      
        if let oddRangeMultiSlider = oddRangeMultiSlider {
            contentView.addConstrainedSubview(oddRangeMultiSlider, constrain: .leftMargin, .rightMargin, .bottomMargin, .topMargin)
            contentView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
          
        }

        oddsCollapseView.hasSliderInfo = true
        oddsCollapseView.updateOddsLabels(fromText: "\(lowerBoundOddsRange)", toText: "\(highBoundOddsRange)")

        oddsCollapseView.didToggle = { value in
            if value {
                UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseIn, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                })
            }
        }
    }

    @objc func timeSliderChanged(_ slider: MultiSlider) {
        // Get time slider values
        lowerBoundTimeRange = slider.value[0]
        highBoundTimeRange = slider.value[1]
    }

    @objc func oddsSliderChanged(_ slider: MultiSlider) {
        // Get odds slider values
        let minValue = String(format: "%.1f", slider.value[0])
        let maxValue = String(format: "%.1f", slider.value[1])
        oddsCollapseView.updateOddsLabels(fromText: minValue, toText: maxValue)
        highBoundOddsRange = slider.value[1].round(to: 1)
        lowerBoundOddsRange = slider.value[0].round(to: 1)

    }

    @IBAction private func resetAction() {
        let homeFilterOptions = HomeFilterOptions()

        lowerBoundTimeRange = homeFilterOptions.lowerBoundTimeRange
        highBoundTimeRange = homeFilterOptions.highBoundTimeRange
        timeRangeMultiSlider?.value = [homeFilterOptions.lowerBoundTimeRange, homeFilterOptions.highBoundTimeRange]
        oddRangeMultiSlider?.value = [homeFilterOptions.lowerBoundOddsRange, homeFilterOptions.highBoundOddsRange]
        
        if let oddRangeMultiSlider = oddRangeMultiSlider {
            lowerBoundOddsRange = oddRangeMultiSlider.value[0].round(to: 1)
            highBoundOddsRange = oddRangeMultiSlider.value[1].round(to: 1)
            oddsCollapseView.updateOddsLabels(fromText: "\(lowerBoundOddsRange)", toText: "\(highBoundOddsRange)")
        }
        
        for view in self.marketViews {
            view.isChecked = false
            // Default market selected
            if view.viewId == Int(homeFilterOptions.defaultMarket.marketId) {
                view.isChecked = true
                
                if let defaultMarketInit = MainMarketType.init(rawValue: String(view.viewId)) {
                    defaultMarket = defaultMarketInit
                }
                
            }
        }
        countFilters = 0
    }

    @IBAction private func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction private func applyFiltersAction() {
        
        if lowerBoundTimeRange != 0.0 || highBoundTimeRange != 48.0 {
            countFilters += 1
        }
        
        if lowerBoundOddsRange != 1.0 || highBoundOddsRange != 30.0 {
            countFilters += 1
        }
        
        if defaultMarket.marketId != MainMarketType.homeDrawAway.marketId {
           countFilters += 1
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
