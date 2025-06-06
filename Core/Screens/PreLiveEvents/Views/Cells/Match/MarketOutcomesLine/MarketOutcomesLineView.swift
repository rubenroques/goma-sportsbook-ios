//
//  MarketOutcomesLineView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 2024.
//

import UIKit
import SwiftUI
import Combine
import ServicesProvider

// MARK: - ViewModel
class LegacyMarketOutcomesLineViewModel {
    // MARK: Outcome Types
    enum OutcomeType {
        case left
        case middle
        case right
    }

    // MARK: Display Mode
    enum DisplayMode {
        case normal
        case suspended
        case seeAll
    }

    // MARK: Odds Change Direction
    enum OddsChangeDirection {
        case up
        case down
        case none
    }

    // MARK: Outcome Model
    struct OutcomeInfo {
        var title: String
        var value: String
        var oddsChangeDirection: OddsChangeDirection
        var isSelected: Bool
        var isDisabled: Bool

        init(title: String = "",
             value: String = "",
             oddsChangeDirection: OddsChangeDirection = .none,
             isSelected: Bool = false,
             isDisabled: Bool = false) {
            self.title = title
            self.value = value
            self.oddsChangeDirection = oddsChangeDirection
            self.isSelected = isSelected
            self.isDisabled = isDisabled
        }
    }

    // MARK: Publishers
    private(set) var displayModePublisher = CurrentValueSubject<DisplayMode, Never>(.normal)
    private(set) var leftOutcomePublisher = CurrentValueSubject<OutcomeInfo, Never>(OutcomeInfo())
    private(set) var middleOutcomePublisher = CurrentValueSubject<OutcomeInfo, Never>(OutcomeInfo())
    private(set) var rightOutcomePublisher = CurrentValueSubject<OutcomeInfo, Never>(OutcomeInfo())
    private(set) var suspendedTextPublisher = CurrentValueSubject<String, Never>("Suspended")
    private(set) var seeAllTextPublisher = CurrentValueSubject<String, Never>("See All")
    private(set) var showMiddleOutcomePublisher = CurrentValueSubject<Bool, Never>(true)

    // MARK: Initialization
    init(displayMode: DisplayMode = .normal,
         leftOutcome: OutcomeInfo = OutcomeInfo(),
         middleOutcome: OutcomeInfo = OutcomeInfo(),
         rightOutcome: OutcomeInfo = OutcomeInfo(),
         suspendedText: String = "Suspended",
         seeAllText: String = "See All",
         showMiddleOutcome: Bool = true) {

        self.displayModePublisher.send(displayMode)
        self.leftOutcomePublisher.send(leftOutcome)
        self.middleOutcomePublisher.send(middleOutcome)
        self.rightOutcomePublisher.send(rightOutcome)
        self.suspendedTextPublisher.send(suspendedText)
        self.seeAllTextPublisher.send(seeAllText)
        self.showMiddleOutcomePublisher.send(showMiddleOutcome)
    }

    // MARK: Configuration Methods
    func configure(displayMode: DisplayMode,
                   leftOutcome: OutcomeInfo,
                   middleOutcome: OutcomeInfo? = nil,
                   rightOutcome: OutcomeInfo,
                   suspendedText: String? = nil,
                   seeAllText: String? = nil) {

        self.displayModePublisher.send(displayMode)
        self.leftOutcomePublisher.send(leftOutcome)

        if let middleOutcome = middleOutcome {
            self.middleOutcomePublisher.send(middleOutcome)
            self.showMiddleOutcomePublisher.send(true)
        } else {
            self.showMiddleOutcomePublisher.send(false)
        }

        self.rightOutcomePublisher.send(rightOutcome)

        if let suspendedText = suspendedText {
            self.suspendedTextPublisher.send(suspendedText)
        }

        if let seeAllText = seeAllText {
            self.seeAllTextPublisher.send(seeAllText)
        }
    }

    func updateOutcomeSelection(type: OutcomeType, isSelected: Bool) {
        switch type {
        case .left:
            var outcome = leftOutcomePublisher.value
            outcome.isSelected = isSelected
            leftOutcomePublisher.send(outcome)

        case .middle:
            var outcome = middleOutcomePublisher.value
            outcome.isSelected = isSelected
            middleOutcomePublisher.send(outcome)

        case .right:
            var outcome = rightOutcomePublisher.value
            outcome.isSelected = isSelected
            rightOutcomePublisher.send(outcome)
        }
    }

    func updateOddsValue(type: OutcomeType, value: String, changeDirection: OddsChangeDirection = .none) {
        switch type {
        case .left:
            var outcome = leftOutcomePublisher.value
            outcome.value = value
            outcome.oddsChangeDirection = changeDirection
            leftOutcomePublisher.send(outcome)

        case .middle:
            var outcome = middleOutcomePublisher.value
            outcome.value = value
            outcome.oddsChangeDirection = changeDirection
            middleOutcomePublisher.send(outcome)

        case .right:
            var outcome = rightOutcomePublisher.value
            outcome.value = value
            outcome.oddsChangeDirection = changeDirection
            rightOutcomePublisher.send(outcome)
        }
    }

