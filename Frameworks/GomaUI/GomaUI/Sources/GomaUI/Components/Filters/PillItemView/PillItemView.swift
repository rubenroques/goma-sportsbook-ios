import UIKit
import Combine
import SwiftUI

final public class PillItemView: UIView {
    // MARK: - Private Properties
    private let containerView = UIView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let leftIconImageView = UIImageView()
    private let expandIconImageView = UIImageView()

    private var cancellables = Set<AnyCancellable>()
    private let viewModel: PillItemViewModelProtocol
    private var customization: PillItemCustomization?
    private var currentIsSelected: Bool = false

    // MARK: - Public Properties
    public var onPillSelected: (() -> Void) = { }

    // MARK: - Public Methods
    public func setCustomization(_ customization: PillItemCustomization?) {
        self.customization = customization
        // Re-apply current selection state with new customization
        updateSelectionState(isSelected: currentIsSelected)
    }

    // MARK: - Constants
    private enum Constants {
        static let minHeight: CGFloat = 40.0
        static let horizontalPadding: CGFloat = 12.0
        static let verticalPadding: CGFloat = 10.0
        static let iconSize: CGFloat = 22.0
        static let iconSpacing: CGFloat = 6.0
        static let borderWidth: CGFloat = 2.0
    }

    // MARK: - Initialization
    public init(viewModel: PillItemViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        configureImmediately()  // Sync render first
        setupBindings()          // Reactive updates second
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.layer.cornerRadius = containerView.frame.height / 2.0
    }

    // MARK: - Synchronous Configuration
    private func configureImmediately() {
        render(state: viewModel.currentDisplayState)
    }

    private func render(state: PillDisplayState) {
        let data = state.pillData
        var counter: String?
        
        switch data.type {
        case .countable(count: let count):
            counter = count > 0 ? " (\(count))" : nil
        case .expansible:
            // Expand icon
            expandIconImageView.isHidden = false
        default:
            expandIconImageView.isHidden = true
            break
        }

        // Title
        titleLabel.text = "\(data.title)\(counter, default: "")"

        // Left icon
        if let iconName = data.leftIconName {
            leftIconImageView.isHidden = false
            if let image = UIImage(named: iconName)?.withRenderingMode(data.shouldApplyTintColor ? .alwaysTemplate : .alwaysOriginal) {
                leftIconImageView.image = image
                if data.shouldApplyTintColor {
                    leftIconImageView.tintColor = StyleProvider.Color.highlightPrimary
                }
            } else {
                leftIconImageView.image = UIImage(systemName: iconName)
            }
        } else {
            leftIconImageView.isHidden = true
        }

        // Selection state
        updateSelectionState(isSelected: data.isSelected)
    }

    // MARK: - Setup
    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false

        // Container setup
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = true
        containerView.backgroundColor = StyleProvider.Color.pills
        addSubview(containerView)

        // Stack view setup
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = Constants.iconSpacing
        containerView.addSubview(stackView)

        // Left icon setup
        leftIconImageView.translatesAutoresizingMaskIntoConstraints = false
        leftIconImageView.contentMode = .scaleAspectFit
        leftIconImageView.isHidden = true
        leftIconImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        leftIconImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        NSLayoutConstraint.activate([
            leftIconImageView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            leftIconImageView.heightAnchor.constraint(equalToConstant: Constants.iconSize)
        ])

        // Title label setup
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.font = StyleProvider.fontWith(type: .semibold, size: 12)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Expand icon setup
        expandIconImageView.translatesAutoresizingMaskIntoConstraints = false
        expandIconImageView.contentMode = .scaleAspectFit
        expandIconImageView.isHidden = true
        expandIconImageView.image = UIImage(named: "expand_vertical_icon",
                                            in: Bundle.module,
                                            with: nil)?.withRenderingMode(.alwaysTemplate)
        expandIconImageView.image?.withTintColor(StyleProvider.Color.highlightPrimary)
        expandIconImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        expandIconImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        NSLayoutConstraint.activate([
            expandIconImageView.widthAnchor.constraint(equalToConstant: Constants.iconSize*0.6),
            expandIconImageView.heightAnchor.constraint(equalToConstant: Constants.iconSize)
        ])
        

        // Add views to stack view
        stackView.addArrangedSubview(leftIconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(expandIconImageView)

        // Setup default theme
        expandIconImageView.tintColor = StyleProvider.Color.highlightPrimary
        
//        #if DEBUG
//        stackView.layer.borderColor = UIColor.red.cgColor
//        stackView.layer.borderWidth = 1
//        #endif

        // Constraints
        NSLayoutConstraint.activate([
            // Container constraints
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),

            // Stack view constraints
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.verticalPadding),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.verticalPadding),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.horizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.horizontalPadding),

            // Height constraint
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.minHeight)
        ])

    }

    private func setupBindings() {
        // Unified state binding - uses dropFirst() to skip initial emit (already rendered synchronously)
        viewModel.displayStatePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state: state)
            }
            .store(in: &cancellables)
    }

    private func updateSelectionState(isSelected: Bool) {
        // Store current selection state
        currentIsSelected = isSelected

        // Use customization if available, otherwise fall back to defaults
        let style: PillItemStyle
        if let customization = customization {
            style = isSelected ? customization.selectedStyle : customization.unselectedStyle
        } else {
            style = isSelected ? PillItemStyle.defaultSelected(isReadOnly: viewModel.isReadOnly) : PillItemStyle.defaultUnselected()
        }

        // Apply the style
        containerView.backgroundColor = style.backgroundColor
        containerView.layer.borderWidth = style.borderWidth
        containerView.layer.borderColor = style.borderColor.cgColor
        titleLabel.textColor = style.textColor
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pillTapped))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }

    @objc private func pillTapped() {
        viewModel.selectPill()
        onPillSelected()
    }
}

// MARK: - Preview Provider
#if DEBUG

#Preview("All States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        // 1. TITLE LABEL
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "PillItemView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center

        // 2. VERTICAL STACK with ALL states
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // 3. ADD ALL COMPONENT INSTANCES
        // Selected with icon and expand icon
        let selectedViewModel = MockPillItemViewModel(
            pillData: PillData(
                id: "football",
                title: "Football",
                leftIconName: "sportscourt.fill",
                type: .expansible,
                isSelected: true
            )
        )
        let selectedPill = PillItemView(viewModel: selectedViewModel)
        selectedPill.translatesAutoresizingMaskIntoConstraints = false

        // Unselected with icon, no expand icon
        let unselectedViewModel = MockPillItemViewModel(
            pillData: PillData(
                id: "popular",
                title: "Popular",
                leftIconName: "flame.fill",
                type: .informative,
                isSelected: false
            )
        )
        let unselectedPill = PillItemView(viewModel: unselectedViewModel)
        unselectedPill.translatesAutoresizingMaskIntoConstraints = false

        // Add all states to stack
        stackView.addArrangedSubview(selectedPill)
        stackView.addArrangedSubview(unselectedPill)

        // 4. ADD TO VIEW HIERARCHY
        vc.view.addSubview(titleLabel)
        vc.view.addSubview(stackView)

        // 5. CONSTRAINTS
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -20),

            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])

        return vc
    }
}

#endif
