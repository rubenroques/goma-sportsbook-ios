//
//  FilterHistoryViewController.swift
//  ShowcaseProd
//
//  Created by Teresa on 18/02/2022.
//

import Foundation
import Combine
import UIKit

class FilterHistoryViewController: UIViewController {

    // MARK: - Private Properties
    // Sub Views
    private lazy var navigationBaseView: UIView = Self.createNavigationView()
    private lazy var filterCollapseView: FilterCollapseView = FilterCollapseView()
    private lazy var resetButton: UILabel = Self.createTopLabel()
    private lazy var filterBaseView: UIView = Self.createBaseView()
    private lazy var cancelButton: UILabel = Self.createTopLabel()
    private lazy var topLabel: UILabel = Self.createTopLabel()
    private lazy var bottomBaseView: UIView = Self.createBottomView()
    private lazy var applyButton: UIButton = Self.createButton()
    private lazy var bottomSeparatorView: UIView = Self.createSimpleView()
    private lazy var dateRangeStackView: UIStackView = Self.createHorizontalStackView()
    private lazy var startTimeHeaderTextView: HeaderTextFieldView = HeaderTextFieldView()
    private lazy var endTimeHeaderTextView: HeaderTextFieldView = HeaderTextFieldView()
    private lazy var filterBaseStackView: UIStackView = Self.createFilterBaseStackView()

    var filterHistoryViewModel = FilterHistoryViewModel()
    var filterRowViews: [FilterRowView] = []

    var defaultFilter = FilterHistoryViewModel.FilterValue.past30Days

    // Logic
    private var cancellables: Set<AnyCancellable> = []
    private var filterSelectedOption: Int = 0

    private var startDate: Date?
    private var endDate: Date?

    var viewModel: FilterHistoryViewModel
    var didSelectFilterAction: ((FilterHistoryViewModel.FilterValue) -> Void)?

