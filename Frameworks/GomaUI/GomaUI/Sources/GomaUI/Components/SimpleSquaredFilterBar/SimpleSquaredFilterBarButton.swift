import UIKit

public final class SimpleSquaredFilterBarButton: UIButton {

    // MARK: - Properties

    public let filterId: String
    private let title: String

    private var isFilterSelected: Bool = false {
        didSet {
            updateAppearance()
        }
    }

    // MARK: - Initialization

    public init(filterId: String, title: String) {
        self.filterId = filterId
        self.title = title
        super.init(frame: .zero)
        setupButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    public func setSelected(_ selected: Bool) {
        isFilterSelected = selected
    }

    // MARK: - Private Methods

    private func setupButton() {
        translatesAutoresizingMaskIntoConstraints = false
        setTitle(title, for: .normal)
        titleLabel?.font = StyleProvider.fontWith(type: .medium, size: 14)
        layer.cornerRadius = 14

        // Set button dimensions
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 48),
            heightAnchor.constraint(equalToConstant: 40)
        ])

        updateAppearance()
    }

    private func updateAppearance() {
        if isFilterSelected {
            backgroundColor = StyleProvider.Color.backgroundPrimary
            setTitleColor(StyleProvider.Color.highlightPrimary, for: .normal)
        } else {
            backgroundColor = .clear
            setTitleColor(StyleProvider.Color.textSecondary, for: .normal)
        }
    }

    // MARK: - Touch Handling

    public override var isHighlighted: Bool {
        didSet {
            // Add subtle feedback on touch
            alpha = isHighlighted ? 0.7 : 1.0
        }
    }
}
