import UIKit
import Combine
import SwiftUI

final public class CustomSliderView: UIView {
    // MARK: - Private Properties
    private let trackView = UIView()
    private let thumbImageView = UIImageView()

    private var cancellables = Set<AnyCancellable>()
    private let viewModel: CustomSliderViewModelProtocol
    private var currentDisplayState: CustomSliderDisplayState?

    private var thumbCenterXConstraint: NSLayoutConstraint!
    private var trackWidthConstraint: NSLayoutConstraint!

    // MARK: - Public Properties
    public var onValueChanged: ((Float) -> Void) = { _ in }
    public var onEditingEnded: ((Float) -> Void) = { _ in }

    // MARK: - Constants
    private enum Constants {
        static let minimumTouchArea: CGFloat = 44.0
        static let animationDuration: TimeInterval = 0.2
    }

    // MARK: - Initialization
    public init(viewModel: CustomSliderViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        // Track view setup
        trackView.translatesAutoresizingMaskIntoConstraints = false
        trackView.backgroundColor = StyleProvider.Color.highlightSecondary.withAlphaComponent(0.3)
        addSubview(trackView)

        // Thumb image view setup
        thumbImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbImageView.contentMode = .scaleAspectFit
        thumbImageView.layer.shadowColor = UIColor.black.cgColor
        thumbImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        thumbImageView.layer.shadowRadius = 4
        thumbImageView.layer.shadowOpacity = 0.2
        addSubview(thumbImageView)

        setupConstraints()
        setupAccessibility()
    }

