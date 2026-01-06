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
    
    // New UI elements for missing states
    private lazy var loadingIndicator: UIActivityIndicatorView = Self.createLoadingIndicator()
    private lazy var lockIcon: UIImageView = Self.createLockIcon()
    private lazy var boostIcon: UIImageView = Self.createBoostIcon()

    private var cancellables = Set<AnyCancellable>()
    private var viewModel: OutcomeItemViewModelProtocol
    private var configuration: OutcomeItemConfiguration = .default

    // MARK: - Public Properties
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
    public init(viewModel: OutcomeItemViewModelProtocol, configuration: OutcomeItemConfiguration? = nil) {
        self.viewModel = viewModel
        self.configuration = configuration ?? .default
        super.init(frame: .zero)

        setupSubviews()
        configureImmediately()
        setupBindings()
        setupGestures()
    }

    // MARK: - Synchronous Configuration
    /// Renders initial state synchronously before async bindings are established.
    /// This enables snapshot tests without RunLoop hacks.
    private func configureImmediately() {
        let data = viewModel.currentOutcomeData
        titleLabel.text = data.title
        valueLabel.text = data.value
        updateDisplayState(data.displayState)
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

        // Render initial state synchronously
        configureImmediately()

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
        
        // Add new state indicators
        baseView.addSubview(loadingIndicator)
        baseView.addSubview(lockIcon)
        baseView.addSubview(boostIcon)

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
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: baseView.leadingAnchor, constant: Constants.horizontalPadding),
            valueLabel.trailingAnchor.constraint(equalTo: changeView.leadingAnchor, constant: -2),
            valueLabel.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -Constants.titleTopPadding),

            // Change indicator container
            changeView.trailingAnchor.constraint(greaterThanOrEqualTo: valueLabel.trailingAnchor),
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
            downChangeImage.bottomAnchor.constraint(equalTo: changeView.bottomAnchor),
            
            // Loading indicator (centered in value area)
            loadingIndicator.centerXAnchor.constraint(equalTo: baseView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: valueLabel.centerYAnchor),
            
            // Lock icon (centered in value area)
            lockIcon.centerXAnchor.constraint(equalTo: baseView.centerXAnchor),
            lockIcon.centerYAnchor.constraint(equalTo: valueLabel.centerYAnchor),
            lockIcon.widthAnchor.constraint(equalToConstant: 16),
            lockIcon.heightAnchor.constraint(equalToConstant: 16),
            
            // Boost icon (positioned like the odds change indicators)
            boostIcon.widthAnchor.constraint(equalToConstant: 10),
            boostIcon.heightAnchor.constraint(equalToConstant: 10),
            boostIcon.trailingAnchor.constraint(equalTo: valueLabel.leadingAnchor, constant: -2),
            boostIcon.centerYAnchor.constraint(equalTo: valueLabel.centerYAnchor)
        ])
    }

    private func setupWithTheme() {
        // Base view styling
        baseView.backgroundColor = StyleProvider.Color.backgroundPrimary
        baseView.layer.cornerRadius = Constants.cornerRadius
        baseView.clipsToBounds = true

        // Label styling - uses configuration
        applyConfiguration()

        // Change indicator styling
        upChangeImage.tintColor = .systemGreen
        downChangeImage.tintColor = .systemRed
    }

    private func applyConfiguration() {
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.font = StyleProvider.fontWith(type: configuration.titleFontType, size: configuration.titleFontSize)

        valueLabel.textColor = StyleProvider.Color.textPrimary
        valueLabel.font = StyleProvider.fontWith(type: configuration.valueFontType, size: configuration.valueFontSize)
    }

    /// Sets a custom configuration for the outcome item appearance
    /// - Parameter customization: The configuration to apply, or nil to reset to default
    public func setCustomization(_ customization: OutcomeItemConfiguration?) {
        self.configuration = customization ?? .default
        applyConfiguration()
    }

    private func setupBindings() {
        // Title binding - dropFirst() since initial value rendered in configureImmediately()
        viewModel.titlePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                 self?.titleLabel.text = title
            }
            .store(in: &cancellables)

        // Value binding - dropFirst() since initial value rendered in configureImmediately()
        viewModel.valuePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.valueLabel.text = value
            }
            .store(in: &cancellables)

        // Selection state binding - dropFirst() since initial state rendered in configureImmediately()
        viewModel.isSelectedPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSelected in
                self?.updateSelectionState(isSelected: isSelected)
            }
            .store(in: &cancellables)

        // Disabled state binding - dropFirst() since initial state rendered in configureImmediately()
        viewModel.isDisabledPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDisabled in
                self?.updateDisabledState(isDisabled: isDisabled)
            }
            .store(in: &cancellables)

        // Odds change event binding for animations (no dropFirst - PassthroughSubject has no initial value)
        viewModel.oddsChangeEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] changeEvent in
                self?.handleOddsChangeAnimation(changeEvent)
            }
            .store(in: &cancellables)

        // Display state binding - dropFirst() since initial state rendered in configureImmediately()
        viewModel.displayStatePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.updateDisplayState(displayState)
            }
            .store(in: &cancellables)

        // Haptic feedback when selection changes to selected
        // Note: Already has dropFirst() - now needs second dropFirst() to skip initial AND first change
        viewModel.isSelectedPublisher
            .dropFirst()
            .filter { $0 } // Only when becoming selected
            .receive(on: DispatchQueue.main)
            .sink { _ in
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
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
    private func updateDisplayState(_ state: OutcomeDisplayState) {
        // Reset all special states first
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        lockIcon.isHidden = true
        boostIcon.isHidden = true
        titleLabel.isHidden = false
        valueLabel.isHidden = false
        
        switch state {
        case .loading:
            // Show loading state
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
            valueLabel.isHidden = true
            baseView.backgroundColor = StyleProvider.Color.backgroundOdds
            titleLabel.textColor = StyleProvider.Color.textOdds
            baseView.isUserInteractionEnabled = false
            
        case .locked:
            // Show lock icon
            lockIcon.isHidden = false
            valueLabel.isHidden = true
            baseView.backgroundColor = StyleProvider.Color.backgroundOdds
            titleLabel.textColor = StyleProvider.Color.textOdds
            baseView.isUserInteractionEnabled = false
            
        case .unavailable:
            // Show "-" for unavailable state
            valueLabel.text = "-"
            baseView.backgroundColor = StyleProvider.Color.backgroundDisabledOdds
            titleLabel.textColor = StyleProvider.Color.textDisabledOdds
            valueLabel.textColor = StyleProvider.Color.textDisabledOdds
            baseView.isUserInteractionEnabled = false
            
        case .normal(let isSelected, let isBoosted):
            // Normal state with selection and boost
            baseView.isUserInteractionEnabled = true
            boostIcon.isHidden = !isBoosted
            
            if isSelected {
                baseView.backgroundColor = StyleProvider.Color.highlightPrimary
                titleLabel.textColor = StyleProvider.Color.allWhite
                valueLabel.textColor = StyleProvider.Color.allWhite
                boostIcon.tintColor = StyleProvider.Color.allWhite
            } else {
                baseView.backgroundColor = StyleProvider.Color.backgroundOdds
                titleLabel.textColor = StyleProvider.Color.textOdds
                valueLabel.textColor = StyleProvider.Color.textOdds
                boostIcon.tintColor = StyleProvider.Color.highlightPrimary
            }
        }
    }
    
    private func updateSelectionState(isSelected: Bool) {
        // Keep for backward compatibility - this will be overridden by displayState updates
        if isSelected {
            baseView.backgroundColor = StyleProvider.Color.highlightPrimary
            titleLabel.textColor = StyleProvider.Color.allWhite
            valueLabel.textColor = StyleProvider.Color.allWhite
        } else {
            baseView.backgroundColor = StyleProvider.Color.backgroundOdds
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
        
        // Store original background color
        let originalBackgroundColor = baseView.backgroundColor
        
        // Set background and border for visual feedback
        baseView.backgroundColor = StyleProvider.Color.myTicketsWonFaded
        baseView.layer.borderWidth = Constants.borderWidth

        // Animate appearance
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseIn, animations: {
            self.upChangeImage.alpha = 1.0
            self.baseView.backgroundColor = StyleProvider.Color.myTicketsWonFaded
            self.animateBorderColor(color: StyleProvider.Color.myTicketsWon, duration: 0.4)
        }, completion: nil)

        // Schedule auto-hide after 3 seconds
        UIView.animate(withDuration: 0.4, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            self.upChangeImage.alpha = 0.0
            self.baseView.backgroundColor = originalBackgroundColor
            self.animateBorderColor(color: UIColor.clear, duration: 0.4)
        }, completion: { _ in
            self.baseView.layer.borderWidth = 0.0
            // Clear the indicator in the view model
            self.viewModel.clearOddsChangeIndicator()
        })
    }

    private func performOddsChangeDownAnimation() {
        // Immediately hide up indicator and show down indicator
        downChangeImage.alpha = 0.0
        upChangeImage.alpha = 0.0
        
        // Store original background color
        let originalBackgroundColor = baseView.backgroundColor

        // Set background and border for visual feedback
        baseView.backgroundColor = StyleProvider.Color.myTicketsLostFaded
        baseView.layer.borderWidth = Constants.borderWidth

        // Animate appearance
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseIn, animations: {
            self.downChangeImage.alpha = 1.0
            self.baseView.backgroundColor = StyleProvider.Color.myTicketsLostFaded
            self.animateBorderColor(color: StyleProvider.Color.myTicketsLost, duration: 0.4)
        }, completion: nil)

        // Schedule auto-hide after 3 seconds
        UIView.animate(withDuration: 0.4, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            self.downChangeImage.alpha = 0.0
            self.baseView.backgroundColor = originalBackgroundColor
            self.animateBorderColor(color: UIColor.clear, duration: 0.4)
        }, completion: { _ in
            self.baseView.layer.borderWidth = 0.0
            // Clear the indicator in the view model
            self.viewModel.clearOddsChangeIndicator()
        })
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
        // Remove any ongoing layer animations
        baseView.layer.removeAllAnimations()

        // Reset border
        baseView.layer.borderWidth = 0.0
        baseView.layer.borderColor = UIColor.clear.cgColor
    }

    // MARK: - Gesture Handlers
    @objc private func handleTap() {
        // Single call - View requests action, ViewModel decides outcome
        // This is the correct MVVM pattern: View -> ViewModel -> State -> Publishers
        // Haptic feedback is handled via isSelectedPublisher observation in setupBindings()
        viewModel.userDidTapOutcome()
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
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        view.layer.cornerRadius = Constants.cornerRadius
        view.clipsToBounds = true
        return view
    }

    static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        // Font is set by applyConfiguration()
        return label
    }

    static func createValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        // Font is set by applyConfiguration()
        return label
    }

    static func createUpChangeImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "arrowtriangle.up.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGreen
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
    
    static func createLoadingIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = StyleProvider.Color.highlightPrimary
        return indicator
    }
    
    static func createLockIcon() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "lock.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.iconSecondary
        imageView.isHidden = true
        return imageView
    }
    
    static func createBoostIcon() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // Using arrow.up.circle.fill as boost icon - you can replace with custom asset
        imageView.image = UIImage(systemName: "arrow.up.circle.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.highlightPrimary
        imageView.isHidden = true
        return imageView
    }
}