    func toggleDisplayMode(_ mode: DisplayMode) {
        self.displayModePublisher.send(mode)
    }
}

// MARK: - View
class MarketOutcomesLineView: UIView {

    // MARK: Private Properties
    // Container stack view for outcomes
    private lazy var oddsStackView: UIStackView = Self.createOddsStackView()

    // Left outcome views
    private lazy var leftBaseView: UIView = Self.createBaseView()
    private lazy var leftTitleLabel: UILabel = Self.createTitleLabel()
    private lazy var leftValueLabel: UILabel = Self.createValueLabel()
    private lazy var leftUpChangeImage: UIImageView = Self.createUpChangeImage()
    private lazy var leftDownChangeImage: UIImageView = Self.createDownChangeImage()

    // Middle outcome views
    private lazy var middleBaseView: UIView = Self.createBaseView()
    private lazy var middleTitleLabel: UILabel = Self.createTitleLabel()
    private lazy var middleValueLabel: UILabel = Self.createValueLabel()
    private lazy var middleUpChangeImage: UIImageView = Self.createUpChangeImage()
    private lazy var middleDownChangeImage: UIImageView = Self.createDownChangeImage()

    // Right outcome views
    private lazy var rightBaseView: UIView = Self.createBaseView()
    private lazy var rightTitleLabel: UILabel = Self.createTitleLabel()
    private lazy var rightValueLabel: UILabel = Self.createValueLabel()
    private lazy var rightUpChangeImage: UIImageView = Self.createUpChangeImage()
    private lazy var rightDownChangeImage: UIImageView = Self.createDownChangeImage()

    // Suspended and see all views
    private lazy var suspendedBaseView: UIView = Self.createSuspendedBaseView()
    private lazy var suspendedLabel: UILabel = Self.createSuspendedLabel()
    private lazy var seeAllBaseView: UIView = Self.createSeeAllBaseView()
    private lazy var seeAllLabel: UILabel = Self.createSeeAllLabel()

    // MARK: Callback Closures
    var onOutcomeSelected: ((LegacyMarketOutcomesLineViewModel.OutcomeType) -> Void)?
    var onOutcomeDeselected: ((LegacyMarketOutcomesLineViewModel.OutcomeType) -> Void)?
    var onOutcomeLongPress: ((LegacyMarketOutcomesLineViewModel.OutcomeType) -> Void)?
    var onSeeAllTapped: (() -> Void)?

    // MARK: ViewModel
    private var viewModel: LegacyMarketOutcomesLineViewModel?
    private var cancellables = Set<AnyCancellable>()

    // MARK: Lifetime Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
        self.setupWithTheme()
        self.setupGestureRecognizers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupSubviews()
        self.setupWithTheme()
        self.setupGestureRecognizers()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    // MARK: Theme Setup
    func setupWithTheme() {
        self.backgroundColor = .clear

        // Base views
        self.leftBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.middleBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.rightBaseView.backgroundColor = UIColor.App.backgroundOdds

        // Suspended view
        self.suspendedBaseView.backgroundColor = UIColor.App.backgroundDisabledOdds
        self.suspendedBaseView.layer.borderColor = UIColor.App.backgroundBorder.resolvedColor(with: self.traitCollection).cgColor
        self.suspendedLabel.textColor = UIColor.App.textDisablePrimary

        // See all view
        self.seeAllBaseView.backgroundColor = UIColor.App.backgroundDisabledOdds
        self.seeAllLabel.textColor = UIColor.App.textPrimary

        // Update colors based on viewModel if available
        updateViewColors()
    }

    private func updateViewColors() {
        guard let viewModel = viewModel else { return }

        // Left outcome
        if viewModel.leftOutcomePublisher.value.isSelected {
            self.leftBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.leftTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.leftValueLabel.textColor = UIColor.App.buttonTextPrimary
        } else {
            self.leftBaseView.backgroundColor = UIColor.App.backgroundOdds
            self.leftTitleLabel.textColor = UIColor.App.textPrimary
            self.leftValueLabel.textColor = UIColor.App.textPrimary
        }

        // Middle outcome
        if viewModel.middleOutcomePublisher.value.isSelected {
            self.middleBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.middleTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.middleValueLabel.textColor = UIColor.App.buttonTextPrimary
        } else {
            self.middleBaseView.backgroundColor = UIColor.App.backgroundOdds
            self.middleTitleLabel.textColor = UIColor.App.textPrimary
            self.middleValueLabel.textColor = UIColor.App.textPrimary
        }

        // Right outcome
        if viewModel.rightOutcomePublisher.value.isSelected {
            self.rightBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.rightTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.rightValueLabel.textColor = UIColor.App.buttonTextPrimary
        } else {
            self.rightBaseView.backgroundColor = UIColor.App.backgroundOdds
            self.rightTitleLabel.textColor = UIColor.App.textPrimary
            self.rightValueLabel.textColor = UIColor.App.textPrimary
        }
    }

