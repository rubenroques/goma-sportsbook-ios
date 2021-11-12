//
//  HomeFilterViewController.swift
//  ShowcaseProd
//
//  Created by André Lascas on 13/10/2021.
//

import UIKit
import MultiSlider
import OrderedCollections

class HomeFilterViewController: UIViewController{
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
    // Variables
    var timeSliderValues: [CGFloat] = []
    var oddsSliderValues: [CGFloat] = []
    var slidersArray: [MultiSlider] = []
    var defaultMarketId: Int = 1
    var marketViews: [FilterRowView] = []
    var filterValues: HomeFilterOptions?
    var mainMarkets: OrderedDictionary<String, EveryMatrix.Market> = [:]
    var sportsModel: SportsViewModel
    var liveEventsViewModel: LiveEventsViewModel
    weak var delegate: HomeFilterOptionsViewDelegate?
    var count : Int = 0
    
    init( sportsModel: SportsViewModel = SportsViewModel(selectedSportId: .football) , liveEventsViewModel: LiveEventsViewModel = LiveEventsViewModel(selectedSportId: .football) ) {
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
    
        if(sportsModel.homeFilterOptions != nil ){
            filterValues = sportsModel.homeFilterOptions
        }else if (liveEventsViewModel.homeFilterOptions != nil){
            filterValues = liveEventsViewModel.homeFilterOptions
        }else{
            filterValues = HomeFilterOptions()
        }
        
        defaultMarketId = filterValues!.defaultMarketId

        navigationLabel.text = localized("string_filters")
        navigationLabel.font = AppFont.with(type: .bold, size: 17)

        navigationResetButton.setTitle(localized("string_reset"), for: .normal)
        navigationResetButton.titleLabel?.font = AppFont.with(type: .semibold, size: 16)

        navigationCancelButton.setTitle(localized("string_cancel"), for: .normal)
        navigationCancelButton.titleLabel?.font = AppFont.with(type: .semibold, size: 16)

        sortByFilterCollapseView.isHidden = true
        
        setupTimeRangeSection()

        setupAvailableMarketsSection(value: "\(String(describing: filterValues!.defaultMarketId))")

        setupOddsSection()

        applyButton.setTitle(localized("string_apply"), for: .normal)
        applyButton.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        applyButton.layer.cornerRadius = CornerRadius.button
        
        
        
        
        
        
        
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainBackground

        topView.backgroundColor = UIColor.App.mainBackground

        navigationView.backgroundColor = UIColor.App.mainBackground

        navigationLabel.textColor = UIColor.App.headingMain

        navigationResetButton.setTitleColor(UIColor.App.mainTint, for: .normal)

        navigationCancelButton.setTitleColor(UIColor.App.mainTint, for: .normal)

        scrollView.backgroundColor = UIColor.App.mainBackground

        stackContainerView.backgroundColor = UIColor.App.mainBackground

        stackView.backgroundColor = UIColor.App.mainBackground

        bottomButtonView.backgroundColor = UIColor.App.mainBackground

        applyButton.backgroundColor = UIColor.App.mainTint
        applyButton.setTitleColor(UIColor.App.headingMain, for: .normal)

    }

