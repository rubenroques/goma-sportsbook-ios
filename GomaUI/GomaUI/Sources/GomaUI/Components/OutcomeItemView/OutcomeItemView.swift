import UIKit
import Combine
import SwiftUI

// MARK: - Position Configuration
public enum OutcomePosition {
    case single                    // Single item (all corners)
    case singleFirst              // Single line, first item (left corners)
    case singleLast               // Single line, last item (right corners)
    case multiTopLeft             // Multi-line, top-left item
    case multiTopRight            // Multi-line, top-right item
    case multiBottomLeft          // Multi-line, bottom-left item
    case multiBottomRight         // Multi-line, bottom-right item
    case middle                   // middle item (no corners)

    var cornerMask: CACornerMask {
        switch self {
        case .single:
            return [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .singleFirst:
            return [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        case .singleLast:
            return [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        case .multiTopLeft:
            return [.layerMinXMinYCorner]
        case .multiTopRight:
            return [.layerMaxXMinYCorner]
        case .multiBottomLeft:
            return [.layerMinXMaxYCorner]
        case .multiBottomRight:
            return [.layerMaxXMaxYCorner]
        case .middle:
            return []
        }
    }
}

final public class OutcomeItemView: UIView {

    // MARK: - Private Properties
    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var valueLabel: UILabel = Self.createValueLabel()
    private lazy var upChangeImage: UIImageView = Self.createUpChangeImage()
    private lazy var downChangeImage: UIImageView = Self.createDownChangeImage()
    private lazy var changeView: UIView = Self.createChangeView()

    private var cancellables = Set<AnyCancellable>()
    private var viewModel: OutcomeItemViewModelProtocol

    // Animation tracking for regulatory compliance
    private var activeAnimation: DispatchWorkItem?

    // MARK: - Public Properties
    public var onTap: (() -> Void) = { }
    public var onLongPress: (() -> Void) = { }

    // MARK: - Constants
    private enum Constants {
        static let cornerRadius: CGFloat = 4.5
        static let titleTopPadding: CGFloat = 6.0
        static let horizontalPadding: CGFloat = 2.0
        static let titleHeight: CGFloat = 14.0
        static let changeIndicatorSize: CGFloat = 12.0
        static let borderWidth: CGFloat = 1.0
    }

    // MARK: - Initialization
    public init(viewModel: OutcomeItemViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Configures the view with a new view model for efficient reuse
    public func configure(with newViewModel: OutcomeItemViewModelProtocol) {
        // Clear previous bindings
        cancellables.removeAll()
        
        // Cancel any active animations
        cancelActiveAnimation()
        
        // Update view model reference
        self.viewModel = newViewModel
        
        // Re-establish bindings with new view model
        setupBindings()
    }

    // MARK: - Setup
    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false

        // Add base view
        addSubview(baseView)

        // Add labels to base view
        baseView.addSubview(titleLabel)
        baseView.addSubview(valueLabel)

        // Add change indicator container
        changeView.addSubview(upChangeImage)
        changeView.addSubview(downChangeImage)
        baseView.addSubview(changeView)

        setupConstraints()
        setupWithTheme()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Base view
            baseView.topAnchor.constraint(equalTo: topAnchor),
            baseView.leadingAnchor.constraint(equalTo: leadingAnchor),
            baseView.trailingAnchor.constraint(equalTo: trailingAnchor),
            baseView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Title label
            titleLabel.topAnchor.constraint(equalTo: baseView.topAnchor, constant: Constants.titleTopPadding),
            titleLabel.centerXAnchor.constraint(equalTo: baseView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: Constants.horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -Constants.horizontalPadding),
            titleLabel.heightAnchor.constraint(equalToConstant: Constants.titleHeight),

            // Value label
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            valueLabel.centerXAnchor.constraint(equalTo: baseView.centerXAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: Constants.horizontalPadding),
            valueLabel.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -Constants.horizontalPadding),
            valueLabel.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -Constants.titleTopPadding),

            // Change indicator container
            changeView.trailingAnchor.constraint(equalTo: valueLabel.trailingAnchor),
            changeView.centerYAnchor.constraint(equalTo: valueLabel.centerYAnchor),
            changeView.widthAnchor.constraint(equalToConstant: Constants.changeIndicatorSize),
            changeView.heightAnchor.constraint(equalToConstant: Constants.changeIndicatorSize),

            // Up/Down images
            upChangeImage.topAnchor.constraint(equalTo: changeView.topAnchor),
            upChangeImage.leadingAnchor.constraint(equalTo: changeView.leadingAnchor),
            upChangeImage.trailingAnchor.constraint(equalTo: changeView.trailingAnchor),
            upChangeImage.bottomAnchor.constraint(equalTo: changeView.bottomAnchor),

            downChangeImage.topAnchor.constraint(equalTo: changeView.topAnchor),
            downChangeImage.leadingAnchor.constraint(equalTo: changeView.leadingAnchor),
            downChangeImage.trailingAnchor.constraint(equalTo: changeView.trailingAnchor),
            downChangeImage.bottomAnchor.constraint(equalTo: changeView.bottomAnchor)
        ])
    }

    private func setupWithTheme() {
        // Base view styling
        baseView.backgroundColor = StyleProvider.Color.backgroundColor
        baseView.layer.cornerRadius = Constants.cornerRadius
        baseView.clipsToBounds = true

        // Label styling
        titleLabel.textColor = StyleProvider.Color.textColor
        titleLabel.font = StyleProvider.fontWith(type: .regular, size: 12)

        valueLabel.textColor = StyleProvider.Color.textColor
        valueLabel.font = StyleProvider.fontWith(type: .bold, size: 16)

        // Change indicator styling
        upChangeImage.tintColor = StyleProvider.Color.successColor
        downChangeImage.tintColor = .systemRed
    }

    private func setupBindings() {
        // Title binding
        viewModel.titlePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                 self?.titleLabel.text = title
            }
            .store(in: &cancellables)

        // Value binding
        viewModel.valuePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.valueLabel.text = value
            }
            .store(in: &cancellables)

        // Selection state binding
        viewModel.isSelectedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSelected in
                self?.updateSelectionState(isSelected: isSelected)
            }
            .store(in: &cancellables)

        // Disabled state binding
        viewModel.isDisabledPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDisabled in
                self?.updateDisabledState(isDisabled: isDisabled)
            }
            .store(in: &cancellables)

        // Odds change event binding for animations
        viewModel.oddsChangeEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] changeEvent in
                self?.handleOddsChangeAnimation(changeEvent)
            }
            .store(in: &cancellables)
    }

    private func setupGestures() {
        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        baseView.addGestureRecognizer(tapGesture)

        // Long press gesture
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        baseView.addGestureRecognizer(longPressGesture)

        baseView.isUserInteractionEnabled = true
    }

    // MARK: - Update Methods
    private func updateSelectionState(isSelected: Bool) {
        if isSelected {
            baseView.backgroundColor = StyleProvider.Color.highlightPrimary
            titleLabel.textColor = StyleProvider.Color.allWhite
            valueLabel.textColor = StyleProvider.Color.allWhite
        } else {
            baseView.backgroundColor = StyleProvider.Color.backgroundColor
            titleLabel.textColor = StyleProvider.Color.textOdds
            valueLabel.textColor = StyleProvider.Color.textOdds
        }
    }

    private func updateDisabledState(isDisabled: Bool) {
        baseView.isUserInteractionEnabled = !isDisabled
        baseView.alpha = isDisabled ? 0.5 : 1.0
    }

    // MARK: - Odds Change Animation (Regulatory Compliant)
    private func handleOddsChangeAnimation(_ changeEvent: OutcomeItemOddsChangeEvent) {
        // Cancel any existing animation
        cancelActiveAnimation()

        // Perform the animation based on direction
        switch changeEvent.direction {
        case .up:
            performOddsChangeUpAnimation()
        case .down:
            performOddsChangeDownAnimation()
        case .none:
            // Clear any existing indicators
            upChangeImage.alpha = 0.0
            downChangeImage.alpha = 0.0
        }
    }

    private func performOddsChangeUpAnimation() {
        // Immediately hide down indicator and show up indicator
        downChangeImage.alpha = 0.0
        upChangeImage.alpha = 0.0
        
        // Set border for visual feedback
        baseView.layer.borderWidth = Constants.borderWidth

        // Animate appearance
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseIn, animations: {
            self.upChangeImage.alpha = 1.0
            self.animateBorderColor(color: StyleProvider.Color.successColor, duration: 0.4)
        }, completion: nil)

        // Schedule auto-hide after 3 seconds
        UIView.animate(withDuration: 0.4, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            self.upChangeImage.alpha = 0.0
            self.animateBorderColor(color: UIColor.clear, duration: 0.4)
        }, completion: { _ in
            self.baseView.layer.borderWidth = 0.0
            // Clear the indicator in the view model
            self.viewModel.clearOddsChangeIndicator()
            // Remove from active animations
            self.activeAnimation = nil
        })

        // Store a simple marker for cancellation
        activeAnimation = DispatchWorkItem { }
    }

    private func performOddsChangeDownAnimation() {
        // Immediately hide up indicator and show down indicator
        downChangeImage.alpha = 0.0
        upChangeImage.alpha = 0.0

        // Set border for visual feedback
        baseView.layer.borderWidth = Constants.borderWidth

        // Animate appearance
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseIn, animations: {
            self.downChangeImage.alpha = 1.0
            self.animateBorderColor(color: .systemRed, duration: 0.4)
        }, completion: nil)

        // Schedule auto-hide after 3 seconds
        UIView.animate(withDuration: 0.4, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            self.downChangeImage.alpha = 0.0
            self.animateBorderColor(color: UIColor.clear, duration: 0.4)
        }, completion: { _ in
            self.baseView.layer.borderWidth = 0.0
            // Clear the indicator in the view model
            self.viewModel.clearOddsChangeIndicator()
            // Remove from active animations
            self.activeAnimation = nil
        })

        // Store a simple marker for cancellation
        activeAnimation = DispatchWorkItem { }
    }

    private func animateBorderColor(color: UIColor, duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = baseView.layer.borderColor
        animation.toValue = color.cgColor
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        baseView.layer.add(animation, forKey: "borderColorAnimation")
        baseView.layer.borderColor = color.cgColor
    }

    private func cancelActiveAnimation() {
        activeAnimation?.cancel()
        activeAnimation = nil

        // Remove any ongoing layer animations
        baseView.layer.removeAllAnimations()

        // Reset border
        baseView.layer.borderWidth = 0.0
        baseView.layer.borderColor = UIColor.clear.cgColor
    }

    // MARK: - Gesture Handlers
    @objc private func handleTap() {
        let wasSelected = viewModel.toggleSelection()
        onTap()

        // Provide haptic feedback
        if wasSelected {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            onLongPress()

            // Provide haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }

    // MARK: - Public Methods
    public func simulateOddsChange(newValue: String) {
        viewModel.updateValue(newValue)
    }

    public func setSelected(_ selected: Bool) {
        viewModel.setSelected(selected)
    }

    public func setDisabled(_ disabled: Bool) {
        viewModel.setDisabled(disabled)
    }

    /// Sets the position-based corner radius configuration
    public func setPosition(_ position: OutcomePosition) {
        baseView.layer.maskedCorners = position.cornerMask
        baseView.layer.cornerRadius = Constants.cornerRadius
    }
}

// MARK: - Factory Methods
private extension OutcomeItemView {
    static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundColor
        view.layer.cornerRadius = Constants.cornerRadius
        view.clipsToBounds = true
        return view
    }

    static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textColor
        return label
    }

    static func createValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.textColor
        return label
    }

    static func createUpChangeImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "arrowtriangle.up.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.successColor
        imageView.alpha = 0.0
        return imageView
    }

    static func createDownChangeImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "arrowtriangle.down.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemRed
        imageView.alpha = 0.0
        return imageView
    }

    static func createChangeView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Home Outcome - Selected") {
    PreviewUIView {
        OutcomeItemView(viewModel: MockOutcomeItemViewModel.homeOutcome)
    }
    .frame(width: 100, height: 50)
    .padding()
    .background(Color(UIColor.systemGray6))
}

