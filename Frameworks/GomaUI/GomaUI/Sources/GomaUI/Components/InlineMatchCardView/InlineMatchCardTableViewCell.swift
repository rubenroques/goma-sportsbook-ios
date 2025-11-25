import UIKit
import Combine
import SwiftUI

/// Table view cell wrapper for InlineMatchCardView
/// Provides container styling and corner radius handling for grouped table views
final public class InlineMatchCardTableViewCell: UITableViewCell {

    // MARK: - Constants
    struct Constants {
        static let verticalSpacing: CGFloat = 9
        static let horizontalSpacing: CGFloat = 13
        static let bottomSpacing: CGFloat = 1
        static let cornerRadius: CGFloat = 12
    }

    // MARK: - Properties
    private let cardView: InlineMatchCardView

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundCards
        return view
    }()

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Public Callbacks
    public var onCardTapped: (() -> Void)?
    public var onOutcomeSelected: ((String) -> Void)?
    public var onOutcomeDeselected: ((String) -> Void)?
    public var onMoreMarketsTapped: (() -> Void)?

    // MARK: - Cell Identifier
    public static let identifier = "InlineMatchCardTableViewCell"

    // MARK: - Initialization
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.cardView = InlineMatchCardView(viewModel: nil)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Cell Lifecycle
    public override func prepareForReuse() {
        super.prepareForReuse()
        cardView.prepareForReuse()
        cancellables.removeAll()

        // Reset callbacks
        onCardTapped = nil
        onOutcomeSelected = nil
        onOutcomeDeselected = nil
        onMoreMarketsTapped = nil
    }

    // MARK: - Setup
    private func setupCell() {
        selectionStyle = .none
        contentView.backgroundColor = StyleProvider.Color.backgroundPrimary
        backgroundColor = StyleProvider.Color.backgroundPrimary

        contentView.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalSpacing),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalSpacing),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.bottomSpacing)
        ])

        cardView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.verticalSpacing),
            cardView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.verticalSpacing)
        ])
    }

    // MARK: - Configuration
    public func configure(with viewModel: InlineMatchCardViewModelProtocol) {
        cardView.configure(with: viewModel)
        setupCardViewCallbacks()
    }

    /// Configure cell position for proper corner radius styling
    public func configureCellPosition(isFirst: Bool, isLast: Bool) {
        if isFirst && isLast {
            // Single cell - all corners rounded
            containerView.layer.cornerRadius = Constants.cornerRadius
            containerView.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner,
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
        } else if isFirst {
            // First cell - top corners rounded
            containerView.layer.cornerRadius = Constants.cornerRadius
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLast {
            // Last cell - bottom corners rounded
            containerView.layer.cornerRadius = Constants.cornerRadius
            containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            // Middle cell - no corners rounded
            containerView.layer.cornerRadius = 0
        }

        containerView.layer.masksToBounds = true
    }

    // MARK: - Private Methods
    private func setupCardViewCallbacks() {
        cardView.onCardTapped = { [weak self] in
            self?.onCardTapped?()
        }

        cardView.onOutcomeSelected = { [weak self] outcomeId in
            self?.onOutcomeSelected?(outcomeId)
        }

        cardView.onOutcomeDeselected = { [weak self] outcomeId in
            self?.onOutcomeDeselected?(outcomeId)
        }

        cardView.onMoreMarketsTapped = { [weak self] in
            self?.onMoreMarketsTapped?()
        }
    }
}

// MARK: - Preview Provider
#if DEBUG
@available(iOS 17.0, *)
#Preview("InlineMatchCardTableViewCell") {
    PreviewUIViewController {
        let vc = TableViewController()
        return vc
    }
}

// MARK: - Preview Table View Controller
@available(iOS 17.0, *)
private class TableViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = StyleProvider.Color.backgroundPrimary
        table.separatorStyle = .none
        table.register(InlineMatchCardTableViewCell.self, forCellReuseIdentifier: InlineMatchCardTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 120
        return table
    }()

    private let mockViewModels: [MockInlineMatchCardViewModel] = [
        .preLiveFootball,
        .liveTennis,
        .withSelectedOutcome,
        .liveFootball,
        .preLiveFootball,
        .liveTennis,
        .withSelectedOutcome,
        .liveFootball
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

@available(iOS 17.0, *)
extension TableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : mockViewModels.count - 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InlineMatchCardTableViewCell.identifier, for: indexPath) as! InlineMatchCardTableViewCell

        let viewModelIndex = indexPath.section == 0 ? 0 : indexPath.row + 1
        let viewModel = mockViewModels[viewModelIndex]

        cell.configure(with: viewModel)

        // Configure corner radius based on position
        let isFirst = indexPath.row == 0
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        let isLast = indexPath.row == numberOfRows - 1

        cell.configureCellPosition(isFirst: isFirst, isLast: isLast)

        // Setup callbacks
        cell.onCardTapped = {
            print("Card tapped at section \(indexPath.section), row \(indexPath.row)")
        }

        cell.onOutcomeSelected = { outcomeId in
            print("Outcome selected: \(outcomeId)")
        }

        cell.onOutcomeDeselected = { outcomeId in
            print("Outcome deselected: \(outcomeId)")
        }

        cell.onMoreMarketsTapped = {
            print("More markets tapped")
        }

        return cell
    }
}

@available(iOS 17.0, *)
extension TableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Single Cell (All Corners)" : "Multiple Cells (Grouped)"
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = StyleProvider.Color.textSecondary
            header.textLabel?.font = StyleProvider.fontWith(type: .medium, size: 14)
        }
    }
}
#endif