    // MARK: - Lifetime and Cycle
    init(viewModel: FilterHistoryViewModel = FilterHistoryViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()
        
        self.startTimeHeaderTextView.setPlaceholderText("From")
        self.startTimeHeaderTextView.setImageTextField(UIImage(named: "calendar_regular_icon")!)
        //self.startTimeHeaderTextView.isDisabled = false
        self.startTimeHeaderTextView.setDatePickerMode()
        
        self.endTimeHeaderTextView.setPlaceholderText("To")
        self.endTimeHeaderTextView.setImageTextField(UIImage(named: "calendar_regular_icon")!)
        //self.endTimeHeaderTextView.isDisabled = false
        self.endTimeHeaderTextView.setDatePickerMode()

        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.calendar = calendar
        components.year = -2
        let minDate = calendar.date(byAdding: components, to: Date())!

        startTimeHeaderTextView.datePicker.minimumDate = minDate
        startTimeHeaderTextView.datePicker.maximumDate = Date()

        endTimeHeaderTextView.datePicker.minimumDate = minDate
        endTimeHeaderTextView.datePicker.maximumDate = Date()

        self.resetButton.text = localized("reset")
        self.cancelButton.text = localized("cancel")
        
        self.view.bringSubviewToFront(self.dateRangeStackView)
        self.dateRangeStackView.bringSubviewToFront(self.startTimeHeaderTextView)
        self.dateRangeStackView.bringSubviewToFront(self.endTimeHeaderTextView)
        
        let tapCancelButton = UITapGestureRecognizer(target: self, action: #selector(self.cancelAction))
        cancelButton.isUserInteractionEnabled = true
        cancelButton.addGestureRecognizer(tapCancelButton)

        let tapResetButton = UITapGestureRecognizer(target: self, action: #selector(self.didTapResetButton))
        resetButton.isUserInteractionEnabled = true
        resetButton.addGestureRecognizer(tapResetButton)
        
        let tapApplyButton = UITapGestureRecognizer(target: self, action: #selector(self.applyAction))
        applyButton.isUserInteractionEnabled = true
        applyButton.addGestureRecognizer(tapApplyButton)

        self.dateRangeStackView.isHidden = true
        self.setupAvailableFilterOptionsSection()
        
        self.applyButton.setTitle(localized("apply"), for: .normal)
        StyleHelper.styleButton(button: self.applyButton)

        self.checkMarketRadioOptions(views: filterRowViews, viewTapped: filterRowViews[self.defaultFilter.identifier])
        self.bindToPublisher()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.checkMarketRadioOptions(views: filterRowViews, viewTapped: filterRowViews[self.viewModel.selectedFilterPublisher.value.identifier])
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        
        self.view.backgroundColor = UIColor.App.backgroundPrimary
        self.bottomSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.bottomBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.dateRangeStackView.backgroundColor = UIColor.App.backgroundSecondary
        self.filterCollapseView.backgroundColor = UIColor.App.backgroundSecondary
        self.resetButton.textColor = UIColor.App.highlightPrimary
        self.cancelButton.textColor = UIColor.App.highlightPrimary
        self.startTimeHeaderTextView.backgroundColor = .clear
        self.startTimeHeaderTextView.setViewColor(UIColor.App.backgroundTertiary)
        self.endTimeHeaderTextView.backgroundColor = .clear
        self.endTimeHeaderTextView.setViewColor(UIColor.App.backgroundTertiary)
        self.startTimeHeaderTextView.setViewBorderColor(UIColor.App.backgroundBorder)
        self.endTimeHeaderTextView.setViewBorderColor(UIColor.App.backgroundBorder)
        self.filterBaseView.backgroundColor = UIColor.App.backgroundSecondary
        
        self.startTimeHeaderTextView.setTextFieldColor(UIColor.App.textPrimary)
        self.endTimeHeaderTextView.setTextFieldColor(UIColor.App.textPrimary)

        self.startTimeHeaderTextView.setPlaceholderColor(UIColor.App.textPrimary)
        self.endTimeHeaderTextView.setPlaceholderColor(UIColor.App.textPrimary)

    }

    // MARK: - Bindings
    func bindToPublisher() {
  
        Publishers.CombineLatest3(self.startTimeHeaderTextView.textPublisher,
                                  self.endTimeHeaderTextView.textPublisher,
                                  self.viewModel.selectedFilterPublisher)
            .receive(on: DispatchQueue.main)
            .map({ startTime, endTime, selectedFilterType -> Bool in
                switch selectedFilterType {
                case .dateRange:
                    if startTime != nil && endTime != nil {
                        return true
                    }
                    return false
                default:
                    return true
                }
            })
            .sink(receiveValue: { isEnabled in
                self.applyButton.isEnabled = isEnabled
            })
            .store(in: &cancellables)

        self.startTimeHeaderTextView.textPublisher 
            .receive(on: DispatchQueue.main)
            .map(toDate)
            .compactMap({ $0 })
            .sink(receiveValue: { [weak self] startDate in
          
                self?.startDate = startDate
                self?.viewModel.setStartTime(dateString: startDate)
                
                if let endDate = self?.endDate,
                   endDate <= startDate,
                   let afterStartDateValue = Calendar.current.date(byAdding: .day, value: 1, to: startDate) {

                    let newEndDateString = afterStartDateValue.toString(formatString: "yyyy-MM-dd")

                    self?.endDate = afterStartDateValue
                    self?.endTimeHeaderTextView.setText(newEndDateString)
                    self?.viewModel.setStartTime(dateString: startDate)
                    self?.viewModel.setEndTime(dateString: endDate)
                    
                }

            })
            .store(in: &cancellables)

        self.endTimeHeaderTextView.textPublisher
            .receive(on: DispatchQueue.main)
            .map(toDate)
            .compactMap({ $0 })
            .sink(receiveValue: { [weak self] endDate in

                self?.endDate = endDate
                self?.viewModel.setEndTime(dateString: endDate)

                if let startDate = self?.startDate,
                   startDate >= endDate,
                   let beforeEndDateValue = Calendar.current.date(byAdding: .day, value: -1, to: endDate) {

                    let newStartDateString = beforeEndDateValue.toString(formatString: "yyyy-MM-dd")

                    self?.startDate = beforeEndDateValue
                    self?.startTimeHeaderTextView.setText(newStartDateString)
                    
                    self?.viewModel.setStartTime(dateString: startDate)
                    self?.viewModel.setEndTime(dateString: endDate)
                                               
                }

            })
            .store(in: &cancellables)

    }

    // MARK: - Convenience
    @IBAction private func didTapResetButton() {
        for view in self.filterRowViews {
            view.isChecked = false
            // Default filter selected
            if view.viewId == "\(defaultFilter.identifier)" {
                view.isChecked = true
            }
            else {
                view.isChecked = false
            }
        }
        self.dateRangeStackView.isHidden = true
        self.viewModel.didSelectFilter(atIndex: defaultFilter.identifier)
    }
    
    func checkMarketRadioOptions(views: [FilterRowView], viewTapped: FilterRowView) {
        for view in views {
            view.isChecked = false
        }
        viewTapped.isChecked = true
        if viewTapped.viewId == "2" {
            self.dateRangeStackView.isHidden = false
            self.viewModel.didSelectFilter(atIndex: Int(viewTapped.viewId) ?? 0)
        }
        else {
            self.dateRangeStackView.isHidden = true
            self.viewModel.didSelectFilter(atIndex: Int(viewTapped.viewId) ?? 0)
        }
        
    }
    
    @IBAction private func applyAction() {
        
        if self.viewModel.selectedFilterPublisher.value.identifier == 2 {
            if self.startTimeHeaderTextView.text != "" && self.endTimeHeaderTextView.text != "" {
                
                self.didSelectFilterAction?(self.viewModel.selectedFilterPublisher.value)
                self.dismiss(animated: true, completion: nil)
            }
            else {
                print("invalid dates")
            }
        }
        else {
            
            self.didSelectFilterAction?(self.viewModel.selectedFilterPublisher.value)
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction private func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension FilterHistoryViewController {

    private func setupAvailableFilterOptionsSection() {
        self.filterCollapseView.hasCheckbox = false

        self.filterCollapseView.setTitle(title: localized("filter_by_date"))
        
        for range in FilterHistoryViewModel.FilterValue.allCases {
            let filterRowView = FilterRowView()
            filterRowView.isChecked = false
            filterRowView.buttonType = .radio
            filterRowView.setTitle(title: range.key)
            filterRowView.viewId = "\(range.identifier)"
            filterRowViews.append(filterRowView)
            filterCollapseView.addViewtoStack(view: filterRowView)
        }

        // Set selected view
        var viewInt = defaultFilter.identifier
        
        if self.viewModel.selectedFilterPublisher.value.identifier != viewInt {
            viewInt = self.viewModel.selectedFilterPublisher.value.identifier
        }
        
        for view in filterRowViews {
            view.didTapView = { [weak self] _ in
                self?.viewModel.didSelectFilter(atIndex: Int(view.viewId) ?? 0)
                self?.checkMarketRadioOptions(views: self?.filterRowViews ?? [], viewTapped: view)
            }

            // Default market selected
            if view.viewId == "\(viewInt)" {
                view.isChecked = true
            }
        }
        
        filterCollapseView.didToggle = { value in
            if value {
                UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseIn, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                })
            }
        }

    }

}

extension FilterHistoryViewController {
    private func toDate(_ dateString: String?) -> Date? {
        var date: Date?
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let dateStringValue = dateString {
            date = dateFormatter.date(from: dateStringValue)
        }
        
        return date
    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension FilterHistoryViewController {

    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createSimpleView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createFilterImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.image = UIImage(named: "match_filters_icons")

        return imageView
    }
    
    private static func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }
    
    private static func createSegmentedControl() -> UISegmentedControl {
        let segment = UISegmentedControl(items: [localized("transactions"), localized("betting")])
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.selectedSegmentIndex = 0
        return segment
    }
    
    private static func createHorizontalStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 8
        
        return stack
    }
    
    private static func createVerticalStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 8
        
        return stack
    }
    
    private static func createTopLabel() -> UILabel {
        let label = UILabel()
        label.text = localized("Filter")
        label.font = AppFont.with(type: .bold, size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTextField() -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }

    private static func createTopSliderCollectionView() -> UICollectionView {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = .horizontal
        collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: collectionLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

        return collectionView
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }

    private static func createEmptyStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        button.setTitleColor(UIColor.App.buttonTextDisablePrimary, for: .disabled)
        button.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        button.setBackgroundColor(UIColor.App.buttonDisablePrimary, for: .disabled)
        
        return button
    }

    private static func createLoadingActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.stopAnimating()
        return activityIndicatorView
    }

    private static func createFilterBaseStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 4

        return stackView
    }

