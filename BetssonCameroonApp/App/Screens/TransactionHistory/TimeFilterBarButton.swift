
import UIKit
import ServicesProvider
import GomaUI

final class TimeFilterBarButton: UIButton {

    // MARK: - Properties

    private let filter: TransactionDateFilter
    private let title: String

    private var isFilterSelected: Bool = false {
        didSet {
            updateAppearance()
        }
    }

    // MARK: - Initialization

    init(filter: TransactionDateFilter, title: String) {
        self.filter = filter
        self.title = title
        super.init(frame: .zero)
        setupButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func setSelected(_ selected: Bool) {
        isFilterSelected = selected
    }

    var filterValue: TransactionDateFilter {
        return filter
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
            backgroundColor = UIColor.white
            setTitleColor(StyleProvider.Color.highlightPrimary, for: .normal)
        } else {
            backgroundColor = UIColor.clear
            setTitleColor(StyleProvider.Color.textSecondary, for: .normal)
        }
    }

    // MARK: - Touch Handling

    override var isHighlighted: Bool {
        didSet {
            // Add subtle feedback on touch
            alpha = isHighlighted ? 0.7 : 1.0
        }
    }
}