    // MARK: Configuration
    func configure(with viewModel: LegacyMarketOutcomesLineViewModel) {
        self.viewModel = viewModel
        self.setupBindings()
    }

    func cleanupForReuse() {
        self.viewModel = nil
        self.cancellables.removeAll()

        // Reset UI state
        self.leftUpChangeImage.alpha = 0.0
        self.leftDownChangeImage.alpha = 0.0
        self.middleUpChangeImage.alpha = 0.0
        self.middleDownChangeImage.alpha = 0.0
        self.rightUpChangeImage.alpha = 0.0
        self.rightDownChangeImage.alpha = 0.0

        self.suspendedBaseView.isHidden = true
        self.seeAllBaseView.isHidden = true
    }

    private func setupBindings() {
        guard let viewModel = viewModel else { return }

        // Clear previous cancellables
        self.cancellables.removeAll()

        // Bind display mode
        viewModel.displayModePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayMode in
                guard let self = self else { return }

                switch displayMode {
                case .normal:
                    self.oddsStackView.isHidden = false
                    self.suspendedBaseView.isHidden = true
                    self.seeAllBaseView.isHidden = true
                case .suspended:
                    self.oddsStackView.isHidden = true
                    self.suspendedBaseView.isHidden = false
                    self.seeAllBaseView.isHidden = true
                case .seeAll:
                    self.oddsStackView.isHidden = true
                    self.suspendedBaseView.isHidden = true
                    self.seeAllBaseView.isHidden = false
                }
            }
            .store(in: &self.cancellables)