@available(iOS 17.0, *)
#Preview("Draw Outcome - Unselected") {
    PreviewUIView {
        OutcomeItemView(viewModel: MockOutcomeItemViewModel.drawOutcome)
    }
    .frame(width: 100, height: 50)
    .padding()
    .background(Color(UIColor.systemGray6))
}

@available(iOS 17.0, *)
#Preview("Over Outcome - Odds Up") {
    PreviewUIView {
        OutcomeItemView(viewModel: MockOutcomeItemViewModel.overOutcomeUp)
    }
    .frame(width: 100, height: 50)
    .padding()
    .background(Color(UIColor.systemGray6))
}

@available(iOS 17.0, *)
#Preview("Under Outcome - Odds Down") {
    PreviewUIView {
        OutcomeItemView(viewModel: MockOutcomeItemViewModel.underOutcomeDown)
    }
    .frame(width: 100, height: 50)
    .padding()
    .background(Color(UIColor.systemGray6))
}

@available(iOS 17.0, *)
#Preview("Disabled Outcome") {
    PreviewUIView {
        OutcomeItemView(viewModel: MockOutcomeItemViewModel.disabledOutcome)
    }
    .frame(width: 100, height: 50)
    .padding()
    .background(Color(UIColor.systemGray6))
}

@available(iOS 17.0, *)
#Preview("Single Line Layout") {
    PreviewUIView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fillEqually

        let homeView = OutcomeItemView(viewModel: MockOutcomeItemViewModel.homeOutcome)
        let drawView = OutcomeItemView(viewModel: MockOutcomeItemViewModel.drawOutcome)
        let awayView = OutcomeItemView(viewModel: MockOutcomeItemViewModel.awayOutcome)

        // Apply position-based corner radius
        homeView.setPosition(.singleFirst)
        drawView.setPosition(.middle) // Middle item gets no special corners
        awayView.setPosition(.singleLast)

        stackView.addArrangedSubview(homeView)
        stackView.addArrangedSubview(drawView)
        stackView.addArrangedSubview(awayView)

        return stackView
    }
    .frame(height: 50)
    .padding()
    .background(Color(UIColor.systemGray6))
}

