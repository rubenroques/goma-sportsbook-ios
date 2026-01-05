import UIKit
import Combine

public class MarketGroupTabItemView: UIView {

    // MARK: - Private Properties
    private let viewModel: MarketGroupTabItemViewModelProtocol
    private let imageResolver: MarketGroupTabImageResolver
    private let idleBackgroundColor: UIColor
    private let selectedBackgroundColor: UIColor
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components
    private let containerView = UIView()
    private let contentStackView = UIStackView()
    private let titleLabel = UILabel()
    private let prefixIconImageView = UIImageView()
    private let suffixIconImageView = UIImageView()
    private let badgeView = UIView()
    private let badgeLabel = UILabel()
    private let underlineView = UIView()

    // MARK: - Layout Constants
    private struct Constants {
        static let horizontalPadding: CGFloat = 16.0
        static let verticalPadding: CGFloat = 2.0
        static let underlineHeight: CGFloat = 2.0
        static let animationDuration: TimeInterval = 0.2
        static let minimumHeight: CGFloat = 42.0
        static let stackSpacing: CGFloat = 4.0
        static let iconSize: CGFloat = 14.0
        static let badgeSize: CGFloat = 16.0
        static let badgeFontSize: CGFloat = 10.0
    }

    // MARK: - Initialization
    public init(viewModel: MarketGroupTabItemViewModelProtocol, 
                imageResolver: MarketGroupTabImageResolver = DefaultMarketGroupTabImageResolver(),
                idleBackgroundColor: UIColor = StyleProvider.Color.backgroundPrimary,
                selectedBackgroundColor: UIColor = StyleProvider.Color.backgroundPrimary) {
        self.viewModel = viewModel
        self.imageResolver = imageResolver
        self.idleBackgroundColor = idleBackgroundColor
        self.selectedBackgroundColor = selectedBackgroundColor
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setupBindings()
        setupGestures()
        
        // Apply initial visual state
        applyVisualState(viewModel.currentVisualState)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Methods
    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubview(contentStackView)
        containerView.addSubview(underlineView)
        
        // Container view setup
        containerView.clipsToBounds = true

        // Stack view setup
        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.distribution = .fill
        contentStackView.spacing = Constants.stackSpacing
        
        // Add views to stack in order: [prefixIcon, title, suffixIcon, badge]
        contentStackView.addArrangedSubview(prefixIconImageView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(suffixIconImageView)
        contentStackView.addArrangedSubview(badgeView)

        // Title label setup
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.font = StyleProvider.fontWith(type: .regular, size: 12)
        
        // Prefix icon image view setup
        prefixIconImageView.contentMode = .scaleAspectFit
        prefixIconImageView.tintColor = StyleProvider.Color.textPrimary
        prefixIconImageView.isHidden = true
        
        // Suffix icon image view setup
        suffixIconImageView.contentMode = .scaleAspectFit
        suffixIconImageView.tintColor = StyleProvider.Color.textPrimary
        suffixIconImageView.isHidden = true
        
        // Badge view setup
        badgeView.backgroundColor = StyleProvider.Color.highlightPrimary
        badgeView.layer.cornerRadius = Constants.badgeSize / 2
        badgeView.isHidden = true
        badgeView.addSubview(badgeLabel)
        
        // Badge label setup
        badgeLabel.textColor = StyleProvider.Color.buttonTextPrimary
        badgeLabel.font = StyleProvider.fontWith(type: .bold, size: Constants.badgeFontSize)
        badgeLabel.textAlignment = .center
        
        // Underline view setup
        underlineView.isHidden = true
        underlineView.layer.cornerRadius = Constants.underlineHeight / 2
    }

    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        prefixIconImageView.translatesAutoresizingMaskIntoConstraints = false
        suffixIconImageView.translatesAutoresizingMaskIntoConstraints = false
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        underlineView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.minimumHeight),
            