        // Bind show middle outcome
        viewModel.showMiddleOutcomePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showMiddle in
                self?.middleBaseView.isHidden = !showMiddle
            }
            .store(in: &self.cancellables)

        // Bind left outcome
        viewModel.leftOutcomePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] outcome in
                guard let self = self else { return }

                self.leftTitleLabel.text = outcome.title
                self.leftValueLabel.text = outcome.value

                // Update selection state
                if outcome.isSelected {
                    self.leftBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
                    self.leftTitleLabel.textColor = UIColor.App.buttonTextPrimary
                    self.leftValueLabel.textColor = UIColor.App.buttonTextPrimary
                } else {
                    self.leftBaseView.backgroundColor = UIColor.App.backgroundOdds
                    self.leftTitleLabel.textColor = UIColor.App.textPrimary
                    self.leftValueLabel.textColor = UIColor.App.textPrimary
                }

                // Update change indicators
                self.leftUpChangeImage.alpha = outcome.oddsChangeDirection == .up ? 1.0 : 0.0
                self.leftDownChangeImage.alpha = outcome.oddsChangeDirection == .down ? 1.0 : 0.0

                // Update enabled state
                self.leftBaseView.isUserInteractionEnabled = !outcome.isDisabled
                self.leftBaseView.alpha = outcome.isDisabled ? 0.5 : 1.0
            }
            .store(in: &self.cancellables)

        // Bind middle outcome
        viewModel.middleOutcomePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] outcome in
                guard let self = self else { return }

                self.middleTitleLabel.text = outcome.title
                self.middleValueLabel.text = outcome.value

                // Update selection state
                if outcome.isSelected {
                    self.middleBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
                    self.middleTitleLabel.textColor = UIColor.App.buttonTextPrimary
                    self.middleValueLabel.textColor = UIColor.App.buttonTextPrimary
                } else {
                    self.middleBaseView.backgroundColor = UIColor.App.backgroundOdds
                    self.middleTitleLabel.textColor = UIColor.App.textPrimary
                    self.middleValueLabel.textColor = UIColor.App.textPrimary
                }

                // Update change indicators
                self.middleUpChangeImage.alpha = outcome.oddsChangeDirection == .up ? 1.0 : 0.0
                self.middleDownChangeImage.alpha = outcome.oddsChangeDirection == .down ? 1.0 : 0.0

                // Update enabled state
                self.middleBaseView.isUserInteractionEnabled = !outcome.isDisabled
                self.middleBaseView.alpha = outcome.isDisabled ? 0.5 : 1.0
            }
            .store(in: &self.cancellables)

        // Bind right outcome
        viewModel.rightOutcomePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] outcome in
                guard let self = self else { return }

                self.rightTitleLabel.text = outcome.title
                self.rightValueLabel.text = outcome.value

                // Update selection state
                if outcome.isSelected {
                    self.rightBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
                    self.rightTitleLabel.textColor = UIColor.App.buttonTextPrimary
                    self.rightValueLabel.textColor = UIColor.App.buttonTextPrimary
                } else {
                    self.rightBaseView.backgroundColor = UIColor.App.backgroundOdds
                    self.rightTitleLabel.textColor = UIColor.App.textPrimary
                    self.rightValueLabel.textColor = UIColor.App.textPrimary
                }

                // Update change indicators
                self.rightUpChangeImage.alpha = outcome.oddsChangeDirection == .up ? 1.0 : 0.0
                self.rightDownChangeImage.alpha = outcome.oddsChangeDirection == .down ? 1.0 : 0.0

                // Update enabled state
                self.rightBaseView.isUserInteractionEnabled = !outcome.isDisabled
                self.rightBaseView.alpha = outcome.isDisabled ? 0.5 : 1.0
            }
            .store(in: &self.cancellables)

        // Bind suspended text
        viewModel.suspendedTextPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.suspendedLabel.text = text
            }
            .store(in: &self.cancellables)

        // Bind see all text
        viewModel.seeAllTextPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.seeAllLabel.text = text
            }
            .store(in: &self.cancellables)
    }

    // MARK: Gesture Recognizers
    private func setupGestureRecognizers() {
        // Tap gestures
        let tapLeftOutcome = UITapGestureRecognizer(target: self, action: #selector(didTapLeftOutcome))
        self.leftBaseView.addGestureRecognizer(tapLeftOutcome)

        let tapMiddleOutcome = UITapGestureRecognizer(target: self, action: #selector(didTapMiddleOutcome))
        self.middleBaseView.addGestureRecognizer(tapMiddleOutcome)

        let tapRightOutcome = UITapGestureRecognizer(target: self, action: #selector(didTapRightOutcome))
        self.rightBaseView.addGestureRecognizer(tapRightOutcome)

        let tapSeeAll = UITapGestureRecognizer(target: self, action: #selector(didTapSeeAll))
        self.seeAllBaseView.addGestureRecognizer(tapSeeAll)

        // Long press gestures
        let longPressLeftOutcome = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressLeftOutcome(_:)))
        self.leftBaseView.addGestureRecognizer(longPressLeftOutcome)

        let longPressMiddleOutcome = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressMiddleOutcome(_:)))
        self.middleBaseView.addGestureRecognizer(longPressMiddleOutcome)

        let longPressRightOutcome = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressRightOutcome(_:)))
        self.rightBaseView.addGestureRecognizer(longPressRightOutcome)
    }

    // MARK: Actions
    @objc private func didTapLeftOutcome() {
        guard let viewModel = viewModel else { return }

        let currentOutcome = viewModel.leftOutcomePublisher.value

        if currentOutcome.isSelected {
            viewModel.updateOutcomeSelection(type: .left, isSelected: false)
            onOutcomeDeselected?(.left)
        } else {
            viewModel.updateOutcomeSelection(type: .left, isSelected: true)
            onOutcomeSelected?(.left)

            // Provide haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    @objc private func didTapMiddleOutcome() {
        guard let viewModel = viewModel else { return }

        let currentOutcome = viewModel.middleOutcomePublisher.value

        if currentOutcome.isSelected {
            viewModel.updateOutcomeSelection(type: .middle, isSelected: false)
            onOutcomeDeselected?(.middle)
        } else {
            viewModel.updateOutcomeSelection(type: .middle, isSelected: true)
            onOutcomeSelected?(.middle)

            // Provide haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    @objc private func didTapRightOutcome() {
        guard let viewModel = viewModel else { return }

        let currentOutcome = viewModel.rightOutcomePublisher.value

        if currentOutcome.isSelected {
            viewModel.updateOutcomeSelection(type: .right, isSelected: false)
            onOutcomeDeselected?(.right)
        } else {
            viewModel.updateOutcomeSelection(type: .right, isSelected: true)
            onOutcomeSelected?(.right)

            // Provide haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    @objc private func didTapSeeAll() {
        onSeeAllTapped?()
    }

    @objc private func didLongPressLeftOutcome(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            onOutcomeLongPress?(.left)
        }
    }

    @objc private func didLongPressMiddleOutcome(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            onOutcomeLongPress?(.middle)
        }
    }

    @objc private func didLongPressRightOutcome(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            onOutcomeLongPress?(.right)
        }
    }
}

