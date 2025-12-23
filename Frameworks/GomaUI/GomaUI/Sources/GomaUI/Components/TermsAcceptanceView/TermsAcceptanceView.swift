import Foundation
import UIKit
import Combine
import SwiftUI

public final class TermsAcceptanceView: UIView {
    
    // MARK: - UI Components
    private lazy var errorLabel: UILabel = {
        // Error label setup
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = .systemRed
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private lazy var checkboxButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 2
        button.layer.borderColor = StyleProvider.Color.textSecondary.cgColor
        button.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        if let customLogo = UIImage(named: "check_icon") {
            imageView.image = customLogo.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = StyleProvider.Color.allWhite
        }
        else {
            imageView.image = UIImage(systemName: "checkmark")?.withTintColor(StyleProvider.Color.allWhite, renderingMode: .alwaysOriginal)
        }
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var highlightedTextView: HighlightedTextView = {
        let textView = HighlightedTextView(viewModel: viewModel.highlightedTextViewModel)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = 12
        return stackView
    }()
    
    // MARK: - Properties
    private let viewModel: TermsAcceptanceViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    public var onCheckboxToggled: ((Bool) -> Void) = { _ in }
    public var onTermsLinkTapped: (() -> Void) = {}
    public var onPrivacyLinkTapped: (() -> Void) = {}
    public var onCookiesLinkTapped: (() -> Void) = {}
    
    // MARK: - Initialization
    public init(viewModel: TermsAcceptanceViewModelProtocol = MockTermsAcceptanceViewModel.defaultMock) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupBindings()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = MockTermsAcceptanceViewModel.defaultMock
        super.init(coder: coder)
        setupViews()
        setupBindings()
        setupGestures()
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        backgroundColor = .clear
        
        // Setup checkbox container
        checkboxButton.addSubview(checkmarkImageView)
        
        // Add to stack view
        containerStackView.addArrangedSubview(checkboxButton)
        containerStackView.addArrangedSubview(highlightedTextView)
        addSubview(errorLabel)
        addSubview(containerStackView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container stack view
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            errorLabel.topAnchor.constraint(equalTo: containerStackView.bottomAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: containerStackView.leadingAnchor, constant: 40),
            errorLabel.trailingAnchor.constraint(equalTo: containerStackView.trailingAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Checkbox button
            checkboxButton.widthAnchor.constraint(equalToConstant: 24),
            checkboxButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Checkmark image view
            checkmarkImageView.centerXAnchor.constraint(equalTo: checkboxButton.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: checkboxButton.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 16),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 16)
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
    
    private func setupGestures() {
        // Add tap gesture to highlighted text view to detect link taps
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textViewTapped(_:)))
        highlightedTextView.addGestureRecognizer(tapGesture)
        highlightedTextView.isUserInteractionEnabled = true
    }
    
    private func configure(with data: TermsAcceptanceData) {
        updateCheckboxAppearance(isChecked: data.isAccepted)
    }
    
    private func updateCheckboxAppearance(isChecked: Bool) {
        if isChecked {
            checkboxButton.backgroundColor = StyleProvider.Color.highlightPrimary
            checkboxButton.layer.borderColor = StyleProvider.Color.highlightPrimary.cgColor
            checkmarkImageView.isHidden = false
        } else {
            checkboxButton.backgroundColor = .clear
            checkboxButton.layer.borderColor = StyleProvider.Color.textSecondary.cgColor
            checkmarkImageView.isHidden = true
        }
    }
    
    // MARK: - Actions
    @objc private func checkboxTapped() {
        let currentData = viewModel.data
        let newState = !currentData.isAccepted
        
        let updatedData = TermsAcceptanceData(
            id: currentData.id,
            fullText: currentData.fullText,
            termsText: currentData.termsText,
            privacyText: currentData.privacyText,
            cookiesText: currentData.cookiesText,
            isAccepted: newState
        )
        
        viewModel.configure(with: updatedData)
        onCheckboxToggled(newState)
    }
    
    @objc private func textViewTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: highlightedTextView)
        let data = viewModel.data
        
        // Check if tap is on "Terms and Conditions"
        if isLocationInText(location, text: data.termsText, in: highlightedTextView) {
            print("Terms tapped!")
            onTermsLinkTapped()
        }
        // Check if tap is on "Privacy Policy"
        else if isLocationInText(location, text: data.privacyText, in: highlightedTextView) {
            print("Privacy tapped!")
            onPrivacyLinkTapped()
        }
        // Check if tap is on "Cookies"
        else if let cookiesText = data.cookiesText ,
                isLocationInText(location, text: cookiesText, in: highlightedTextView) {
            print("Cookies tapped!")
            onCookiesLinkTapped()
        }
    }
    
    private func isLocationInText(_ location: CGPoint, text: String, in textView: UIView) -> Bool {
        guard let highlightedTextView = textView as? HighlightedTextView,
              let label = highlightedTextView.subviews.first(where: { $0 is UILabel }) as? UILabel,
              let attributedText = label.attributedText else {
            return false
        }
        
        // Create text storage and layout manager
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: label.bounds.size)
        
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        // Configure text container
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        
        // Get character index at tap location
        let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // Check if character index falls within any range of the target text
        let ranges = HighlightedTextView.findRanges(of: text, in: viewModel.data.fullText)
        
        for range in ranges {
            if NSLocationInRange(characterIndex, range) {
                return true
            }
        }
        
        return false
    }
}

extension TermsAcceptanceView {
    public func showError(_ hasError: Bool) {
        errorLabel.text = hasError ? LocalizationProvider.string("required_field") : ""
        errorLabel.isHidden = !hasError
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("All States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        // 1. TITLE LABEL
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "TermsAcceptanceView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center

        // 2. VERTICAL STACK with ALL states
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // 3. ADD ALL COMPONENT INSTANCES
        let uncheckedView = TermsAcceptanceView(viewModel: MockTermsAcceptanceViewModel.defaultMock)
        uncheckedView.translatesAutoresizingMaskIntoConstraints = false

        let acceptedView = TermsAcceptanceView(viewModel: MockTermsAcceptanceViewModel.acceptedMock)
        acceptedView.translatesAutoresizingMaskIntoConstraints = false

        let shortTextView = TermsAcceptanceView(viewModel: MockTermsAcceptanceViewModel.shortTextMock)
        shortTextView.translatesAutoresizingMaskIntoConstraints = false

        // Add all states to stack
        stackView.addArrangedSubview(uncheckedView)
        stackView.addArrangedSubview(acceptedView)
        stackView.addArrangedSubview(shortTextView)

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
