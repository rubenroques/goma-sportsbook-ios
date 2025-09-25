
import UIKit
import ServicesProvider
import GomaUI

final class TimeFilterBar: UIView {

    // MARK: - Public Properties

    var onFilterSelected: ((TransactionDateFilter) -> Void)?

    // MARK: - Private Properties

    private let filterData: [(filter: TransactionDateFilter, title: String)] = [
        (.all, "All"),
        (.oneDay, "1D"),
        (.oneWeek, "1W"),
        (.oneMonth, "1M"),
        (.threeMonths, "3M")
    ]
    private var buttons: [TimeFilterBarButton] = []
    private var selectedFilter: TransactionDateFilter = .all

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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = UIColor.App.backgroundPrimary
        translatesAutoresizingMaskIntoConstraints = false

        setupViewHierarchy()
        setupConstraints()
        createButtons()
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

    private func createButtons() {
        for (index, data) in filterData.enumerated() {
            let button = TimeFilterBarButton(filter: data.filter, title: data.title)
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
    }

    // MARK: - Public Methods

    func setSelectedFilter(_ filter: TransactionDateFilter) {
        selectedFilter = filter
        updateButtonStates()
    }

    // MARK: - Private Methods

    private func updateButtonStates() {
        for button in buttons {
            let isSelected = button.filterValue == selectedFilter
            button.setSelected(isSelected)
        }
    }

    // MARK: - Actions

    @objc private func buttonTapped(_ sender: UIButton) {
        guard let filterButton = sender as? TimeFilterBarButton else { return }

        let selectedFilter = filterButton.filterValue
        self.selectedFilter = selectedFilter
        updateButtonStates()
        onFilterSelected?(selectedFilter)
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("Time Filter Bar - All Selected") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .red

        let timeFilterBar = TimeFilterBar()
        timeFilterBar.setSelectedFilter(.all)
        timeFilterBar.onFilterSelected = { filter in
            print("Selected filter: \(filter)")
        }

        vc.view.addSubview(timeFilterBar)

        NSLayoutConstraint.activate([
            timeFilterBar.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timeFilterBar.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            timeFilterBar.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Time Filter Bar - 1W Selected") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .red

        let timeFilterBar = TimeFilterBar()
        timeFilterBar.setSelectedFilter(.oneWeek)
        timeFilterBar.onFilterSelected = { filter in
            print("Selected filter: \(filter)")
        }

        vc.view.addSubview(timeFilterBar)

        NSLayoutConstraint.activate([
            timeFilterBar.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timeFilterBar.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            timeFilterBar.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Time Filter Bar - 3M Selected") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .red

        let timeFilterBar = TimeFilterBar()
        timeFilterBar.setSelectedFilter(.threeMonths)
        timeFilterBar.onFilterSelected = { filter in
            print("Selected filter: \(filter)")
        }

        vc.view.addSubview(timeFilterBar)

        NSLayoutConstraint.activate([
            timeFilterBar.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timeFilterBar.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            timeFilterBar.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Time Filter Bar - Interactive Test") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .red

        // Create multiple filter bars to test different states
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill

        // All selected
        let filterBar1 = TimeFilterBar()
        filterBar1.setSelectedFilter(.all)
        filterBar1.onFilterSelected = { filter in
            print("FilterBar1 selected: \(filter)")
        }

        // 1D selected
        let filterBar2 = TimeFilterBar()
        filterBar2.setSelectedFilter(.oneDay)
        filterBar2.onFilterSelected = { filter in
            print("FilterBar2 selected: \(filter)")
        }

        // 1M selected
        let filterBar3 = TimeFilterBar()
        filterBar3.setSelectedFilter(.oneMonth)
        filterBar3.onFilterSelected = { filter in
            print("FilterBar3 selected: \(filter)")
        }

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