// MARK: - Factory Methods
extension MarketOutcomesLineView {
    private static func createOddsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        stackView.backgroundColor = .clear
        return stackView
    }

    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4.5
        view.clipsToBounds = true
        view.backgroundColor = UIColor.App.backgroundOdds
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .medium, size: 10)
        label.textAlignment = .center
        label.textColor = UIColor.App.textPrimary
        return label
    }

    private static func createValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 13)
        label.textAlignment = .center
        label.textColor = UIColor.App.textPrimary
        return label
    }

    private static func createUpChangeImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "odd_up_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.0
        return imageView
    }

    private static func createDownChangeImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "odd_down_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.0
        return imageView
    }

    private static func createSuspendedBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4.5
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.App.backgroundBorder.cgColor
        view.backgroundColor = UIColor.App.backgroundDisabledOdds
        view.isHidden = true
        return view
    }

    private static func createSuspendedLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 13)
        label.textAlignment = .center
        label.textColor = UIColor.App.textDisablePrimary
        label.text = "Suspended"
        return label
    }

    private static func createSeeAllBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4.5
        view.backgroundColor = UIColor.App.backgroundDisabledOdds
        view.isHidden = true
        return view
    }

    private static func createSeeAllLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 13)
        label.textAlignment = .center
        label.textColor = UIColor.App.textPrimary
        label.text = "See All"
        return label
    }
}

// MARK: - Layout Setup
extension MarketOutcomesLineView {
    private func setupSubviews() {
        // Add odds stack view to self
        self.addSubview(self.oddsStackView)

        // Add base views to stack view
        self.oddsStackView.addArrangedSubview(self.leftBaseView)
        self.oddsStackView.addArrangedSubview(self.middleBaseView)
        self.oddsStackView.addArrangedSubview(self.rightBaseView)

        // Set up left outcome
        self.leftBaseView.addSubview(self.leftTitleLabel)
        self.leftBaseView.addSubview(self.leftValueLabel)

        // Set up left outcome change indicators
        let leftChangeView = UIView()
        leftChangeView.translatesAutoresizingMaskIntoConstraints = false
        leftChangeView.backgroundColor = .clear
        leftChangeView.addSubview(self.leftUpChangeImage)
        leftChangeView.addSubview(self.leftDownChangeImage)
        self.leftBaseView.addSubview(leftChangeView)

        // Set up middle outcome
        self.middleBaseView.addSubview(self.middleTitleLabel)
        self.middleBaseView.addSubview(self.middleValueLabel)

        // Set up middle outcome change indicators
        let middleChangeView = UIView()
        middleChangeView.translatesAutoresizingMaskIntoConstraints = false
        middleChangeView.backgroundColor = .clear
        middleChangeView.addSubview(self.middleUpChangeImage)
        middleChangeView.addSubview(self.middleDownChangeImage)
        self.middleBaseView.addSubview(middleChangeView)

        // Set up right outcome
        self.rightBaseView.addSubview(self.rightTitleLabel)
        self.rightBaseView.addSubview(self.rightValueLabel)

        // Set up right outcome change indicators
        let rightChangeView = UIView()
        rightChangeView.translatesAutoresizingMaskIntoConstraints = false
        rightChangeView.backgroundColor = .clear
        rightChangeView.addSubview(self.rightUpChangeImage)
        rightChangeView.addSubview(self.rightDownChangeImage)
        self.rightBaseView.addSubview(rightChangeView)

        // Set up suspended view
        self.addSubview(self.suspendedBaseView)
        self.suspendedBaseView.addSubview(self.suspendedLabel)

        // Set up see all view
        self.addSubview(self.seeAllBaseView)
        self.seeAllBaseView.addSubview(self.seeAllLabel)

        // Initialize constraints
        self.setupConstraints()
    }