    private func setupSubviews() {

        // Add subviews to self.view or each other

        self.view.addSubview(self.navigationBaseView)
        self.view.addSubview(self.filterBaseView)
        self.view.addSubview(self.bottomSeparatorView)
        self.view.addSubview(self.bottomBaseView)

        self.navigationBaseView.addSubview(self.topLabel)
        self.navigationBaseView.addSubview(self.resetButton)
        self.navigationBaseView.addSubview(self.cancelButton)
        
        self.bottomBaseView.addSubview(self.applyButton)

        self.filterBaseView.addSubview(self.filterBaseStackView)

        self.filterBaseStackView.addArrangedSubview(self.filterCollapseView)
        self.filterBaseStackView.addArrangedSubview(self.dateRangeStackView)

//        self.filterBaseView.addSubview(self.filterCollapseView)
//        self.filterBaseView.addSubview(self.dateRangeStackView)

//        self.dateRangeBaseView.addSubview(self.dateRangeStackView)

        self.dateRangeStackView.addArrangedSubview(self.startTimeHeaderTextView)
        self.dateRangeStackView.addArrangedSubview(self.endTimeHeaderTextView)
        


        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.navigationBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.navigationBaseView.heightAnchor.constraint(equalToConstant: 50),
            
            self.topLabel.heightAnchor.constraint(equalToConstant: 20),
            self.topLabel.centerXAnchor.constraint(equalTo: self.navigationBaseView.centerXAnchor),
            self.topLabel.topAnchor.constraint(equalTo: self.navigationBaseView.topAnchor, constant: 16),
            
            self.resetButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16 ),
            self.resetButton.topAnchor.constraint(equalTo: self.navigationBaseView.topAnchor, constant: 16),

