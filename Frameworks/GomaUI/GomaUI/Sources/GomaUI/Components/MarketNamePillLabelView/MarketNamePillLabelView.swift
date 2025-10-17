import UIKit
import Combine
import SwiftUI

final public class MarketNamePillLabelView: UIView {
    
    // MARK: - UI Components
    private lazy var borderView = Self.createBorderView()
    private lazy var fadingLineView: FadingView = Self.createFadingLineView()
    private lazy var textLabel = Self.createTextLabel()
    
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: MarketNamePillLabelViewModelProtocol
    private var lineWidthConstraint: NSLayoutConstraint?
    
    // MARK: - Public Properties
    public var onInteraction: (() -> Void) = { }
    
    // MARK: - Initialization
    public init(viewModel: MarketNamePillLabelViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ViewCode
extension MarketNamePillLabelView {
    private func setupSubviews() {
        buildViewHierarchy()
        setupConstraints()
        setupAdditionalConfiguration()
    }
    
    private func buildViewHierarchy() {
        addSubview(borderView)
        addSubview(fadingLineView)
        borderView.addSubview(textLabel)
    }
    
    private func setupConstraints() {
        lineWidthConstraint = fadingLineView.widthAnchor.constraint(equalToConstant: 20)
        
        NSLayoutConstraint.activate([
            // Border view (pill container)
            borderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1),
            borderView.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            borderView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            borderView.trailingAnchor.constraint(equalTo: fadingLineView.leadingAnchor),
            
            // Fading line
            lineWidthConstraint!,
            fadingLineView.heightAnchor.constraint(equalToConstant: 1.2),
            fadingLineView.centerYAnchor.constraint(equalTo: borderView.centerYAnchor),
            fadingLineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // Text label
            textLabel.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 2),
            textLabel.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -2),
            textLabel.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 6),
            textLabel.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -6)
        ])
    }
    
    private func setupAdditionalConfiguration() {
        backgroundColor = .clear
        
        // Add tap gesture for interactive pills
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    private func setupBindings() {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(state: displayState)
            }
            .store(in: &cancellables)
    }
    
    private func render(state: MarketNamePillDisplayState) {
        updateText(state.pillData.text)
        updateStyle(state.pillData.style)
        updateInteractiveState(state.pillData.isInteractive)
    }
    
    private func updateText(_ text: String) {
        textLabel.text = text
    }
    
    private func updateStyle(_ style: MarketNamePillStyle) {
        switch style {
        case .standard:
            applyStandardStyle()
        case .highlighted:
            applyHighlightedStyle()
        case .disabled:
            applyDisabledStyle()
        case .custom(let borderColor, let textColor, let backgroundColor):
            applyCustomStyle(borderColor: borderColor, textColor: textColor, backgroundColor: backgroundColor)
        }
    }

    private func updateInteractiveState(_ isInteractive: Bool) {
        isUserInteractionEnabled = isInteractive
        if isInteractive {
            addHoverEffect()
        } else {
            removeHoverEffect()
        }
    }
    
    
    @objc private func handleTap() {
        viewModel.handleInteraction()
        onInteraction()
        
        // Add subtle tap animation
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
    }
    
    // MARK: - Style Application Methods
    private func applyStandardStyle() {
        borderView.layer.borderColor = StyleProvider.Color.highlightPrimary.cgColor
        borderView.backgroundColor = .clear
        textLabel.textColor = StyleProvider.Color.highlightPrimary
        fadingLineView.backgroundColor = StyleProvider.Color.highlightPrimary
    }
    
    private func applyHighlightedStyle() {
        borderView.layer.borderColor = StyleProvider.Color.highlightPrimary.cgColor
        borderView.backgroundColor = StyleProvider.Color.highlightPrimary.withAlphaComponent(0.1)
        textLabel.textColor = StyleProvider.Color.highlightPrimary
        fadingLineView.backgroundColor = StyleProvider.Color.highlightPrimary
    }
    
    private func applyDisabledStyle() {
        borderView.layer.borderColor = StyleProvider.Color.separatorLineSecondary.withAlphaComponent(0.5).cgColor
        borderView.backgroundColor = .clear
        textLabel.textColor = StyleProvider.Color.textSecondary.withAlphaComponent(0.5)
        fadingLineView.backgroundColor = StyleProvider.Color.separatorLineSecondary.withAlphaComponent(0.5)
    }
    
    private func applyCustomStyle(borderColor: UIColor, textColor: UIColor, backgroundColor: UIColor?) {
        borderView.layer.borderColor = borderColor.cgColor
        borderView.backgroundColor = backgroundColor ?? .clear
        textLabel.textColor = textColor
        fadingLineView.backgroundColor = borderColor
    }
    
    private func addHoverEffect() {
        // Add subtle shadow for interactive state
        layer.shadowColor = StyleProvider.Color.shadow.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.1
    }
    
    private func removeHoverEffect() {
        layer.shadowOpacity = 0
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        borderView.layer.cornerRadius = borderView.bounds.height / 2
    }

}

// MARK: - UI Elements Factory
extension MarketNamePillLabelView {
    private static func createBorderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.borderWidth = 1.2
        return view
    }
    
    private static func createFadingLineView() -> FadingView {
        let fadingView = FadingView()
        fadingView.translatesAutoresizingMaskIntoConstraints = false
        fadingView.colors = [.black, .black, .clear]
        fadingView.startPoint = CGPoint(x: 0.0, y: 0.5)
        fadingView.endPoint = CGPoint(x: 1.0, y: 0.5)
        fadingView.fadeLocations = [0.0, 0.15, 1.0]
        return fadingView
    }
    
    private static func createTextLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.font = StyleProvider.fontWith(type: .medium, size: 10)
        label.numberOfLines = 1
        return label
    }
    
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("MarketNamePillLabelView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "MarketNamePillLabelView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Standard Pill
        let standardView = MarketNamePillLabelView(viewModel: MockMarketNamePillLabelViewModel.standardPill)
        standardView.translatesAutoresizingMaskIntoConstraints = false

        // Highlighted Pill
        let highlightedView = MarketNamePillLabelView(viewModel: MockMarketNamePillLabelViewModel.highlightedPill)
        highlightedView.translatesAutoresizingMaskIntoConstraints = false

        // Disabled Pill
        let disabledView = MarketNamePillLabelView(viewModel: MockMarketNamePillLabelViewModel.disabledPill)
        disabledView.translatesAutoresizingMaskIntoConstraints = false

        // Interactive Pill
        let interactiveView = MarketNamePillLabelView(viewModel: MockMarketNamePillLabelViewModel.interactivePill)
        interactiveView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(standardView)
        stackView.addArrangedSubview(highlightedView)
        stackView.addArrangedSubview(disabledView)
        stackView.addArrangedSubview(interactiveView)

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
