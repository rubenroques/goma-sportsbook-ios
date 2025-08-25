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
    
    // Main stack view
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 12
        return stackView
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
    
    // Label with link
    private lazy var labelWithLinkLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
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
        containerView.addSubview(mainStackView)
        
        // Add checkbox and label to main stack view
        mainStackView.addArrangedSubview(checkboxButton)
        mainStackView.addArrangedSubview(labelWithLinkLabel)
        
        // Add checkmark to checkbox
        checkboxButton.addSubview(checkmarkImageView)
        
        // Add tap gesture to text view
        labelWithLinkLabel.addGestureRecognizer(linkTapGesture)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Main stack view
            mainStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Checkbox button
            checkboxButton.widthAnchor.constraint(equalToConstant: 24),
            checkboxButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Checkmark image view
            checkmarkImageView.centerXAnchor.constraint(equalTo: checkboxButton.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: checkboxButton.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 12),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 12)
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
        
        // Update label text with link
        updateLabelWithLink(labelText: data.labelText, linkText: data.linkText)
        
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
    
    private func updateLabelWithLink(labelText: String, linkText: String) {
        let fullText = "\(labelText) \(linkText)"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Set base attributes
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: StyleProvider.fontWith(type: .regular, size: 12),
            .foregroundColor: StyleProvider.Color.textPrimary
        ]
        attributedString.addAttributes(baseAttributes, range: NSRange(location: 0, length: fullText.count))
        
        // Add link attributes
        let linkRange = NSRange(location: labelText.count + 1, length: linkText.count)
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .font: StyleProvider.fontWith(type: .regular, size: 12),
            .foregroundColor: StyleProvider.Color.textPrimary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        attributedString.addAttributes(linkAttributes, range: linkRange)
        
        labelWithLinkLabel.attributedText = attributedString
    }
    
    // MARK: - Actions
    @objc private func handleCheckboxTapped() {
        viewModel.onCheckboxTapped()
    }
    
    @objc private func handleLinkTap(_ gesture: UITapGestureRecognizer) {
        let label = labelWithLinkLabel
        let location = gesture.location(in: label)
        
        // Get the attributed text
        guard let attributedText = label.attributedText else { return }
        
        // Create text storage and layout manager for character index detection
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: label.bounds.size)
        
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        
        // Get character index at tap location
        let characterIndex = layoutManager.characterIndex(
            for: location,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // Check if the tap is on the link portion
        let labelText = viewModel.currentData.labelText
        let linkStartIndex = labelText.count + 1
        let linkEndIndex = linkStartIndex + viewModel.currentData.linkText.count
        
        if characterIndex >= linkStartIndex && characterIndex < linkEndIndex {
            viewModel.onLinkTapped()
        }
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Accepted") {
    PreviewUIView {
        OddsAcceptanceView(viewModel: MockOddsAcceptanceViewModel.acceptedMock())
    }
    .frame(height: 40)
    .padding()
}

@available(iOS 17.0, *)
#Preview("Not Accepted") {
    PreviewUIView {
        OddsAcceptanceView(viewModel: MockOddsAcceptanceViewModel.notAcceptedMock())
    }
    .frame(height: 40)
    .padding()
}

@available(iOS 17.0, *)
#Preview("Disabled") {
    PreviewUIView {
        OddsAcceptanceView(viewModel: MockOddsAcceptanceViewModel.disabledMock())
    }
    .frame(height: 40)
    .padding()
}

#endif 
