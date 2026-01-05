import UIKit
import Combine
import SwiftUI

/// A lightweight search input with a leading magnifying-glass icon and a trailing clear button.
/// Uses StyleProvider for all colors and fonts.
public final class SearchView: UIView {

    // MARK: Private properties
    private let viewModel: SearchViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var outerContainerView: UIView = Self.createOuterContainerView()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var stackView: UIStackView = Self.createStackView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var textField: UITextField = Self.createTextField()
    private lazy var clearButton: UIButton = Self.createClearButton()

    // Layout
    private enum Layout {
        static let height: CGFloat = 40
        static let horizontalPadding: CGFloat = 12
        static let spacing: CGFloat = 8
        static let cornerRadius: CGFloat = 4
        static let iconSize: CGFloat = 18
        static let clearSize: CGFloat = 18
    }

    // MARK: - Init
    public init(viewModel: SearchViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.commonInit()
        self.setupBindings()
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func commonInit() {
        self.setupSubviews()
        self.setupWithTheme()
        self.textField.delegate = self
    }

    // MARK: - Theme
    private func setupWithTheme() {
        self.outerContainerView.backgroundColor = StyleProvider.Color.inputBackgroundSecondary
        self.containerView.backgroundColor = StyleProvider.Color.inputBackground
        self.containerView.layer.cornerRadius = Layout.cornerRadius
        self.containerView.layer.masksToBounds = true
        self.textField.textColor = StyleProvider.Color.textPrimary
        self.iconImageView.tintColor = StyleProvider.Color.highlightPrimary
        self.clearButton.tintColor = StyleProvider.Color.highlightPrimary
    }

    // MARK: - Subviews
    private func setupSubviews() {
        self.addSubview(self.outerContainerView)
        self.outerContainerView.addSubview(self.containerView)
        self.containerView.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.iconImageView)
        self.stackView.addArrangedSubview(self.textField)
        self.stackView.addArrangedSubview(self.clearButton)

        NSLayoutConstraint.activate([
            self.outerContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.outerContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.outerContainerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.outerContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.containerView.leadingAnchor.constraint(equalTo: self.outerContainerView.leadingAnchor, constant: Layout.spacing),
            self.containerView.trailingAnchor.constraint(equalTo: self.outerContainerView.trailingAnchor, constant: -Layout.spacing),
            self.containerView.topAnchor.constraint(equalTo: self.outerContainerView.topAnchor, constant: Layout.spacing),
            self.containerView.bottomAnchor.constraint(equalTo: self.outerContainerView.bottomAnchor, constant: -Layout.spacing),
            self.containerView.heightAnchor.constraint(equalToConstant: Layout.height),

            self.stackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: Layout.horizontalPadding),
            self.stackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -Layout.horizontalPadding),
            self.stackView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

            self.iconImageView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),

            self.clearButton.widthAnchor.constraint(equalToConstant: Layout.clearSize),
            self.clearButton.heightAnchor.constraint(equalTo: self.clearButton.widthAnchor)
        ])
    }
    
    private static func createOuterContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Layout.spacing
        return stackView
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        if let customImage = UIImage(named: "search_icon") {
            imageView.image = customImage
        }
        else if let systemImage = UIImage(systemName: "magnifyingglass") {
            imageView.image = systemImage
        }
        return imageView
    }

    private static func createTextField() -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = StyleProvider.fontWith(type: .regular, size: 14)
        textField.clearButtonMode = .never
        textField.borderStyle = .none
        textField.returnKeyType = .search
        return textField
    }

    private static func createClearButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        if let customImage = UIImage(named: "cancel_search_icon") {
            button.setImage(customImage, for: .normal)
        }
        else if let systemImage = UIImage(systemName: "xmark") {
            button.setImage(systemImage, for: .normal)
        }
        return button
    }

    // MARK: - Bindings
    private func setupBindings() {
        // Text field events
        self.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        self.textField.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        self.textField.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)

        self.clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)

        // ViewModel → View
        self.viewModel.placeholderTextPublisher
            .sink { [weak self] placeholder in
                guard let self = self else { return }
                self.textField.attributedPlaceholder = self.buildAttributedPlaceholder(from: placeholder)
            }
            .store(in: &cancellables)

        self.viewModel.attributedPlaceholderPublisher
            .sink { [weak self] attributed in
                guard let self = self else { return }
                if let attributed = attributed {
                    self.textField.attributedPlaceholder = attributed
                }
            }
            .store(in: &cancellables)

        self.viewModel.textPublisher
            .sink { [weak self] text in
                guard let self = self else { return }
                if self.textField.text != text { self.textField.text = text }
            }
            .store(in: &cancellables)

        self.viewModel.isClearButtonVisiblePublisher
            .sink { [weak self] visible in
                self?.clearButton.isHidden = !visible
            }
            .store(in: &cancellables)

        self.viewModel.isEnabledPublisher
            .sink { [weak self] enabled in
                self?.textField.isEnabled = enabled
                self?.alpha = enabled ? 1.0 : 0.5
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions
    @objc private func textDidChange() {
        self.viewModel.updateText(self.textField.text ?? "")
    }

    @objc private func editingDidBegin() {
        self.viewModel.setFocused(true)
    }

    @objc private func editingDidEnd() {
        self.viewModel.setFocused(false)
    }

    @objc private func clearTapped() {
        self.viewModel.clearText()
    }
}

// MARK: - UITextFieldDelegate
extension SearchView: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Placeholder Styling
private extension SearchView {
    /// Builds an attributed placeholder with mixed font sizes and weights.
    /// Default rule: everything regular 16pt, emphasize the last word (if any) with semibold 16pt.
    func buildAttributedPlaceholder(from text: String) -> NSAttributedString {
        let regularFont = StyleProvider.fontWith(type: .regular, size: 14)
        let boldFont = StyleProvider.fontWith(type: .bold, size: 14)
        let color = StyleProvider.Color.inputText

        let fullRange = NSRange(location: 0, length: (text as NSString).length)
        let mutable = NSMutableAttributedString(string: text)
        mutable.addAttributes([
            .font: regularFont,
            .foregroundColor: color
        ], range: fullRange)

        // Emphasize the last word (commonly the brand, e.g., "Sportsbook")
        if let lastSpace = text.range(of: " ", options: .backwards) {
            let lastWordStart = text.distance(from: text.startIndex, to: lastSpace.upperBound)
            let lastWordLength = text.distance(from: lastSpace.upperBound, to: text.endIndex)
            if lastWordLength > 0 {
                let boldRange = NSRange(location: lastWordStart, length: lastWordLength)
                mutable.addAttributes([
                    .font: boldFont
                ], range: boldRange)
            }
        }

        return mutable
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
@available(iOS 17.0, *)
#Preview("SearchView") {
    PreviewUIViewController {
        let view = SearchView(viewModel: MockSearchViewModel.default)
        view.translatesAutoresizingMaskIntoConstraints = false
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            view.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        return vc
    }
}
#endif
