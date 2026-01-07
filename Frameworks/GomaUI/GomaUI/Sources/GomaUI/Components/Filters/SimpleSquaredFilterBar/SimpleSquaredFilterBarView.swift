import UIKit
import SwiftUI


public final class SimpleSquaredFilterBarView: UIView {

    // MARK: - Public Properties

    public var onFilterSelected: ((String) -> Void)?

    // MARK: - Private Properties

    private var data: SimpleSquaredFilterBarData = SimpleSquaredFilterBarData(items: [])
    private var buttons: [SimpleSquaredFilterBarButton] = []

    // MARK: - UI Components

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 0 // We'll handle spacing with equal distribution
        return stackView
    }()

    // MARK: - Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public init(data: SimpleSquaredFilterBarData) {
        super.init(frame: .zero)
        self.data = data
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Public Methods

    public func configure(with data: SimpleSquaredFilterBarData) {
        self.data = data
        recreateButtons()
        updateButtonStates()
    }

    public func setSelected(_ id: String) {
        let newData = SimpleSquaredFilterBarData(items: data.items, selectedId: id)
        configure(with: newData)
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = StyleProvider.Color.backgroundSecondary
        translatesAutoresizingMaskIntoConstraints = false

        setupViewHierarchy()
        setupConstraints()
        recreateButtons()
        updateButtonStates()
    }

    private func setupViewHierarchy() {
        addSubview(stackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Stack view constraints
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Self height constraint
            heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func recreateButtons() {
        // Clear existing buttons
        clearButtons()

        // Create new buttons
        for (filterId, title) in data.items {
            let button = SimpleSquaredFilterBarButton(filterId: filterId, title: title)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
    }

    private func clearButtons() {
        // Remove all arranged subviews
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        // Clear references
        buttons.removeAll()
    }

    private func updateButtonStates() {
        for button in buttons {
            let isSelected = button.filterId == data.selectedId
            button.setSelected(isSelected)
        }
    }

    // MARK: - Actions

    @objc private func buttonTapped(_ sender: UIButton) {
        guard let filterButton = sender as? SimpleSquaredFilterBarButton else { return }

        let selectedId = filterButton.filterId

        // Update internal state
        data = SimpleSquaredFilterBarData(items: data.items, selectedId: selectedId)
        updateButtonStates()

        // Notify callback
        onFilterSelected?(selectedId)
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

#Preview("Simple Squared Filter Bar - Time Filters") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let timeFilters = SimpleSquaredFilterBarData(
            items: [
                ("all", "All"),
                ("1d", "1D"),
                ("1w", "1W"),
                ("1m", "1M"),
                ("3m", "3M")
            ],
            selectedId: "all"
        )

        let filterBar = SimpleSquaredFilterBarView(data: timeFilters)
        filterBar.onFilterSelected = { filterId in
            print("Selected filter: \(filterId)")
        }

        vc.view.addSubview(filterBar)

        NSLayoutConstraint.activate([
            filterBar.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            filterBar.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            filterBar.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])

        return vc
    }
}

#Preview("Simple Squared Filter Bar - Status Filters") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let statusFilters = SimpleSquaredFilterBarData(
            items: [
                ("active", LocalizationProvider.string("active")),
                ("pending", LocalizationProvider.string("pending")),
                ("completed", LocalizationProvider.string("done")),
                ("failed", LocalizationProvider.string("failed"))
            ],
            selectedId: "active"
        )

        let filterBar = SimpleSquaredFilterBarView(data: statusFilters)
        filterBar.onFilterSelected = { filterId in
            print("Selected status: \(filterId)")
        }

        vc.view.addSubview(filterBar)

        NSLayoutConstraint.activate([
            filterBar.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            filterBar.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            filterBar.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])

        return vc
    }
}

#Preview("Simple Squared Filter Bar - Multiple States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill

        // Time filters - All selected
        let timeFilters1 = SimpleSquaredFilterBarData(
            items: [("all", "All"), ("1d", "1D"), ("1w", "1W"), ("1m", "1M"), ("3m", "3M")],
            selectedId: "all"
        )
        let filterBar1 = SimpleSquaredFilterBarView(data: timeFilters1)

        // Time filters - 1W selected
        let timeFilters2 = SimpleSquaredFilterBarData(
            items: [("all", "All"), ("1d", "1D"), ("1w", "1W"), ("1m", "1M"), ("3m", "3M")],
            selectedId: "1w"
        )
        let filterBar2 = SimpleSquaredFilterBarView(data: timeFilters2)

        // Priority filters
        let priorityFilters = SimpleSquaredFilterBarData(
            items: [("low", "Low"), ("med", "Medium"), ("high", "High"), ("urgent", "Urgent")],
            selectedId: "high"
        )
        let filterBar3 = SimpleSquaredFilterBarView(data: priorityFilters)

        stackView.addArrangedSubview(filterBar1)
        stackView.addArrangedSubview(filterBar2)
        stackView.addArrangedSubview(filterBar3)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])

        return vc
    }
}

#endif
