import UIKit
import SwiftUI

/// A simple, reusable navigation bar with back button and optional title.
///
/// This component provides a clean navigation bar suitable for screens that need
/// basic back navigation with an optional centered title. It replaces hardcoded
/// back button implementations with a consistent, protocol-driven approach.
///
/// ## Features
/// - Back button with icon (chevron.left) and optional text
/// - Optional centered title
/// - Configurable visibility of back button
/// - Callback-based navigation (no Combine complexity)
/// - Immutable after init (simple, no reactivity)
/// - Consistent styling via StyleProvider
///
/// ## Usage
/// ```swift
/// let viewModel = SimpleNavigationBarViewModel(
///     title: "Transaction History",
///     onBackTapped: { [weak self] in
///         self?.coordinator?.popViewController()
///     }
/// )
/// let navBar = SimpleNavigationBarView(viewModel: viewModel)
/// view.addSubview(navBar)
///
/// NSLayoutConstraint.activate([
///     navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
///     navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
///     navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
/// ])
/// ```
///
/// ## Component Structure
/// ```
/// SimpleNavigationBarView (56pt height)
/// ├── backButtonContainer (UIView with tap gesture)
/// │   ├── backIconImageView (chevron.left, 20x20pt)
/// │   └── backLabel (optional text, 12pt bold)
/// └── titleLabel (centered, 16pt bold, optional)
/// ```
public final class SimpleNavigationBarView: UIView {

    // MARK: - UI Components

    /// Container view for the back button (icon + optional text).
    ///
    /// **Purpose**: Provides a larger touch target than individual button.
    /// User can tap anywhere in the "← Back" area.
    private lazy var backButtonContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.backgroundColor = .clear
        return view
    }()

    /// Back icon (chevron pointing left).
    private lazy var backIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "chevron.left")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    /// Optional back button text label (e.g., "Back").
    ///
    /// Hidden if `viewModel.backButtonText` is `nil`.
    private lazy var backLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 12)
        label.textAlignment = .left
        return label
    }()

    /// Optional centered title label.
    ///
    /// Hidden if `viewModel.title` is `nil`.
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    /// Bottom separator line.
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Properties

    private let viewModel: SimpleNavigationBarViewModelProtocol
    private var customization: SimpleNavigationBarStyle?

    // MARK: - Constants

    private enum Constants {
        static let height: CGFloat = 56.0
        static let backButtonContainerHeight: CGFloat = 44.0  // iOS HIG minimum touch target
        static let backIconSize: CGFloat = 20.0
        static let backIconLeading: CGFloat = 16.0
        static let backLabelSpacing: CGFloat = 6.0
        static let backLabelTrailing: CGFloat = 8.0  // Trailing padding for back label
        static let titleHorizontalPadding: CGFloat = 16.0
        static let separatorHeight: CGFloat = 1.0
    }

    // MARK: - Initialization

    /// Creates a simple navigation bar view.
    ///
    /// - Parameter viewModel: View model conforming to `SimpleNavigationBarViewModelProtocol`.
    ///                        Provides configuration data and navigation callback.
    public init(viewModel: SimpleNavigationBarViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    /// Sets optional style customization for the navigation bar.
    ///
    /// If not set, defaults to StyleProvider colors. Call this method
    /// before or after adding the view to the hierarchy.
    ///
    /// - Parameter style: Custom style or `nil` to use defaults
    public func setCustomization(_ style: SimpleNavigationBarStyle?) {
        self.customization = style
        applyCurrentStyle()
    }

    // MARK: - Setup

    private func setupViews() {
        self.translatesAutoresizingMaskIntoConstraints = false

        // Add subviews to hierarchy
        addSubview(backButtonContainer)
        backButtonContainer.addSubview(backIconImageView)
        backButtonContainer.addSubview(backLabel)
        addSubview(titleLabel)
        addSubview(separatorView)

        // Configure content priorities for proper layout behavior
        configureContentPriorities()

        // Add tap gesture to container (not individual icon/label)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackTap))
        backButtonContainer.addGestureRecognizer(tapGesture)

        setupConstraints()
    }

    /// Configures content compression and hugging priorities.
    ///
    /// **Priority Hierarchy**:
    /// - Back label: MUST be fully visible (never compress)
    /// - Title: Should compress/truncate when space is tight
    private func configureContentPriorities() {
        // Back label MUST be fully visible - never compress
        backLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        backLabel.setContentHuggingPriority(.required, for: .horizontal)

        // Title should compress/truncate before back label
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private func setupConstraints() {
        // Title centering constraint (breakable when space is tight)
        let titleCenterX = titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        titleCenterX.priority = .defaultHigh  // Priority: 750 - can break for long titles

        // Title leading constraint (required - must respect back button)
        let titleLeading = titleLabel.leadingAnchor.constraint(
            greaterThanOrEqualTo: backButtonContainer.trailingAnchor,
            constant: Constants.titleHorizontalPadding
        )
        titleLeading.priority = .required  // Priority: 1000 - never breaks

        NSLayoutConstraint.activate([
            // Self height
            heightAnchor.constraint(equalToConstant: Constants.height),

            // Back button container (left side, sizes to fit content)
            backButtonContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            backButtonContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButtonContainer.heightAnchor.constraint(equalToConstant: Constants.backButtonContainerHeight),

            // Back icon (inside container)
            backIconImageView.leadingAnchor.constraint(equalTo: backButtonContainer.leadingAnchor, constant: Constants.backIconLeading),
            backIconImageView.centerYAnchor.constraint(equalTo: backButtonContainer.centerYAnchor),
            backIconImageView.widthAnchor.constraint(equalToConstant: Constants.backIconSize),
            backIconImageView.heightAnchor.constraint(equalToConstant: Constants.backIconSize),

            // Back label (inside container, after icon, with trailing padding)
            backLabel.leadingAnchor.constraint(equalTo: backIconImageView.trailingAnchor, constant: Constants.backLabelSpacing),
            backLabel.centerYAnchor.constraint(equalTo: backButtonContainer.centerYAnchor),
            backLabel.trailingAnchor.constraint(equalTo: backButtonContainer.trailingAnchor, constant: -Constants.backLabelTrailing),

            // Title label (with explicit priorities for proper layout behavior)
            titleCenterX,      // Priority: 750 (breakable - shifts left when needed)
            titleLeading,      // Priority: 1000 (required - never overlaps back button)
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Constants.titleHorizontalPadding),

            // Separator line (bottom)
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: Constants.separatorHeight)
        ])
    }

    // MARK: - Configuration

    /// Configures the view based on ViewModel properties.
    ///
    /// Called once during initialization. The view is immutable after init.
    private func configure() {
        // Configure back button text
        if let backText = viewModel.backButtonText {
            backLabel.text = backText
            backLabel.isHidden = false
        } else {
            backLabel.isHidden = true
        }

        // Configure title
        if let title = viewModel.title {
            titleLabel.text = title
            titleLabel.isHidden = false
        } else {
            titleLabel.isHidden = true
        }

        // Configure back button visibility
        backButtonContainer.isHidden = !viewModel.showBackButton
        backIconImageView.isHidden = !viewModel.showBackButton

        // Apply style (custom or default)
        applyCurrentStyle()
    }

    /// Applies the current style customization (or default StyleProvider colors).
    ///
    /// This method is called both during initialization and when customization changes.
    private func applyCurrentStyle() {
        let style = customization ?? .defaultStyle()

        // Apply colors
        backgroundColor = style.backgroundColor
        backLabel.textColor = style.textColor
        titleLabel.textColor = style.textColor
        backIconImageView.tintColor = style.iconColor
        separatorView.backgroundColor = style.separatorColor
    }

    // MARK: - Actions

    /// Handles back button tap gesture.
    ///
    /// Delegates navigation to the ViewModel's callback.
    @objc private func handleBackTap() {
        viewModel.onBackTapped()
    }
}