// MARK: - Preview Provider
#if DEBUG

#Preview("Home Outcome - Selected") {
    PreviewUIViewController {
        let vc = UIViewController()
        let outcomeView = OutcomeItemView(viewModel: MockOutcomeItemViewModel.homeOutcome)
        outcomeView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(outcomeView)
        
        NSLayoutConstraint.activate([
            outcomeView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            outcomeView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            outcomeView.widthAnchor.constraint(equalToConstant: 100),
            outcomeView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        vc.view.backgroundColor = UIColor.systemGray6
        return vc
    }
}

#Preview("Draw Outcome - Unselected") {
    PreviewUIViewController {
        let vc = UIViewController()
        let outcomeView = OutcomeItemView(viewModel: MockOutcomeItemViewModel.drawOutcome)
        outcomeView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(outcomeView)
        
        NSLayoutConstraint.activate([
            outcomeView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            outcomeView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            outcomeView.widthAnchor.constraint(equalToConstant: 100),
            outcomeView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        vc.view.backgroundColor = UIColor.systemGray6
        return vc
    }
}

#Preview("Over Outcome - Odds Up") {
    PreviewUIViewController {
        let vc = UIViewController()
        let outcomeView = OutcomeItemView(viewModel: MockOutcomeItemViewModel.overOutcomeUp)
        outcomeView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(outcomeView)
        
        NSLayoutConstraint.activate([
            outcomeView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            outcomeView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            outcomeView.widthAnchor.constraint(equalToConstant: 100),
            outcomeView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        vc.view.backgroundColor = UIColor.red
        return vc
    }
}

#Preview("Under Outcome - Odds Down") {
    PreviewUIViewController {
        let vc = UIViewController()
        let outcomeView = OutcomeItemView(viewModel: MockOutcomeItemViewModel.underOutcomeDown)
        outcomeView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(outcomeView)
        
        NSLayoutConstraint.activate([
            outcomeView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            outcomeView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            outcomeView.widthAnchor.constraint(equalToConstant: 100),
            outcomeView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        vc.view.backgroundColor = UIColor.systemGray6
        return vc
    }
}

#Preview("Disabled Outcome") {
    PreviewUIViewController {
        let vc = UIViewController()
        let outcomeView = OutcomeItemView(viewModel: MockOutcomeItemViewModel.disabledOutcome)
        outcomeView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(outcomeView)
        
        NSLayoutConstraint.activate([
            outcomeView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            outcomeView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            outcomeView.widthAnchor.constraint(equalToConstant: 100),
            outcomeView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        vc.view.backgroundColor = UIColor.systemGray6
        return vc
    }
}

#Preview("Single Line Layout") {
    PreviewUIViewController {
        let vc = UIViewController()
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

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
        
        vc.view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 300),
            stackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        vc.view.backgroundColor = UIColor.systemGray6
        return vc
    }
}

#Preview("Multi-Line Layout") {
    PreviewUIViewController {
        let vc = UIViewController()
        
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
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        mainStackView.addArrangedSubview(topStackView)
        mainStackView.addArrangedSubview(bottomStackView)
        
        vc.view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            mainStackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            mainStackView.widthAnchor.constraint(equalToConstant: 200),
            mainStackView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        vc.view.backgroundColor = UIColor.systemGray6
        return vc
    }
}

#endif