        private func setupConstraints() {
        // We'll set these up with default values and update them when we get the display state
        thumbCenterXConstraint = thumbImageView.centerXAnchor.constraint(equalTo: leadingAnchor)
        trackWidthConstraint = trackView.widthAnchor.constraint(equalToConstant: 100)

        NSLayoutConstraint.activate([
            // Track constraints
            trackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            trackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackWidthConstraint,

            // Thumb constraints
            thumbImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            thumbCenterXConstraint,

            // Self height constraint based on thumb size (will be updated)
            heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.minimumTouchArea)
        ])
    }

    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .adjustable
        accessibilityLabel = LocalizationProvider.string("custom_slider")
        accessibilityIdentifier = "customSlider.slider"
    }

    private func setupBindings() {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(state: displayState)
            }
            .store(in: &cancellables)
    }

    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(panGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        addGestureRecognizer(tapGesture)
    }

    // MARK: - Rendering
    private func render(state: CustomSliderDisplayState) {
        currentDisplayState = state

        // Update track appearance
        updateTrackAppearance(with: state.configuration)

        // Update thumb appearance
        updateThumbAppearance(with: state.configuration)

        // Update thumb position
        updateThumbPosition(for: state.currentValue, configuration: state.configuration)

        // Update enabled state
        updateEnabledState(state.isEnabled)

        // Update accessibility
        updateAccessibility(with: state)
    }

    private func updateTrackAppearance(with configuration: SliderConfiguration) {
        trackView.layer.cornerRadius = configuration.trackCornerRadius

        // Update track height constraint
        trackView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = configuration.trackHeight
            }
        }

        // Add height constraint if it doesn't exist
        if !trackView.constraints.contains(where: { $0.firstAttribute == .height }) {
            trackView.heightAnchor.constraint(equalToConstant: configuration.trackHeight).isActive = true
        }
    }

        private func updateThumbAppearance(with configuration: SliderConfiguration) {
        // Update thumb size constraints
        thumbImageView.constraints.forEach { $0.isActive = false }

        NSLayoutConstraint.activate([
            thumbImageView.widthAnchor.constraint(equalToConstant: configuration.thumbSize),
            thumbImageView.heightAnchor.constraint(equalToConstant: configuration.thumbSize),
            thumbImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            thumbCenterXConstraint
        ])

        // Set up thumb image and tinting
        setupThumbImage(with: configuration)

        // Update self height constraint
        constraints.forEach { constraint in
            if constraint.firstAttribute == .height && constraint.secondItem == nil {
                constraint.constant = max(configuration.thumbSize, Constants.minimumTouchArea)
            }
        }
    }

    private func setupThumbImage(with configuration: SliderConfiguration) {
        if let thumbImageName = configuration.thumbImageName {
            // Use custom image
            thumbImageView.image = UIImage(named: thumbImageName) ?? UIImage(systemName: thumbImageName)
        } else {
            // Create default circular thumb image
            thumbImageView.image = UIImage(named: "slider_handle", in: Bundle.module, with: nil)
        }

        // Apply tint color
        let tintColor = configuration.thumbTintColor ?? StyleProvider.Color.highlightPrimary
        thumbImageView.tintColor = tintColor

        // Set rendering mode to allow tinting
        thumbImageView.image = thumbImageView.image?.withRenderingMode(.alwaysTemplate)
    }

    private func updateThumbPosition(for value: Float, configuration: SliderConfiguration, animated: Bool = false) {
        let trackWidth = bounds.width
        let thumbRadius = configuration.thumbSize / 2
        let availableWidth = trackWidth - configuration.thumbSize

        let normalizedValue = (value - configuration.minimumValue) / (configuration.maximumValue - configuration.minimumValue)
        let thumbCenterX = thumbRadius + (availableWidth * CGFloat(normalizedValue))

        thumbCenterXConstraint.constant = thumbCenterX

        if animated {
            UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: [.curveEaseOut], animations: {
                self.layoutIfNeeded()
            })
        } else {
            layoutIfNeeded()
        }
    }

    private func updateEnabledState(_ isEnabled: Bool) {
        self.isUserInteractionEnabled = isEnabled
        alpha = isEnabled ? 1.0 : 0.6
    }

    private func updateAccessibility(with state: CustomSliderDisplayState) {
        accessibilityValue = String(format: "%.2f", state.currentValue)
        accessibilityHint = state.isEnabled ? "Swipe up or down to adjust value" : "Slider is disabled"
    }

    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()

        // Update thumb position when layout changes
        if let state = currentDisplayState {
            updateThumbPosition(for: state.currentValue, configuration: state.configuration)
        }
    }

    // MARK: - Gesture Handlers
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let state = currentDisplayState, state.isEnabled else { return }

        let location = gesture.location(in: self)
        let newValue = calculateValue(from: location, configuration: state.configuration)

        switch gesture.state {
        case .began, .changed:
            viewModel.updateValue(newValue)
            onValueChanged(newValue)

        case .ended, .cancelled:
            viewModel.snapToNearestStep()
            onEditingEnded(newValue)

        default:
            break
        }
    }

    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard let state = currentDisplayState, state.isEnabled else { return }

        let location = gesture.location(in: self)
        let newValue = calculateValue(from: location, configuration: state.configuration)

        viewModel.updateValue(newValue)
        viewModel.snapToNearestStep()

        onValueChanged(newValue)
        onEditingEnded(newValue)
    }

    // MARK: - Helper Methods
    private func calculateValue(from location: CGPoint, configuration: SliderConfiguration) -> Float {
        let trackWidth = bounds.width
        let thumbRadius = configuration.thumbSize / 2
        let availableWidth = trackWidth - configuration.thumbSize

        let clampedX = max(thumbRadius, min(location.x, trackWidth - thumbRadius))
        let normalizedPosition = (clampedX - thumbRadius) / availableWidth

        let value = configuration.minimumValue + Float(normalizedPosition) * (configuration.maximumValue - configuration.minimumValue)
        return max(configuration.minimumValue, min(configuration.maximumValue, value))
    }

    private func snapValueToStep(_ value: Float, configuration: SliderConfiguration) -> Float {
        let range = configuration.maximumValue - configuration.minimumValue
        let stepSize = range / Float(configuration.numberOfSteps - 1)
        let stepIndex = round((value - configuration.minimumValue) / stepSize)
        return configuration.minimumValue + (stepIndex * stepSize)
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("CustomSliderView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "CustomSliderView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Default (start position)
        let defaultView = CustomSliderView(viewModel: MockCustomSliderViewModel.defaultMock)
        defaultView.translatesAutoresizingMaskIntoConstraints = false

        // Mid position
        let midPositionView = CustomSliderView(viewModel: MockCustomSliderViewModel.midPositionMock)
        midPositionView.translatesAutoresizingMaskIntoConstraints = false

        // Time filter
        let timeFilterView = CustomSliderView(viewModel: MockCustomSliderViewModel.timeFilterMock)
        timeFilterView.translatesAutoresizingMaskIntoConstraints = false

        // Disabled state
        let disabledView = CustomSliderView(viewModel: MockCustomSliderViewModel.disabledMock)
        disabledView.translatesAutoresizingMaskIntoConstraints = false

        // Custom image and color
        let customImageView = CustomSliderView(viewModel: MockCustomSliderViewModel.customImageMock)
        customImageView.translatesAutoresizingMaskIntoConstraints = false

        // Volume slider
        let volumeSliderView = CustomSliderView(viewModel: MockCustomSliderViewModel.volumeSliderMock)
        volumeSliderView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(defaultView)
        stackView.addArrangedSubview(midPositionView)
        stackView.addArrangedSubview(timeFilterView)
        stackView.addArrangedSubview(disabledView)
        stackView.addArrangedSubview(customImageView)
        stackView.addArrangedSubview(volumeSliderView)

        scrollView.addSubview(stackView)
        vc.view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        return vc
    }
}

#endif