@available(iOS 17.0, *)
#Preview("Multi-Line Layout") {
    PreviewUIView {
        let containerView = UIView()

        // Top row
        let topStackView = UIStackView()
        topStackView.axis = .horizontal
        topStackView.spacing = 0
        topStackView.distribution = .fillEqually

        let topLeftView = OutcomeItemView(viewModel: MockOutcomeItemViewModel.homeOutcome)
        let topRightView = OutcomeItemView(viewModel: MockOutcomeItemViewModel.drawOutcome)

        topLeftView.setPosition(.multiTopLeft)
        topRightView.setPosition(.multiTopRight)

        topStackView.addArrangedSubview(topLeftView)
        topStackView.addArrangedSubview(topRightView)

        // Bottom row
        let bottomStackView = UIStackView()
        bottomStackView.axis = .horizontal
        bottomStackView.spacing = 0
        bottomStackView.distribution = .fillEqually

        let bottomLeftView = OutcomeItemView(viewModel: MockOutcomeItemViewModel.awayOutcome)
        let bottomRightView = OutcomeItemView(viewModel: MockOutcomeItemViewModel.overOutcomeUp)

        bottomLeftView.setPosition(.multiBottomLeft)
        bottomRightView.setPosition(.multiBottomRight)

        bottomStackView.addArrangedSubview(bottomLeftView)
        bottomStackView.addArrangedSubview(bottomRightView)

        // Main stack
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 0
        mainStackView.distribution = .fillEqually

        mainStackView.addArrangedSubview(topStackView)
        mainStackView.addArrangedSubview(bottomStackView)

        containerView.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
    }
    .frame(height: 100)
    .padding()
    .background(Color(UIColor.systemGray6))
}

#endif