// MARK: - SwiftUI Preview

#if DEBUG

@available(iOS 17.0, *)
#Preview("All Variants") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fill

        // 1. Icon only
        let nav1 = SimpleNavigationBarView(viewModel: MockSimpleNavigationBarViewModel.iconOnly)
        nav1.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(nav1)

        // 2. Icon + "Back" text
        let nav2 = SimpleNavigationBarView(viewModel: MockSimpleNavigationBarViewModel.withBackText)
        nav2.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(nav2)

        // 3. Icon + centered title
        let nav3 = SimpleNavigationBarView(viewModel: MockSimpleNavigationBarViewModel.withTitle)
        nav3.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(nav3)

        // 4. Icon + text + title
        let nav4 = SimpleNavigationBarView(viewModel: MockSimpleNavigationBarViewModel.withBackTextAndTitle)
        nav4.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(nav4)

        // 5. Title only (no back button)
        let nav5 = SimpleNavigationBarView(viewModel: MockSimpleNavigationBarViewModel.titleOnly)
        nav5.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(nav5)

        // 6. Long title (truncation test)
        let nav6 = SimpleNavigationBarView(viewModel: MockSimpleNavigationBarViewModel.longTitle)
        nav6.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(nav6)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Dark Mode") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        vc.overrideUserInterfaceStyle = .dark

        let nav = SimpleNavigationBarView(
            viewModel: MockSimpleNavigationBarViewModel.withBackTextAndTitle
        )
        nav.translatesAutoresizingMaskIntoConstraints = false

        vc.view.addSubview(nav)

        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])

        return vc
    }
}

#endif