    func setupTimeRangeSection() {
        let minValue: CGFloat = 0
        let maxValue: CGFloat = 24
        let values : [CGFloat]
        if delegate?.turnTimeRangeOn == true {
            timeRangeCollapseView.isUserInteractionEnabled = true
             values = filterValues!.timeRange
        }else{
            timeRangeCollapseView.isUserInteractionEnabled = false
            values = [minValue , maxValue]
            timeRangeCollapseView.alpha = 0.3 //para desmaiar as cores
        
        }
        timeSliderValues = values
        timeRangeCollapseView.setTitle(title: localized("string_time_today_only"))
        timeRangeCollapseView.hasCheckbox = false
        
        
        let contentView = timeRangeCollapseView.getContentView()

        setupSlider(minValue: minValue, maxValue: maxValue, values: values, steps: 1, hasLabels: true, edges: UIEdgeInsets(top: 8, left: 8, bottom: 16, right: 8), view: contentView, target: #selector(timeSliderChanged))

        timeRangeCollapseView.didToggle = { value in
            print(value)
            if value {
                UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseIn, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                })
            }
        }
        
        

    }

    func setupAvailableMarketsSection(value: String) {
        availableMarketsCollapseView.setTitle(title: localized("string_default_market"))
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
        print(value)
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
        defaultMarketId = viewTapped.viewId
    }

    func setupOddsSection() {
        let minValue: CGFloat = 1.0
        let maxValue: CGFloat = 30.0
        let values = filterValues!.oddsRange
        oddsSliderValues = values
        oddsCollapseView.setTitle(title: localized("string_odds_filter"))
        oddsCollapseView.hasCheckbox = false
        let contentView = oddsCollapseView.getContentView()
        setupSlider(minValue: minValue, maxValue: maxValue, values: values, steps: 0.1, hasLabels: false, edges: UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8), view: contentView, target: #selector(oddsSliderChanged))

        oddsCollapseView.hasSliderInfo = true
        oddsCollapseView.updateOddsLabels(fromText: "\(values[0])", toText: "\(values[1])")

        oddsCollapseView.didToggle = { value in
            if value {
                UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseIn, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                })
            }
        }
    }

    func setupSlider(minValue: CGFloat, maxValue: CGFloat, values: [CGFloat], steps: CGFloat, hasLabels: Bool, edges: UIEdgeInsets, view: UIView, target: Selector) {
        let horizontalMultiSlider = MultiSlider()
        horizontalMultiSlider.backgroundColor = UIColor.App.secondaryBackground
        horizontalMultiSlider.orientation = .horizontal
        horizontalMultiSlider.minimumValue = minValue
        horizontalMultiSlider.maximumValue = maxValue
        horizontalMultiSlider.outerTrackColor = UIColor.App.fadedGrayLine
        horizontalMultiSlider.value = values
        horizontalMultiSlider.snapStepSize = steps
        horizontalMultiSlider.thumbImage = UIImage(named: "slider_thumb_icon")
        horizontalMultiSlider.tintColor = UIColor.App.mainTint
        horizontalMultiSlider.trackWidth = 6
        horizontalMultiSlider.showsThumbImageShadow = false
        horizontalMultiSlider.keepsDistanceBetweenThumbs = false
        horizontalMultiSlider.addTarget(self, action: target, for: .valueChanged)
        if hasLabels {
            horizontalMultiSlider.valueLabelPosition = .bottom
            horizontalMultiSlider.valueLabelColor = UIColor.App.headingMain
            horizontalMultiSlider.valueLabelFont = AppFont.with(type: .bold, size: 14)
        }
        else {
            horizontalMultiSlider.valueLabelPosition = .notAnAttribute
        }

        view.addConstrainedSubview(horizontalMultiSlider, constrain: .leftMargin, .rightMargin, .bottomMargin, .topMargin)
        view.layoutMargins = edges
        slidersArray.append(horizontalMultiSlider)

    }

    @objc func timeSliderChanged(_ slider: MultiSlider) {
        // Get time slider values
        timeSliderValues = slider.value
        print(timeSliderValues)
    }

    @objc func oddsSliderChanged(_ slider: MultiSlider) {
        // Get odds slider values
        let minValue = String(format: "%.1f", slider.value[0])
        let maxValue = String(format: "%.1f", slider.value[1])
        oddsCollapseView.updateOddsLabels(fromText: minValue, toText: maxValue)
        oddsSliderValues = [slider.value[0].round(to: 1), slider.value[1].round(to: 1)]
        print(oddsSliderValues)
    }

    @IBAction private func resetAction() {
        let homeFilterOptions = HomeFilterOptions()

        slidersArray[0].value = homeFilterOptions.timeRange
        
        slidersArray[1].value = homeFilterOptions.oddsRange
        
        oddsCollapseView.updateOddsLabels(fromText: "\(slidersArray[1].value[0])", toText: "\(slidersArray[1].value[1])")
        oddsSliderValues = [slidersArray[1].value[0].round(to: 1), slidersArray[1].value[1].round(to: 1)]
        
        
        for view in self.marketViews {
            view.isChecked = false
            // Default market selected
            if view.viewId == homeFilterOptions.defaultMarketId {
                view.isChecked = true
                defaultMarketId = view.viewId
            }
        }
        count = 0
    }

    @IBAction private func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction private func applyFiltersAction() {
        
        if timeSliderValues[0] != 0.0 || timeSliderValues[1] != 24.0{
            count = count + 1
        }
        
        if oddsSliderValues[0] != 1.0 || oddsSliderValues[1] != 30.0{
            count = count + 1
        }
        
        if defaultMarketId != 69 {
           count = count + 1
        }
        
        let homeFilterOptions = HomeFilterOptions(timeRange: timeSliderValues, defaultMarketId: defaultMarketId, oddsRange: oddsSliderValues, countFilters : count)
        delegate?.setHomeFilters(homeFilters: homeFilterOptions)
        
        self.dismiss(animated: true, completion: nil)
        
    }

}
