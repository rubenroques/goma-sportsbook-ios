import Foundation
import UIKit
import Combine
import SwiftUI

/// A view component that displays an odds acceptance checkbox with label and clickable link
public final class OddsAcceptanceView: UIView {
    
    // MARK: - Properties
    public var viewModel: OddsAcceptanceViewModelProtocol {
        didSet {
            // Clear old cancellables and re-setup bindings for new view model
            cancellables.removeAll()
            setupBindings()
        }
    }
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    // Container view
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    // Checkbox button
    private lazy var checkboxButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = StyleProvider.Color.backgroundBorder.cgColor
        button.addTarget(self, action: #selector(handleCheckboxTapped), for: .touchUpInside)
        return button
    }()
    
    // Checkmark image view
    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if let customLogo = UIImage(named: "check_icon") {
            imageView.image = customLogo.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = StyleProvider.Color.allWhite
        }
        else {
            imageView.image = UIImage(systemName: "checkmark")?.withTintColor(StyleProvider.Color.allWhite, renderingMode: .alwaysOriginal)
        }
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    // Title label
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 0
        return label
    }()
    
    // Label with link
    private lazy var labelWithLinkLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        return label
    }()
    
    // Tap gesture recognizer for link detection
    private lazy var linkTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleLinkTap))
        return gesture
    }()
    
    // MARK: - Initialization
    public init(viewModel: OddsAcceptanceViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        addSubview(containerView)
        
        // Add checkbox, title label, and link label to container
        containerView.addSubview(checkboxButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(labelWithLinkLabel)
        
        // Add checkmark to checkbox
        checkboxButton.addSubview(checkmarkImageView)
        
        // Add tap gesture to link label
        labelWithLinkLabel.addGestureRecognizer(linkTapGesture)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Checkbox button - anchored at left, aligned with top
            checkboxButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            checkboxButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 24),
            checkboxButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Checkmark image view - centered in checkbox
            checkmarkImageView.centerXAnchor.constraint(equalTo: checkboxButton.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: checkboxButton.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 12),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 12),
            
            // Title label - next to checkbox on the right
            titleLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            
            // Label with link - below checkbox and title label
            labelWithLinkLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            labelWithLinkLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            labelWithLinkLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            labelWithLinkLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
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
    private func render(data: OddsAcceptanceData) {
        // Update checkbox state
        updateCheckboxState(data.state)
        
        // Update title label
        titleLabel.text = data.labelText

        // Update link label
        updateLinkLabel(linkText: data.linkText, isLinkTappable: data.isLinkTappable)
        
        // Update enabled state
        alpha = data.isEnabled ? 1.0 : 0.5
        isUserInteractionEnabled = data.isEnabled
        checkboxButton.isEnabled = data.isEnabled
    }
    
    private func updateCheckboxState(_ state: OddsAcceptanceState) {
        switch state {
        case .accepted:
            checkboxButton.backgroundColor = StyleProvider.Color.highlightPrimary
            checkboxButton.layer.borderColor = StyleProvider.Color.highlightPrimary.cgColor
            checkmarkImageView.isHidden = false
        case .notAccepted:
            checkboxButton.backgroundColor = .clear
            checkboxButton.layer.borderColor = StyleProvider.Color.backgroundBorder.cgColor
            checkmarkImageView.isHidden = true
        }
    }
    
    private func updateLinkLabel(linkText: String, isLinkTappable: Bool) {
        let attributedString = NSMutableAttributedString(string: linkText)

        var linkAttributes: [NSAttributedString.Key: Any] = [
            .font: StyleProvider.fontWith(type: .regular, size: 12),
            .foregroundColor: StyleProvider.Color.textPrimary
        ]

        // Only add underline if link is tappable
        if isLinkTappable {
            linkAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }

        attributedString.addAttributes(linkAttributes, range: NSRange(location: 0, length: linkText.count))
        labelWithLinkLabel.attributedText = attributedString
        labelWithLinkLabel.isUserInteractionEnabled = isLinkTappable
    }
    
    // MARK: - Actions
    @objc private func handleCheckboxTapped() {
        viewModel.onCheckboxTapped()
    }
    
    @objc private func handleLinkTap(_ gesture: UITapGestureRecognizer) {
        // Since the entire labelWithLinkLabel is now the link, any tap triggers the action
        viewModel.onLinkTapped()
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

#Preview("OddsAcceptanceView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "OddsAcceptanceView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Accepted state
        let acceptedView = OddsAcceptanceView(viewModel: MockOddsAcceptanceViewModel.acceptedMock())
        acceptedView.translatesAutoresizingMaskIntoConstraints = false

        // Not Accepted state
        let notAcceptedView = OddsAcceptanceView(viewModel: MockOddsAcceptanceViewModel.notAcceptedMock())
        notAcceptedView.translatesAutoresizingMaskIntoConstraints = false

        // Disabled state
        let disabledView = OddsAcceptanceView(viewModel: MockOddsAcceptanceViewModel.disabledMock())
        disabledView.translatesAutoresizingMaskIntoConstraints = false

        // Tappable link state (for future use - shows underlined link)
        let tappableLinkView = OddsAcceptanceView(viewModel: MockOddsAcceptanceViewModel(state: .notAccepted, isLinkTappable: true))
        tappableLinkView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(acceptedView)
        stackView.addArrangedSubview(notAcceptedView)
        stackView.addArrangedSubview(disabledView)
        stackView.addArrangedSubview(tappableLinkView)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])

        return vc
    }
}

#endif 