            self.cancelButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16 ),
            self.cancelButton.topAnchor.constraint(equalTo: self.navigationBaseView.topAnchor, constant: 16),
        ])

        NSLayoutConstraint.activate([
            self.filterBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            self.filterBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            self.filterBaseView.topAnchor.constraint(equalTo: self.navigationBaseView.bottomAnchor, constant: 30),

            self.filterBaseStackView.leadingAnchor.constraint(equalTo: self.filterBaseView.leadingAnchor),
            self.filterBaseStackView.trailingAnchor.constraint(equalTo: self.filterBaseView.trailingAnchor),
            self.filterBaseStackView.topAnchor.constraint(equalTo: self.filterBaseView.topAnchor),
            self.filterBaseStackView.bottomAnchor.constraint(equalTo: self.filterBaseView.bottomAnchor),

            self.filterCollapseView.leadingAnchor.constraint(equalTo: self.filterBaseStackView.leadingAnchor, constant: 2),
            self.filterCollapseView.trailingAnchor.constraint(equalTo: self.filterBaseStackView.trailingAnchor, constant: -2),
//            self.filterCollapseView.topAnchor.constraint(equalTo: self.filterBaseView.topAnchor, constant: 2),

        ])

        NSLayoutConstraint.activate([
            
//            self.dateRangeBaseView.leadingAnchor.constraint(equalTo: self.filterBaseView.leadingAnchor),
//            self.dateRangeBaseView.trailingAnchor.constraint(equalTo: self.filterBaseView.trailingAnchor),
//            self.dateRangeBaseView.topAnchor.constraint(equalTo: self.filterCollapseView.bottomAnchor),
//            self.dateRangeBaseView.bottomAnchor.constraint(equalTo: self.filterBaseView.bottomAnchor),
            
            self.dateRangeStackView.leadingAnchor.constraint(equalTo: self.filterBaseStackView.leadingAnchor, constant: 20),
            self.dateRangeStackView.trailingAnchor.constraint(equalTo: self.filterBaseStackView.trailingAnchor, constant: -20),
//            self.dateRangeStackView.topAnchor.constraint(equalTo: self.filterCollapseView.bottomAnchor),
//            self.dateRangeStackView.bottomAnchor.constraint(equalTo: self.filterBaseView.bottomAnchor),
            
            self.endTimeHeaderTextView.heightAnchor.constraint(equalToConstant: 80),

            self.startTimeHeaderTextView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            self.bottomSeparatorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomSeparatorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            self.bottomSeparatorView.bottomAnchor.constraint(equalTo: self.bottomBaseView.topAnchor),
            
            self.bottomBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.bottomBaseView.heightAnchor.constraint(equalToConstant: 90),
            
            self.applyButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            self.applyButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            self.applyButton.centerYAnchor.constraint(equalTo: self.bottomBaseView.centerYAnchor),
            self.applyButton.heightAnchor.constraint(equalToConstant: 50),
        ])

    }

}