            // Content stack view constraints - centered with minimum padding
            contentStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            contentStackView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: Constants.horizontalPadding),
            contentStackView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -Constants.horizontalPadding),
            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: underlineView.topAnchor),

            // Prefix icon size constraints
            prefixIconImageView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            prefixIconImageView.heightAnchor.constraint(equalToConstant: Constants.iconSize),
            
            // Suffix icon size constraints
            suffixIconImageView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            suffixIconImageView.heightAnchor.constraint(equalToConstant: Constants.iconSize),
            
            // Badge size constraints
            badgeView.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.badgeSize),
            badgeView.heightAnchor.constraint(equalToConstant: Constants.badgeSize),
            
            // Badge label constraints
            badgeLabel.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
            badgeLabel.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
            badgeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: badgeView.leadingAnchor, constant: 3),
            badgeLabel.trailingAnchor.constraint(lessThanOrEqualTo: badgeView.trailingAnchor, constant: -3),

            // Underline view constraints
            underlineView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            underlineView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
            underlineView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            underlineView.heightAnchor.constraint(equalToConstant: Constants.underlineHeight)
        ])
    }

    private func setupBindings() {
        // Title binding
        viewModel.titlePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.titleLabel.text = title
            }
            .store(in: &cancellables)

        // Prefix icon type binding
        viewModel.prefixIconTypePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] iconType in
                self?.updatePrefixIcon(iconType)
            }
            .store(in: &cancellables)
        
        // Suffix icon type binding
        viewModel.suffixIconTypePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] iconType in
                self?.updateSuffixIcon(iconType)
            }
            .store(in: &cancellables)
        
        // Badge count binding
        viewModel.badgeCountPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.updateBadge(count)
            }
            .store(in: &cancellables)

        // Visual state binding
        viewModel.visualStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] visualState in
                self?.updateVisualState(visualState)
            }
            .store(in: &cancellables)
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }

    // MARK: - Action Handlers
    @objc private func handleTap() {
        viewModel.handleTap()

        // Add haptic feedback for better UX
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }

    // MARK: - State Updates
    private func updatePrefixIcon(_ iconType: String?) {
        guard let iconType = iconType else {
            prefixIconImageView.isHidden = true
            return
        }
        
        prefixIconImageView.image = imageResolver.tabIcon(for: iconType)?.withRenderingMode(.alwaysTemplate)
        prefixIconImageView.isHidden = false
    }
    
    private func updateSuffixIcon(_ iconType: String?) {
        guard let iconType = iconType else {
            suffixIconImageView.isHidden = true
            return
        }
        
        suffixIconImageView.image = imageResolver.tabIcon(for: iconType)?.withRenderingMode(.alwaysTemplate)
        suffixIconImageView.isHidden = false
    }
    
    private func updateBadge(_ count: Int?) {
        guard let count = count, count > 0 else {
            badgeView.isHidden = true
            return
        }
        
        badgeLabel.text = "\(count)"
        badgeView.isHidden = false
    }
    
    private func updateVisualState(_ visualState: MarketGroupTabItemVisualState) {
        UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: [.curveEaseInOut]) {
            self.applyVisualState(visualState)
        }
    }

    private func applyVisualState(_ visualState: MarketGroupTabItemVisualState) {
        switch visualState {
        case .idle:
            applyIdleState()
        case .selected:
            applySelectedState()
        }
    }

    private func applyIdleState() {
        backgroundColor = idleBackgroundColor
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        
        // Set icon colors to match idle text
        prefixIconImageView.tintColor = StyleProvider.Color.textPrimary
        suffixIconImageView.tintColor = StyleProvider.Color.textPrimary
        
        underlineView.isHidden = true
        underlineView.backgroundColor = .clear
        
        alpha = 1.0
    }

    private func applySelectedState() {
        backgroundColor = selectedBackgroundColor
        
        titleLabel.textColor = StyleProvider.Color.highlightPrimary
        titleLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        
        // Set icon colors to match selected text
        prefixIconImageView.tintColor = StyleProvider.Color.highlightPrimary
        suffixIconImageView.tintColor = StyleProvider.Color.highlightPrimary
        
        underlineView.isHidden = false
        underlineView.backgroundColor = StyleProvider.Color.highlightPrimary
        
        alpha = 1.0
    }

}

// MARK: - Intrinsic Content Size
extension MarketGroupTabItemView {
    public override var intrinsicContentSize: CGSize {
        let stackSize = contentStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(
            width: stackSize.width + (Constants.horizontalPadding * 2),
            height: Constants.minimumHeight
        )
    }
}

// MARK: - Preview Provider
#if DEBUG
import SwiftUI


