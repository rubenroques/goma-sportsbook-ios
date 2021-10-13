//
//  HomeFilterViewController.swift
//  ShowcaseProd
//
//  Created by André Lascas on 13/10/2021.
//

import UIKit
import MultiSlider

class HomeFilterViewController: UIViewController {
    @IBOutlet private var topView: UIView!
    @IBOutlet private var navigationView: UIView!
    @IBOutlet private var navigationLabel: UILabel!
    @IBOutlet private var navigationCancelButton: UIButton!
    @IBOutlet private var navigationResetButton: UIButton!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var sortByFilterCollapseView: FilterCollapseView!

    @IBOutlet private var timeRangeCollapseView: FilterCollapseView!
    @IBOutlet private var availableMarketsCollapseView: FilterCollapseView!
    @IBOutlet private var bottomButtonView: UIView!
    @IBOutlet private var applyButton: RoundButton!

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

        navigationLabel.text = localized("string_filters")
        navigationLabel.font = AppFont.with(type: .bold, size: 17)

        navigationResetButton.setTitle(localized("string_reset"), for: .normal)
        navigationResetButton.titleLabel?.font = AppFont.with(type: .semibold, size: 16)

        navigationCancelButton.setTitle(localized("string_cancel"), for: .normal)
        navigationCancelButton.titleLabel?.font = AppFont.with(type: .semibold, size: 16)

        setupSortBySection()

        setupTimeRangeSection()

        setupAvailableMarketsSection()

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

        stackView.backgroundColor = UIColor.App.mainBackground

        bottomButtonView.backgroundColor = UIColor.App.mainBackground

        applyButton.backgroundColor = UIColor.App.mainTint
        applyButton.setTitleColor(UIColor.App.headingMain, for: .normal)

    }

    func setupSortBySection() {
        sortByFilterCollapseView.setTitle(title: localized("string_sort_by"))
        sortByFilterCollapseView.hasCheckbox = false

        let startingSoonView = FilterRowView()
        startingSoonView.buttonType = .radio
        let startingSoonRadio = startingSoonView.getRadioButton()
        startingSoonView.setTitle(title: localized("string_starting_soon"))

        let competitionView = FilterRowView()
        competitionView.buttonType = .radio
        let competitionRadio = competitionView.getRadioButton()
        competitionView.setTitle(title: localized("string_by_competition"))

        let lowOddsView = FilterRowView()
        lowOddsView.buttonType = .radio
        let lowRadio = lowOddsView.getRadioButton()
        lowOddsView.setTitle(title: localized("string_lowest_odds"))

        let highOddsView = FilterRowView()
        highOddsView.buttonType = .radio
        let highRadio = highOddsView.getRadioButton()
        highOddsView.hasBorderBottom = false
        highOddsView.setTitle(title: localized("string_highest_odds"))

        //Alternate Radio Button
        startingSoonRadio.alternateButton = [competitionRadio, lowRadio, highRadio]
        startingSoonRadio.isSelected = true
        competitionRadio.alternateButton = [startingSoonRadio, lowRadio, highRadio]
        lowRadio.alternateButton = [competitionRadio, startingSoonRadio, highRadio]
        highRadio.alternateButton = [competitionRadio, lowRadio, startingSoonRadio]


        sortByFilterCollapseView.addViewtoStack(view: startingSoonView)
        sortByFilterCollapseView.addViewtoStack(view: competitionView)
        sortByFilterCollapseView.addViewtoStack(view: lowOddsView)
        sortByFilterCollapseView.addViewtoStack(view: highOddsView)
    }

    func setupTimeRangeSection() {
        timeRangeCollapseView.setTitle(title: localized("string_time_range"))
        timeRangeCollapseView.hasCheckbox = true
        timeRangeCollapseView.setCheckboxSelected(selected: true)

        let horizontalMultiSlider = MultiSlider()
        //horizontalMultiSlider.disabledThumbIndices = [0]
        horizontalMultiSlider.backgroundColor = UIColor.App.secondaryBackground
        horizontalMultiSlider.orientation = .horizontal
        horizontalMultiSlider.minimumValue = 0
        horizontalMultiSlider.maximumValue = 24
        horizontalMultiSlider.outerTrackColor = UIColor.App.headerTextField
                horizontalMultiSlider.value = [0, 24]
        horizontalMultiSlider.snapStepSize = 1
        horizontalMultiSlider.thumbImage = UIImage(named: "sport_type_soccer_icon")
        horizontalMultiSlider.valueLabelPosition = .bottomMargin
        horizontalMultiSlider.tintColor = UIColor.App.mainTint
        horizontalMultiSlider.trackWidth = 6
        horizontalMultiSlider.showsThumbImageShadow = false
        horizontalMultiSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        view.addConstrainedSubview(horizontalMultiSlider, constrain: .leftMargin, .rightMargin, .bottomMargin)
        view.layoutMargins = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)

        horizontalMultiSlider.keepsDistanceBetweenThumbs = false
        //horizontalMultiSlider.valueLabelFormatter.positiveSuffix = " 𝞵s"
        horizontalMultiSlider.valueLabelColor = UIColor.App.headingMain
        horizontalMultiSlider.valueLabelFont = AppFont.with(type: .bold, size: 14)
        timeRangeCollapseView.addViewtoStack(view: horizontalMultiSlider)
    }

    @objc func sliderChanged(_ slider: MultiSlider) {
            print("thumb \(slider.draggedThumbIndex) moved")
            print("now thumbs are at \(slider.value)") // e.g., [1.0, 4.5, 5.0]
        }

    func setupAvailableMarketsSection() {
        availableMarketsCollapseView.setTitle(title: localized("string_available_markets"))
        availableMarketsCollapseView.hasCheckbox = true
        availableMarketsCollapseView.setCheckboxSelected(selected: true)

        let resultView = FilterRowView()
        resultView.buttonType = .checkbox
        resultView.setTitle(title: "Result")
        resultView.setCheckboxSelected(selected: true)

        let doubleOutcomeView = FilterRowView()
        doubleOutcomeView.buttonType = .checkbox
        doubleOutcomeView.setTitle(title: "Double Outcome")

        let handicapView = FilterRowView()
        handicapView.buttonType = .checkbox
        handicapView.hasBorderBottom = false
        handicapView.setTitle(title: "Handycap")



        availableMarketsCollapseView.addViewtoStack(view: resultView)
        availableMarketsCollapseView.addViewtoStack(view: doubleOutcomeView)
        availableMarketsCollapseView.addViewtoStack(view: handicapView)
    }
}