    private func setupConstraints() {
        // Odds stack view constraints
        NSLayoutConstraint.activate([
            self.oddsStackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.oddsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.oddsStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.oddsStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        // Left outcome constraints
        NSLayoutConstraint.activate([
            self.leftTitleLabel.topAnchor.constraint(equalTo: self.leftBaseView.topAnchor, constant: 6),
            self.leftTitleLabel.centerXAnchor.constraint(equalTo: self.leftBaseView.centerXAnchor),
            self.leftTitleLabel.leadingAnchor.constraint(equalTo: self.leftBaseView.leadingAnchor, constant: 2),
            self.leftTitleLabel.trailingAnchor.constraint(equalTo: self.leftBaseView.trailingAnchor, constant: -2),
            self.leftTitleLabel.heightAnchor.constraint(equalToConstant: 14),

            self.leftValueLabel.topAnchor.constraint(equalTo: self.leftBaseView.centerYAnchor),
            self.leftValueLabel.topAnchor.constraint(equalTo: self.leftTitleLabel.bottomAnchor),
            self.leftValueLabel.centerXAnchor.constraint(equalTo: self.leftBaseView.centerXAnchor),
            self.leftValueLabel.leadingAnchor.constraint(equalTo: self.leftBaseView.leadingAnchor, constant: 2),
            self.leftValueLabel.trailingAnchor.constraint(equalTo: self.leftBaseView.trailingAnchor, constant: -2)
        ])

        // Left change indicators constraints
        let leftChangeView = self.leftUpChangeImage.superview!
        NSLayoutConstraint.activate([
            leftChangeView.trailingAnchor.constraint(equalTo: self.leftValueLabel.trailingAnchor),
            leftChangeView.centerYAnchor.constraint(equalTo: self.leftValueLabel.centerYAnchor),
            leftChangeView.widthAnchor.constraint(equalToConstant: 12),
            leftChangeView.heightAnchor.constraint(equalToConstant: 12),

            self.leftUpChangeImage.topAnchor.constraint(equalTo: leftChangeView.topAnchor),
            self.leftUpChangeImage.leadingAnchor.constraint(equalTo: leftChangeView.leadingAnchor),
            self.leftUpChangeImage.trailingAnchor.constraint(equalTo: leftChangeView.trailingAnchor),
            self.leftUpChangeImage.bottomAnchor.constraint(equalTo: leftChangeView.bottomAnchor),

            self.leftDownChangeImage.topAnchor.constraint(equalTo: leftChangeView.topAnchor),
            self.leftDownChangeImage.leadingAnchor.constraint(equalTo: leftChangeView.leadingAnchor),
            self.leftDownChangeImage.trailingAnchor.constraint(equalTo: leftChangeView.trailingAnchor),
            self.leftDownChangeImage.bottomAnchor.constraint(equalTo: leftChangeView.bottomAnchor)
        ])

        // Middle outcome constraints
        NSLayoutConstraint.activate([
            self.middleTitleLabel.topAnchor.constraint(equalTo: self.middleBaseView.topAnchor, constant: 6),
            self.middleTitleLabel.centerXAnchor.constraint(equalTo: self.middleBaseView.centerXAnchor),
            self.middleTitleLabel.leadingAnchor.constraint(equalTo: self.middleBaseView.leadingAnchor, constant: 2),
            self.middleTitleLabel.trailingAnchor.constraint(equalTo: self.middleBaseView.trailingAnchor, constant: -2),
            self.middleTitleLabel.heightAnchor.constraint(equalToConstant: 14),

            self.middleValueLabel.topAnchor.constraint(equalTo: self.middleBaseView.centerYAnchor),
            self.middleValueLabel.topAnchor.constraint(equalTo: self.middleTitleLabel.bottomAnchor),
            self.middleValueLabel.centerXAnchor.constraint(equalTo: self.middleBaseView.centerXAnchor),
            self.middleValueLabel.leadingAnchor.constraint(equalTo: self.middleBaseView.leadingAnchor, constant: 2),
            self.middleValueLabel.trailingAnchor.constraint(equalTo: self.middleBaseView.trailingAnchor, constant: -2)
        ])

        // Middle change indicators constraints
        let middleChangeView = self.middleUpChangeImage.superview!
        NSLayoutConstraint.activate([
            middleChangeView.trailingAnchor.constraint(equalTo: self.middleValueLabel.trailingAnchor),
            middleChangeView.centerYAnchor.constraint(equalTo: self.middleValueLabel.centerYAnchor),
            middleChangeView.widthAnchor.constraint(equalToConstant: 12),
            middleChangeView.heightAnchor.constraint(equalToConstant: 12),

            self.middleUpChangeImage.topAnchor.constraint(equalTo: middleChangeView.topAnchor),
            self.middleUpChangeImage.leadingAnchor.constraint(equalTo: middleChangeView.leadingAnchor),
            self.middleUpChangeImage.trailingAnchor.constraint(equalTo: middleChangeView.trailingAnchor),
            self.middleUpChangeImage.bottomAnchor.constraint(equalTo: middleChangeView.bottomAnchor),

            self.middleDownChangeImage.topAnchor.constraint(equalTo: middleChangeView.topAnchor),
            self.middleDownChangeImage.leadingAnchor.constraint(equalTo: middleChangeView.leadingAnchor),
            self.middleDownChangeImage.trailingAnchor.constraint(equalTo: middleChangeView.trailingAnchor),
            self.middleDownChangeImage.bottomAnchor.constraint(equalTo: middleChangeView.bottomAnchor)
        ])

        // Right outcome constraints
        NSLayoutConstraint.activate([
            self.rightTitleLabel.topAnchor.constraint(equalTo: self.rightBaseView.topAnchor, constant: 6),
            self.rightTitleLabel.centerXAnchor.constraint(equalTo: self.rightBaseView.centerXAnchor),
            self.rightTitleLabel.leadingAnchor.constraint(equalTo: self.rightBaseView.leadingAnchor, constant: 2),
            self.rightTitleLabel.trailingAnchor.constraint(equalTo: self.rightBaseView.trailingAnchor, constant: -2),
            self.rightTitleLabel.heightAnchor.constraint(equalToConstant: 14),

            self.rightValueLabel.topAnchor.constraint(equalTo: self.rightBaseView.centerYAnchor),
            self.rightValueLabel.topAnchor.constraint(equalTo: self.rightTitleLabel.bottomAnchor),
            self.rightValueLabel.centerXAnchor.constraint(equalTo: self.rightBaseView.centerXAnchor),
            self.rightValueLabel.leadingAnchor.constraint(equalTo: self.rightBaseView.leadingAnchor, constant: 2),
            self.rightValueLabel.trailingAnchor.constraint(equalTo: self.rightBaseView.trailingAnchor, constant: -2)
        ])

        // Right change indicators constraints
        let rightChangeView = self.rightUpChangeImage.superview!
        NSLayoutConstraint.activate([
            rightChangeView.trailingAnchor.constraint(equalTo: self.rightValueLabel.trailingAnchor),
            rightChangeView.centerYAnchor.constraint(equalTo: self.rightValueLabel.centerYAnchor),
            rightChangeView.widthAnchor.constraint(equalToConstant: 12),
            rightChangeView.heightAnchor.constraint(equalToConstant: 12),

            self.rightUpChangeImage.topAnchor.constraint(equalTo: rightChangeView.topAnchor),
            self.rightUpChangeImage.leadingAnchor.constraint(equalTo: rightChangeView.leadingAnchor),
            self.rightUpChangeImage.trailingAnchor.constraint(equalTo: rightChangeView.trailingAnchor),
            self.rightUpChangeImage.bottomAnchor.constraint(equalTo: rightChangeView.bottomAnchor),

            self.rightDownChangeImage.topAnchor.constraint(equalTo: rightChangeView.topAnchor),
            self.rightDownChangeImage.leadingAnchor.constraint(equalTo: rightChangeView.leadingAnchor),
            self.rightDownChangeImage.trailingAnchor.constraint(equalTo: rightChangeView.trailingAnchor),
            self.rightDownChangeImage.bottomAnchor.constraint(equalTo: rightChangeView.bottomAnchor)
        ])

        // Suspended view constraints
        NSLayoutConstraint.activate([
            self.suspendedBaseView.topAnchor.constraint(equalTo: self.topAnchor),
            self.suspendedBaseView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.suspendedBaseView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.suspendedBaseView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.suspendedLabel.centerXAnchor.constraint(equalTo: self.suspendedBaseView.centerXAnchor),
            self.suspendedLabel.centerYAnchor.constraint(equalTo: self.suspendedBaseView.centerYAnchor)
        ])

        // See all view constraints
        NSLayoutConstraint.activate([
            self.seeAllBaseView.topAnchor.constraint(equalTo: self.topAnchor),
            self.seeAllBaseView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.seeAllBaseView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.seeAllBaseView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.seeAllLabel.centerXAnchor.constraint(equalTo: self.seeAllBaseView.centerXAnchor),
            self.seeAllLabel.centerYAnchor.constraint(equalTo: self.seeAllBaseView.centerYAnchor)
        ])
    }
}

@available(iOS 17.0, *)
#Preview("MarketOutcomesLineView - All States") {
    ScrollView {
        VStack(spacing: 20) {
            // Title for Normal state
            Text("Normal State")
                .font(.system(size: 14, weight: .bold))

            // Normal state with three outcomes
            PreviewUIView {
                let view = MarketOutcomesLineView()
                let viewModel = LegacyMarketOutcomesLineViewModel(
                    displayMode: .normal,
                    leftOutcome: LegacyMarketOutcomesLineViewModel.OutcomeInfo(
                        title: "Home",
                        value: "1.85",
                        oddsChangeDirection: .none,
                        isSelected: false,
                        isDisabled: false
                    ),
                    middleOutcome: LegacyMarketOutcomesLineViewModel.OutcomeInfo(
                        title: "Draw",
                        value: "3.55",
                        oddsChangeDirection: .none,
                        isSelected: false,
                        isDisabled: false
                    ),
                    rightOutcome: LegacyMarketOutcomesLineViewModel.OutcomeInfo(
                        title: "Away",
                        value: "4.20",
                        oddsChangeDirection: .none,
                        isSelected: false,
                        isDisabled: false
                    )
                )
                view.configure(with: viewModel)
                view.backgroundColor = UIColor.systemGray6
                return view
            }
            .frame(width: 300, height: 40)

            // Title for Selected state
            Text("Selected Outcome")
                .font(.system(size: 14, weight: .bold))

            // Selected state
            PreviewUIView {
                let view = MarketOutcomesLineView()
                let viewModel = LegacyMarketOutcomesLineViewModel(
                    displayMode: .normal,
                    leftOutcome: LegacyMarketOutcomesLineViewModel.OutcomeInfo(
                        title: "Home",
                        value: "1.85",
                        oddsChangeDirection: .none,
                        isSelected: true,
                        isDisabled: false
                    ),
                    middleOutcome: LegacyMarketOutcomesLineViewModel.OutcomeInfo(
                        title: "Draw",
                        value: "3.55",
                        oddsChangeDirection: .none,
                        isSelected: false,
                        isDisabled: false
                    ),
                    rightOutcome: LegacyMarketOutcomesLineViewModel.OutcomeInfo(
                        title: "Away",
                        value: "4.20",
                        oddsChangeDirection: .none,
                        isSelected: false,
                        isDisabled: false
                    )
                )
                view.configure(with: viewModel)
                view.backgroundColor = UIColor.systemGray6
                return view
            }
            .frame(width: 300, height: 40)

            // Title for Disabled state
            Text("Disabled Outcome")
                .font(.system(size: 14, weight: .bold))

            // Disabled state
            PreviewUIView {
                let view = MarketOutcomesLineView()
                let viewModel = LegacyMarketOutcomesLineViewModel(
                    displayMode: .normal,
                    leftOutcome: LegacyMarketOutcomesLineViewModel.OutcomeInfo(
                        title: "Home",
                        value: "1.85",
                        oddsChangeDirection: .none,
                        isSelected: false,
                        isDisabled: true
                    ),
                    middleOutcome: LegacyMarketOutcomesLineViewModel.OutcomeInfo(
                        title: "Draw",
                        value: "3.55",
                        oddsChangeDirection: .none,
                        isSelected: false,
                        isDisabled: false
                    ),
                    rightOutcome: LegacyMarketOutcomesLineViewModel.OutcomeInfo(
                        title: "Away",
                        value: "4.20",
                        oddsChangeDirection: .none,
                        isSelected: false,
                        isDisabled: false
                    )
                )
                view.configure(with: viewModel)
                view.backgroundColor = UIColor.systemGray6
                return view
            }
            .frame(width: 300, height: 40)

            // Title for Odds Change state
            Text("Odds Change Indicators")
                .font(.system(size: 14, weight: .bold))

            // Odds change state
            PreviewUIView {
                let view = MarketOutcomesLineView()
                let viewModel = LegacyMarketOutcomesLineViewModel(
                    displayMode: .normal,
                    leftOutcome: LegacyMarketOutcomesLineViewModel.OutcomeInfo(
                        title: "Home",
                        value: "1.85",
                        oddsChangeDirection: .up,
                        isSelected: false,
                        isDisabled: false
                    ),
                    middleOutcome: LegacyMarketOutcomesLineViewModel.OutcomeInfo(
                        title: "Draw",
                        value: "3.55",
                        oddsChangeDirection: .none,
                        isSelected: false,
                        isDisabled: false
                    ),
                    rightOutcome: LegacyMarketOutcomesLineViewModel.OutcomeInfo(
                        title: "Away",
                        value: "4.20",
                        oddsChangeDirection: .down,
                        isSelected: false,
                        isDisabled: false
                    )
                )
                view.configure(with: viewModel)
                view.backgroundColor = UIColor.systemGray6
                return view
            }
            .frame(width: 300, height: 40)

            // Title for Two-Way Market
            Text("Two-Way Market (No Draw)")
                .font(.system(size: 14, weight: .bold))

            // Two-way market
            PreviewUIView {
                let view = MarketOutcomesLineView()
                let viewModel = LegacyMarketOutcomesLineViewModel(
                    displayMode: .normal,
                    leftOutcome: LegacyMarketOutcomesLineViewModel.OutcomeInfo(
                        title: "Under",
                        value: "1.95",
                        oddsChangeDirection: .none,
                        isSelected: false,
                        isDisabled: false
                    ),
                    rightOutcome: LegacyMarketOutcomesLineViewModel.OutcomeInfo(
                        title: "Over",
                        value: "1.85",
                        oddsChangeDirection: .none,
                        isSelected: false,
                        isDisabled: false
                    ),
                    showMiddleOutcome: false
                )
                view.configure(with: viewModel)
                view.backgroundColor = UIColor.systemGray6
                return view
            }
            .frame(width: 300, height: 40)

            // Title for Suspended state
            Text("Suspended State")
                .font(.system(size: 14, weight: .bold))

            // Suspended state
            PreviewUIView {
                let view = MarketOutcomesLineView()
                let viewModel = LegacyMarketOutcomesLineViewModel(
                    displayMode: .suspended,
                    suspendedText: "Suspended"
                )
                view.configure(with: viewModel)
                view.backgroundColor = UIColor.systemGray6
                return view
            }
            .frame(width: 300, height: 40)

            // Title for See All state
            Text("See All Markets State")
                .font(.system(size: 14, weight: .bold))

            // See all state
            PreviewUIView {
                let view = MarketOutcomesLineView()
                let viewModel = LegacyMarketOutcomesLineViewModel(
                    displayMode: .seeAll,
                    seeAllText: "See All Markets"
                )
                view.configure(with: viewModel)
                view.backgroundColor = UIColor.systemGray6
                return view
            }
            .frame(width: 300, height: 40)
        }
        .padding()
    }
}
