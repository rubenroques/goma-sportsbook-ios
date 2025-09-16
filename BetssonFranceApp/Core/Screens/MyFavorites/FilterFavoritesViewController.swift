//
//  FilterFavoritesViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 03/08/2023.
//

import UIKit
import Combine

class FilterFavoritesViewController: UIViewController {

    // MARK: - Private Properties
    private lazy var navigationBaseView: UIView = Self.createNavigationView()
    private lazy var topLabel: UILabel = Self.createTopLabel()
    private lazy var resetButton: UIButton = Self.createResetButton()
    private lazy var cancelButton: UIButton = Self.createCancelButton()
    private lazy var filterCollapseView: FilterCollapseView = FilterCollapseView()
    private lazy var filterBaseView: UIView = Self.createFilterBaseView()
    private lazy var applyButton: UIButton = Self.createApplyButton()

    var viewModel = FilterFavoritesViewModel()
    var filterRowViews: [FilterRowView] = []

    var defaultFilter = FilterFavoritesValue.time

    // Logic
    private var cancellables: Set<AnyCancellable> = []
    private var filterSelectedOption: Int = 0

    // Callbacks
    var didSelectFilterAction: ((FilterFavoritesValue) -> Void)?

    // MARK: - Lifetime and Cycle
    init(viewModel: FilterFavoritesViewModel = FilterFavoritesViewModel()) {
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

        let tapCancelButton = UITapGestureRecognizer(target: self, action: #selector(self.cancelAction))
        cancelButton.addGestureRecognizer(tapCancelButton)

        let tapResetButton = UITapGestureRecognizer(target: self, action: #selector(self.didTapResetButton))
        resetButton.addGestureRecognizer(tapResetButton)

        let tapApplyButton = UITapGestureRecognizer(target: self, action: #selector(self.applyAction))
        applyButton.addGestureRecognizer(tapApplyButton)

        self.setupSortFilterOptionsSection()

    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.filterBaseView.layer.cornerRadius = CornerRadius.view
        self.filterBaseView.layer.masksToBounds = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.filterCollapseView.backgroundColor = UIColor.App.backgroundSecondary

        self.resetButton.backgroundColor = .clear
        self.resetButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.cancelButton.backgroundColor = .clear
        self.cancelButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.filterBaseView.backgroundColor = UIColor.App.backgroundSecondary

        StyleHelper.styleButton(button: self.applyButton)

    }

    // MARK: Functions
    private func setupSortFilterOptionsSection() {

        self.filterCollapseView.hasCheckbox = false

        self.filterCollapseView.setTitle(title: localized("sort_by"))

        for (index, filter) in FilterFavoritesValue.allCases.enumerated() {
            let filterRowView = FilterRowView()
            filterRowView.isChecked = false
            filterRowView.buttonType = .radio
            filterRowView.setTitle(title: filter.name)
            filterRowView.viewId = "\(filter.identifier)"

            if index == 1 {
                filterRowView.hasBorderBottom = false
            }
            
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
                self?.checkSortRadioOptions(views: self?.filterRowViews ?? [], viewTapped: view)
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

    func checkSortRadioOptions(views: [FilterRowView], viewTapped: FilterRowView) {

        for view in views {
            view.isChecked = false
        }

        viewTapped.isChecked = true

        self.viewModel.didSelectFilter(atIndex: Int(viewTapped.viewId) ?? 0)

    }

    // MARK: - Actions
    @objc private func didTapResetButton() {
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
        self.viewModel.didSelectFilter(atIndex: defaultFilter.identifier)
    }

    @objc private func applyAction() {

        self.didSelectFilterAction?(self.viewModel.selectedFilterPublisher.value)
        self.dismiss(animated: true, completion: nil)
        
    }

    @objc private func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension FilterFavoritesViewController {

    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTopLabel() -> UILabel {
        let label = UILabel()
        label.text = localized("Filter")
        label.font = AppFont.with(type: .bold, size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createResetButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("Reset"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        return button
    }

    private static func createCancelButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("Cancel"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        return button
    }

    private static func createFilterBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createApplyButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("Apply"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        return button
    }

    private static func createBottomSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        self.view.addSubview(self.navigationBaseView)

        self.navigationBaseView.addSubview(self.topLabel)
        self.navigationBaseView.addSubview(self.resetButton)
        self.navigationBaseView.addSubview(self.cancelButton)

        self.view.addSubview(self.filterBaseView)

        self.filterBaseView.addSubview(self.filterCollapseView)

        self.view.addSubview(self.applyButton)

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
            self.filterBaseView.bottomAnchor.constraint(lessThanOrEqualTo: self.applyButton.topAnchor, constant: -10),

            self.filterCollapseView.leadingAnchor.constraint(equalTo: self.filterBaseView.leadingAnchor),
            self.filterCollapseView.trailingAnchor.constraint(equalTo: self.filterBaseView.trailingAnchor),
            self.filterCollapseView.topAnchor.constraint(equalTo: self.filterBaseView.topAnchor),
            self.filterCollapseView.bottomAnchor.constraint(equalTo: self.filterBaseView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([

            self.applyButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            self.applyButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            self.applyButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            self.applyButton.heightAnchor.constraint(equalToConstant: 50),
        ])

    }

}
