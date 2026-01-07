import UIKit
import Combine
import SwiftUI


public final class CapsuleView: UIView {
    
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private var customContentView: UIView?
    
    // MARK: - Properties
    private let viewModel: CapsuleViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // Dynamic constraints for padding
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    private var minimumHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Public Properties
    public var onTapped: (() -> Void) = { }
    
    // MARK: - Initialization
    public init(viewModel: CapsuleViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupBindings()
    }
    
    // Convenience initializer for simple text capsules
    public convenience init(
        text: String,
        backgroundColor: UIColor? = nil,
        textColor: UIColor? = nil,
        font: UIFont? = nil,
        horizontalPadding: CGFloat = 12.0,
        verticalPadding: CGFloat = 4.0
    ) {
        let data = CapsuleData(
            text: text,
            backgroundColor: backgroundColor,
            textColor: textColor,
            font: font,
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding
        )
        let mockViewModel = MockCapsuleViewModel(data: data)
        self.init(viewModel: mockViewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        // Create perfect capsule shape
        containerView.layer.cornerRadius = containerView.bounds.height / 2
    }
    
    // MARK: - Setup
    private func setupViews() {
        addSubview(containerView)
        containerView.addSubview(label)
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container fills this view
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Dynamic padding constraints for label
        leadingConstraint = label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
        trailingConstraint = label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        topConstraint = label.topAnchor.constraint(equalTo: containerView.topAnchor)
        bottomConstraint = label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        
        NSLayoutConstraint.activate([
            leadingConstraint,
            trailingConstraint,
            topConstraint,
            bottomConstraint
        ])
    }
    
    private func setupBindings() {
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.configure(with: data)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Configuration
    private func configure(with data: CapsuleData) {
        // Configure text and visibility
        if let text = data.text, !text.isEmpty {
            label.text = text
            label.isHidden = false
            customContentView?.isHidden = true
        } else {
            label.isHidden = true
        }
        
        // Configure styling
        containerView.backgroundColor = data.backgroundColor ?? StyleProvider.Color.highlightSecondary
        label.textColor = data.textColor ?? StyleProvider.Color.buttonTextPrimary
        label.font = data.font ?? StyleProvider.fontWith(type: .bold, size: 10)
        
        // Update padding constraints
        leadingConstraint.constant = data.horizontalPadding
        trailingConstraint.constant = -data.horizontalPadding
        topConstraint.constant = data.verticalPadding
        bottomConstraint.constant = -data.verticalPadding
        
        // Configure minimum height
        if let minHeight = data.minimumHeight {
            if minimumHeightConstraint == nil {
                minimumHeightConstraint = containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight)
                minimumHeightConstraint?.isActive = true
            } else {
                minimumHeightConstraint?.constant = minHeight
            }
        } else {
            minimumHeightConstraint?.isActive = false
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: - Custom Content
    public func setCustomContent(_ contentView: UIView) {
        // Remove existing custom content
        customContentView?.removeFromSuperview()
        
        // Hide label
        label.isHidden = true
        
        // Add new custom content
        customContentView = contentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(contentView)
        
        // Apply same padding constraints to custom content
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: viewModel.data.horizontalPadding),
            contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -viewModel.data.horizontalPadding),
            contentView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: viewModel.data.verticalPadding),
            contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -viewModel.data.verticalPadding)
        ])
        
        setNeedsLayout()
    }
    
    // MARK: - Actions
    @objc private func handleTap() {
        onTapped()
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

#Preview("All States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Live Badge
        let liveBadgeView = CapsuleView(viewModel: MockCapsuleViewModel.liveBadge)
        liveBadgeView.translatesAutoresizingMaskIntoConstraints = false

        // Count Badge
        let countBadgeView = CapsuleView(viewModel: MockCapsuleViewModel.countBadge)
        countBadgeView.translatesAutoresizingMaskIntoConstraints = false

        // Tag Style
        let tagStyleView = CapsuleView(viewModel: MockCapsuleViewModel.tagStyle)
        tagStyleView.translatesAutoresizingMaskIntoConstraints = false

        // Convenience Init - Custom Purple
        let customView = CapsuleView(
            text: LocalizationProvider.string("custom"),
            backgroundColor: .systemPurple,
            textColor: .white
        )
        customView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(liveBadgeView)
        stackView.addArrangedSubview(countBadgeView)
        stackView.addArrangedSubview(tagStyleView)
        stackView.addArrangedSubview(customView)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

#endif
