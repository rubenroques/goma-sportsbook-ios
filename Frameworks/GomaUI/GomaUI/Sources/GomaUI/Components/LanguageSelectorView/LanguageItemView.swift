import UIKit
import SwiftUI

/// Individual language selection row with flag, name, and radio button
internal final class LanguageItemView: UIView {

    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var flagImageView: UIImageView = Self.createFlagImageView()
    private lazy var nameLabel: UILabel = Self.createNameLabel()
    private lazy var radioButton: UIView = Self.createRadioButton()
    private lazy var radioButtonInnerDot: UIView = Self.createRadioButtonInnerDot()
    private lazy var leftStackView: UIStackView = Self.createLeftStackView()
    private lazy var mainStackView: UIStackView = Self.createMainStackView()
    private lazy var separatorView: UIView = Self.createSeparatorView()

    // MARK: - Properties
    private var language: LanguageModel?
    private var imageResolver: LanguageFlagImageResolver?
    private var onTapCallback: ((LanguageModel) -> Void)?
    private var isLastItem: Bool = false
    
    // MARK: - Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupWithTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        setupWithTheme()
    }
    
    func commonInit() {
        setupSubviews()
        setupActions()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update radio button appearance
        radioButton.layer.cornerRadius = 10 // 20px diameter = 10px radius
        radioButtonInnerDot.layer.cornerRadius = 6 // 12px diameter = 6px radius
    }
    
    func setupWithTheme() {
        backgroundColor = .clear
        containerView.backgroundColor = StyleProvider.Color.backgroundTertiary
        nameLabel.textColor = StyleProvider.Color.textPrimary
        separatorView.backgroundColor = StyleProvider.Color.separatorLine
        
        // Radio button styling
        radioButton.backgroundColor = StyleProvider.Color.backgroundTertiary
        radioButton.layer.borderWidth = 2
        radioButton.layer.borderColor = StyleProvider.Color.iconSecondary.cgColor
        
        radioButtonInnerDot.backgroundColor = StyleProvider.Color.backgroundTertiary
    }
    
    // MARK: Functions
    func configure(
        with language: LanguageModel,
        imageResolver: LanguageFlagImageResolver?,
        isLastItem: Bool = false,
        onTap: @escaping (LanguageModel) -> Void
    ) {
        self.language = language
        self.imageResolver = imageResolver
        self.isLastItem = isLastItem
        self.onTapCallback = onTap

        // Configure flag using imageResolver based on language id
        if let resolver = imageResolver, let flagImage = resolver.flagImage(for: language.id) {
            flagImageView.image = flagImage
        } else {
            // Fallback to globe SF Symbol
            flagImageView.image = UIImage(systemName: "globe")
            flagImageView.tintColor = StyleProvider.Color.iconSecondary
        }

        nameLabel.text = language.displayName

        // Update selection state
        updateSelectionState(language.isSelected)

        // Hide separator for last item
        separatorView.isHidden = isLastItem
    }
    
    private func updateSelectionState(_ isSelected: Bool) {
        if isSelected {
            // Selected state: orange border and fill with white dot
            radioButton.layer.borderColor = StyleProvider.Color.highlightPrimary.cgColor
            radioButton.backgroundColor = StyleProvider.Color.highlightPrimary
            radioButtonInnerDot.backgroundColor = StyleProvider.Color.backgroundTertiary
            radioButtonInnerDot.isHidden = false
        } else {
            // Unselected state: gray border, transparent background, no dot
            radioButton.layer.borderColor = StyleProvider.Color.iconSecondary.cgColor
            radioButton.backgroundColor = StyleProvider.Color.backgroundTertiary
            radioButtonInnerDot.isHidden = true
        }
    }
    
    // MARK: - Corner Radius Management
    
    enum CornerPosition {
        case top
        case bottom
        case all
        case none
    }
    
    func applyCornerRadius(position: CornerPosition) {
        switch position {
        case .top:
            containerView.layer.cornerRadius = 8
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .bottom:
            containerView.layer.cornerRadius = 8
            containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .all:
            containerView.layer.cornerRadius = 8
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .none:
            containerView.layer.cornerRadius = 0
            containerView.layer.maskedCorners = []
        }
    }
}

// MARK: - Subviews Initialization and Setup
extension LanguageItemView {
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createFlagImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }
    
    private static func createNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.numberOfLines = 1
        return label
    }
    
    private static func createRadioButton() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createRadioButtonInnerDot() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }
    
    private static func createLeftStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }
    
    private static func createMainStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }
    
    private static func createSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func setupSubviews() {
        addSubview(containerView)
        containerView.addSubview(mainStackView)
        containerView.addSubview(separatorView)
        
        // Setup radio button with inner dot
        radioButton.addSubview(radioButtonInnerDot)
        
        // Setup left stack (flag + name)
        leftStackView.addArrangedSubview(flagImageView)
        leftStackView.addArrangedSubview(nameLabel)
        
        // Setup main stack
        mainStackView.addArrangedSubview(leftStackView)
        mainStackView.addArrangedSubview(radioButton)
        
        // Set content priorities
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 56),
            
            // Main stack
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            mainStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Flag image
            flagImageView.widthAnchor.constraint(equalToConstant: 24),
            flagImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Radio button
            radioButton.widthAnchor.constraint(equalToConstant: 20),
            radioButton.heightAnchor.constraint(equalToConstant: 20),
            
            // Radio button inner dot
            radioButtonInnerDot.centerXAnchor.constraint(equalTo: radioButton.centerXAnchor),
            radioButtonInnerDot.centerYAnchor.constraint(equalTo: radioButton.centerYAnchor),
            radioButtonInnerDot.widthAnchor.constraint(equalToConstant: 12),
            radioButtonInnerDot.heightAnchor.constraint(equalToConstant: 12),
            
            // Separator
            separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        guard let language = language else { return }
        
        // Add tap feedback
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = CGAffineTransform.identity
            }
        }
        
        onTapCallback?(language)
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Language Item - Selected") {
    PreviewUIViewController {
        let vc = UIViewController()
        let selectedLanguage = LanguageModel.english.withSelection(true)
        let itemView = LanguageItemView()
        itemView.configure(
            with: selectedLanguage,
            imageResolver: nil,
            isLastItem: false
        ) { language in
            print("Selected: \(language.displayName)")
        }
        itemView.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        vc.view.addSubview(itemView)

        NSLayoutConstraint.activate([
            itemView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            itemView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            itemView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Language Item - Unselected") {
    PreviewUIViewController {
        let vc = UIViewController()
        let unselectedLanguage = LanguageModel.french.withSelection(false)
        let itemView = LanguageItemView()
        itemView.configure(
            with: unselectedLanguage,
            imageResolver: nil,
            isLastItem: true
        ) { language in
            print("Selected: \(language.displayName)")
        }
        itemView.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        vc.view.addSubview(itemView)

        NSLayoutConstraint.activate([
            itemView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            itemView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            itemView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

#endif
