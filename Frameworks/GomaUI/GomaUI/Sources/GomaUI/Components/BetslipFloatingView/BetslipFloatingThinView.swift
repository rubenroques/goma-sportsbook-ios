import Foundation
import UIKit
import Combine
import SwiftUI

/// A thin floating view that displays betslip status with two states: no tickets (circular button) and with tickets (compact horizontal detailed view)
public final class BetslipFloatingThinView: UIView {
    
    // MARK: - UI Components
    
    // No tickets state - circular button
    private lazy var circularButton: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.highlightPrimary
        view.layer.cornerRadius = 28
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.2
        return view
    }()
    
    private lazy var betslipIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "betslip_icon") ?? UIImage(systemName: "ticket")
        imageView.tintColor = StyleProvider.Color.highlightSecondaryContrast
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var betslipLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Betslip" // TODO: localization
        label.font = StyleProvider.fontWith(type: .bold, size: 10)
        label.textColor = StyleProvider.Color.highlightSecondaryContrast
        label.textAlignment = .center
        return label
    }()
    
    // With tickets state - detailed view
    private lazy var detailedContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundGradient2
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.2
        return view
    }()
    
    // Top bar components
    private lazy var topBarStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var selectionCountView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        view.layer.borderWidth = 1
        view.layer.borderColor = StyleProvider.Color.highlightPrimary.cgColor
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var selectionCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 12)
        label.textColor = StyleProvider.Color.highlightPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var oddsCapsuleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.highlightPrimary
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var oddsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 10)
        label.textColor = StyleProvider.Color.buttonTextPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var oddsValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 14)
        label.textColor = StyleProvider.Color.buttonTextPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var winBoostCapsuleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.highlightSecondary
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()
    
    private lazy var winBoostLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 10)
        label.textColor = StyleProvider.Color.buttonTextPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var winBoostValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 14)
        label.textColor = StyleProvider.Color.buttonTextPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var openBetslipButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Open Betslip", for: .normal) // TODO: localization
        button.setTitleColor(StyleProvider.Color.textPrimary, for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 12)
        
        if let customImage = UIImage(named: "caret_up_icon")?.withRenderingMode(.alwaysTemplate) {
            button.setImage(customImage, for: .normal)
        }
        else if let systemImage = UIImage(systemName: "chevron.up") {
            button.setImage(systemImage, for: .normal)
        }
        
        button.tintColor = StyleProvider.Color.highlightPrimary
        button.semanticContentAttribute = .forceRightToLeft
        return button
    }()
    
    // Bottom section components
    private lazy var bottomSectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        view.layer.cornerRadius = 8
        view.isHidden = true
        return view
    }()
    
    private lazy var callToActionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 0
        return label
    }()
    
    // Progress segments
    private lazy var progressSegmentsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()

    private var progressSegments: [ProgressSegmentView] = []
    
    // MARK: - Properties
    private let viewModel: BetslipFloatingViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constraint Properties (for external access)
    private var circularButtonLeadingConstraint: NSLayoutConstraint?
    private var detailedContainerLeadingConstraint: NSLayoutConstraint?
    private var circularButtonTopConstraint: NSLayoutConstraint?
    private var circularButtonBottomConstraint: NSLayoutConstraint?
    private var topBarStackViewBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    public init(viewModel: BetslipFloatingViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // Create and apply width constraints when added to superview
        if let superview = superview {
            // Create leading constraints
            circularButtonLeadingConstraint = leadingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -72) // 56 + 16 padding
            detailedContainerLeadingConstraint = leadingAnchor.constraint(equalTo: superview.leadingAnchor)
            
            // Create height constraints for circular button
            circularButtonTopConstraint = circularButton.topAnchor.constraint(equalTo: topAnchor)
            circularButtonBottomConstraint = circularButton.bottomAnchor.constraint(equalTo: bottomAnchor)
            
            // Create the topBarStackView bottom constraint
            topBarStackViewBottomConstraint = topBarStackView.bottomAnchor.constraint(equalTo: detailedContainerView.bottomAnchor, constant: -12)
            
            // Apply constraints based on current state
            updateWidthConstraints(for: viewModel.currentData.state)
        }
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        // Add circular button components
        addSubview(circularButton)
        circularButton.addSubview(betslipIconImageView)
        circularButton.addSubview(betslipLabel)
        
        // Add detailed view components
        addSubview(detailedContainerView)
        
        // Setup top bar
        detailedContainerView.addSubview(topBarStackView)
        topBarStackView.addArrangedSubview(selectionCountView)
        topBarStackView.addArrangedSubview(oddsCapsuleView)
        topBarStackView.addArrangedSubview(winBoostCapsuleView)
        topBarStackView.addArrangedSubview(UIView()) // Spacer
        topBarStackView.addArrangedSubview(openBetslipButton)
        
        selectionCountView.addSubview(selectionCountLabel)
        oddsCapsuleView.addSubview(oddsLabel)
        oddsCapsuleView.addSubview(oddsValueLabel)
        winBoostCapsuleView.addSubview(winBoostLabel)
        winBoostCapsuleView.addSubview(winBoostValueLabel)

        // Setup bottom section
        detailedContainerView.addSubview(bottomSectionView)
        bottomSectionView.addSubview(callToActionLabel)
        bottomSectionView.addSubview(progressSegmentsStackView)
        
        setupConstraints()
        setupGestures()
    }
    
    private func setupConstraints() {
        // Circular button constraints
        NSLayoutConstraint.activate([
            circularButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            circularButton.widthAnchor.constraint(equalToConstant: 56),
            circularButton.heightAnchor.constraint(equalToConstant: 56),
            
            betslipIconImageView.centerXAnchor.constraint(equalTo: circularButton.centerXAnchor),
            betslipIconImageView.centerYAnchor.constraint(equalTo: circularButton.centerYAnchor, constant: -8),
            betslipIconImageView.widthAnchor.constraint(equalToConstant: 20),
            betslipIconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            betslipLabel.centerXAnchor.constraint(equalTo: circularButton.centerXAnchor),
            betslipLabel.topAnchor.constraint(equalTo: betslipIconImageView.bottomAnchor, constant: 2),
            betslipLabel.leadingAnchor.constraint(greaterThanOrEqualTo: circularButton.leadingAnchor, constant: 4),
            betslipLabel.trailingAnchor.constraint(lessThanOrEqualTo: circularButton.trailingAnchor, constant: -4)
        ])
        
        // Detailed view constraints
        NSLayoutConstraint.activate([
            detailedContainerView.topAnchor.constraint(equalTo: topAnchor),
            detailedContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            detailedContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            detailedContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Top bar
            topBarStackView.topAnchor.constraint(equalTo: detailedContainerView.topAnchor, constant: 12),
            topBarStackView.leadingAnchor.constraint(equalTo: detailedContainerView.leadingAnchor, constant: 12),
            topBarStackView.trailingAnchor.constraint(equalTo: detailedContainerView.trailingAnchor, constant: -12),
            
            // Create but don't activate the bottom constraint initially
            // It will be managed conditionally based on bottomSectionView visibility
            
            // Selection count view
            selectionCountView.widthAnchor.constraint(equalToConstant: 24),
            selectionCountView.heightAnchor.constraint(equalToConstant: 24),
            
            selectionCountLabel.centerXAnchor.constraint(equalTo: selectionCountView.centerXAnchor),
            selectionCountLabel.centerYAnchor.constraint(equalTo: selectionCountView.centerYAnchor),
            
            // Odds capsule
            oddsCapsuleView.heightAnchor.constraint(equalToConstant: 24),
            
            oddsLabel.leadingAnchor.constraint(equalTo: oddsCapsuleView.leadingAnchor, constant: 8),
            oddsLabel.centerYAnchor.constraint(equalTo: oddsCapsuleView.centerYAnchor),
            
            oddsValueLabel.leadingAnchor.constraint(equalTo: oddsLabel.trailingAnchor, constant: 1),
            oddsValueLabel.trailingAnchor.constraint(equalTo: oddsCapsuleView.trailingAnchor, constant: -8),
            oddsValueLabel.centerYAnchor.constraint(equalTo: oddsCapsuleView.centerYAnchor),
            
            // Win boost capsule
            winBoostCapsuleView.heightAnchor.constraint(equalToConstant: 24),
            
            winBoostLabel.leadingAnchor.constraint(equalTo: winBoostCapsuleView.leadingAnchor, constant: 8),
//            winBoostLabel.trailingAnchor.constraint(equalTo: winBoostCapsuleView.trailingAnchor, constant: -8),
            winBoostLabel.centerYAnchor.constraint(equalTo: winBoostCapsuleView.centerYAnchor),
            
            winBoostValueLabel.leadingAnchor.constraint(equalTo: winBoostLabel.trailingAnchor, constant: 1),
            winBoostValueLabel.trailingAnchor.constraint(equalTo: winBoostCapsuleView.trailingAnchor, constant: -8),
            winBoostValueLabel.centerYAnchor.constraint(equalTo: winBoostCapsuleView.centerYAnchor),
            
            // Bottom section
            bottomSectionView.topAnchor.constraint(equalTo: topBarStackView.bottomAnchor, constant: 8),
            bottomSectionView.leadingAnchor.constraint(equalTo: detailedContainerView.leadingAnchor, constant: 12),
            bottomSectionView.trailingAnchor.constraint(equalTo: detailedContainerView.trailingAnchor, constant: -12),
            bottomSectionView.bottomAnchor.constraint(equalTo: detailedContainerView.bottomAnchor, constant: -12),
            
            callToActionLabel.topAnchor.constraint(equalTo: bottomSectionView.topAnchor, constant: 8),
            callToActionLabel.leadingAnchor.constraint(equalTo: bottomSectionView.leadingAnchor, constant: 8),
            callToActionLabel.trailingAnchor.constraint(equalTo: bottomSectionView.trailingAnchor, constant: -8),
            
            progressSegmentsStackView.topAnchor.constraint(equalTo: callToActionLabel.bottomAnchor, constant: 8),
            progressSegmentsStackView.leadingAnchor.constraint(equalTo: bottomSectionView.leadingAnchor, constant: 8),
            progressSegmentsStackView.trailingAnchor.constraint(equalTo: bottomSectionView.trailingAnchor, constant: -8),
            progressSegmentsStackView.bottomAnchor.constraint(equalTo: bottomSectionView.bottomAnchor, constant: -8),
            progressSegmentsStackView.heightAnchor.constraint(equalToConstant: 8)
        ])
    }

    /// Updates progress segments with diff-based approach and animations
    /// - Parameters:
    ///   - filledCount: Number of segments that should be filled
    ///   - totalCount: Total number of segments to display
    ///   - animated: Whether to animate changes (default: true)
    private func updateProgressSegments(filledCount: Int, totalCount: Int, animated: Bool = true) {
        let currentCount = progressSegments.count

        // 1. Add new segments if needed
        if totalCount > currentCount {
            let newSegments = (currentCount..<totalCount).map { _ -> ProgressSegmentView in
                let segment = ProgressSegmentView()
                NSLayoutConstraint.activate([
                    segment.heightAnchor.constraint(equalToConstant: 8)
                ])
                return segment
            }

            // Prepare for animation
            if animated {
                newSegments.forEach {
                    $0.alpha = 0
                    $0.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                }
            }

            // Add to stack view and array
            newSegments.forEach { progressSegmentsStackView.addArrangedSubview($0) }
            progressSegments.append(contentsOf: newSegments)

            // Animate in
            if animated {
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0.1,
                    options: [.curveEaseOut],
                    animations: {
                        newSegments.forEach {
                            $0.alpha = 1.0
                            $0.transform = .identity
                        }
                    }
                )
            }
        }
        // 2. Remove excess segments if needed
        else if totalCount < currentCount {
            let segmentsToRemove = progressSegments[totalCount...]

            if animated {
                UIView.animate(
                    withDuration: 0.2,
                    animations: {
                        segmentsToRemove.forEach {
                            $0.alpha = 0
                            $0.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                        }
                    },
                    completion: { _ in
                        segmentsToRemove.forEach { $0.removeFromSuperview() }
                        self.progressSegments.removeLast(currentCount - totalCount)
                    }
                )
            } else {
                segmentsToRemove.forEach { $0.removeFromSuperview() }
                progressSegments.removeLast(currentCount - totalCount)
            }
        }

        // 3. Update fill state of existing segments with staggered animation (wave effect)
        for (index, segment) in progressSegments.enumerated() {
            let shouldBeFilled = index < filledCount
            let delay = animated ? Double(index) * 0.05 : 0 // 50ms stagger between segments

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                segment.setFilled(shouldBeFilled, animated: animated)
            }
        }
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        
        openBetslipButton.addTarget(self, action: #selector(handleOpenBetslipTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.render(data: data)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Rendering
    private func render(data: BetslipFloatingData) {
        // Update width constraints based on state (only if view has superview)
        if superview != nil {
            updateWidthConstraints(for: data.state)
        }
        
        switch data.state {
        case .noTickets:
            circularButton.isHidden = false
            detailedContainerView.isHidden = true
            bottomSectionView.isHidden = true
        case .withTickets(let selectionCount, let odds, let winBoostPercentage, let totalEligibleCount, let nextTierPercentage):
            circularButton.isHidden = true
            detailedContainerView.isHidden = false

            selectionCountLabel.text = "\(selectionCount)"

            oddsLabel.text = "Odds:" // TODO: localization
            oddsValueLabel.text = "\(odds)"

            if let winBoost = winBoostPercentage {
                winBoostLabel.text = "Win Boost:" // TODO: localization
                winBoostValueLabel.text = winBoost
                winBoostCapsuleView.isHidden = false
            } else {
                winBoostCapsuleView.isHidden = true
            }

            updateProgressSegments(filledCount: selectionCount, totalCount: totalEligibleCount, animated: true)

            // Show/hide bottom section based on totalEligibleCount
            if totalEligibleCount > 0 {
                bottomSectionView.isHidden = false

                // Deactivate the topBarStackView bottom constraint when bottom section is visible
                topBarStackViewBottomConstraint?.isActive = false

                let remainingSelections = max(0, totalEligibleCount - selectionCount)
                if remainingSelections > 0 {
                    let boostText = nextTierPercentage ?? "bonus"
                    callToActionLabel.text = "Add \(remainingSelections) more qualifying selection to get a \(boostText) win boost" // TODO: localization
                } else {
                    callToActionLabel.text = "Max win boost activated!" // TODO: localization
                }
            } else {
                bottomSectionView.isHidden = true
                
                // Activate the topBarStackView bottom constraint when bottom section is hidden
                topBarStackViewBottomConstraint?.isActive = true
            }
        }
        
        alpha = data.isEnabled ? 1.0 : 0.5
        isUserInteractionEnabled = data.isEnabled
    }
    
    // MARK: - Public Methods
    public func updateWidthConstraints(for state: BetslipFloatingState) {
        guard let superview = superview else {
            // If no superview yet, store the state and apply when added to superview
            return
        }
        
        switch state {
        case .noTickets:
            detailedContainerLeadingConstraint?.isActive = false
            circularButtonLeadingConstraint?.isActive = true
            circularButtonTopConstraint?.isActive = true
            circularButtonBottomConstraint?.isActive = true
            
        case .withTickets:
            circularButtonLeadingConstraint?.isActive = false
            circularButtonTopConstraint?.isActive = false
            circularButtonBottomConstraint?.isActive = false
            detailedContainerLeadingConstraint?.isActive = true
        }
    }
    
    // MARK: - Actions
    @objc private func handleTap() {
        viewModel.onBetslipTapped?()
    }
    
    @objc private func handleOpenBetslipTapped() {
        viewModel.onBetslipTapped?()
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("No Tickets") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let betslipView = BetslipFloatingThinView(viewModel: MockBetslipFloatingViewModel(state: .noTickets))
        betslipView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(betslipView)

        NSLayoutConstraint.activate([
            betslipView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            betslipView.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            betslipView.heightAnchor.constraint(equalToConstant: 56)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("With Tickets") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let betslipView = BetslipFloatingThinView(viewModel: MockBetslipFloatingViewModel(state: .withTickets(selectionCount: 3, odds: "1.55", winBoostPercentage: "10%", totalEligibleCount: 6, nextTierPercentage: "15%")))
        betslipView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(betslipView)

        NSLayoutConstraint.activate([
            betslipView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            betslipView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            betslipView.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("With Tickets (No Boost)") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let betslipView = BetslipFloatingThinView(viewModel: MockBetslipFloatingViewModel(state: .withTickets(selectionCount: 2, odds: "1.85", winBoostPercentage: nil, totalEligibleCount: 0, nextTierPercentage: nil)))
        betslipView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(betslipView)

        NSLayoutConstraint.activate([
            betslipView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            betslipView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            betslipView.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        return vc
    }
}

// MARK: - Interactive Preview

@available(iOS 17.0, *)
#Preview("Interactive States") {
    PreviewUIViewController {
        BetslipFloatingInteractivePreviewController()
    }
}

/// Interactive preview controller for testing betslip state transitions
@available(iOS 17.0, *)
private final class BetslipFloatingInteractivePreviewController: UIViewController {

    private let mockViewModel = MockBetslipFloatingViewModel(state: .noTickets)
    private lazy var betslipView = BetslipFloatingThinView(viewModel: mockViewModel)

    private lazy var segmentedControl: UISegmentedControl = {
        let items = ["No Tickets", "With Tickets", "Max Boost"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        return control
    }()

    private lazy var enabledToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = true
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: #selector(enabledToggled), for: .valueChanged)
        return toggle
    }()

    private lazy var enabledLabel: UILabel = {
        let label = UILabel()
        label.text = "Enabled"
        label.font = StyleProvider.fontWith(type: .medium, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var tapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Simulate Tap (Check Console)", for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 14)
        button.backgroundColor = StyleProvider.Color.highlightPrimary
        button.setTitleColor(StyleProvider.Color.buttonTextPrimary, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(testTap), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateInfoLabel()

        // Set up tap callback
        mockViewModel.onBetslipTapped = { [weak self] in
            print("🎯 Betslip tapped! Current state: \(self?.mockViewModel.currentData.state ?? .noTickets)")
            self?.showTapFeedback()
        }
    }

    private func setupUI() {
        view.backgroundColor = StyleProvider.Color.backgroundPrimary

        // Add betslip view
        betslipView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(betslipView)

        // Add controls container
        let controlsStack = UIStackView(arrangedSubviews: [enabledLabel, enabledToggle])
        controlsStack.axis = .horizontal
        controlsStack.spacing = 8
        controlsStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(segmentedControl)
        view.addSubview(controlsStack)
        view.addSubview(infoLabel)
        view.addSubview(tapButton)

        NSLayoutConstraint.activate([
            // Segmented control at top
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Controls stack
            controlsStack.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            controlsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Info label
            infoLabel.topAnchor.constraint(equalTo: controlsStack.bottomAnchor, constant: 20),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Test tap button
            tapButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 20),
            tapButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tapButton.widthAnchor.constraint(equalToConstant: 250),
            tapButton.heightAnchor.constraint(equalToConstant: 44),

            // Betslip view at bottom
            betslipView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            betslipView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            betslipView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    @objc private func stateChanged() {
        let newState: BetslipFloatingState

        switch segmentedControl.selectedSegmentIndex {
        case 0:
            newState = .noTickets
        case 1:
            newState = .withTickets(selectionCount: 2, odds: "2.40", winBoostPercentage: nil, totalEligibleCount: 0, nextTierPercentage: nil)
        case 2:
            newState = .withTickets(selectionCount: 4, odds: "5.75", winBoostPercentage: "15%", totalEligibleCount: 6, nextTierPercentage: "20%")
        default:
            newState = .noTickets
        }

        mockViewModel.updateState(newState)
        updateInfoLabel()
    }

    @objc private func enabledToggled() {
        mockViewModel.setEnabled(enabledToggle.isOn)
        updateInfoLabel()
    }

    @objc private func testTap() {
        // Manually trigger the tap callback
        mockViewModel.onBetslipTapped?()
    }

    private func updateInfoLabel() {
        let data = mockViewModel.currentData
        let stateDescription: String

        switch data.state {
        case .noTickets:
            stateDescription = "State: No Tickets\nCircular button visible"
        case .withTickets(let count, let odds, let boost, let eligible,  let nextBoost):
            var desc = "State: With Tickets\nSelections: \(count) | Odds: \(odds)"
            if let boost = boost {
                desc += "\nWin Boost: \(boost) (Progress: \(count)/\(eligible)) - next: \(nextBoost)"
            }
            stateDescription = desc
        }

        let enabledStatus = data.isEnabled ? "Enabled ✓" : "Disabled"
        infoLabel.text = "\(stateDescription)\n\nStatus: \(enabledStatus)"
    }

    private func showTapFeedback() {
        // Visual feedback for tap
        let feedbackLabel = UILabel()
        feedbackLabel.text = "👆 Tapped!"
        feedbackLabel.font = StyleProvider.fontWith(type: .bold, size: 20)
        feedbackLabel.textColor = StyleProvider.Color.highlightPrimary
        feedbackLabel.alpha = 0
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(feedbackLabel)

        NSLayoutConstraint.activate([
            feedbackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feedbackLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        UIView.animate(withDuration: 0.3, animations: {
            feedbackLabel.alpha = 1
            feedbackLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0.3, animations: {
                feedbackLabel.alpha = 0
            }) { _ in
                feedbackLabel.removeFromSuperview()
            }
        }
    }
}

#endif