@available(iOS 17.0, *)
#Preview("1x2 Tab - Selected") {
    PreviewUIViewController {
        let vc = UIViewController()
        let tabView = MarketGroupTabItemView(viewModel: MockMarketGroupTabItemViewModel.oneXTwoTab)
        tabView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(tabView)
        
        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tabView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            tabView.trailingAnchor.constraint(lessThanOrEqualTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Double Chance Tab - Idle") {
    PreviewUIViewController {
        let vc = UIViewController()
        let tabView = MarketGroupTabItemView(viewModel: MockMarketGroupTabItemViewModel.doubleChanceTab)
        tabView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(tabView)
        
        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tabView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            tabView.trailingAnchor.constraint(lessThanOrEqualTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("BetBuilder Tab with Icon and Badge") {
    PreviewUIViewController {
        let vc = UIViewController()
        let tabView = MarketGroupTabItemView(viewModel: MockMarketGroupTabItemViewModel.betBuilderTab)
        tabView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(tabView)
        
        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tabView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            tabView.trailingAnchor.constraint(lessThanOrEqualTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Popular Tab with Icon and Badge") {
    PreviewUIViewController {
        let vc = UIViewController()
        let tabView = MarketGroupTabItemView(viewModel: MockMarketGroupTabItemViewModel.popularTab)
        tabView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(tabView)
        
        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tabView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            tabView.trailingAnchor.constraint(lessThanOrEqualTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Sets Tab with Badge Only") {
    PreviewUIViewController {
        let vc = UIViewController()
        let tabView = MarketGroupTabItemView(viewModel: MockMarketGroupTabItemViewModel.setsTab)
        tabView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(tabView)
        
        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tabView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            tabView.trailingAnchor.constraint(lessThanOrEqualTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Multiple Tabs Layout") {
    PreviewUIViewController {
        let vc = UIViewController()
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let tabs = [
            ("All", true, nil as String?, nil as Int?),
            ("BetBuilder", false, "betbuilder", 16),
            (LocalizationProvider.string("popular_string"), false, "popular", 16),
            (LocalizationProvider.string("market_group_sets"), false, nil, 16)
        ]

        for (title, selected, iconTypeName, badgeCount) in tabs {
            let tabView = MarketGroupTabItemView(
                viewModel: MockMarketGroupTabItemViewModel.customTab(
                    id: title.lowercased().replacingOccurrences(of: " ", with: ""),
                    title: title,
                    selected: selected,
                    suffixIconTypeName: iconTypeName,
                    badgeCount: badgeCount
                )
            )
            stackView.addArrangedSubview(tabView)
        }

        vc.view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Custom Background Colors - Blue Tab") {
    PreviewUIViewController {
        let vc = UIViewController()
        let tabView = MarketGroupTabItemView(
            viewModel: MockMarketGroupTabItemViewModel.betBuilderTab,
            idleBackgroundColor: .systemBlue,
            selectedBackgroundColor: .systemBlue
        )
        tabView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(tabView)
        
        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tabView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            tabView.trailingAnchor.constraint(lessThanOrEqualTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Different Idle/Selected Background Colors") {
    PreviewUIViewController {
        let vc = UIViewController()
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Create one selected tab and one idle tab with different background colors
        let selectedTab = MarketGroupTabItemView(
            viewModel: MockMarketGroupTabItemViewModel.customTab(id: "selected", title: "Selected", selected: true),
            idleBackgroundColor: .systemGray5,
            selectedBackgroundColor: .systemBlue
        )
        
        let idleTab = MarketGroupTabItemView(
            viewModel: MockMarketGroupTabItemViewModel.customTab(id: "idle", title: "Idle", selected: true),
            idleBackgroundColor: .systemGray5,
            selectedBackgroundColor: .systemGreen
        )
        
        stackView.addArrangedSubview(selectedTab)
        stackView.addArrangedSubview(idleTab)
        
        vc.view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Prefix Only Icon") {
    PreviewUIViewController {
        let vc = UIViewController()
        let tabView = MarketGroupTabItemView(viewModel: MockMarketGroupTabItemViewModel.prefixOnlyTab)
        tabView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(tabView)
        
        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tabView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            tabView.trailingAnchor.constraint(lessThanOrEqualTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Suffix Only Icon") {
    PreviewUIViewController {
        let vc = UIViewController()
        let tabView = MarketGroupTabItemView(viewModel: MockMarketGroupTabItemViewModel.suffixOnlyTab)
        tabView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(tabView)
        
        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tabView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            tabView.trailingAnchor.constraint(lessThanOrEqualTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Both Prefix and Suffix Icons") {
    PreviewUIViewController {
        let vc = UIViewController()
        let tabView = MarketGroupTabItemView(viewModel: MockMarketGroupTabItemViewModel.bothIconsTab)
        tabView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(tabView)
        
        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tabView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            tabView.trailingAnchor.constraint(lessThanOrEqualTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Icon Combinations Layout") {
    PreviewUIViewController {
        let vc = UIViewController()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let tabs = [
            ("Prefix Only", MockMarketGroupTabItemViewModel.prefixOnlyTab),
            ("Suffix Only", MockMarketGroupTabItemViewModel.suffixOnlyTab),
            ("Both Icons", MockMarketGroupTabItemViewModel.bothIconsTab)
        ]

        for (description, viewModel) in tabs {
            let label = UILabel()
            label.text = description
            label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            label.textColor = .secondaryLabel
            stackView.addArrangedSubview(label)
            
            let tabView = MarketGroupTabItemView(viewModel: viewModel)
            stackView.addArrangedSubview(tabView)
        }

        vc.view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return vc
    }
}

#endif
